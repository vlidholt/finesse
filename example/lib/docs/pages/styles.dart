import 'package:example/docs/docs.dart';

final stylesDoc = ComponentDoc(
  slug: 'styles',
  title: 'Styles',
  description:
      'A style is a complete preset for geometry, typography, shadows and '
      'translucency. Four ship with una, switchable with one line.',
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
  style: StyleTokens.pebble,
)''',
          ),
          DocBullets(
            items: [
              '`fluid`: the default. Soft glass: 36px buttons and 40px '
                  'fields, controls rounded to 10 and cards to 18, with '
                  'translucent cards and outline buttons, and bars, menus '
                  'and popovers over a blurred backdrop. It has '
                  'hand-measured phone metrics.',
              '`crisp`: compact and neutral. 32px controls, moderate '
                  'radii, opaque surfaces.',
              '`pebble`: pill-shaped and roomy, with fully rounded '
                  'controls.',
              '`sharp`: square and compact. No radii, flat shadows, 12px '
                  'body text.',
            ],
          ),
          DocParagraph(
            '`crisp`, `pebble` and `sharp` are made from three of the '
            "styles of shadcn/ui (Nova, Maia and Lyra), measured from its "
            'CSS. `fluid` is the '
            "package's own, measured from the designs of Demo, the app at "
            '`https://vlidholt.github.io/una_demo/`.',
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
StyleTokens.fromName('sharp'); // one, by name''',
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
  style: StyleTokens.crisp.copyWith(
    buttonRadius: RadiusToken.full,
    buttonHeight: 40,
  ),
)''',
          ),
          DocParagraph(
            '`copyWith` changes the set of metrics it is called on. '
            '`crisp`, `pebble` and `sharp` derive their phone metrics '
            'from the result, so one call covers both. `fluid` has its '
            'own, `fluidMobile`: `copyWith` carries a change to them for '
            'every field the two share, and a field the phone sets '
            'differently (control heights, page margins) is changed '
            'there by passing `mobile:` as well.',
          ),
        ],
      ),
      DocSection(
        title: 'Desktop and phone',
        children: [
          DocParagraph(
            'Every style carries a second set of metrics for a phone: '
            'larger touch targets, larger body text, tighter page '
            'margins. `fluid` defines its own; the others derive '
            'theirs. `UnaApp` picks between the two from the window '
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
            'each opacity. An opaque style such as `crisp` pays for no '
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
  style: opaque(StyleTokens.fluid).copyWith(
    mobile: opaque(StyleTokens.fluidMobile),
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
  style: StyleTokens.fluid.copyWith(cardBlur: true),
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
