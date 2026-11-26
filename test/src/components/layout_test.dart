import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  Widget wrap(Widget child, {Spacing spacing = const Spacing()}) {
    return Theme(
      data: ThemeData(spacing: spacing),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );
  }

  group('Gap', () {
    testWidgets('sizes along the axis of the enclosing flex', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox.square(dimension: 10), Gap(4)],
          ),
        ),
      );

      final size = tester.getSize(find.byType(Gap));
      expect(size.height, 16);
      expect(size.width, 0);
    });

    testWidgets('turns horizontal inside a Row', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox.square(dimension: 10), Gap(4)],
          ),
        ),
      );

      final size = tester.getSize(find.byType(Gap));
      expect(size.width, 16);
      expect(size.height, 0);
    });

    testWidgets('follows the theme spacing step', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox.square(dimension: 10), Gap(4)],
          ),
          spacing: const Spacing(step: 2),
        ),
      );

      expect(tester.getSize(find.byType(Gap)).height, 8);
    });

    testWidgets('raw bypasses the scale', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox.square(dimension: 10), Gap.raw(7)],
          ),
        ),
      );

      expect(tester.getSize(find.byType(Gap)).height, 7);
    });

    testWidgets('takes cross-axis space when asked', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Gap(4, crossAxisSteps: 5)],
          ),
        ),
      );

      final size = tester.getSize(find.byType(Gap));
      expect(size.height, 16);
      expect(size.width, 20);
    });

    testWidgets('outside a flex it is square', (tester) async {
      await tester.pumpWidget(wrap(const Gap(4)));
      expect(tester.getSize(find.byType(Gap)), const Size(16, 16));
    });

    testWidgets('resizes when the step changes', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox.square(dimension: 10), Gap(4)],
          ),
        ),
      );
      expect(tester.getSize(find.byType(Gap)).height, 16);

      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox.square(dimension: 10), Gap(4)],
          ),
          spacing: const Spacing(step: 10),
        ),
      );
      expect(tester.getSize(find.byType(Gap)).height, 40);
    });
  });

  group('UnaPadding', () {
    testWidgets('all, symmetric and only are measured in steps', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UnaPadding.all(6, child: SizedBox.shrink()),
              UnaPadding.symmetric(
                horizontal: 4,
                vertical: 2,
                child: SizedBox.shrink(),
              ),
              UnaPadding.only(top: 3, child: SizedBox.shrink()),
            ],
          ),
        ),
      );

      final paddings = tester
          .widgetList<Padding>(find.byType(Padding))
          .map((p) => p.padding)
          .toList();

      expect(paddings, contains(const EdgeInsets.all(24)));
      expect(
        paddings,
        contains(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      );
      expect(paddings, contains(const EdgeInsets.only(top: 12)));
    });

    testWidgets('directional resolves against the text direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const UnaPadding.directional(
            start: 5,
            child: SizedBox.shrink(),
          ),
        ),
      );

      expect(
        tester.widgetList<Padding>(find.byType(Padding)).map((p) => p.padding),
        contains(const EdgeInsetsDirectional.only(start: 20)),
      );
    });
  });

  group('UnaColumn / UnaRow', () {
    testWidgets('spacing is expressed in steps', (tester) async {
      await tester.pumpWidget(
        wrap(
          const UnaColumn(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              SizedBox.square(dimension: 10),
              SizedBox.square(dimension: 10),
            ],
          ),
        ),
      );

      // Two 10px children plus one 16px gap.
      expect(tester.getSize(find.byType(UnaColumn)).height, 36);
    });

    testWidgets('UnaRow spaces horizontally', (tester) async {
      await tester.pumpWidget(
        wrap(
          const UnaRow(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              SizedBox.square(dimension: 10),
              SizedBox.square(dimension: 10),
            ],
          ),
        ),
      );

      expect(tester.getSize(find.byType(UnaRow)).width, 28);
    });
  });
}
