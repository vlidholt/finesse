import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// The one clock every animated `Skeleton` paints from.
///
/// A ticker runs while at least one skeleton listens and stops when the last
/// one goes, so skeletons anywhere on screen are at the same point of their
/// pulse or shimmer — neighbours shimmer as one — and a hundred of them cost
/// one ticker. Each skeleton listens only while its `TickerMode` lets it.
class SkeletonClock extends ChangeNotifier {
  SkeletonClock._();

  /// The clock.
  static final SkeletonClock instance = SkeletonClock._();

  Ticker? _ticker;
  int _listeners = 0;
  Duration _elapsed = Duration.zero;

  /// How long the clock has run since a skeleton first listened.
  Duration get elapsed => _elapsed;

  /// Whether the clock is running.
  bool get isTicking => _ticker?.isActive ?? false;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listeners++;
    if (_listeners == 1) {
      _elapsed = Duration.zero;
      (_ticker ??= Ticker(_tick, debugLabel: 'SkeletonClock')).start();
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _listeners--;
    if (_listeners == 0) _ticker?.stop();
  }

  void _tick(Duration elapsed) {
    _elapsed = elapsed;
    notifyListeners();
  }
}

/// How a skeleton moves.
enum SkeletonMotion {
  /// Not at all: the base colour.
  still,

  /// The whole block fades towards the highlight and back.
  pulse,

  /// A soft band of the highlight sweeps across the screen; every skeleton
  /// shows the part of it that passes over it.
  shimmer,
}

/// Paints a skeleton's block: a rounded rectangle in its colour, pulsing or
/// shimmering from [SkeletonClock] at paint time. Its child, if any, sizes
/// it and is not painted.
class SkeletonPaint extends SingleChildRenderObjectWidget {
  /// Creates the painted block of a skeleton.
  const SkeletonPaint({
    super.key,
    required this.color,
    required this.highlightColor,
    required this.borderRadius,
    required this.motion,
    required this.period,
    required this.curve,
    super.child,
  });

  /// The base colour.
  final Color color;

  /// The colour of the pulse's far end or the shimmer's band.
  final Color highlightColor;

  /// The corners.
  final BorderRadiusGeometry borderRadius;

  /// How it moves.
  final SkeletonMotion motion;

  /// One pulse, or one shimmer pass with its pause.
  final Duration period;

  /// The curve of the pulse or of the band's travel.
  final Curve curve;

  @override
  RenderSkeleton createRenderObject(BuildContext context) => RenderSkeleton(
    color: color,
    highlightColor: highlightColor,
    borderRadius: borderRadius,
    motion: _motionFor(context),
    period: period,
    curve: curve,
    textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
    viewSize: MediaQuery.maybeSizeOf(context) ?? const Size(800, 600),
  );

  // Off stage — under a covered route, or a hidden child of an
  // `IndexedStack`, which keeps its tickers running — it holds still and
  // stops listening to the clock.
  SkeletonMotion _motionFor(BuildContext context) =>
      TickerMode.valuesOf(context).enabled && Visibility.of(context)
      ? motion
      : SkeletonMotion.still;

  @override
  void updateRenderObject(BuildContext context, RenderSkeleton renderObject) {
    renderObject
      ..color = color
      ..highlightColor = highlightColor
      ..borderRadius = borderRadius
      ..motion = _motionFor(context)
      ..period = period
      ..curve = curve
      ..textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr
      ..viewSize = MediaQuery.maybeSizeOf(context) ?? const Size(800, 600);
  }
}

/// The render object of [SkeletonPaint]: a repaint boundary that repaints
/// itself on every tick of [SkeletonClock] while it moves, and paints
/// nothing of its child.
class RenderSkeleton extends RenderProxyBox {
  /// Creates the render object.
  RenderSkeleton({
    required Color color,
    required Color highlightColor,
    required BorderRadiusGeometry borderRadius,
    required SkeletonMotion motion,
    required Duration period,
    required Curve curve,
    required TextDirection textDirection,
    required Size viewSize,
  }) : _color = color,
       _highlightColor = highlightColor,
       _borderRadius = borderRadius,
       _motion = motion,
       _period = period,
       _curve = curve,
       _textDirection = textDirection,
       _viewSize = viewSize;

  /// The angle the shimmer's band leans at, from the vertical.
  static const bandLean = math.pi / 9;

  /// The base colour.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  /// The highlight's colour.
  Color get highlightColor => _highlightColor;
  Color _highlightColor;
  set highlightColor(Color value) {
    if (value == _highlightColor) return;
    _highlightColor = value;
    markNeedsPaint();
  }

