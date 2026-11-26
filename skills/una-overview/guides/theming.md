# Theming

One `ThemeData` drives every component: color scheme, radius, typography, and
per-component overrides.

## Reading the theme

Every component resolves its appearance from the nearest `Theme`. Your own
widgets read it the same way:

```dart
final theme = Theme.of(context);

final primary = theme.colorScheme.primary; // the palette
final body = theme.textTheme.p; // the type scale
final corners = theme.radii.lg; // the radius scale
final style = theme.style; // the active style's tokens
final formFactor = theme.formFactor; // FormFactor.desktop or .mobile
final margins = theme.layoutTheme.pagePadding; // page margins, gaps
```

Do not build a `ThemeData`, or call `copyWith` on one, in a `build` that
runs often (a row, anything animated): each call re-derives some seventy
component themes. Building the app's themes in its root widget is fine;
themes compare by value. A subtree that needs a re-themed copy derives it
once per ambient theme and keeps it.

## Which colour to use

Pick a token by what the colour *does*, never by how it looks in the
default scheme: six schemes ship, and in each the same role is a
different colour.

| Token | For |
| --- | --- |
| `background` / `foreground` | The page, and the default ink on it: titles, names, body text you want at full strength. |
| `card` / `cardForeground`, `popover` / `popoverForeground` | Surfaces. Components paint them; read them only for a surface of your own. |
| `mutedForeground` | Descriptions, metadata, placeholders, inactive icons. `textTheme.muted` and `caption` are already in it. |
| `foregroundSubtle` | One step louder than muted: chip labels, ghost button labels, a secondary line that must still read. |
| `tint` / `tintForeground` | The brand colour drawn *straight on a surface*: a selected icon, a link, a progress fill, a liked heart, a "Verified" glyph. |
| `primary` / `primaryForeground` | A *fill* that carries text: primary buttons, checked controls, badges. Too dark or too light to read as ink on some pages. |
| `accent` / `accentForeground` | The wash of a selected chip, card or menu row, and the ink *on that wash*. Not a brand ink for a card. |
| `muted`, `secondary` | Quiet fills: a track, a skeleton, a hovered row, a secondary button. |
| `border`, `borderStrong`, `input` | Hairlines; `borderStrong` for outline buttons and key caps on a surface of nearly the same colour; `input` for field outlines. |
| `success` / `successMuted`, `warning`, `destructive` | Status ink and its soft fill. |
| `bar` | The solid colour under app and navigation bars (the style makes it translucent). |
| `chart1`...`chart5` | A data ramp. |

```dart
final theme = Theme.of(context);
final scheme = theme.colorScheme;

final verified = PhosphorIcon(PhosphorIconsFill.sealCheck, color: scheme.tint);
final age = Text('3 days ago', style: theme.textTheme.caption); // already muted
final author = Text(
  'Ada Lovelace',
  style: theme.textTheme.large.copyWith(color: scheme.foreground),
);
```

Never write a hex colour in a screen. A colour of your own goes in the
scheme's `custom` map (below), so it switches with light and dark.

## Color schemes

Six schemes ship, each a light and a dark palette made from one ladder of
lightness, so none is louder than another:

| `ColorSchemes` | Classes | Character |
| --- | --- | --- |
| `ocean` (the default) | `OceanColorScheme.light()` / `.dark()` | A standard blue on a cool grey page. |
| `graphite` | `GraphiteColorScheme` | Monochrome: near-black ink as the primary, near-white in the dark. |
| `forest` | `ForestColorScheme` | A deep green on greys with a breath of sage. |
| `iris` | `IrisColorScheme` | A clear violet on cool, faintly violet greys. |
| `ember` | `EmberColorScheme` | A burnt orange on warm stone greys. |
| `rose` | `RoseColorScheme` | A rose red on soft, warm greys. |

Each supplies the whole palette, every optional token included. With no
`colorScheme`, `ThemeData` uses Ocean in the theme's brightness.

```dart
UnaApp(
  theme: ThemeData(colorScheme: const IrisColorScheme.light()),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: const IrisColorScheme.dark(),
  ),
)
```

For a picker, `ColorSchemes` lists them with a display name and both
palettes, and `ColorScheme.fromName` looks one up:

```dart
for (final scheme in ColorSchemes.values) {
  scheme.label; // 'Ocean', 'Graphite', ...
  scheme.of(Brightness.dark); // its dark palette
}
final forest = ColorScheme.fromName('forest', brightness: Brightness.dark);
```

There is no `TealColorScheme`, `NeutralColorScheme`, `ZincColorScheme`,
`StoneColorScheme`, `BlueColorScheme` or `AccentScheme` any more, and no
`applyAccentScheme`. A brand colour is `applyAccent` (below); any other
change is `copyWith`.

## An accent from one colour

`applyAccent` re-colours a scheme from a single colour and leaves the
neutral palette (page, surfaces, borders, muted tones) alone:

```dart
ThemeData(
  colorScheme: const GraphiteColorScheme.light()
      .applyAccent(const Color(0xFF6D28D9)),
)
```

It sets `primary`, a readable `primaryForeground`, the focus `ring` and the
text `selection`. It also moves `tint`, `tintForeground` and
`accentBorder` when the colour has a contrast of at least 4.5:1 against
both `background` and `card`. A colour too faint for that (a light yellow,
or a dark navy on a dark page) leaves the tint alone, so give the dark
scheme a lighter tint yourself:

```dart
const brand = Color(0xFF1D4ED8);
final light = const OceanColorScheme.light().applyAccent(brand);
final dark = const OceanColorScheme.dark()
    .applyAccent(brand)
    .copyWith(tint: const Color(0xFF93B4FF));
```

