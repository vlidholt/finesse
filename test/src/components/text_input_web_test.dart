// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  // The web's default shortcuts scroll with the arrow keys and leave text
  // editing keys to the browser. The lists under a field and the number
  // field hear their keys on the focus chain instead, which has to hold in
  // a real browser.
  testWidgets("the arrow keys walk an autocomplete's options in the "
      'browser, and Enter takes one', (tester) async {
    String? selected;
    await tester.pumpWidget(
      FinesseApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: Autocomplete<String>(
              optionsBuilder: (value) => value.text.isEmpty
                  ? const <String>[]
                  : const ['Apple', 'Apricot', 'Avocado'],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'a');
    await _settle(tester);
    expect(find.text('Apricot'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await _settle(tester);
    expect(selected, 'Apricot');
  });

  testWidgets('the arrow keys step a number field in the browser', (
    tester,
  ) async {
    num? value = 5;
    await tester.pumpWidget(
      FinesseApp(
        home: Center(
          child: SizedBox(
            width: 200,
            child: StatefulBuilder(
              builder: (context, setState) => NumberField(
                value: value,
                min: 0,
                max: 10,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(value, 6);
  });

  testWidgets('the selection toolbar lays out, pages and paints in the '
      'browser', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var pressed = 0;
    await tester.pumpWidget(
      FinesseApp(
        home: TextSelectionToolbar(
          anchorAbove: const Offset(160, 200),
          anchorBelow: const Offset(160, 220),
          children: [
            for (var i = 0; i < 8; i++)
              TextSelectionToolbarButton(
                onPressed: () => pressed++,
                child: Text('Action $i'),
              ),
          ],
        ),
      ),
    );
    await _settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Action 0').hitTestable(), findsOneWidget);
    expect(find.text('Action 7').hitTestable(), findsNothing);
    await tester.tap(find.text('Action 0'));
    expect(pressed, 1);

    final more = find.bySemanticsLabel('More');
    for (var i = 0; i < 8 && more.hitTestable().evaluate().isNotEmpty; i++) {
      await tester.tap(more.hitTestable());
      await tester.pump();
    }
    expect(find.text('Action 7').hitTestable(), findsOneWidget);
  });

  testWidgets('a search view opens, searches and closes on Escape in the '
      'browser', (tester) async {
    await tester.pumpWidget(
      FinesseApp(
        formFactor: FormFactor.desktop,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Button(
                onPressed: () => showSearch<String>(
                  context: context,
                  debounce: Duration.zero,
                  builder: (context, query, close) => Text('Query: $query'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await _settle(tester);
    await tester.enterText(find.byType(SearchField), 'teal');
    await _settle(tester);
    expect(find.text('Query: teal'), findsOneWidget);

    // The first Escape clears the query, the second closes the view.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.text('Query: '), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.byType(SearchField), findsNothing);
  });
}
