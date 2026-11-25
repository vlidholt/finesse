import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The button restyled, and replaced: `formatDate`, `variant` and `leading`
/// change the default one; `triggerBuilder` builds any other control.
class DatePickerTriggerExample extends StatefulWidget {
  const DatePickerTriggerExample({super.key});

  @override
  State<DatePickerTriggerExample> createState() =>
      _DatePickerTriggerExampleState();
}

class _DatePickerTriggerExampleState extends State<DatePickerTriggerExample> {
  DateTime? date = DateTime.now();

  static String _short(DateTime date) =>
      '${date.day}.${date.month}.${date.year}';

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        DatePicker(
          value: date,
          onChanged: (value) => setState(() => date = value),
          variant: ButtonVariant.secondary,
          width: 160,
          formatDate: _short,
          captionLayout: CalendarCaptionLayout.dropdown,
        ),
        DatePicker(
          value: date,
          onChanged: (value) => setState(() => date = value),
          triggerBuilder: (context, value, toggle) => Chip(
            leading: const PhosphorIcon(PhosphorIconsRegular.calendarDots),
            label: Text(value == null ? 'Any day' : _short(value)),
            selected: value != null,
            onPressed: toggle,
          ),
        ),
      ],
    );
  }
}
