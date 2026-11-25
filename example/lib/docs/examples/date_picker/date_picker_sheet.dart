import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The phone presentations, forced so they show on any screen: a calendar
/// as wide as the sheet, and wheels for a date far from today.
class DatePickerSheetExample extends StatefulWidget {
  const DatePickerSheetExample({super.key});

  @override
  State<DatePickerSheetExample> createState() => _DatePickerSheetExampleState();
}

class _DatePickerSheetExampleState extends State<DatePickerSheetExample> {
  DateTime? appointment;
  DateTime? birthday = DateTime(1990, 6, 15);

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        DatePicker(
          value: appointment,
          onChanged: (value) => setState(() => appointment = value),
          presentation: PickerPresentation.sheet,
          placeholder: const Text('Appointment'),
          title: const Text('Choose a day'),
        ),
        DatePicker(
          value: birthday,
          onChanged: (value) => setState(() => birthday = value),
          presentation: PickerPresentation.sheet,
          mode: DatePickerMode.wheel,
          max: DateTime.now(),
          placeholder: const Text('Date of birth'),
          leading: const PhosphorIcon(PhosphorIconsRegular.cake),
        ),
      ],
    );
  }
}
