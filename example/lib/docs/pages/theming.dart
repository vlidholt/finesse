import 'package:example/docs/docs.dart';

final themingDoc = ComponentDoc(
  slug: 'theming',
  title: 'Theming',
  description:
      'One ThemeData drives every component: color scheme, radius, '
      'typography, and per-component overrides.',
  body: (context) => const DocProse(
    children: [
      DocSection(
        title: 'Reading the theme',
        children: [
          DocParagraph(
            'Every component resolves its appearance from the nearest '
            '`Theme`. Your own widgets read it the same way:',
          ),
          CodeBlock(
            code: '''
final theme = Theme.of(context);

theme.colorScheme.primary;   // the palette
theme.textTheme.p;           // the type scale
theme.radius;                // the base corner radius
theme.style;                 // the active style preset
theme.formFactor;            // desktop or mobile''',
          ),
        ],
      ),
      DocSection(
        title: 'Color schemes',
        children: [
          DocParagraph(
            'Seven schemes ship, each a light and a dark palette: Slate '
            '(the default, a quiet slate blue), Ocean (a standard blue), '
            'Graphite (monochrome), Forest, Iris, Ember and Rose. Each '
            'supplies the whole palette — page, surfaces, text, lines, the '
            'primary and its tint, status colors and the chart colors — '
            'and all seven are made from one ladder of lightness, so none '
            'is louder than another.',
          ),
          CodeBlock(
            code: '''
UnaApp(
  theme: ThemeData(
    colorScheme: const IrisColorScheme.light(),
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: const IrisColorScheme.dark(),
  ),
)''',
          ),
          DocParagraph(
            'To let users pick one at runtime, `ColorSchemes` lists them '
            'with their names and both palettes:',
          ),
          CodeBlock(
            code: '''
for (final scheme in ColorSchemes.values) {
  scheme.label;              // 'Slate', 'Ocean', …
  scheme.of(Brightness.dark); // its dark palette
}
ColorScheme.fromName('forest', brightness: Brightness.dark);''',
          ),
        ],
      ),
      DocSection(
        title: 'Chart colors',
        children: [
          DocParagraph(
            'Charts draw their series in the scheme\'s `chart1`…`chart5`, '
            'which every built-in scheme sets to `ChartPalette.green`: five '
            'shades of one green, a darker one first on a light page and a '
            'lighter one on a dark page. `ThemeData(chartPalette:)` swaps in '
            'another. The presets are shadcn/ui\'s chart themes — '
            '`ChartPalette.multicolor`, `slate`, and one per color from '
            '`red` around to `rose` — and a palette of your own is any '
            'colors, light and dark:',
          ),
          CodeBlock(
            code: '''
ThemeData(chartPalette: ChartPalette.blue)

ThemeData(
  chartPalette: const ChartPalette(
    light: [Color(0xFF0F766E), Color(0xFFF59E0B), Color(0xFF6366F1)],
    dark: [Color(0xFF2DD4BF), Color(0xFFFBBF24), Color(0xFF818CF8)],
  ),
)''',
          ),
          DocParagraph(
            'For one chart, or a chart with more series than five, '
            '`ChartTheme(palette:)` sets the colors of the charts below it.',
          ),
        ],
      ),
      DocSection(
        title: 'Accent from one color',
        children: [
          DocParagraph(
            '`applyAccent` re-colors a scheme from a single color: the '
            'primary, the focus ring and the selection, with a readable '
            'foreground derived for it. It also moves the `tint` '
            '(selected icons, links, progress fills), `tintForeground` '
            'and `accentBorder` when the color has a contrast of at '
            'least 4.5:1 against both `background` and `card`; a color '
            'too faint for that leaves them alone, so set `tint` yourself '
            'with `copyWith`.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  colorScheme: const GraphiteColorScheme.light()
      .applyAccent(const Color(0xFF6D28D9)),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Customizing a scheme',
        children: [
          DocParagraph(
            'A scheme is a value. Change any color with `copyWith` (or '
            'where you construct it), and carry your own colors in the '
            '`custom` map so they lerp and switch with the rest of the '
            'theme. The theme editor exports exactly this.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  colorScheme: const OceanColorScheme.light(
    primary: Color(0xFF16A34A),
    custom: {
      'highlight': Color(0xFFFACC15),
    },
  ),
)

// Read it back anywhere:
Theme.of(context).colorScheme.custom['highlight'];''',
          ),
          DocParagraph(
            'An extension keeps custom colors as convenient as the '
            'built-in ones:',
          ),
          CodeBlock(
            code: '''
extension AppColors on ColorScheme {
  Color get highlight => custom['highlight']!;
}''',
          ),
        ],
      ),
      DocSection(
        title: 'Component themes',
        children: [
          DocParagraph(
            'Every component has a theme slot on `ThemeData`: '
            '`primaryButtonTheme`, `cardTheme`, `textFieldTheme`, and so on. '
            'Values you pass are merged over what the style derives, so an '
            'override touches exactly the property you name:',
          ),
          CodeBlock(
            code: '''
ThemeData(
  primaryButtonTheme: const ButtonTheme(
    backgroundColor: Color(0xFF16A34A),
  ),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Radius',
        children: [
          DocParagraph(
            'The theme carries one base radius, the `md` step of the '
            'scale. Everything else derives from it through the style: in '
            'the default style the base is 10 and the scale runs sm 6, '
            'md 10, lg 12, xl 16, 2xl 18, 3xl 20, 4xl 24. Each component '
            'picks the step its style prescribes, so one setting keeps '
            'cards, dialogs and menu rows in proportion.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  radius: const BorderRadius.all(Radius.circular(14)),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Menu appearance',
        children: [
          DocParagraph(
            'How menus look is a theme setting. `menuColorScheme` '
            'renders menu surfaces on another '
            'palette (pass the dark counterpart for the "Inverted" look) '
            'and `menuAccent` picks how strongly rows highlight. Whether '
            'menus are glass is the style\'s choice — they are in '
            '`fluid`, whose `popoverOpacity` is below 1, and solid in '
            '`crisp`, `pebble` and `sharp` — unless `menuTranslucent` says otherwise: '
            '`true` gives any style the blurred 70% finish, `false` keeps '
            'menus solid.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  menuColorScheme: const OceanColorScheme.dark(),
  menuTranslucent: true,
  menuAccent: MenuAccent.bold,
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Focus rings',
        children: [
          DocParagraph(
            'Focus is shown as an outward ring. Set '
            '`disableSecondaryBorder: true` to switch to the alternative '
            'treatment: a 2px border inside the control, which keeps '
            'focus visible where an outward ring would be clipped.',
          ),
        ],
      ),
    ],
  ),
);
