import 'dart:math' as math;
import 'dart:ui' show ClipOp;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// {@template ShadowDecoration}
/// A [Decoration] that paints [shadows] behind [decoration] the way CSS paints
/// an outer `box-shadow`.
///
/// Flutter's [BoxShadow] cannot express that on its own:
///
/// * With the default [BlurStyle.normal] the whole blurred shape is painted
///   behind the element, so it shows through any transparent or translucent
///   fill as a grey wash.
/// * With [BlurStyle.outer] the hole is cut out of the *shadow's* own
///   rectangle — `rect.shift(offset).inflate(spreadRadius)`, see
///   `BoxDecoration`'s painter — which is a different shape from the element
///   whenever the shadow has an offset or a spread. Every shadow in `Shadows`
///   has both, so the cut-out lands below and inside the element: a `shadow-lg`
///   dialog loses the 7px of shadow directly under it and then starts again
///   with a hard edge.
///
/// CSS clips to the border box itself. This does the same: the shadows are
/// blurred normally and clipped to the region *outside*
/// [Decoration.getClipPath] of the wrapped decoration, which is where both
/// behaviours above were trying to get to.
///
/// [decoration] must not carry shadows of its own — pass them here instead.
/// Inset shadows are not covered by this; they stay on the wrapped decoration,
/// where [BlurStyle.inner] already clips them the way CSS clips `inset`.
/// {@endtemplate}
@immutable
class ShadowDecoration extends Decoration {
  /// {@macro ShadowDecoration}
  const ShadowDecoration({
    required this.decoration,
    this.shadows = const [],
  });

  /// A [ShadowDecoration] wrapping a [BoxDecoration] built from the usual
  /// [BoxDecoration] arguments, so a call site reads like the plain decoration
  /// it replaces.
  factory ShadowDecoration.box({
    List<BoxShadow> shadows = const [],
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadiusGeometry? borderRadius,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return ShadowDecoration(
      shadows: shadows,
      decoration: BoxDecoration(
        color: color,
        image: image,
        border: border,
        borderRadius: borderRadius,
        gradient: gradient,
        backgroundBlendMode: backgroundBlendMode,
        shape: shape,
      ),
    );
  }

  /// The decoration painted on top of [shadows].
  final Decoration decoration;

  /// The outer shadows, painted behind [decoration] and clipped to the region
  /// outside its shape.
  final List<BoxShadow> shadows;

  @override
  EdgeInsetsGeometry get padding => decoration.padding;

  @override
  bool get isComplex => shadows.isNotEmpty || decoration.isComplex;

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      decoration.getClipPath(rect, textDirection);

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) =>
      decoration.hitTest(size, position, textDirection: textDirection);

  @override
  ShadowDecoration? lerpFrom(Decoration? a, double t) {
    final other = _wrap(a);
    if (other == null && a != null) return null;
    return ShadowDecoration(
      decoration: Decoration.lerp(other?.decoration, decoration, t)!,
      shadows: BoxShadow.lerpList(other?.shadows, shadows, t) ?? const [],
    );
  }

  @override
  ShadowDecoration? lerpTo(Decoration? b, double t) {
    final other = _wrap(b);
    if (other == null && b != null) return null;
    return ShadowDecoration(
      decoration: Decoration.lerp(decoration, other?.decoration, t)!,
      shadows: BoxShadow.lerpList(shadows, other?.shadows, t) ?? const [],
    );
  }

  /// Views a plain [BoxDecoration]/[ShapeDecoration] as a shadowless
  /// [ShadowDecoration] so the two can be lerped against each other.
  static ShadowDecoration? _wrap(Decoration? decoration) {
    return switch (decoration) {
      null => null,
      final ShadowDecoration d => d,
      final BoxDecoration d => ShadowDecoration(decoration: d),
      final ShapeDecoration d => ShadowDecoration(decoration: d),
      _ => null,
    };
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    final inner = onChanged == null
        ? decoration.createBoxPainter()
        : decoration.createBoxPainter(onChanged);
    return _ShadowPainter(this, inner, onChanged);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShadowDecoration &&
        other.decoration == decoration &&
        listEquals(other.shadows, shadows);
  }

