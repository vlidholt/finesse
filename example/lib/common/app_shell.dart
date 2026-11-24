import 'dart:math' as math;

import 'package:example/common/app_state.dart';
import 'package:example/common/page_switch.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/screens/components_screen.dart';
import 'package:example/strand/strand_shell.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

export 'package:example/common/app_state.dart' show AppSection;

/// The application frame: the page, with the theme customizer docked beside
/// it when it is open.
///
/// The page is a [Navigator] showing the current [AppSection] — Strand, or
/// the component library — and whatever full-screen routes a screen pushes
/// on top of it. Because the navigator is *inside* the frame, such a route
/// covers the section's own chrome but leaves the editor panel docked, so a
/// conversation or a search page can still be re-themed live.
///
/// Both sections stay alive once visited, so switching back and forth keeps
/// scroll position and page state.
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
  /// window, so docking the editor beside a medium-width window lays Strand
  /// out for the phone-sized space it actually has.
  static double pageWidth(double windowWidth, {required bool editorOpen}) =>
      editorOpen && docksEditor(windowWidth)
      ? windowWidth - ThemeCustomizerPanel.width
      : windowWidth;

  /// The form factor the app is themed for in a window [windowWidth] wide:
  /// the one the editor pins, or else the one the page's width calls for —
  /// a phone below [breakpoint], the theme's `md`.
  ///
  /// `App` passes this to `FinesseApp` and the shell lays the page out for
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

        ThemeCustomizerPanel panel({required bool docked}) =>
            ThemeCustomizerPanel(
              config: config,
              onChanged: (next) => configSignal.value = next,
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
            // have, and `FinesseApp` applies a theme in the build it is
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
                    child: panel(docked: docked),
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

/// The navigator in the page area. Its first route is the section switcher;
/// screens push full-screen routes above it.
class _PageNavigator extends StatefulWidget {
  const _PageNavigator({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<_PageNavigator> {
  /// Whether a full-screen route is showing above the sections.
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
      onGenerateRoute: (settings) => FinessePageRoute<void>(
        settings: settings,
        builder: (context) => const _Sections(),
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

/// Strand and the component library, one showing at a time.
class _Sections extends StatefulWidget {
  const _Sections();

  @override
  State<_Sections> createState() => _SectionsState();
}

class _SectionsState extends State<_Sections> {
  /// The component library registers ~50 doc pages; it is not built until it
  /// is first opened.
  bool _componentsBuilt = false;

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, _) {
        final section = appSectionProvider.of(context).value;
        if (section == AppSection.components) _componentsBuilt = true;

        // IndexedStack keeps both sections alive but installs no
        // TickerMode, so the offstage one's skeletons, spinners and
        // progress bars would keep asking for a frame every 16ms for the
        // whole session — the app never idles, and every per-frame
        // allocation compounds instead of being absorbed.
        Widget onlyTicksWhenActive(AppSection self, Widget child) =>
            TickerMode(enabled: section == self, child: child);

        return ColoredBox(
          color: Theme.of(context).colorScheme.background,
          // The section switched to slides in from its side: the library
          // from the end, Strand back from the start.
          child: PageSwitch(
            value: section.index,
            child: IndexedStack(
              index: section.index,
              sizing: StackFit.expand,
              children: [
                onlyTicksWhenActive(AppSection.strand, const StrandShell()),
                onlyTicksWhenActive(
                  AppSection.components,
                  _componentsBuilt
                      ? const ComponentsSection()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The component-library browser under a slim app bar: back to Strand,
/// light/dark, text direction and the theme editor.
class ComponentsSection extends StatelessWidget {
  const ComponentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // A Column, not a Scaffold: the docs browser is a sidebar layout that
    // fills its box and does not inset itself for a bar laid over it.
    return Column(
      children: [
        AppBar(
          // The docs browser is full-bleed, so its bar is too.
          maxWidth: double.infinity,
          leading: IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
            semanticLabel: 'Back to Strand',
            onPressed: () =>
                appSectionProvider.of(context).value = AppSection.strand,
          ),
          title: const Text('Components'),
          actions: const [
            _ThemeModeButton(),
            _DirectionButton(),
            _ThemeEditorButton(),
          ],
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: const ComponentsScreen(),
          ),
        ),
      ],
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
