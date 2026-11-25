import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:finesse/src/components/tabs.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The pages that go with a `TabBar`: the page of the selected tab, which a
/// finger can swipe to the next one.
///
/// `Tabs` is a tab bar with its pages under it. Use a [TabBarView] when the
/// bar lives somewhere else — in an `AppBar`'s `bottom`, say — and share a
/// [TabsController] between the two, so the bar's indicator follows the
/// finger while a page is dragged:
///
/// ```dart
/// final tabs = TabsController<String>(value: 'posts');
///
/// Scaffold(
///   appBar: AppBar(
///     title: const Text('Profile'),
///     bottom: TabBar<String>(
///       controller: tabs,
///       tabs: const [
///         Tab(value: 'posts', child: Text('Posts')),
///         Tab(value: 'about', child: Text('About')),
///       ],
///     ),
///   ),
///   body: TabBarView<String>(
///     controller: tabs,
///     pages: {
///       'posts': (context) => const PostList(),
///       'about': (context) => const AboutPage(),
///     },
///   ),
/// )
/// ```
///
/// Without a controller it is controlled, like the bar: give it [value] and
/// change that in [onChanged]. The bar's indicator then moves when the
/// swipe is let go rather than with the finger.
///
/// The pages are in the order of [pages]. A drag follows the finger; let go
/// past the middle, or flicked, the next page springs into place on the
/// theme's `Motion.snappy`, carrying the speed it was let go at. A value
/// changed from outside — a tap on a tab — swaps the page with a short fade
/// rather than sliding every page between the two past.
///
/// Given a height, it fills it and so does each page. Without one — in a
/// `Column`, in a scrolling page — it is as tall as the page it shows, and
/// while one page is dragged over to the next it goes from the one height
/// to the other.
class TabBarView<T> extends StatefulWidget {
  /// Creates the pages of a tab bar.
  const TabBarView({
    required this.pages,
    this.value,
    this.onChanged,
    this.controller,
    this.maintainState = true,
    this.swipeable = true,
    super.key,
  }) : assert(
         value == null || controller == null,
         'Give either a value or a controller, not both.',
       );

  /// Builds the page of each value, in the order they are swiped through.
  final Map<T, WidgetBuilder> pages;

  /// The value whose page is shown, when there is no [controller].
  final T? value;

  /// Called with the value of the page a swipe ended on.
  final ValueChanged<T>? onChanged;

  /// Holds the selection in place of [value], and tells a `TabBar` on the
  /// same controller where a drag is.
  final TabsController<T>? controller;

  /// Whether a page that is not showing stays built, keeping its state:
  /// its scroll offset, what was typed. With false only the page showing —
  /// and the one being dragged in — is built.
  final bool maintainState;

  /// Whether a drag changes the page. A mouse never does: it selects
  /// text. Defaults to true.
  final bool swipeable;

  @override
  State<TabBarView<T>> createState() => _TabBarViewState<T>();
}

class _TabBarViewState<T> extends State<TabBarView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_changed);
  }

  @override
  void didUpdateWidget(TabBarView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?.removeListener(_changed);
      widget.controller?.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final values = widget.pages.keys.toList(growable: false);
    final builders = widget.pages.values.toList(growable: false);
    final value = controller != null ? controller.value : widget.value;
    return TabPages(
      count: values.length,
      index: math.max(values.indexOf(value as T), 0),
      onIndexChanged: (index) {
        final next = values[index];
        controller?.select(next);
        widget.onChanged?.call(next);
      },
      builder: (context, index) => builders[index](context),
      maintainState: widget.maintainState,
      swipeable: widget.swipeable,
      track: controller?.swipePosition,
      fill: true,
    );
  }
}

/// The pager behind `Tabs` and [TabBarView]: one page showing, the next
/// dragged in beside it.
///
/// Internal. It knows indices, not values, and holds no selection of its
/// own: a swipe is reported through [onIndexChanged] and springs back if
/// the index it is given does not follow.
class TabPages extends StatefulWidget {
  /// Creates a pager of [count] pages showing the one at [index].
  const TabPages({
    required this.count,
    required this.index,
    required this.onIndexChanged,
    required this.builder,
    required this.maintainState,
    required this.swipeable,
    required this.fill,
    this.track,
    this.canShow,
    super.key,
  });

  /// How many pages there are.
  final int count;

  /// The page that is showing.
  final int index;

  /// Called with the page a swipe ended on.
  final ValueChanged<int> onIndexChanged;

  /// Builds the page at an index.
  final IndexedWidgetBuilder builder;

  /// Whether pages that are not showing stay built.
  final bool maintainState;

  /// Whether a drag changes the page.
  final bool swipeable;

