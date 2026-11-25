# Progress Ring

A ring that fills as something progresses — an upload, a quota, a goal — or spins while the length is unknown. The circular counterpart of the progress bar.

## A value, with something in the middle

`value` runs from 0 to 1 and the arc eases to each new value on the theme's smooth spring. `child` is centred in the ring: a percentage, an icon. Colours come from the progress bar's theme.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A ring that follows a value: drag the slider and the arc eases to it.
/// The middle of a ring holds a number or an icon.
class ProgressRingBasicExample extends StatefulWidget {
  const ProgressRingBasicExample({super.key});

  @override
  State<ProgressRingBasicExample> createState() =>
      _ProgressRingBasicExampleState();
}

class _ProgressRingBasicExampleState extends State<ProgressRingBasicExample> {
  double value = .64;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: FinesseColumn(
        gap: GapSize.xl,
        mainAxisSize: MainAxisSize.min,
        children: [
          FinesseRow(
            gap: GapSize.xl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressRing(value: value, semanticLabel: 'Upload'),
              ProgressRing(
                value: value,
                size: 72,
                semanticLabel: 'Upload',
                child: Text('$percent%'),
              ),
              ProgressRing(
                value: value,
                size: 72,
                semanticLabel: 'Upload',
                child: PhosphorIcon(
                  value >= 1
                      ? PhosphorIconsRegular.check
                      : PhosphorIconsRegular.arrowUp,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            semanticLabel: 'Progress',
            onChanged: (next) => setState(() => value = next),
          ),
        ],
      ),
    );
  }
}
```

## Gauges and unknown length

A `sweepAngle` of less than a full turn opens the ring at the bottom. With `value: null` the ring spins; `Spinner` stays the small inline indicator for a button or a line of text.

```dart
import 'dart:math' as math;

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A gauge is a ring that stops short of a full turn, and a ring with no
/// value spins: progress of unknown length at any size.
class ProgressRingGaugeExample extends StatelessWidget {
  const ProgressRingGaugeExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseRow(
      gap: GapSize.xl,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(
          value: .72,
          size: 104,
          strokeWidth: 8,
          sweepAngle: math.pi * 1.5,
          semanticLabel: 'Profile strength',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '72',
                style: theme.textTheme.h3.copyWith(
                  color: theme.colorScheme.foreground,
                ),
              ),
              Text('of 100', style: theme.textTheme.caption),
            ],
          ),
        ),
        ProgressRing(
          value: .9,
          size: 104,
          strokeWidth: 8,
          sweepAngle: math.pi,
          color: theme.colorScheme.warning,
          semanticLabel: 'Storage',
          semanticValue: '45 of 50 GB',
          child: const Text('45 GB'),
        ),
        const ProgressRing(value: null, size: 56, semanticLabel: 'Syncing'),
      ],
    );
  }
}
```
