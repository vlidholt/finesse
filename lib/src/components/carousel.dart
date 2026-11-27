import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/page_indicator.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/icons/phosphor_icons.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/shadow.dart';

/// Drives a [Carousel] from outside: go to a page, step forward or back.
///
/// It is also a [Listenable] that reports each change of [page], so
/// something beside the carousel can follow it:
///
/// ```dart
/// final controller = CarouselController();
///
/// ListenableBuilder(
///   listenable: controller,
///   builder: (context, _) => PageIndicator(
///     count: controller.pageCount,
///     index: controller.page,
///     onSelected: controller.animateToPage,
///   ),
/// )
/// ```
///
/// Dispose it with the state that created it.
class CarouselController extends ChangeNotifier {
  _CarouselState? _state;

  /// The current page, or 0 before the carousel is built.
  int get page => _state?._page ?? 0;

  /// The number of pages, or 0 before the carousel is built.
  int get pageCount => _state?.widget.itemCount ?? 0;

  /// Moves to [page] on the theme's motion. In a looping carousel it goes
  /// the short way round.
  void animateToPage(int page) => _state?._goTo(page);

  /// Goes to [page] at once.
  void jumpToPage(int page) => _state?._goTo(page, animate: false);

  /// Moves one page on. At the last page it does nothing, unless the
  /// carousel loops.
  void nextPage() => _state?._step(1);

  /// Moves one page back. At the first page it does nothing, unless the
  /// carousel loops.
  void previousPage() => _state?._step(-1);

  // ignore: use_setters_to_change_properties
  void _attach(_CarouselState state) => _state = state;

  void _detach(_CarouselState state) {
    if (identical(_state, state)) _state = null;
  }

  void _changed() => notifyListeners();
}

/// Pages to swipe through, one or a few at a time: a post's photographs, a
/// row of cards, an onboarding flow.
///
/// ```dart
/// Carousel(
///   height: 220,
///   showIndicator: true,
///   borderRadius: theme.radii.xl,
///   semanticLabel: 'Photos',
///   children: [
///     for (final photo in photos)
///       Image.asset(photo.asset, fit: BoxFit.cover),
///   ],
/// )
/// ```
///
/// A finger or a trackpad drags the pages. Where a mouse is connected the
/// carousel also shows a previous and a next button while the pointer is
/// over it or the focus is in it ([showArrows] decides otherwise). With the
/// focus on it, the arrow keys, Page Up and Page Down, Home and End move
/// between pages, the arrows following the reading direction.
///
/// [viewportFraction] below 1 shows the neighbours of the current page at
/// its sides, with [spacing] between them. [loop] goes round from the last
/// page to the first. [autoPlay] moves on by itself every so often; it
/// waits while the pointer is over the carousel, while the focus is in it
/// and while it is being touched, and does not run at all when the
/// platform asks for reduced motion or a screen reader is on. A carousel
/// that plays by itself shows a pause button in its bottom corner, which
/// stops it until it is pressed again.
///
/// The carousel fills the space it is given along its [axis], and across
/// it too unless [height] or [aspectRatio] says how tall (or, for a
/// vertical carousel, how wide) it is — one of the two is needed inside a
/// scrolling column.
class Carousel extends StatefulWidget {
  /// Creates a carousel of [children].
  Carousel({
    required List<Widget> children,
    this.controller,
    this.initialPage = 0,
    this.onPageChanged,
    this.viewportFraction = 1,
    this.spacing,
    this.axis = Axis.horizontal,
    this.loop = false,
    this.autoPlay,
    this.showArrows,
    this.showIndicator = false,
    this.borderRadius,
    this.height,
    this.aspectRatio,
    this.semanticLabel,
    super.key,
  }) : itemCount = children.length,
       itemBuilder = ((context, index) => children[index]),
       assert(viewportFraction > 0 && viewportFraction <= 1, '0 to 1'),
       assert(
         height == null || aspectRatio == null,
         'Give a height or an aspect ratio, not both.',
       );

