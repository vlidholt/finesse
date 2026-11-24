import 'package:example/docs/docs.dart';

final stylesDoc = ComponentDoc(
  slug: 'styles',
  title: 'Styles',
  description:
      'The eight shadcn styles are complete presets for geometry, '
      'typography, and shadows, switchable with one line.',
  body: (context) => const DocProse(
    children: [
      DocParagraph(
        'shadcn/ui ships eight named styles, and they are not color '
        'variations. Each one is a full geometry set. A mira button is '
        '28px tall with 8px of padding where a sera button is 40px with '
        '24px, and inputs, menu rows, cards, sliders, and switches move '
        'with them. Styles also retype the UI, each redefines the title, '
        'label, body, caption, and field roles, and reshape it with their '
        'own radii and shadows. Every value was read from the reference '
        'CSS.',
      ),
      DocSection(
        title: 'Choosing a style',
        children: [
          CodeBlock(
            code: '''
ThemeData(
  style: StyleTokens.maia,
)''',
          ),
          DocBullets(
            items: [
              '`vega`: the classic. 36px controls, moderate radii, subtle '
                  'shadows.',
              '`nova`: the default. Vega, condensed to 32px controls and '
                  'tighter surfaces.',
              '`maia`: pill-shaped and roomy, with fully rounded controls.',
              '`lyra`: square. No radii, flat shadows, 12px body text.',
              '`mira`: the densest. 28px controls on a relaxed 12px line.',
              '`luma`: soft. Filled fields, large radii, weighty shadows.',
              '`sera`: editorial. 40px controls, underlined fields, '
                  'uppercase labels, generous space.',
              '`rhea`: gently rounded mid-size controls with soft '
                  'hairlines.',
            ],
          ),
          DocParagraph(
            'Try them live: open the theme editor with the paintbrush '
            'button above and switch styles. The whole app follows.',
          ),
        ],
      ),
      DocSection(
        title: 'Picking at runtime',
        children: [
          DocParagraph(
            'The presets are values on `StyleTokens`, so a style '
            'switcher is a list and a lookup:',
          ),
          CodeBlock(
            code: '''
StyleTokens.all;              // the eight presets
StyleTokens.fromName('sera'); // one, by its shadcn name''',
          ),
        ],
      ),
      DocSection(
        title: 'Custom styles',
        children: [
          DocParagraph(
            'A style is data, a set of measured tokens. Derive your own '
            'from the preset closest to what you want:',
          ),
          CodeBlock(
            code: '''
ThemeData(
  style: StyleTokens.nova.copyWith(
    buttonRadius: RadiusToken.full,
    buttonHeight: 40,
  ),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Spacing',
        children: [
          DocParagraph(
            "Metrics the reference writes in Tailwind's spacing units "
            "follow the theme's `Spacing` step: 4px, like "
            '`0.25rem`. Raising it loosens every unit-derived padding and '
            'gap in one move:',
          ),
          CodeBlock(
            code: '''
ThemeData(
  spacing: const Spacing(step: 5),
)''',
          ),
        ],
      ),
    ],
  ),
);
