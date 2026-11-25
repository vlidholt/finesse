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
