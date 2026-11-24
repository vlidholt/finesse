import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/icon_tile/icon_tile_basic.dart';
import 'package:example/docs/examples/icon_tile/icon_tile_stats.dart';

final iconTileDoc = ComponentDoc(
  slug: 'icon_tile',
  title: 'Icon Tile',
  description:
      'An `IconTile` is an icon on a soft, rounded square: the marker '
      'beside a statistic, a file type, a setting. A `StatTile` puts one '
      'on a card next to a headline number and its label.',
  examples: [
    ComponentExample(
      id: 'icon_tile_basic',
      title: 'IconTile',
      description:
          'The accent fill and tint colour are what make a tile read as '
          'part of the brand rather than as a control.',
      builder: (_) => const IconTileBasicExample(),
    ),
    ComponentExample(
      id: 'icon_tile_stats',
      title: 'StatTile',
      description:
          'Wrap each tile in an `Expanded` for a summary strip. '
          '`trailing` holds a trend or a chevron, and `onTap` makes the '
          'tile focusable.',
      minPreviewHeight: 280,
      builder: (_) => const IconTileStatsExample(),
    ),
  ],
);