  /// Creates a carousel whose pages are built as they come into view.
  const Carousel.builder({
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.initialPage = 0,
    this.onPageChanged,
    this.viewportFraction = 1,
    this.spacing,
    this.axis = Axis.horizontal,
    this.loop = false,
    this.autoPlay,
    this.showArrows,
    this.showIndicator = false,
    this.borderRadius,
    this.height,
    this.aspectRatio,
    this.semanticLabel,
    super.key,
  }) : assert(viewportFraction > 0 && viewportFraction <= 1, '0 to 1'),
       assert(
         height == null || aspectRatio == null,
         'Give a height or an aspect ratio, not both.',
       );

  /// The number of pages.
  final int itemCount;

  /// Builds the page at the index it is given.
  final IndexedWidgetBuilder itemBuilder;

  /// Drives the carousel from outside.
  final CarouselController? controller;

  /// The page shown first.
  final int initialPage;

  /// Called when another page has become the current one.
  final ValueChanged<int>? onPageChanged;

  /// How much of the carousel one page takes along the [axis]: 1 for one
  /// page at a time, less to let the neighbours show.
  final double viewportFraction;

  /// The gap between two pages. Defaults to the theme's when
  /// [viewportFraction] is below 1, and to none otherwise.
  final double? spacing;

  /// The direction the pages run in.
  final Axis axis;

  /// Whether the pages go round: the first follows the last.
  final bool loop;

  /// How long each page stays before the carousel moves on by itself. Null
  /// for a carousel that only moves when it is moved.
  final Duration? autoPlay;

  /// Whether the previous and next buttons are shown. Null, the default,
  /// shows them where a mouse is connected, while the pointer is over the
  /// carousel or the focus is in it; true shows them always.
  final bool? showArrows;

  /// Whether the carousel lays a [PageIndicator] over its bottom edge.
  final bool showIndicator;

  /// Rounds and clips the carousel's corners.
  final BorderRadius? borderRadius;

  /// The carousel's extent across its [axis]: the height of a horizontal
  /// carousel, the width of a vertical one.
  final double? height;

  /// The carousel's width divided by its height, as an alternative to
  /// [height].
  final double? aspectRatio;

  /// What the carousel is, for assistive technology: "Photos".
  final String? semanticLabel;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  /// Where an endless carousel starts counting, so that there is as far to
  /// go back as anyone will go.
  static const _loopBase = 10000;

  late PageController _pages = _createPages();
  final _focusNode = FocusNode(debugLabel: 'Carousel');

  late int _page = widget.itemCount == 0
      ? 0
      : widget.initialPage.clamp(0, widget.itemCount - 1);
  bool _hovered = false;
  bool _focused = false;
  bool _primaryFocus = false;
  bool _pressed = false;
  bool _mouse = false;
  Timer? _timer;

  /// Whether the pause button has stopped the auto-play.
  bool _paused = false;

  /// The page view's index a programmatic move is heading for.
  int? _travellingTo;

  bool get _loops => widget.loop && widget.itemCount > 1;

  PageController _createPages() => PageController(
    initialPage: _loops ? _loopBase * widget.itemCount + _page : _page,
    viewportFraction: widget.viewportFraction,
  );

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    final tracker = RendererBinding.instance.mouseTracker;
    _mouse = tracker.mouseIsConnected;
    tracker.addListener(_onMouseChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAutoPlay();
  }

