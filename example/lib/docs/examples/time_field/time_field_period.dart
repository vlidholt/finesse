import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The 12-hour clock: the hours run to 12 and a day period follows them.
/// Left alone, `use24HourFormat` follows the platform and the locale.
class TimeFieldPeriodExample extends StatelessWidget {
  const TimeFieldPeriodExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeField(
      initialValue: const TimeOfDay(hour: 16, minute: 45),
      use24HourFormat: false,
      onChanged: (time) {},
    );
  }
}
