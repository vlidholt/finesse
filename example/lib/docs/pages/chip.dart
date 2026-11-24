import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/chip/chip_filters.dart';
import 'package:example/docs/examples/chip/chip_removable.dart';
import 'package:example/docs/examples/chip/chip_variants.dart';

final chipDoc = ComponentDoc(
  slug: 'chip',
  title: 'Chip',
  description:
      'A compact pill for a filter, a choice or a tag. With `onSelected` '
      'it toggles, with `onPressed` it is a button, and with neither it '
      'is a static tag. Its height follows the form factor.',
  examples: [
    ComponentExample(
      id: 'chip_filters',
      title: 'Filters',
      description:
          '`onSelected` is called with the opposite of `selected`; the '
          'caller keeps the state.',
      builder: (_) => const ChipFiltersExample(),
    ),
    ComponentExample(
      id: 'chip_variants',
      title: 'Variants',
      description:
          '`ChipVariant.outline` is the default. `soft` is a muted fill '
          'for read-only tags, and `dashed` marks something absent or '
          'suggested.',
      minPreviewHeight: 300,
      builder: (_) => const ChipVariantsExample(),
    ),
    ComponentExample(
      id: 'chip_removable',
      title: 'Removable',
      description:
          'A trailing icon and `onPressed`. Give an icon-led action a '
          '`semanticLabel` that says what the tap does.',
      builder: (_) => const ChipRemovableExample(),
    ),
  ],
);
