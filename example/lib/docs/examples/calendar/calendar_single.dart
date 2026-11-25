import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One day. The parent holds it; tapping the selected day again clears it
/// when `allowDeselection` is true.
class CalendarSingleExample extends StatefulWidget {
  const CalendarSingleExample({super.key});

  @override
  State<CalendarSingleExample> createState() => _CalendarSingleExampleState();
}

class _CalendarSingleExampleState extends State<CalendarSingleExample> {
  DateTime? day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Calendar(
      value: day,
      allowDeselection: true,
      onChanged: (value) => setState(() => day = value),
    );
  }
}
