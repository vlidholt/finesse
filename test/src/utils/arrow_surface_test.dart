import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/arrow_surface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The outline a tooltip and an arrowed popover share.
void main() {
  ArrowShape shapeFor(
    AxisDirection? direction, {
    double radius = 8,
    double arrowSize = 10,
    double arrowRadius = 2,
    Offset shift = Offset.zero,
    Alignment anchor = Alignment.center,
  }) => ArrowShape(
    radius: BorderRadius.circular(radius),
    direction: direction,
    arrowSize: arrowSize,
    arrowRadius: arrowRadius,
    shift: shift,
    anchor: anchor,
  );

  group('ArrowShape.outline', () {
    // The two forms of the outline have to cover the same area: a tooltip
    // fills the two-contour one, a bordered popover the single one, and the
    // popover's line has to lie on the edge its fill has.
    for (final direction in [...AxisDirection.values, null]) {
      for (final (radius, arrowSize, arrowRadius) in [
        (8.0, 10.0, 2.0),
        (16.0, 14.0, 2.0),
        (0.0, 10.0, 0.0),
        (6.0, 20.0, 5.0),
      ]) {
        test('covers what the box and the square cover together '
            '(${direction?.name ?? 'no arrow'}, r$radius, $arrowSize)', () {
          const size = Size(120, 64);
          final shape = shapeFor(
            direction,
            radius: radius,
            arrowSize: arrowSize,
            arrowRadius: arrowRadius,
            shift: const Offset(17, -9),
          );
          final two = shape.build(size);
          final one = shape.outline(size);
          expect(one.computeMetrics().length, 1);
          var compared = 0;
          final disagreements = <Offset>[];
          // Off the pixel grid, so no sample sits on an edge.
          for (var y = -20.13; y < size.height + 20; y += .71) {
            for (var x = -20.29; x < size.width + 20; x += .73) {
              final point = Offset(x, y);
              compared++;
              if (two.contains(point) != one.contains(point)) {
                disagreements.add(point);
              }
            }
          }
          expect(compared, greaterThan(10000));
          // A sample within a hundredth of a pixel of a curve may fall
          // either side: the box's corners are conics in one form and arcs
          // in the other.
          expect(disagreements.length, lessThanOrEqualTo(2));
        });
      }
    }

    test('reaches as far as the tip of the arrow', () {
      const size = Size(120, 64);
      for (final (arrowSize, arrowRadius) in [(10.0, 2.0), (14.0, 0.0)]) {
        final out = ArrowShape.protrusionOf(arrowSize, arrowRadius);
        for (final single in [true, false]) {
          final shape = shapeFor(
            AxisDirection.up,
            arrowSize: arrowSize,
            arrowRadius: arrowRadius,
          );
          final path = single ? shape.outline(size) : shape.build(size);
          // Not `getBounds`, which takes in the control point of the
          // rounded tip: the corner the rounding cut off.
          expect(path.contains(Offset(size.width / 2, -out + .1)), isTrue);
          expect(path.contains(Offset(size.width / 2, -out - .1)), isFalse);
        }
      }
    });
  });

  group('ArrowShape.arrowCenter', () {
    const size = Size(200, 80);

    test('sits on the anchor point, less the shift', () {
      expect(
        shapeFor(AxisDirection.up).arrowCenter(size),
        const Offset(100, ArrowShape.inset),
      );
      expect(
        shapeFor(
          AxisDirection.up,
          shift: const Offset(30, 99),
        ).arrowCenter(size),
        const Offset(70, ArrowShape.inset),
      );
      expect(
        shapeFor(
          AxisDirection.down,
          anchor: const Alignment(.5, 1),
          shift: const Offset(-10, 0),
        ).arrowCenter(size),
        const Offset(160, 80 - ArrowShape.inset),
      );
      expect(
        shapeFor(
          AxisDirection.left,
          shift: const Offset(99, 12),
        ).arrowCenter(size),
        const Offset(ArrowShape.inset, 28),
      );
    });

    test('keeps clear of the corners', () {
      final shape = shapeFor(
        AxisDirection.up,
        anchor: Alignment.topLeft,
        radius: 12,
      );
      final keepClear = 12 + 10 * 1.4142135623730951 / 2;
      expect(shape.arrowCenter(size)!.dx, closeTo(keepClear, .001));
    });

    test('is nowhere without a direction', () {
      expect(shapeFor(null).arrowCenter(size), isNull);
    });
  });

  group('ArrowPlacement.directionFor', () {
    test('the edge that faces the target', () {
      expect(
        ArrowPlacement.directionFor(
          Alignment.topCenter,
          Alignment.bottomCenter,
        ),
        AxisDirection.up,
      );
      expect(
        ArrowPlacement.directionFor(
          Alignment.bottomCenter,
          Alignment.topCenter,
        ),
        AxisDirection.down,
      );
      expect(
        ArrowPlacement.directionFor(
          Alignment.centerLeft,
          Alignment.centerRight,
        ),
        AxisDirection.left,
      );
      expect(
        ArrowPlacement.directionFor(
          Alignment.centerRight,
          Alignment.centerLeft,
        ),
        AxisDirection.right,
      );
    });

    test('hanging off a corner is hanging below', () {
      expect(
        ArrowPlacement.directionFor(Alignment.topLeft, Alignment.bottomLeft),
        AxisDirection.up,
      );
      expect(
        ArrowPlacement.directionFor(Alignment.topLeft, Alignment.bottomRight),
        AxisDirection.up,
      );
      // Beside it, top edges level: not below.
      expect(
        ArrowPlacement.directionFor(Alignment.topLeft, Alignment.topRight),
        AxisDirection.left,
      );
    });

    test('a point is faced by the nearer edge', () {
      expect(
        ArrowPlacement.directionFor(Alignment.topLeft, null),
        AxisDirection.up,
      );
      expect(
        ArrowPlacement.directionFor(Alignment.centerRight, null),
        AxisDirection.right,
      );
      expect(ArrowPlacement.directionFor(Alignment.center, null), isNull);
    });
  });

  group('ArrowPlacement.withGap', () {
    test('moves every anchor of a chain away from its target', () {
      const anchor = AnchorAuto(
        offset: Offset(0, 4),
        fallback: AnchorAuto(
          offset: Offset(0, -4),
          followerAnchor: Alignment.topCenter,
          targetAnchor: Alignment.topCenter,
          fallback: AnchorAuto(
            offset: Offset(4, 0),
            followerAnchor: Alignment.centerRight,
            targetAnchor: Alignment.centerRight,
          ),
        ),
      );
      final spaced =
          ArrowPlacement.withGap(anchor, 5, TextDirection.ltr) as AnchorAuto;
      expect(spaced.offset, const Offset(0, 9));
      expect(spaced.fallback!.offset, const Offset(0, -9));
      expect(spaced.fallback!.fallback!.offset, const Offset(9, 0));
      expect(spaced.fallback!.followerAnchor, Alignment.topCenter);
    });

    test('follows the text direction', () {
      const anchor = Anchor(
        childAlignment: AlignmentDirectional.centerEnd,
        overlayAlignment: AlignmentDirectional.centerStart,
      );
      expect(
        (ArrowPlacement.withGap(anchor, 5, TextDirection.ltr) as Anchor)
            .offset,
        const Offset(5, 0),
      );
      expect(
        (ArrowPlacement.withGap(anchor, 5, TextDirection.rtl) as Anchor)
            .offset,
        const Offset(-5, 0),
      );
    });

    test('leaves a point alone', () {
      const anchor = GlobalAnchor(Offset(10, 10));
      expect(
        ArrowPlacement.withGap(anchor, 5, TextDirection.ltr),
        same(anchor),
      );
    });
  });
}
