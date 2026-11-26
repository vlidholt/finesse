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
