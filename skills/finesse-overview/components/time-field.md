# Time Field

A time typed into small number fields: hours, minutes and, optionally, seconds, with a day period on the 12-hour clock. It is the inline, keyboard-first way to enter a time; `TimePicker` is the button that opens one in a popover, or wheels on a phone. `TimeFormField` puts it in a form.

## 24-hour

`value` and `onChanged` hold the time in the parent; `initialValue` lets the field keep it. `onChanged` is called once every field that shows is filled.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A time typed into its fields. The focus moves on once two digits are
/// in, and the time is reported when every field holds a number.
class TimeFieldBasicExample extends StatefulWidget {
  const TimeFieldBasicExample({super.key});

  @override
  State<TimeFieldBasicExample> createState() => _TimeFieldBasicExampleState();
}

class _TimeFieldBasicExampleState extends State<TimeFieldBasicExample> {
  TimeOfDay? time = const TimeOfDay(hour: 9, minute: 30);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = this.time;
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        TimeField(
          value: time,
          use24HourFormat: true,
          onChanged: (value) => setState(() => this.time = value),
        ),
        Text(
          time == null
              ? 'No time yet'
              : 'Stand-up at ${formatTimeOfDay(context, time)}',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
```

## 12-hour, with a day period

The time reported is always on the 24-hour clock: 4:45 PM is `TimeOfDay(hour: 16, minute: 45)`.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The 12-hour clock: the hours run to 12 and a day period follows them.
/// Left alone, `use24HourFormat` follows the platform and the locale.
class TimeFieldPeriodExample extends StatelessWidget {
  const TimeFieldPeriodExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeField(
      initialValue: const TimeOfDay(hour: 16, minute: 45),
      use24HourFormat: false,
      onChanged: (time) {},
    );
  }
}
```

## Which fields show

`showHours`, `showMinutes`, `showSeconds` and `showLabels` choose the fields; `leading` and `trailing` sit beside them.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Minutes and seconds only, without the names above the fields: a lap
/// time. A time outside `min` and `max` is moved inside when the focus
/// leaves.
class TimeFieldSecondsExample extends StatelessWidget {
  const TimeFieldSecondsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeField(
      initialValue: const TimeOfDay(hour: 0, minute: 1, second: 30),
      showHours: false,
      showSeconds: true,
      showLabels: false,
      max: const TimeOfDay(hour: 0, minute: 10),
      leading: const PhosphorIcon(PhosphorIconsRegular.timer),
      onChanged: (time) {},
    );
  }
}
```
