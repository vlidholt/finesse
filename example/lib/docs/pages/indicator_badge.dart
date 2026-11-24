import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/indicator_badge/indicator_badge_count.dart';
import 'package:example/docs/examples/indicator_badge/indicator_badge_presence.dart';
import 'package:example/docs/examples/indicator_badge/indicator_badge_standalone.dart';

final indicatorBadgeDoc = ComponentDoc(
  slug: 'indicator_badge',
  title: 'Indicator Badge',
  description:
      'A small count or dot pinned to the corner of another widget: '
      'unread messages on an icon, presence on an avatar. For a label '
      'that stands in the flow of text, use `Badge`.',
  examples: [
    ComponentExample(
      id: 'indicator_badge_count',
      title: 'Counts on icons',
      description:
          'With a `count` the badge is a pill, and above `maxCount` it '
          'reads `99+`. With no count it is a dot. A ring in the colour '
          'of the surface behind keeps it legible over its child.',
      builder: (_) => const IndicatorBadgeCountExample(),
    ),
    ComponentExample(
      id: 'indicator_badge_presence',
      title: 'A dot on an avatar',
      description:
          '`alignment` picks the corner. `overhang` is how far the badge '
          'hangs outside it, as a fraction of its own size: the default '
          'suits a count on an icon, and 0 keeps a presence dot on the '
          'edge of a round avatar.',
      builder: (_) => const IndicatorBadgePresenceExample(),
    ),
    ComponentExample(
      id: 'indicator_badge_standalone',
      title: 'Standalone',
      description:
          'Leave `child` out to lay the badge out on its own. `label` '
          'shows any widget in place of the number.',
      minPreviewHeight: 280,
      builder: (_) => const IndicatorBadgeStandaloneExample(),
    ),
  ],
);
