import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/expansion_tile/expansion_tile_plain.dart';
import 'package:example/docs/examples/expansion_tile/expansion_tile_settings.dart';

final expansionTileDoc = ComponentDoc(
  slug: 'expansion_tile',
  title: 'Expansion Tile',
  description:
      'A list row that opens to show rows of its own: settings folded under '
      'a heading, the parts of an order. The heading is a `ListTile` ending '
      'in a caret; the rows unfold on the theme\'s spring. For panels of '
      'content rather than rows, use `Accordion` or `Collapsible`.',
  examples: [
    ComponentExample(
      id: 'expansion_tile_settings',
      title: 'In a section',
      description:
          'Inside a `ListSection` the heading and its rows take the '
          'section\'s padding and fill to the card\'s corners. `value` '
          'sums up what is folded away.',
      builder: (_) => const ExpansionTileSettingsExample(),
    ),
    ComponentExample(
      id: 'expansion_tile_plain',
      title: 'Held by the parent',
      description:
          '`open` and `onOpenChanged` hold the state outside the row; '
          '`initiallyOpen` lets it keep its own. `childrenPadding` indents '
          'the rows.',
      builder: (_) => const ExpansionTilePlainExample(),
    ),
  ],
);
