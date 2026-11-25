import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `copyWith` re-derives the component themes from the theme's inputs, so a
/// copy is indistinguishable from a theme built with those inputs directly.
void main() {
  final base = ThemeData(
    colorScheme: const ZincColorScheme.light(),
    brightness: Brightness.light,
  );

  test('copyWith(radius:) moves the component themes too', () {
    const radius = BorderRadius.all(Radius.circular(2));
    final copy = base.copyWith(radius: radius);
    final direct = ThemeData(
      colorScheme: const ZincColorScheme.light(),
      brightness: Brightness.light,
      radius: radius,
    );

    expect(copy.radius, radius);
    expect(copy.primaryButtonTheme, direct.primaryButtonTheme);
    expect(copy.textFieldTheme, direct.textFieldTheme);
    expect(copy, direct);
  });

  test('copyWith(colorScheme:) recolours the component themes', () {
    final copy = base.copyWith(colorScheme: const StoneColorScheme.light());
    final direct = ThemeData(
      colorScheme: const StoneColorScheme.light(),
      brightness: Brightness.light,
    );
    expect(copy.primaryButtonTheme, direct.primaryButtonTheme);
    expect(copy, direct);
  });

  test('copyWith(style:) and copyWith(spacing:) re-derive metrics', () {
    final copy = base.copyWith(
      style: StyleTokens.lyra,
      spacing: const Spacing(step: 3),
    );
    final direct = ThemeData(
      colorScheme: const ZincColorScheme.light(),
      brightness: Brightness.light,
      style: StyleTokens.lyra,
      spacing: const Spacing(step: 3),
    );
    expect(copy.style, StyleTokens.lyra);
    expect(copy.spacing.step, 3);
    expect(copy, direct);
  });

  test('copyWith(formFactor:) re-derives the metrics', () {
    final copy = base.copyWith(formFactor: FormFactor.mobile);
    final direct = ThemeData(
      colorScheme: const ZincColorScheme.light(),
      brightness: Brightness.light,
      formFactor: FormFactor.mobile,
    );
    expect(base.formFactor, FormFactor.desktop);
    expect(copy.formFactor, FormFactor.mobile);
    expect(copy.style, StyleTokens.finesseMobile);
    expect(copy.buttonSizesTheme.regular!.height, 44);
    expect(copy.textFieldTheme.constraints!.minHeight, 46);
    expect(copy.chipTheme.height, 36);
    expect(copy.textTheme.p.fontSize, 15);
    expect(copy.layoutTheme, direct.layoutTheme);
    expect(copy.primaryButtonTheme, direct.primaryButtonTheme);
    expect(copy, direct);
    // And back again.
    expect(copy.copyWith(formFactor: FormFactor.desktop), base);
  });

  test('copyWith(style:) re-derives from the new style', () {
    final finesse = ThemeData();
    final copy = finesse.copyWith(style: StyleTokens.nova);
    final direct = ThemeData(style: StyleTokens.nova);

    expect(copy.style, StyleTokens.nova);
    expect(copy.variant.baseStyle, StyleTokens.nova);
    // 36 -> nova's h-8.
    expect(finesse.buttonSizesTheme.regular!.height, 36);
    expect(copy.buttonSizesTheme.regular!.height, 32);
    // The card goes opaque. Neither style blurs behind its cards.
    expect(finesse.cardTheme.backgroundColor!.a, lessThan(1));
    expect(finesse.cardTheme.blur, 0);
    expect(copy.cardTheme.blur, 0);
    expect(copy.cardTheme.backgroundColor, copy.colorScheme.card);
    // A style that does, loses it with the style.
    final glass = ThemeData(
      style: StyleTokens.finesse.copyWith(cardBlur: true),
    );
    expect(glass.cardTheme.blur, StyleTokens.finesse.glassBlur);
    expect(glass.copyWith(style: StyleTokens.nova).cardTheme.blur, 0);
    // The published type scale becomes nova's: paragraphs are 14 in both,
    // but `large` drops from finesse's 15-point subtitle to nova's 14, and
    // `h4` from finesse's semibold title to nova's medium one.
    expect(finesse.textTheme.p.fontSize, 14);
    expect(copy.textTheme.p.fontSize, 14);
    expect(finesse.textTheme.large.fontSize, 15);
    expect(copy.textTheme.large.fontSize, 14);
    expect(finesse.textTheme.h4.fontWeight, FontWeight.w600);
    expect(copy.textTheme.h4.fontWeight, FontWeight.w500);
    expect(copy.textTheme, direct.textTheme);
    expect(copy, direct);
  });

  test("copyWith(style:) takes the style's own radius and scale when the "
      'theme stated none', () {
    final finesse = ThemeData();
    expect(finesse.radius, const BorderRadius.all(Radius.circular(10)));
    expect(finesse.radii.scale, StyleTokens.finesse.radiusScale);

    final nova = finesse.copyWith(style: StyleTokens.nova);
    expect(nova.radius, const BorderRadius.all(Radius.circular(8)));
    expect(nova.radii.scale, const RadiusScale());
    // lg on the Tailwind scale: 8 * 1.25.
    expect(
      (nova.primaryButtonTheme.decoration!.border!.radius! as BorderRadius)
          .topLeft
          .x,
      10,
    );

    // A radius the caller stated is theirs and survives the style change.
    const stated = BorderRadius.all(Radius.circular(4));
    final pinned = ThemeData(radius: stated).copyWith(style: StyleTokens.nova);
    expect(pinned.radius, stated);
  });

  test('copyWith(style:) keeps the form factor', () {
    final mobile = ThemeData(formFactor: FormFactor.mobile);
    final copy = mobile.copyWith(style: StyleTokens.nova);

    expect(copy.formFactor, FormFactor.mobile);
    expect(copy.variant.baseStyle, StyleTokens.nova);
    expect(copy.style, StyleTokens.nova.forFormFactor(FormFactor.mobile));
    expect(copy.buttonSizesTheme.regular!.height, 44);
    expect(
      copy,
      ThemeData(style: StyleTokens.nova, formFactor: FormFactor.mobile),
    );
  });

  test('copyWith of something unrelated keeps style and form factor', () {
    final mobile = ThemeData(
      style: StyleTokens.maia,
      formFactor: FormFactor.mobile,
    );
    final copy = mobile.copyWith(disabledOpacity: .3);
    expect(copy.formFactor, FormFactor.mobile);
    expect(copy.variant.baseStyle, StyleTokens.maia);
    expect(copy.style, mobile.style);
    expect(copy.buttonSizesTheme, mobile.buttonSizesTheme);
    expect(copy.disabledOpacity, .3);
  });

  test('copyWith(colorScheme:) recolours the finesse component themes', () {
    final copy = ThemeData().copyWith(
      colorScheme: const TealColorScheme.dark(),
    );
    const dark = TealColorScheme.dark();
    expect(copy.brightness, Brightness.dark);
    expect(copy.navigationBarTheme.selectedIconColor, dark.tint);
    expect(copy.chipTheme.selectedBorderColor, dark.accentBorder);
    expect(copy.glassTheme.color, dark.card);
    // The dark-only opacities are picked up with the scheme.
    expect(copy.glassTheme.opacity, .66);
    expect(copy.cardTheme.backgroundColor, dark.card.withValues(alpha: .82));
    expect(copy, ThemeData(colorScheme: const TealColorScheme.dark()));
  });

  test('copyWith(disableSecondaryBorder: true) switches the variant', () {
    final copy = base.copyWith(disableSecondaryBorder: true);
    expect(copy.variant, isA<DefaultThemeNoSecondaryBorderVariant>());
  });

  test('component overrides survive a copy', () {
    final themed = ThemeData(
      colorScheme: const ZincColorScheme.light(),
      brightness: Brightness.light,
      cardTheme: const CardTheme(padding: EdgeInsets.all(3)),
    );
    final copy = themed.copyWith(radius: BorderRadius.circular(1));
    expect(copy.cardTheme.padding, const EdgeInsets.all(3));
  });

  test('the floating action button and app bar themes survive a copy, and '
      'can be the copy', () {
    final themed = ThemeData(
      floatingActionButtonTheme: const FloatingActionButtonTheme(size: 60),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
    final copy = themed.copyWith(radius: BorderRadius.circular(1));
    expect(copy.floatingActionButtonTheme.size, 60);
    expect(copy.appBarTheme.centerTitle, isTrue);
    // Merged over what the variant derives, not replacing it.
    expect(
      copy.floatingActionButtonTheme.backgroundColor,
      copy.colorScheme.primary,
    );

    final changed = base.copyWith(
      floatingActionButtonTheme: const FloatingActionButtonTheme(gap: 3),
    );
    expect(changed.floatingActionButtonTheme.gap, 3);
    expect(
      changed.floatingActionButtonTheme.size,
      base.floatingActionButtonTheme.size,
    );
    // Recoloured with the scheme, resized with the form factor.
    const dark = TealColorScheme.dark();
    expect(
      base
          .copyWith(colorScheme: dark)
          .floatingActionButtonTheme
          .backgroundColor,
      dark.primary,
    );
    expect(base.floatingActionButtonTheme.size, 48);
    expect(
      base.withFormFactor(FormFactor.mobile).floatingActionButtonTheme.size,
      56,
    );
  });

  test('a copy with no arguments equals the original', () {
    expect(base.copyWith(), base);
  });

  group('brightness', () {
    test('follows a dark scheme when not given', () {
      final theme = ThemeData(
        colorScheme: const ZincColorScheme.dark(),
      );
      expect(theme.brightness, Brightness.dark);
    });

    test('follows a light scheme when not given', () {
      final theme = ThemeData(
        colorScheme: const ZincColorScheme.light(),
      );
      expect(theme.brightness, Brightness.light);
    });

    test('an explicit brightness wins', () {
      final theme = ThemeData(
        colorScheme: const ZincColorScheme.dark(),
        brightness: Brightness.light,
      );
      expect(theme.brightness, Brightness.light);
    });
  });
}
