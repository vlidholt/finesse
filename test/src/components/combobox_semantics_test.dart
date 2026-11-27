import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../announcements.dart';
import '../../una_harness.dart';

/// A field with a list under it keeps the focus while the arrows walk the
/// list, so it says which option they reached, and its node says whether
/// the list is showing.
void main() {
  const fruits = ['Apple', 'Apricot', 'Avocado', 'Banana'];

  Iterable<String> filter(TextEditingValue value) {
    final query = value.text.toLowerCase();
    if (query.isEmpty) return const [];
    return fruits.where((fruit) => fruit.toLowerCase().startsWith(query));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  SemanticsData fieldData(WidgetTester tester) =>
      tester.getSemantics(find.byType(EditableText)).getSemanticsData();

  testWidgets('Autocomplete says the highlighted option and is expanded '
      'while its list shows', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 300,
          child: Autocomplete<String>(
            semanticLabel: 'Fruit',
            optionsBuilder: filter,
          ),
        ),
      ),
    );
    expect(fieldData(tester).flagsCollection.isExpanded, Tristate.isFalse);

    await tester.enterText(find.byType(EditableText), 'a');
    await settle(tester);
    expect(fieldData(tester).flagsCollection.isExpanded, Tristate.isTrue);

    final said = captureAnnouncements(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(said.map((a) => a.message), [
      'Apple, 1 of 3',
      'Apricot, 2 of 3',
      'Apple, 1 of 3',
    ]);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(fieldData(tester).flagsCollection.isExpanded, Tristate.isFalse);
    handle.dispose();
  });

  testWidgets('TagField says the highlighted suggestion and is expanded '
      'while its list shows', (tester) async {
    final handle = tester.ensureSemantics();
    var values = <String>[];
    await pumpUna(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 300,
          child: StatefulBuilder(
            builder: (context, setState) => TagField<String>(
              values: values,
              semanticLabel: 'Fruit',
              labelBuilder: (context, tag) => Text(tag),
              optionsBuilder: filter,
              onChanged: (next) => setState(() => values = next),
            ),
          ),
        ),
      ),
    );
    expect(fieldData(tester).flagsCollection.isExpanded, Tristate.isFalse);
    expect(fieldData(tester).label, 'Fruit');

    await tester.enterText(find.byType(EditableText), 'av');
    await settle(tester);
    expect(fieldData(tester).flagsCollection.isExpanded, Tristate.isTrue);

    final said = captureAnnouncements(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(said.map((a) => a.message), ['Avocado, 1 of 1']);
    handle.dispose();
  });

  testWidgets('a TagField with no suggestions has no expanded state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      Center(
        child: SizedBox(
          width: 300,
          child: TagField<String>(
            values: const [],
            labelBuilder: (context, tag) => Text(tag),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(fieldData(tester).flagsCollection.isExpanded, Tristate.none);
    handle.dispose();
  });
}
