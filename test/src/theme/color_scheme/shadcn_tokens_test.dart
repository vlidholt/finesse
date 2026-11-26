import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// Pins the values generated from shadcn/ui's `registry/themes.ts`.
///
/// The generator converted each OKLCH literal to sRGB; these spot-checks catch
/// a conversion or transcription error, which would otherwise be invisible.
void main() {
  group('base colour schemes', () {
    test('zinc light matches shadcn', () {
      const s = ZincColorScheme.light();
      // oklch(1 0 0)
      expect(s.background, const Color(0xffffffff));
      // oklch(0.141 0.005 285.823) -> Tailwind v4 zinc-950, a very slightly
      // blue near-black.
      expect(s.foreground, const Color(0xff09090b));
    });

    test('the kept palettes are reachable by name', () {
      for (final name in ['blue', 'neutral', 'stone', 'zinc']) {
        expect(
          ColorScheme.fromName(name),
          isNotNull,
          reason: '$name should resolve',
        );
        expect(
          ColorScheme.fromName(name, brightness: Brightness.dark),
          isNotNull,
        );
      }
      expect(
        ColorScheme.fromName('blue'),
        const BlueColorScheme.light(),
      );
      expect(
        ColorScheme.fromName('blue', brightness: Brightness.dark),
        const BlueColorScheme.dark(),
      );
    });

    test('the palettes una dropped are no longer reachable', () {
      for (final name in [
        'teal',
        'gray',
        'green',
        'mauve',
        'mist',
        'olive',
        'orange',
        'red',
        'rose',
        'slate',
        'taupe',
        'violet',
        'yellow',
      ]) {
        expect(
          () => ColorScheme.fromName(name),
          throwsException,
          reason: name,
        );
      }
    });

    test('a base palette carries its own chart ramp', () {
      const s = ZincColorScheme.light();
      // Explicit chart tokens, not the derived fallback.
      expect(s.charts, hasLength(5));
      expect(s.chart1, isNot(s.chart5));
    });
  });

  group('AccentScheme', () {
    test('all seventeen shadcn accents are present', () {
      expect(AccentScheme.all, hasLength(17));
      for (final entry in AccentScheme.all.entries) {
        expect(entry.value.$1.name, entry.key);
        expect(entry.value.$2.name, entry.key);
      }
    });

    test('violet light matches shadcn', () {
      // themes.ts: oklch(0.491 0.27 292.581), i.e. Tailwind v4 violet-700.
      // Note these are the v4 OKLCH-native values, which differ slightly from
      // the v3 sRGB hexes.
      expect(AccentScheme.violetLight.primary, const Color(0xff7008e7));
    });

    test('the OKLCH conversion is accurate', () {
      // shadcn's destructive is oklch(0.577 0.245 27.325) — Tailwind v4's
      // red-600, published as #e7000b. If the conversion drifts, this catches
      // it against a value that can be checked against Tailwind directly.
      expect(
        const ZincColorScheme.light().destructive,
        const Color(0xffe7000b),
      );
    });

    test('fromName resolves per brightness and rejects unknown names', () {
      expect(
        AccentScheme.fromName('violet'),
        AccentScheme.violetLight,
      );
      expect(
        AccentScheme.fromName('violet', brightness: Brightness.dark),
        AccentScheme.violetDark,
      );
      expect(
        () => AccentScheme.fromName('chartreuse'),
        throwsArgumentError,
      );
    });
  });

  group('applyAccentScheme', () {
    const base = ZincColorScheme.light();

    test('takes the accent hue and keeps the neutral palette', () {
      final themed = base.applyAccentScheme(AccentScheme.violetLight);

      expect(themed.primary, AccentScheme.violetLight.primary);
      expect(themed.ring, AccentScheme.violetLight.primary);
      // Neutrals untouched — the whole point of the base/accent split.
      expect(themed.background, base.background);
      expect(themed.border, base.border);
      expect(themed.muted, base.muted);
      expect(themed.destructive, base.destructive);
    });

    test('adopts the accent chart ramp', () {
      final themed = base.applyAccentScheme(AccentScheme.violetLight);
      expect(themed.chart1, AccentScheme.violetLight.chart1);
      expect(themed.chart5, AccentScheme.violetLight.chart5);
    });

    test('every accent applies to every base without error', () {
      for (final name in AccentScheme.all.keys) {
        for (final brightness in Brightness.values) {
          for (final baseName in ['blue', 'neutral', 'stone', 'zinc']) {
            final scheme =
                ColorScheme.fromName(
                  baseName,
                  brightness: brightness,
                ).applyAccentScheme(
                  AccentScheme.fromName(name, brightness: brightness),
                );
            expect(scheme.primary, isNotNull);
          }
        }
      }
    });
  });

  group('chart and sidebar fallbacks', () {
    // A hand-written scheme that sets only the required tokens: every shipped
    // palette now states its chart and sidebar tokens explicitly.
    const bare = ColorScheme(
      background: Color(0xffffffff),
      foreground: Color(0xff020817),
      card: Color(0xfffefefe),
      cardForeground: Color(0xff020818),
      popover: Color(0xffffffff),
      popoverForeground: Color(0xff020817),
      primary: Color(0xff0f172a),
      primaryForeground: Color(0xfff8fafc),
      secondary: Color(0xfff1f5f9),
      secondaryForeground: Color(0xff0f172a),
      muted: Color(0xfff1f5f9),
      mutedForeground: Color(0xff64748b),
      accent: Color(0xfff1f5f9),
      accentForeground: Color(0xff0f172a),
      destructive: Color(0xffef4444),
      destructiveForeground: Color(0xfff8fafc),
      border: Color(0xffe2e8f0),
      input: Color(0xffe2e8f1),
      ring: Color(0xff020817),
      selection: Color(0xffb4d7ff),
    );

    test('a scheme without explicit tokens derives a usable ramp', () {
      expect(bare.chart1, bare.primary);
      expect(bare.chart5, bare.mutedForeground);
      expect(bare.charts, hasLength(5));
    });

    test('sidebar tokens fall back to their closest neighbour', () {
      expect(bare.sidebar, bare.card);
      expect(bare.sidebarForeground, bare.cardForeground);
      expect(bare.sidebarPrimary, bare.primary);
      expect(bare.sidebarBorder, bare.border);
      expect(bare.sidebarRing, bare.ring);
    });

    test('explicit tokens win over the fallback', () {
      final s = bare.copyWith(
        chart1: const Color(0xff123456),
        sidebar: const Color(0xff654321),
      );
      expect(s.chart1, const Color(0xff123456));
      expect(s.sidebar, const Color(0xff654321));
    });

    test('the new tokens take part in equality', () {
      final b = bare.copyWith(chart1: const Color(0xff123456));
      expect(bare, isNot(b));
      expect(bare.hashCode, isNot(b.hashCode));
    });

    test('lerp interpolates the new tokens', () {
      final a = bare.copyWith(chart1: const Color(0xff000000));
      final b = bare.copyWith(chart1: const Color(0xffffffff));
      final mid = ColorScheme.lerp(a, b, .5);
      expect(mid.chart1.r, closeTo(.5, .05));
    });
  });
}
