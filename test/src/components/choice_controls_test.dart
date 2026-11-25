import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  group('Checkbox tristate', () {
    testWidgets('null is the mixed state: a filled box with a dash', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Checkbox(
            value: null,
            tristate: true,
            onChanged: (_) {},
            label: const Text('All'),
          ),
        ),
      );
      expect(find.byIcon(PhosphorIconsBold.minus), findsOneWidget);
      expect(
        tester.getSemantics(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.mixed != null,
          ),
        ),
        containsSemantics(isCheckStateMixed: true),
      );
      handle.dispose();
    });

    testWidgets('a tap on a mixed box checks it, then it toggles', (
      tester,
    ) async {
      bool? value;
      final reported = <bool>[];
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Checkbox(
              value: value,
              tristate: true,
              label: const Text('All'),
              onChanged: (v) {
                reported.add(v);
                setState(() => value = v);
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('All'));
      await settle(tester);
      await tester.tap(find.text('All'));
      await settle(tester);
      await tester.tap(find.text('All'));
      await settle(tester);
      expect(reported, [true, false, true]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the keyboard toggles it too', (tester) async {
      bool? value;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Checkbox(
              value: value,
              tristate: true,
              autofocus: true,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);
      expect(value, isTrue);
    });

    test('a two-state checkbox may not be null', () {
      expect(
        () => Checkbox(value: null, onChanged: (_) {}),
        throwsAssertionError,
      );
    });

    testWidgets('a two-state checkbox has no mixed semantics and no dash', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(child: Checkbox(value: true, onChanged: (_) {})),
      );
      expect(find.byIcon(PhosphorIconsBold.minus), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.mixed != null,
        ),
        findsNothing,
      );
    });
  });

  group('control affinity', () {
    for (final direction in TextDirection.values) {
      testWidgets('leading puts the control first, trailing last '
          '(${direction.name})', (tester) async {
        for (final affinity in ControlAffinity.values) {
          await pumpFinesse(
            tester,
            Center(
              child: Column(
                key: ValueKey(affinity),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    controlAffinity: affinity,
                    label: const Text('check'),
                    description: const Text('more'),
                  ),
                  Switch(
                    value: true,
                    onChanged: (_) {},
                    controlAffinity: affinity,
                    label: const Text('switch'),
                    description: const Text('more'),
                  ),
                  FinesseRadioGroup<int>(
                    initialValue: 1,
                    items: [
                      Radio(
                        value: 1,
                        controlAffinity: affinity,
                        label: const Text('radio'),
                        description: const Text('more'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            textDirection: direction,
          );
          final ltr = direction == TextDirection.ltr;
          final controlFirst = affinity == ControlAffinity.leading;
          for (final (type, label) in [
            (Checkbox, 'check'),
            (Switch, 'switch'),
            (Radio<int>, 'radio'),
          ]) {
            final whole = tester.getRect(find.byType(type));
            final text = tester.getRect(find.text(label));
            // The label hugs the far side from the control, and the gap is
            // on the control's side of it.
            final textAtRight = controlFirst == ltr;
            if (textAtRight) {
              expect(text.right, closeTo(whole.right, .5), reason: '$type');
              expect(text.left - whole.left, greaterThan(16), reason: '$type');
            } else {
              expect(text.left, closeTo(whole.left, .5), reason: '$type');
              expect(
                whole.right - text.right,
                greaterThan(16),
                reason: '$type',
              );
            }
          }
          expect(tester.takeException(), isNull);
        }
      });
    }
  });

  group('FinesseRadioGroup value', () {
    Widget group({
      int? value,
      int? initialValue,
      ValueChanged<int>? onChanged,
      bool enabled = true,
    }) => Center(
      child: FinesseRadioGroup<int>(
        value: value,
        initialValue: initialValue,
        onChanged: onChanged,
        enabled: enabled,
        items: const [
          Radio(value: 1, label: Text('one')),
          Radio(value: 2, label: Text('two')),
          Radio(value: 3, label: Text('three')),
        ],
      ),
    );

    bool checked(WidgetTester tester, String label) => tester
        .widget<Semantics>(
          find.descendant(
            of: find.ancestor(
              of: find.text(label),
              matching: find.byType(Radio<int>),
            ),
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.checked != null,
            ),
          ),
        )
        .properties
        .checked!;

    testWidgets('controlled: shows the value it is given and waits for it', (
      tester,
    ) async {
      final reported = <int>[];
      await pumpFinesse(tester, group(value: 1, onChanged: reported.add));
      expect(checked(tester, 'one'), isTrue);
      await tester.tap(find.text('two'));
      await settle(tester);
      expect(reported, [2]);
      // The parent did not take it.
      expect(checked(tester, 'one'), isTrue);
      expect(checked(tester, 'two'), isFalse);
      await pumpFinesse(tester, group(value: 3, onChanged: reported.add));
      expect(checked(tester, 'three'), isTrue);
      expect(reported, [2]);
    });

    testWidgets('uncontrolled: keeps its own value from initialValue', (
      tester,
    ) async {
      final reported = <int>[];
      await pumpFinesse(
        tester,
        group(initialValue: 1, onChanged: reported.add),
      );
      await tester.tap(find.text('two'));
      await settle(tester);
      expect(checked(tester, 'two'), isTrue);
      expect(checked(tester, 'one'), isFalse);
      expect(reported, [2]);
    });

    testWidgets('a disabled group reports nothing', (tester) async {
      final reported = <int>[];
      await pumpFinesse(
        tester,
        group(initialValue: 1, onChanged: reported.add, enabled: false),
      );
      await tester.tap(find.text('two'), warnIfMissed: false);
      await settle(tester);
      expect(reported, isEmpty);
    });

    testWidgets('maybeOf lets any widget be an option', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: FinesseRadioGroup<String>(
            initialValue: 'a',
            items: [
              for (final option in ['a', 'b'])
                Builder(
                  builder: (context) {
                    final scope = FinesseRadioGroup.maybeOf<String>(context)!;
                    return Chip(
                      label: Text('option $option'),
                      selected: scope.value == option,
                      onSelected: (_) => scope.select(option),
                    );
                  },
                ),
            ],
          ),
        ),
      );
      Chip chip(String option) =>
          tester.widget(find.widgetWithText(Chip, 'option $option'));
      expect(chip('a').selected, isTrue);
      await tester.tap(find.text('option b'));
      await settle(tester);
      expect(chip('b').selected, isTrue);
      expect(chip('a').selected, isFalse);
    });

    testWidgets('outside a group maybeOf is null', (tester) async {
      await pumpFinesse(
        tester,
        Builder(
          builder: (context) {
            expect(FinesseRadioGroup.maybeOf<int>(context), isNull);
            return const SizedBox();
          },
        ),
      );
    });
  });

  group('RadioGroupFormField', () {
    testWidgets('validates, saves and resets', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: RadioGroupFormField<String>(
              id: 'plan',
              validator: (v) => v == null ? 'Pick one' : null,
              items: const [
                Radio(value: 'free', label: Text('Free')),
                Radio(value: 'pro', label: Text('Pro')),
              ],
            ),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick one'), findsOneWidget);
      await tester.tap(find.text('Pro'));
      await settle(tester);
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(formKey.currentState!.value['plan'], 'pro');
      formKey.currentState!.reset();
      await settle(tester);
      expect(formKey.currentState!.validate(), isFalse);
    });
  });
}
