# Typography

`Theme.of(context).textTheme` carries the type scale. Read a role and
hand it to a `Text`:

```dart
Text(
  'Senior product designer',
  style: Theme.of(context).textTheme.h3,
)
```

## Roles

Every style carries an app type scale and maps it onto these names, so a
screen written against them is the right size in all four styles and on
both form factors.

| Role | Use for |
| --- | --- |
| `h1` | Page titles (the style's display role). |
| `h2` | Large section titles. |
| `h3` | Section titles, the title of a large card (the headline role). |
| `h4` | Card and dialog titles. |
| `large` | An emphasised single line: a person's name, a dialog's question (the subtitle role). |
| `p` | Body text. |
| `small` | Labels and secondary UI text. |
| `muted` | Descriptions and supporting text, in the muted colour. |
| `caption` | Fine print a size under `muted`: counts, timestamps, sources. |
| `lead` | The introductory paragraph under a page title. |
| `h1Large`, `blockquote`, `list`, `table` | Prose: articles and documentation. |

Components read their own text styles from their component themes, which
the style derives; they do not need these.

## Changing a weight or colour

Copy a theme style; never write a bare `TextStyle(fontWeight: ...)` for a
span or an override.

```dart
final theme = Theme.of(context);
final bold = theme.textTheme.p.copyWith(fontWeight: FontWeight.w600);
final link = theme.textTheme.small.copyWith(color: theme.colorScheme.tint);
```

A font loaded per weight (as `google_fonts` does) has one family per
weight; a style copied from the theme resolves the right face for its new
weight, a hand-built `TextStyle` silently draws the wrong one.

Do not give text a `fontSize`: pick the role. The roles grow on a phone
(body text is 15 there) and with the platform's text scale.

## Fonts

`finesse` bundles no text fonts. Text uses the platform font until a
`TextTheme` names one.

### Your own font files

Declare the font in `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: fonts/Inter[opsz,wght].ttf
```

Then name the family:

```dart
final theme = ThemeData(textTheme: TextTheme(family: 'Inter'));
```

### Google Fonts

Add the [google_fonts](https://pub.dev/packages/google_fonts) package and
build the text theme from one of its fonts:

```dart
import 'package:finesse/finesse.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.inter),
);
```

- Pass a static tear-off such as `GoogleFonts.inter`. Never
  `GoogleFonts.getFont(name)` or `GoogleFonts.asMap()`: either keeps all of
  Google's 1,700 families in a web build (megabytes of JavaScript).
- Build the text theme once. A new closure per build makes the theme
  unequal to itself, and the app is rebuilt and re-faded on every build.
- The default style was designed around Geist; Inter is a close
  alternative. Control heights come from the style, not the font.

## Custom styles

Add your own named styles with `custom`, the pattern `ColorScheme` uses
for custom colours:

```dart
final theme = ThemeData(
  textTheme: TextTheme(
    custom: {
      'price': const TextStyle(fontSize: 20, fontFeatures: [
        FontFeature.tabularFigures(),
      ]),
    },
  ),
);
```

Read it back with `Theme.of(context).textTheme.custom['price']!`, or add
an extension:

```dart
extension AppTextStyles on TextTheme {
  TextStyle get price => custom['price']!;
}
```

## Text case

A style's text role may be uppercase (an overline). `TextStyle` has no
text transform and finesse components take widgets, not strings, so apply
it yourself: `theme.style.overline.applyCase('Section')`.

See also: [styles.md](styles.md), [form-factors.md](form-factors.md).
