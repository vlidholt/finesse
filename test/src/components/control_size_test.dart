import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// `ControlSize.sm` draws a field-like control at a small button's height,
/// on every form factor, and a small number field keeps room for its value
/// between its two buttons.
void main() {
  for (final formFactor in FormFactor.values) {
    group('small, $formFactor', () {
      double smHeight(WidgetTester tester) => Theme.of(
        tester.element(find.byType(Center).first),
      ).buttonSizesTheme.sm!.height;

      testWidgets('a number field is a small button tall and shows its '
          'value between its buttons', (tester) async {
        await pumpUna(
          tester,
          Center(
            child: SizedBox(
              width: 120,
              child: NumberField(
                value: 36,
                size: ControlSize.sm,
                onChanged: (_) {},
              ),
            ),
          ),
          formFactor: formFactor,
        );
        final field = find.byType(NumberField);
        expect(tester.getSize(field).height, smHeight(tester));
        // The value has room: its editable box is wider than a few digits.
        final text = find.byType(EditableText);
        expect(tester.getSize(text).width, greaterThan(20));
        // Minus at the start, plus at the end, whatever the form factor.
        expect(
          find.byIcon(PhosphorIconsRegular.minus),
          findsOneWidget,
        );
        expect(find.byIcon(PhosphorIconsRegular.plus), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('a select and a segmented control are a small button tall', (
        tester,
      ) async {
        await pumpUna(
          tester,
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 140,
                  child: Select<int>(
                    value: 1,
                    size: ControlSize.sm,
                    onChanged: (_) {},
                    options: const [
                      SelectOption(value: 1, label: 'One'),
                      SelectOption(value: 2, label: 'Two'),
                    ],
                  ),
                ),
                SegmentedControl<int>(
                  value: 1,
                  size: ControlSize.sm,
                  onChanged: (_) {},
                  segments: const [
                    Segment(value: 1, label: Text('A')),
                    Segment(value: 2, label: Text('B')),
                  ],
                ),
              ],
            ),
          ),
          formFactor: formFactor,
        );
        final h = smHeight(tester);
        expect(tester.getSize(find.byType(Select<int>)).height, h);
        expect(
          tester.getSize(find.byType(SegmentedControl<int>)).height,
          closeTo(h, 1),
        );
        expect(tester.takeException(), isNull);
      });
    });
  }
}
