import 'package:flutter/material.dart' hide ButtonTheme, IconButton, ThemeData;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/icon_button.dart';
import 'package:una/src/theme/color_scheme/iris.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/spacing.dart';
import 'package:una/src/theme/style.dart';

import '../../fixture_styles.dart';

void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child, {ThemeData? theme}) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      theme: theme,
      home: Scaffold(body: child),
    );
  }

  // The `.cn-button-size-icon*` values quoted below are shadcn's nova.
  final nova = ThemeData(style: StyleTokens.crisp);

  group('IconButton', () {
    testWidgets('IconButton matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const IconButton(
            onPressed: _noop,
            icon: Icon(Icons.add),
          ),
        ),
      );

      await expectLater(
        find.byType(IconButton),
        matchesGoldenFile('goldens/icon_button.png'),
      );
    });

    testWidgets('IconButton.destructive matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const IconButton.destructive(
            onPressed: _noop,
            icon: Icon(Icons.add),
          ),
        ),
      );

      await expectLater(
        find.byType(IconButton),
        matchesGoldenFile('goldens/icon_button_destructive.png'),
      );
    });

    testWidgets('IconButton.outline matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const IconButton.outline(
            onPressed: _noop,
            icon: Icon(Icons.add),
          ),
        ),
      );

      await expectLater(
        find.byType(IconButton),
        matchesGoldenFile('goldens/icon_button_outline.png'),
      );
    });
    testWidgets('IconButton.secondary matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const IconButton.secondary(
            onPressed: _noop,
            icon: Icon(Icons.add),
          ),
        ),
      );

      await expectLater(
        find.byType(IconButton),
        matchesGoldenFile('goldens/icon_button_secondary.png'),
      );
    });

    testWidgets('IconButton.ghost matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const IconButton.ghost(
            onPressed: _noop,
            icon: Icon(Icons.add),
          ),
        ),
      );

      await expectLater(
        find.byType(IconButton),
        matchesGoldenFile('goldens/icon_button_ghost.png'),
      );
    });

    testWidgets("a style's iconSize updates icon size", (tester) async {
      const customIconSize = 10.0;
      await tester.pumpWidget(
        createTestWidget(
          const IconButton(
            icon: Icon(Icons.add),
            style: ButtonTheme(iconSize: customIconSize),
          ),
        ),
      );

      final iconSize = tester.getSize(find.byType(Icon));
      expect(iconSize, const Size.square(customIconSize));
    });

    testWidgets("the icon defaults to the style, not to Flutter's 24", (
      tester,
    ) async {
      // `.cn-button` is `[&_svg:not([class*='size-'])]:size-4`; without a
      // size the IconTheme fallback used to render every icon at 24.
      await tester.pumpWidget(
        createTestWidget(
          const IconButton(icon: Icon(Icons.add)),
          theme: nova,
        ),
      );

      expect(tester.getSize(find.byType(Icon)), const Size.square(16));
      // nova's `.cn-button-size-icon` is `size-8`.
      expect(
        tester.getSize(find.byType(IconButton)),
        const Size.square(32),
      );
    });

    testWidgets('an icon carrying its own size still wins', (tester) async {
      // The reference's `:not([class*='size-'])`.
      await tester.pumpWidget(
        createTestWidget(
          const IconButton(icon: Icon(Icons.add, size: 20)),
        ),
      );

      expect(tester.getSize(find.byType(Icon)), const Size.square(20));
    });

    testWidgets('the square sizes come from the icon slots', (tester) async {
      // `.cn-button-size-icon-sm` keeps the 16px glyph that
      // `.cn-button-size-sm` shrinks to 14 — icon buttons are sized
      // independently of text buttons at the same step.
      await tester.pumpWidget(
        createTestWidget(
          const IconButton(
            icon: Icon(Icons.add),
            size: ButtonSize.sm,
          ),
          theme: nova,
        ),
      );

      expect(tester.getSize(find.byType(Icon)), const Size.square(16));
      expect(
        tester.getSize(find.byType(IconButton)),
        const Size.square(28),
      );
    });

    testWidgets("with no size it takes the variant theme's, as a Button "
        'does', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: _noop, icon: Icon(Icons.add)),
              IconButton(
                onPressed: _noop,
                size: ButtonSize.lg,
                icon: Icon(Icons.add),
              ),
            ],
          ),
          theme: ThemeData(
            style: StyleTokens.crisp,
            primaryButtonTheme: const ButtonTheme(size: ButtonSize.sm),
          ),
        ),
      );
      final buttons = find.byType(IconButton);
      // nova's `.cn-button-size-icon-sm` is `size-7`, `icon-lg` `size-9`.
      expect(tester.getSize(buttons.first), const Size.square(28));
      expect(tester.getSize(buttons.last), const Size.square(36));
    });
  });

  group('the styles size their glyphs', () {
    // Read off `[&_svg:not([class*='size-'])]:size-*` in
    // apps/v4/registry/styles/style-*.css: most styles keep 16 everywhere,
    // `mira` follows the step down and `sera`'s base is `size-3.5`.
    // una draws its glyphs larger: 18 in a text button (16 in a small
    // one) and 20 in every icon button. `mira` and `sera` no longer ship;
    // they stay here as fixtures because they are the styles that prove the
    // `sm` and base slots are read independently.
    final expected = {
      StyleTokens.fluid: (16.0, 18.0, 18.0),
      StyleTokens.crisp: (14.0, 16.0, 16.0),
      StyleTokens.pebble: (16.0, 16.0, 16.0),
      StyleTokens.sharp: (14.0, 16.0, 16.0),
      FixtureStyles.vega: (16.0, 16.0, 16.0),
      FixtureStyles.mira: (12.0, 14.0, 16.0),
      FixtureStyles.sera: (14.0, 14.0, 14.0),
    };

    test('text buttons', () {
      for (final entry in expected.entries) {
        final sizes = ThemeData(
          brightness: Brightness.light,
          colorScheme: const IrisColorScheme.light(),
          style: entry.key,
        ).buttonSizesTheme;

        expect(
          (sizes.sm!.iconSize, sizes.regular!.iconSize, sizes.lg!.iconSize),
          entry.value,
          reason: entry.key.name,
        );
      }
    });

    test('icon buttons keep the base glyph except in mira and sera', () {
      final iconExpected = {
        StyleTokens.fluid: (20.0, 20.0, 20.0),
        StyleTokens.crisp: (16.0, 16.0, 16.0),
        StyleTokens.pebble: (16.0, 16.0, 16.0),
        StyleTokens.sharp: (16.0, 16.0, 16.0),
        FixtureStyles.vega: (16.0, 16.0, 16.0),
        FixtureStyles.mira: (12.0, 14.0, 16.0),
        FixtureStyles.sera: (14.0, 14.0, 14.0),
      };

      for (final entry in iconExpected.entries) {
        final sizes = ThemeData(
          brightness: Brightness.light,
          colorScheme: const IrisColorScheme.light(),
          style: entry.key,
        ).buttonSizesTheme;

        expect(
          (
            sizes.iconSm!.iconSize,
            sizes.icon!.iconSize,
            sizes.iconLg!.iconSize,
          ),
          entry.value,
          reason: entry.key.name,
        );
      }
    });

    test('the spacing unit scales them', () {
      // `size-4` is `calc(var(--spacing) * 4)`, so a wider unit widens the
      // glyph with everything else.
      final theme = ThemeData(
        brightness: Brightness.light,
        colorScheme: const IrisColorScheme.light(),
        style: StyleTokens.crisp,
        spacing: const Spacing(step: 5),
      );
      expect(theme.buttonSizesTheme.icon!.iconSize, 20);
    });
  });
}

/// A callback, so a button is enabled.
void _noop() {}