  /// Whether the pager, given a height, fills it. Otherwise — and whenever
  /// its height is unbounded — it is as tall as the page it shows.
  final bool fill;

  /// Told where a drag is, as a fractional index, and null at rest.
  final ValueNotifier<double?>? track;

  /// Whether a page can be swiped to. Defaults to all of them.
  final bool Function(int index)? canShow;

  @override
  State<TabPages> createState() => _TabPagesState();
}

class _TabPagesState extends State<TabPages> with TickerProviderStateMixin {
  late final _position = SpringController(
    vsync: this,
    value: widget.index.toDouble(),
    tolerance: 1e-4,
  );

  // Plays once per selection made elsewhere: the incoming page fades in,
  // sliding from the side its tab is on. At rest on 1, so nothing animates
  // on first build.
  late final _transition = AnimationController(vsync: this, value: 1);

  // +1 when the page now showing is after the previous one, -1 before.
  double _direction = 1;

  final _keys = <GlobalKey>[];
  HorizontalDragGestureRecognizer? _recognizer;

  /// Whether a finger has hold of the pages, or they are settling after it
  /// let go.
  bool _swiping = false;

  /// The pages a drag is between.
  late int _low = widget.index;
  late int _high = widget.index;

  @override
  void initState() {
    super.initState();
    _position.animation.addListener(_moved);
    _syncKeys();
  }

