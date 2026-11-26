import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/color_picker/color_picker_button.dart';
import 'package:example/docs/examples/color_picker/color_picker_inline.dart';

final colorPickerDoc = ComponentDoc(
  slug: 'color_picker',
  title: 'Color Picker',
  description:
      'A colour chosen by eye, by number or from a list, as iOS and macOS '
      'offer it: a spectrum (an area for saturation and brightness over a '
      'hue track), a grid of twelve hues in nine shades, or red, green and '
      'blue sliders, switched by a segmented control; then an opacity '
      'track, a hex field and swatches. `modes` picks which of the three '
      'are offered, and a null `onChanged` disables it. '
      '`ColorPickerButton` puts it behind a swatch, in a popover or, on a '
      'phone, a bottom sheet.',
  examples: [
    ComponentExample(
      id: 'color_picker_button',
      title: 'Behind a swatch',
      description:
          '`ColorPickerButton` is controlled like the picker. '
          '`presentation` forces the popover or the sheet.',
      builder: (_) => const ColorPickerButtonExample(),
    ),
    ComponentExample(
      id: 'color_picker_inline',
      title: 'In the page',
      description:
          '`showAlpha` adds the opacity track and writes the hex with '
          'its alpha. `colorToHex` and `colorFromHex` convert.',
      minPreviewHeight: 520,
      builder: (_) => const ColorPickerInlineExample(),
    ),
  ],
);
