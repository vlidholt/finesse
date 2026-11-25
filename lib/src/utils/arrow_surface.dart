import 'dart:math' as math;

import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:flutter/widgets.dart';

/// The outline of a floating surface: its box and, when [direction] is not
/// null, the arrow pointing from it at whatever it is anchored to. A
/// `Tooltip`'s bubble and an arrowed `Popover` are both one of these.
///
/// The arrow is shadcn/ui's `TooltipArrow`: a `size-2.5` square rotated 45°,
/// its tip rounded by `rounded-[2px]`, its centre 2px inside the edge it
/// rides (`translate-y-[calc(-50%-2px)]`) so about half its diagonal — 5px —
/// pokes out across the anchor gap.
///
/// Along its edge the arrow tracks the trigger rather than the surface: one
/// near the side of the window is pushed inward to stay on screen (see
/// [PortalPlacement.shift]) and a centred arrow would then point somewhere
/// the trigger is not. It stops short of the corners, where a rounded
/// surface has no straight edge left to sit on.
@immutable
class ArrowShape {
  /// Creates the outline of a surface with [radius] corners and an arrow on
  /// the [direction] edge.
  const ArrowShape({
    required this.radius,
    required this.direction,
    required this.arrowSize,
    required this.arrowRadius,
    required this.shift,
    this.anchor = Alignment.center,
  });

  /// The surface's corners.
  final BorderRadius radius;

  /// The edge the arrow rides — [AxisDirection.down] is the bottom edge, the
  /// arrow pointing down — or null for no arrow.
  final AxisDirection? direction;

  /// The side of the arrow's square.
  final double arrowSize;

  /// The corner radius of the arrow's tip.
  final double arrowRadius;

  /// The point of the surface the arrow sits at along its edge, before
  /// [shift]: the centre for a surface centred on its trigger.
  final Alignment anchor;

  /// How far the surface was moved off its anchor, from
  /// [PortalPlacement.shift]. The arrow moves back by as much of this as
  /// its edge has room for.
  final Offset shift;

  /// How far the arrow's centre sits inside the edge it rides.
  static const inset = 2.0;

  /// How far the tip of an arrow of [arrowSize] and [arrowRadius] pokes out
  /// of the edge it rides: half the square's diagonal, less the [inset] and
  /// what the rounding takes off the corner.
  static double protrusionOf(double arrowSize, double arrowRadius) => math.max(
    0,
    arrowSize * math.sqrt2 / 2 - inset - arrowRadius * (math.sqrt2 - 1),
  );

  /// How far from the centre of an edge of [extent] the arrow may sit.
  double _travel(double extent) {
    final cornerRadius = [
      radius.topLeft.x,
      radius.topRight.x,
      radius.bottomLeft.x,
      radius.bottomRight.x,
    ].reduce(math.max);
    // The rotated square is `size * sqrt2` across, so its own half-diagonal
    // has to clear the corner too.
    final keepClear = cornerRadius + arrowSize * math.sqrt2 / 2;
    return math.max(0, extent / 2 - keepClear);
  }

  /// The centre of the arrow's square on a surface of [size], or null
  /// without an arrow.
  Offset? arrowCenter(Size size) {
    final direction = this.direction;
    if (direction == null) return null;
    final along = switch (direction) {
      AxisDirection.down || AxisDirection.up =>
        size.width / 2 +
            (anchor.x / 2 * size.width - shift.dx).clamp(
              -_travel(size.width),
              _travel(size.width),
            ),
      AxisDirection.left || AxisDirection.right =>
        size.height / 2 +
            (anchor.y / 2 * size.height - shift.dy).clamp(
              -_travel(size.height),
              _travel(size.height),
            ),
    };
    return switch (direction) {
      AxisDirection.down => Offset(along, size.height - inset),
      AxisDirection.up => Offset(along, inset),
      AxisDirection.left => Offset(inset, along),
      AxisDirection.right => Offset(size.width - inset, along),
    };
  }

