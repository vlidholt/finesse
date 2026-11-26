import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Rows that cannot be chosen are dimmed. The wheel rolls on past them and
/// never reports one.
class WheelPickerDisabledExample extends StatefulWidget {
  const WheelPickerDisabledExample({super.key});

  @override
  State<WheelPickerDisabledExample> createState() =>
      _WheelPickerDisabledExampleState();
}

class _WheelPickerDisabledExampleState
    extends State<WheelPickerDisabledExample> {
  static const _slots = {
    '09:00': true,
    '09:30': true,
    '10:00': false,
    '10:30': false,
    '11:00': true,
    '11:30': false,
    '12:00': true,
  };

  String slot = '09:30';

  @override
  Widget build(BuildContext context) {
    return WheelPicker<String>(
      semanticLabel: 'Time slot',
      value: slot,
      onChanged: (value) => setState(() => slot = value),
      items: [
        for (final MapEntry(key: time, value: free) in _slots.entries)
          WheelPickerItem(value: time, label: time, enabled: free),
      ],
    );
  }
}
