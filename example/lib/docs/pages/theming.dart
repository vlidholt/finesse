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
theme.style;                 // the active style preset''',
          ),
        ],
      ),
      DocSection(
        title: 'Color schemes',
        children: [
          DocParagraph(
            'Sixteen schemes ship in light and dark: blue, gray, green, '
            'mauve, mist, neutral, olive, orange, red, rose, slate '
            '(the default), stone, taupe, violet, yellow, and zinc.',
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
  'rose',
  brightness: Brightness.dark,
);''',
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
  colorScheme: const SlateColorScheme.light(
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
            'scale. Everything else derives from it: at the default 8 the '
            'scale runs sm 6, md 8, lg 10, xl 14, 2xl 16, 3xl 24, 4xl 32, '
            'and each component picks the step its style prescribes.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  radius: const BorderRadius.all(Radius.circular(10)),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Menu appearance',
        children: [
          DocParagraph(
            "The shadcn theme editor's menu options are theme settings "
            'here too. `menuColorScheme` renders menu surfaces on another '
            'palette (pass the dark counterpart for the "Inverted" look), '
            '`menuTranslucent` gives them the blurred 70% finish, and '
            '`menuAccent` picks how strongly rows highlight.',
          ),
          CodeBlock(
            code: '''
ThemeData(
  menuColorScheme: const SlateColorScheme.dark(),
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
            'Focus is shown as an outward ring, like shadcn/ui. Set '
            '`disableSecondaryBorder: true` to switch to the alternative '
            'treatment: a 2px border inside the control, which keeps '
            'focus visible where an outward ring would be clipped.',
          ),
        ],
      ),
    ],
  ),
);
