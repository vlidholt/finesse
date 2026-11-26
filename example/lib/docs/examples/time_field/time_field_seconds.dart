import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Minutes and seconds only, without the names above the fields: a lap
/// time. A time outside `min` and `max` is moved inside when the focus
/// leaves.
class TimeFieldSecondsExample extends StatelessWidget {
  const TimeFieldSecondsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return TimeField(
      initialValue: const TimeOfDay(hour: 0, minute: 1, second: 30),
      showHours: false,
      showSeconds: true,
      showLabels: false,
      max: const TimeOfDay(hour: 0, minute: 10),
      leading: const PhosphorIcon(PhosphorIconsRegular.timer),
      onChanged: (time) {},
    );
  }
}
