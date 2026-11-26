import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The unnamed constructor of a widget with variants takes `variant:`, and a
/// named constructor is a shortcut for one value of it.
void main() {
  Widget app(Widget child) => FinesseApp(home: Center(child: child));

  test('a named constructor is the unnamed one with its variant', () {
    expect(const Divider().variant, DividerVariant.horizontal);
    expect(const Divider.vertical().variant, DividerVariant.vertical);
    expect(
      const Divider(variant: DividerVariant.vertical).variant,
      const Divider.vertical().variant,
    );

    const label = Text('x');
    // None named: primary, or the look a bar gives its buttons.
    expect(const Button(child: label).variant, isNull);
    expect(
      const Button(variant: ButtonVariant.ghost, child: label).variant,
      const Button.ghost(child: label).variant,
    );
    expect(
      const IconButton(variant: ButtonVariant.outline, icon: label).variant,
      const IconButton.outline(icon: label).variant,
    );
    expect(
      const Badge(variant: BadgeVariant.outline, child: label).variant,
      const Badge.outline(child: label).variant,
    );
    expect(
      const Toggle(
        variant: ToggleVariant.outline,
        value: false,
        child: label,
      ).variant,
      const Toggle.outline(value: false, child: label).variant,
    );
    expect(
      const Dialog(variant: DialogVariant.alert).variant,
      const Dialog.alert().variant,
    );
    expect(
      const FinesseTableCell(
        variant: TableCellVariant.header,
        child: label,
      ).variant,
      const FinesseTableCell.header(child: label).variant,
    );
  });

  test('IconButton has no link variant', () {
    expect(
      () => IconButton(variant: ButtonVariant.link, icon: const Text('x')),
      throwsAssertionError,
    );
  });

  group('Select', () {
    const options = [SelectOption(value: 'a', child: Text('a'))];

    test('each value shape takes its own two variants', () {
      expect(
        Select<String>(
          variant: SelectVariant.search,
          options: options,
          onSearchChanged: (_) {},
        ).variant,
        SelectVariant.search,
      );
      expect(
        Select<String>.multiple(
          variant: SelectVariant.multipleWithSearch,
          options: options,
          onSearchChanged: (_) {},
        ).variant,
        SelectVariant.multipleWithSearch,
      );
      expect(
        () => Select<String>(variant: SelectVariant.multiple, options: options),
        throwsAssertionError,
      );
      expect(
        () => Select<String>.multiple(
          variant: SelectVariant.search,
          options: options,
        ),
        throwsAssertionError,
      );
      // A search variant needs a way to hear the query.
      expect(
        () => Select<String>(variant: SelectVariant.search, options: options),
        throwsAssertionError,
      );
      // The multiple variant does not.
      expect(
        const Select<String>.multiple(options: options).variant,
        SelectVariant.multiple,
      );
    });

    testWidgets('the form fields pass their variant on', (tester) async {
      await tester.pumpWidget(
        app(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectFormField<String>(
                variant: SelectVariant.search,
                options: options,
                placeholder: const Text('one'),
                onSearchChanged: (_) {},
                selectedOptionBuilder: (context, value) => Text(value),
              ),
              SelectFormField<String>(
                options: options,
                placeholder: const Text('one'),
                selectedOptionBuilder: (context, value) => Text(value),
              ),
              SelectMultipleFormField<String>(
                variant: SelectVariant.multipleWithSearch,
                options: options,
                placeholder: const Text('many'),
                onSearchChanged: (_) {},
                selectedOptionsBuilder: (context, values) =>
                    Text(values.join()),
              ),
              SelectMultipleFormField<String>(
                options: options,
                placeholder: const Text('many'),
                selectedOptionsBuilder: (context, values) =>
                    Text(values.join()),
              ),
            ],
          ),
        ),
      );
      final variants = tester
          .widgetList<Select<String>>(find.byType(Select<String>))
          .map((select) => select.variant)
          .toList();
      expect(variants, [
        SelectVariant.search,
        SelectVariant.primary,
        SelectVariant.multipleWithSearch,
        SelectVariant.multiple,
      ]);
    });
  });
}
