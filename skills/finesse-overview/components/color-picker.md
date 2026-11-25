# Color Picker

A colour chosen by eye, by number or from a list: an area for saturation and brightness, tracks for the hue and the opacity, a hex field and swatches. `ColorPickerButton` puts it behind a swatch, in a popover or, on a phone, a bottom sheet.

## Behind a swatch

`ColorPickerButton` is controlled like the picker. `presentation` forces the popover or the sheet.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
    return FinesseRow(
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
```

## In the page

`showAlpha` adds the opacity track and writes the hex with its alpha. `colorToHex` and `colorFromHex` convert.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
```

