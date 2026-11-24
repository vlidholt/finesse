import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/kbd.dart';
import 'package:finesse/src/components/tooltip.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/material.dart' hide Theme, ThemeData, Tooltip;
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Tooltip', () {
    testWidgets('DatePicker matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Tooltip(
            builder: (context) {
              return const Text('Tooltip');
            },
            child: const Text('trigger'),
          ),
        ),
      );

      await expectLater(
        find.byType(Tooltip),
        matchesGoldenFile('goldens/tooltip.png'),
      );
      await tester.pumpAndSettle();
    });
  });

  group('hit testing', () {
    const trigger = Key('trigger');

    testWidgets(
      'a GestureDetector around the tooltip receives taps on the trigger',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          createTestWidget(
            Center(
              child: GestureDetector(
                onTap: () => taps++,
                child: Tooltip(
                  builder: (_) => const Text('Tooltip'),
                  child: const SizedBox.square(
                    key: trigger,
                    dimension: 40,
                    child: ColoredBox(color: Color(0xff000000)),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(trigger));
        expect(taps, 1);
      },
    );

    testWidgets('a tap on the trigger does not reach a widget behind it', (
      tester,
    ) async {
      var behind = 0;
      await tester.pumpWidget(
        createTestWidget(
          Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => behind++,
                ),
              ),
              Center(
                child: Tooltip(
                  builder: (_) => const Text('Tooltip'),
                  child: const SizedBox.square(
                    key: trigger,
                    dimension: 40,
                    child: ColoredBox(color: Color(0xff000000)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.byKey(trigger));
      expect(behind, 0);
    });
  });

  group('tooltip theme resolution', () {
    // `.cn-tooltip-content` is the inverted surface: `bg-foreground
    // text-background` at `text-xs`, borderless and shadowless, with a
    // per-style radius one notch under the popover's.
    test('the surface is inverted, shadowless, at text-xs', () {
      final theme = ThemeData();
      final tooltip = theme.tooltipTheme;
      expect(tooltip.decoration?.color, theme.colorScheme.foreground);
      expect(tooltip.decoration?.shadows, isNull);
      expect(tooltip.textStyle?.color, theme.colorScheme.background);
      expect(tooltip.textStyle?.fontSize, 12);
      expect(tooltip.showArrow, isTrue);
      expect(tooltip.arrowSize, 10);
      expect(tooltip.arrowRadius, 2);
    });

    test('the radius follows the style, and square styles sharpen the tip', () {
      BorderRadius radiusOf(StyleTokens style) => ThemeData(
        style: style,
      ).tooltipTheme.decoration!.border!.radius!.resolve(TextDirection.ltr);

      // vega `rounded-md` 8, maia `rounded-2xl` 16, luma `rounded-xl` 14.
      expect(radiusOf(StyleTokens.vega).topLeft.x, 8);
      expect(radiusOf(StyleTokens.maia).topLeft.x, 16);
      expect(radiusOf(StyleTokens.luma).topLeft.x, 14);
      expect(radiusOf(StyleTokens.lyra), BorderRadius.zero);
      expect(radiusOf(StyleTokens.sera), BorderRadius.zero);
      expect(
        ThemeData(style: StyleTokens.lyra).tooltipTheme.arrowRadius,
        0,
      );
    });
  });

  group('content inversion', () {
    testWidgets('the builder context sees the inverted text style and the '
        'kbd re-theme', (tester) async {
      final controller = TooltipController();
      addTearDown(controller.dispose);
      TextStyle? seenStyle;
      await tester.pumpWidget(
        createTestWidget(
          Center(
            child: Tooltip(
              controller: controller,
              builder: (context) {
                seenStyle = DefaultTextStyle.of(context).style;
                return const Kbd('S');
              },
              child: const Text('trigger'),
            ),
          ),
        ),
      );
      controller.show();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final theme = Theme.of(tester.element(find.text('trigger')));
      // A custom builder reads the tooltip's own style through its context —
      // it used to get the page's, which painted foreground-on-foreground.
      expect(seenStyle?.color, theme.colorScheme.background);
      expect(seenStyle?.fontSize, 12);

      // And a key cap inverts with the surface:
      // `in-data-[slot=tooltip-content]:bg-background/20 text-background`.
      final capText = tester.widget<Text>(find.text('S'));
      expect(capText.style?.color, theme.colorScheme.background);
    });
  });

  group('the arrow', () {
    // The arrow is the one widget rotated by exactly 45°.
    Finder diamond() => find.byWidgetPredicate((widget) {
      if (widget is! Transform) return false;
      final storage = widget.transform.storage;
      const sqrt2over2 = 0.7071;
      return (storage[0] - sqrt2over2).abs() < .01 &&
          (storage[1] - sqrt2over2).abs() < .01;
    });

    testWidgets('rides the bottom edge when the tooltip sits above', (
      tester,
    ) async {
      final controller = TooltipController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createTestWidget(
          Center(
            child: Tooltip(
              controller: controller,
              builder: (_) => const Text('Tooltip'),
              child: const Text('trigger'),
            ),
          ),
        ),
      );
      controller.show();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(diamond(), findsOneWidget);
      final tooltipCenter = tester.getCenter(find.text('Tooltip'));
      final arrowCenter = tester.getCenter(diamond());
      final triggerCenter = tester.getCenter(find.text('trigger'));
      // Tooltip above the trigger; the arrow between them.
      expect(tooltipCenter.dy, lessThan(triggerCenter.dy));
      expect(arrowCenter.dy, greaterThan(tooltipCenter.dy));
      expect(arrowCenter.dy, lessThan(triggerCenter.dy));
    });

    testWidgets('flips above when the portal falls back below', (
      tester,
    ) async {
      final controller = TooltipController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createTestWidget(
          Align(
            // No room above: the fallback anchor places the tooltip below.
            alignment: Alignment.topCenter,
            child: Tooltip(
              controller: controller,
              builder: (_) => const Text('Tooltip'),
              child: const Text('trigger'),
            ),
          ),
        ),
      );
      controller.show();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      final tooltipCenter = tester.getCenter(find.text('Tooltip'));
      final arrowCenter = tester.getCenter(diamond());
      final triggerCenter = tester.getCenter(find.text('trigger'));
      // Tooltip below the trigger; the arrow between them, above the bubble.
      expect(tooltipCenter.dy, greaterThan(triggerCenter.dy));
      expect(arrowCenter.dy, lessThan(tooltipCenter.dy));
    });

    testWidgets('can be turned off', (tester) async {
      final controller = TooltipController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        createTestWidget(
          Center(
            child: Tooltip(
              controller: controller,
              showArrow: false,
              builder: (_) => const Text('Tooltip'),
              child: const Text('trigger'),
            ),
          ),
        ),
      );
      controller.show();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Tooltip'), findsOneWidget);
      expect(diamond(), findsNothing);
    });
  });
}
