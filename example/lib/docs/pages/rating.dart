import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/rating/rating_basic.dart';
import 'package:example/docs/examples/rating/rating_variants.dart';

final ratingDoc = ComponentDoc(
  slug: 'rating',
  title: 'Rating',
  description:
      'A row of stars that shows a rating, and takes one when it is given '
      '`onChanged`. A tap or a drag rates, a mouse previews, the arrow '
      'keys adjust, and assistive technology sees a slider.',
  examples: [
    ComponentExample(
      id: 'rating_basic',
      title: 'Give a rating',
      description: 'Controlled: `value` and `onChanged`.',
      builder: (_) => const RatingBasicExample(),
    ),
    ComponentExample(
      id: 'rating_variants',
      title: 'Read-only, halves and other icons',
      description:
          'Read-only without `onChanged`. `allowHalf`, `count`, `size`, '
          '`color`, `icon` and `selectedIcon` shape it.',
      builder: (_) => const RatingVariantsExample(),
    ),
  ],
);
