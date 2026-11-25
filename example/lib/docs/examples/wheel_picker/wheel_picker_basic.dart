import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// One wheel. It reports the row under the lens as it turns, and rests on
/// the value it is given.
class WheelPickerBasicExample extends StatefulWidget {
  const WheelPickerBasicExample({super.key});

  @override
  State<WheelPickerBasicExample> createState() =>
      _WheelPickerBasicExampleState();
}

class _WheelPickerBasicExampleState extends State<WheelPickerBasicExample> {
  static const _choices = {
    5: '5 minutes',
    10: '10 minutes',
    15: '15 minutes',
    30: 'Half an hour',
    45: '45 minutes',
    60: 'One hour',
    90: 'An hour and a half',
    120: 'Two hours',
  };

  int minutes = 15;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WheelPicker<int>(
          semanticLabel: 'Remind me in',
          value: minutes,
          onChanged: (value) => setState(() => minutes = value),
          items: [
            for (final MapEntry(key: m, value: label) in _choices.entries)
              WheelPickerItem(value: m, label: label),
          ],
        ),
        const Gap.md(),
        Text('Reminder in $minutes minutes', style: theme.textTheme.muted),
      ],
    );
  }
}
