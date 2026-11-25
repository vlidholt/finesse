import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/chip/chip_filters.dart';
import 'package:example/docs/examples/chip/chip_group.dart';
import 'package:example/docs/examples/chip/chip_group_scroll.dart';
import 'package:example/docs/examples/chip/chip_removable.dart';
import 'package:example/docs/examples/chip/chip_variants.dart';

final chipDoc = ComponentDoc(
  slug: 'chip',
  title: 'Chip',
  description:
      'A compact pill for a filter, a choice or a tag. With `onSelected` '
      'it toggles, with `onPressed` it is a button, and with neither it '
      'is a static tag. Its height follows the form factor. `onDeleted` '
      'adds a cross that removes it, `showCheckmark` a check while it is '
      'selected, and `ChipGroup` holds the chosen chip (`ChipGroup.multiple` '
      'the chosen set).',
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
          '`onDeleted` adds a cross with its own target and its own name '
          'for assistive technology (`deleteSemanticLabel`). Backspace or '
          'Delete on the focused chip removes it as well.',
      builder: (_) => const ChipRemovableExample(),
    ),
    ComponentExample(
      id: 'chip_group',
      title: 'A group',
      description:
          '`ChipGroup.multiple` is controlled: `values` is the chosen set '
          'and `onValuesChanged` reports the set a tap would make. It is '
          'one Tab '
          'stop; the arrow keys, Home and End move between its chips. '
          '`showCheckmark` marks the chosen ones.',
      builder: (_) => const ChipGroupExample(),
    ),
    ComponentExample(
      id: 'chip_group_scroll',
      title: 'A scrolling filter bar',
      description:
          '`wrap: false` keeps the chips on one row that scrolls and '
          'fades at an edge it continues beyond. `ChipGroup` with `value` '
          'and `allowDeselection: false` makes it a choice of exactly one. '
          'Give the '
          "page's margin as `padding` so the chips scroll to the screen's "
          'edge. `leading` and `trailing` hold an action beside the '
          'chips — here the order — that stays put while they scroll.',
      builder: (_) => const ChipGroupScrollExample(),
    ),
  ],
);