  @override
  int get hashCode => Object.hash(decoration, Object.hashAll(shadows));

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Decoration>('decoration', decoration))
      ..add(IterableProperty<BoxShadow>('shadows', shadows));
  }
}

class _ShadowPainter extends BoxPainter {
  _ShadowPainter(this._decoration, this._inner, [super.onChanged]);

  final ShadowDecoration _decoration;
  final BoxPainter _inner;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size != null) {
      paintOuterShadows(
        canvas,
        offset & size,
        shadows: _decoration.shadows,
        decoration: _decoration.decoration,
        textDirection: configuration.textDirection,
        // Painted next, on top, in the same shape.
        covered: _isOpaque(_decoration.decoration),
      );
    }
    _inner.paint(canvas, offset, configuration);
  }

  @override
  void dispose() {
    _inner.dispose();
    super.dispose();
  }
}

/// Whether [decoration] fills its whole shape with an opaque colour, so
/// that nothing painted under it shows.
bool _isOpaque(Decoration decoration) =>
    decoration is BoxDecoration &&
    decoration.backgroundBlendMode == null &&
    (decoration.color?.a ?? 0) >= 1;

/// Paints [shadows] outside the shape [decoration] describes for [rect], the
/// way CSS clips an outer `box-shadow` to the border box.
///
/// With [covered], the caller paints an opaque fill of the same shape on
/// top straight afterwards, and the shadows are painted whole: what the
/// clip would have removed is hidden anyway, and a clip is the expensive
/// half of a shadow.
///
/// {@macro ShadowDecoration}
void paintOuterShadows(
  Canvas canvas,
  Rect rect, {
  required List<BoxShadow> shadows,
  required Decoration decoration,
  TextDirection? textDirection,
  bool covered = false,
}) {
  if (shadows.isEmpty || rect.isEmpty) return;

  // How far the shadows can reach from the element, so the clip has something
  // finite to subtract the border box from. Three sigma covers a gaussian.
  var reach = 0.0;
  for (final shadow in shadows) {
    final shadowReach =
        shadow.spreadRadius +
        shadow.blurSigma * 3 +
        math.max(shadow.offset.dx.abs(), shadow.offset.dy.abs());
    reach = math.max(reach, shadowReach);
  }
  if (reach <= 0) return;

  final direction = textDirection ?? TextDirection.ltr;

  void paintShadows() {
    for (final shadow in shadows) {
      final bounds = rect.shift(shadow.offset).inflate(shadow.spreadRadius);
      if (bounds.isEmpty) continue;
      final paint = Paint()..color = shadow.color;
      if (shadow.blurSigma > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma);
      }
      assert(() {
        if (debugDisableShadows) paint.maskFilter = null;
        return true;
      }());
      canvas.drawPath(
        _spreadPath(decoration, bounds, shadow, direction),
        paint,
      );
    }
  }

  if (covered) return paintShadows();

  final box = _roundedBoxOf(decoration, rect, direction);
  if (box != null) {
    return _paintOutsideBox(canvas, box, paintShadows);
  }

  canvas.save();
  // Any other shape: a tooltip with its arrow, a `ShapeDecoration`.
  _clipOutside(
    canvas,
    rect.inflate(reach + 1),
    decoration.getClipPath(rect, direction),
  );
  paintShadows();
  canvas.restore();
}

/// The rounded rectangle [decoration] fills in [rect], when it is a box: a
/// rectangle, a rounded one, or a circle (a square with full corners).
RRect? _roundedBoxOf(
  Decoration decoration,
  Rect rect,
  TextDirection direction,
) {
  if (decoration is! BoxDecoration) return null;
  switch (decoration.shape) {
    case BoxShape.circle:
      final square = Rect.fromCircle(
        center: rect.center,
        radius: rect.shortestSide / 2,
      );
      return RRect.fromRectAndRadius(
        square,
        Radius.circular(square.width / 2),
      );
    case BoxShape.rectangle:
      final radius = decoration.borderRadius?.resolve(direction);
      return (radius ?? BorderRadius.zero).toRRect(rect).scaleRadii();
  }
}

