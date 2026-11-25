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
