import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Up to three days, weekends excluded, with the month and the year in
/// dropdowns and a column of week numbers.
class CalendarMultipleExample extends StatefulWidget {
  const CalendarMultipleExample({super.key});

  @override
  State<CalendarMultipleExample> createState() =>
      _CalendarMultipleExampleState();
}

class _CalendarMultipleExampleState extends State<CalendarMultipleExample> {
  List<DateTime> days = const [];

  @override
  Widget build(BuildContext context) {
    return Calendar.multiple(
      values: days,
      onValuesChanged: (value) => setState(() => days = value),
      maxSelected: 3,
      selectableDayPredicate: (day) => day.weekday <= DateTime.friday,
      captionLayout: CalendarCaptionLayout.dropdown,
      showWeekNumbers: true,
    );
  }
}
