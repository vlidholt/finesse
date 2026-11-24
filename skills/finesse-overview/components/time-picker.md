# Time Picker

A field for entering a time of day.

## 24-hour

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TimePickerBasicExample extends StatelessWidget {
  const TimePickerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimePicker(
      trailing: const Padding(
        padding: EdgeInsets.only(left: 8, top: 14),
        child: Icon(PhosphorIconsRegular.clock),
      ),
      onChanged: (time) {},
    );
  }
}
```

## With AM/PM period

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TimePickerPeriodExample extends StatelessWidget {
  const TimePickerPeriodExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimePicker.period(
      onChanged: (time) {},
    );
  }
}
```

