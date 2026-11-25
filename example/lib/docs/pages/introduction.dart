import 'package:example/docs/docs.dart';

final introductionDoc = ComponentDoc(
  slug: 'introduction',
  title: 'Introduction',
  description:
      'A design system for Flutter: more than sixty components, four '
      'styles and one theme, laid out for desktop and phone alike.',
  body: (context) => const DocProse(
    children: [
      DocParagraph(
        'finesse is a Flutter implementation of a complete design system. '
        'It began as a port of shadcn/ui and still carries its component '
        'set and three of its styles, measured from the reference CSS. On '
        'top of that it has its own default look, soft teal glass, and '
        'the pieces an app needs beyond a web component kit: app and '
        'navigation bars, a scaffold, list rows, chat bubbles, and a '
        'theme that knows whether it is on a phone.',
      ),
      DocParagraph(
        'The library is self-contained. Components use the Flutter widgets '
        'layer directly, with no Material or Cupertino dependency, and '
        'every visual decision flows from the theme. Restyling an app is '
        'configuration, not surgery: swap the color scheme, the corner '
        'radius, or the entire style preset, and every component follows.',
      ),
      DocSection(
        title: "What's in the box",
        children: [
          DocBullets(
            items: [
              'Components: buttons, forms, menus, dialogs and sheets, '
                  'the command palette, data table, calendar and '
                  'sidebar, plus app structure (`Scaffold`, `AppBar`, '
                  '`NavigationBar`) and content pieces (`ListTile`, '
                  '`Chip`, `ChatBubble`, `Timeline`).',
              'Four styles (`finesse`, the default, and `nova`, `maia`, '
                  '`lyra`) as complete presets: geometry, typography, '
                  'shadows and translucency, switchable with one '
                  'setting.',
              'Two form factors per style. The same widgets come out '
                  'with 36-point buttons in a desktop window and '
                  '44-point ones on a phone.',
              'Four base color schemes (`teal`, the default, `neutral`, '
                  '`zinc` and `stone`), each in light and dark, with '
                  'seventeen accent overlays and three menu finishes: '
                  'inverted, translucent, and bold accent.',
              'The Phosphor icon set in six weights, bundled, and one '
                  'motion vocabulary — springs, entrances and moving '
                  'indicators — so a single import covers them.',
            ],
          ),
        ],
      ),
      DocSection(
        title: 'About these docs',
        children: [
          DocParagraph(
            'Every example on these pages is a real widget. The code under '
            'the Code tab is the exact file the preview runs, bundled into '
            'the app as an asset, so the two can never drift apart.',
          ),
          DocParagraph(
            'This app is itself built with finesse. It opens on Strand, a '
            'small social network that the default theme was designed '
            'for; this component library is its other half. Open the '
            'theme editor with the paintbrush button in the top bar and '
            'change the style, palette, or radius. The whole app '
            'restyles, Strand and these pages included.',
          ),
        ],
      ),
    ],
  ),
);
