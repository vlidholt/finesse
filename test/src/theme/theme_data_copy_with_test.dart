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
    final copy = base.copyWith(colorScheme: const RoseColorScheme.light());
    final direct = ThemeData(
      colorScheme: const RoseColorScheme.light(),
      brightness: Brightness.light,
    );
    expect(copy.primaryButtonTheme, direct.primaryButtonTheme);
    expect(copy, direct);
  });

  test('copyWith(style:) and copyWith(spacing:) re-derive metrics', () {
    final copy = base.copyWith(
      style: StyleTokens.mira,
      spacing: const Spacing(step: 3),
    );
    final direct = ThemeData(
      colorScheme: const ZincColorScheme.light(),
      brightness: Brightness.light,
      style: StyleTokens.mira,
      spacing: const Spacing(step: 3),
    );
    expect(copy.style, StyleTokens.mira);
    expect(copy.spacing.step, 3);
    expect(copy, direct);
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
