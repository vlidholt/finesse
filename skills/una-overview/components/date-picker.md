# Date Picker

A field that shows a date and opens a way to change it: a calendar in a popover on a desktop, a calendar or wheels in a bottom sheet on a phone. `presentation` forces either one and `mode` chooses calendar or wheels. `DateRangePicker` picks a first and a last day, `DateWheelPicker` is the wheels on their own, and `DatePickerFormField` and `DateRangePickerFormField` put the pickers in a form.

## A date

Controlled: `value` and `onChanged`. `min` and `max` bound the choice; tapping the selected day clears it unless `allowDeselection` is false.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A button that shows a date. On a desktop it opens a calendar in a
/// popover; on a phone, in a bottom sheet. A tap on a day chooses it.
class DatePickerSingleExample extends StatefulWidget {
  const DatePickerSingleExample({super.key});

  @override
  State<DatePickerSingleExample> createState() =>
      _DatePickerSingleExampleState();
}

class _DatePickerSingleExampleState extends State<DatePickerSingleExample> {
  DateTime? due;

  @override
  Widget build(BuildContext context) {
    return DatePicker(
      value: due,
      onChanged: (value) => setState(() => due = value),
      min: DateTime.now(),
      placeholder: const Text('Due date'),
    );
  }
}
```

## A range

`DateRangePicker` holds a `DateTimeRange`. `minDays` and `maxDays` bound its length.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `DateRangePicker` picks a first and a last day. The popover shows two
/// months and closes on the second tap; a sheet shows one month and waits
/// for Done.
class DatePickerRangeExample extends StatefulWidget {
  const DatePickerRangeExample({super.key});

  @override
  State<DatePickerRangeExample> createState() => _DatePickerRangeExampleState();
}

class _DatePickerRangeExampleState extends State<DatePickerRangeExample> {
  DateTimeRange? stay;

  @override
  Widget build(BuildContext context) {
    return DateRangePicker(
      value: stay,
      onChanged: (value) => setState(() => stay = value),
      min: DateTime.now(),
      maxDays: 14,
      numberOfMonths: 2,
      placeholder: const Text('Check in - check out'),
    );
  }
}
```

## In a sheet: calendar and wheels

`PickerPresentation.sheet` shows on any screen what a phone gets. On the calendar a tap is the choice; `DatePickerMode.wheel` turns a draft that Done reports.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The phone presentations, forced so they show on any screen: a calendar
/// as wide as the sheet, and wheels for a date far from today.
class DatePickerSheetExample extends StatefulWidget {
  const DatePickerSheetExample({super.key});

  @override
  State<DatePickerSheetExample> createState() => _DatePickerSheetExampleState();
}

class _DatePickerSheetExampleState extends State<DatePickerSheetExample> {
  DateTime? appointment;
  DateTime? birthday = DateTime(1990, 6, 15);

  @override
  Widget build(BuildContext context) {
    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        DatePicker(
          value: appointment,
          onChanged: (value) => setState(() => appointment = value),
          presentation: PickerPresentation.sheet,
          placeholder: const Text('Appointment'),
          title: const Text('Choose a day'),
        ),
        DatePicker(
          value: birthday,
          onChanged: (value) => setState(() => birthday = value),
          presentation: PickerPresentation.sheet,
          mode: DatePickerMode.wheel,
          max: DateTime.now(),
          placeholder: const Text('Date of birth'),
          leading: const PhosphorIcon(PhosphorIconsRegular.cake),
        ),
      ],
    );
  }
}
```

## Wheels in the page

`DateWheelPicker` orders day, month and year the way the locale writes a date. `DateWheelMode.dateAndTime` adds a time, and `monthYear` drops the day.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The wheels on their own, in the page: `DateWheelPicker`, here choosing a
/// day and a time in the next month.
class DatePickerWheelsExample extends StatefulWidget {
  const DatePickerWheelsExample({super.key});

  @override
  State<DatePickerWheelsExample> createState() =>
      _DatePickerWheelsExampleState();
}

class _DatePickerWheelsExampleState extends State<DatePickerWheelsExample> {
  static DateTime _nextHour() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  final DateTime earliest = _nextHour();
  late DateTime pickup = earliest;

  @override
  Widget build(BuildContext context) {
    return DateWheelPicker(
      value: pickup,
      mode: DateWheelMode.dateAndTime,
      minuteInterval: 15,
      min: earliest,
      max: earliest.add(const Duration(days: 30)),
      onChanged: (value) => setState(() => pickup = value),
    );
  }
}
```

## Another trigger

The trigger is a field, to sit among the fields of a form; `variant` makes it that button instead, and `triggerBuilder` any other control. The calendar inside is configured on the picker too: `captionLayout`, `numberOfMonths`, `weekStartsOn`, `showWeekNumbers`, `selectableDayPredicate` and `calendarTheme`.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The trigger restyled, and replaced: `variant` makes the default field a
/// button and `formatDate` writes the date; `triggerBuilder` builds any
/// other control.
class DatePickerTriggerExample extends StatefulWidget {
  const DatePickerTriggerExample({super.key});

  @override
  State<DatePickerTriggerExample> createState() =>
      _DatePickerTriggerExampleState();
}

class _DatePickerTriggerExampleState extends State<DatePickerTriggerExample> {
  DateTime? date = DateTime.now();

  static String _short(DateTime date) =>
      '${date.day}.${date.month}.${date.year}';

  @override
  Widget build(BuildContext context) {
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        DatePicker(
          value: date,
          onChanged: (value) => setState(() => date = value),
          variant: ButtonVariant.secondary,
          width: 160,
          formatDate: _short,
          captionLayout: CalendarCaptionLayout.dropdown,
        ),
        DatePicker(
          value: date,
          onChanged: (value) => setState(() => date = value),
          triggerBuilder: (context, value, toggle) => Chip(
            leading: const PhosphorIcon(PhosphorIconsRegular.calendarDots),
            label: Text(value == null ? 'Any day' : _short(value)),
            selected: value != null,
            onPressed: toggle,
          ),
        ),
      ],
    );
  }
}
```