  /// The corners.
  BorderRadiusGeometry get borderRadius => _borderRadius;
  BorderRadiusGeometry _borderRadius;
  set borderRadius(BorderRadiusGeometry value) {
    if (value == _borderRadius) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  /// How it moves.
  SkeletonMotion get motion => _motion;
  SkeletonMotion _motion;
  set motion(SkeletonMotion value) {
    if (value == _motion) return;
    final wasMoving = _moving;
    _motion = value;
    if (attached && wasMoving != _moving) {
      if (_moving) {
        SkeletonClock.instance.addListener(markNeedsPaint);
      } else {
        SkeletonClock.instance.removeListener(markNeedsPaint);
      }
    }
    markNeedsPaint();
  }

  /// One pulse, or one pass with its pause.
  Duration get period => _period;
  Duration _period;
  set period(Duration value) {
    if (value == _period) return;
    _period = value;
    markNeedsPaint();
  }

  /// The curve of the pulse or of the band.
  Curve get curve => _curve;
  Curve _curve;
  set curve(Curve value) {
    if (value == _curve) return;
    _curve = value;
    markNeedsPaint();
  }

  /// Which edge the shimmer starts from.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  /// The size of the screen the shimmer crosses.
  Size get viewSize => _viewSize;
  Size _viewSize;
  set viewSize(Size value) {
    if (value == _viewSize) return;
    _viewSize = value;
    markNeedsPaint();
  }

  bool get _moving =>
      _motion != SkeletonMotion.still && _period > Duration.zero;

  /// Whether this skeleton is listening to the clock.
  @visibleForTesting
  bool get isListening => attached && _moving;

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_moving) SkeletonClock.instance.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    if (_moving) SkeletonClock.instance.removeListener(markNeedsPaint);
    super.detach();
  }

  /// Where in its period the clock is, 0 to 1.
  double get _phase {
    final micros = _period.inMicroseconds;
    return SkeletonClock.instance.elapsed.inMicroseconds % micros / micros;
  }

  /// The colour of a pulsing skeleton now; the base colour otherwise.
  @visibleForTesting
  Color get pulseColor {
    if (_motion != SkeletonMotion.pulse || !_moving) return _color;
    // There and back once per period.
    final t = _curve.transform(1 - (_phase * 2 - 1).abs());
    return Color.lerp(_color, _highlightColor, t)!;
  }

  /// Where the centre of the shimmer's band is now, measured along its
  /// direction of travel from the screen's leading top corner; null while
  /// it rests between passes.
  @visibleForTesting
  double? get bandCentre {
    if (_motion != SkeletonMotion.shimmer || !_moving) return null;
    // The band crosses in three quarters of the period and rests for the
    // last quarter, so a pass reads as a pass and not as a conveyor belt.
    const travel = .75;
    final p = _phase;
    if (p >= travel) return null;
    final span = _span;
    return -_bandWidth + (span + _bandWidth * 2) * _curve.transform(p / travel);
  }

  /// The screen's extent along the band's direction of travel.
  double get _span =>
      _viewSize.width * math.cos(bandLean) +
      _viewSize.height * math.sin(bandLean);

  double get _bandWidth => (_span * .24).clamp(120.0, 320.0);

  @override
  void paint(PaintingContext context, Offset offset) {
    final rrect = _borderRadius.resolve(_textDirection).toRRect(offset & size);
    final canvas = context.canvas;
    final paint = Paint()..color = pulseColor;
    final centre = bandCentre;
    if (centre != null) {
      // The band's direction, mirrored in a right-to-left layout, and this
      // box's top-left on the screen, measured from the leading edge.
      final rtl = _textDirection == TextDirection.rtl;
      final direction = Offset(
        (rtl ? -1 : 1) * math.cos(bandLean),
        math.sin(bandLean),
      );
      var origin = localToGlobal(Offset.zero);
      if (rtl) origin = origin.translate(-_viewSize.width, 0);
      final along = origin.dx * direction.dx + origin.dy * direction.dy;
      // Only a box the band is over pays for a gradient.
      final reach = size.width.abs() + size.height.abs();
      if (centre + _bandWidth / 2 > along - reach &&
          centre - _bandWidth / 2 < along + reach) {
        final from = centre - _bandWidth / 2 - along;
        final to = centre + _bandWidth / 2 - along;
        final mid = Color.lerp(_color, _highlightColor, .55)!;
        // A shader is drawn at the paint colour's alpha: an opaque colour
        // leaves the gradient's own alphas alone.
        paint
          ..color = const Color(0xFF000000)
          ..shader = ui.Gradient.linear(
            offset + direction * from,
            offset + direction * to,
            [_color, mid, _highlightColor, mid, _color],
            const [0, .3, .5, .7, 1],
          );
      }
    }
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool hitTestSelf(Offset position) => false;
}
