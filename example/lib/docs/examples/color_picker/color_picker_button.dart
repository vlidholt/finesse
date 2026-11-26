import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A swatch that opens the picker: in a popover on a desktop, where the
/// colour is taken as it changes, and in a bottom sheet with Cancel and
/// Done on a phone.
class ColorPickerButtonExample extends StatefulWidget {
  const ColorPickerButtonExample({super.key});

  @override
  State<ColorPickerButtonExample> createState() =>
      _ColorPickerButtonExampleState();
}

class _ColorPickerButtonExampleState extends State<ColorPickerButtonExample> {
  static const _palette = [
    Color(0xFF0F766E),
    Color(0xFFB45309),
    Color(0xFFBE123C),
    Color(0xFF4338CA),
    Color(0xFF15803D),
    Color(0xFF334155),
  ];

  Color label = const Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        ColorPickerButton(
          semanticLabel: 'Label colour',
          value: label,
          swatches: _palette,
          onChanged: (color) => setState(() => label = color),
        ),
        Text(
          colorToHex(label),
          style: theme.textTheme.p.copyWith(color: label),
        ),
      ],
    );
  }
}
