import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A date typed into its fields, in the order the locale writes one. The
/// focus moves on once a field is full, the arrow keys step the field that
/// has the focus, and the button beside the fields opens a calendar.
class DateFieldBasicExample extends StatefulWidget {
  const DateFieldBasicExample({super.key});

  @override
  State<DateFieldBasicExample> createState() => _DateFieldBasicExampleState();
}

class _DateFieldBasicExampleState extends State<DateFieldBasicExample> {
  DateTime? date = DateTime(1990, 4, 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = this.date;
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      gap: GapSize.md,
      children: [
        DateField(
          value: date,
          max: DateTime.now(),
          onChanged: (value) => setState(() => this.date = value),
        ),
        Text(
          date == null
              ? 'No date yet'
              : 'Born on ${formatPickedDate(context, date)}',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}
