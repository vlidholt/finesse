import 'package:example/common/app_state.dart';
import 'package:example/common/page_switch.dart';
import 'package:example/strand/data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/screens/home_screen.dart';
import 'package:example/strand/screens/jobs_screen.dart';
import 'package:example/strand/screens/messages_screen.dart';
import 'package:example/strand/screens/network_screen.dart';
import 'package:example/strand/screens/notifications_screen.dart';
import 'package:example/strand/screens/profile_screen.dart';
import 'package:example/strand/screens/search_screen.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/compose_dialog.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/search_bar.dart';
import 'package:example/strand/widgets/strand_logo.dart';
import 'package:example/strand/widgets/user_menu.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

export 'package:example/strand/navigation.dart';

/// Strand's chrome: the app bar and navigation around the screen of the
/// selected [StrandDestination].
///
/// A [NavigationScaffold], so it follows the theme's form factor:
///
/// * **Desktop** — one app bar: logo, the search field (a
///   `StrandSearchBar`, which shows live results under itself), the five
///   top destinations, the dark-mode button and the avatar pill, which
///   opens the [UserMenu] (profile, saved items, settings, component
///   library, theme editor).
/// * **Phone** — a short app bar with the logo and three icon buttons
///   (search, notifications, messages), and a floating bottom bar with Home,
///   Network, the "Create post" action, Jobs and Me.
///
/// ## How a screen plugs in
///
/// A screen is the widget [StrandShell] builds for its destination; it
/// returns page content — normally a `PageContainer` — and never touches
/// this file. The scaffold's bars are laid *over* the screen, and the
/// screen's `MediaQuery` padding already accounts for them, so a
/// `PageContainer`, a `ListView` or a `SafeArea` clears them by itself.
/// Screens stay alive once visited, so scroll position survives a round
/// trip.
///
/// To navigate, write to [strandDestinationProvider] — or call
/// `context.goTo(StrandDestination.jobs)`; from a page pushed over the
/// shell, `context.leaveTo(...)` closes the page on the way.
///
/// What more than one screen shows — the unread notifications the bell
/// counts, the invitations, the recent searches, the settings — is in the
/// `StrandSession` (`session.dart`), reached with `context.strand`.
///
/// ## Full-screen routes
///
/// Some pages need the whole viewport: on a phone the Messages design is a
/// conversation with its own header and no bottom bar. Such a page is not a
/// destination. The screen pushes it as a route:
///
/// ```dart
/// context.pushFullScreen((context) => const ConversationScreen());
/// // which is
/// Navigator.of(context).push(
///   FinessePageRoute<void>(builder: (context) => const ConversationScreen()),
/// );
/// ```
///
/// and the page is a `Scaffold` with its own `AppBar` that calls
/// `Navigator.of(context).pop()` to go back. `Navigator.of(context)` inside
/// Strand is the navigator `AppShell` hosts in its page area, so the route
/// covers this shell's bars but not the theme editor panel docked beside
/// it; the theme, the form factor and every app-level provider (this
/// file's, and those in `common/app_state.dart`) reach it unchanged.
/// `SearchScreen` and `SettingsScreen` are working examples.
///
/// On a phone the shell shows no app bar over the Profile destination,
/// because the design's cover photo runs to the top of the screen.
class StrandShell extends StatelessWidget {
  const StrandShell({super.key});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, _) {
        final destinationSignal = strandDestinationProvider.of(context);
        final destination = destinationSignal.value;
        final dark = themeModeProvider.of(context).value == ThemeMode.dark;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        void goTo(StrandDestination next) => destinationSignal.value = next;
        final notifications = context.strand.notifications;

        // The bell counts the unread notifications, which are not a signal.
        return ListenableBuilder(
          listenable: notifications,
          builder: (context, _) => NavigationScaffold(
            selectedIndex: destination.index,
            onDestinationSelected: (index) =>
                goTo(StrandDestination.values[index]),
            // In the order of [StrandDestination], so an index is an enum
            // value.
            destinations: [
              const NavigationDestination(
                icon: Icon(PhosphorIconsRegular.house),
                selectedIcon: Icon(PhosphorIconsFill.house),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(PhosphorIconsRegular.usersThree),
                selectedIcon: Icon(PhosphorIconsFill.usersThree),
                label: 'Network',
              ),
              const NavigationDestination(
                icon: Icon(PhosphorIconsRegular.briefcase),
                selectedIcon: Icon(PhosphorIconsFill.briefcase),
                label: 'Jobs',
              ),
              const NavigationDestination(
                icon: Icon(PhosphorIconsRegular.chatCircleDots),
                selectedIcon: Icon(PhosphorIconsFill.chatCircleDots),
                label: 'Messages',
                badgeCount: StrandCounts.unreadMessages,
                // On a phone: the app bar's button.
                showInBottomBar: false,
              ),
              NavigationDestination(
                icon: const Icon(PhosphorIconsRegular.bell),
                selectedIcon: const Icon(PhosphorIconsFill.bell),
                label: 'Notifications',
                badgeCount: notifications.unreadCount,
                showInBottomBar: false,
              ),
              NavigationDestination(
                // 28 is the design's size for the tab's portrait.
                icon: const PersonAvatar(People.me, size: 28),
                selectedIcon: PersonAvatar(
                  People.me,
                  size: 28,
                  ringColor: colors.tint,
                ),
                label: 'Me',
                // On a desktop: the avatar pill's menu.
                showInTopBar: false,
              ),
            ],
            // The logo and the search field together, as the bar's flexible
            // title rather than as `leading` + `title`: a leading widget is
            // laid out at its natural width, and the pair has to give way in
            // a narrow window (see [_BarStart]).
            title: _BarStart(onLogoPressed: () => goTo(StrandDestination.home)),
            actions: [
              IconButton.secondary(
                size: ButtonSize.lg,
                // The design's `--fill`, one step quieter than the secondary
                // button's own fill.
                backgroundColor: colors.muted,
                hoverBackgroundColor: colors.secondary,
                icon: Icon(
                  dark ? PhosphorIconsRegular.sun : PhosphorIconsRegular.moon,
                ),
                semanticLabel: 'Toggle dark mode',
                onPressed: () => toggleThemeMode(context),
              ),
              const _AvatarPill(),
            ],
            action: NavigationAction(
              icon: const Icon(PhosphorIconsRegular.plus),
              label: 'Create post',
              onPressed: () => showComposeDialog(context),
            ),
            mobileAppBar: _MobileAppBar(
              destination: destination,
              unreadNotifications: notifications.unreadCount,
              onSelected: goTo,
            ),
            showMobileAppBar: destination != StrandDestination.profile,
            body: _Screens(destination: destination),
          ),
        );
      },
    );
  }
}