  /// The outline on a surface of [size], as the box and the arrow's square:
  /// two contours wound the same way, to be filled non-zero.
  ///
  /// That is their union, with the overlap counted once. Not
  /// `Path.combine(PathOperation.union, …)`, which on the web returns the
  /// box alone — a tooltip without its arrow.
  Path build(Size size) {
    final box = Path()..addRRect(radius.toRRect(Offset.zero & size));
    final center = arrowCenter(size);
    if (center == null) return box;
    final square = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: arrowSize,
            height: arrowSize,
          ),
          Radius.circular(arrowRadius),
        ),
      );
    final placed = square.transform(
      (Matrix4.translationValues(
        center.dx,
        center.dy,
        0,
      )..rotateZ(math.pi / 4)).storage,
    );
    return box..addPath(placed, Offset.zero);
  }

  /// The same outline as **one** contour: round the box, out to the arrow's
  /// tip and back where the arrow is.
  ///
  /// A line drawn along [build] would cross the arrow's foot and trace the
  /// part of the square that is inside the box; this one can be stroked. A
  /// surface with a border fills, clips and casts its shadow with it too,
  /// so that all four agree to the pixel.
  Path outline(Size size) {
    final rrect = radius.toRRect(Offset.zero & size).scaleRadii();
    final center = arrowCenter(size);
    final direction = this.direction;
    final path = Path();

    // The arrow, entered at its first foot on the edge and left at its
    // second, travelling clockwise round the box. [out] points away from
    // the box, [along] the way the contour is going.
    void arrow(AxisDirection edge, Offset along, Offset out) {
      if (center == null || direction != edge) return;
      final half = arrowSize * math.sqrt2 / 2;
      final foot = half - inset;
      if (foot <= 0) return;
      // Where the rounding of the tip begins and ends on the two sides.
      final cut = math.min(arrowRadius, foot * math.sqrt2) / math.sqrt2;
      final base = center + out * inset;
      final tip = base + out * foot;
      path
        ..lineTo((base - along * foot).dx, (base - along * foot).dy)
        ..lineTo(
          (tip - along * cut - out * cut).dx,
          (tip - along * cut - out * cut).dy,
        );
      if (cut > 0) {
        path.arcToPoint(
          tip + along * cut - out * cut,
          radius: Radius.circular(cut * math.sqrt2),
        );
      }
      path.lineTo((base + along * foot).dx, (base + along * foot).dy);
    }

    path.moveTo(rrect.left + rrect.tlRadiusX, rrect.top);
    arrow(AxisDirection.up, const Offset(1, 0), const Offset(0, -1));
    path
      ..lineTo(rrect.right - rrect.trRadiusX, rrect.top)
      ..arcToPoint(
        Offset(rrect.right, rrect.top + rrect.trRadiusY),
        radius: rrect.trRadius,
      );
    arrow(AxisDirection.right, const Offset(0, 1), const Offset(1, 0));
    path
      ..lineTo(rrect.right, rrect.bottom - rrect.brRadiusY)
      ..arcToPoint(
        Offset(rrect.right - rrect.brRadiusX, rrect.bottom),
        radius: rrect.brRadius,
      );
    arrow(AxisDirection.down, const Offset(-1, 0), const Offset(0, 1));
    path
      ..lineTo(rrect.left + rrect.blRadiusX, rrect.bottom)
      ..arcToPoint(
        Offset(rrect.left, rrect.bottom - rrect.blRadiusY),
        radius: rrect.blRadius,
      );
    arrow(AxisDirection.left, const Offset(0, -1), const Offset(-1, 0));
    path
      ..lineTo(rrect.left, rrect.top + rrect.tlRadiusY)
      ..arcToPoint(
        Offset(rrect.left + rrect.tlRadiusX, rrect.top),
        radius: rrect.tlRadius,
      )
      ..close();
    return path;
  }

  @override
  bool operator ==(Object other) =>
      other is ArrowShape &&
      other.radius == radius &&
      other.direction == direction &&
      other.arrowSize == arrowSize &&
      other.arrowRadius == arrowRadius &&
      other.anchor == anchor &&
      other.shift == shift;

  @override
  int get hashCode =>
      Object.hash(radius, direction, arrowSize, arrowRadius, anchor, shift);
}

/// Where the arrow of a surface shown by a [Portal] goes: the edge it rides
/// and the point along it that faces the trigger.
@immutable
class ArrowPlacement {
  /// Creates a placement.
  const ArrowPlacement({
    required this.direction,
    required this.anchor,
    required this.shift,
  });

  /// See [ArrowShape.direction].
  final AxisDirection? direction;

  /// See [ArrowShape.anchor].
  final Alignment anchor;

  /// See [ArrowShape.shift].
  final Offset shift;

  /// The edge of an overlay that faces what it is anchored to, given the
  /// point of the overlay ([overlayPoint]) that sits on a point of the
  /// target ([targetPoint], null for a bare point on screen).
  ///
  /// The overlay lies wholly beyond the target on an axis when an edge of
  /// one meets the opposite edge of the other; that is the axis the arrow
  /// crosses. Below or above wins over beside — an overlay hanging off a
  /// corner is a menu under its trigger. One that overlaps its target on
  /// both axes points from whichever edge its anchor point is nearer, and
  /// one centred on its target has nowhere to point.
  static AxisDirection? directionFor(
    Alignment overlayPoint,
    Alignment? targetPoint,
  ) {
    if (targetPoint != null) {
      if (overlayPoint.y <= -1 && targetPoint.y >= 1) return AxisDirection.up;
      if (overlayPoint.y >= 1 && targetPoint.y <= -1) return AxisDirection.down;
      if (overlayPoint.x <= -1 && targetPoint.x >= 1) return AxisDirection.left;
      if (overlayPoint.x >= 1 && targetPoint.x <= -1) {
        return AxisDirection.right;
      }
    }
    if (overlayPoint.x == 0 && overlayPoint.y == 0) return null;
    if (overlayPoint.y.abs() >= overlayPoint.x.abs()) {
      return overlayPoint.y < 0 ? AxisDirection.up : AxisDirection.down;
    }
    return overlayPoint.x < 0 ? AxisDirection.left : AxisDirection.right;
  }