  @override
  void didUpdateWidget(TabPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    if (!identical(widget.track, oldWidget.track)) {
      oldWidget.track?.value = null;
      _report();
    }
    if (widget.index == oldWidget.index) return;
    // A swipe that is on its way here, or has arrived: nothing to do.
    if (_position.target == widget.index) return;
    // Chosen elsewhere: swap, with a fade from the side the page is on.
    _swiping = false;
    _direction = widget.index < oldWidget.index ? -1 : 1;
    _position.jumpTo(widget.index.toDouble());
    final motion = Motion.of(context);
    _transition
      ..duration =
          Theme.of(context).tabsTheme.contentTransitionDuration ?? motion.normal
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _recognizer?.dispose();
    _position.animation.removeListener(_moved);
    _position.dispose();
    _transition.dispose();
    // Not during the frame that tears this down.
    final track = widget.track;
    if (track != null && track.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => track.value = null);
    }
    super.dispose();
  }

  void _syncKeys() {
    while (_keys.length > widget.count) {
      _keys.removeLast();
    }
    while (_keys.length < widget.count) {
      _keys.add(GlobalKey());
    }
  }

  void _report() {
    widget.track?.value = _swiping ? _position.value : null;
  }

  void _moved() {
    _report();
    final value = _position.value.clamp(0.0, math.max(widget.count - 1.0, 0));
    final low = (value + 1e-6).floor();
    final high = (value - 1e-6).ceil();
    if (low != _low || high != _high) {
      setState(() {
        _low = low;
        _high = high;
      });
    }
  }

  bool _canShow(int index) =>
      index >= 0 &&
      index < widget.count &&
      (widget.canShow?.call(index) ?? true);

  double get _width => math.max(context.size?.width ?? 1, 1);

  double get _forward =>
      Directionality.of(context) == TextDirection.rtl ? -1 : 1;

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.swipeable || widget.count < 2) return;
    (_recognizer ??=
            HorizontalDragGestureRecognizer(
                debugOwner: this,
                // A finger, a pen or two fingers on a trackpad. A mouse
                // drags to select.
                supportedDevices: const {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                  PointerDeviceKind.trackpad,
                },
              )
              ..onStart = _handleDragStart
              ..onUpdate = _handleDragUpdate
              ..onEnd = _handleDragEnd
              ..onCancel = (() => _settle(0)))
        .addPointer(event);
  }

  void _handleDragStart(DragStartDetails details) {
    // Caught mid-flight, the pages stop under the finger.
    _position.stop();
    _transition.value = 1;
    _swiping = true;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_swiping) return;
    var delta = -_forward * (details.primaryDelta ?? 0) / _width;
    final value = _position.value;
    // Towards a page that is not there, or cannot be shown, the pages
    // resist: they move a third as far as the finger.
    final towards = delta > 0 ? value.floor() + 1 : value.ceil() - 1;
    if (!_canShow(towards)) delta /= 3;
    _position.jumpTo(
      (value + delta).clamp(widget.index - 1.0, widget.index + 1.0),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    _settle(-_forward * details.velocity.pixelsPerSecond.dx / _width);
  }

  /// Lets go of the pages, moving at [velocity] pages a second.
  void _settle(double velocity) {
    if (!_swiping) return;
    final value = _position.value;
    // A flick decides; without one, whichever page is nearer.
    var target = velocity > .5
        ? value.floor() + 1
        : velocity < -.5
        ? value.ceil() - 1
        : value.round();
    if (!_canShow(target)) target = widget.index;
    final motion = Motion.of(context);
    _position
        .animateTo(
          target.toDouble(),
          // Critically damped: a page that overshot would show a sliver of
          // the one beyond it.
          spring: motion.snappy.copyWith(bounce: 0),
          velocity: velocity,
        )
        .whenCompleteOrCancel(() {
          if (!mounted || _position.isAnimating) return;
          if (_position.target != target) return;
          _arrived(target);
        });
    if (target != widget.index) widget.onIndexChanged(target);
  }

  void _arrived(int target) {
    if (!_swiping) return;
    if (target != widget.index) {
      // The selection did not follow: back to the page it is on.
      final back = widget.index;
      _position
          .animateTo(
            back.toDouble(),
            spring: Motion.of(context).snappy.copyWith(bounce: 0),
          )
          .whenCompleteOrCancel(() {
            if (!mounted || _position.isAnimating) return;
            if (_position.target != back) return;
            _swiping = false;
            _report();
          });
      return;
    }
    _swiping = false;
    _report();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final offset =
        (theme.tabsTheme.contentTransitionOffset ?? motion.overlayTravel * 2) *
        (motion.reduced ? 0 : 1) *
        _direction *
        _forward;
    // Driven, not a `CurvedAnimation`: that registers a listener on its
    // parent and would need disposing on every build.
    final curve = _transition.drive(CurveTween(curve: motion.emphasized));

    final children = <Widget>[
      for (var i = 0; i < widget.count; i++)
        if (widget.maintainState ||
            i == widget.index ||
            i == _low ||
            i == _high)
          _page(
            i,
            showing: i == widget.index || i == _low || i == _high,
            animation: curve,
            offset: i == widget.index ? offset : 0,
          )
        else
          const SizedBox.shrink(),
    ];

    return Listener(
      onPointerDown: _handlePointerDown,
      child: _TabPagesBody(
        position: _position.animation,
        textDirection: Directionality.of(context),
        fill: widget.fill,
        children: children,
      ),
    );
  }

  Widget _page(
    int index, {
    required bool showing,
    required Animation<double> animation,
    required double offset,
  }) {
    final content = KeyedSubtree(
      key: _keys[index],
      child: widget.builder(context, index),
    );
    return _TabContentTransition(
      animation: animation,
      // Only the page coming in moves; the others stay put.
      offset: offset,
      // A page that is not showing is not there: nothing in it takes the
      // focus, runs an animation or keeps a menu open.
      child: Visibility.maintain(
        visible: showing,
        child: TickerMode(
          enabled: showing,
          child: FocusTraversalGroup(
            descendantsAreFocusable: index == widget.index,
            policy: WidgetOrderTraversalPolicy(),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Fades a page in, sliding it [offset] logical pixels into place.
///
/// Paint only: the page is laid out where it will rest from the first
/// frame, so the transition never moves anything around it.
class _TabContentTransition extends StatelessWidget {
  const _TabContentTransition({
    required this.animation,
    required this.offset,
    required this.child,
  });

  final Animation<double> animation;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(offset * (1 - animation.value), 0),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

class _TabPagesBody extends MultiChildRenderObjectWidget {
  const _TabPagesBody({
    required this.position,
    required this.textDirection,
    required this.fill,
    required super.children,
  });

  final Animation<double> position;
  final TextDirection textDirection;
  final bool fill;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTabPages(
    position: position,
    textDirection: textDirection,
    fill: fill,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderTabPages renderObject) {
    renderObject
      ..position = position
      ..textDirection = textDirection
      ..fill = fill;
  }
}

class _PageParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays every page out at the pager's width, shows the one — or the two —
/// that [position] is on, and takes its own height from them.
class _RenderTabPages extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PageParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PageParentData> {
  _RenderTabPages({
    required Animation<double> position,
    required TextDirection textDirection,
    required bool fill,
  }) : _position = position,
       _textDirection = textDirection,
       _fill = fill;

  Animation<double> get position => _position;
  Animation<double> _position;
  set position(Animation<double> value) {
    if (identical(value, _position)) return;
    if (attached) {
      _position.removeListener(_moved);
      value.addListener(_moved);
    }
    _position = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  bool get fill => _fill;
  bool _fill;
  set fill(bool value) {
    if (value == _fill) return;
    _fill = value;
    markNeedsLayout();
  }

  /// Whether the pager's height is its pages': it changes as one page is
  /// dragged over to a taller one.
  bool _hugs = false;

  void _moved() {
    if (_hugs) {
      markNeedsLayout();
    } else {
      markNeedsPaint();
    }
    markNeedsSemanticsUpdate();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _position.addListener(_moved);
  }

  @override
  void detach() {
    _position.removeListener(_moved);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PageParentData) {
      child.parentData = _PageParentData();
    }
  }

  /// Where the pages are: the two pages the position lies between, how far
  /// between them, and how far past an end it has been pulled.
  ({int low, int high, double t, double over}) get _at {
    final last = math.max(childCount - 1, 0);
    final value = _position.value;
    final within = value.clamp(0.0, last.toDouble());
    final low = (within + 1e-6).floor().clamp(0, last);
    final high = (within - 1e-6).ceil().clamp(0, last);
    return (
      low: low,
      high: high,
      t: high == low ? 0 : within - low,
      over: value - within,
    );
  }

  RenderBox? _childAt(int index) {
    var child = firstChild;
    for (var i = 0; child != null && i < index; i++) {
      child = childAfter(child);
    }
    return child;
  }

  int _indexOf(RenderObject target) {
    var index = 0;
    for (
      var child = firstChild;
      child != null;
      child = childAfter(child), index++
    ) {
      if (identical(child, target)) return index;
    }
    return -1;
  }

  /// How far to the side the page at [index] is drawn.
  double _dx(int index) {
    final at = _at;
    final sign = _textDirection == TextDirection.rtl ? -1.0 : 1.0;
    return (index - (at.low + at.t) - at.over) * size.width * sign;
  }

  bool _showing(int index) {
    final at = _at;
    return index == at.low || index == at.high;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    final fills = _fill && constraints.hasBoundedHeight;
    _hugs = !fills;
    final bounded = constraints.hasBoundedWidth;
    final pageConstraints = BoxConstraints(
      minWidth: bounded ? constraints.maxWidth : 0,
      maxWidth: constraints.maxWidth,
      minHeight: fills ? constraints.maxHeight : 0,
      maxHeight: constraints.maxHeight,
    );
    var width = bounded ? constraints.maxWidth : 0.0;
    final heights = <double>[];
    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(pageConstraints, parentUsesSize: true);
      if (!bounded) width = math.max(width, child.size.width);
      heights.add(child.size.height);
    }
    final at = _at;
    final height = fills
        ? constraints.maxHeight
        : heights.isEmpty
        ? 0.0
        : lerpDouble(heights[at.low], heights[at.high], at.t)!;
    size = constraints.constrain(Size(width, height));
  }

  double _widest(double Function(RenderBox child) of) {
    var width = 0.0;
    for (var child = firstChild; child != null; child = childAfter(child)) {
      width = math.max(width, of(child));
    }
    return width;
  }

  /// The height of what is showing, by [of].
  double _shown(double Function(RenderBox child) of) {
    final at = _at;
    final low = _childAt(at.low);
    final high = _childAt(at.high);
    if (low == null || high == null) return 0;
    return lerpDouble(of(low), of(high), at.t)!;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _widest((child) => child.getMinIntrinsicWidth(height));

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _widest((child) => child.getMaxIntrinsicWidth(height));

  @override
  double computeMinIntrinsicHeight(double width) =>
      _shown((child) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _shown((child) => child.getMaxIntrinsicHeight(width));

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final child = _childAt(_at.low);
    return child?.getDistanceToActualBaseline(baseline);
  }

  @override
  bool paintsChild(RenderBox child) => _showing(_indexOf(child));

  void _paintPages(PaintingContext context, Offset offset) {
    final at = _at;
    var index = 0;
    for (
      var child = firstChild;
      child != null;
      child = childAfter(child), index++
    ) {
      if (index != at.low && index != at.high) continue;
      context.paintChild(child, offset + Offset(_dx(index), 0));
    }
  }

  final _clipLayer = LayerHandle<ClipRectLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    final at = _at;
    // At rest on a page nothing is clipped: what a page paints beyond its
    // box — a card's shadow — stays whole. Between two, neither may show
    // outside the pager.
    if (at.low == at.high && at.over == 0) {
      _clipLayer.layer = null;
      _paintPages(context, offset);
      return;
    }
    _clipLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      _paintPages,
      oldLayer: _clipLayer.layer,
    );
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final at = _at;
    var index = childCount - 1;
    for (
      var child = lastChild;
      child != null;
      child = childBefore(child), index--
    ) {
      if (index != at.low && index != at.high) continue;
      final hit = result.addWithPaintOffset(
        offset: Offset(_dx(index), 0),
        position: position,
        hitTest: (result, position) =>
            child!.hitTest(result, position: position),
      );
      if (hit) return true;
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(_dx(_indexOf(child)), 0, 0, 1);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // One page is read: the one most of which is showing.
    final at = _at;
    final child = _childAt(at.t < .5 ? at.low : at.high);
    if (child != null) visitor(child);
  }
}
