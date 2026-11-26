import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

// `TextTheme.caption` is the app-facing fine-print style: the size, line
// height and tracking of the style's `caption` role, at the regular weight
// and in the muted colour. Screens read it instead of shrinking `muted`
// with a literal font size, so it has to follow the style, the form factor
// and the scheme.

void main() {
  group('TextTheme.caption', () {
    for (final style in StyleTokens.all) {
      for (final formFactor in FormFactor.values) {
        for (final brightness in Brightness.values) {
          test('${style.name}, ${formFactor.name}, ${brightness.name}: the '
              'caption role, regular and muted', () {
            final theme = ThemeData(
              style: style,
              formFactor: formFactor,
              brightness: brightness,
            );
            final role = theme.style.caption;
            final caption = theme.textTheme.caption;
            expect(caption.fontSize, role.fontSize);
            expect(
              caption.height,
              role.height ?? TextRole.defaultHeightFor(role.fontSize),
            );
            expect(caption.letterSpacing, role.letterSpacing ?? 0);
            // Not the role's medium weight: metadata set in it stops
            // receding.
            expect(caption.fontWeight, FontWeight.w400);
            expect(caption.color, theme.colorScheme.mutedForeground);
            // A size under the secondary line it sits beneath.
            expect(
              caption.fontSize,
              lessThanOrEqualTo(theme.textTheme.muted.fontSize!),
            );
          });
        }
      }
    }

    test('follows a customised caption role', () {
      final theme = ThemeData(
        style: StyleTokens.una.copyWith(
          caption: const TextRole(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
            height: 1.25,
          ),
        ),
      );
      final caption = theme.textTheme.caption;
      expect(caption.fontSize, 16);
      expect(caption.height, 1.25);
      expect(caption.letterSpacing, .5);
      expect(caption.fontWeight, FontWeight.w400);
      // The phone metrics had the role in common, so they follow too.
      final phone = theme.withFormFactor(FormFactor.mobile);
      expect(phone.textTheme.caption.fontSize, 16);
    });

    test('a text theme that states its own caption colour keeps it', () {
      const ink = Color(0xFF123456);
      final theme = ThemeData(
        textTheme: TextTheme(
          caption: const TextStyle(color: ink, fontWeight: FontWeight.w400),
        ),
      );
      expect(theme.textTheme.caption.color, ink);
    });

    test('is carried by copyWith, merge, apply, lerp and equality', () {
      const a = TextStyle(fontSize: 10);
      const b = TextStyle(fontSize: 20);
      final base = TextTheme();
      final withA = base.copyWith(caption: a);
      final withB = base.copyWith(caption: b);

      expect(withA.caption, a);
      expect(withA, isNot(base));
      expect(withA, base.copyWith(caption: a));
      expect(withA.hashCode, base.copyWith(caption: a).hashCode);

      expect(base.merge(withA).caption.fontSize, 10);
      expect(withA.apply(fontSizeFactor: 2).caption.fontSize, 20);
      expect(TextTheme.lerp(withA, withB, .5)!.caption.fontSize, 15);
    });

    test('a font builder reaches it, and its weight changes keep the face', () {
      TextStyle builder({
        TextStyle? textStyle,
        Color? color,
        Color? backgroundColor,
        double? fontSize,
        FontWeight? fontWeight,
        FontStyle? fontStyle,
        double? letterSpacing,
        double? wordSpacing,
        TextBaseline? textBaseline,
        double? height,
        Locale? locale,
        Paint? foreground,
        Paint? background,
        List<Shadow>? shadows,
        List<FontFeature>? fontFeatures,
        TextDecoration? decoration,
        Color? decorationColor,
        TextDecorationStyle? decorationStyle,
        double? decorationThickness,
      }) => TextStyle(
        fontFamily: 'Fake_${(fontWeight ?? FontWeight.w400).value}',
        fontWeight: fontWeight,
      );

      final theme = ThemeData(textTheme: TextTheme.fromGoogleFont(builder));
      final caption = theme.textTheme.caption;
      expect(caption, isA<BuilderTextStyle>());
      expect(caption.fontFamily, 'Fake_400');
      expect(
        caption.copyWith(fontWeight: FontWeight.w600).fontFamily,
        'Fake_600',
      );
    });
  });
}
