import 'package:example/docs/docs.dart';

final fontsDoc = ComponentDoc(
  slug: 'fonts',
  title: 'Fonts',
  description:
      'finesse bundles no fonts. Text uses the platform font until you choose '
      'one: from Google Fonts at runtime, or from your own assets.',
  body: (context) => const DocProse(
    children: [
      DocSection(
        title: 'Google Fonts',
        children: [
          DocParagraph(
            'Add `google_fonts` and build the text theme from one of its '
            'fonts. Faces are fetched the first time they are used. This '
            'docs site does it for every font in the theme editor.',
          ),
          CodeBlock(
            code: '''
// flutter pub add google_fonts
ThemeData(
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.inter),
)''',
          ),
          DocParagraph(
            'Pass a static tear-off such as `GoogleFonts.inter`. It is the '
            'same object every time, so the theme stays equal to itself, '
            'and it is the only font the compiler keeps. '
            '`GoogleFonts.getFont(name)` and `GoogleFonts.asMap()` look a '
            'family up by name, which keeps the tables of all 1,700 '
            'families of the package in the app: about 8 MB of JavaScript '
            'in a web build. For a font picker, list a tear-off per font.',
          ),
          DocParagraph(
            'To avoid a flash of the fallback font on the first frame, fetch '
            'the face before `runApp`:',
          ),
          CodeBlock(
            code: '''
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.inter();
  await GoogleFonts.pendingFonts();
  runApp(const App());
}''',
          ),
        ],
      ),
      DocSection(
        title: 'Your own fonts',
        children: [
          DocParagraph(
            'Put the files in your app, declare the family in pubspec.yaml, '
            'and name it in the text theme. Ship the font licence with it.',
          ),
          CodeBlock(
            code: '''
# pubspec.yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter[opsz,wght].ttf''',
          ),
          CodeBlock(
            code: '''
ThemeData(
  textTheme: TextTheme(family: 'Inter'),
)''',
          ),
          DocParagraph(
            'A font from another package is named with its package: '
            "`TextTheme(family: 'Inter', package: 'my_fonts')`.",
          ),
        ],
      ),
      DocSection(
        title: 'Which font',
        children: [
          DocParagraph(
            'This app uses Geist, which is what the default style was '
            'designed around; Inter is a close and widely available '
            'alternative. Controls keep their heights whatever the font, '
            'because heights come from the style tokens.',
          ),
        ],
      ),
    ],
  ),
);
