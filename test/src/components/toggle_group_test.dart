import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ToggleGroup` as a controlled value control, and its form field.
void main() {
  const items = [
    ToggleGroupItem(value: 'a', child: Text('A')),
    ToggleGroupItem(value: 'b', child: Text('B')),
    ToggleGroupItem(value: 'c', child: Text('C')),
  ];

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    FinesseApp(home: Center(child: child)),
  );

  Set<String> selected(WidgetTester tester) => {
    for (final (index, toggle)
        in tester.widgetList<Toggle>(find.byType(Toggle)).indexed)
      if (toggle.value) items[index].value,
  };

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
              onChanged: reported.add,
              children: items,
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
      final reported = <Set<String>>[];
      for (final allow in [true, false]) {
        reported.clear();
        await pump(
          tester,
          ToggleGroup<String>(
            values: const {'a'},
            allowDeselection: allow,
            onChanged: reported.add,
            children: items,
          ),
        );
        await tester.tap(find.text('B'));
        await tester.tap(find.text('A'));
        await tester.pump();
        expect(reported, [
          {'b'},
          if (allow) <String>{},
        ]);
      }
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
          onChanged: reported.add,
          children: items,
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

    test('values and initialValues together are refused', () {
      expect(
        () => ToggleGroup<String>(
          values: const {'a'},
          initialValues: const {'a'},
          children: items,
        ),
        throwsAssertionError,
      );
      expect(
        () => ToggleGroup<String>(
          initialValues: const {'a', 'b'},
          children: items,
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
          onChanged: reported.add,
          children: const [
            ToggleGroupItem(value: 'a', child: Text('A')),
            ToggleGroupItem(value: 'b', enabled: false, child: Text('B')),
          ],
        ),
      );
      await tester.tap(find.text('B'));
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(reported, [
        {'a'},
      ]);
    });
  });

  group('ToggleGroupFormField', () {
    testWidgets('holds the selection for the form: validated, saved and '
        'reset with it', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      final changes = <Set<String>>[];
      await pump(
        tester,
        FinesseForm(
          key: formKey,
          child: ToggleGroupFormField<String>(
            id: 'days',
            label: const Text('Delivery days'),
            multiple: true,
            initialValue: const {'a'},
            onChanged: changes.add,
            validator: (days) => days.length < 2 ? 'Pick two days' : null,
            children: items,
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

    testWidgets('one at a time by default', (tester) async {
      await pump(
        tester,
        FinesseForm(
          child: ToggleGroupFormField<String>(
            id: 'size',
            initialValue: const {'a'},
            children: items,
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selected(tester), {'b'});
    });

    testWidgets('disabled, it takes no taps', (tester) async {
      await pump(
        tester,
        FinesseForm(
          child: ToggleGroupFormField<String>(
            id: 'size',
            enabled: false,
            initialValue: const {'a'},
            children: items,
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selected(tester), {'a'});
    });
  });

  group('ToggleGroup', () {
    Widget wrap(Widget child) => FinesseApp(home: Center(child: child));

    testWidgets('single variant replaces the selection', (tester) async {
      Set<String>? latest;
      await tester.pumpWidget(
        wrap(
          ToggleGroup<String>(
            values: const {'a'},
            onChanged: (v) => latest = v,
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(latest, {'b'});
    });

    testWidgets('single variant deselects on re-tap', (tester) async {
      Set<String>? latest;
      await tester.pumpWidget(
        wrap(
          ToggleGroup<String>(
            values: const {'a'},
            onChanged: (v) => latest = v,
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();
      expect(latest, isEmpty);
    });

    testWidgets('multiple variant accumulates', (tester) async {
      Set<String>? latest;
      await tester.pumpWidget(
        wrap(
          ToggleGroup<String>.multiple(
            values: const {'a'},
            onChanged: (v) => latest = v,
            children: const [
              ToggleGroupItem(value: 'a', child: Text('A')),
              ToggleGroupItem(value: 'b', child: Text('B')),
            ],
          ),
        ),
      );

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(latest, {'a', 'b'});
    });
  });
}
