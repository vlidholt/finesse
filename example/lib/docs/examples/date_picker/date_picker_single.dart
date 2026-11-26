import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A button that shows a date. On a desktop it opens a calendar in a
/// popover; on a phone, in a bottom sheet. A tap on a day chooses it.
class DatePickerSingleExample extends StatefulWidget {
  const DatePickerSingleExample({super.key});

  @override
  State<DatePickerSingleExample> createState() =>
      _DatePickerSingleExampleState();
}

class _DatePickerSingleExampleState extends State<DatePickerSingleExample> {
  DateTime? due;

  @override
  Widget build(BuildContext context) {
    return DatePicker(
      value: due,
      onChanged: (value) => setState(() => due = value),
      min: DateTime.now(),
      placeholder: const Text('Due date'),
    );
  }
}