/// Runs [paint] clipped to the outside of [box], without a clip the size of
/// the shadow.
///
/// The obvious clip — the shadow's bounds with [box] cut out of them as one
/// path — is the slowest thing a shadow can ask for. Skia has no analytic
/// form for it, so on the web it rasterises a coverage mask the size of the
/// whole shadow on the CPU and uploads it, and does so again on every frame
/// in which the surface has moved by a fraction of a pixel: every frame of
/// a scroll, for every card on screen. Measured on the Strand feed that
/// clip was two thirds of the whole frame's raster time.
///
/// The outside of a rounded box is the outside of its bounding rectangle
/// plus the four slivers between each square corner and its arc. The first
/// is a rectangle clipped by difference, which every renderer does without
/// a mask; the slivers do need one, but each is a corner radius across. So
/// the shadows are painted five times through small or cheap clips instead
/// of once through a huge one — and a blurred rounded rectangle is a draw
/// Skia has a fast path for.
void _paintOutsideBox(Canvas canvas, RRect box, VoidCallback paint) {
  final rect = box.outerRect;
  canvas
    ..save()
    ..clipRect(rect, clipOp: ClipOp.difference);
  paint();
  canvas.restore();

  // [horizontal] and [vertical] point from the corner into the box.
  void sliver(
    Offset corner,
    Radius radius,
    double horizontal,
    double vertical,
  ) {
    if (radius.x <= 0 || radius.y <= 0) return;
    canvas
      ..save()
      ..clipPath(
        Path()
          ..moveTo(corner.dx, corner.dy)
          ..lineTo(corner.dx + horizontal * radius.x, corner.dy)
          ..arcToPoint(
            Offset(corner.dx, corner.dy + vertical * radius.y),
            radius: radius,
            clockwise: horizontal * vertical < 0,
          )
          ..close(),
      );
    paint();
    canvas.restore();
  }

  sliver(rect.topLeft, box.tlRadius, 1, 1);
  sliver(rect.topRight, box.trRadius, -1, 1);
  sliver(rect.bottomLeft, box.blRadius, 1, -1);
  sliver(rect.bottomRight, box.brRadius, -1, -1);
}

/// Clips [canvas] to the part of [bounds] that is outside [shape], whatever
/// the shape. A box does not come here: see [_paintOutsideBox].
///
/// Each contour of [shape] is cut out of [bounds] as the hole of an
/// even-odd path. Not `Path.combine(PathOperation.difference, …)`: on the
/// web that returns its first operand unchanged, the clip then covers the
/// element too, and every shadow is painted behind the whole surface —
/// exactly the grey wash through a translucent fill this file exists to
/// prevent. `test/src/utils/shadow_web_test.dart` runs it in a browser.
///
/// One contour at a time, because even-odd counts an overlap twice: two
/// contours that overlap (a tooltip's bubble and its arrow) cut out
/// together would leave the overlap *in*. Cutting them out one after the
/// other intersects the clips, which is the outside of their union.
void _clipOutside(Canvas canvas, Rect bounds, Path shape) {
  for (final contour in shape.computeMetrics()) {
    canvas.clipPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(bounds)
        ..addPath(contour.extractPath(0, contour.length)..close(), Offset.zero),
    );
  }
}

/// The shadow's own shape at [bounds].
///
/// A CSS spread grows the corner radii along with the box, which
/// [Decoration.getClipPath] does not do for a [BoxDecoration] — it keeps the
/// element's radii on the larger rect. That is invisible under a wide blur but
/// not for the crisp spread-only shadows used as outlines, so rounded
/// rectangles are built here instead.
Path _spreadPath(
  Decoration decoration,
  Rect bounds,
  BoxShadow shadow,
  TextDirection textDirection,
) {
  if (decoration case BoxDecoration(
    shape: BoxShape.rectangle,
    :final borderRadius?,
  ) when shadow.spreadRadius != 0) {
    final radius = borderRadius.resolve(textDirection);
    Radius grow(Radius r) => Radius.elliptical(
      math.max(0, r.x + shadow.spreadRadius),
      math.max(0, r.y + shadow.spreadRadius),
    );
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        bounds,
        topLeft: grow(radius.topLeft),
        topRight: grow(radius.topRight),
        bottomLeft: grow(radius.bottomLeft),
        bottomRight: grow(radius.bottomRight),
      ),
    );
  }
  return decoration.getClipPath(bounds, textDirection);
}
