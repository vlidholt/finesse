import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/icons/icons_duotone.dart';
import 'package:example/docs/examples/icons/icons_sample.dart';
import 'package:example/docs/examples/icons/icons_selected.dart';
import 'package:example/docs/examples/icons/icons_sizing.dart';
import 'package:example/docs/examples/icons/icons_weights.dart';

final iconsDoc = ComponentDoc(
  slug: 'icons',
  title: 'Icons',
  description:
      'The Phosphor icon set ships inside the package: 1,512 icons in six '
      'weights, exported from the same import as everything else.',
  body: (context) => DocProse(
    children: [
      const DocSection(
        title: 'Using an icon',
        children: [
          DocParagraph(
            'Each weight is a class of constants named after the icon: '
            '`PhosphorIconsThin`, `PhosphorIconsLight`, '
            '`PhosphorIconsRegular`, `PhosphorIconsBold`, '
            '`PhosphorIconsFill` and `PhosphorIconsDuotone`. Five of them '
            'hold plain `IconData`, drawn by Flutter\'s own `Icon`:',
          ),
          CodeBlock(
            code: '''
import 'package:finesse/finesse.dart';

const Icon(PhosphorIconsRegular.house)''',
          ),
          DocParagraph(
            'The fonts are bundled with finesse, so there is no second '
            'dependency and nothing to declare in your pubspec. The '
            'constants are `const IconData`, which keeps Flutter\'s icon '
            'tree-shaking working: a release build carries only the '
            'glyphs the app uses.',
          ),
        ],
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_weights',
          title: 'The six weights',
          description:
              'Regular is the weight the components use. Pick one weight '
              'for an app and keep to it.',
          builder: (_) => const IconsWeightsExample(),
        ),
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_selected',
          title: 'Regular and fill for selected states',
          description:
              'The convention throughout finesse: the regular weight at '
              'rest, the fill weight of the same icon when selected. It '
              'is what `NavigationDestination.selectedIcon` is for.',
          builder: (_) => const IconsSelectedExample(),
        ),
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_duotone',
          title: 'Duotone',
          description:
              'A duotone icon is two glyphs, so `PhosphorIconsDuotone.x` '
              'is a `PhosphorDuotoneIconData` and is drawn by '
              '`PhosphorDuotoneIcon`, not by `Icon`. Size and colour '
              'default to the ambient `IconTheme`.',
          builder: (_) => const IconsDuotoneExample(),
        ),
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_sizing',
          title: 'Sizes come from the theme',
          description:
              'A button hands its icon size down through an `IconTheme`. '
              'In the default style that is 18 in a regular button, 16 in '
              'a small one and 20 in an icon button; every style sets its '
              'own. Leave `size` off and an icon is right wherever it is '
              'put.',
          builder: (_) => const IconsSizingExample(),
        ),
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_sample',
          title: 'A sample',
          description:
              'Browse the full set at phosphoricons.com. A name there '
              'becomes camelCase here: `chat-circle-dots` is '
              '`chatCircleDots`.',
          minPreviewHeight: 320,
          builder: (_) => const IconsSampleExample(),
        ),
      ),
      const DocSection(
        title: 'Direction',
        children: [
          DocParagraph(
            'The constants do not mirror themselves in right-to-left '
            'layouts: flipping every icon would also flip checkmarks and '
            'logos. Components that need a directional chevron pick the '
            'right one themselves; in your own code choose between '
            '`caretLeft` and `caretRight` from `Directionality.of(context)`.',
          ),
        ],
      ),
      const DocSection(
        title: 'Other icon sets',
        children: [
          DocParagraph(
            'Nothing ties a component to Phosphor. Every icon slot takes '
            'a widget, so an `Icon` from any other font, an SVG or an '
            'image works in its place.',
          ),
        ],
      ),
      const DocSection(
        title: 'Licence',
        children: [
          DocParagraph(
            'Phosphor Icons are MIT licensed. The notice is part of '
            "finesse's own `LICENSE`, which Flutter collects onto an "
            "app's licence page automatically.",
          ),
        ],
      ),
    ],
  ),
);
