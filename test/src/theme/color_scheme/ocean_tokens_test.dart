import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// Pins the una palette and the tokens it added to [ColorScheme].
///
/// The blue scheme sets every optional token; every other
/// scheme — and any scheme an app wrote by hand — leaves them unset and gets
/// the fallbacks, which is why both halves are locked here.
void main() {
  // A scheme that states only the required tokens.
  const bare = ColorScheme(
    background: Color(0xffffffff),
    foreground: Color(0xff101010),
    card: Color(0xfffefefe),
    cardForeground: Color(0xff111111),
    popover: Color(0xfffdfdfd),
    popoverForeground: Color(0xff121212),
    primary: Color(0xff2040c0),
    primaryForeground: Color(0xfff0f0ff),
    secondary: Color(0xffeeeeee),
    secondaryForeground: Color(0xff131313),
    muted: Color(0xffededed),
    mutedForeground: Color(0xff707070),
    accent: Color(0xffe0e8ff),
    accentForeground: Color(0xff141414),
    destructive: Color(0xffd02020),
    destructiveForeground: Color(0xffffffff),
    border: Color(0xffe1e1e1),
    input: Color(0xffd5d5d5),
    ring: Color(0xff2040c1),
    selection: Color(0x402040c0),
  );

  group('OceanColorScheme', () {
    test('Slate is the default scheme of a theme, per brightness', () {
      expect(ThemeData().colorScheme, const SlateColorScheme.light());
      expect(ThemeData().brightness, Brightness.light);
      expect(
        ThemeData(brightness: Brightness.dark).colorScheme,
        const SlateColorScheme.dark(),
      );
      // Made the way `ColorScheme.fromSeed` makes one from Tailwind's
      // slate-500: the same primary, to the rounding of a channel.
      final seeded = ColorScheme.fromSeed(const Color(0xFF64748B)).primary;
      const slate = SlateColorScheme.light();
      expect((seeded.r - slate.primary.r).abs(), lessThan(1.5 / 255));
      expect((seeded.g - slate.primary.g).abs(), lessThan(1.5 / 255));
      expect((seeded.b - slate.primary.b).abs(), lessThan(1.5 / 255));
      // And a theme given only the dark scheme reads its brightness off it.
      expect(
        ThemeData(colorScheme: const OceanColorScheme.dark()).brightness,
        Brightness.dark,
      );
    });

    test('light: a standard blue on a cool grey page', () {
      const s = OceanColorScheme.light();
      expect(s.background, const Color(0xfff4f5f7));
      expect(s.foreground, const Color(0xff161a22));
      expect(s.card, const Color(0xffffffff));
      expect(s.cardForeground, const Color(0xff161a22));
      expect(s.popover, const Color(0xffffffff));
      expect(s.primary, const Color(0xff2563eb));
      expect(s.primaryForeground, const Color(0xffffffff));
      expect(s.mutedForeground, const Color(0xff5f6775));
      expect(s.accent, const Color(0xffeaf1fe));
      expect(s.accentForeground, const Color(0xff1d4ed8));
      expect(s.destructive, const Color(0xffdc2626));
      expect(s.ring, const Color(0xff2563eb));
    });

    test('light: fills and hairlines are washes of the foreground', () {
      const s = OceanColorScheme.light();
      // 8%, 4.3% and 9% of #193c4a — translucent, so they sit correctly on
      // glass rather than painting an opaque grey over it.
      expect(s.secondary, const Color(0x14161a22));
      expect(s.muted, const Color(0x0b161a22));
      expect(s.border, const Color(0x17161a22));
      expect(s.input, const Color(0x17161a22));
      expect(s.borderStrong, const Color(0x2e161a22));
      for (final wash in [s.secondary, s.muted, s.border, s.input]) {
        expect(wash.a, lessThan(.2));
        expect(wash.withValues(alpha: 1), s.foreground);
      }
    });

    test('light: the optional tokens are all stated', () {
      const s = OceanColorScheme.light();
      expect(s.foregroundSubtle, const Color(0xff3a414e));
      expect(s.tint, const Color(0xff1d4ed8));
      expect(s.tintForeground, const Color(0xffffffff));
      expect(s.success, const Color(0xff13753a));
      expect(s.successMuted, const Color(0xffe7f3ec));
      expect(s.warning, const Color(0xffb45309));
      expect(s.accentBorder, const Color(0x522563eb));
      expect(s.bar, const Color(0xffffffff));
      expect(s.chart1, const Color(0xff45a056));
      expect(s.chart5, const Color(0xff357d46));
      expect(s.sidebar, const Color(0xffffffff));
      expect(s.sidebarPrimary, const Color(0xff2563eb));
    });

    test('dark: the same blue on a deep blue-grey page', () {
      const s = OceanColorScheme.dark();
      expect(s.background, const Color(0xff141a26));
      expect(s.foreground, const Color(0xffeef1f5));
      // The card and popover are a step lighter than the page.
      expect(s.card, const Color(0xff1c222e));
      expect(s.popover, const Color(0xff1c222e));
      expect(
        s.card.computeLuminance(),
        greaterThan(s.background.computeLuminance()),
      );
      // The button fill is the same blue in both modes…
      expect(s.primary, const OceanColorScheme.light().primary);
      expect(s.primaryForeground, const Color(0xffffffff));
      expect(s.mutedForeground, const Color(0xff97a1af));
      expect(s.accent, const Color(0x522563eb));
      expect(s.accentForeground, const Color(0xff93c5fd));
      expect(s.destructive, const Color(0xffdc2626));
      expect(s.ring, const Color(0xff6eb0fb));
      // …and the hairlines are translucent near-whites.
      expect(s.border, const Color(0x14e8edf5));
      expect(s.input, const Color(0x14e8edf5));
      expect(s.secondary, const Color(0x1ae8edf5));
      expect(s.muted, const Color(0x0fe8edf5));
    });

    test('dark: the optional tokens are all stated', () {
      const s = OceanColorScheme.dark();
      expect(s.foregroundSubtle, const Color(0xffc6ccd6));
      expect(s.tint, const Color(0xff6eb0fb));
      expect(s.tintForeground, const Color(0xff141a26));
      expect(s.success, const Color(0xff86d3a8));
      expect(s.successMuted, const Color(0x243e8e67));
      expect(s.warning, const Color(0xfffbbf24));
      expect(s.borderStrong, const Color(0x29e8edf5));
      expect(s.accentBorder, const Color(0x666eb0fb));
      expect(s.bar, const Color(0xff171d29));
      expect(s.sidebarPrimary, const Color(0xff6eb0fb));
      expect(s.sidebarPrimaryForeground, const Color(0xff141a26));
    });

    test('dark: the tint is lighter than the primary so it reads on the '
        'page', () {
      const light = OceanColorScheme.light();
      const dark = OceanColorScheme.dark();
      // In the light, the tint is a step deeper than the button fill, so
      // text and selection washes in it read on white.
      expect(light.tint, isNot(light.primary));
      expect(
        _contrast(light.tint, light.background),
        greaterThan(_contrast(light.primary, light.background)),
      );
      // In the dark that blue sinks into the page, so the tint is lifted.
      expect(dark.tint, isNot(dark.primary));
      expect(
        _contrast(dark.tint, dark.background),
        greaterThan(_contrast(dark.primary, dark.background)),
      );
    });

    test('text reads on every surface it is paired with', () {
      for (final s in const [
        OceanColorScheme.light(),
        OceanColorScheme.dark(),
      ]) {
        final dark = s.background.computeLuminance() < .5;
        final label = dark ? 'dark' : 'light';
        Color over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

        // WCAG AA for body text is 4.5:1.
        expect(
          _contrast(s.foreground, s.background),
          greaterThan(7),
          reason: '$label foreground on background',
        );
        expect(
          _contrast(s.cardForeground, s.card),
          greaterThan(7),
          reason: '$label card',
        );
        expect(
          _contrast(s.foregroundSubtle, s.card),
          greaterThan(4.5),
          reason: '$label foregroundSubtle on card',
        );
        expect(
          _contrast(s.mutedForeground, s.background),
          greaterThan(4.5),
          reason: '$label mutedForeground on background',
        );
        expect(
          _contrast(s.mutedForeground, s.card),
          greaterThan(4.5),
          reason: '$label mutedForeground on card',
        );
        expect(
          _contrast(s.primaryForeground, s.primary),
          greaterThan(4.5),
          reason: '$label primary',
        );
        expect(
          _contrast(s.tintForeground, s.tint),
          greaterThan(4.5),
          reason: '$label tint',
        );
        expect(
          _contrast(s.tint, s.background),
          greaterThan(4.5),
          reason: '$label tint on the page',
        );
        // The accent is translucent in the dark, so it is judged where it
        // lands: on a card.
        expect(
          _contrast(s.accentForeground, over(s.accent, s.card)),
          greaterThan(4.5),
          reason: '$label accent',
        );
        expect(
          _contrast(s.success, over(s.successMuted, s.card)),
          greaterThan(4.5),
          reason: '$label success on its muted fill',
        );
        expect(
          _contrast(s.warning, s.card),
          greaterThan(4.5),
          reason: '$label warning on card',
        );
        expect(
          _contrast(s.destructiveForeground, s.destructive),
          greaterThan(4.5),
          reason: '$label destructive',
        );
      }
    });

    test('light and dark are different schemes, each equal to itself', () {
      expect(const OceanColorScheme.light(), const OceanColorScheme.light());
      expect(
        const OceanColorScheme.light().hashCode,
        const OceanColorScheme.light().hashCode,
      );
      expect(
        const OceanColorScheme.light(),
        isNot(const OceanColorScheme.dark()),
      );
    });

    test('a named constructor argument overrides one token', () {
      const s = OceanColorScheme.light(tint: Color(0xff112233));
      expect(s.tint, const Color(0xff112233));
      expect(s.primary, const OceanColorScheme.light().primary);
      expect(s, isNot(const OceanColorScheme.light()));
    });
  });

  group('optional token fallbacks', () {
    test('a scheme that sets none of them still resolves every one', () {
      expect(
        bare.foregroundSubtle,
        Color.lerp(bare.foreground, bare.mutedForeground, .5),
      );
      expect(bare.tint, bare.primary);
      expect(bare.tintForeground, bare.primaryForeground);
      expect(bare.success, const Color(0xff15803d));
      expect(bare.successMuted, bare.success.withValues(alpha: .12));
      expect(bare.warning, const Color(0xffb45309));
      expect(bare.borderStrong, bare.input);
      expect(bare.accentBorder, bare.primary.withValues(alpha: .32));
      expect(bare.bar, bare.card);
    });

    test('a scheme that names no optional token relies on the fallbacks', () {
      for (final s in const <ColorScheme>[bare]) {
        expect(s.tint, s.primary);
        expect(s.tintForeground, s.primaryForeground);
        expect(s.borderStrong, s.input);
        expect(s.bar, s.card);
        expect(s.accentBorder, s.primary.withValues(alpha: .32));
      }
    });

    test('a fallback follows the token it derives from', () {
      // `tint` falls back to `primary`, and `accentBorder` to `tint`, so
      // re-tinting a scheme moves all three.
      final themed = bare.copyWith(primary: const Color(0xff008060));
      expect(themed.tint, const Color(0xff008060));
      expect(
        themed.accentBorder,
        const Color(0xff008060).withValues(alpha: .32),
      );
      // And `successMuted` follows an explicit `success`.
      final green = bare.copyWith(success: const Color(0xff00aa00));
      expect(
        green.successMuted,
        const Color(0xff00aa00).withValues(alpha: .12),
      );
      // A legible accent applied to a built-in scheme moves the tint with
      // it.
      final violet = const OceanColorScheme.light().applyAccent(
        const Color(0xff6d28d9),
      );
      expect(violet.tint, const Color(0xff6d28d9));
    });

    test('an explicit token wins over its fallback', () {
      final s = bare.copyWith(
        foregroundSubtle: const Color(0xff010101),
        tint: const Color(0xff020202),
        tintForeground: const Color(0xff030303),
        success: const Color(0xff040404),
        successMuted: const Color(0xff050505),
        warning: const Color(0xff060606),
        borderStrong: const Color(0xff070707),
        accentBorder: const Color(0xff080808),
        bar: const Color(0xff090909),
      );
      expect(s.foregroundSubtle, const Color(0xff010101));
      expect(s.tint, const Color(0xff020202));
      expect(s.tintForeground, const Color(0xff030303));
      expect(s.success, const Color(0xff040404));
      expect(s.successMuted, const Color(0xff050505));
      expect(s.warning, const Color(0xff060606));
      expect(s.borderStrong, const Color(0xff070707));
      expect(s.accentBorder, const Color(0xff080808));
      expect(s.bar, const Color(0xff090909));
      // The required tokens are untouched.
      expect(s.primary, bare.primary);
      expect(s.card, bare.card);
    });

    test('the tokens take part in equality and the hash', () {
      for (final changed in [
        bare.copyWith(foregroundSubtle: const Color(0xff123456)),
        bare.copyWith(tint: const Color(0xff123456)),
        bare.copyWith(tintForeground: const Color(0xff123456)),
        bare.copyWith(success: const Color(0xff123456)),
        bare.copyWith(successMuted: const Color(0xff123456)),
        bare.copyWith(warning: const Color(0xff123456)),
        bare.copyWith(borderStrong: const Color(0xff123456)),
        bare.copyWith(accentBorder: const Color(0xff123456)),
        bare.copyWith(bar: const Color(0xff123456)),
      ]) {
        expect(changed, isNot(bare));
        expect(changed.hashCode, isNot(bare.hashCode));
      }
      expect(bare.copyWith(), bare);
      expect(bare.copyWith().hashCode, bare.hashCode);
    });

    test('copyWith keeps the tokens it is not given', () {
      final copy = const OceanColorScheme.dark().copyWith(
        primary: const Color(0xff000001),
      );
      const dark = OceanColorScheme.dark();
      expect(copy.tint, dark.tint);
      expect(copy.foregroundSubtle, dark.foregroundSubtle);
      expect(copy.borderStrong, dark.borderStrong);
      expect(copy.accentBorder, dark.accentBorder);
      expect(copy.bar, dark.bar);
      expect(copy.successMuted, dark.successMuted);
    });

    test("merge takes the other scheme's tokens and keeps its own where "
        'the other has none', () {
      const blue = OceanColorScheme.light();
      // The override states the tokens: they win.
      final overBlue = bare.merge(blue);
      expect(overBlue.tint, blue.tint);
      expect(overBlue.bar, blue.bar);
      expect(overBlue.borderStrong, blue.borderStrong);
      // The override leaves them unset: the base's survive.
      final overBare = blue.merge(bare);
      expect(overBare.primary, bare.primary);
      expect(overBare.tint, blue.tint);
      expect(overBare.foregroundSubtle, blue.foregroundSubtle);
      expect(overBare.success, blue.success);
      expect(overBare.accentBorder, blue.accentBorder);
    });

    test('lerp interpolates explicit tokens', () {
      final a = bare.copyWith(tint: const Color(0xff000000));
      final b = bare.copyWith(tint: const Color(0xffffffff));
      final mid = ColorScheme.lerp(a, b, .5);
      expect(mid.tint.r, closeTo(.5, .01));
      expect(mid.tint.a, 1);
    });

    test('lerp between light and dark blue stays opaque where both are', () {
      const light = OceanColorScheme.light();
      const dark = OceanColorScheme.dark();
      for (final t in [0.0, .25, .5, .75, 1.0]) {
        final mid = ColorScheme.lerp(light, dark, t);
        expect(mid.tint.a, 1, reason: 't=$t');
        expect(mid.foregroundSubtle.a, 1, reason: 't=$t');
        expect(mid.bar.a, 1, reason: 't=$t');
        expect(mid.success.a, 1, reason: 't=$t');
      }
      expect(ColorScheme.lerp(light, dark, 0), light);
      expect(ColorScheme.lerp(light, dark, 1), dark);
    });

    test('lerp from a scheme that relies on a fallback starts at the '
        'fallback, not at transparent', () {
      // Halfway between a scheme whose tint is its primary and one that
      // states a tint, the tint is halfway between those two colours. Lerping
      // the raw nullable fields instead fades the stated colour in from
      // nothing, which shows as every tinted icon flashing translucent
      // during a theme change.
      const blue = OceanColorScheme.light();
      final mid = ColorScheme.lerp(bare, blue, .5);

      expect(mid.tint, Color.lerp(bare.tint, blue.tint, .5));
      expect(mid.tint.a, 1);
      expect(mid.bar, Color.lerp(bare.bar, blue.bar, .5));
      expect(
        mid.foregroundSubtle,
        Color.lerp(bare.foregroundSubtle, blue.foregroundSubtle, .5),
      );
      expect(mid.success, Color.lerp(bare.success, blue.success, .5));
      expect(mid.warning, Color.lerp(bare.warning, blue.warning, .5));
      // The same holds in the other direction…
      final back = ColorScheme.lerp(blue, bare, .5);
      expect(back.tint, Color.lerp(blue.tint, bare.tint, .5));
      // …and for the chart and sidebar tokens, which work the same way.
      expect(mid.chart1, Color.lerp(bare.chart1, blue.chart1, .5));
      expect(mid.sidebar, Color.lerp(bare.sidebar, blue.sidebar, .5));
    });

    test('lerp between two schemes that both rely on a fallback keeps '
        'relying on it', () {
      final other = bare.copyWith(primary: const Color(0xff00ff00));
      final mid = ColorScheme.lerp(bare, other, .5);
      // Still unset, so it follows the interpolated primary.
      expect(mid.tint, mid.primary);
      expect(mid.bar, mid.card);
      expect(ColorScheme.lerp(bare, other, 0), bare);
      expect(ColorScheme.lerp(bare, other, 1), other);
    });
  });

  group('the tokens reach the component themes', () {
    test('una outline buttons take the strong border', () {
      final theme = ThemeData();
      expect(
        theme.outlineButtonTheme.decoration!.border!.top!.color,
        theme.colorScheme.borderStrong,
      );
      // nova keeps shadcn's `--border`.
      final nova = ThemeData(
        style: StyleTokens.crisp,
        colorScheme: const GraphiteColorScheme.light(),
      );
      expect(
        nova.outlineButtonTheme.decoration!.border!.top!.color,
        nova.colorScheme.border,
      );
    });

    test('bars, navigation and chips read tint, bar and accentBorder', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final s = theme.colorScheme;
        final barOpacity = brightness == Brightness.dark ? .95 : .94;

        expect(
          theme.appBarTheme.backgroundColor,
          s.bar.withValues(alpha: barOpacity),
        );
        // The floating bar is the bar colour too — lifted toward the
        // foreground on the dark page, where the plain bar colour is lost.
        expect(
          theme.bottomNavigationBarTheme.backgroundColor,
          brightness == Brightness.dark
              ? Color.alphaBlend(
                  s.foreground.withValues(alpha: .08),
                  s.bar,
                ).withValues(alpha: .84)
              : s.bar.withValues(alpha: barOpacity),
        );
        expect(theme.navigationBarTheme.selectedIconColor, s.tint);
        expect(theme.navigationBarTheme.indicatorColor, s.tint);
        expect(theme.bottomNavigationBarTheme.selectedForegroundColor, s.tint);
        expect(
          theme.bottomNavigationBarTheme.foregroundColor,
          s.foregroundSubtle,
        );
        expect(theme.chipTheme.foregroundColor, s.foregroundSubtle);
        expect(theme.chipTheme.selectedBorderColor, s.accentBorder);
        expect(theme.chipTheme.selectedBackgroundColor, s.accent);
        expect(theme.chipTheme.selectedForegroundColor, s.accentForeground);
        expect(theme.iconTileTheme.foregroundColor, s.tint);
        expect(theme.chatBubbleTheme.outgoingColor, s.tint);
        expect(theme.chatBubbleTheme.outgoingForegroundColor, s.tintForeground);
        expect(theme.timelineTheme.lineColor, s.borderStrong);
      }
    });

    test('a scheme of required tokens only themes the new widgets through '
        'the fallbacks', () {
      final theme = ThemeData(colorScheme: bare, style: StyleTokens.crisp);
      final s = theme.colorScheme;
      expect(theme.navigationBarTheme.selectedIconColor, s.primary);
      expect(theme.chatBubbleTheme.outgoingColor, s.primary);
      expect(
        theme.chatBubbleTheme.outgoingForegroundColor,
        s.primaryForeground,
      );
      // Crisp's bars are opaque, so they pay for no backdrop layer.
      expect(theme.appBarTheme.backgroundColor, s.card);
      expect(theme.appBarTheme.blur, 0);
      expect(theme.appBarTheme.saturation, 1);
      expect(theme.bottomNavigationBarTheme.blur, 0);
    });
  });
}

/// The WCAG contrast ratio between two opaque colours.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + .05) / (lo + .05);
}