  @override
  void didUpdateWidget(Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (widget.itemCount > 0 && _page >= widget.itemCount) {
      _page = widget.itemCount - 1;
    }
    if (widget.viewportFraction != oldWidget.viewportFraction ||
        widget.loop != oldWidget.loop ||
        (widget.loop && widget.itemCount != oldWidget.itemCount)) {
      // A page controller's geometry is fixed when it is made.
      final old = _pages;
      _pages = _createPages();
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    _syncAutoPlay();
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    RendererBinding.instance.mouseTracker.removeListener(_onMouseChanged);
    _timer?.cancel();
    _focusNode.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _onMouseChanged() {
    final connected = RendererBinding.instance.mouseTracker.mouseIsConnected;
    if (connected != _mouse && mounted) setState(() => _mouse = connected);
  }

  void _onFocusChanged() {
    final focused = _focusNode.hasFocus;
    final primary = _focusNode.hasPrimaryFocus;
    if (focused == _focused && primary == _primaryFocus) return;
    setState(() {
      _focused = focused;
      _primaryFocus = primary;
    });
    _syncAutoPlay();
  }

  // --- Moving ---------------------------------------------------------------

  /// The page view's own index of the current page.
  int get _rawPage {
    if (_pages.hasClients) return _pages.page?.round() ?? _pages.initialPage;
    return _pages.initialPage;
  }

  void _goTo(int page, {bool animate = true}) {
    final count = widget.itemCount;
    if (count == 0 || !_pages.hasClients) return;
    final target = page.clamp(0, count - 1);
    var raw = target;
    if (_loops) {
      // The short way round.
      final here = _rawPage;
      var delta = (target - here % count) % count;
      if (delta > count / 2) delta -= count;
      raw = here + delta;
    }
    _animateRaw(raw, animate: animate);
  }

  void _step(int delta) {
    final count = widget.itemCount;
    if (count == 0 || !_pages.hasClients) return;
    // A step taken while a move is under way goes on from where that one
    // is heading, so two quick presses move two pages.
    final travelling = _travellingTo;
    if (_loops) return _animateRaw((travelling ?? _rawPage) + delta);
    final from = travelling ?? _page;
    final target = (from + delta).clamp(0, count - 1);
    if (target != from) _animateRaw(target);
  }

  void _animateRaw(int raw, {bool animate = true}) {
    final spring = Motion.of(context).smooth;
    if (!animate || spring.isInstant) {
      _travellingTo = null;
      _pages.jumpToPage(raw);
    } else {
      // The pages passed on the way are not stops: only the arrival is
      // reported, or wherever a finger catches the carousel instead.
      _travellingTo = raw;
      _pages
          .animateToPage(
            raw,
            duration: spring.settleDuration,
            curve: spring.curve,
          )
          .whenComplete(() {
            if (!mounted || _travellingTo != raw) return;
            _travellingTo = null;
            if (_pages.hasClients) _onPageChanged(_rawPage);
          });
    }
  }

  void _onPageChanged(int raw) {
    final count = widget.itemCount;
    if (count == 0) return;
    final destination = _travellingTo;
    if (destination != null) {
      if (raw != destination) return;
      _travellingTo = null;
    }
    final page = raw % count;
    if (page == _page) return;
    setState(() => _page = page);
    widget.controller?._changed();
    widget.onPageChanged?.call(page);
    _syncAutoPlay();
  }

  // --- Auto-play ------------------------------------------------------------

  /// Whether the carousel plays by itself at all, paused or not.
  bool get _canAutoPlay {
    final interval = widget.autoPlay;
    if (interval == null || interval <= Duration.zero) return false;
    if (widget.itemCount < 2) return false;
    // It moves by itself, which is what reduced motion asks not to happen;
    // and a page that changes under a screen reader loses its place.
    return !Motion.of(context).reduced &&
        !MediaQuery.accessibleNavigationOf(context);
  }

  bool get _autoPlays {
    if (!_canAutoPlay || _paused) return false;
    if (_hovered || _focused || _pressed) return false;
    // Not behind another route, nor in a hidden tab.
    return TickerMode.valuesOf(context).enabled && Visibility.of(context);
  }

  void _togglePaused() {
    setState(() => _paused = !_paused);
    _syncAutoPlay();
  }

  /// Starts the wait for the next page over, or stops waiting.
  void _syncAutoPlay() {
    _timer?.cancel();
    _timer = null;
    if (!mounted || !_autoPlays) return;
    _timer = Timer(widget.autoPlay!, () {
      if (!mounted || !_autoPlays) return;
      if (!_loops && _page == widget.itemCount - 1) {
        _goTo(0);
      } else {
        _step(1);
      }
      // A carousel of one page moved nowhere and reports nothing.
      _syncAutoPlay();
    });
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _syncAutoPlay();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    _pressed = value;
    _syncAutoPlay();
  }

  // --- Keys -----------------------------------------------------------------

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final horizontal = widget.axis == Axis.horizontal;
    final ltr = Directionality.of(context) == TextDirection.ltr;
    final key = event.logicalKey;
    final forward = horizontal
        ? (ltr ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft)
        : LogicalKeyboardKey.arrowDown;
    final back = horizontal
        ? (ltr ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowUp;
    if (key == forward || key == LogicalKeyboardKey.pageDown) {
      _step(1);
    } else if (key == back || key == LogicalKeyboardKey.pageUp) {
      _step(-1);
    } else if (key == LogicalKeyboardKey.home) {
      _goTo(0);
    } else if (key == LogicalKeyboardKey.end) {
      _goTo(widget.itemCount - 1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final carousel = theme.carouselTheme;
    final strings = UnaLocalizations.of(context).carousel;
    final count = widget.itemCount;
    final horizontal = widget.axis == Axis.horizontal;
    final spacing =
        widget.spacing ??
        (widget.viewportFraction < 1 ? carousel.spacing ?? 12 : 0);

    final pages = PageView.builder(
      controller: _pages,
      scrollDirection: widget.axis,
      itemCount: _loops ? null : count,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, raw) {
        final index = raw % count;
        var page = widget.itemBuilder(context, index);
        if (spacing > 0) {
          page = Padding(
            padding: horizontal
                ? EdgeInsets.symmetric(horizontal: spacing / 2)
                : EdgeInsets.symmetric(vertical: spacing / 2),
            child: page,
          );
        }
        return Semantics(
          container: true,
          label: strings.item(index: index + 1, count: count),
          child: page,
        );
      },
    );

    final arrowsWanted = widget.showArrows ?? _mouse;
    final arrowsShown = (widget.showArrows ?? false) || _hovered || _focused;
    final atStart = !_loops && _page == 0;
    final atEnd = !_loops && _page >= count - 1;

    Widget content = Stack(
      fit: StackFit.passthrough,
      children: [
        pages,
        if (arrowsWanted && count > 1) ...[
          _ArrowSlot(
            axis: widget.axis,
            forward: false,
            visible: arrowsShown && !atStart,
            label: strings.previous,
            onPressed: () => _step(-1),
          ),
          _ArrowSlot(
            axis: widget.axis,
            forward: true,
            visible: arrowsShown && !atEnd,
            label: strings.next,
            onPressed: () => _step(1),
          ),
        ],
        // WCAG 2.2.2: what moves by itself can be stopped.
        if (_canAutoPlay)
          PositionedDirectional(
            end: carousel.indicatorInset ?? 8,
            bottom: carousel.indicatorInset ?? 8,
            child: _OverlayButton(
              icon: _paused
                  ? PhosphorIconsRegular.play
                  : PhosphorIconsRegular.pause,
              label: _paused ? strings.play : strings.pause,
              size: carousel.arrowSize ?? 36,
              onPressed: _togglePaused,
            ),
          ),
        if (widget.showIndicator && count > 1)
          Positioned(
            left: horizontal ? 0 : null,
            right: horizontal ? 0 : carousel.indicatorInset ?? 8,
            top: horizontal ? null : 0,
            bottom: horizontal ? carousel.indicatorInset ?? 8 : 0,
            child: Center(
              child: PageIndicator(
                count: count,
                index: _page,
                controller: _pages,
                axis: widget.axis,
                variant: PageIndicatorVariant.overlay,
                // Read with the carousel, which already says the page.
                semanticLabel: '',
              ),
            ),
          ),
      ],
    );

    String pageLabel(int page) => strings.page(page: page + 1, count: count);
    final canIncrease = count > 1 && !atEnd;
    final canDecrease = count > 1 && !atStart;

    final radius = widget.borderRadius;
    if (radius != null) {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    content = FocusRing(
      visible: _primaryFocus && _keyboardFocus,
      borderRadius: radius ?? BorderRadius.zero,
      child: content,
    );

    if (widget.height != null) {
      content = SizedBox(
        height: horizontal ? widget.height : null,
        width: horizontal ? null : widget.height,
        child: content,
      );
    } else if (widget.aspectRatio != null) {
      content = AspectRatio(aspectRatio: widget.aspectRatio!, child: content);
    }

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: count == 0 ? null : pageLabel(_page),
      increasedValue: canIncrease ? pageLabel((_page + 1) % count) : null,
      decreasedValue: canDecrease
          ? pageLabel((_page - 1 + count) % count)
          : null,
      onIncrease: canIncrease ? () => _step(1) : null,
      onDecrease: canDecrease ? () => _step(-1) : null,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: Listener(
            onPointerDown: (_) => _setPressed(true),
            onPointerUp: (_) => _setPressed(false),
            onPointerCancel: (_) => _setPressed(false),
            child: content,
          ),
        ),
      ),
    );
  }

  /// Whether the focus is shown: by the keyboard, not by a click.
  bool get _keyboardFocus =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
}

/// One of the carousel's two buttons, at the middle of an edge, fading in
/// and out.
class _ArrowSlot extends StatelessWidget {
  const _ArrowSlot({
    required this.axis,
    required this.forward,
    required this.visible,
    required this.label,
    required this.onPressed,
  });

