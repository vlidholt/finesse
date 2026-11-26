import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The picker in the page, with an opacity track. Drag in the area and on
/// the tracks, type a hex, or pick a swatch; every part answers the arrow
/// keys.
class ColorPickerInlineExample extends StatefulWidget {
  const ColorPickerInlineExample({super.key});

  @override
  State<ColorPickerInlineExample> createState() =>
      _ColorPickerInlineExampleState();
}

class _ColorPickerInlineExampleState extends State<ColorPickerInlineExample> {
  Color color = const Color(0xCC4338CA);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ColorPicker(
        value: color,
        showAlpha: true,
        swatches: const [
          Color(0xFF4338CA),
          Color(0xFF0F766E),
          Color(0xFFB45309),
          Color(0x804338CA),
        ],
        onChanged: (value) => setState(() => color = value),
      ),
    );
  }
}
