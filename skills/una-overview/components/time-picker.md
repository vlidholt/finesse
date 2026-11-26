# Time Picker

A field that shows a time and opens a way to change it: a `TimeField` in a popover on a desktop, wheels in a bottom sheet on a phone. It is the counterpart of `DatePicker`. `presentation` forces either one, `TimeWheelPicker` is the wheels on their own, and `TimePickerFormField` puts the picker in a form.

## Basic

Controlled: `value` and `onChanged`. The clock, 12- or 24-hour, follows the platform and the locale unless `use24HourFormat` says otherwise.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A button that shows a time. On a desktop it opens a popover to type
/// in; on a phone, wheels in a sheet with Cancel and Done.
class TimePickerBasicExample extends StatefulWidget {
  const TimePickerBasicExample({super.key});

  @override
  State<TimePickerBasicExample> createState() => _TimePickerBasicExampleState();
}

class _TimePickerBasicExampleState extends State<TimePickerBasicExample> {
  TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    return TimePicker(
      value: time,
      onChanged: (value) => setState(() => time = value),
    );
  }
}
```

## Wheels in a sheet

`PickerPresentation.sheet` shows on any screen what a phone gets. The wheels turn a draft: Done reports it, Cancel or a tap outside drops it. `minuteInterval`, `min` and `max` shape the wheels, and Clear empties the time unless `allowDeselection` is false.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The phone presentation, forced: wheels in a bottom sheet. The minutes
/// step by five, opening hours bound the choice, and the sheet offers to
/// clear the time.
class TimePickerSheetExample extends StatefulWidget {
  const TimePickerSheetExample({super.key});

  @override
  State<TimePickerSheetExample> createState() => _TimePickerSheetExampleState();
}

class _TimePickerSheetExampleState extends State<TimePickerSheetExample> {
  TimeOfDay? time = const TimeOfDay(hour: 12, minute: 30);

  @override
  Widget build(BuildContext context) {
    return TimePicker(
      value: time,
      onChanged: (value) => setState(() => time = value),
      presentation: PickerPresentation.sheet,
      title: const Text('Table for two at'),
      placeholder: const Text('Any time'),
      minuteInterval: 5,
      min: const TimeOfDay(hour: 11, minute: 30),
      max: const TimeOfDay(hour: 22, minute: 0),
    );
  }
}
```

## Wheels in the page

`TimeWheelPicker` is controlled like any wheel and reports as it turns.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The wheels on their own, in the page: `TimeWheelPicker`. Here on the
/// 12-hour clock with seconds.
class TimePickerWheelsExample extends StatefulWidget {
  const TimePickerWheelsExample({super.key});

  @override
  State<TimePickerWheelsExample> createState() =>
      _TimePickerWheelsExampleState();
}

class _TimePickerWheelsExampleState extends State<TimePickerWheelsExample> {
  TimeOfDay time = const TimeOfDay(hour: 6, minute: 45);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        TimeWheelPicker(
          value: time,
          use24HourFormat: false,
          showSeconds: true,
          onChanged: (value) => setState(() => time = value),
        ),
        Text(
          'Alarm at ${formatTimeOfDay(context, time, use24HourFormat: false)}',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
```

## Another trigger

`triggerBuilder` replaces the button; `leading`, `trailing`, `variant`, `size` and `formatTime` restyle it.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Another trigger: `triggerBuilder` gets the time and a callback that
/// opens the picker. `formatTime` writes the time on the default button.
class TimePickerTriggerExample extends StatefulWidget {
  const TimePickerTriggerExample({super.key});

  @override
  State<TimePickerTriggerExample> createState() =>
      _TimePickerTriggerExampleState();
}

class _TimePickerTriggerExampleState extends State<TimePickerTriggerExample> {
  TimeOfDay? reminder = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay? bedtime = const TimeOfDay(hour: 22, minute: 30);

  @override
  Widget build(BuildContext context) {
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        TimePicker(
          value: reminder,
          onChanged: (value) => setState(() => reminder = value),
          triggerBuilder: (context, value, toggle) => Chip(
            leading: const PhosphorIcon(PhosphorIconsRegular.bell),
            label: Text(
              value == null ? 'Remind me' : formatTimeOfDay(context, value),
            ),
            selected: value != null,
            onPressed: toggle,
          ),
        ),
        TimePicker(
          value: bedtime,
          onChanged: (value) => setState(() => bedtime = value),
          leading: const PhosphorIcon(PhosphorIconsRegular.moon),
          formatTime: (time) =>
              'Lights out ${time.hourOfPeriod}.'
              '${time.minute.toString().padLeft(2, '0')}',
        ),
      ],
    );
  }
}
```
