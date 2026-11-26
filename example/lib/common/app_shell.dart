import 'dart:math' as math;

import 'package:example/common/app_state.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/una_logo.dart';
import 'package:example/screens/components_screen.dart';
import 'package:example/showcase/showcase_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:una/una.dart';

/// The application frame: the page, with the theme customizer docked beside
/// it when it is open.
///
/// The page is a [Navigator] showing the component library and whatever
/// full-screen routes a docs example pushes on top of it. Because the
/// navigator is *inside* the frame, such a route covers the library's own
/// chrome but leaves the editor panel docked, so it can still be re-themed
/// live.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Below this window width the docked panel would leave the app too narrow
  /// to use, so it takes the viewport instead.
  static const narrowBreakpoint = 700.0;

  /// Whether the panel sits beside the page — rather than over it — in a
  /// window [windowWidth] wide.
  static bool docksEditor(double windowWidth) =>
      windowWidth >= narrowBreakpoint;

  /// The width left for the page in a window [windowWidth] wide.
  ///
  /// `App` picks the theme's form factor from this rather than from the
  /// window, so docking the editor beside a medium-width window lays the
  /// page out for the phone-sized space it actually has.
  static double pageWidth(double windowWidth, {required bool editorOpen}) =>
      editorOpen && docksEditor(windowWidth)
      ? windowWidth - ThemeCustomizerPanel.width
      : windowWidth;

  /// The form factor the app is themed for in a window [windowWidth] wide:
  /// the one the editor pins, or else the one the page's width calls for —
  /// a phone below [breakpoint], the theme's `md`.
  ///
  /// `App` passes this to `UnaApp` and the shell lays the page out for
  /// it, so the two are computed in one place.
  static FormFactor formFactorFor(
    double windowWidth, {
    required bool editorOpen,
    required EditorFormFactor mode,
    required double breakpoint,
  }) => mode.resolve(
    pageWidth(windowWidth, editorOpen: editorOpen),
    breakpoint: breakpoint,
  );

  /// The size of the frame the phone layout is shown in when the editor pins
  /// it on a window wide enough for a desktop: the designs' phone canvas.
  static const phoneFrame = Size(390, 844);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  /// The width from which the app opens with the editor beside it: room
  /// for the panel and a desktop page.
  static const _editorOnStartWidth = 1100.0;

  bool _checkedStart = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedStart) return;
    _checkedStart = true;
    if (!openEditorOnDesktop) return;
    final width = MediaQuery.sizeOf(context).width;
    if (width < _editorOnStartWidth) return;
    // After the first frame: the panel slides in beside the page it is
    // about to restyle, which says what it is for.
    final open = themeEditorOpenProvider.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) open.value = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, _) {
        final openSignal = themeEditorOpenProvider.of(context);
        final configSignal = themeConfigProvider.of(context);
        // Read both here rather than inside the LayoutBuilder below: that
        // callback runs during layout, outside the scope SignalBuilder
        // tracks, so a read in there never subscribes.
        final open = openSignal.value;
        final config = configSignal.value;

        ThemeCustomizerPanel panel({
          required bool docked,
          required ThemeData theme,
        }) => ThemeCustomizerPanel(
          config: config,
          onChanged: (next) => configSignal.value = next,
          // The lists of colours and metrics edit what the app shows.
          brightness: theme.brightness,
          formFactor: theme.formFactor,
          showLeadingBorder: docked,
          // Covering the viewport, it also covers every button that
          // could close it again.
          onClose: docked ? null : () => openSignal.value = false,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final docked = AppShell.docksEditor(width);
            final media = MediaQuery.of(context);
            final theme = Theme.of(context);

            final height = constraints.maxHeight;
            final breakpoint = theme.breakpoints.md.value;

            // `App` picks the form factor from the width the page will
            // have, and `UnaApp` applies a theme in the build it is
            // given in, so the two normally agree. Should a theme ever
            // arrive late (an app that lerps its theme), docking the panel
            // at once would squeeze a desktop layout into a phone-sized
            // box, so the page keeps its width — with the panel over its
            // edge — until the theme has caught up.
            final targetWidth = AppShell.pageWidth(width, editorOpen: open);
            final targetFormFactor = AppShell.formFactorFor(
              width,
              editorOpen: open,
              mode: config.formFactor,
              breakpoint: breakpoint,
            );
            final isDesktop = theme.formFactor == FormFactor.desktop;
            final areaWidth =
                isDesktop &&
                    targetFormFactor == FormFactor.mobile &&
                    config.formFactor == EditorFormFactor.auto
                ? width
                : targetWidth;

            // The editor can pin a form factor the page's width would not
            // have picked. Either way the layout gets the room it was
            // designed for, and the box it is shown in is fitted to that:
            //
            // * a desktop layout in less than a desktop's width is laid out
            //   at the breakpoint and scaled down to fit, rather than
            //   overflowing;
            // * a phone layout on a wide page is shown in a phone-sized
            //   frame, rather than stretched across the window.
            //
            // Both go by the form factor the theme *has*, not the one it is
            // heading for, so the frame arrives with the layout it frames.
            final fitsDesktop = isDesktop && areaWidth < breakpoint;
            final framesPhone =
                !isDesktop &&
                config.formFactor == EditorFormFactor.mobile &&
                areaWidth >= breakpoint;

            var box = Rect.fromLTWH(0, 0, areaWidth, height);
            var layout = box.size;
            if (fitsDesktop && areaWidth > 0) {
              layout = Size(breakpoint, height * breakpoint / areaWidth);
            } else if (framesPhone) {
              final frame = Size(
                AppShell.phoneFrame.width,
                // A margin above and below, so it reads as a device.
                math.min(AppShell.phoneFrame.height, math.max(0, height - 32)),
              );
              box = Alignment.center.inscribe(frame, box);
              layout = frame;
            }

            // The page is always the same child of the Stack, under the
            // same ancestors, so opening the panel — or framing the page —
            // never reshapes the element above it. Building it
            // conditionally instead threw away the docs browser's state —
            // which read as "the editor does not affect this page", since
            // it also bounced you back to the first component.
            return Stack(
              children: [
                // What shows around the phone frame.
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: areaWidth,
                  child: ColoredBox(
                    color: framesPhone
                        ? theme.colorScheme.muted
                        : theme.colorScheme.background,
                  ),
                ),
                PositionedDirectional(
                  start: box.left,
                  top: box.top,
                  width: box.width,
                  height: box.height,
                  child: _PageFrame(
                    framed: framesPhone,
                    layoutSize: layout,
                    // Breakpoints below read the window width from
                    // MediaQuery; tell them how wide the page really is.
                    child: MediaQuery(
                      data: media.copyWith(size: layout),
                      child: _PageNavigator(navigatorKey: _navigatorKey),
                    ),
                  ),
                ),
                // Docked beside the page on a wide window. On a narrow one
                // it covers the page rather than squeezing it, and carries
                // its own close button. Always in the stack, after the
                // page: it slides in and out, and builds nothing while it
                // is away.
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  bottom: 0,
                  width: docked ? ThemeCustomizerPanel.width : width,
                  child: _SlideFromEnd(
                    visible: open,
                    child: panel(docked: docked, theme: theme),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Slides the editor panel in from the end edge of the window, and out
/// again, on the theme's surface spring.
///
/// Only the panel moves. The page takes its new width at once — animating
/// that would lay the whole app out again on every frame — and the panel
/// arrives over the room that was made for it, or leaves over the page that
/// has already spread out under it. While it is away it builds nothing and
/// takes no pointers; with reduced motion it is simply there or not.
///
/// The panel is handed over as a widget, built once per build of the shell,
/// and passed through the spring's `child`: built inside the spring's
/// `builder` it would be a new widget on every tick, and the whole editor —
/// every picker and slider row — would rebuild on every frame of the slide.
/// Away, the widget is constructed but never inflated.
class _SlideFromEnd extends StatelessWidget {
  const _SlideFromEnd({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SpringBuilder(
      value: visible ? 1 : 0,
      spring: Motion.of(context).smooth,
      child: child,
      builder: (context, value, child) {
        final t = value.clamp(0.0, 1.0);
        if (t <= .001 && !visible) return const SizedBox.shrink();
        return ClipRect(
          child: FractionalTranslation(
            translation: Offset((1 - t) * (rtl ? -1 : 1), 0),
            // Gone as far as input goes the moment it is told to leave.
            child: IgnorePointer(ignoring: !visible, child: child),
          ),
        );
      },
    );
  }
}

/// The box the page is shown in.
///
/// The page is laid out at [layoutSize] and fitted to the box: the two are
/// the same size except when the editor pins the desktop layout on a narrow
/// page, where the layout is larger and is scaled down. When [framed] — the
/// phone layout pinned on a wide page — the box gets a phone's rounded
/// outline.
///
/// The same widgets are built in every case, so switching between them
/// keeps the page's state.
class _PageFrame extends StatelessWidget {
  const _PageFrame({
    required this.framed,
    required this.layoutSize,
    required this.child,
  });

  final bool framed;
  final Size layoutSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = framed
        ? const BorderRadius.all(Radius.circular(36))
        : BorderRadius.zero;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: framed
            ? Border.all(color: Theme.of(context).colorScheme.borderStrong)
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        clipBehavior: framed ? Clip.antiAlias : Clip.none,
        child: FittedBox(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox.fromSize(size: layoutSize, child: child),
        ),
      ),
    );
  }
}

/// The navigator in the page area. Its first route is the component
/// library; docs examples push full-screen routes above it.
class _PageNavigator extends StatefulWidget {
  const _PageNavigator({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<_PageNavigator> {
  /// Whether a full-screen route is showing above the library.
  final _canPop = ValueNotifier(false);
  late final _observer = _CanPopObserver(_canPop);

  @override
  void dispose() {
    _canPop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      key: widget.navigatorKey,
      observers: [_observer],
      onGenerateRoute: (settings) => UnaPageRoute<void>(
        settings: settings,
        builder: (context) => ColoredBox(
          color: Theme.of(context).colorScheme.background,
          child: const ComponentsSection(),
        ),
      ),
    );
    // The system back gesture goes to the root navigator, which has nothing
    // to pop; hand it to this one while it has a route to close, and let it
    // leave the app otherwise.
    return ValueListenableBuilder(
      valueListenable: _canPop,
      child: navigator,
      builder: (context, canPop, child) => NavigatorPopHandler(
        enabled: canPop,
        onPopWithResult: (_) => widget.navigatorKey.currentState?.maybePop(),
        child: child!,
      ),
    );
  }
}

class _CanPopObserver extends NavigatorObserver {
  _CanPopObserver(this.canPop);

  final ValueNotifier<bool> canPop;

  void _update() {
    // After the frame: a route change can arrive while the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      canPop.value = navigator?.canPop() ?? false;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _update();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _update();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _update();
}

/// The component-library browser under a slim app bar: light/dark, text
/// direction and the theme editor.
class ComponentsSection extends StatelessWidget {
  const ComponentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // The app's two halves are destinations, as in any app: tabs in the
    // top bar on a desktop, the floating bar at the bottom on a phone.
    return SignalBuilder(
      builder: (context, _) {
        final section = appSectionProvider.of(context);
        final current = section.value;
        return NavigationScaffold(
          selectedIndex: current.index,
          onDestinationSelected: (index) =>
              section.value = AppSection.values[index],
          destinations: const [
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.sparkle),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.sparkle),
              label: 'Showcase',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.squaresFour),
              selectedIcon: PhosphorIcon(PhosphorIconsFill.squaresFour),
              label: 'Components',
            ),
          ],
          // Leading, not the title: a phone's bar keeps the leading widget
          // and its actions only.
          leading: const UnaLogo(),
          actions: const [
            _ThemeModeButton(),
            _DirectionButton(),
            _ThemeEditorButton(),
          ],
          // Both stay built, so switching keeps the page you were on and
          // the showcase's scroll; the hidden one is off stage and its
          // tickers stop.
          body: IndexedStack(
            index: current.index,
            children: [
              for (final s in AppSection.values)
                TickerMode(
                  enabled: s == current,
                  child: switch (s) {
                    AppSection.showcase => const ShowcaseScreen(),
                    // The docs browser fills its box and does not inset
                    // itself for bars laid over it: it starts below the top
                    // bar and ends above the bottom one.
                    AppSection.components => const _UnderBars(
                      child: ComponentsScreen(),
                    ),
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Shows and hides the customizer.
class _ThemeEditorButton extends StatelessWidget {
  const _ThemeEditorButton();

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, _) {
        final open = themeEditorOpenProvider.of(context);
        void toggle() => open.value = !open.value;
        final icon = PhosphorIcon(
          PhosphorIconsRegular.paintBrush,
          semanticLabel: open.value
              ? 'Hide the theme editor'
              : 'Show the theme editor',
        );
        // The pressed-in secondary variant is what marks the panel as open.
        return open.value
            ? IconButton.secondary(icon: icon, onPressed: toggle)
            : IconButton.ghost(icon: icon, onPressed: toggle);
      },
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton();

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, _) {
        final mode = themeModeProvider.of(context).value;
        final isLight = mode == ThemeMode.light;
        return IconButton.ghost(
          icon: PhosphorIcon(
            isLight ? PhosphorIconsRegular.sun : PhosphorIconsRegular.moon,
            semanticLabel: isLight
                ? 'Switch to dark mode'
                : 'Switch to light mode',
          ),
          onPressed: () => toggleThemeMode(context),
        );
      },
    );
  }
}

class _DirectionButton extends StatelessWidget {
  const _DirectionButton();

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, _) {
        final direction = directionalityProvider.of(context).value;
        final isLtr = direction == TextDirection.ltr;
        return IconButton.ghost(
          icon: PhosphorIcon(
            isLtr
                ? PhosphorIconsRegular.textAlignLeft
                : PhosphorIconsRegular.textAlignRight,
            semanticLabel: isLtr ? 'Switch to RTL' : 'Switch to LTR',
          ),
          onPressed: () {
            directionalityProvider
                .of(context)
                .updateValue(
                  (value) => value == TextDirection.ltr
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                );
          },
        );
      },
    );
  }
}

/// [child] inset by the bars the scaffold lays over it, which it is then
/// told nothing of.
class _UnderBars extends StatelessWidget {
  const _UnderBars({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: child,
      ),
    );
  }
}
