part of 'board.dart';

/// A [MotionSpring] reduced to the numbers [_Spring.advance] needs.
@immutable
class _SpringSpec {
  factory _SpringSpec(MotionSpring spring) {
    if (spring.isInstant) return const _SpringSpec._(0, 1, true);
    final seconds =
        spring.duration.inMicroseconds / Duration.microsecondsPerSecond;
    // `MotionSpring.description` in closed form: a mass of 1, a natural
    // frequency of 2π over the duration, and a damping ratio that falls
    // from 1 as the bounce rises.
    final zeta = spring.bounce >= 0
        ? 1 - spring.bounce
        : 1 / (1 + spring.bounce);
    return _SpringSpec._(2 * math.pi / seconds, zeta, false);
  }

  const _SpringSpec._(this.omega, this.zeta, this.instant);

  /// The natural frequency, in radians per second.
  final double omega;

  /// The damping ratio: 1 is critical, below it the spring overshoots.
  final double zeta;

  final bool instant;
}

/// One number on a spring.
///
/// It is stepped by the board's single ticker with the exact solution of the
/// damped oscillator, not by an integrator: a critically damped spring that
/// starts at rest then never passes its target, however long the frame, and
/// retargeting it keeps the velocity it has.
class _Spring {
  _Spring([this.value = 0]) : target = value;

  double value;
  double velocity = 0;
  double target;

  bool get atRest => velocity == 0 && value == target;

  void jumpTo(double to) {
    value = to;
    target = to;
    velocity = 0;
  }

  /// The lowest value the spring passes on its way to [target] from here.
  double lowestWith(_SpringSpec spec, {required double velocity}) {
    final probe = _Spring(value)
      ..target = target
      ..velocity = velocity;
    var lowest = math.min(value, target);
    for (var i = 0; i < 400; i++) {
      if (!probe.advance(.002, spec, tolerance: 1e-4)) break;
      lowest = math.min(lowest, probe.value);
    }
    return lowest;
  }

  /// Sends the spring on its way to [to] with a push that carries it as
  /// far as [through] before it comes back: a landing that presses in and
  /// rebounds, as one motion.
  void kickThrough(double to, double through, _SpringSpec spec) {
    target = to;
    if (spec.instant || through >= math.min(value, to)) return;
    // The push is found by bisection; the dip grows with it.
    var gentle = 0.0;
    var hard = -400.0;
    for (var i = 0; i < 24; i++) {
      final middle = (gentle + hard) / 2;
      if (lowestWith(spec, velocity: middle) > through) {
        gentle = middle;
      } else {
        hard = middle;
      }
    }
    velocity = (gentle + hard) / 2;
  }

  /// Advances by [dt] seconds; returns whether it is still moving.
  bool advance(double dt, _SpringSpec spec, {double tolerance = .05}) {
    if (atRest) return false;
    if (spec.instant) {
      jumpTo(target);
      return false;
    }
    if (dt <= 0) return true;

    final w = spec.omega;
    final z = spec.zeta;
    final y0 = value - target;
    final v0 = velocity;
    double y;
    double v;
    if ((z - 1).abs() < 1e-6) {
      final decay = math.exp(-w * dt);
      final c = v0 + w * y0;
      y = (y0 + c * dt) * decay;
      v = (v0 - c * w * dt) * decay;
    } else if (z < 1) {
      final wd = w * math.sqrt(1 - z * z);
      final decay = math.exp(-z * w * dt);
      final c = (v0 + z * w * y0) / wd;
      final cos = math.cos(wd * dt);
      final sin = math.sin(wd * dt);
      y = decay * (y0 * cos + c * sin);
      v = decay * ((v0 * cos) - (y0 * wd + c * z * w) * sin);
    } else {
      final root = w * math.sqrt(z * z - 1);
      final r1 = -z * w + root;
      final r2 = -z * w - root;
      final a = (v0 - r2 * y0) / (r1 - r2);
      final b = y0 - a;
      final e1 = math.exp(r1 * dt);
      final e2 = math.exp(r2 * dt);
      y = a * e1 + b * e2;
      v = a * r1 * e1 + b * r2 * e2;
    }

    if (y.abs() < tolerance && v.abs() < tolerance * w) {
      jumpTo(target);
      return false;
    }
    value = target + y;
    velocity = v;
    return true;
  }
}

