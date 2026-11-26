# Calendar

A month calendar that selects a day, several days or a range. Its parameters say what it does: bounds, how many months show, where the week starts, how the caption is laid out. How it looks is the theme's `CalendarTheme`, which `calendarTheme` overrides for one calendar. Cells grow with the text scale and a month that does not fit its room is shown whole, smaller. `DatePicker` puts a calendar behind a button.

## One day

`value` and `onChanged`.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// One day. The parent holds it; tapping the selected day again clears it
/// when `allowDeselection` is true.
class CalendarSingleExample extends StatefulWidget {
  const CalendarSingleExample({super.key});

  @override
  State<CalendarSingleExample> createState() => _CalendarSingleExampleState();
}

class _CalendarSingleExampleState extends State<CalendarSingleExample> {
  DateTime? day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Calendar(
      value: day,
      allowDeselection: true,
      onChanged: (value) => setState(() => day = value),
    );
  }
}
```

## A range

`Calendar.range` takes `range` and `onRangeChanged`. `min` and `max` are the earliest and latest day; `minDays` and `maxDays` bound the length of the range.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A stay of two to seven nights, no earlier than today. Once the first day
/// is chosen, the days too near and too far are disabled.
class CalendarRangeExample extends StatefulWidget {
  const CalendarRangeExample({super.key});

  @override
  State<CalendarRangeExample> createState() => _CalendarRangeExampleState();
}

class _CalendarRangeExampleState extends State<CalendarRangeExample> {
  DateTimeRange? stay;

  @override
  Widget build(BuildContext context) {
    return Calendar.range(
      range: stay,
      onRangeChanged: (value) => setState(() => stay = value),
      min: DateTime.now(),
      minDays: 2,
      maxDays: 7,
      numberOfMonths: 2,
    );
  }
}
```

## Several days

`Calendar.multiple` takes `values` and `onValuesChanged`. `selectableDayPredicate` disables days one by one, `captionLayout` puts the month and year in dropdowns, and `showWeekNumbers` adds a column.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Up to three days, weekends excluded, with the month and the year in
/// dropdowns and a column of week numbers.
class CalendarMultipleExample extends StatefulWidget {
  const CalendarMultipleExample({super.key});

  @override
  State<CalendarMultipleExample> createState() =>
      _CalendarMultipleExampleState();
}

class _CalendarMultipleExampleState extends State<CalendarMultipleExample> {
  List<DateTime> days = const [];

  @override
  Widget build(BuildContext context) {
    return Calendar.multiple(
      values: days,
      onValuesChanged: (value) => setState(() => days = value),
      maxSelected: 3,
      selectableDayPredicate: (day) => day.weekday <= DateTime.friday,
      captionLayout: CalendarCaptionLayout.dropdown,
      showWeekNumbers: true,
    );
  }
}
```

## Restyled

Cell size and radius, button variants, text styles and the formats of the labels are all fields of `CalendarTheme`.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// How a calendar looks is the theme's `CalendarTheme`. `calendarTheme`
/// overrides part of it for one calendar: here larger, rounder cells, the
/// week starting on Sunday and one-letter weekday names.
class CalendarThemeExample extends StatefulWidget {
  const CalendarThemeExample({super.key});

  @override
  State<CalendarThemeExample> createState() => _CalendarThemeExampleState();
}

class _CalendarThemeExampleState extends State<CalendarThemeExample> {
  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  DateTime? day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Calendar(
      value: day,
      onChanged: (value) => setState(() => day = value),
      weekStartsOn: DateTime.sunday,
      calendarTheme: CalendarTheme(
        dayButtonSize: 44,
        dayButtonBorderRadius: theme.radii.full,
        todayButtonVariant: ButtonVariant.outline,
        formatWeekday: (date) => _letters[date.weekday - 1],
      ),
    );
  }
}
```
