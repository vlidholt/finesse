import 'package:example/docs/docs.dart';

final stylesDoc = ComponentDoc(
  slug: 'styles',
  title: 'Styles',
  description:
      'A style is a complete preset for geometry, typography, shadows and '
      'translucency. Four ship with finesse, switchable with one line.',
  body: (context) => const DocProse(
    children: [
      DocParagraph(
        'Styles are not color variations. Each one is a full set of '
        'measurements: control heights and padding, the radius of every '
        'kind of surface, the type roles (title, label, body, caption, '
        'field), the shadows, and how translucent cards and bars are. '
        'Buttons, fields, menu rows, cards, sliders and switches all move '
        'together when the style changes. Color is a separate choice; see '
        'Theming.',
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
              '`finesse`: the default. Soft glass: 36px buttons and 40px '
                  'fields, controls rounded to 10 and cards to 18, with '
                  'translucent cards and outline buttons, and bars, menus '
                  'and popovers over a blurred backdrop. It has '
                  'hand-measured phone metrics.',
              '`nova`: compact and neutral. 32px controls, moderate '
                  'radii, opaque surfaces.',
              '`maia`: pill-shaped and roomy, with fully rounded '
                  'controls.',
              '`lyra`: square and compact. No radii, flat shadows, 12px '
                  'body text.',
            ],
          ),
          DocParagraph(
            '`nova`, `maia` and `lyra` are three of the styles of '
            'shadcn/ui, measured from its CSS. `finesse` is the '
            "package's own, measured from the Strand designs that the "
            'example app opens on.',
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
StyleTokens.all;              // the four presets, the default first
StyleTokens.fromName('lyra'); // one, by name''',
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
          DocParagraph(
            '`copyWith` changes the set of metrics it is called on. '
            '`nova`, `maia` and `lyra` derive their phone metrics from '
            'the result, so one call covers both. `finesse` has a '
            'separate `finesseMobile`: to change it on a phone too, copy '
            'that as well and pass it as `mobile`.',
          ),
        ],
      ),
      DocSection(
        title: 'Desktop and phone',
        children: [
          DocParagraph(
            'Every style carries a second set of metrics for a phone: '
            'larger touch targets, larger body text, tighter page '
            'margins. `finesse` defines its own; the others derive '
            'theirs. `FinesseApp` picks between the two from the window '
            'width. See Form Factors.',
          ),
        ],
      ),
      DocSection(
        title: 'Glass',
        children: [
          DocParagraph(
            'Translucency belongs to the style, not to the color scheme. '
            'The scheme holds the solid `card` and `bar` colors; the '
            'style holds `cardOpacity`, `barOpacity`, `glassOpacity`, '
            '`glassBlur` and `glassSaturation`, with a dark override for '
            'each opacity. An opaque style such as `nova` pays for no '
            'blur at all. To turn the default style opaque, change both '
            'of its sets of metrics:',
          ),
          CodeBlock(
            code: '''
StyleTokens opaque(StyleTokens style) => style.copyWith(
  cardOpacity: 1,
  cardOpacityDark: 1,
  barOpacity: 1,
  barOpacityDark: 1,
);

ThemeData(
  style: opaque(StyleTokens.finesse).copyWith(
    mobile: opaque(StyleTokens.finesseMobile),
  ),
)''',
          ),
          DocParagraph(
            'Bars, popovers, menus, tooltips, toasts and `Glass` filter '
            'their backdrop. Cards do not, in any shipped style: a card '
            'lies on the flat page, where a blur shows nothing and still '
            'costs a backdrop filter for every card on every frame. A '
            'style whose cards float over imagery turns it on with '
            '`cardBlur`, on both sets of metrics:',
          ),
          CodeBlock(
            code: '''
ThemeData(
  style: StyleTokens.finesse.copyWith(cardBlur: true),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Spacing',
        children: [
          DocParagraph(
            'Metrics a style writes in spacing units follow the '
            "theme's `Spacing` step, 4px by default. Raising it loosens "
            'every unit-derived padding and gap in one move:',
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
