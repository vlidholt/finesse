import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/icon_button/icon_button_tooltip.dart';
import 'package:example/docs/examples/icon_button/icon_button_variants.dart';

final iconButtonDoc = ComponentDoc(
  slug: 'icon_button',
  title: 'Icon Button',
  description: 'A square button holding a single icon.',
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
  ],
);
