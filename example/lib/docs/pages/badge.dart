import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/badge/badge_variants.dart';

final badgeDoc = ComponentDoc(
  slug: 'badge',
  title: 'Badge',
  description:
      'A small pill that states something: a status, a category, a count. '
      'A badge is read, not pressed — a pill that does something is a '
      '`Chip`, and the count on the corner of an icon is an '
      '`IndicatorBadge`.',
  examples: [
    ComponentExample(
      id: 'badge_variants',
      title: 'Variants',
      builder: (_) => const BadgeVariantsExample(),
    ),
  ],
);
