import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A stay of two to seven nights, no earlier than today. Once the first day
/// is chosen, the days too near and too far are disabled; once the stay is
/// chosen, the next tap starts a new one.
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
    );
  }
}
