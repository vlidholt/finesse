import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A long select list scrolls as any list does: no arrows above and below
/// it that scroll it while hovered.
void main() {
  testWidgets('a long list has no scroll arrows, and scrolls', (tester) async {
    await pumpUna(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: Select<int>(
          onChanged: (_) {},
          placeholder: const Text('Pick'),
          options: [
            for (var i = 0; i < 60; i++)
              SelectOption(value: i, child: Text('Option $i')),
          ],
          selectedOptionBuilder: (context, value) => Text('$value'),
        ),
      ),
    );
    await tester.tap(find.text('Pick'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Option 0'), findsOneWidget);
    // The trigger's own caret is the only one.
    expect(find.byIcon(PhosphorIconsRegular.caretUp), findsNothing);
    expect(find.byIcon(PhosphorIconsRegular.caretDown), findsOneWidget);

    final list = find.ancestor(
      of: find.text('Option 0'),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(list.first).position;
    expect(position.maxScrollExtent, greaterThan(0));
    await tester.drag(find.text('Option 3'), const Offset(0, -200));
    await tester.pump();
    expect(position.pixels, greaterThan(0));
  });
}
