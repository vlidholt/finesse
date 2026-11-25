import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A timer's length: three wheels under one lens, with their units beside
/// them. The minutes and seconds go round.
class WheelPickerGroupExample extends StatefulWidget {
  const WheelPickerGroupExample({super.key});

  @override
  State<WheelPickerGroupExample> createState() =>
      _WheelPickerGroupExampleState();
}

class _WheelPickerGroupExampleState extends State<WheelPickerGroupExample> {
  Duration length = const Duration(minutes: 12, seconds: 30);

  static List<WheelPickerItem<int>> _numbers(int count) => [
    for (var i = 0; i < count; i++) WheelPickerItem(value: i, label: '$i'),
  ];

  void _set({int? hours, int? minutes, int? seconds}) {
    setState(() {
      length = Duration(
        hours: hours ?? length.inHours,
        minutes: minutes ?? length.inMinutes % 60,
        seconds: seconds ?? length.inSeconds % 60,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.muted;
    return WheelPickerGroup(
      children: [
        WheelPicker<int>(
          semanticLabel: 'Hours',
          alignment: AlignmentDirectional.centerEnd,
          value: length.inHours,
          onChanged: (value) => _set(hours: value),
          items: _numbers(24),
        ),
        Text('h', style: muted),
        WheelPicker<int>(
          semanticLabel: 'Minutes',
          alignment: AlignmentDirectional.centerEnd,
          looping: true,
          value: length.inMinutes % 60,
          onChanged: (value) => _set(minutes: value),
          items: _numbers(60),
        ),
        Text('min', style: muted),
        WheelPicker<int>(
          semanticLabel: 'Seconds',
          alignment: AlignmentDirectional.centerEnd,
          looping: true,
          value: length.inSeconds % 60,
          onChanged: (value) => _set(seconds: value),
          items: _numbers(60),
        ),
        Text('s', style: muted),
      ],
    );
  }
}
