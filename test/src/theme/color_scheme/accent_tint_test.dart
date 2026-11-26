import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

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

/// [scheme]'s core tokens alone: a scheme that names no tint, whose tint
/// falls back to its primary.
ColorScheme _bare(ColorScheme scheme) => ColorScheme(
  background: scheme.background,
  foreground: scheme.foreground,
  card: scheme.card,
  cardForeground: scheme.cardForeground,
  popover: scheme.popover,
  popoverForeground: scheme.popoverForeground,
  primary: scheme.primary,
  primaryForeground: scheme.primaryForeground,
  secondary: scheme.secondary,
  secondaryForeground: scheme.secondaryForeground,
  muted: scheme.muted,
  mutedForeground: scheme.mutedForeground,
  accent: scheme.accent,
  accentForeground: scheme.accentForeground,
  destructive: scheme.destructive,
  destructiveForeground: scheme.destructiveForeground,
  border: scheme.border,
  input: scheme.input,
  ring: scheme.ring,
  selection: scheme.selection,
);

void main() {
  final bases = <String, ColorScheme>{
    for (final scheme in ColorSchemes.values) ...{
      '${scheme.name} light': scheme.light,
      '${scheme.name} dark': scheme.dark,
    },
    'bare light': _bare(const OceanColorScheme.light()),
    'bare dark': _bare(const OceanColorScheme.dark()),
  };

  test('every built-in tint reads on the page and on a card, and its '
      'foreground on it', () {
    for (final scheme in ColorSchemes.values) {
      for (final s in [scheme.light, scheme.dark]) {
        final reason = '${scheme.name} ${s == scheme.dark ? 'dark' : 'light'}';
        expect(
          legibility(s.tint, s),
          greaterThanOrEqualTo(4.5),
          reason: reason,
        );
        expect(
          contrast(s.tintForeground, s.tint),
          greaterThanOrEqualTo(4.5),
          reason: reason,
        );
      }
    }
  });

  group('ColorScheme.applyAccent tint', () {
    /// The base schemes that set `tint` themselves instead of leaving it to
    /// fall back to the primary: every built-in one.
    final namesItsOwnTint = {
      for (final name in bases.keys)
        if (!name.startsWith('bare')) name,
    };

    /// A spread of single colours: every 15° of hue at seven lightnesses,
    /// plus the greys. Some read on every base, some on none.
    final colours = <Color>[
      for (var hue = 0; hue < 360; hue += 15)
        for (final lightness in [.1, .25, .4, .5, .6, .75, .9])
          HSLColor.fromAHSL(1, hue.toDouble(), .85, lightness).toColor(),
      for (var v = 0; v < 256; v += 17) Color.fromARGB(255, v, v, v),
    ];

    test('the bases that name their own tint are the built-in ones', () {
      for (final MapEntry(key: name, value: base) in bases.entries) {
        // Re-colouring the primary alone shows which: a tint that only falls
        // back to the primary moves with it.
        const probe = Color(0xff123456);
        final moved = base.copyWith(primary: probe).tint == probe;
        expect(moved, !namesItsOwnTint.contains(name), reason: name);
      }
    });

    test('a colour that reads on the page and on a card becomes the tint, '
        'with a matching foreground and border, on every base', () {
      var applied = 0;
      for (final MapEntry(key: baseName, value: base) in bases.entries) {
        for (final colour in colours) {
          if (legibility(colour, base) < 4.5) continue;
          final result = base.applyAccent(colour);
          final reason = '$colour on $baseName';
          expect(result.tint, colour, reason: reason);
          expect(result.primary, colour, reason: reason);
          expect(
            result.tintForeground,
            result.primaryForeground,
            reason: reason,
          );
          expect(
            result.tintForeground,
            ColorScheme.contrastingForeground(colour),
            reason: reason,
          );
          expect(
            result.accentBorder,
            colour.withValues(alpha: .32),
            reason: reason,
          );
          applied++;
        }
      }
      expect(applied, greaterThan(bases.length));
    });

    test('a colour too faint for the page or the card leaves the tint, its '
        'foreground and the accent border as they resolve', () {
      var followedPrimary = 0;
      var keptOwn = 0;
      for (final MapEntry(key: baseName, value: base) in bases.entries) {
        for (final colour in colours) {
          if (legibility(colour, base) >= 4.5) continue;
          final result = base.applyAccent(colour);
          final reason = '$colour on $baseName';
          expect(result.primary, colour, reason: reason);
          if (namesItsOwnTint.contains(baseName)) {
            // A legible tint of the old hue beats an illegible new one.
            expect(result.tint, base.tint, reason: reason);
            expect(result.tintForeground, base.tintForeground, reason: reason);
            expect(result.accentBorder, base.accentBorder, reason: reason);
            keptOwn++;
          } else {
            // Nothing was set, so the fallbacks follow the new primary.
            expect(result.tint, colour, reason: reason);
            expect(
              result.tintForeground,
              result.primaryForeground,
              reason: reason,
            );
            expect(
              result.accentBorder,
              colour.withValues(alpha: .32),
              reason: reason,
            );
            // Unset rather than set to the faint colour: a later change of
            // primary still carries the tint with it.
            const next = Color(0xff654321);
            expect(result.copyWith(primary: next).tint, next, reason: reason);
            followedPrimary++;
          }
        }
      }
      expect(followedPrimary, greaterThan(0));
      expect(keptOwn, greaterThan(0));
    });

    test('the default scheme no longer keeps its own tint under a '
        'legible accent, in either brightness', () {
      for (final (base, colour) in [
        (const OceanColorScheme.light(), const Color(0xff6d28d9)),
        (const OceanColorScheme.dark(), const Color(0xffc4b5fd)),
      ]) {
        expect(legibility(colour, base), greaterThanOrEqualTo(4.5));
        final result = base.applyAccent(colour);
        expect(result.tint, colour);
        expect(result.tint, isNot(base.tint));
        expect(result.tintForeground, isNot(base.tintForeground));
        expect(result.accentBorder, colour.withValues(alpha: .32));
        expect(result.accentBorder, isNot(base.accentBorder));
        // The neutral half of the scheme is left alone.
        expect(result.background, base.background);
        expect(result.card, base.card);
        expect(result.border, base.border);
        expect(result.accent, base.accent);
        expect(result.accentForeground, base.accentForeground);
      }
    });

    test('a yellow on light Ocean is too faint: the primary changes and the '
        'blue tint stays', () {
      const base = OceanColorScheme.light();
      const yellow = Color(0xfffacc15);
      expect(legibility(yellow, base), lessThan(4.5));
      final result = base.applyAccent(yellow);
      expect(result.primary, yellow);
      expect(result.ring, yellow);
      expect(result.tint, base.tint);
      expect(result.tintForeground, base.tintForeground);
      expect(result.accentBorder, base.accentBorder);
    });

    test('the card counts as much as the page', () {
      // Reads on the white page, not on a mid-grey card — and the reverse.
      const colour = Color(0xff1d4ed8);
      const grey = Color(0xff808080);
      const white = Color(0xffffffff);
      expect(contrast(colour, white), greaterThanOrEqualTo(4.5));
      expect(contrast(colour, grey), lessThan(4.5));
      const own = Color(0xff111111);
      for (final base in [
        const IrisColorScheme.light().copyWith(
          background: white,
          card: grey,
          tint: own,
        ),
        const IrisColorScheme.light().copyWith(
          background: grey,
          card: white,
          tint: own,
        ),
      ]) {
        final result = base.applyAccent(colour);
        expect(result.primary, colour);
        expect(result.tint, own);
      }
      final both = const IrisColorScheme.light()
          .copyWith(background: white, card: white, tint: own)
          .applyAccent(colour);
      expect(both.tint, colour);
    });

    test('the threshold is 4.5', () {
      // Greys on white either side of the line: #767676 is the well-known
      // lightest grey that passes AA, #777777 the first that does not.
      final base = const OceanColorScheme.light().copyWith(
        background: const Color(0xffffffff),
      );
      const own = Color(0xff111111);
      final named = base.copyWith(tint: own);
      const passes = Color(0xff767676);
      const fails = Color(0xff777777);
      expect(legibility(passes, base), greaterThanOrEqualTo(4.5));
      expect(legibility(fails, base), lessThan(4.5));
      expect(named.applyAccent(passes).tint, passes);
      expect(named.applyAccent(fails).tint, own);
    });

    test('a supplied foreground is the tint foreground too', () {
      const colour = Color(0xff6d28d9);
      const foreground = Color(0xfffff7ed);
      final result = const OceanColorScheme.light().applyAccent(
        colour,
        accentForeground: foreground,
      );
      expect(result.tint, colour);
      expect(result.primaryForeground, foreground);
      expect(result.tintForeground, foreground);
    });

    test('tintSelection does not decide the tint', () {
      const base = OceanColorScheme.light();
      const colour = Color(0xff6d28d9);
      final result = base.applyAccent(colour, tintSelection: false);
      expect(result.selection, base.selection);
      expect(result.tint, colour);
      expect(result.accentBorder, colour.withValues(alpha: .32));
    });

    test('the tint reaches the theme', () {
      const colour = Color(0xffc4b5fd);
      final scheme = const OceanColorScheme.dark().applyAccent(colour);
      final theme = ThemeData(colorScheme: scheme);
      expect(theme.colorScheme.tint, colour);
      expect(theme.progressBarTheme.color, colour);
      expect(theme.navigationBarTheme.selectedIconColor, colour);
    });

    test('the result is still a value type', () {
      const colour = Color(0xff6d28d9);
      for (final base in bases.values) {
        expect(base.applyAccent(colour), base.applyAccent(colour));
        expect(
          base.applyAccent(colour).hashCode,
          base.applyAccent(colour).hashCode,
        );
      }
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
      const base = IrisColorScheme.light();
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
