import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TimePickerBasicExample extends StatelessWidget {
  const TimePickerBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimePicker(
      trailing: const Padding(
        padding: EdgeInsets.only(left: 8, top: 14),
        child: Icon(PhosphorIconsRegular.clock),
      ),
      onChanged: (time) {},
    );
  }
}
