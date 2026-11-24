import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class CalendarSingleExample extends StatefulWidget {
  const CalendarSingleExample({super.key});

  @override
  State<CalendarSingleExample> createState() => _CalendarSingleExampleState();
}

class _CalendarSingleExampleState extends State<CalendarSingleExample> {
  DateTime? selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Calendar(
      selected: selected,
      onChanged: (date) => setState(() => selected = date),
    );
  }
}
