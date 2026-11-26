# Number Field

A field for a number, typed or stepped. It is controlled: `value` and `onChanged`. What is typed is clamped to `min` and `max` and written out again when the field loses the focus.

## Default

Stacked carets on a desktop; a minus and a plus at the two ends on a phone. A held button repeats, faster the longer it is held.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldBasicExample extends StatefulWidget {
  const NumberFieldBasicExample({super.key});

  @override
  State<NumberFieldBasicExample> createState() =>
      _NumberFieldBasicExampleState();
}

class _NumberFieldBasicExampleState extends State<NumberFieldBasicExample> {
  num? guests = 2;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      // Type a number, or step it: the buttons, the arrow keys, Page Up and
      // Page Down for ten at a time, Home and End for the bounds. On a
      // phone the buttons are a minus and a plus at the two ends.
      child: NumberField(
        value: guests,
        min: 1,
        max: 12,
        semanticLabel: 'Guests',
        onChanged: (value) => setState(() => guests = value),
      ),
    );
  }
}
```

## Decimals and formats

`decimalDigits` sets the precision and `format` takes any `NumberFormat` from `package:intl`.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldFormatExample extends StatefulWidget {
  const NumberFieldFormatExample({super.key});

  @override
  State<NumberFieldFormatExample> createState() =>
      _NumberFieldFormatExampleState();
}

class _NumberFieldFormatExampleState extends State<NumberFieldFormatExample> {
  // A format writes the number and reads it back from what was typed.
  final currency = NumberFormat.simpleCurrency(locale: 'en_US');

  num? price = 1249.5;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: NumberField(
        value: price,
        min: 0,
        step: .5,
        decimalDigits: 2,
        format: currency,
        semanticLabel: 'Price',
        onChanged: (value) => setState(() => price = value),
      ),
    );
  }
}
```

## Stepper

`NumberField.stepper` for a small count that is never typed.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldStepperExample extends StatefulWidget {
  const NumberFieldStepperExample({super.key});

  @override
  State<NumberFieldStepperExample> createState() =>
      _NumberFieldStepperExampleState();
}

class _NumberFieldStepperExampleState extends State<NumberFieldStepperExample> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Quantity', style: theme.textTheme.small),
        const Gap.md(),
        // A compact pill with no typing. Hold a button to keep stepping;
        // it stops at the bounds.
        NumberField.stepper(
          value: quantity,
          min: 1,
          max: 9,
          semanticLabel: 'Quantity',
          onChanged: (value) {
            setState(() => quantity = value?.toInt() ?? 1);
          },
        ),
      ],
    );
  }
}
```

## In a form

`NumberFormField` adds a label, a description and validation.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class NumberFieldFormExample extends StatefulWidget {
  const NumberFieldFormExample({super.key});

  @override
  State<NumberFieldFormExample> createState() => _NumberFieldFormExampleState();
}

class _NumberFieldFormExampleState extends State<NumberFieldFormExample> {
  final formKey = GlobalKey<UnaFormState>();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: UnaForm(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberFormField(
              id: 'age',
              label: const Text('Age'),
              description: const Text('You must be 18 or older.'),
              placeholder: const Text('Years'),
              min: 0,
              max: 120,
              validator: (value) {
                if (value == null) return 'Enter your age';
                return value < 18 ? 'You must be 18 or older' : null;
              },
            ),
            const Gap.md(),
            Button(
              onPressed: () => formKey.currentState!.validate(),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
```
