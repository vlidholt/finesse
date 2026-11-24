import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/icons/icons_duotone.dart';
import 'package:example/docs/examples/icons/icons_optical_weight.dart';
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
            'hold plain `IconData`. Draw a regular icon with '
            '`PhosphorIcon`, which is Flutter\'s `Icon` with one addition: '
            'it keeps a small icon\'s line from thinning with its size.',
          ),
          CodeBlock(
            code: '''
import 'package:finesse/finesse.dart';

const PhosphorIcon(PhosphorIconsRegular.house)''',
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
      const DocSection(
        title: 'Optical weight',
        children: [
          DocParagraph(
            'The regular weight draws its line as a fixed share of the '
            'icon: a sixteenth of its size. That is 1.5 pixels at 24 but '
            '1 at 16 and 0.75 at 12, so small icons look thin beside '
            'large ones. `PhosphorIcon` resolves its size as an `Icon` '
            'does — its own `size`, or the `IconTheme` a button or a '
            'navigation bar hands down — and gives a `PhosphorIconsRegular` '
            'icon smaller than 24 a fine outline in its own colour, which '
            'thickens every line by the same amount. By default it makes '
            'up half of what the font loses: 1.38 pixels at 20, 1.25 at '
            '16, 1.13 at 12. The change is continuous, so no size is a '
            'step heavier than its neighbour, and it needs only the '
            'regular font.',
          ),
          DocParagraph(
            'Only regular icons are thickened. `PhosphorIconsBold`, '
            '`Light`, `Thin` and `Fill` are your own choice of weight and '
            'are drawn as given, as is an icon from another font and any '
            'icon of 24 or more. Everything else is `Icon`\'s: the same '
            'parameters, the same box, the same semantics, and in a test '
            '`find.byIcon(PhosphorIconsRegular.house)` finds it. To keep '
            'one small icon at the font\'s own line, use a plain `Icon`.',
          ),
        ],
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_optical_weight',
          title: 'A line that holds as the icon shrinks',
          description:
              'One icon from 12 to 24 with the width of its line, and the '
              'same row at strength 0, which is the font on its own.',
          builder: (_) => const IconsOpticalWeightExample(),
        ),
      ),
      const DocSection(
        title: 'Changing the strength',
        children: [
          DocParagraph(
            'Two style tokens set it: `iconOpticalSize`, the size at '
            'which an icon is drawn as the font has it (24), and '
            '`iconOpticalStrength`, how much of the difference a smaller '
            'icon makes up, from 0 (nothing, which switches it off) to 1 '
            '(every icon below 24 has the 1.5 pixel line of one at 24). '
            'The theme resolves them into `ThemeData.phosphorIconTheme`, '
            'which can also be set directly, for the app or for a '
            'subtree:',
          ),
          CodeBlock(
            code: '''
// For the app: a stronger correction.
ThemeData(
  style: StyleTokens.finesse.copyWith(iconOpticalStrength: .8),
)

// Off, here only.
Theme(
  data: Theme.of(context).copyWith(
    phosphorIconTheme: const PhosphorIconTheme(strength: 0),
  ),
  child: toolbar,
)''',
          ),
        ],
      ),
      DocExample(
        slug: 'icons',
        example: ComponentExample(
          id: 'icons_weights',
          title: 'The six weights',
          description:
              'Regular is the weight the components use, and the one '
              '`PhosphorIcon` thickens when small. Pick one weight for an '
              'app and keep to it.',
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
            'image works in its place. A `PhosphorIcon` given another '
            'font\'s `IconData` draws it unchanged.',
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
