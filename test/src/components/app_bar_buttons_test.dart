import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:una/src/liquid_glass/liquid_glass.dart'
    show LiquidGlassBarGroup;
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A bar gives the buttons in it that name no variant the look for what it
/// is drawn on, and lines up the glyph of a bare one at either end with its
/// margin.
void main() {
  /// The variant the icon button found by [finder] was resolved to.
  ButtonVariant? variantOf(WidgetTester tester, Finder finder) => tester
      .widget<Button>(
        find.descendant(of: finder, matching: find.byType(Button)).first,
      )
      .variant;

  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body, {
    bool shaderFilters = true,
  }) async {
    debugDefaultTargetPlatformOverride = platform;
    LiquidGlass.debugHasShaderFilters = shaderFilters;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
      LiquidGlass.debugHasShaderFilters = null;
    }
  }

  const iconKey = Key('icon');
  const explicitKey = Key('explicit');
  Widget bar({EdgeInsetsGeometry? padding, List<Widget>? actions}) => Column(
    children: [
      AppBar(
        padding: padding,
        title: const Text('Title'),
        actions:
            actions ??
            [
              IconButton(
                key: explicitKey,
                variant: ButtonVariant.outline,
                icon: const SizedBox.square(dimension: 16),
                onPressed: () {},
              ),
              IconButton(
                key: iconKey,
                icon: const SizedBox.square(dimension: 16),
                onPressed: () {},
              ),
            ],
      ),
    ],
  );

  testWidgets('outside a bar a button with no variant is primary', (
    tester,
  ) async {
    await pumpUna(
      tester,
      IconButton(
        key: iconKey,
        icon: const SizedBox.square(dimension: 16),
        onPressed: () {},
      ),
    );
    expect(variantOf(tester, find.byKey(iconKey)), ButtonVariant.primary);
  });

  testWidgets('on its own surface a bar gives its buttons the ghost', (
    tester,
  ) async {
    await pumpUna(tester, bar(), formFactor: FormFactor.mobile);
    expect(variantOf(tester, find.byKey(iconKey)), ButtonVariant.ghost);
    // A variant the caller names is kept.
    expect(variantOf(tester, find.byKey(explicitKey)), ButtonVariant.outline);
  });

  testWidgets('over a picture the buttons are outline discs', (tester) async {
    await pumpUna(
      tester,
      SizedBox(
        height: 400,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Title'),
              expandedHeight: 120,
              background: const ColoredBox(color: Color(0xFF336699)),
              leading: const BackButton(),
              actions: [
                IconButton(
                  key: iconKey,
                  icon: const SizedBox.square(dimension: 16),
                  onPressed: () {},
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 800)),
          ],
        ),
      ),
      formFactor: FormFactor.mobile,
    );
    expect(variantOf(tester, find.byKey(iconKey)), ButtonVariant.outline);
    // The bar's own back button too.
    expect(
      variantOf(tester, find.byType(BackButton)),
      ButtonVariant.outline,
    );
  });

  testWidgets('on Liquid Glass the buttons are round, on an unclipped '
      'capsule', (tester) async {
    await onPlatform(TargetPlatform.iOS, () async {
      await pumpUna(tester, bar(), formFactor: FormFactor.mobile);
      expect(variantOf(tester, find.byKey(iconKey)), ButtonVariant.ghost);
      final capsule = find.byType(LiquidGlassBarGroup);
      expect(capsule, findsOneWidget);
      // A badge hangs over the capsule's edge instead of being cut off.
      final glass = tester.widget<lg.GlassContainer>(
        find.descendant(of: capsule, matching: find.byType(lg.GlassContainer)),
      );
      expect(glass.clipBehavior, Clip.none);
      // So every button on it is round, to keep its fills inside the ends.
      final theme = Theme.of(tester.element(capsule));
      for (final key in [iconKey, explicitKey]) {
        final button = tester.widget<Button>(
          find.descendant(
            of: find.byKey(key),
            matching: find.byType(Button),
          ),
        );
        expect(
          button.style?.decoration?.border?.borderRadius,
          theme.radii.full,
          reason: '$key',
        );
      }
    });
  });

  testWidgets('a solid web bar gives its buttons the ghost, no capsule', (
    tester,
  ) async {
    await onPlatform(TargetPlatform.iOS, shaderFilters: false, () async {
      await pumpUna(tester, bar(), formFactor: FormFactor.mobile);
      expect(find.byType(LiquidGlassBarGroup), findsNothing);
      expect(variantOf(tester, find.byKey(iconKey)), ButtonVariant.ghost);
    });
  });

  testWidgets("a menu opened from a bar's button keeps its own buttons", (
    tester,
  ) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    const inMenu = Key('inMenu');
    await pumpUna(
      tester,
      bar(
        actions: [
          Popover(
            controller: controller,
            builder: (context) => IconButton(
              key: inMenu,
              icon: const SizedBox.square(dimension: 16),
              onPressed: () {},
            ),
            child: IconButton(
              key: iconKey,
              icon: const SizedBox.square(dimension: 16),
              onPressed: controller.toggle,
            ),
          ),
        ],
      ),
      formFactor: FormFactor.mobile,
    );
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(variantOf(tester, find.byKey(iconKey)), ButtonVariant.ghost);
    expect(variantOf(tester, find.byKey(inMenu)), ButtonVariant.primary);
  });

  group('the glyph of a bare button at an end', () {
    const margin = 16.0;
    const padding = EdgeInsets.symmetric(horizontal: margin);

    /// How far the glyph sits inside a regular icon button.
    double inset(WidgetTester tester) {
      final style = Theme.of(tester.element(find.byType(AppBar))).style;
      return (style.iconButtonSize - style.iconButtonIconSize) / 2;
    }

    testWidgets('stands on the margin, through a badge', (tester) async {
      await pumpUna(
        tester,
        bar(
          padding: padding,
          actions: [
            IndicatorBadge(
              count: 3,
              child: IconButton(
                key: iconKey,
                icon: const SizedBox.square(dimension: 16),
                onPressed: () {},
              ),
            ),
          ],
        ),
        formFactor: FormFactor.mobile,
      );
      final width = tester.view.physicalSize.width;
      final box = tester.getRect(find.byKey(iconKey));
      expect(box.right, width - margin + inset(tester));
    });

    testWidgets('at the start too, in either direction', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(
          tester,
          Column(
            children: [
              AppBar(
                padding: padding,
                leading: IconButton(
                  key: iconKey,
                  icon: const SizedBox.square(dimension: 16),
                  onPressed: () {},
                ),
                title: const Text('Title'),
              ),
            ],
          ),
          formFactor: FormFactor.mobile,
          textDirection: direction,
        );
        final width = tester.view.physicalSize.width;
        final box = tester.getRect(find.byKey(iconKey));
        if (direction == TextDirection.ltr) {
          expect(box.left, margin - inset(tester));
        } else {
          expect(box.right, width - margin + inset(tester));
        }
      }
    });

    testWidgets('but a button with a surface stands its edge there', (
      tester,
    ) async {
      await pumpUna(
        tester,
        bar(
          padding: padding,
          actions: [
            IconButton.outline(
              key: iconKey,
              icon: const SizedBox.square(dimension: 16),
              onPressed: () {},
            ),
          ],
        ),
        formFactor: FormFactor.mobile,
      );
      final width = tester.view.physicalSize.width;
      expect(tester.getRect(find.byKey(iconKey)).right, width - margin);
    });

    testWidgets('and on Liquid Glass the capsule does', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pumpUna(
          tester,
          bar(padding: padding),
          formFactor: FormFactor.mobile,
        );
        final width = tester.view.physicalSize.width;
        expect(
          tester.getRect(find.byType(LiquidGlassBarGroup)).right,
          width - margin,
        );
      });
    });
  });
}