/// The start of the desktop app bar: the logo, then the search field.
///
/// The bar gives this zone whatever is left beside the centred navigation —
/// 396 logical pixels in the designs' 1440 window, where everything fits,
/// and next to nothing just above the phone breakpoint. So it sheds in
/// order: the search field narrows and then goes (it collapses itself), and
/// last the logo drops its wordmark.
class _BarStart extends StatelessWidget {
  const _BarStart({required this.onLogoPressed});

  final VoidCallback onLogoPressed;

  @override
  Widget build(BuildContext context) {
    // The gap the app bar itself puts between a leading widget and a title.
    final gap = (Theme.of(context).appBarTheme.gap ?? 24) - 4;
    final logoWidth = StrandLogo.widthOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showWordmark = constraints.maxWidth >= logoWidth;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StrandLogo(onPressed: onLogoPressed, showWordmark: showWordmark),
            if (showWordmark) ...[
              Gap.raw(gap),
              const Flexible(child: StrandSearchBar()),
            ],
          ],
        );
      },
    );
  }
}

/// The phone's app bar: the logo, then search, notifications and messages.
///
/// The designs inset it 16 at the start but only 8 at the end, so the last
/// 44-point button's glyph — not its box — lines up with the page margin.
class _MobileAppBar extends StatelessWidget {
  const _MobileAppBar({
    required this.destination,
    required this.unreadNotifications,
    required this.onSelected,
  });

