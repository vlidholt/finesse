import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

const _fruit = ['Apple', 'Banana', 'Blueberry', 'Cherry', 'Grape'];

List<Widget> _options() => [
  for (final fruit in _fruit) SelectOption(value: fruit, label: fruit),
];

/// The option that has the primary focus, by its label.
String? _focusedOption() => FocusManager.instance.primaryFocus?.context
    ?.findAncestorWidgetOfExactType<SelectOption<String>>()
    ?.label;

Future<void> _rest(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump();
  await tester.pump();
}

class _Host extends StatefulWidget {
  const _Host({this.initial, this.semanticLabel});

  final String? initial;
  final String? semanticLabel;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String? value = widget.initial;
  final trigger = FocusNode(debugLabel: 'trigger');

  @override
  void dispose() {
    trigger.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Select<String>(
      value: value,
      focusNode: trigger,
      placeholder: const Text('Fruit'),
      semanticLabel: widget.semanticLabel,
      options: _options(),
      onChanged: (next) => setState(() => value = next),
    ),
  );
}

void main() {
  _HostState host(WidgetTester tester) => tester.state(find.byType(_Host));

  SemanticsData triggerData(WidgetTester tester) => tester
      .getSemantics(
        find.descendant(
          of: find.byType(Select<String>),
          matching: find.byType(Focusable),
        ),
      )
      .getSemanticsData();

  group('Select semantics', () {
    testWidgets('the trigger is a button named by its placeholder, with the '
        'choice as its value and whether its list is open', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, const _Host());
      var data = triggerData(tester);
      expect(data.label, 'Fruit');
      expect(data.value, '');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isExpanded, Tristate.isFalse);
      expect(data.flagsCollection.isEnabled, Tristate.isTrue);

      await tester.tap(find.byType(Select<String>));
      await _rest(tester);
      data = triggerData(tester);
      expect(data.flagsCollection.isExpanded, Tristate.isTrue);

      await tester.tap(find.text('Cherry'));
      await _rest(tester);
      data = triggerData(tester);
      expect(data.label, 'Fruit');
      expect(data.value, 'Cherry');
      expect(data.flagsCollection.isExpanded, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('semanticLabel names it in place of the placeholder', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const _Host(initial: 'Apple', semanticLabel: 'Favourite fruit'),
      );
      final data = triggerData(tester);
      expect(data.label, 'Favourite fruit');
      expect(data.value, 'Apple');
      handle.dispose();
    });

    testWidgets('an option is a button, selected or not, one of a group', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, const _Host(initial: 'Banana'));
      await tester.tap(find.byType(Select<String>));
      await _rest(tester);
      SemanticsData option(String label) => tester
          .getSemantics(find.widgetWithText(SelectOption<String>, label))
          .getSemanticsData();
      final banana = option('Banana');
      expect(banana.label, 'Banana');
      expect(banana.flagsCollection.isButton, isTrue);
      expect(banana.flagsCollection.isSelected, Tristate.isTrue);
      expect(banana.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(option('Apple').flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets("a multiple select's options are not exclusive", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Center(
          child: Select<String>.multiple(
            initialValues: const {'Apple'},
            placeholder: const Text('Fruit'),
            options: _options(),
            onValuesChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byType(Select<String>));
      await _rest(tester);
      final apple = tester
          .getSemantics(find.widgetWithText(SelectOption<String>, 'Apple'))
          .getSemanticsData();
      expect(apple.flagsCollection.isSelected, Tristate.isTrue);
      expect(apple.flagsCollection.isInMutuallyExclusiveGroup, isFalse);
      handle.dispose();
    });
  });

  group('Select keyboard', () {
    testWidgets('the arrows open the list, the first option takes the focus '
        'with nothing selected, and Space chooses', (tester) async {
      await pumpUna(tester, const _Host());
      host(tester).trigger.requestFocus();
      await tester.pump();

      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _rest(tester);
      expect(find.text('Cherry'), findsOneWidget);
      expect(_focusedOption(), 'Apple');

      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_focusedOption(), 'Banana');
      await _key(tester, LogicalKeyboardKey.space);
      await _rest(tester);
      expect(host(tester).value, 'Banana');
      expect(find.text('Cherry'), findsNothing);
      expect(host(tester).trigger.hasPrimaryFocus, isTrue);

      // Up and Alt+Down open it as well; the selected option has the focus.
      await _key(tester, LogicalKeyboardKey.arrowUp);
      await _rest(tester);
      expect(_focusedOption(), 'Banana');
      await _key(tester, LogicalKeyboardKey.escape);
      await _rest(tester);
      expect(find.text('Cherry'), findsNothing);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await _rest(tester);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('Home and End go to the ends, and typing to the option it '
        'starts', (tester) async {
      await pumpUna(tester, const _Host());
      host(tester).trigger.requestFocus();
      await tester.pump();
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _rest(tester);
      expect(_focusedOption(), 'Apple');

      await _key(tester, LogicalKeyboardKey.end);
      expect(_focusedOption(), 'Grape');
      await _key(tester, LogicalKeyboardKey.home);
      expect(_focusedOption(), 'Apple');

      await _key(tester, LogicalKeyboardKey.keyC);
      expect(_focusedOption(), 'Cherry');
      await tester.pump(const Duration(seconds: 2));
      // The same letter again goes on to the next option it starts.
      await _key(tester, LogicalKeyboardKey.keyB);
      expect(_focusedOption(), 'Banana');
      await tester.pump(const Duration(seconds: 2));
      await _key(tester, LogicalKeyboardKey.keyB);
      expect(_focusedOption(), 'Blueberry');
      await tester.pump(const Duration(seconds: 2));
      // Letters typed in a row narrow the match.
      await _key(tester, LogicalKeyboardKey.keyB);
      expect(_focusedOption(), 'Banana');
      await _key(tester, LogicalKeyboardKey.keyL);
      expect(_focusedOption(), 'Blueberry');

      await _key(tester, LogicalKeyboardKey.enter);
      await _rest(tester);
      expect(host(tester).value, 'Blueberry');
    });
  });
}
