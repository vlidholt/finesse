# Wheel Picker

A wheel of rows, one of which rests under a lens: the way a phone chooses from a short, ordered list. It scrolls with momentum and settles on a row, ticks under a finger, moves a row per notch of a mouse wheel and follows the arrow keys. `TimePicker` and `DatePicker` open wheels in a sheet on a phone.

## One wheel

Controlled: `onChanged` reports the row under the lens as the wheel turns, and the wheel rests on `value`. Drag it, click a row, or focus it and type.

```dart
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
```

## A group under one lens

`WheelPickerGroup` draws the lens once across its children and gives its wheels one row height. A child that is not a wheel, such as a unit, is centred on the lens. `looping` makes a wheel go round.

```dart
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
```

## A long list

`WheelPicker.builder` makes rows on demand; `indexOf` is the inverse of `itemBuilder`. A value set from outside is rolled to.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A long list is built a row at a time: three centuries of years cost no
/// more than the rows in view.
class WheelPickerBuilderExample extends StatefulWidget {
  const WheelPickerBuilderExample({super.key});

  @override
  State<WheelPickerBuilderExample> createState() =>
      _WheelPickerBuilderExampleState();
}

class _WheelPickerBuilderExampleState extends State<WheelPickerBuilderExample> {
  static const _first = 1800;

  int year = 1969;

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        WheelPicker<int>.builder(
          semanticLabel: 'Year',
          itemCount: 301,
          itemBuilder: (index) => WheelPickerItem(
            value: _first + index,
            label: '${_first + index}',
          ),
          indexOf: (year) => year - _first,
          value: year,
          onChanged: (value) => setState(() => year = value),
        ),
        Button.outline(
          onPressed: () => setState(() => year = DateTime.now().year),
          child: const Text('This year'),
        ),
      ],
    );
  }
}
```

## Rows that cannot be chosen

A row with `enabled: false` is dimmed, skipped by the keyboard, and never rested on.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
```
