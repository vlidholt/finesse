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
            'Four base schemes ship in light and dark: `teal` (the '
            'default), `neutral`, `zinc` and `stone`. A base scheme '
            'supplies the whole palette: backgrounds, borders, muted '
            'tones and a primary.',
          ),
          CodeBlock(
            code: '''
FinesseApp(
  theme: ThemeData(
    colorScheme: const ZincColorScheme.light(),
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ZincColorScheme.dark(),
  ),
)''',
          ),
          DocParagraph(
            'To let users pick a palette at runtime, resolve one by name '
            'with `ColorScheme.fromName`:',
          ),
          CodeBlock(
            code: '''
final scheme = ColorScheme.fromName(
  'stone',
  brightness: Brightness.dark,
);''',
          ),
        ],
      ),
      DocSection(
        title: 'Accents',
        children: [
          DocParagraph(
            'An `AccentScheme` is an overlay: it replaces only the '
            'tokens that carry the hue (the primary pair, the focus '
            'ring, the selection and the chart ramp) and leaves the '
            'base palette alone. Seventeen ship, each in light and dark: '
            'amber, blue, cyan, emerald, fuchsia, green, indigo, lime, '
            'orange, pink, purple, red, rose, sky, teal, violet and '
            'yellow.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  colorScheme: const ZincColorScheme.light()
      .applyAccentScheme(AccentScheme.violetLight),
)

// By name, for a picker:
AccentScheme.fromName('violet', brightness: Brightness.dark);

// Or any one color, with a readable foreground derived for it:
const NeutralColorScheme.light().applyAccent(const Color(0xFF3B82F6));''',
          ),
          DocParagraph(
            '`applyAccent` re-colors the primary, the focus ring and the '
            'selection. It also moves the `tint` (selected icons, links, '
            'progress fills), `tintForeground` and `accentBorder` when '
            'the color has a contrast of at least 4.5:1 against both '
            '`background` and `card`; a color too faint for that leaves '
            'them alone, so set `tint` yourself with `copyWith` or use '
            'an `AccentScheme`, which picks a legible step from its '
            'ramp.',
          ),
        ],
      ),
      DocSection(
        title: 'Customizing a scheme',
        children: [
          DocParagraph(
            'A scheme is a value. Override individual slots where you '
            'construct it, and carry your own colors in the `custom` map '
            'so they lerp and switch with the rest of the theme.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  colorScheme: const TealColorScheme.light(
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
            'palette (pass the dark counterpart for the "Inverted" look), '
            '`menuTranslucent` gives them the blurred 70% finish, and '
            '`menuAccent` picks how strongly rows highlight.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  menuColorScheme: const TealColorScheme.dark(),
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