## Customizing a scheme

A scheme is a value. Change any colour with `copyWith`, or where you
construct it, and carry your own colours in the `custom` map so they lerp
and switch with the rest of the theme.

```dart
final scheme = const OceanColorScheme.light().copyWith(
  background: const Color(0xFFF7F7F5),
  custom: {'highlight': const Color(0xFFFACC15)},
);

final theme = ThemeData(
  colorScheme: const OceanColorScheme.light(
    primary: Color(0xFF16A34A),
    custom: {'highlight': Color(0xFFFACC15)},
  ),
);

// Read it back anywhere:
final highlight = Theme.of(context).colorScheme.custom['highlight'];
```

An extension keeps custom colors as convenient as the built-in ones:

```dart
extension AppColors on ColorScheme {
  Color get highlight => custom['highlight']!;
}
```

Define both palettes when you change one: a light-only override leaves
dark mode on the stock colours.

## Component themes

Every component has a theme slot on `ThemeData`: `primaryButtonTheme` (and
`outlineButtonTheme`, `ghostButtonTheme`, ... per variant), `cardTheme`,
`textFieldTheme`, `sheetTheme`, and so on. Values you pass are merged over what
the style derives, so an override touches exactly the property you name:

```dart
ThemeData(
  primaryButtonTheme: const ButtonTheme(
    backgroundColor: Color(0xFF16A34A),
  ),
)
```

## Radius

The theme carries one base radius, the `md` step of the scale. Everything else
derives from it through the style: in the default style the base is 10 and the
scale runs sm 6, md 10, lg 12, xl 16, 2xl 18, 3xl 20, 4xl 24 (`crisp`, `pebble`
and `sharp` use a base of 8 and Tailwind's factors). Each component picks the step its style
prescribes. Read the scale with `Theme.of(context).radii` (`radii.lg`,
`radii.xl2`, `radii.full`).

```dart
ThemeData(
  radius: const BorderRadius.all(Radius.circular(14)),
)
```

## Menu appearance

How menus look is a theme setting. `menuColorScheme` renders menu surfaces on
another palette (pass the dark counterpart for the "Inverted" look).
`menuTranslucent` is three-state: null follows the style (glass in `fluid`,
solid in `crisp`, `pebble` and `sharp`), `true` is shadcn's blurred 70% finish, `false`
keeps menus solid. `menuAccent: MenuAccent.bold` fills a highlighted row with
the primary colour; it changes menus only, never the scheme's `accent`.

```dart
ThemeData(
  menuColorScheme: const OceanColorScheme.dark(),
  menuTranslucent: true,
  menuAccent: MenuAccent.bold,
)
```

## Focus rings

Focus is shown as an outward ring, only for keyboard focus. Set
`disableSecondaryBorder: true` to switch to the alternative treatment: a 2px
border inside the control, which keeps focus visible where an outward ring would
be clipped.

```dart
ThemeData(
  disableSecondaryBorder: true,
)
```

## Other theme switches

```dart
final theme = ThemeData(
  motion: Motion.calm, // see motion.md
  haptics: false, // no ticks under a finger (on by default on phones)
  spacing: const Spacing(step: 5), // the spacing unit, 4 by default
  breakpoints: Breakpoints(md: 600), // where the phone layout begins
);
```

`UnaApp` switches between `theme` and `darkTheme` (and any other
theme change) with one rebuild and a cross-fade of the previous frame
(`CrossFadeTheme`), not a per-frame interpolation. Keep themes equal when
nothing changed: build them once, not in `build`, so the app is not
rebuilt and re-faded for nothing.

## Interop with Material and Cupertino

`package:una/una.dart` does not import Material, and Cupertino only
through its Liquid Glass adapter ([liquid-glass.md](liquid-glass.md)). To use
their widgets in a una app, import `package:una/material.dart` too and
wrap the app in a `UnaMaterial`. It derives a Material theme from the
una theme (Cupertino widgets read theirs from it), adds a transparent
`Material`, and adds the Material and Cupertino localizations when no ancestor
provides them:

```dart
import 'package:una/una.dart';
import 'package:una/material.dart';
import 'package:flutter/widgets.dart';

final app = UnaApp(
  themeMode: ThemeMode.system,
  builder: (context, child) => UnaMaterial(child: child!),
  home: const HomePage(),
);
```

`UnaMaterial.themeBuilder` adjusts the derived Material `ThemeData`. A file
that imports both `package:flutter/material.dart` and una must hide one
side's clashing names (`Theme`, `ThemeData`, `ColorScheme`, `TextTheme`,
`ButtonTheme`, `IconButton`, `Tab`, ...) or import Material with a prefix.
Flutter 3.47 and later mark the SDK's Material and Cupertino libraries
deprecated in favour of the `material_ui` and `cupertino_ui` packages;
`package:una/material.dart` still uses the SDK libraries.

To put una widgets inside your own `MaterialApp` or `CupertinoApp`, use
`UnaApp.custom`. Theme the app with `materialThemeFrom` and wrap its
`builder` in a `UnaAppBuilder`:

```dart
import 'package:una/una.dart';
import 'package:una/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaApp.custom(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const OceanColorScheme.dark(),
      ),
      appBuilder: (context) {
        return m.MaterialApp(
          theme: materialThemeFrom(Theme.of(context)),
          localizationsDelegates: const [
            GlobalUnaLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) => UnaAppBuilder(child: child!),
          home: const HomePage(),
        );
      },
    );
  }
}
```

If the app needs the `Router` API, use `MaterialApp.router` or
`CupertinoApp.router` inside `appBuilder`.
