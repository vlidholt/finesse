import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  testWidgets('a trailing header action does not toggle the item', (
    tester,
  ) async {
    var resets = 0;
    await tester.pumpWidget(
      UnaApp(
        home: Accordion<int>(
          children: [
            AccordionItem(
              value: 1,
              title: const Text('Axes'),
              trailing: Button.link(
                onPressed: () => resets++,
                child: const Text('Reset'),
              ),
              child: const Text('body'),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(resets, 1);
    expect(find.text('body'), findsNothing);

    await tester.tap(find.text('Axes'));
    await tester.pumpAndSettle();
    expect(find.text('body'), findsOneWidget);
  });
}
