import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// `UnaBorder.merge` takes from the other border only what it sets.
void main() {
  const radius = BorderRadius.all(Radius.circular(6));
  const side = UnaBorderSide(color: Color(0xff0000ff), width: 2);

  test('an override that sets only the radius keeps the offset', () {
    const ring = UnaBorder(
      top: side,
      right: side,
      bottom: side,
      left: side,
      offset: 2,
    );
    final merged = ring.merge(const UnaBorder(borderRadius: radius));
    expect(merged.offset, 2);
    expect(merged.borderRadius, radius);
  });

  test(
    'a superellipse border keeps its offset and padding through a merge',
    () {
      const ring = UnaRoundedSuperellipseBorder(
        side: side,
        offset: 2,
        padding: EdgeInsets.all(1),
      );
      final merged = ring.merge(
        const UnaRoundedSuperellipseBorder(borderRadius: radius),
      );
      expect(merged, isA<UnaRoundedSuperellipseBorder>());
      expect(merged.offset, 2);
      expect(merged.padding, const EdgeInsets.all(1));
      expect(merged.borderRadius, radius);
      expect((merged as UnaRoundedSuperellipseBorder).side, side);

      // And it takes the other's where the other sets them.
      final moved = ring.merge(
        const UnaRoundedSuperellipseBorder(offset: 4),
      );
      expect(moved.offset, 4);
    },
  );

  test('a plain override keeps the superellipse shape', () {
    const ring = UnaRoundedSuperellipseBorder(side: side, offset: 2);
    final merged = ring.merge(const UnaBorder(borderRadius: radius));
    expect(merged, isA<UnaRoundedSuperellipseBorder>());
    expect((merged as UnaRoundedSuperellipseBorder).side, side);
    expect(merged.borderRadius, radius);
    expect(merged.offset, 2);

    const wider = UnaBorderSide(width: 3);
    final recoloured = ring.merge(
      const UnaBorder(top: wider, right: wider, bottom: wider, left: wider),
    );
    expect(
      (recoloured as UnaRoundedSuperellipseBorder).side,
      side.merge(wider),
    );
  });

  test('the offset is part of the equality of a superellipse border', () {
    expect(
      const UnaRoundedSuperellipseBorder(offset: 1),
      isNot(const UnaRoundedSuperellipseBorder(offset: 2)),
    );
  });
}
