import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/layout/layout_card_sections.dart';
import 'package:example/docs/examples/layout/layout_form_actions.dart';
import 'package:example/docs/examples/layout/layout_gap.dart';
import 'package:example/docs/examples/layout/layout_padding.dart';
import 'package:example/docs/examples/layout/layout_spacing.dart';

final layoutDoc = ComponentDoc(
  slug: 'layout',
  title: 'Layout',
  description:
      'Layout widgets measure gaps and padding in theme spacing steps: '
      '`FinesseRow`, `FinesseColumn`, `Gap`, and `FinessePadding`.',
  examples: [
    ComponentExample(
      id: 'layout_spacing',
      title: 'Row and column spacing',
      description:
          'Set `spacing` on `FinesseRow` or `FinesseColumn` to insert the same '
          'gap between every child.',
      builder: (_) => const LayoutSpacingExample(),
    ),
    ComponentExample(
      id: 'layout_gap',
      title: 'Gaps',
      description:
          'Use `Gap` in a plain `Row` or `Column` when only some '
          'children need space between them.',
      builder: (_) => const LayoutGapExample(),
    ),
    ComponentExample(
      id: 'layout_padding',
      title: 'Padding',
      description:
          '`FinessePadding` maps Tailwind inset classes to theme steps. '
          '`symmetric(horizontal: 6, vertical: 4)` matches `px-6 py-4`.',
      builder: (_) => const LayoutPaddingExample(),
    ),
    ComponentExample(
      id: 'layout_card_sections',
      title: 'Card sections',
      description:
          'Use `FinesseColumn` with `crossAxisAlignment: stretch` inside a '
          'card. Put `Divider` between groups.',
      builder: (_) => const LayoutCardSectionsExample(),
    ),
    ComponentExample(
      id: 'layout_form_actions',
      title: 'Form actions',
      description:
          'Stack fields and buttons in a `FinesseColumn`. Put the primary '
          'action above the outline cancel.',
      builder: (_) => const LayoutFormActionsExample(),
    ),
  ],
);
