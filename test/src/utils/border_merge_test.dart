import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `FinesseBorder.merge` takes from the other border only what it sets.
void main() {
  const radius = BorderRadius.all(Radius.circular(6));
  const side = FinesseBorderSide(color: Color(0xff0000ff), width: 2);

  test('an override that sets only the radius keeps the offset', () {
    const ring = FinesseBorder(
      top: side,
      right: side,
      bottom: side,
      left: side,
      offset: 2,
    );
    final merged = ring.merge(const FinesseBorder(borderRadius: radius));
    expect(merged.offset, 2);
    expect(merged.borderRadius, radius);
  });

  test(
    'a superellipse border keeps its offset and padding through a merge',
    () {
      const ring = FinesseRoundedSuperellipseBorder(
        side: side,
        offset: 2,
        padding: EdgeInsets.all(1),
      );
      final merged = ring.merge(
        const FinesseRoundedSuperellipseBorder(borderRadius: radius),
      );
      expect(merged, isA<FinesseRoundedSuperellipseBorder>());
      expect(merged.offset, 2);
      expect(merged.padding, const EdgeInsets.all(1));
      expect(merged.borderRadius, radius);
      expect((merged as FinesseRoundedSuperellipseBorder).side, side);

      // And it takes the other's where the other sets them.
      final moved = ring.merge(
        const FinesseRoundedSuperellipseBorder(offset: 4),
      );
      expect(moved.offset, 4);
    },
  );

  test('the offset is part of the equality of a superellipse border', () {
    expect(
      const FinesseRoundedSuperellipseBorder(offset: 1),
      isNot(const FinesseRoundedSuperellipseBorder(offset: 2)),
    );
  });
}
