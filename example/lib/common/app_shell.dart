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

/// The application frame: the app's top bar across the window, the page
/// under it, and the theme customizer docked beside the page when it is
/// open.
///
/// The page is a [Navigator] showing the app's destinations
/// ([ComponentsSection]) and whatever full-screen routes a docs example
/// pushes on top of it. Because the navigator is *inside* the frame, such a
/// route covers the page — and on a phone the page's own bars — but leaves
/// the editor panel docked, so it can still be re-themed live, and on a
/// desktop it leaves the top bar too.
///
/// Where the destinations are depends on the layout the page has:
///
/// * a desktop layout at its own size: in the shell's top bar, which spans
///   the window — the logo at its leading edge and the settings at its
///   trailing one, with the editor open or not — and lies over the page and
///   the panel's column alike;
/// * a phone layout, or a desktop one the editor pinned on a page too
///   narrow for it (scaled down to fit): in the page's own bars, laid out
///   with the rest of the page.
///
/// Docked, the panel is a rounded box under the top bar, clear of the
/// window's edges by [ThemeCustomizerPanel.dockMargin]. Below
/// [narrowBreakpoint] it covers the viewport instead.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  /// Below this window width the docked panel would leave the app too narrow
  /// to use, so it takes the viewport instead.
  static const narrowBreakpoint = 700.0;

  /// Whether the panel sits beside the page — rather than over it — in a
  /// window [windowWidth] wide.
  static bool docksEditor(double windowWidth) =>
      windowWidth >= narrowBreakpoint;

  /// The width the docked panel takes out of the window: its own, and its
  /// margin on either side.
  static double get dockedPanelWidth =>
      ThemeCustomizerPanel.width + 2 * ThemeCustomizerPanel.dockMargin;

  /// The width left for the page in a window [windowWidth] wide.
  ///
  /// `App` picks the theme's form factor from this rather than from the
  /// window, so docking the editor beside a medium-width window lays the
  /// page out for the phone-sized space it actually has.
  static double pageWidth(double windowWidth, {required bool editorOpen}) =>
      editorOpen && docksEditor(windowWidth)
      ? windowWidth - dockedPanelWidth
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
        final sectionSignal = appSectionProvider.of(context);
        // Read them here rather than inside the LayoutBuilder below: that
        // callback runs during layout, outside the scope SignalBuilder
        // tracks, so a read in there never subscribes.
        final open = openSignal.value;
        final config = configSignal.value;
        final section = sectionSignal.value;

        ThemeCustomizerPanel panel({
          required bool docked,
          required ThemeData theme,
        }) => ThemeCustomizerPanel(
          config: config,
          onChanged: (next) => configSignal.value = next,
          // The lists of colours and metrics edit what the app shows.
          brightness: theme.brightness,
          formFactor: theme.formFactor,
          docked: docked,
          // Covering the viewport, it also covers every button that
          // could close it again.
          onClose: docked ? null : () => openSignal.value = false,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final docked = AppShell.docksEditor(width);
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

            // The destinations go in the window's own top bar when the page
            // is a desktop layout at its own size. A phone layout keeps its
            // bars, and a scaled-down desktop one its top bar, inside the
            // page: they are part of what the page previews.
            final barInShell = isDesktop && !fitsDesktop;

            // A scaffold whatever the layout, with the bar or without it,
            // so the page under it keeps its place in the tree. It lays the
            // bar over the page and tells the page how far down the bar
            // reaches, as a page's own scaffold does. The page's own
            // scaffolds resize for the keyboard; this one does not.
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: barInShell
                  ? _TopBar(
                      section: section,
                      onSelected: (next) => sectionSignal.value = next,
                    )
                  : null,
              body: Builder(
                builder: (context) {
                  // Under the bar's inset: the page and the panel keep
                  // clear of it.
                  final media = MediaQuery.of(context);

                  var box = Rect.fromLTWH(0, 0, areaWidth, height);
                  var layout = box.size;
                  if (fitsDesktop && areaWidth > 0) {
                    layout = Size(breakpoint, height * breakpoint / areaWidth);
                  } else if (framesPhone) {
                    final frame = Size(
                      AppShell.phoneFrame.width,
                      // A margin above and below, so it reads as a device.
                      math.min(
                        AppShell.phoneFrame.height,
                        math.max(0, height - 32),
                      ),
                    );
                    box = Alignment.center.inscribe(frame, box);
                    layout = frame;
                  }

                  final margin = ThemeCustomizerPanel.dockMargin;

                  // The page is always the same child of the Stack, under
                  // the same ancestors, so opening the panel — or framing
                  // the page, or moving the destinations between the top
                  // bar and the page — never reshapes the element above
                  // it. Building it conditionally instead threw away the
                  // docs browser's state — which read as "the editor does
                  // not affect this page", since it also bounced you back
                  // to the first component.
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
                          // MediaQuery; tell them how wide the page really
                          // is.
                          child: MediaQuery(
                            data: media.copyWith(size: layout),
                            child: ShellBar(
                              inShell: barInShell,
                              child: _PageNavigator(
                                navigatorKey: _navigatorKey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Docked beside the page on a wide window: a rounded
                      // box under the top bar, clear of the window's edges.
                      // On a narrow one it covers the page rather than
                      // squeezing it, and carries its own close button.
                      // Always in the stack, after the page: it slides in
                      // and out, and builds nothing while it is away.
                      PositionedDirectional(
                        end: 0,
                        top: docked ? media.padding.top + margin : 0,
                        bottom: docked ? media.padding.bottom + margin : 0,
                        // Docked, its slot runs on to the window's edge, so
                        // it slides in from there.
                        width: docked
                            ? ThemeCustomizerPanel.width + margin
                            : width,
                        child: _SlideFromEnd(
                          visible: open,
                          child: docked
                              // In its box nothing has a bar or a notch to
                              // keep clear of.
                              ? MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  removeLeft: true,
                                  removeRight: true,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      end: margin,
                                    ),
                                    child: panel(docked: true, theme: theme),
                                  ),
                                )
                              : panel(docked: false, theme: theme),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Whether the app's top bar, with the destinations, is the shell's — across
/// the window — rather than the page's own.
///
/// The shell puts this above the page's navigator, so the page's first
/// route can leave out what the shell already shows.
class ShellBar extends InheritedWidget {
  const ShellBar({super.key, required this.inShell, required super.child});

  /// Whether the shell shows the top bar.
  final bool inShell;

  /// Whether the shell above [context] shows the top bar; false with no
  /// shell.
  static bool inShellOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellBar>()?.inShell ?? false;

  @override
  bool updateShouldNotify(ShellBar oldWidget) => inShell != oldWidget.inShell;
}

/// The window-wide top bar of a desktop page: the logo at the leading edge,
/// the destinations, and the settings at the trailing edge.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.section, required this.onSelected});

  final AppSection section;
  final ValueChanged<AppSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Across the window, not held to the page's measure: the logo and
      // the settings stay at the window's edges.
      maxWidth: double.infinity,
      leading: const UnaLogo(),
      middle: NavigationBar(
        destinations: _destinations,
        selectedIndex: section.index,
        onDestinationSelected: (index) => onSelected(AppSection.values[index]),
      ),
      actions: _actions,
    );
  }
}

/// The app's destinations, in [AppSection] order.
const _destinations = [
  NavigationDestination(
    icon: PhosphorIcon(PhosphorIconsRegular.balloon),
    selectedIcon: PhosphorIcon(PhosphorIconsFill.balloon),
    label: 'Showcase',
  ),
  NavigationDestination(
    icon: PhosphorIcon(PhosphorIconsRegular.bookOpen),
    selectedIcon: PhosphorIcon(PhosphorIconsFill.bookOpen),
    label: 'Introduction',
  ),
  NavigationDestination(
    icon: PhosphorIcon(PhosphorIconsRegular.squaresFour),
    selectedIcon: PhosphorIcon(PhosphorIconsFill.squaresFour),
    label: 'Components',
  ),
];

/// The bar's settings: light/dark, text direction and the theme editor.
const _actions = [_ThemeModeButton(), _DirectionButton(), _ThemeEditorButton()];

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

/// The app's destinations — the showcase, and the docs browser on its
/// introduction or its components — with their bars when the shell does
/// not show them (see [AppShell]): a phone's app bar and bottom bar, or the
/// top bar of a desktop layout scaled down to fit.
class ComponentsSection extends StatelessWidget {
  const ComponentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final inShell = ShellBar.inShellOf(context);
    return SignalBuilder(
      builder: (context, _) {
        final section = appSectionProvider.of(context);
        final current = section.value;
        return NavigationScaffold(
          // With the bar in the shell, the page has no bars of its own.
          layout: inShell ? NavigationLayout.bottomBar : NavigationLayout.auto,
          showMobileAppBar: !inShell,
          showBottomNavigationBar: !inShell,
          selectedIndex: current.index,
          onDestinationSelected: (index) =>
              section.value = AppSection.values[index],
          destinations: _destinations,
          // Leading, not the title: a phone's bar keeps the leading widget
          // and its actions only.
          leading: const UnaLogo(),
          actions: _actions,
          // Both stay built, so switching keeps the page you were on and
          // the showcase's scroll; the hidden one is off stage and its
          // tickers stop. Introduction and Components are one docs
          // browser, which opens the page each stands for.
          body: IndexedStack(
            index: current.isDocs ? 1 : 0,
            children: [
              TickerMode(
                enabled: !current.isDocs,
                child: const ShowcaseScreen(),
              ),
              TickerMode(
                enabled: current.isDocs,
                // The docs browser fills its box and does not inset itself
                // for bars laid over it: it starts below the top bar and
                // ends above the bottom one.
                child: _UnderBars(
                  child: ComponentsScreen(
                    section: current,
                    onSectionChanged: (next) => section.value = next,
                  ),
                ),
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

/// [child] below the top bar the scaffold lays over it. The bottom bar
/// floats over the page, so the page runs on beneath it and is told how
/// much of its bottom edge the bar covers, as a scrolling page is: its last
/// lines scroll up clear of the bar instead of stopping short of it.
class _UnderBars extends StatelessWidget {
  const _UnderBars({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.only(top: padding.top),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: child,
      ),
    );
  }
}
