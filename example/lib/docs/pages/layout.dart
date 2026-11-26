import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/layout/layout_card_sections.dart';
import 'package:example/docs/examples/layout/layout_form_actions.dart';
import 'package:example/docs/examples/layout/layout_gap.dart';
import 'package:example/docs/examples/layout/layout_gap_scale.dart';
import 'package:example/docs/examples/layout/layout_named_gaps.dart';
import 'package:example/docs/examples/layout/layout_padding.dart';
import 'package:example/docs/examples/layout/layout_spacing.dart';

final layoutDoc = ComponentDoc(
  slug: 'layout',
  title: 'Layout and Spacing',
  description:
      'Space between things comes from the theme: a scale of five named '
      'gaps that follows the form factor, and a spacing step for '
      'everything measured in units.',
  body: (context) => DocProse(
    children: [
      const DocSection(
        title: 'Name the relationship, not the pixel count',
        children: [
          DocParagraph(
            'A layout rarely means "16 pixels". It means "these are two '
            'cards" or "this label belongs to that icon". `GapSize` names '
            'those relationships, and the theme decides what each one '
            'measures:',
          ),
          DocBullets(
            items: [
              '`GapSize.xs`, 4: between an icon and its label.',
              '`GapSize.sm`, 8: between related controls.',
              '`GapSize.md`, 12: between the rows of a group.',
              '`GapSize.lg`, 16 on a desktop and 12 on a phone: between '
                  'cards and sections.',
              '`GapSize.xl`, 24 on a desktop and 16 on a phone: between '
                  'the columns of a page.',
            ],
          ),
          DocParagraph(
            'Because the name is resolved against the theme, the same '
            'line of code yields 16 in a desktop window and 12 on a phone. '
            'Nothing in the layout checks which it is in.',
          ),
        ],
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_gap_scale',
          title: 'The gap scale',
          description:
              'Each bar is as wide as its gap. The two largest steps '
              'tighten on a phone; the three small ones hold.',
          builder: (_) => const LayoutGapScaleExample(),
        ),
      ),
      const DocSection(
        title: 'Using the scale',
        children: [
          DocParagraph(
            '`UnaRow` and `UnaColumn` take a `gap` and put it '
            'between every child. In a plain `Row` or `Column`, where '
            'only some children need space between them, use a `Gap`: '
            '`Gap.xs()` to `Gap.xl()`, or `Gap.size(size)` for a step '
            'held in a variable. A `Gap` sizes itself along whichever '
            'axis its flex runs.',
          ),
          CodeBlock(
            code: '''
UnaColumn(
  gap: GapSize.lg, // 16 on a desktop, 12 on a phone
  children: [
    const ProfileCard(),
    const ActivityCard(),
  ],
)

Row(
  children: [
    const PhosphorIcon(PhosphorIconsRegular.mapPin),
    const Gap.xs(),
    const Text('Copenhagen'),
    const Gap.md(),
    const Text('Hybrid'),
  ],
)''',
          ),
        ],
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_named_gaps',
          title: 'A card in named gaps',
          description:
              '`lg` between the sections, `sm` between the two buttons, '
              '`xs` between the pin and the place.',
          minPreviewHeight: 280,
          builder: (_) => const LayoutNamedGapsExample(),
        ),
      ),
      const DocSection(
        title: 'The layout theme',
        children: [
          DocParagraph(
            'The scale lives on `ThemeData.layoutTheme`, a `LayoutTheme`, '
            'together with the page margins and the page width. The '
            'style fills it in for the current form factor. Read it for '
            'a value the layout widgets do not cover, and override it '
            'like any other component theme:',
          ),
          CodeBlock(
            code: '''
// Reading: padding that matches the gap between cards.
final layout = Theme.of(context).layoutTheme;
EdgeInsets.all(layout.gap(GapSize.lg));

// Overriding: a roomier app.
ThemeData(
  layoutTheme: const LayoutTheme(
    gapLg: 20,
    gapXl: 32,
    pageMaxWidth: 1120,
  ),
)''',
          ),
          DocParagraph(
            'To change the scale for one form factor only, set the '
            "style's tokens instead: `gapLg` and `gapXl` on "
            '`StyleTokens`, and on its `mobile` counterpart.',
          ),
        ],
      ),
      const DocSection(
        title: 'Page margins',
        children: [
          DocParagraph(
            '`PageContainer` is the gap scale\'s counterpart for a whole '
            'page: it applies `layoutTheme.pagePadding` (24 on a desktop, '
            '16 on a phone), caps the content at `pageMaxWidth` and '
            'centres it. An `AppBar` caps its content to match, so the '
            'bar and the page line up. See the Page Container page.',
          ),
          CodeBlock(
            code: '''
Scaffold(
  appBar: const AppBar(title: Text('Jobs')),
  body: PageContainer(
    scrollable: true,
    child: UnaColumn(gap: GapSize.lg, children: sections),
  ),
)''',
          ),
        ],
      ),
      const DocSection(
        title: 'Spacing steps',
        children: [
          DocParagraph(
            'The second scale is numeric. `ThemeData.spacing` is one '
            'step, 4 logical pixels by default, and `spacing: 3`, '
            '`Gap(2)` and `UnaPadding.all(4)` are multiples of it. '
            'Steps do not follow the form factor. They rescale together '
            'when the step changes, and the named gaps scale with them. '
            'Use steps for the inside of a component, where a design '
            'gives a specific measure, and the named gaps for the space '
            'between components.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  spacing: const Spacing(step: 5), // everything in steps grows by a quarter
)''',
          ),
          DocParagraph(
            '`Gap.raw(10)` bypasses both scales, for a value that is '
            'deliberately off them.',
          ),
        ],
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_spacing',
          title: 'Row and column spacing',
          description:
              'Set `spacing` on `UnaRow` or `UnaColumn` to insert '
              'the same number of steps between every child.',
          builder: (_) => const LayoutSpacingExample(),
        ),
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_gap',
          title: 'Gaps in steps',
          description:
              '`Gap(2)` is two steps. Use it in a plain `Row` or `Column` '
              'when only some children need space between them.',
          builder: (_) => const LayoutGapExample(),
        ),
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_padding',
          title: 'Padding',
          description:
              '`UnaPadding` takes steps, not pixels: '
              '`symmetric(horizontal: 6, vertical: 4)` is 24 by 16 at the '
              'default step.',
          builder: (_) => const LayoutPaddingExample(),
        ),
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_card_sections',
          title: 'Card sections',
          description:
              'Use `UnaColumn` with `crossAxisAlignment: stretch` '
              'inside a card. Put `Divider` between groups.',
          builder: (_) => const LayoutCardSectionsExample(),
        ),
      ),
      DocExample(
        slug: 'layout',
        example: ComponentExample(
          id: 'layout_form_actions',
          title: 'Form actions',
          description:
              'Stack fields and buttons in a `UnaColumn`. Put the '
              'primary action above the outline cancel.',
          builder: (_) => const LayoutFormActionsExample(),
        ),
      ),
    ],
  ),
);