  /// Which of [anchor] and its fallbacks the portal above [context] used.
  ///
  /// The portal says only *that* it fell back. With one fallback that is
  /// enough; with a chain, the one whose own origin is nearest the origin
  /// the portal published is the one in use.
  static AnchorAuto _usedCandidate(
    BuildContext context,
    AnchorAuto anchor,
    TextDirection textDirection,
  ) {
    if (!PortalPlacement.usedFallbackOf(context)) return anchor;
    final first = anchor.fallback;
    if (first == null) return anchor;
    if (first.fallback == null) return first;
    final origin = MotionOrigin.maybeOf(context);
    if (origin == null) return first;
    var best = first;
    var bestDistance = double.infinity;
    for (AnchorAuto? c = first; c != null; c = c.fallback) {
      final own = -c.followerAnchor.resolve(textDirection);
      final distance = (own.x - origin.x).abs() + (own.y - origin.y).abs();
      if (distance < bestDistance) {
        best = c;
        bestDistance = distance;
      }
    }
    return best;
  }

  /// The placement of the arrow of an overlay built under a [Portal] that
  /// was given [anchor]. [context] is the overlay's: the portal publishes
  /// what it resolved to there.
  ///
  /// [targetSize] is the size of the portal's child. With it the arrow
  /// points at the middle of the child's edge, wherever on that edge the
  /// overlay hangs — a popover aligned with the start of a wide field still
  /// points at the field's middle, as far as its own edge reaches.
  static ArrowPlacement of(
    BuildContext context,
    AnchorBase anchor, {
    Size? targetSize,
  }) {
    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final Alignment overlayPoint;
    final Alignment? targetPoint;
    var shift = Offset.zero;
    switch (anchor) {
      case final AnchorAuto auto:
        final used = _usedCandidate(context, auto, textDirection);
        // The portal centres the overlay on its target and hangs it below,
        // then moves it by the follower anchor: mirrored, that is the point
        // of the overlay on the target.
        overlayPoint = -used.followerAnchor.resolve(textDirection);
        targetPoint = used.targetAnchor.resolve(textDirection);
        shift = PortalPlacement.shiftOf(context) + used.offset;
      case final Anchor manual:
        overlayPoint = manual.overlayAlignment.resolve(textDirection);
        targetPoint = manual.childAlignment.resolve(textDirection);
        shift = manual.offset;
      case final GlobalAnchor global:
        // Mirrored at a screen edge, the published origin says where the
        // point ended up.
        overlayPoint =
            MotionOrigin.maybeOf(context) ??
            global.followerAnchor.resolve(textDirection);
        targetPoint = null;
    }
    final direction = directionFor(overlayPoint, targetPoint);
    if (targetPoint != null && targetSize != null) {
      // From the anchored point of the target to the middle of its edge.
      shift -= Offset(
        -targetPoint.x / 2 * targetSize.width,
        -targetPoint.y / 2 * targetSize.height,
      );
    }
    return ArrowPlacement(
      direction: direction,
      anchor: overlayPoint,
      shift: shift,
    );
  }

