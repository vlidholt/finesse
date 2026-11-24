import 'package:example/docs/docs.dart';

final installationDoc = ComponentDoc(
  slug: 'installation',
  title: 'Installation',
  description: 'Add the package, wrap your app in FinesseApp, start building.',
  body: (context) => const DocProse(
    children: [
      DocSection(
        title: 'Install the package',
        children: [
          DocParagraph(
            'Add `finesse` to your project from the command line:',
          ),
          CodeBlock(code: 'flutter pub add finesse'),
          DocParagraph(
            'Everything ships through one import: components, theme, '
            'Lucide icons, and animation effects.',
          ),
          CodeBlock(code: "import 'package:finesse/finesse.dart';"),
        ],
      ),
      DocSection(
        title: 'Set up FinesseApp',
        children: [
          DocParagraph(
            '`FinesseApp` takes the place of `MaterialApp`. It installs the '
            'theme, localizations, navigation, and the overlay layer the '
            'floating components use. With no arguments it uses the slate '
            'color scheme and the nova style.',
          ),
          CodeBlock(
            code: '''
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const FinesseApp(
      home: HomePage(),
    );
  }
}''',
          ),
          DocParagraph(
            'Apps that use the `Router` API use `FinesseApp.router` with the '
            'usual `routerConfig` or delegate parameters.',
          ),
        ],
      ),
      DocSection(
        title: 'Dark mode',
        children: [
          DocParagraph(
            'Pass a `theme` and a `darkTheme`, and pick between them with '
            '`themeMode`. Follow the platform, or bind it to your own '
            'setting.',
          ),
          CodeBlock(
            code: '''
FinesseApp(
  themeMode: ThemeMode.system,
  theme: ThemeData(),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
  ),
  home: const HomePage(),
)''',
          ),
        ],
      ),
      DocSection(
        title: 'Use the components',
        children: [
          DocParagraph(
            'Components are plain widgets. Icons come from the bundled '
            'Lucide set:',
          ),
          CodeBlock(
            code: '''
Button(
  leading: const Icon(LucideIcons.mail),
  onPressed: () {},
  child: const Text('Login with Email'),
)''',
          ),
          DocParagraph(
            'From here, the Theming and Styles pages cover how to make it '
            'yours, and each component page pairs a live preview with the '
            'code that renders it.',
          ),
        ],
      ),
    ],
  ),
);
