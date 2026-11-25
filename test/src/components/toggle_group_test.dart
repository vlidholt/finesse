import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ToggleGroup` as a controlled value control, and its form fields.
void main() {
  const items = [
    ToggleGroupItem(value: 'a', child: Text('A')),
    ToggleGroupItem(value: 'b', child: Text('B')),
    ToggleGroupItem(value: 'c', child: Text('C')),
  ];

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    FinesseApp(home: Center(child: child)),
  );

  /// The toggle labelled [label]. A disabled toggle absorbs pointers below
  /// it, so a tap aimed at its label would not reach anything: aim at the
  /// toggle itself, whose own region a tap still reaches.
  Finder toggle(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(Toggle));

  Set<String> selected(WidgetTester tester) => {
    for (final (index, toggle)
        in tester.widgetList<Toggle>(find.byType(Toggle)).indexed)
      if (toggle.value) items[index].value,
  };

  bool allEnabled(WidgetTester tester) => tester
      .widgetList<Toggle>(find.byType(Toggle))
      .every((toggle) => toggle.enabled && toggle.onChanged != null);

  group('controlled', () {
    testWidgets('a tap is reported and changes nothing until the parent '
        'passes the new values back', (tester) async {
      var values = {'a'};
      final reported = <Set<String>>[];
      late StateSetter rebuild;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return ToggleGroup<String>.multiple(
              values: values,
              onValuesChanged: reported.add,
              items: items,
            );
          },
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(reported, [
        {'a', 'b'},
      ]);
      expect(selected(tester), {'a'});

      rebuild(() => values = reported.last);
      await tester.pump();
      expect(selected(tester), {'a', 'b'});

      // The parent may also change them by itself.
      rebuild(() => values = {'c'});
      await tester.pump();
      expect(selected(tester), {'c'});
    });

    testWidgets('one at a time: a tap replaces, a tap on the selected one '
        'clears it unless that is not allowed', (tester) async {
      final reported = <String?>[];
      for (final allow in [true, false]) {
        reported.clear();
        await pump(
          tester,
          ToggleGroup<String>(
            value: 'a',
            allowDeselection: allow,
            onChanged: reported.add,
            items: items,
          ),
        );
        await tester.tap(find.text('B'));
        await tester.tap(find.text('A'));
        await tester.pump();
        expect(reported, ['b', if (allow) null]);
      }
    });

    testWidgets('several: the last one stays selected when deselection is '
        'not allowed', (tester) async {
      final reported = <Set<String>>[];
      await pump(
        tester,
        ToggleGroup<String>.multiple(
          values: const {'a'},
          allowDeselection: false,
          onValuesChanged: reported.add,
          items: items,
        ),
      );
      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(reported, [
        {'a', 'b'},
      ]);
    });

    testWidgets('a value taken away by the parent is an empty selection', (
      tester,
    ) async {
      String? value = 'a';
      late StateSetter rebuild;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return ToggleGroup<String>(
              value: value,
              onChanged: (_) {},
              items: items,
            );
          },
        ),
      );
      expect(selected(tester), {'a'});
      rebuild(() => value = null);
      await tester.pump();
      expect(selected(tester), isEmpty);
    });

    testWidgets('with no callback the group is disabled', (tester) async {
      await pump(tester, const ToggleGroup<String>(value: 'a', items: items));
      expect(allEnabled(tester), isFalse);
      await tester.tap(toggle('B'));
      await tester.pump();
      expect(selected(tester), {'a'});

      await pump(
        tester,
        const ToggleGroup<String>.multiple(values: {'a'}, items: items),
      );
      expect(allEnabled(tester), isFalse);

      await pump(
        tester,
        ToggleGroup<String>.multiple(
          values: const {'a'},
          onValuesChanged: (_) {},
          items: items,
        ),
      );
      expect(allEnabled(tester), isTrue);
    });
  });

  group('uncontrolled', () {
    testWidgets('initialValues starts a group that keeps its own selection', (
      tester,
    ) async {
      final reported = <Set<String>>[];
      await pump(
        tester,
        ToggleGroup<String>.multiple(
          initialValues: const {'b'},
          onValuesChanged: reported.add,
          items: items,
        ),
      );
      expect(selected(tester), {'b'});
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(selected(tester), {'b', 'c'});
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selected(tester), {'c'});
      expect(reported, [
        {'b', 'c'},
        {'c'},
      ]);
    });

    testWidgets('initialValue starts a single group that keeps its own', (
      tester,
    ) async {
      final reported = <String?>[];
      await pump(
        tester,
        ToggleGroup<String>(
          initialValue: 'b',
          onChanged: reported.add,
          items: items,
        ),
      );
      expect(selected(tester), {'b'});
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(selected(tester), {'c'});
      expect(reported, ['c']);
    });

    test('a value and an initial value together are refused', () {
      expect(
        () => ToggleGroup<String>(
          value: 'a',
          initialValue: 'a',
          items: items,
        ),
        throwsAssertionError,
      );
      expect(
        () => ToggleGroup<String>.multiple(
          values: const {'a'},
          initialValues: const {'a'},
          items: items,
        ),
        throwsAssertionError,
      );
    });

    testWidgets('a disabled group and a disabled item take no taps', (
      tester,
    ) async {
      final reported = <Set<String>>[];
      await pump(
        tester,
        ToggleGroup<String>.multiple(
          onValuesChanged: reported.add,
          items: const [
            ToggleGroupItem(value: 'a', child: Text('A')),
            ToggleGroupItem(value: 'b', enabled: false, child: Text('B')),
          ],
        ),
      );
      await tester.tap(toggle('B'));
      await tester.tap(toggle('A'));
      await tester.pump();
      expect(selected(tester), {'a'});
    });
  });

  group('ToggleGroupMultipleFormField', () {
    testWidgets('holds the selection for the form: validated, saved and '
        'reset with it', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      final changes = <Set<String>>[];
      await pump(
        tester,
        FinesseForm(
          key: formKey,
          child: ToggleGroupMultipleFormField<String>(
            id: 'days',
            label: const Text('Delivery days'),
            initialValue: const {'a'},
            onChanged: changes.add,
            validator: (days) => days.length < 2 ? 'Pick two days' : null,
            items: items,
          ),
        ),
      );
      expect(find.text('Delivery days'), findsOneWidget);
      expect(selected(tester), {'a'});
      expect(formKey.currentState!.saveAndValidate(), isFalse);
      await tester.pump();
      expect(find.text('Pick two days'), findsOneWidget);

      await tester.tap(find.text('C'));
      await tester.pump();
      expect(selected(tester), {'a', 'c'});
      expect(changes.last, {'a', 'c'});
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(formKey.currentState!.value['days'], {'a', 'c'});

      formKey.currentState!.reset();
      await tester.pump();
      expect(selected(tester), {'a'});
    });

    testWidgets('disabled, it takes no taps', (tester) async {
      await pump(
        tester,
        FinesseForm(
          child: ToggleGroupMultipleFormField<String>(
            id: 'size',
            enabled: false,
            initialValue: const {'a'},
            items: items,
          ),
        ),
      );
      await tester.tap(toggle('B'));
      await tester.pump();
      expect(selected(tester), {'a'});
    });
  });

  group('ToggleGroupFormField', () {
    testWidgets('holds one value: a tap replaces it, a second tap clears '
        'it, and a reset brings it back', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pump(
        tester,
        FinesseForm(
          key: formKey,
          child: ToggleGroupFormField<String>(
            id: 'size',
            initialValue: 'a',
            validator: (size) => size == null ? 'Pick a size' : null,
            items: items,
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selected(tester), {'b'});
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(formKey.currentState!.value['size'], 'b');

      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selected(tester), isEmpty);
      expect(formKey.currentState!.saveAndValidate(), isFalse);

      formKey.currentState!.reset();
      await tester.pump();
      expect(selected(tester), {'a'});
    });

    testWidgets('disabled, it takes no taps', (tester) async {
      await pump(
        tester,
        FinesseForm(
          child: ToggleGroupFormField<String>(
            id: 'size',
            enabled: false,
            initialValue: 'a',
            items: items,
          ),
        ),
      );
      await tester.tap(toggle('B'));
      await tester.pump();
      expect(selected(tester), {'a'});
    });
  });
}
