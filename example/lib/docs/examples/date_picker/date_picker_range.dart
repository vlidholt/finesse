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
