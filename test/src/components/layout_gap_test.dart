import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  const a = SizedBox(key: Key('a'), width: 20, height: 20);
  const b = SizedBox(key: Key('b'), width: 20, height: 20);
  const c = SizedBox(key: Key('c'), width: 20, height: 20);

  /// The distance from the end of `a` to the start of `b` along [axis], in a
  /// left-to-right layout.
  double distance(WidgetTester tester, Axis axis) {
    final first = tester.getRect(find.byKey(const Key('a')));
    final second = tester.getRect(find.byKey(const Key('b')));
    return axis == Axis.vertical
        ? second.top - first.bottom
        : second.left - first.right;
  }

  // The finesse scale: lg and xl tighten on a phone, the rest do not.
  const scale = {
    FormFactor.desktop: {
      GapSize.none: 0.0,
      GapSize.xs: 4.0,
      GapSize.sm: 8.0,
      GapSize.md: 12.0,
      GapSize.lg: 16.0,
      GapSize.xl: 24.0,
    },
    FormFactor.mobile: {
      GapSize.none: 0.0,
      GapSize.xs: 4.0,
      GapSize.sm: 8.0,
      GapSize.md: 12.0,
      GapSize.lg: 12.0,
      GapSize.xl: 16.0,
    },
  };

  group('Gap.size', () {
    testWidgets("each named step takes the theme's extent, per form factor", (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        for (final size in GapSize.values) {
          await pumpFinesse(
            tester,
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [a, Gap.size(size), b],
              ),
            ),
            formFactor: formFactor,
          );
          expect(
            distance(tester, Axis.vertical),
            scale[formFactor]![size],
            reason: '$formFactor $size',
          );
        }
      }
    });

    testWidgets('the shorthands are the named steps', (tester) async {
      const shorthands = {
        GapSize.xs: Gap.xs(),
        GapSize.sm: Gap.sm(),
        GapSize.md: Gap.md(),
        GapSize.lg: Gap.lg(),
        GapSize.xl: Gap.xl(),
      };
      for (final entry in shorthands.entries) {
        expect(entry.value.size, entry.key);
        await pumpFinesse(
          tester,
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [a, entry.value, b],
            ),
          ),
        );
        expect(
          distance(tester, Axis.vertical),
          scale[FormFactor.desktop]![entry.key],
        );
      }
    });

    testWidgets('runs along the main axis of whatever it is in', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [a, Gap.xl(), b],
          ),
        ),
      );
      expect(distance(tester, Axis.horizontal), 24);
      // And takes no cross-axis space of its own.
      expect(tester.getSize(find.byType(Row)), const Size(20 + 24 + 20, 20));
    });

    testWidgets('follows a change of form factor without being rebuilt', (
      tester,
    ) async {
      const tree = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [a, Gap.xl(), b],
        ),
      );
      await pumpFinesse(tester, tree);
      expect(distance(tester, Axis.vertical), 24);
      await pumpFinesse(tester, tree, formFactor: FormFactor.mobile);
      expect(distance(tester, Axis.vertical), 16);
      await pumpFinesse(tester, tree);
      expect(distance(tester, Axis.vertical), 24);
    });

    testWidgets('follows a theme override', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [a, Gap.lg(), b],
          ),
        ),
        theme: ThemeData(layoutTheme: const LayoutTheme(gapLg: 30)),
      );
      expect(distance(tester, Axis.vertical), 30);
    });

    testWidgets('scales with the spacing unit', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [a, Gap.lg(), b],
          ),
        ),
        theme: ThemeData(spacing: const Spacing(step: 5)),
      );
      expect(distance(tester, Axis.vertical), 20);
    });

    testWidgets('a step-count gap is unaffected by the form factor', (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [a, Gap(4), b, Gap.raw(7), c],
            ),
          ),
          formFactor: formFactor,
        );
        // Four 4px steps.
        expect(distance(tester, Axis.vertical), 16);
        expect(
          tester.getRect(find.byKey(const Key('c'))).top -
              tester.getRect(find.byKey(const Key('b'))).bottom,
          7,
        );
      }
      expect(const Gap(4).size, isNull);
      expect(const Gap.raw(7).size, isNull);
    });
  });

  group('FinesseColumn and FinesseRow gap', () {
    testWidgets('gap spaces the children by the named step, per form factor', (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        for (final size in GapSize.values) {
          await pumpFinesse(
            tester,
            Center(
              child: FinesseColumn(
                mainAxisSize: MainAxisSize.min,
                gap: size,
                children: const [a, b, c],
              ),
            ),
            formFactor: formFactor,
          );
          final expected = scale[formFactor]![size]!;
          expect(distance(tester, Axis.vertical), expected, reason: '$size');
          expect(
            tester.getSize(find.byType(FinesseColumn)).height,
            60 + expected * 2,
          );

          await pumpFinesse(
            tester,
            Center(
              child: FinesseRow(
                mainAxisSize: MainAxisSize.min,
                gap: size,
                children: const [a, b, c],
              ),
            ),
            formFactor: formFactor,
          );
          expect(distance(tester, Axis.horizontal), expected, reason: '$size');
          expect(
            tester.getSize(find.byType(FinesseRow)).width,
            60 + expected * 2,
          );
        }
      }
    });

    testWidgets('gap takes precedence over spacing', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: FinesseColumn(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            gap: GapSize.sm,
            children: [a, b],
          ),
        ),
      );
      expect(distance(tester, Axis.vertical), 8);
    });

    testWidgets('without a gap, spacing is still a step count', (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          const Center(
            child: FinesseColumn(
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [a, b],
            ),
          ),
          formFactor: formFactor,
        );
        expect(distance(tester, Axis.vertical), 12);
      }
    });

    testWidgets("a row's gap runs in reading order", (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: FinesseRow(
            mainAxisSize: MainAxisSize.min,
            gap: GapSize.xl,
            children: [a, b],
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      final first = tester.getRect(find.byKey(const Key('a')));
      final second = tester.getRect(find.byKey(const Key('b')));
      expect(first.left - second.right, 24);
    });

    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => const PageContainer(
          child: FinesseColumn(
            gap: GapSize.lg,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinesseRow(gap: GapSize.sm, children: [a, b, c]),
              Gap.xl(),
              FinesseRow(gap: GapSize.xl, children: [a, b]),
            ],
          ),
        ),
      );
    });

    testWidgets("a column's gap follows a resize across the breakpoint", (
      tester,
    ) async {
      const tree = Center(
        child: FinesseColumn(
          mainAxisSize: MainAxisSize.min,
          gap: GapSize.xl,
          children: [a, b],
        ),
      );
      await pumpFinesse(
        tester,
        tree,
        surfaceSize: const Size(1280, 800),
        pinFormFactor: false,
      );
      expect(distance(tester, Axis.vertical), 24);
      await pumpFinesse(
        tester,
        tree,
        surfaceSize: const Size(390, 844),
        pinFormFactor: false,
      );
      expect(distance(tester, Axis.vertical), 16);
    });
  });
}
