import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
      allowClear: true,
    );
  }
}
