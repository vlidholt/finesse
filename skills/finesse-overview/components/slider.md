# Slider

An input where the user selects a value from within a given range. Give `value` to hold it yourself or `initialValue` to let the slider keep it; `RangeSlider` has a thumb per value. `SliderFormField` puts a slider in a form.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SliderBasicExample extends StatelessWidget {
  const SliderBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: Slider(
        initialValue: 33,
        max: 100,
      ),
    );
  }
}
```

## Range

RangeSlider takes one value per thumb. The values stay in ascending order — a thumb stops where its neighbour is rather than crossing it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SliderRangeExample extends StatefulWidget {
  const SliderRangeExample({super.key});

  @override
  State<SliderRangeExample> createState() => _SliderRangeExampleState();
}

class _SliderRangeExampleState extends State<SliderRangeExample> {
  List<double> values = const [25, 75];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            // The values stay ascending, so the ends of the range are always
            // the first and last entry.
            '\$${values.first.round()} – \$${values.last.round()}',
            style: theme.textTheme.small,
          ),
          RangeSlider(
            initialValues: values,
            max: 100,
            onChanged: (next) => setState(() => values = next),
          ),
        ],
      ),
    );
  }
}
```

## Steps

With divisions the slider snaps; set showDivisionMarks to false to snap without drawing the ticks.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class SliderStepsExample extends StatelessWidget {
  const SliderStepsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          Slider(initialValue: 50, max: 100, divisions: 10),
          Slider(
            initialValue: 50,
            max: 100,
            divisions: 10,
            showDivisionMarks: false,
          ),
        ],
      ),
    );
  }
}
```

## Value indicator

`valueIndicator` shows the value in a bubble above the thumb: `whileDragging` (also on hover and keyboard focus) or `always`. `valueLabel` formats it, for the bubble and for assistive technology. On a touch screen a stepped slider ticks at each stop.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The value in a bubble above the thumb: while the thumb is dragged,
/// hovered or focused, or always. `valueLabel` writes it.
class SliderValueIndicatorExample extends StatefulWidget {
  const SliderValueIndicatorExample({super.key});

  @override
  State<SliderValueIndicatorExample> createState() =>
      _SliderValueIndicatorExampleState();
}

class _SliderValueIndicatorExampleState
    extends State<SliderValueIndicatorExample> {
  double volume = 40;
  List<double> price = const [200, 650];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: FinesseColumn(
        mainAxisSize: MainAxisSize.min,
        gap: GapSize.xl,
        children: [
          const Gap.lg(),
          Slider(
            semanticLabel: 'Volume',
            value: volume,
            max: 100,
            valueIndicator: SliderValueIndicator.whileDragging,
            valueLabel: (value) => '${value.round()}%',
            onChanged: (value) => setState(() => volume = value),
          ),
          RangeSlider(
            semanticLabel: 'Price',
            values: price,
            max: 1000,
            divisions: 20,
            showDivisionMarks: false,
            valueIndicator: SliderValueIndicator.always,
            valueLabel: (value) => '\$${value.round()}',
            onChanged: (values) => setState(() => price = values),
          ),
        ],
      ),
    );
  }
}
```

## Controlled

With `value` the slider shows what the parent holds and reports a change without making it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A controlled slider: the parent holds the value, so buttons beside it
/// can move the thumb too, and a value the parent rounds stays rounded.
class SliderControlledExample extends StatefulWidget {
  const SliderControlledExample({super.key});

  @override
  State<SliderControlledExample> createState() =>
      _SliderControlledExampleState();
}

class _SliderControlledExampleState extends State<SliderControlledExample> {
  double brightness = 60;

  void _set(double value) =>
      setState(() => brightness = value.clamp(0, 100).roundToDouble());

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: FinesseRow(
        gap: GapSize.sm,
        children: [
          IconButton.ghost(
            semanticLabel: 'Dimmer',
            icon: const PhosphorIcon(PhosphorIconsRegular.sunDim),
            onPressed: () => _set(brightness - 10),
          ),
          Expanded(
            child: Slider(
              semanticLabel: 'Brightness',
              value: brightness,
              max: 100,
              onChanged: _set,
            ),
          ),
          IconButton.ghost(
            semanticLabel: 'Brighter',
            icon: const PhosphorIcon(PhosphorIconsRegular.sun),
            onPressed: () => _set(brightness + 10),
          ),
          SizedBox(
            width: 44,
            child: Text('${brightness.round()}%', textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
```