  final StrandDestination destination;
  final int unreadNotifications;
  final ValueChanged<StrandDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final start = (layout.pagePadding ?? const EdgeInsets.all(16))
        .resolve(Directionality.of(context))
        .left;

    Widget action({
      required StrandDestination target,
      required IconData icon,
      required IconData selectedIcon,
      required String label,
      required int count,
    }) {
      final selected = destination == target;
      return IndicatorBadge(
        count: count,
        // Inside the button's box, 2 below its top edge, as in the designs.
        overhang: 0,
        offset: const Offset(0, 2),
        semanticLabel: '$count unread',
        child: IconButton.ghost(
          icon: Icon(selected ? selectedIcon : icon),
          foregroundColor: selected ? theme.colorScheme.tint : null,
          semanticLabel: label,
          onPressed: () => onSelected(target),
        ),
      );
    }

    return AppBar(
      padding: EdgeInsetsDirectional.only(
        start: start,
        end: layout.gap(GapSize.sm),
      ),
      actionsGap: 0,
      leading: StrandLogo(onPressed: () => onSelected(StrandDestination.home)),
      actions: [
        IconButton.ghost(
          icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
          semanticLabel: 'Search',
          onPressed: () =>
              context.pushFullScreen<void>((context) => const SearchScreen()),
        ),
        action(
          target: StrandDestination.notifications,
          icon: PhosphorIconsRegular.bell,
          selectedIcon: PhosphorIconsFill.bell,
          label: 'Notifications',
          count: unreadNotifications,
        ),
        action(
          target: StrandDestination.messages,
          icon: PhosphorIconsRegular.chatCircleDots,
          selectedIcon: PhosphorIconsFill.chatCircleDots,
          label: 'Messages',
          count: StrandCounts.unreadMessages,
        ),
      ],
    );
  }
}

/// The desktop app bar's last action: the signed-in user's portrait and a
/// caret in a glass pill, opening the [UserMenu].
class _AvatarPill extends StatelessWidget {
  const _AvatarPill();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UserMenu(
      builder: (context, controller, _) => Pressable(
        onPressed: controller.toggle,
        semanticLabel: 'Your profile',
        builder: (context, states) => FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: theme.radii.full,
          child: Glass(
            level: GlassLevel.strong,
            borderRadius: theme.radii.full,
            // The pill hugs its 32-point portrait: 3 around it, 8 after the
            // caret. Neither is on the spacing scale.
            padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 8, 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PersonAvatar(People.me, size: 32),
                const Gap.raw(6),
                Icon(
                  PhosphorIconsRegular.caretDown,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The screens, one per destination.
///
/// A screen is built the first time its destination is shown and kept alive
/// from then on, so going back to it finds it where it was left. Screens
/// that are not showing do not tick: an `IndexedStack` installs no
/// `TickerMode` of its own, and an offstage spinner would otherwise keep the
/// app from ever idling.
///
/// The screen that is switched to comes in from the side its destination is
/// on (see [PageSwitch]); the stack under it is the same one throughout, so
/// the transition costs no screen its state.
class _Screens extends StatefulWidget {
  const _Screens({required this.destination});

  final StrandDestination destination;

  @override
  State<_Screens> createState() => _ScreensState();
}

class _ScreensState extends State<_Screens> {
  late final _visited = <StrandDestination>{widget.destination};

  @override
  void didUpdateWidget(_Screens oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visited.add(widget.destination);
  }

  static Widget _screen(StrandDestination destination) => switch (destination) {
    StrandDestination.home => const HomeScreen(),
    StrandDestination.network => const NetworkScreen(),
    StrandDestination.jobs => const JobsScreen(),
    StrandDestination.messages => const MessagesScreen(),
    StrandDestination.notifications => const NotificationsScreen(),
    StrandDestination.profile => const ProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return PageSwitch(
      value: widget.destination.index,
      child: IndexedStack(
        index: widget.destination.index,
        children: [
          for (final destination in StrandDestination.values)
            TickerMode(
              enabled: destination == widget.destination,
              child: _visited.contains(destination)
                  ? KeyedSubtree(
                      key: ValueKey(destination),
                      child: _screen(destination),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
