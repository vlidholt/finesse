import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/icon_button/icon_button_sizes.dart';
import 'package:example/docs/examples/icon_button/icon_button_tooltip.dart';
import 'package:example/docs/examples/icon_button/icon_button_variants.dart';

final iconButtonDoc = ComponentDoc(
  slug: 'icon_button',
  title: 'Icon Button',
  description:
      'A square button holding a single icon. It is a `Button` in the '
      'square sizes, with the name an icon-only control needs.',
  examples: [
    ComponentExample(
      id: 'icon_button_variants',
      title: 'Variants',
      builder: (_) => const IconButtonVariantsExample(),
    ),
    ComponentExample(
      id: 'icon_button_tooltip',
      title: 'With a tooltip',
      description:
          'An icon alone says little. `tooltip` names the button on hover, '
          'on keyboard focus and on a long press, and is what a screen '
          'reader calls it unless `semanticLabel` says otherwise. '
          '`loading` swaps the icon for a spinner, as on `Button`.',
      builder: (_) => const IconButtonTooltipExample(),
    ),
    ComponentExample(
      id: 'icon_button_sizes',
      title: 'Sizes and style',
      description:
          '`size` takes the three button sizes and reads them as the '
          'theme\'s square ones, which size the glyph on their own. Anything '
          'else is the `style`, the same `ButtonTheme` a `Button` takes: '
          'its width, height, padding and icon size replace the size\'s.',
      builder: (_) => const IconButtonSizesExample(),
    ),
  ],
);
