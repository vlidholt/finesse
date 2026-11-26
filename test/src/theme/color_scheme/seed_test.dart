import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

double _contrast(Color a, Color b) {
  final la = a.withValues(alpha: 1).computeLuminance();
  final lb = b.withValues(alpha: 1).computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

/// `ColorScheme.fromSeed` makes a scheme the way the built-in ones are
/// made, so any seed gets the contrast they have.
void main() {
  final seeds = <Color>[
    for (var hue = 0; hue < 360; hue += 15)
      for (final (saturation, lightness) in [(.9, .5), (.6, .35), (.8, .75)])
        HSLColor.fromAHSL(1, hue.toDouble(), saturation, lightness).toColor(),
    const Color(0xff000000),
    const Color(0xff808080),
    const Color(0xffffffff),
    const Color(0xff64748b),
  ];

  test('every seed gives readable text, primaries and tints in both '
      'brightnesses', () {
    for (final seed in seeds) {
      for (final brightness in Brightness.values) {
        final s = ColorScheme.fromSeed(seed, brightness: brightness);
        final why = '$seed $brightness';
        expect(
          _contrast(s.foreground, s.background),
          greaterThan(12),
          reason: why,
        );
        expect(
          _contrast(s.mutedForeground, s.background),
          greaterThanOrEqualTo(4.5),
          reason: why,
        );
        expect(
          _contrast(s.mutedForeground, s.card),
          greaterThanOrEqualTo(4.5),
          reason: why,
        );
        expect(
          _contrast(s.primaryForeground, s.primary),
          greaterThanOrEqualTo(4.5),
          reason: why,
        );
        expect(
          _contrast(s.tint, s.background),
          greaterThanOrEqualTo(4.5),
          reason: why,
        );
        expect(
          _contrast(s.tint, s.card),
          greaterThanOrEqualTo(4.5),
          reason: why,
        );
        expect(
          _contrast(s.tintForeground, s.tint),
          greaterThanOrEqualTo(4.5),
          reason: why,
        );
      }
    }
  });

  test("Ocean's own primary seeds a scheme close to Ocean", () {
    const ocean = OceanColorScheme.light();
    final seeded = ColorScheme.fromSeed(ocean.primary);
    for (final (a, b) in [
      (seeded.primary, ocean.primary),
      (seeded.background, ocean.background),
      (seeded.tint, ocean.tint),
    ]) {
      expect((a.r - b.r).abs(), lessThan(.05));
      expect((a.g - b.g).abs(), lessThan(.05));
      expect((a.b - b.b).abs(), lessThan(.05));
    }
  });

  test('a grey seed is monochrome: the primary is the ink', () {
    for (final brightness in Brightness.values) {
      final s = ColorScheme.fromSeed(
        const Color(0xff808080),
        brightness: brightness,
      );
      expect(s.primary, s.foreground);
      expect(s.tint, s.foreground);
    }
  });

  test("the seed's hue carries to the primary, light and dark", () {
    const seed = Color(0xff16a34a);
    final light = ColorScheme.fromSeed(seed);
    final dark = ColorScheme.fromSeed(seed, brightness: Brightness.dark);
    expect(light.primary.g, greaterThan(light.primary.r));
    expect(dark.tint.g, greaterThan(dark.tint.r));
    // A value: the same seed is the same scheme.
    expect(ColorScheme.fromSeed(seed), light);
  });
}