/// How a drag is driven.
enum _DragMode { pointer, keyboard }

/// A drag in progress.
class _Drag<T extends Object> {
  _Drag({
    required this.id,
    required this.item,
    required this.mode,
    required this.proxy,
    required this.size,
    required this.extent,
    required this.grab,
    required this.pointer,
    required this.touch,
    required this.targetColumn,
    required this.targetIndex,
  });

  final Object id;
  T item;
  final _DragMode mode;
  final _Proxy<T> proxy;

  /// The item's size, and the extent of its slot: its height plus the gap.
  final Size size;
  final double extent;

  /// The pointer's offset from the item's top left corner when it was
  /// picked up.
  final Offset grab;

  /// Where the pointer is, in global coordinates.
  Offset pointer;

  /// How far behind the pointer the copy still is, when it was caught in
  /// flight: it closes the distance on a spring instead of jumping.
  final _Spring catchUpX = _Spring();
  final _Spring catchUpY = _Spring();

  /// Where the copy's top left corner belongs.
  Offset get position =>
      pointer - grab + Offset(catchUpX.value, catchUpY.value);

  /// Whether a finger is dragging: it gets haptics, a mouse does not.
  final bool touch;

  /// The column the item would land in, and its index there once it has
  /// left its own column. A null column is "nowhere": outside the board.
  Object? targetColumn;
  int targetIndex;

  /// Whether [targetColumn] turns the item down.
  bool refused = false;

  /// The pointer's smoothed horizontal speed, which the tilt follows.
  double speedX = 0;
  double lastX = 0;

  /// How long the pointer has rested at a horizontal edge of a board that
  /// snaps, and whether the board is turning to the next column.
  double dwell = 0;
  bool turning = false;
}

/// What a lifted copy of an item is doing.
enum _ProxyPhase {
  /// It follows the pointer, or the keyboard's target.
  held,

  /// It has been let go and is on its way to its slot.
  flying,

  /// It is over its slot and settling.
  landing,
}

/// A listenable that is told when to notify.
class _Signal extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// The lifted copy of an item: the card that follows the pointer, and after
/// release flies to its slot and lands.
///
/// It is painted in the overlay by a [_RenderProxy], which listens to it:
/// a notification moves a layer, or repaints the shadow and the glow, and
/// builds nothing. Only [chrome] — what the copy does with the pointer —
/// rebuilds anything.
class _Proxy<T extends Object> extends ChangeNotifier {
  _Proxy({
    required this.id,
    required this.item,
    required this.details,
    required this.size,
    required Offset position,
  }) : x = _Spring(position.dx),
       y = _Spring(position.dy);

  final Object id;
  T item;
  BoardItemDetails<T> details;
  final Size size;

  /// The top left corner, in global coordinates.
  final _Spring x;
  final _Spring y;

  /// How lifted the copy is: 0 lies in its slot, 1 is in the hand. Below 0
  /// it is pressed into the slot, which is the pop of a landing.
  final _Spring lift = _Spring();

  /// The lean, in radians.
  final _Spring tilt = _Spring();

  /// The landing glow, from 1 down to 0.
  double highlight = 0;

  double opacity = 1;
  _ProxyPhase phase = _ProxyPhase.held;

  /// Notifies when [interactive] or [forbidden] changes.
  final _Signal chrome = _Signal();

  /// Whether the pointer is dragging it, so it shows the grabbing cursor
  /// and takes the scroll wheel.
  bool get interactive => _interactive;
  bool _interactive = false;
  set interactive(bool value) {
    if (value == _interactive) return;
    _interactive = value;
    chrome.fire();
  }

  /// Whether the column under it refuses the item.
  bool get forbidden => _forbidden;
  bool _forbidden = false;
  set forbidden(bool value) {
    if (value == _forbidden) return;
    _forbidden = value;
    chrome.fire();
  }

  /// Whether it has arrived on its slot; from then on it stays on it.
  bool settled = false;

  /// The column and index it was picked up from. Landing anywhere else
  /// ends with the glow.
  (Object, int)? origin;

  /// Whether it is on its way out, the item having left the board or its
  /// slot being out of view.
  bool fading = false;

