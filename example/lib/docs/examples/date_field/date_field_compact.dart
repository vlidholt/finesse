import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The fields without their names and without the calendar button: an
/// expiry date someone copies off a card. The placeholders spell out the
/// order, and a date outside `min` and `max` is moved inside when the focus
/// leaves.
class DateFieldCompactExample extends StatelessWidget {
  const DateFieldCompactExample({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return DateField(
      showLabels: false,
      showCalendarButton: false,
      min: today,
      max: DateTime(today.year + 10, today.month, today.day),
      leading: const PhosphorIcon(PhosphorIconsRegular.hourglassMedium),
      onChanged: (date) {},
    );
  }
}
