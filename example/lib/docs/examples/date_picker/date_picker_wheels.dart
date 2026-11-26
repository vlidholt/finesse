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
