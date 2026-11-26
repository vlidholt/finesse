import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// `StyleTokens.copyWith` carries an override to the style's phone metrics
/// wherever the phone did not differ from the desktop to begin with.
void main() {
  const una = StyleTokens.una;
  const phone = StyleTokens.unaMobile;

  group('StyleTokens.copyWith and the phone metrics', () {
    test('the fixtures are what these tests assume', () {
      expect(una.mobile, phone);
      // Shared between the two…
      expect(phone.glassBlur, una.glassBlur);
      expect(phone.dividerMargin, una.dividerMargin);
      expect(phone.cardShadow, una.cardShadow);
      expect(phone.cardBorderOpacityDark, una.cardBorderOpacityDark);
      // …and set on purpose for a phone.
      expect(una.buttonHeight, 36);
      expect(phone.buttonHeight, 44);
      expect(una.tabHeight, 32);
      expect(phone.tabHeight, 36);
      expect(StyleTokens.nova.mobile, isNull);
    });

    test('a copy with no arguments is equal, phone metrics included', () {
      final copy = una.copyWith();
      expect(copy, una);
      expect(copy.hashCode, una.hashCode);
      expect(copy.mobile, phone);
      for (final style in [
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
        phone,
      ]) {
        expect(style.copyWith(), style, reason: style.name);
      }
    });

    test('a copy that restates a value is equal too', () {
      expect(
        una.copyWith(
          glassBlur: una.glassBlur,
          buttonHeight: una.buttonHeight,
          cardShadow: una.cardShadow,
        ),
        una,
      );
    });

    test('a field the phone shared follows the override', () {
      final copy = una.copyWith(glassBlur: 12);
      expect(copy.glassBlur, 12);
      expect(copy.mobile!.glassBlur, 12);
      // Nothing else about the phone moved.
      expect(copy.mobile, phone.copyWith(glassBlur: 12));
      expect(copy.mobile!.buttonHeight, 44);

      final margin = una.copyWith(dividerMargin: 8, timelineLineGap: 10);
      expect(margin.mobile!.dividerMargin, 8);
      expect(margin.mobile!.timelineLineGap, 10);
    });

    test('a field the phone sets on purpose keeps its phone value', () {
      final copy = una.copyWith(buttonHeight: 40);
      expect(copy.buttonHeight, 40);
      expect(copy.mobile!.buttonHeight, 44);
      // The phone metrics are exactly what they were.
      expect(copy.mobile, phone);
    });

    test('both at once: each field is decided on its own', () {
      final copy = una.copyWith(glassBlur: 12, buttonHeight: 40);
      expect(copy.glassBlur, 12);
      expect(copy.buttonHeight, 40);
      expect(copy.mobile!.glassBlur, 12);
      expect(copy.mobile!.buttonHeight, 44);
      expect(copy.mobile, phone.copyWith(glassBlur: 12));
    });

    test('a list-valued field follows, compared by value', () {
      const shadow = [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 9,
          offset: Offset(0, 3),
        ),
      ];
      final copy = una.copyWith(cardShadow: shadow);
      expect(copy.cardShadow, shadow);
      expect(copy.mobile!.cardShadow, shadow);

      // The phone's list need not be the same instance as the desktop's,
      // only equal to it.
      final rebuilt = una.copyWith(
        mobile: phone.copyWith(cardShadow: [...una.cardShadow]),
      );
      expect(
        identical(rebuilt.mobile!.cardShadow, rebuilt.cardShadow),
        isFalse,
      );
      expect(rebuilt.copyWith(cardShadow: shadow).mobile!.cardShadow, shadow);
    });

    test('a list the phone sets differently is kept', () {
      const phoneShadow = [
        BoxShadow(color: Color(0x22000000), blurRadius: 2),
      ];
      const shadow = [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 9,
          offset: Offset(0, 3),
        ),
      ];
      final base = una.copyWith(
        mobile: phone.copyWith(cardShadow: phoneShadow),
      );
      final copy = base.copyWith(cardShadow: shadow);
      expect(copy.cardShadow, shadow);
      expect(copy.mobile!.cardShadow, phoneShadow);
    });

    test('a nullable field the phone sets on purpose is kept', () {
      final copy = una.copyWith(tabHeight: 30);
      expect(copy.tabHeight, 30);
      expect(copy.mobile!.tabHeight, 36);
      expect(copy.mobile, phone);
    });

    test('a nullable field the two shared follows', () {
      final copy = una.copyWith(cardBorderOpacityDark: .2);
      expect(copy.cardBorderOpacityDark, .2);
      expect(copy.mobile!.cardBorderOpacityDark, .2);
    });

    test('a nullable field that neither set follows as well', () {
      expect(una.surfaceRadiusCap, phone.surfaceRadiusCap);
      final copy = una.copyWith(surfaceRadiusCap: 11);
      expect(copy.surfaceRadiusCap, 11);
      expect(copy.mobile!.surfaceRadiusCap, 11);
    });

    test('an explicit mobile is used as given', () {
      final given = phone.copyWith(glassBlur: 3, buttonHeight: 50);
      final copy = una.copyWith(
        glassBlur: 12,
        buttonHeight: 40,
        dividerMargin: 8,
        mobile: given,
      );
      expect(copy.glassBlur, 12);
      expect(copy.buttonHeight, 40);
      expect(copy.mobile, given);
      // Not even the shared fields are written into it.
      expect(copy.mobile!.glassBlur, 3);
      expect(copy.mobile!.dividerMargin, phone.dividerMargin);
      expect(copy.mobile!.buttonHeight, 50);
    });

    test("that is how a phone's own metric is changed", () {
      final copy = una.copyWith(
        mobile: una.mobile!.copyWith(buttonHeight: 48),
      );
      expect(copy.buttonHeight, 36);
      expect(copy.mobile!.buttonHeight, 48);
      expect(copy.forFormFactor(FormFactor.mobile).buttonHeight, 48);
    });

    test('"shared" is judged before each copy, so a field that has come to '
        'agree follows from then on', () {
      // Raise the desktop button to the phone's 44: now the two agree…
      final agreed = una.copyWith(buttonHeight: 44);
      expect(agreed.mobile!.buttonHeight, 44);
      // …so the next override reaches both.
      final next = agreed.copyWith(buttonHeight: 50);
      expect(next.buttonHeight, 50);
      expect(next.mobile!.buttonHeight, 50);
    });

    test('a name reaches the phone metrics', () {
      final copy = una.copyWith(name: 'mine');
      expect(copy.name, 'mine');
      expect(copy.mobile!.name, 'mine');
    });

    test('the phone metrics of a copy are still a fixed point', () {
      final copy = una.copyWith(glassBlur: 12, buttonHeight: 40);
      final mobile = copy.forFormFactor(FormFactor.mobile);
      expect(mobile, copy.mobile);
      expect(mobile.mobile, isNull);
      expect(mobile.forFormFactor(FormFactor.mobile), mobile);
      expect(copy.forFormFactor(FormFactor.desktop), copy);
    });

    test('a style with no mobile gains none: its phone metrics are derived '
        'from the copy', () {
      for (final style in [
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        final copy = style.copyWith(glassBlur: 7, buttonHeight: 40);
        expect(copy.mobile, isNull, reason: style.name);
        expect(copy.glassBlur, 7, reason: style.name);
        expect(copy.buttonHeight, 40, reason: style.name);

        final derived = copy.forFormFactor(FormFactor.mobile);
        // Derivation carries the override over…
        expect(derived.glassBlur, 7, reason: style.name);
        // …and still makes controls touch-sized.
        expect(
          derived.buttonHeight,
          greaterThanOrEqualTo(44),
          reason: style.name,
        );
        // A control already taller than a touch target is not shrunk.
        expect(
          style
              .copyWith(buttonHeight: 60)
              .forFormFactor(FormFactor.mobile)
              .buttonHeight,
          60,
          reason: style.name,
        );
      }
    });

    test('a mobile style copies like any style without one', () {
      final copy = phone.copyWith(glassBlur: 5, buttonHeight: 48);
      expect(copy.mobile, isNull);
      expect(copy.glassBlur, 5);
      expect(copy.buttonHeight, 48);
    });
  });

  group('a copied style through ThemeData', () {
    test('a shared override reaches the component themes on a phone', () {
      final style = una.copyWith(glassBlur: 12, buttonHeight: 40);
      final desktop = ThemeData(style: style);
      final mobile = ThemeData(style: style, formFactor: FormFactor.mobile);

      expect(desktop.baseStyle, style);
      expect(mobile.baseStyle, style);
      expect(desktop.style.glassBlur, 12);
      expect(mobile.style.glassBlur, 12);
      expect(desktop.glassTheme.blur, 12);
      expect(mobile.glassTheme.blur, 12);
      expect(mobile.appBarTheme.blur, 12);
      expect(mobile.bottomNavigationBarTheme.blur, 12);
      // Without the carry-over a phone kept the stock 24.
      expect(
        ThemeData(formFactor: FormFactor.mobile).glassTheme.blur,
        una.glassBlur,
      );
    });

    test("the phone's own metrics are untouched by a desktop override", () {
      final style = una.copyWith(glassBlur: 12, buttonHeight: 40);
      final desktop = ThemeData(style: style);
      final mobile = ThemeData(style: style, formFactor: FormFactor.mobile);
      final stock = ThemeData(formFactor: FormFactor.mobile);

      expect(desktop.style.buttonHeight, 40);
      expect(mobile.style.buttonHeight, 44);
      expect(desktop.buttonSizesTheme.regular!.height, 40);
      expect(mobile.buttonSizesTheme.regular!.height, 44);
      expect(mobile.buttonSizesTheme, stock.buttonSizesTheme);
      expect(mobile.chipTheme.height, 36);
    });

    test('the other shared tokens follow on a phone too', () {
      final style = una.copyWith(
        dividerMargin: 8,
        timelineLineGap: 10,
        progressTinted: false,
        secondaryButtonFill: SurfaceFill.secondary,
      );
      final mobile = ThemeData(style: style, formFactor: FormFactor.mobile);
      expect(
        mobile.dividerTheme.horizontalMargin,
        const EdgeInsets.symmetric(vertical: 8),
      );
      expect(mobile.timelineTheme.lineGap, 10);
      expect(mobile.progressBarTheme.color, mobile.colorScheme.primary);
      expect(
        mobile.secondaryButtonTheme.backgroundColor,
        mobile.colorScheme.secondary,
      );
    });

    test(
      'withFormFactor and copyWith(style:) agree with building directly',
      () {
        final style = una.copyWith(glassBlur: 12, buttonHeight: 40);
        final direct = ThemeData(style: style, formFactor: FormFactor.mobile);
        expect(
          ThemeData(style: style).withFormFactor(FormFactor.mobile),
          direct,
        );
        expect(
          ThemeData(formFactor: FormFactor.mobile).copyWith(style: style),
          direct,
        );
        expect(direct.copyWith(style: direct.baseStyle), direct);
      },
    );

    test('nova with an override derives its phone theme from the copy', () {
      final style = StyleTokens.nova.copyWith(
        dividerMargin: 4,
        buttonHeight: 40,
      );
      final mobile = ThemeData(style: style, formFactor: FormFactor.mobile);
      expect(mobile.baseStyle, style);
      expect(
        mobile.dividerTheme.horizontalMargin,
        const EdgeInsets.symmetric(vertical: 4),
      );
      expect(mobile.style.buttonHeight, greaterThanOrEqualTo(44));
      expect(
        mobile.buttonSizesTheme.regular!.height,
        mobile.style.buttonHeight,
      );
    });

    test('an explicit mobile reaches the phone theme as given', () {
      final style = una.copyWith(
        glassBlur: 12,
        mobile: una.mobile!.copyWith(glassBlur: 3, buttonHeight: 50),
      );
      final mobile = ThemeData(style: style, formFactor: FormFactor.mobile);
      expect(mobile.glassTheme.blur, 3);
      expect(mobile.buttonSizesTheme.regular!.height, 50);
      expect(ThemeData(style: style).glassTheme.blur, 12);
    });
  });
}
