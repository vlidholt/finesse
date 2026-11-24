import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class CalendarRangeExample extends StatelessWidget {
  const CalendarRangeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Calendar.range(
      min: 2,
      max: 7,
    );
  }
}
