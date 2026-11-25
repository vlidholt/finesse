import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/glass/glass_levels.dart';
import 'package:example/docs/examples/glass/glass_scrim.dart';
import 'package:example/docs/examples/glass/glass_toolbar.dart';

final glassDoc = ComponentDoc(
  slug: 'glass',
  title: 'Glass',
  description:
      'A frosted surface: a translucent tint over a blurred, saturated '
      'backdrop, with a hairline border. Blur, saturation and opacity come '
      'from the style, so `Glass` follows the theme and its brightness.',
  examples: [
    ComponentExample(
      id: 'glass_levels',
      title: 'Regular and strong',
      description:
          '`level` picks how much of the backdrop shows through. Use '
          '`GlassLevel.strong` for a surface that carries text.',
      minPreviewHeight: 320,
      builder: (_) => const GlassLevelsExample(),
    ),
    ComponentExample(
      id: 'glass_scrim',
      title: 'A dark scrim',
      description:
          '`color` replaces the tint and is used at its own alpha. A dark '
          'scrim keeps white labels readable over a photo in both light '
          'and dark themes.',
      minPreviewHeight: 320,
      builder: (_) => const GlassScrimExample(),
    ),
    ComponentExample(
      id: 'glass_toolbar',
      title: 'Floating chrome',
      description:
          'Scroll the list beneath the toolbar. `shadows` are painted '
          'outside the surface and never show through it. Each `Glass` is '
          'a compositing layer: a handful on screen is fine, a long list '
          'of them is not.',
      minPreviewHeight: 360,
      builder: (_) => const GlassToolbarExample(),
    ),
  ],
  body: (context) => const DocProse(
    children: [
      DocSection(
        title: 'Card, Surface or Glass',
        children: [
          DocParagraph(
            'Three widgets draw a rounded panel, and they differ in where '
            'the panel sits. Pick by that, not by how translucent you want '
            'it: the style decides the translucency of all three.',
          ),
          DocTable(
            columns: ['Widget', 'What it is', 'Use it for'],
            rows: [
              [
                '`Card`',
                'Content on the page. Translucent in the default style but '
                    'never blurred, so a page of them costs nothing per '
                    'frame; it has a title, description and footer, and '
                    'padding from the theme.',
                'A post, a settings group, a stat, a form: anything that '
                    'scrolls with the page.',
              ],
              [
                '`Surface`',
                'The skin of something that floats: the popover\'s or the '
                    'menu\'s colours, hairline, shadow and filter, exactly '
                    'as `Popover` and the menus paint them.',
                'An overlay you place yourself: a search panel under a '
                    'field, a custom menu, a hover preview. `Popover` '
                    'already wraps its content in one.',
              ],
              [
                '`Glass`',
                'The raw material: a tint over the blurred backdrop, with '
                    'a hairline. No padding rules, no text style, no '
                    'meaning.',
                'Floating chrome over content that moves: a toolbar, a '
                    'pill, a label on a photo. Pass `frosted: false` '
                    'inside scrolling content.',
              ],
            ],
          ),
          DocParagraph(
            'If you need only the blur, with a tint of your own, that is '
            '`Backdrop`; see Building Blocks.',
          ),
        ],
      ),
    ],
  ),
);