  /// Frames for which the flight keeps to [predicted] rather than looking
  /// its slot up: the parent has been told of the move but has not rebuilt.
  int holdFrames = 0;
  Offset? predicted;

  Offset get position => Offset(x.value, y.value);

  void moveTo(Offset to) {
    x.jumpTo(to.dx);
    y.jumpTo(to.dy);
  }

  void changed() => notifyListeners();

  @override
  void dispose() {
    chrome.dispose();
    super.dispose();
  }
}

/// Every lifted copy of a board, in the overlay.
///
/// It is the overlay child of the board's `OverlayPortal`, so it is painted
/// right above the page the board is on — under anything opened over that
/// page — and inherits what the board inherits.
class _ProxyLayer<T extends Object> extends StatelessWidget {
  const _ProxyLayer({required this.board});

  final _BoardState<T> board;

  @override
  Widget build(BuildContext context) {
    // A copy is a picture: it takes no focus, no selection and no part in
    // the semantics tree, whatever the item builder puts in it.
    return SelectionContainer.disabled(
      child: ExcludeFocus(
        child: ExcludeSemantics(
          child: ListenableBuilder(
            listenable: board._proxyLayer,
            builder: (context, _) => Stack(
              children: [
                for (final proxy in board._proxies.values)
                  _ProxyView<T>(
                    key: ObjectKey(proxy),
                    proxy: proxy,
                    board: board,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One [_Proxy] in the overlay.
///
/// The tree has one shape for as long as the copy lives — held, flying,
/// landing or fading — so the item inside it keeps its state.
class _ProxyView<T extends Object> extends StatelessWidget {
  const _ProxyView({required this.proxy, required this.board, super.key});

  final _Proxy<T> proxy;
  final _BoardState<T> board;

  @override
  Widget build(BuildContext context) {
    final style = board._style;
    final proxy = this.proxy;
    return Positioned(
      left: 0,
      top: 0,
      child: _ProxyTransform(
        proxy: proxy,
        dragScale: style.dragScale,
        radius: style.itemRadius,
        shadows: style.dragShadows,
        highlightColor: style.highlightColor,
        child: SizedBox.fromSize(
          size: proxy.size,
          child: ListenableBuilder(
            listenable: proxy.chrome,
            // Opaque while it is held, so nothing under the card hovers,
            // and so the wheel can be handed to the column beneath.
            builder: (context, child) => IgnorePointer(
              ignoring: !proxy.interactive,
              child: MouseRegion(
                cursor: proxy.forbidden
                    ? SystemMouseCursors.forbidden
                    : SystemMouseCursors.grabbing,
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerSignal: board._handleDragPointerSignal,
                  child: child,
                ),
              ),
            ),
            child: RepaintBoundary(
              child: IgnorePointer(
                child: Theme(
                  data: style.itemTheme,
                  child: Builder(
                    builder: (context) => board.widget.itemBuilder(
                      context,
                      proxy.item,
                      proxy.details,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProxyTransform extends SingleChildRenderObjectWidget {
  const _ProxyTransform({
    required this.proxy,
    required this.dragScale,
    required this.radius,
    required this.shadows,
    required this.highlightColor,
    required super.child,
  });

  final _Proxy<Object> proxy;
  final double dragScale;
  final BorderRadius radius;
  final List<BoxShadow> shadows;
  final Color highlightColor;

  @override
  _RenderProxy createRenderObject(BuildContext context) => _RenderProxy(
    proxy: proxy,
    dragScale: dragScale,
    radius: radius,
    shadows: shadows,
    highlightColor: highlightColor,
  );

  @override
  void updateRenderObject(BuildContext context, _RenderProxy renderObject) {
    renderObject
      ..proxy = proxy
      ..dragScale = dragScale
      ..radius = radius
      ..shadows = shadows
      ..highlightColor = highlightColor;
  }
}

/// Places, scales and tilts a lifted copy, and paints what the lift adds to
/// it: the shadow under it and the glow of a landing.
///
/// The copy moves every frame, so moving it must cost next to nothing. This
/// is a repaint boundary whose layer *is* the transform: a new position only
/// updates that layer, and neither this object nor the card inside it is
/// painted again. It repaints only while the shadow, the glow or the opacity
/// is changing — the first moments of a lift and the landing.
class _RenderProxy extends RenderProxyBox {
  _RenderProxy({
    required _Proxy<Object> proxy,
    required double dragScale,
    required BorderRadius radius,
    required List<BoxShadow> shadows,
    required Color highlightColor,
  }) : _proxy = proxy,
       _dragScale = dragScale,
       _radius = radius,
       _shadows = shadows,
       _highlightColor = highlightColor;

  _Proxy<Object> get proxy => _proxy;
  _Proxy<Object> _proxy;
  set proxy(_Proxy<Object> value) {
    if (identical(value, _proxy)) return;
    if (attached) _proxy.removeListener(_changed);
    _proxy = value;
    if (attached) {
      _proxy.addListener(_changed);
      markNeedsPaint();
    }
  }

  double get dragScale => _dragScale;
  double _dragScale;
  set dragScale(double value) {
    if (value == _dragScale) return;
    _dragScale = value;
    markNeedsCompositedLayerUpdate();
  }

  BorderRadius get radius => _radius;
  BorderRadius _radius;
  set radius(BorderRadius value) {
    if (value == _radius) return;
    _radius = value;
    _resetShadowPainter();
    markNeedsPaint();
  }

  List<BoxShadow> get shadows => _shadows;
  List<BoxShadow> _shadows;
  set shadows(List<BoxShadow> value) {
    if (listEquals(value, _shadows)) return;
    _shadows = value;
    _resetShadowPainter();
    markNeedsPaint();
  }

  Color get highlightColor => _highlightColor;
  Color _highlightColor;
  set highlightColor(Color value) {
    if (value == _highlightColor) return;
    _highlightColor = value;
    markNeedsPaint();
  }

  BoxPainter? _shadowPainter;
  final LayerHandle<OpacityLayer> _fade = LayerHandle<OpacityLayer>();

  // What the last paint drew, to tell a move from a change of looks.
  double _paintedShadow = -1;
  double _paintedGlow = -1;
  double _paintedOpacity = -1;

  void _resetShadowPainter() {
    _shadowPainter?.dispose();
    _shadowPainter = null;
  }

  /// The shadow of a lifted card, which comes and goes with the lift.
  double get _shadowOpacity => _proxy.lift.value.clamp(0.0, 1.0);

  /// The glow comes up quickly and fades slowly; `highlight` runs from 1
  /// down to 0.
  double get _glow {
    final highlight = _proxy.highlight;
    if (highlight <= 0) return 0;
    final progress = 1 - highlight;
    return progress < .12
        ? progress / .12
        : Curves.easeOut.transform(highlight / .88);
  }

  void _changed() {
    if (_shadowOpacity != _paintedShadow ||
        _glow != _paintedGlow ||
        _proxy.opacity != _paintedOpacity) {
      markNeedsPaint();
    } else {
      markNeedsCompositedLayerUpdate();
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _proxy.addListener(_changed);
  }

  @override
  void detach() {
    _proxy.removeListener(_changed);
    super.detach();
  }

  @override
  void dispose() {
    _resetShadowPainter();
    _fade.layer = null;
    super.dispose();
  }

  @override
  bool get isRepaintBoundary => true;

  /// The copy's top left corner is a global position; the overlay it is
  /// painted in need not start at the window's.
  Matrix4 _transform() {
    final position = _proxy.position;
    final origin = attached ? globalToLocal(position) : position;
    final half = hasSize ? size.center(Offset.zero) : Offset.zero;
    final scale = 1 + (_dragScale - 1) * _proxy.lift.value;
    return Matrix4.identity()
      ..translateByDouble(origin.dx + half.dx, origin.dy + half.dy, 0, 1)
      ..rotateZ(_proxy.tilt.value)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-half.dx, -half.dy, 0, 1);
  }

  @override
  OffsetLayer updateCompositedLayer({
    required covariant TransformLayer? oldLayer,
  }) {
    return (oldLayer ?? TransformLayer())..transform = _transform();
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform());
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // As with any transform, this box's own bounds are not where the card
    // is.
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _transform(),
      position: position,
      hitTest: (result, position) =>
          super.hitTestChildren(result, position: position),
    );
  }

  void _paintShadow(Canvas canvas, Offset offset, double opacity) {
    if (_shadows.isEmpty) return;
    final painter = _shadowPainter ??= ShadowDecoration.box(
      borderRadius: _radius,
      shadows: _shadows,
    ).createBoxPainter(markNeedsPaint);
    final fading = opacity < 1;
    if (fading) {
      var reach = 0.0;
      for (final shadow in _shadows) {
        reach = math.max(
          reach,
          shadow.offset.distance +
              math.max(0, shadow.spreadRadius) +
              shadow.blurSigma * 3 +
              1,
        );
      }
      canvas.saveLayer(
        (offset & size).inflate(reach),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      );
    }
    painter.paint(canvas, offset, ImageConfiguration(size: size));
    if (fading) canvas.restore();
  }

  void _paintGlow(Canvas canvas, Offset offset, double glow) {
    final rect = offset & size;
    final color = _highlightColor;
    canvas.drawRRect(
      _radius.toRRect(rect),
      Paint()..color = color.withValues(alpha: color.a * .1 * glow),
    );
    Border.all(
      color: color.withValues(alpha: color.a * .7 * glow),
      width: 1.5,
    ).paint(canvas, rect, borderRadius: _radius);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final shadow = _paintedShadow = _shadowOpacity;
    final glow = _paintedGlow = _glow;
    final opacity = _paintedOpacity = _proxy.opacity;
    if (opacity <= 0) {
      _fade.layer = null;
      return;
    }

    void contents(PaintingContext context, Offset offset) {
      // The shadow is painted here, not by the card: the card paints its
      // own decoration, at rest.
      if (shadow > 0) _paintShadow(context.canvas, offset, shadow);
      super.paint(context, offset);
      if (glow > 0) _paintGlow(context.canvas, offset, glow);
    }

    if (opacity < 1) {
      _fade.layer = context.pushOpacity(
        offset,
        (opacity * 255).round(),
        contents,
        oldLayer: _fade.layer,
      );
    } else {
      _fade.layer = null;
      contents(context, offset);
    }
  }
}

/// Starts a drag once the pointer has moved [slop] logical pixels, in any
/// direction. Flutter's own immediate recognizer waits for one pixel with a
/// mouse, which turns a slightly unsteady click into a drag.
class _SlopMultiDragGestureRecognizer extends MultiDragGestureRecognizer {
  _SlopMultiDragGestureRecognizer({required this.slop, super.debugOwner});

  final double slop;

  @override
  MultiDragPointerState createNewPointerState(PointerDownEvent event) =>
      _SlopPointerState(event.position, event.kind, gestureSettings, slop);

  @override
  String get debugDescription => 'board drag';
}

class _SlopPointerState extends MultiDragPointerState {
  _SlopPointerState(
    super.initialPosition,
    super.kind,
    super.gestureSettings,
    this.slop,
  );

  final double slop;

  // Set when the arena was won before the pointer had moved far enough —
  // which it is at once when nothing else wants the pointer.
  GestureMultiDragStartCallback? _starter;

  @override
  void checkForResolutionAfterMove() {
    if (pendingDelta!.distance <= slop) return;
    final starter = _starter;
    if (starter == null) {
      resolve(GestureDisposition.accepted);
    } else {
      _starter = null;
      starter(initialPosition);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    if (pendingDelta!.distance > slop) {
      starter(initialPosition);
    } else {
      _starter = starter;
    }
  }

  @override
  void dispose() {
    _starter = null;
    super.dispose();
  }
}

/// The `Drag` the gesture recognizer drives.
class _PointerDrag<T extends Object> implements Drag {
  _PointerDrag(this.board, this.drag);

  final _BoardState<T> board;
  final _Drag<T> drag;

  @override
  void update(DragUpdateDetails details) =>
      board._pointerMoved(drag, details.globalPosition);

  @override
  void end(DragEndDetails details) => board._pointerReleased(drag);

  @override
  void cancel() => board._pointerCancelled(drag);
}

/// The distance between two columns' leading edges, read by
/// [_BoardSnapPhysics] when a fling ends.
///
/// A `Scrollable` keeps its first physics object for as long as the type
/// matches, so the physics cannot carry the number itself: it would be the
/// one from the first build for ever.
class _SnapMetrics {
  double step = 0;
  bool enabled = false;
}

/// Scroll physics that bring the board to rest with a column at its leading
/// edge, like a page view whose pages are narrower than the viewport.
class _BoardSnapPhysics extends ScrollPhysics {
  const _BoardSnapPhysics({required this.metrics, super.parent});

  final _SnapMetrics metrics;

  @override
  _BoardSnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _BoardSnapPhysics(metrics: metrics, parent: buildParent(ancestor));

  double _target(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    var page = position.pixels / metrics.step;
    if (velocity < -tolerance.velocity) {
      page -= .5;
    } else if (velocity > tolerance.velocity) {
      page += .5;
    }
    return (page.roundToDouble() * metrics.step).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (!metrics.enabled || metrics.step <= 0) {
      return super.createBallisticSimulation(position, velocity);
    }
    // Past an end, let the parent physics bring it back.
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final target = _target(position, velocity);
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => false;
}

/// The board's theme, its widget's overrides and the motion in force,
/// resolved once per build so that nothing below reads a nullable.
@immutable
class _BoardStyle {
  const _BoardStyle({
    required this.columnGap,
    required this.itemGap,
    required this.padding,
    required this.columnPadding,
    required this.headerPadding,
    required this.footerPadding,
    required this.columnRadius,
    required this.columnColor,
    required this.columnBorderColor,
    required this.targetColumnColor,
    required this.targetColumnBorderColor,
    required this.refusedColumnColor,
    required this.refusedColumnBorderColor,
    required this.headerTextStyle,
    required this.countTextStyle,
    required this.countColor,
    required this.countForegroundColor,
    required this.fullCountColor,
    required this.fullCountForegroundColor,
    required this.itemRadius,
    required this.placeholderColor,
    required this.placeholderBorderColor,
    required this.emptyHeight,
    required this.dragScale,
    required this.dragTilt,
    required this.landScale,
    required this.dragShadows,
    required this.highlightColor,
    required this.highlightSeconds,
    required this.lift,
    required this.shift,
    required this.drop,
    required this.land,
    required this.fade,
    required this.fadeCurve,
    required this.turn,
    required this.turnCurve,
    required this.autoScrollExtent,
    required this.autoScrollSpeed,
    required this.snap,
    required this.reduced,
    required this.itemTheme,
    required this.textDirection,
  });

  final double columnGap;
  final double itemGap;
  final EdgeInsets padding;
  final EdgeInsets columnPadding;
  final EdgeInsets headerPadding;
  final EdgeInsets footerPadding;
  final BorderRadius columnRadius;
  final Color columnColor;
  final Color columnBorderColor;
  final Color targetColumnColor;
  final Color targetColumnBorderColor;
  final Color refusedColumnColor;
  final Color refusedColumnBorderColor;
  final TextStyle headerTextStyle;
  final TextStyle countTextStyle;
  final Color countColor;
  final Color countForegroundColor;
  final Color fullCountColor;
  final Color fullCountForegroundColor;
  final BorderRadius itemRadius;
  final Color placeholderColor;
  final Color placeholderBorderColor;
  final double emptyHeight;
  final double dragScale;
  final double dragTilt;
  final double landScale;
  final List<BoxShadow> dragShadows;
  final Color highlightColor;
  final double highlightSeconds;
  final _SpringSpec lift;
  final _SpringSpec shift;
  final _SpringSpec drop;
  final _SpringSpec land;

  /// The duration and curve of the board's plain fades: a column changing
  /// colour, the slot appearing.
  final Duration fade;
  final Curve fadeCurve;

  /// The duration and curve of a scroll the board makes by itself: turning
  /// to the next column, bringing a slot into view.
  final Duration turn;
  final Curve turnCurve;
  final double autoScrollExtent;
  final double autoScrollSpeed;
  final bool snap;

  /// Whether motion is reduced: nothing slides, scales or tilts.
  final bool reduced;

  /// The theme items, and their lifted copies, are built in.
  final ThemeData itemTheme;
  final TextDirection textDirection;
}

/// Paints a dashed rounded rectangle: an empty column's drop target.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    final path = Path()
      ..addRRect(radius.toRRect((Offset.zero & size).deflate(.5)));
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      // Whole dashes only, so the pattern closes on itself.
      final count = math.max(1, (metric.length / (dash + gap)).round());
      final period = metric.length / count;
      for (var i = 0; i < count; i++) {
        final start = i * period;
        canvas.drawPath(
          metric.extractPath(start, start + period * dash / (dash + gap)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
