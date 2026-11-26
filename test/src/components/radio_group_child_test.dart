import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// `UnaRadioGroup(child:)`: the radios are laid out by the caller, and
/// the group only holds the selection.
void main() {
  testWidgets('a list section of radio tiles takes the width it is given', (
    tester,
  ) async {
    String? plan = 'free';
    await tester.pumpWidget(
      UnaApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 340,
            child: StatefulBuilder(
              builder: (context, setState) => UnaRadioGroup<String>(
                value: plan,
                onChanged: (value) => setState(() => plan = value),
                // In the wrap of `items:` a section had no width to fill.
                child: const ListSection(
                  children: [
                    RadioListTile(value: 'free', title: Text('Free')),
                    RadioListTile(value: 'pro', title: Text('Pro')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ListSection)).width, 340);
    expect(find.byType(Wrap), findsNothing);

    await tester.tap(find.text('Pro'));
    await tester.pumpAndSettle();
    expect(plan, 'pro');
  });

  testWidgets('radios anywhere under the child belong to the group', (
    tester,
  ) async {
    final seen = <int>[];
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: UnaRadioGroup<int>(
            initialValue: 1,
            onChanged: seen.add,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio(value: 1, label: Text('One')),
                SizedBox(width: 24),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Radio(value: 2, label: Text('Two')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // Side by side, as the row says.
    expect(
      tester.getCenter(find.text('One')).dy,
      closeTo(tester.getCenter(find.text('Two')).dy, 1),
    );
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(seen, [2]);
    final group = UnaRadioGroup.maybeOf<int>(
      tester.element(find.text('Two')),
    );
    expect(group?.value, 2);
  });

  testWidgets('a disabled group takes no tap', (tester) async {
    final seen = <int>[];
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: UnaRadioGroup<int>(
            initialValue: 1,
            enabled: false,
            onChanged: seen.add,
            child: const Radio(value: 2, label: Text('Two')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Two'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(seen, isEmpty);
  });

  testWidgets('the form field takes a child too', (tester) async {
    final formKey = GlobalKey<UnaFormState>();
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: SizedBox(
            width: 340,
            child: UnaForm(
              key: formKey,
              child: RadioGroupFormField<String>(
                id: 'plan',
                initialValue: 'free',
                child: const ListSection(
                  children: [
                    RadioListTile(value: 'free', title: Text('Free')),
                    RadioListTile(value: 'pro', title: Text('Pro')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Pro'));
    await tester.pumpAndSettle();
    expect(formKey.currentState!.value['plan'], 'pro');
  });

  test('items and child are one or the other', () {
    expect(UnaRadioGroup<int>.new, throwsA(isA<AssertionError>()));
    expect(
      () => UnaRadioGroup<int>(
        onChanged: (_) {},
        items: const [],
        child: const SizedBox(),
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
