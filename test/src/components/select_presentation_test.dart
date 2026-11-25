import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

const _fruit = ['Apple', 'Banana', 'Cherry', 'Grape'];

List<Widget> _options() => [
  for (final fruit in _fruit) SelectOption(value: fruit, label: fruit),
];

void main() {
  Future<void> rest(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(Select<String>));
    await rest(tester);
  }

  /// The row of [fruit] in the open list.
  Finder optionOf(String fruit) => find.widgetWithText(
    SelectOption<String>,
    fruit,
  );

  group('Select value', () {
    testWidgets('the trigger shows the label of the selected option', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>(
            initialValue: 'Cherry',
            placeholder: const Text('A fruit'),
            options: _options(),
          ),
        ),
      );
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.text('A fruit'), findsNothing);
    });

    testWidgets('a value with no label is written as it is', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: Select<int>(
            initialValue: 7,
            placeholder: Text('A number'),
            options: [SelectOption(value: 7, child: Text('Seven'))],
          ),
        ),
      );
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('a multiple select lists the labels', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>.multiple(
            initialValues: const {'Apple', 'Grape'},
            placeholder: const Text('Fruit'),
            options: _options(),
          ),
        ),
      );
      expect(find.text('Apple, Grape'), findsOneWidget);
    });

    testWidgets('controlled: shows the value it is given and waits for it', (
      tester,
    ) async {
      final reported = <String?>[];
      Widget build(String? value) => Center(
        child: Select<String>(
          value: value,
          placeholder: const Text('A fruit'),
          onChanged: reported.add,
          options: _options(),
        ),
      );
      await pumpFinesse(tester, build('Apple'));
      await open(tester);
      await tester.tap(optionOf('Banana'));
      await rest(tester);
      expect(reported, ['Banana']);
      // The parent did not take it: the trigger still says Apple.
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsNothing);
      await pumpFinesse(tester, build('Banana'));
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('uncontrolled: keeps its own value', (tester) async {
      final reported = <String?>[];
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>(
            initialValue: 'Apple',
            placeholder: const Text('A fruit'),
            onChanged: reported.add,
            options: _options(),
          ),
        ),
      );
      await open(tester);
      await tester.tap(optionOf('Banana'));
      await rest(tester);
      expect(reported, ['Banana']);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('controlled multiple: values and onChanged', (tester) async {
      var values = {'Apple'};
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Select<String>.multiple(
              values: values,
              placeholder: const Text('Fruit'),
              closeOnSelect: false,
              onChanged: (v) => setState(() => values = v),
              options: _options(),
            ),
          ),
        ),
      );
      await open(tester);
      await tester.tap(optionOf('Cherry'));
      await rest(tester);
      expect(values, {'Apple', 'Cherry'});
      await tester.tap(optionOf('Apple'));
      await rest(tester);
      expect(values, {'Cherry'});
      expect(find.text('Cherry'), findsWidgets);
    });

    for (final constant in [true, false]) {
      testWidgets('an uncontrolled multiple select keeps its choice when its '
          'parent rebuilds (initialValues const: $constant)', (tester) async {
        Set<String>? reported;
        await pumpFinesse(
          tester,
          Center(
            child: StatefulBuilder(
              builder: (context, setState) => Select<String>.multiple(
                placeholder: const Text('Fruit'),
                initialValues: constant ? const {'Apple'} : {'Apple'},
                onChanged: (values) => setState(() => reported = values),
                options: _options(),
              ),
            ),
          ),
        );
        await open(tester);
        await tester.tap(optionOf('Banana'));
        await rest(tester);
        expect(reported, {'Apple', 'Banana'});
        expect(find.text('Apple, Banana'), findsOneWidget);
      });
    }

    testWidgets('a search field of its own in a searchable select takes '
        'Space and Enter', (tester) async {
      final search = TextEditingController();
      addTearDown(search.dispose);
      final node = FocusNode();
      addTearDown(node.dispose);
      var submitted = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>.withSearch(
            placeholder: const Text('City'),
            search: TextField(
              controller: search,
              focusNode: node,
              onSubmitted: (_) => submitted++,
            ),
            options: const [
              SelectOption(value: 'New York', label: 'New York'),
              SelectOption(value: 'Oslo', label: 'Oslo'),
            ],
          ),
        ),
      );
      await open(tester);
      node.requestFocus();
      await rest(tester);
      await tester.enterText(find.byType(EditableText), 'New');
      await rest(tester);
      expect(node.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await rest(tester);
      expect(find.text('Oslo'), findsOneWidget, reason: 'still open');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await rest(tester);
      expect(find.text('Oslo'), findsOneWidget, reason: 'still open');
    });

    testWidgets('Escape with the search field focused closes a searchable '
        'select', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>.withSearch(
            placeholder: const Text('Fruit'),
            onSearchChanged: (_) {},
            options: _options(),
          ),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(1, 1));
      addTearDown(mouse.removePointer);
      await mouse.down(tester.getCenter(find.text('Fruit')));
      await mouse.up();
      await rest(tester);
      expect(find.text('Banana'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await rest(tester);
      expect(find.text('Banana'), findsNothing);
    });

    test('an option needs a child or a label', () {
      expect(() => SelectOption<int>(value: 1), throwsAssertionError);
    });
  });

  group('Select on a phone', () {
    Widget searchable({
      PickerPresentation presentation = PickerPresentation.auto,
      ValueChanged<Set<String>>? onChanged,
      Set<String> values = const {},
    }) => Center(
      child: Select<String>.multipleWithSearch(
        values: values,
        presentation: presentation,
        placeholder: const Text('Fruit'),
        searchPlaceholder: const Text('Search fruit'),
        closeOnSelect: false,
        onSearchChanged: (_) {},
        onChanged: onChanged ?? (_) {},
        options: _options(),
      ),
    );

    testWidgets('a searchable or multiple select opens a sheet', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        searchable(),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      // Titled by the placeholder, the search on top, Done at the foot.
      expect(
        find.descendant(of: find.byType(Sheet), matching: find.text('Fruit')),
        findsOneWidget,
      );
      expect(find.text('Search fruit'), findsOneWidget);
      final search = tester.getRect(find.byType(TextField));
      final first = tester.getRect(optionOf('Apple'));
      final done = tester.getRect(find.widgetWithText(Button, 'Done'));
      expect(search.bottom, lessThanOrEqualTo(first.top));
      expect(first.bottom, lessThanOrEqualTo(done.top));
      // Rows are touch targets and as wide as the sheet's content.
      expect(first.height, greaterThanOrEqualTo(44));
      expect(first.width, greaterThan(300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('taps in the sheet choose, and Done closes it', (tester) async {
      var values = <String>{'Apple'};
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => searchable(
            values: values,
            onChanged: (v) => setState(() => values = v),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      await tester.tap(optionOf('Cherry'));
      await rest(tester);
      expect(values, {'Apple', 'Cherry'});
      // The sheet stays open and its checks follow the selection.
      expect(find.byType(Sheet), findsOneWidget);
      expect(
        find.descendant(
          of: optionOf('Cherry'),
          matching: find.byWidgetPredicate(
            (w) => w is Visibility && w.visible,
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(Button, 'Done'));
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(find.text('Apple, Cherry'), findsOneWidget);
    });

    testWidgets('a single searchable select closes its sheet on a choice', (
      tester,
    ) async {
      String? value;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Select<String>.withSearch(
              value: value,
              placeholder: const Text('A fruit'),
              onSearchChanged: (_) {},
              onChanged: (v) => setState(() => value = v),
              options: _options(),
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      expect(find.widgetWithText(Button, 'Done'), findsNothing);
      await tester.tap(optionOf('Grape'));
      await rest(tester);
      expect(value, 'Grape');
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('a plain single select stays a popover', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>(
            placeholder: const Text('A fruit'),
            options: _options(),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(optionOf('Apple'), findsOneWidget);
    });

    testWidgets('presentation forces either one', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>(
            presentation: PickerPresentation.sheet,
            placeholder: const Text('A fruit'),
            options: _options(),
          ),
        ),
      );
      await open(tester);
      expect(find.byType(Sheet), findsOneWidget);
      await tester.tap(optionOf('Apple'));
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);

      await pumpFinesse(
        tester,
        KeyedSubtree(
          key: const ValueKey(2),
          child: searchable(presentation: PickerPresentation.popover),
        ),
        formFactor: FormFactor.mobile,
      );
      await open(tester);
      expect(find.byType(Sheet), findsNothing);
      expect(optionOf('Apple'), findsOneWidget);
    });

    testWidgets('a controller opens and closes the sheet', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Select<String>.multiple(
            controller: controller,
            placeholder: const Text('Fruit'),
            options: _options(),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      controller.open();
      await rest(tester);
      expect(find.byType(Sheet), findsOneWidget);
      controller.close();
      await rest(tester);
      expect(find.byType(Sheet), findsNothing);
    });

    testWidgets('the sheet reads in the page palette under inverted menus', (
      tester,
    ) async {
      final theme = ThemeData(
        menuColorScheme: const TealColorScheme.dark(),
      );
      await pumpFinesse(
        tester,
        searchable(),
        formFactor: FormFactor.mobile,
        theme: theme,
      );
      await open(tester);
      final style = DefaultTextStyle.of(
        tester.element(find.text('Banana')),
      ).style;
      expect(style.color, theme.colorScheme.foreground);
    });

    testWidgets('builds in every layout, open and closed', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => searchable(values: const {'Apple'}),
        check: (layout) async {
          await open(tester);
          expect(tester.takeException(), isNull);
          if (layout.formFactor == FormFactor.mobile) {
            await tester.tap(find.widgetWithText(Button, 'Done'));
          } else {
            await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          }
          await rest(tester);
        },
      );
    });
  });

  group('select form fields', () {
    testWidgets('SelectFormField validates, saves and resets', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: SelectFormField<String>(
              id: 'fruit',
              placeholder: const Text('A fruit'),
              validator: (v) => v == null ? 'Pick one' : null,
              options: _options(),
            ),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick one'), findsOneWidget);
      await open(tester);
      await tester.tap(optionOf('Banana'));
      await rest(tester);
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(formKey.currentState!.value['fruit'], 'Banana');
      expect(find.text('Banana'), findsOneWidget);
      formKey.currentState!.reset();
      await rest(tester);
      expect(find.text('A fruit'), findsOneWidget);
    });

    testWidgets('SelectMultipleFormField holds a set', (tester) async {
      final formKey = GlobalKey<FinesseFormState>();
      await pumpFinesse(
        tester,
        Center(
          child: FinesseForm(
            key: formKey,
            child: SelectMultipleFormField<String>(
              id: 'fruit',
              placeholder: const Text('Fruit'),
              closeOnSelect: false,
              options: _options(),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(Select<String>));
      await rest(tester);
      await tester.tap(optionOf('Apple'));
      await rest(tester);
      await tester.tap(optionOf('Grape'));
      await rest(tester);
      expect(formKey.currentState!.saveAndValidate(), isTrue);
      expect(formKey.currentState!.value['fruit'], {'Apple', 'Grape'});
    });
  });
}
