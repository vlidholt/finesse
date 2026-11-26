# Date Field

A date typed into small number fields — day, month and year, in the order the locale writes them — with a button beside them that opens a calendar. It is the keyboard-first way to enter a date someone knows by heart, the sibling of `TimeField`; `DatePicker` is the button that shows a calendar, or wheels on a phone. `DateFormField` puts it in a form.

## Typed, or picked from a calendar

Typing fills a field and moves on once it is full; the up and down arrows step the field that has the focus. `onChanged` is called once the three fields spell a date. On a phone the calendar opens in a sheet.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A date typed into its fields, in the order the locale writes one. The
/// focus moves on once a field is full, the arrow keys step the field that
/// has the focus, and the button beside the fields opens a calendar.
class DateFieldBasicExample extends StatefulWidget {
  const DateFieldBasicExample({super.key});

  @override
  State<DateFieldBasicExample> createState() => _DateFieldBasicExampleState();
}

class _DateFieldBasicExampleState extends State<DateFieldBasicExample> {
  DateTime? date = DateTime(1990, 4, 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = this.date;
    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      gap: GapSize.md,
      children: [
        DateField(
          value: date,
          max: DateTime.now(),
          onChanged: (value) => setState(() => this.date = value),
        ),
        Text(
          date == null
              ? 'No date yet'
              : 'Born on ${formatPickedDate(context, date)}',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
```

## Compact

`showLabels` and `showCalendarButton` choose what shows beside the digits; `leading` and `trailing` sit at the ends. A date outside `min` and `max` is moved inside when the focus leaves.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The fields without their names and without the calendar button: an
/// expiry date someone copies off a card. The placeholders spell out the
/// order, and a date outside `min` and `max` is moved inside when the focus
/// leaves.
class DateFieldCompactExample extends StatelessWidget {
  const DateFieldCompactExample({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return DateField(
      showLabels: false,
      showCalendarButton: false,
      min: today,
      max: DateTime(today.year + 10, today.month, today.day),
      leading: const PhosphorIcon(PhosphorIconsRegular.hourglassMedium),
      onChanged: (date) {},
    );
  }
}
```

## In a form

The form's value is the date once the fields spell one, and null before.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `DateFormField` puts the field in a form. A failed validation moves the
/// focus to the first field.
class DateFieldFormExample extends StatefulWidget {
  const DateFieldFormExample({super.key});

  @override
  State<DateFieldFormExample> createState() => _DateFieldFormExampleState();
}

class _DateFieldFormExampleState extends State<DateFieldFormExample> {
  final formKey = GlobalKey<UnaFormState>();
  String? saved;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saved = this.saved;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: UnaForm(
        key: formKey,
        child: UnaColumn(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          gap: GapSize.md,
          children: [
            DateFormField(
              id: 'born',
              label: const Text('Date of birth'),
              description: const Text('As it is written in your passport.'),
              max: DateTime.now(),
              validator: (date) =>
                  date == null ? 'Enter your date of birth' : null,
            ),
            Button(
              onPressed: () {
                if (!formKey.currentState!.saveAndValidate()) return;
                final date = formKey.currentState!.value['born'] as DateTime;
                setState(() => this.saved = formatPickedDate(context, date));
              },
              child: const Text('Save'),
            ),
            if (saved != null)
              Text('Saved: $saved', style: theme.textTheme.muted),
          ],
        ),
      ),
    );
  }
}
```
