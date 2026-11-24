import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TimePickerPeriodExample extends StatelessWidget {
  const TimePickerPeriodExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimePicker.period(
      onChanged: (time) {},
    );
  }
}
