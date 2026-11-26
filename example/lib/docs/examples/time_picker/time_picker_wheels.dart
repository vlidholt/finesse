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
