import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
