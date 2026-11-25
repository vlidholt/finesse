import 'package:finesse/finesse.dart' hide Scaffold;
import 'package:finesse/material.dart';
import 'package:finesse/src/components/select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(body: child),
    );
  }

  group('Select', () {
    testWidgets('Select matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Select<String>(
            onChanged: (_) {},
            placeholder: const Text('Select a fruit'),
            options: [
              const Padding(
                padding: EdgeInsets.fromLTRB(32, 6, 6, 6),
                child: Text(
                  'Fruits',
                ),
              ),
              ...['apple', 'banana', 'watermelon'].map(
                (fruit) => SelectOption(
                  value: fruit,
                  child: Text(fruit),
                ),
              ),
            ],
            selectedOptionBuilder: (context, value) => Text(value),
          ),
        ),
      );

      await expectLater(
        find.byType(Select<String>),
        matchesGoldenFile('goldens/select.png'),
      );
    });

    testWidgets('with no callback it is disabled, and onTap enables it', (
      tester,
    ) async {
      for (final multiple in [false, true]) {
        await tester.pumpWidget(
          createTestWidget(
            multiple
                ? const Select<String>.multiple(
                    placeholder: Text('Fruit'),
                    options: [
                      SelectOption(value: 'apple', child: Text('Apple')),
                    ],
                  )
                : const Select<String>(
                    placeholder: Text('Fruit'),
                    options: [
                      SelectOption(value: 'apple', child: Text('Apple')),
                    ],
                  ),
          ),
        );
        await tester.tap(find.text('Fruit'), warnIfMissed: false);
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Apple'), findsNothing);
      }

      var tapped = 0;
      await tester.pumpWidget(
        createTestWidget(
          Select<String>(
            placeholder: const Text('Fruit'),
            onTap: () => tapped++,
            options: const [SelectOption(value: 'apple', child: Text('Apple'))],
          ),
        ),
      );
      await tester.tap(find.text('Fruit'));
      await tester.pump();
      expect(tapped, 1);
    });
  });

  group('SelectMultipleFormField', () {
    /// Returns an iterable of [SelectOption] widgets for the given [fruits].
    Iterable<Widget> fruitOptions(List<String> fruits) {
      return fruits.map((f) => SelectOption<String>(value: f, child: Text(f)));
    }

    testWidgets('onChanged fires on the first selection', (tester) async {
      final changes = <Set<String>?>[];

      await tester.pumpWidget(
        createTestWidget(
          SelectMultipleFormField<String>(
            onChanged: changes.add,
            placeholder: const Text('Select fruits'),
            selectedOptionsBuilder: (context, values) =>
                Text(values.join(', ')),
            options: fruitOptions(['apple', 'banana', 'cherry']),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final selectState = tester.state<SelectState<String>>(
        find.byType(Select<String>),
      );

      selectState.select('apple');
      await tester.pumpAndSettle();

      expect(changes, hasLength(1));
      expect(changes.last, {'apple'});
    });

    testWidgets(
      'onChanged fires on every subsequent selection (regression)',
      (tester) async {
        final changes = <Set<String>?>[];

        await tester.pumpWidget(
          createTestWidget(
            SelectMultipleFormField<String>(
              onChanged: changes.add,
              placeholder: const Text('Select fruits'),
              selectedOptionsBuilder: (context, values) =>
                  Text(values.join(', ')),
              options: fruitOptions(['apple', 'banana', 'cherry']),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final selectState = tester.state<SelectState<String>>(
          find.byType(Select<String>),
        );

        selectState.select('apple');
        await tester.pumpAndSettle();
        expect(changes, hasLength(1));
        expect(changes.last, {'apple'});

        // Before the fix this second call was silently ignored because
        // controller.value and form-field value pointed to the same Set.
        selectState.select('banana');
        await tester.pumpAndSettle();
        expect(changes, hasLength(2));
        expect(changes.last, {'apple', 'banana'});

        selectState.select('cherry');
        await tester.pumpAndSettle();
        expect(changes, hasLength(3));
        expect(changes.last, {'apple', 'banana', 'cherry'});
      },
    );

    testWidgets('onChanged fires correctly when deselecting', (tester) async {
      final changes = <Set<String>?>[];

      await tester.pumpWidget(
        createTestWidget(
          SelectMultipleFormField<String>(
            onChanged: changes.add,
            placeholder: const Text('Select fruits'),
            selectedOptionsBuilder: (context, values) =>
                Text(values.join(', ')),
            options: fruitOptions(['apple', 'banana']),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final selectState = tester.state<SelectState<String>>(
        find.byType(Select<String>),
      );

      selectState.select('apple');
      await tester.pumpAndSettle();
      expect(changes.last, {'apple'});

      selectState.select('banana');
      await tester.pumpAndSettle();
      expect(changes.last, {'apple', 'banana'});

      // Deselect apple.
      selectState.select('apple');
      await tester.pumpAndSettle();
      expect(changes, hasLength(3));
      expect(changes.last, {'banana'});
    });

    testWidgets(
      'form value reflects every selection',
      (tester) async {
        final formKey = GlobalKey<FinesseFormState>();

        await tester.pumpWidget(
          createTestWidget(
            FinesseForm(
              key: formKey,
              child: SelectMultipleFormField<String>(
                id: 'fruits',
                placeholder: const Text('Select fruits'),
                selectedOptionsBuilder: (context, values) =>
                    Text(values.join(', ')),
                options: fruitOptions(['apple', 'banana', 'cherry']),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final selectState = tester.state<SelectState<String>>(
          find.byType(Select<String>),
        );

        selectState.select('apple');
        await tester.pumpAndSettle();
        expect(formKey.currentState!.value['fruits'], {'apple'});

        selectState.select('banana');
        await tester.pumpAndSettle();
        expect(formKey.currentState!.value['fruits'], {'apple', 'banana'});
      },
    );
  });
}