  /// [anchor] moved away from its target by [gap] on the side its arrow is,
  /// for every anchor of a fallback chain: room for the arrow between the
  /// overlay and what it points at.
  static AnchorBase withGap(
    AnchorBase anchor,
    double gap,
    TextDirection textDirection,
  ) {
    if (gap == 0) return anchor;
    Offset away(Alignment overlayPoint, Alignment targetPoint) =>
        switch (directionFor(overlayPoint, targetPoint)) {
          AxisDirection.up => Offset(0, gap),
          AxisDirection.down => Offset(0, -gap),
          AxisDirection.left => Offset(gap, 0),
          AxisDirection.right => Offset(-gap, 0),
          null => Offset.zero,
        };
    AnchorAuto auto(AnchorAuto a) => AnchorAuto(
      offset:
          a.offset +
          away(
            -a.followerAnchor.resolve(textDirection),
            a.targetAnchor.resolve(textDirection),
          ),
      followTargetOnResize: a.followTargetOnResize,
      followerAnchor: a.followerAnchor,
      targetAnchor: a.targetAnchor,
      fallback: a.fallback == null ? null : auto(a.fallback!),
    );
    return switch (anchor) {
      final AnchorAuto a => auto(a),
      final Anchor a => a.copyWith(
        offset:
            a.offset +
            away(
              a.overlayAlignment.resolve(textDirection),
              a.childAlignment.resolve(textDirection),
            ),
      ),
      // A point has no side to stand off from.
      GlobalAnchor() => anchor,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is ArrowPlacement &&
      other.direction == direction &&
      other.anchor == anchor &&
      other.shift == shift;

  @override
  int get hashCode => Object.hash(direction, anchor, shift);
}

/// An [ArrowShape] as a border, so a `ShadowDecoration` can cast its shadow
/// around the whole outline — box and arrow — and keep it out of both.
class ArrowShapeOutline extends ShapeBorder {
  /// Creates the border of [shape]. With [single] it is one contour (see
  /// [ArrowShape.outline]), otherwise the box and the arrow's square.
  const ArrowShapeOutline(this.shape, {this.single = false});

  /// The outline.
  final ArrowShape shape;

  /// Whether the outline is [ArrowShape.outline] rather than
  /// [ArrowShape.build].
  final bool single;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      (single ? shape.outline(rect.size) : shape.build(rect.size)).shift(
        rect.topLeft,
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  bool operator ==(Object other) =>
      other is ArrowShapeOutline &&
      other.shape == shape &&
      other.single == single;

  @override
  int get hashCode => Object.hash(shape, single);
}

/// Fills an [ArrowShape] with [color] in one stroke, so a translucent tint
/// is not doubled where the box and its arrow meet.
///
/// With a [border] the outline is one contour (see [ArrowShape.outline]) and
/// the line is drawn just inside it, round the arrow and not across its
/// foot. With [shadows] they are painted first and whole: only for an
/// opaque fill, which covers what a clip would have removed (see
/// `paintOuterShadows`).
class ArrowShapePainter extends CustomPainter {
  /// Creates a painter for [shape].
  const ArrowShapePainter({
    required this.shape,
    required this.color,
    this.single = false,
    this.border = BorderSide.none,
    this.shadows = const [],
  });

  /// The outline to fill.
  final ArrowShape shape;

  /// The fill.
  final Color color;

  /// Whether to fill [ArrowShape.outline] rather than [ArrowShape.build].
  final bool single;

  /// A line along the inside of the outline. Needs [single].
  final BorderSide border;

  /// Shadows to paint under an opaque fill.
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isNotEmpty) {
      paintOuterShadows(
        canvas,
        Offset.zero & size,
        shadows: shadows,
        decoration: ShapeDecoration(
          shape: ArrowShapeOutline(shape, single: single),
        ),
        covered: true,
      );
    }
    final path = single ? shape.outline(size) : shape.build(size);
    canvas.drawPath(path, Paint()..color = color);
    if (border.style == BorderStyle.none || border.width <= 0) return;
    // Twice the width, half of it clipped away: a line on the inside of
    // the edge, where a box's border is.
    canvas
      ..save()
      ..clipPath(path)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = border.width * 2
          ..strokeJoin = StrokeJoin.round
          ..color = border.color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(ArrowShapePainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.single != single ||
      oldDelegate.border != border ||
      oldDelegate.shadows != shadows;
}

/// Clips to an [ArrowShape]: a glass surface blurs one continuous area, box
/// and arrow.
class ArrowShapeClipper extends CustomClipper<Path> {
  /// Creates a clipper for [shape].
  const ArrowShapeClipper(this.shape, {this.single = false});

  /// The outline to clip to.
  final ArrowShape shape;

  /// Whether to clip to [ArrowShape.outline] rather than
  /// [ArrowShape.build].
  final bool single;

  @override
  Path getClip(Size size) => single ? shape.outline(size) : shape.build(size);

  @override
  bool shouldReclip(ArrowShapeClipper oldClipper) =>
      oldClipper.shape != shape || oldClipper.single != single;
}

/// An empty box where the arrow's square is, so a test can measure where
/// the tip landed. It takes its place from the same [ArrowShape] the
/// painter does. Lay it over the surface with `Positioned.fill`.
class ArrowMarker extends StatelessWidget {
  /// Creates a marker for the arrow of [shape], found by [markerKey].
  const ArrowMarker({required this.shape, required this.markerKey, super.key});

  /// The outline whose arrow to mark; it must have one.
  final ArrowShape shape;

  /// The key of the box.
  final Key markerKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = shape.arrowCenter(constraints.biggest)!;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fromRect(
              rect: Rect.fromCenter(
                center: center,
                width: shape.arrowSize,
                height: shape.arrowSize,
              ),
              child: IgnorePointer(
                child: SizedBox.expand(key: markerKey),
              ),
            ),
          ],
        );
      },
    );
  }
}
