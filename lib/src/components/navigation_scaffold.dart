import 'package:flutter/widgets.dart';
import 'package:una/src/components/app_bar.dart';
import 'package:una/src/components/navigation_bar.dart';
import 'package:una/src/components/navigation_rail.dart';
import 'package:una/src/components/scaffold.dart';
import 'package:una/src/theme/form_factor.dart';
import 'package:una/src/theme/theme.dart';

/// Where a [NavigationScaffold] puts its destinations.
enum NavigationLayout {
  /// By form factor: a bottom bar on a phone, the top bar on a desktop.
  auto,

  /// A `BottomNavigationBar`, whatever the form factor.
  bottomBar,

  /// A `NavigationBar` in the middle of the app bar, whatever the form
  /// factor.
  topBar,

  /// A rail down the start edge, under the app bar — an icon over a small
  /// label, styled by `ThemeData.navigationRailTheme`: a tablet, or a
  /// desktop app whose top bar is needed for other things.
  rail,
}

/// A [Scaffold] whose navigation adapts to the theme's form factor.
///
/// On a desktop the [destinations] sit in the middle of the [AppBar], between
/// [leading], [title] and [actions]. On a phone the app bar shrinks to
/// [leading] and [mobileActions], and the destinations move to a
/// [BottomNavigationBar] with [action] in its middle. [layout] overrides the
/// choice, or picks a third: a rail down the start edge
/// ([NavigationLayout.rail]).
///
/// ```dart
/// NavigationScaffold(
///   leading: const Logo(),
///   title: const SearchField(),
///   destinations: destinations,
///   selectedIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
///   action: NavigationAction(
///     icon: const PhosphorIcon(PhosphorIconsRegular.plus),
///     label: 'Create post',
///     onPressed: _compose,
///   ),
///   body: DestinationStack(index: index, builders: pages),
/// )
/// ```
///
/// A destination can opt out of a bar with
/// [NavigationDestination.showInTopBar],
/// [NavigationDestination.showInBottomBar] and
/// [NavigationDestination.showInRail] — notifications that live in the top
/// bar on a desktop but behind an app bar button on a phone, say.
/// [selectedIndex] and [onDestinationSelected] always use indices into the
/// full [destinations] list.
///
/// The scaffold shows one [body]. To keep each destination's page alive
/// with its scroll offset and state, make the body a `DestinationStack`.
class NavigationScaffold extends StatelessWidget {
  /// Creates an adaptive navigation scaffold.
  const NavigationScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.body,
    this.onDestinationSelected,
    this.layout = NavigationLayout.auto,
    this.leading,
    this.title,
    this.actions = const [],
    this.mobileActions,
    this.action,
    this.mobileAppBar,
    this.showMobileAppBar = true,
    this.showBottomNavigationBar = true,
    this.railExtended = false,
    this.railTrailing,
    this.backgroundColor,
    super.key,
  });

  /// Every destination of the app.
  final List<NavigationDestination> destinations;

  /// The index into [destinations] of the selected one.
  final int? selectedIndex;

  /// Called with the index into [destinations] of the one that was tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// The page.
  final Widget body;

  /// Where the destinations go. Defaults to [NavigationLayout.auto].
  final NavigationLayout layout;

  /// The widget at the start of the app bar, usually a logo.
  final Widget? leading;

  /// The widget after [leading] on a desktop, usually a search field.
  final Widget? title;

  /// The app bar's actions on a desktop.
  final List<Widget> actions;

  /// The app bar's actions with a bottom bar. Defaults to [actions].
  final List<Widget>? mobileActions;

  /// The primary action: in the middle of the bottom bar, or at the top of
  /// the rail. The top bar has no place for one; put it in [actions].
  final NavigationAction? action;

  /// Replaces the app bar over a bottom bar, for a screen with its own
  /// header such as a conversation.
  final Widget? mobileAppBar;

  /// Whether the bottom bar layout shows an app bar at all.
  final bool showMobileAppBar;

  /// Whether the bottom bar layout shows its bottom bar. Turn it off for a
  /// screen that needs the whole height, such as a conversation.
  final bool showBottomNavigationBar;

  /// Whether the rail shows its labels beside the icons, in a wider rail,
  /// rather than under them. A change is animated on the theme's
  /// `Motion.smooth`.
  final bool railExtended;

  /// Shown at the bottom of the rail, centred under the icons: settings,
  /// an avatar.
  final Widget? railTrailing;

  /// The page's colour. Defaults to the theme's background.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = switch (layout) {
      NavigationLayout.auto =>
        theme.formFactor == FormFactor.desktop
            ? NavigationLayout.topBar
            : NavigationLayout.bottomBar,
      final chosen => chosen,
    };

    // The destinations a bar lists, as indices into the full list, and
    // which of them is the selected one.
    (List<int>, int?) shown(bool Function(NavigationDestination) test) {
      final indices = [
        for (final (index, destination) in destinations.indexed)
          if (test(destination)) index,
      ];
      final selected = selectedIndex == null
          ? -1
          : indices.indexOf(selectedIndex!);
      return (indices, selected < 0 ? null : selected);
    }

    ValueChanged<int>? selects(List<int> indices) =>
        onDestinationSelected == null
        ? null
        : (i) => onDestinationSelected!(indices[i]);

    // The page is in the same place in the tree whatever the layout, so a
    // change of layout — a window narrowed past a breakpoint — keeps its
    // state. Only the rail's slot beside it is filled or not.
    Widget page({Widget? rail}) => Builder(
      // Under the scaffold's own media query, which says how far the app
      // bar reaches down.
      builder: (context) {
        final direction = Directionality.of(context);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The rail is part of the page as far as the scaffold goes: it
            // sits under the app bar, and keeps clear of it by the padding
            // the scaffold hands down.
            rail ?? const SizedBox.shrink(),
            Expanded(
              // The start edge is the rail's to keep clear of.
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: rail != null && direction == TextDirection.ltr,
                removeRight: rail != null && direction == TextDirection.rtl,
                child: body,
              ),
            ),
          ],
        );
      },
    );

    switch (resolved) {
      case NavigationLayout.auto:
      case NavigationLayout.topBar:
        final (indices, selected) = shown((d) => d.showInTopBar);
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            leading: leading,
            title: title,
            middle: NavigationBar(
              destinations: [for (final i in indices) destinations[i]],
              selectedIndex: selected,
              onDestinationSelected: selects(indices),
            ),
            actions: actions,
          ),
          body: page(),
        );
      case NavigationLayout.rail:
        final (indices, selected) = shown(
          (d) => d.showInRail ?? d.showInTopBar,
        );
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(leading: leading, title: title, actions: actions),
          body: page(
            rail: NavigationRail(
              destinations: [for (final i in indices) destinations[i]],
              selectedIndex: selected,
              onDestinationSelected: selects(indices),
              action: action,
              extended: railExtended,
              trailing: railTrailing,
            ),
          ),
        );
      case NavigationLayout.bottomBar:
        final (indices, selected) = shown((d) => d.showInBottomBar);
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: !showMobileAppBar
              ? null
              : mobileAppBar ??
                    AppBar(leading: leading, actions: mobileActions ?? actions),
          bottomNavigationBar: !showBottomNavigationBar
              ? null
              : BottomNavigationBar(
                  destinations: [for (final i in indices) destinations[i]],
                  selectedIndex: selected,
                  onDestinationSelected: selects(indices),
                  action: action,
                ),
          body: page(),
        );
    }
  }
}