  final Axis axis;
  final bool forward;
  final bool visible;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carousel = theme.carouselTheme;
    final motion = Motion.of(context);
    final inset = carousel.arrowInset ?? 8;
    final size = carousel.arrowSize ?? 36;
    final horizontal = axis == Axis.horizontal;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    // The caret points where the pages will come from; a horizontal one
    // follows the reading direction.
    final icon = horizontal
        ? ((forward != rtl)
              ? PhosphorIconsRegular.caretRight
              : PhosphorIconsRegular.caretLeft)
        : (forward
              ? PhosphorIconsRegular.caretDown
              : PhosphorIconsRegular.caretUp);
    final alignment = horizontal
        ? (forward
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart)
        : (forward ? Alignment.bottomCenter : Alignment.topCenter);

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(inset),
          child: IgnorePointer(
            ignoring: !visible,
            child: ExcludeSemantics(
              excluding: !visible,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: motion.fast,
                curve: motion.standard,
                child: _OverlayButton(
                  icon: icon,
                  label: label,
                  size: size,
                  onPressed: visible ? onPressed : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round button laid over the pages: the arrows, and the pause button.
class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final carousel = theme.carouselTheme;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.full,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: ShadowDecoration.box(
            shape: BoxShape.circle,
            shadows: theme.style.controlShadow,
          ),
          child: AnimatedFill(
            color: states.contains(WidgetState.hovered)
                ? carousel.arrowHoverColor ?? theme.colorScheme.muted
                : carousel.arrowColor ?? theme.colorScheme.popover,
            borderColor: carousel.arrowBorderColor ?? theme.colorScheme.border,
            borderRadius: theme.radii.full,
            child: SizedBox.square(
              dimension: size - 2,
              child: Center(
                child: PhosphorIcon(
                  icon,
                  size: carousel.arrowIconSize ?? 16,
                  color:
                      carousel.arrowForegroundColor ??
                      theme.colorScheme.popoverForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
