import 'dart:math' as math;

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The WCAG contrast ratio between two colours, ignoring their alpha.
double contrast(Color a, Color b) {
  final la = a.withValues(alpha: 1).computeLuminance();
  final lb = b.withValues(alpha: 1).computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

/// How well [color] reads where a tint is drawn: the lower of its contrast
/// against the page and against a card.
double legibility(Color color, ColorScheme scheme) => math.min(
  contrast(color, scheme.background),
  contrast(color, scheme.card),
);

const _dark = Color(0xff09090b);
const _light = Color(0xfffafafa);

void main() {
  const bases = <String, ColorScheme>{
    'teal light': TealColorScheme.light(),
    'teal dark': TealColorScheme.dark(),
    'neutral light': NeutralColorScheme.light(),
    'neutral dark': NeutralColorScheme.dark(),
    'zinc light': ZincColorScheme.light(),
    'zinc dark': ZincColorScheme.dark(),
    'stone light': StoneColorScheme.light(),
    'stone dark': StoneColorScheme.dark(),
  };

  /// Every accent, light and dark, by a name that says which.
  final accents = <String, AccentScheme>{
    for (final entry in AccentScheme.all.entries) ...{
      '${entry.key} (light)': entry.value.$1,
      '${entry.key} (dark)': entry.value.$2,
    },
  };

  List<Color> stepsOf(AccentScheme accent) => [
    accent.primary,
    ?accent.chart1,
    ?accent.chart2,
    ?accent.chart3,
    ?accent.chart4,
    ?accent.chart5,
  ];

  group('ColorScheme.applyAccentScheme tint', () {
    test('there are accents and bases to walk', () {
      expect(AccentScheme.all.length, greaterThanOrEqualTo(17));
      expect(accents, hasLength(AccentScheme.all.length * 2));
      expect(bases, hasLength(8));
    });

    test('the tint reads against the background: contrast of at least 3 for '
        'every accent on every base scheme, in both brightnesses', () {
      // The whole matrix, mismatched pairs included (a light accent on a
      // dark base): nothing stops a caller composing them.
      final short = <String>[];
      for (final MapEntry(key: accentName, value: accent) in accents.entries) {
        for (final MapEntry(key: baseName, value: base) in bases.entries) {
          final result = base.applyAccentScheme(accent);
          final ratio = contrast(result.tint, result.background);
          if (ratio < 3) {
            // An accent none of whose steps reaches 3 must at least have
            // taken its most legible one.
            final best = stepsOf(
              accent,
            ).map((c) => legibility(c, base)).reduce(math.max);
            expect(
              legibility(result.tint, base),
              closeTo(best, 1e-9),
              reason: '$accentName on $baseName is not its most legible step',
            );
            short.add('$accentName on $baseName: ${ratio.toStringAsFixed(2)}');
          }
        }
      }
      // Today every accent reaches 3 on every base. If a new one cannot,
      // this lists it rather than hiding it behind the fallback above.
      expect(short, isEmpty);
    });

    test('the tint reads on a card as well as on the page: 4.5 on both '
        'wherever any step of the accent can reach it', () {
      var reached = 0;
      final fellBack = <String>[];
      for (final MapEntry(key: accentName, value: accent) in accents.entries) {
        for (final MapEntry(key: baseName, value: base) in bases.entries) {
          final result = base.applyAccentScheme(accent);
          final reason = '$accentName on $baseName';
          final steps = stepsOf(accent);
          final best = steps.map((c) => legibility(c, base)).reduce(math.max);
          if (best >= 4.5) {
            expect(
              legibility(result.tint, base),
              greaterThanOrEqualTo(4.5),
              reason: reason,
            );
            reached++;
          } else {
            // No step is legible enough: the most legible one it is.
            expect(
              legibility(result.tint, base),
              closeTo(best, 1e-9),
              reason: reason,
            );
            fellBack.add('$reason: ${best.toStringAsFixed(2)}');
          }
          expect(steps, contains(result.tint), reason: reason);
        }
      }
      expect(reached, greaterThan(0));
      // Every shipped accent has a step that reaches 4.5 on every base.
      expect(fellBack, isEmpty);
    });

    test('the tint foreground reads on the tint: contrast of at least 3', () {
      for (final MapEntry(key: accentName, value: accent) in accents.entries) {
        for (final MapEntry(key: baseName, value: base) in bases.entries) {
          final result = base.applyAccentScheme(accent);
          expect(
            contrast(result.tintForeground, result.tint),
            greaterThanOrEqualTo(3),
            reason: '$accentName on $baseName',
          );
        }
      }
    });

    test("the accent's primary is the tint wherever it is legible, and then "
        'brings its own foreground', () {
      var kept = 0;
      for (final MapEntry(key: accentName, value: accent) in accents.entries) {
        for (final MapEntry(key: baseName, value: base) in bases.entries) {
          if (legibility(accent.primary, base) < 4.5) continue;
          final result = base.applyAccentScheme(accent);
          final reason = '$accentName on $baseName';
          expect(result.tint, accent.primary, reason: reason);
          expect(
            result.tintForeground,
            accent.primaryForeground,
            reason: reason,
          );
          kept++;
        }
      }
      expect(kept, greaterThan(0));
    });

    test('a primary too dim for the page or the card gives way to the '
        'legible step nearest its own lightness, with a derived '
        'foreground', () {
      var replaced = 0;
      for (final MapEntry(key: accentName, value: accent) in accents.entries) {
        for (final MapEntry(key: baseName, value: base) in bases.entries) {
          if (legibility(accent.primary, base) >= 4.5) continue;
          final result = base.applyAccentScheme(accent);
          final reason = '$accentName on $baseName';
          final legible = [
            for (final step in stepsOf(accent))
              if (legibility(step, base) >= 4.5) step,
          ];
          if (legible.isEmpty) continue;

          expect(result.tint, isNot(accent.primary), reason: reason);
          expect(legible, contains(result.tint), reason: reason);
          // Of the steps that read, the one that changes the accent least:
          // none is nearer the primary's own lightness.
          double distance(Color c) =>
              (c.computeLuminance() - accent.primary.computeLuminance()).abs();
          for (final step in legible) {
            expect(
              distance(result.tint),
              lessThanOrEqualTo(distance(step) + 1e-12),
              reason: reason,
            );
          }
          expect(
            result.tintForeground,
            ColorScheme.contrastingForeground(result.tint),
            reason: reason,
          );
          // The button fill itself is not touched: only the tint moves.
          expect(result.primary, accent.primary, reason: reason);
          expect(
            result.primaryForeground,
            accent.primaryForeground,
            reason: reason,
          );
          replaced++;
        }
      }
      // The dark accents are the reason this exists.
      expect(replaced, greaterThan(0));
    });

    test('with no step legible enough, the most legible one is taken', () {
      // A ramp of near-background greys: nothing reaches 4.5 on white.
      const pale = AccentScheme(
        name: 'pale',
        primary: Color(0xfff0f0f0),
        primaryForeground: Color(0xff101010),
        chart1: Color(0xffe0e0e0),
        chart2: Color(0xffc0c0c0),
        chart3: Color(0xfff8f8f8),
      );
      const base = ZincColorScheme.light();
      for (final step in [pale.primary, pale.chart1!, pale.chart2!]) {
        expect(legibility(step, base), lessThan(4.5));
      }
      final result = base.applyAccentScheme(pale);
      expect(result.tint, pale.chart2);
      expect(
        result.tintForeground,
        ColorScheme.contrastingForeground(pale.chart2!),
      );
      expect(result.primary, pale.primary);
    });

    test('an accent with no chart ramp keeps its primary as the tint', () {
      const bare = AccentScheme(
        name: 'bare',
        primary: Color(0xfff0f0f0),
        primaryForeground: Color(0xff101010),
      );
      final result = const ZincColorScheme.light().applyAccentScheme(bare);
      expect(result.tint, bare.primary);
      expect(result.tintForeground, bare.primaryForeground);
    });

    test('the dark blue accent on dark zinc is one that gives way', () {
      const base = ZincColorScheme.dark();
      final result = base.applyAccentScheme(AccentScheme.blueDark);
      expect(legibility(AccentScheme.blueDark.primary, base), lessThan(4.5));
      expect(result.tint, isNot(AccentScheme.blueDark.primary));
      expect(legibility(result.tint, base), greaterThanOrEqualTo(4.5));
    });

    test('the accent border is the tint at 32%', () {
      for (final MapEntry(key: accentName, value: accent) in accents.entries) {
        for (final MapEntry(key: baseName, value: base) in bases.entries) {
          final result = base.applyAccentScheme(accent);
          expect(
            result.accentBorder,
            result.tint.withValues(alpha: .32),
            reason: '$accentName on $baseName',
          );
        }
      }
    });

    test(
      "a scheme that names its own tint has it replaced by the accent's",
      () {
        for (final (base, accent) in [
          (const TealColorScheme.light(), AccentScheme.violetLight),
          (const TealColorScheme.dark(), AccentScheme.violetDark),
          (const TealColorScheme.light(), AccentScheme.orangeLight),
          (const TealColorScheme.dark(), AccentScheme.orangeDark),
        ]) {
          // Teal sets `tint` itself rather than leaving it to fall back to
          // the primary, so changing the primary alone would leave a teal
          // tint behind. None of it survives the accent.
          final result = base.applyAccentScheme(accent);
          expect(result.tint, isNot(base.tint), reason: accent.name);
          expect(stepsOf(accent), contains(result.tint), reason: accent.name);
          expect(
            result.tintForeground,
            isNot(base.tintForeground),
            reason: accent.name,
          );
          expect(
            result.accentBorder,
            isNot(base.accentBorder),
            reason: accent.name,
          );
          expect(result.accentBorder.a, closeTo(.32, 1e-6));
          // The neutral half of teal is left alone.
          expect(result.background, base.background);
          expect(result.card, base.card);
          expect(result.border, base.border);
        }
      },
    );

    test("the dark teal scheme's tint is not its primary, and is replaced "
        'all the same', () {
      const base = TealColorScheme.dark();
      expect(base.tint, isNot(base.primary));
      final result = base.applyAccentScheme(AccentScheme.violetDark);
      expect(result.tint, isNot(base.tint));
      expect(result.primary, AccentScheme.violetDark.primary);
    });

    test('the tint reaches the theme', () {
      final scheme = const TealColorScheme.dark().applyAccentScheme(
        AccentScheme.roseDark,
      );
      final theme = ThemeData(colorScheme: scheme);
      expect(theme.colorScheme.tint, scheme.tint);
      // finesse fills its progress bar with the tint.
      expect(theme.progressBarTheme.color, scheme.tint);
      expect(theme.navigationBarTheme.selectedIconColor, scheme.tint);
    });

    test('the result is still a value type', () {
      const base = StoneColorScheme.dark();
      expect(
        base.applyAccentScheme(AccentScheme.greenDark),
        base.applyAccentScheme(AccentScheme.greenDark),
      );
      expect(
        base.applyAccentScheme(AccentScheme.greenDark).hashCode,
        base.applyAccentScheme(AccentScheme.greenDark).hashCode,
      );
    });
  });

  group('ColorScheme.contrastingForeground', () {
    test('only ever answers near-black or near-white', () {
      for (var v = 0; v < 256; v++) {
        expect(
          ColorScheme.contrastingForeground(Color.fromARGB(255, v, v, v)),
          anyOf(_dark, _light),
        );
      }
    });

    test('picks the higher-contrast of the two across every grey', () {
      for (var v = 0; v < 256; v++) {
        final grey = Color.fromARGB(255, v, v, v);
        final picked = ColorScheme.contrastingForeground(grey);
        final other = picked == _dark ? _light : _dark;
        expect(
          contrast(picked, grey),
          greaterThanOrEqualTo(contrast(other, grey)),
          reason: 'grey $v',
        );
      }
    });

    test('switches to dark text once, where the two contrasts cross', () {
      Color pickFor(int v) =>
          ColorScheme.contrastingForeground(Color.fromARGB(255, v, v, v));
      final firstDark = Iterable<int>.generate(
        256,
      ).firstWhere((v) => pickFor(v) == _dark);
      for (var v = 0; v < 256; v++) {
        expect(pickFor(v), v < firstDark ? _light : _dark, reason: 'grey $v');
      }
      // Luminance 0.18, not the 0.45 it used to be: a mid grey that the old
      // threshold gave white text gets the dark text that reads better.
      final below = Color.fromARGB(
        255,
        firstDark - 1,
        firstDark - 1,
        firstDark - 1,
      );
      final at = Color.fromARGB(255, firstDark, firstDark, firstDark);
      expect(below.computeLuminance(), lessThanOrEqualTo(.18));
      expect(at.computeLuminance(), greaterThan(.18));
      const mid = Color(0xff999999);
      expect(mid.computeLuminance(), inInclusiveRange(.18, .45));
      expect(ColorScheme.contrastingForeground(mid), _dark);
      expect(contrast(_dark, mid), greaterThan(contrast(_light, mid)));
    });

    test('picks the higher-contrast of the two across hues as well', () {
      for (var hue = 0; hue < 360; hue += 15) {
        for (final lightness in [.1, .25, .4, .5, .6, .75, .9]) {
          final colour = HSLColor.fromAHSL(
            1,
            hue.toDouble(),
            .9,
            lightness,
          ).toColor();
          final picked = ColorScheme.contrastingForeground(colour);
          final other = picked == _dark ? _light : _dark;
          // Within a hair of the crossing either answer is right.
          expect(
            contrast(picked, colour),
            greaterThanOrEqualTo(contrast(other, colour) * .99),
            reason: 'hue $hue, lightness $lightness',
          );
        }
      }
    });

    test('ignores how the colour is carried: the answer is opaque', () {
      expect(ColorScheme.contrastingForeground(const Color(0xffffffff)).a, 1);
      expect(ColorScheme.contrastingForeground(const Color(0xff000000)).a, 1);
    });

    test('applyAccent derives its foreground from it', () {
      const base = ZincColorScheme.light();
      for (final accent in const [
        Color(0xff1e1b4b),
        Color(0xff3b82f6),
        Color(0xff999999),
        Color(0xfffacc15),
      ]) {
        expect(
          base.applyAccent(accent).primaryForeground,
          ColorScheme.contrastingForeground(accent),
        );
      }
    });
  });
}
