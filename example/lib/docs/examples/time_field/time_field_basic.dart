import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A time typed into its fields. The focus moves on once two digits are
/// in, and the time is reported when every field holds a number.
class TimeFieldBasicExample extends StatefulWidget {
  const TimeFieldBasicExample({super.key});

  @override
  State<TimeFieldBasicExample> createState() => _TimeFieldBasicExampleState();
}

class _TimeFieldBasicExampleState extends State<TimeFieldBasicExample> {
  TimeOfDay? time = const TimeOfDay(hour: 9, minute: 30);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = this.time;
    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        TimeField(
          value: time,
          use24HourFormat: true,
          onChanged: (value) => setState(() => this.time = value),
        ),
        Text(
          time == null
              ? 'No time yet'
              : 'Stand-up at ${formatTimeOfDay(context, time)}',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
