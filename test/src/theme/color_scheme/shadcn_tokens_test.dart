import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// The built-in schemes (scripts/generate_color_schemes.dart) and the
/// optional tokens' fallbacks.
void main() {
  group('built-in colour schemes', () {
    test('every one is reachable by name, light and dark', () {
      for (final scheme in ColorSchemes.values) {
        expect(ColorScheme.fromName(scheme.name), scheme.light);
        expect(
          ColorScheme.fromName(scheme.name, brightness: Brightness.dark),
          scheme.dark,
        );
        expect(scheme.of(Brightness.dark), scheme.dark);
      }
      expect(ColorSchemes.values.map((s) => s.name), [
        'slate',
        'ocean',
        'graphite',
        'forest',
        'iris',
        'ember',
        'rose',
      ]);
    });

    test("shadcn's palettes are gone", () {
      for (final name in ['blue', 'neutral', 'stone', 'zinc', 'teal']) {
        expect(() => ColorScheme.fromName(name), throwsArgumentError);
      }
    });

    test('each charts in the green palette, per brightness', () {
      for (final scheme in ColorSchemes.values) {
        expect(scheme.light.charts, ChartPalette.green.light);
        expect(scheme.dark.charts, ChartPalette.green.dark);
      }
      // A seeded scheme too: the charts do not follow the accent.
      expect(
        ColorScheme.fromSeed(const Color(0xFFE60076)).charts,
        ChartPalette.green.light,
      );
      expect(
        ColorScheme.fromSeed(
          const Color(0xFF808080),
          brightness: Brightness.dark,
        ).charts,
        ChartPalette.green.dark,
      );
    });

    test('every scheme is equally strong: the primaries share a lightness '
        'and carry white text', () {
      for (final scheme in ColorSchemes.values) {
        if (scheme == ColorSchemes.graphite) continue;
        final s = scheme.light;
        final luminance = s.primary.computeLuminance();
        expect(luminance, inInclusiveRange(.1, .25), reason: scheme.name);
        expect(s.primaryForeground, const Color(0xffffffff));
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
