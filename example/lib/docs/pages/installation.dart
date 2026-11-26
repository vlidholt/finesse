import 'package:example/docs/docs.dart';

final installationDoc = ComponentDoc(
  slug: 'installation',
  title: 'Installation',
  description: 'Add the package, wrap your app in UnaApp, start building.',
  body: (context) => const DocProse(
    children: [
      DocSection(
        title: 'Install the package',
        children: [
          DocParagraph(
            'Add `una` to your project from the command line:',
          ),
          CodeBlock(code: 'flutter pub add una'),
          DocParagraph(
            'Everything ships through one import: components, theme, '
            'Phosphor icons, and motion.',
          ),
          CodeBlock(code: "import 'package:una/una.dart';"),
        ],
      ),
      DocSection(
        title: 'Set up UnaApp',
        children: [
          DocParagraph(
            '`UnaApp` takes the place of `MaterialApp`. It installs the '
            'theme, localizations, navigation, and the overlay layer the '
            'floating components use. With no arguments it uses the teal '
            'color scheme and the una style, and lays itself out for '
            'a desktop or a phone from the window width.',
          ),
          CodeBlock(
            code: '''
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnaApp(
      home: HomePage(),
    );
  }
}''',
          ),
          DocParagraph(
            'Apps that use the `Router` API use `UnaApp.router` with the '
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
UnaApp(
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
            'Phosphor set:',
          ),
          CodeBlock(
            code: '''
Button(
  leading: const PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
  onPressed: () {},
  child: const Text('Login with Email'),
)''',
          ),
          DocParagraph(
            'A screen is usually a `Scaffold` with an `AppBar`, and its '
            'content a `PageContainer`, which supplies the page margins:',
          ),
          CodeBlock(
            code: '''
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(title: Text('Home')),
      body: PageContainer(
        scrollable: true,
        child: UnaColumn(
          gap: GapSize.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Card(title: Text('Welcome')),
          ],
        ),
      ),
    );
  }
}''',
          ),
          DocParagraph(
            'From here, the Theming and Styles pages cover how to make it '
            'yours, Form Factors and Layout and Spacing how it adapts to '
            'a phone, and each component page pairs a live preview with '
            'the code that renders it.',
          ),
        ],
      ),
    ],
  ),
);
