import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// How a calendar looks is the theme's `CalendarTheme`. `calendarTheme`
/// overrides part of it for one calendar: here larger, rounder cells, the
/// week starting on Sunday and one-letter weekday names.
class CalendarThemeExample extends StatefulWidget {
  const CalendarThemeExample({super.key});

  @override
  State<CalendarThemeExample> createState() => _CalendarThemeExampleState();
}

class _CalendarThemeExampleState extends State<CalendarThemeExample> {
  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  DateTime? day = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Calendar(
      value: day,
      onChanged: (value) => setState(() => day = value),
      weekStartsOn: DateTime.sunday,
      calendarTheme: CalendarTheme(
        dayButtonSize: 44,
        dayButtonBorderRadius: theme.radii.full,
        todayButtonVariant: ButtonVariant.outline,
        formatWeekday: (date) => _letters[date.weekday - 1],
      ),
    );
  }
}
