import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

const _invisible = '​';

const _slots = [
  OtpFieldGroup(
    children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
  ),
  OtpFieldGroup(
    children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
  ),
];

Finder _slot(int index) => find.descendant(
  of: find.byType(OtpFieldSlot).at(index),
  matching: find.byType(EditableText),
);

EditableText _editable(WidgetTester tester, int index) =>
    tester.widget<EditableText>(_slot(index));

/// What the six slots show, a space for an empty one.
String _shown(WidgetTester tester) => [
  for (var i = 0; i < 6; i++)
    _editable(tester, i).controller.text.replaceAll(_invisible, ' '),
].join();

/// The index of the slot that has the focus, or -1.
int _focused(WidgetTester tester) => [
  for (var i = 0; i < 6; i++) _editable(tester, i).focusNode.hasFocus,
].indexOf(true);

/// What a key press in slot [index] leaves in its text field: the platform
/// sends the whole new text of the slot.
Future<void> _type(WidgetTester tester, int index, String text) async {
  await tester.enterText(_slot(index), text);
  await tester.pump();
  await tester.pump();
}

void main() {
  group('OtpField, uncontrolled', () {
    testWidgets('starts from initialValue; a space skips a slot', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(
          child: OtpField(maxLength: 6, initialValue: '12 4', children: _slots),
        ),
      );
      expect(_shown(tester), '12 4  ');
    });

    testWidgets('typing fills slot after slot and reports each change', (
      tester,
    ) async {
      final changes = <String>[];
      final completed = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            onChanged: changes.add,
            onCompleted: completed.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(0));
      await tester.pump();
      expect(_focused(tester), 0);
      for (var i = 0; i < 6; i++) {
        // Each key lands in the slot the focus moved to.
        expect(_focused(tester), i);
        await _type(tester, i, '$_invisible${i + 1}');
      }
      expect(_shown(tester), '123456');
      expect(changes, [
        '1     ',
        '12    ',
        '123   ',
        '1234  ',
        '12345 ',
        '123456',
      ]);
      expect(completed, ['123456']);
      // The last slot keeps the focus.
      expect(_focused(tester), 5);
    });

    testWidgets('backspace empties a slot, then steps back through the rest', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            initialValue: '123',
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(2));
      await tester.pump();
      // Backspace in a filled slot empties it and steps back.
      await _type(tester, 2, '');
      expect(_shown(tester), '12    ');
      expect(_focused(tester), 1);
      // The slot now focused is filled: backspace empties it.
      await _type(tester, 1, '');
      expect(_shown(tester), '1     ');
      expect(_focused(tester), 0);
      expect(changes, ['12    ', '1     ']);

      // Backspace in an *empty* slot empties the one before it too.
      await tester.tap(_slot(3));
      await tester.pump();
      await _type(tester, 3, '7');
      expect(_shown(tester), '1  7  ');
      await tester.tap(_slot(2));
      await tester.pump();
      await _type(tester, 2, '');
      expect(_focused(tester), 1);
      await _type(tester, 1, '');
      expect(_shown(tester), '   7  ');
      expect(_focused(tester), 0);
    });

    testWidgets('a key in a filled slot replaces its character', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            initialValue: '123',
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      // After the character the slot held…
      await tester.tap(_slot(0));
      await tester.pump();
      await _type(tester, 0, '19');
      expect(_shown(tester), '923   ');
      expect(_focused(tester), 1);
      // …or before it.
      await _type(tester, 1, '82');
      expect(_shown(tester), '983   ');
      expect(_focused(tester), 2);
      expect(changes, ['923   ', '983   ']);
    });

    testWidgets('a pasted code is spread over the slots and reported once', (
      tester,
    ) async {
      final changes = <String>[];
      final completed = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            onChanged: changes.add,
            onCompleted: completed.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(0));
      await tester.pump();
      await _type(tester, 0, '${_invisible}482913');
      expect(_shown(tester), '482913');
      expect(changes, ['482913']);
      expect(completed, ['482913']);
      expect(_focused(tester), 5);
    });

    testWidgets('a whole code pasted into a later slot starts at the first', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(3));
      await tester.pump();
      await _type(tester, 3, '${_invisible}482913');
      expect(_shown(tester), '482913');
      expect(changes, ['482913']);
    });

    testWidgets('a shorter paste fills from the slot it was put in', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            initialValue: '12',
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(2));
      await tester.pump();
      await _type(tester, 2, '${_invisible}345');
      expect(_shown(tester), '12345 ');
      expect(changes, ['12345 ']);
      expect(_focused(tester), 4);

      // Past the last slot the rest is dropped, not thrown on.
      await tester.tap(_slot(4));
      await tester.pump();
      await _type(tester, 4, '5678');
      expect(_shown(tester), '123467');
      expect(tester.takeException(), isNull);
    });

    testWidgets('the platform may fill in a one-time code', (tester) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        expect(_editable(tester, i).autofillHints, [
          AutofillHints.oneTimeCode,
        ]);
      }
      // Autofill replaces the text of the focused field with the code.
      await tester.tap(_slot(0));
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '733105',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(_shown(tester), '733105');
      expect(changes, ['733105']);

      await pumpUna(
        tester,
        const Center(
          child: OtpField(maxLength: 6, autofillHints: [], children: _slots),
        ),
      );
      expect(_editable(tester, 0).autofillHints, isEmpty);
    });

    testWidgets('input formatters still refuse a character', (tester) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(0));
      await tester.pump();
      await _type(tester, 0, '${_invisible}a');
      expect(_shown(tester), '      ');
      expect(_focused(tester), 0);
      await _type(tester, 0, '${_invisible}4');
      expect(_shown(tester), '4     ');
      expect(changes, ['4     ']);
    });

    testWidgets('right to left: the code still reads left to right', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(
          child: OtpField(maxLength: 6, initialValue: '123', children: _slots),
        ),
        textDirection: TextDirection.rtl,
      );
      for (var i = 0; i < 5; i++) {
        expect(
          tester.getCenter(_slot(i)).dx,
          lessThan(tester.getCenter(_slot(i + 1)).dx),
        );
      }
      await tester.tap(_slot(3));
      await tester.pump();
      await _type(tester, 3, '${_invisible}4');
      expect(_shown(tester), '1234  ');
      expect(_focused(tester), 4);
      // The arrows follow the slots, not the text direction.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_focused(tester), 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_focused(tester), 4);
    });
  });

  group('OtpField, controlled', () {
    testWidgets('shows the value it is given, padded or not', (tester) async {
      await pumpUna(
        tester,
        const Center(
          child: OtpField(maxLength: 6, value: '12', children: _slots),
        ),
      );
      expect(_shown(tester), '12    ');
      await pumpUna(
        tester,
        const Center(
          child: OtpField(maxLength: 6, value: '1 3   ', children: _slots),
        ),
      );
      expect(_shown(tester), '1 3   ');
      // More than fits is cut, not thrown on.
      await pumpUna(
        tester,
        const Center(
          child: OtpField(maxLength: 6, value: '123456789', children: _slots),
        ),
      );
      expect(_shown(tester), '123456');
    });

    testWidgets('an accepted edit stays, and is reported once', (tester) async {
      var code = '';
      final changes = <String>[];
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: OtpField(
              maxLength: 6,
              value: code,
              onChanged: (value) {
                changes.add(value);
                setState(() => code = value);
              },
              children: _slots,
            ),
          ),
        ),
      );
      await tester.tap(_slot(0));
      await tester.pump();
      await _type(tester, 0, '${_invisible}7');
      await _type(tester, 1, '${_invisible}8');
      expect(_shown(tester), '78    ');
      expect(code, '78    ');
      expect(changes, ['7     ', '78    ']);
      expect(_focused(tester), 2);
    });

    testWidgets('a refused edit is taken back', (tester) async {
      final changes = <String>[];
      await pumpUna(
        tester,
        Center(
          child: OtpField(
            maxLength: 6,
            value: '12',
            // Reported, never applied.
            onChanged: changes.add,
            children: _slots,
          ),
        ),
      );
      await tester.tap(_slot(2));
      await tester.pump();
      await _type(tester, 2, '${_invisible}3');
      expect(changes, ['123   ']);
      expect(_shown(tester), '12    ');

      // And a refused paste.
      await _type(tester, 0, '1482913');
      expect(changes.last, '482913');
      expect(_shown(tester), '12    ');
    });

    testWidgets('a value from outside is shown and not reported', (
      tester,
    ) async {
      var code = '123456';
      final changes = <String>[];
      late StateSetter rebuild;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Center(
              child: OtpField(
                maxLength: 6,
                value: code,
                onChanged: (value) {
                  changes.add(value);
                  setState(() => code = value);
                },
                children: _slots,
              ),
            );
          },
        ),
      );
      expect(_shown(tester), '123456');

      // Cleared after a wrong code, say.
      rebuild(() => code = '');
      await tester.pump();
      await tester.pump();
      expect(_shown(tester), '      ');

      rebuild(() => code = '90');
      await tester.pump();
      await tester.pump();
      expect(_shown(tester), '90    ');
      expect(changes, isEmpty);
      expect(tester.takeException(), isNull);

      // Typing goes on from what was set.
      await tester.tap(_slot(2));
      await tester.pump();
      await _type(tester, 2, '${_invisible}1');
      expect(_shown(tester), '901   ');
      expect(changes, ['901   ']);
    });

    testWidgets('value and initialValue together are refused', (tester) async {
      expect(
        () => OtpField(
          maxLength: 6,
          value: '1',
          initialValue: '2',
          children: _slots,
        ),
        throwsAssertionError,
      );
    });
  });

  group('OtpFormField', () {
    testWidgets('holds the value: validates, saves, resets and is set', (
      tester,
    ) async {
      final formKey = GlobalKey<UnaFormState>();
      String? saved;
      await pumpUna(
        tester,
        Center(
          child: UnaForm(
            key: formKey,
            child: OtpFormField(
              id: 'code',
              maxLength: 6,
              initialValue: '12',
              validator: (value) =>
                  value.contains(' ') ? 'Enter all six digits.' : null,
              onSaved: (value) => saved = value,
              children: _slots,
            ),
          ),
        ),
      );
      expect(_shown(tester), '12    ');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter all six digits.'), findsOneWidget);

      await tester.tap(_slot(2));
      await tester.pump();
      await _type(tester, 2, '${_invisible}3456');
      expect(_shown(tester), '123456');
      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      expect(saved, '123456');

      // A reset goes back to the initial value, in the slots too.
      formKey.currentState!.reset();
      await tester.pump();
      await tester.pump();
      expect(_shown(tester), '12    ');

      // A value set through the form reaches the slots.
      formKey.currentState!.fields['code']!.didChange('654321');
      await tester.pump();
      await tester.pump();
      expect(_shown(tester), '654321');
      expect(tester.takeException(), isNull);
    });
  });
}
