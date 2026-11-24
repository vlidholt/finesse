# Theming

One `ThemeData` drives every component: color scheme, radius, typography, and per-component overrides.

## Reading the theme

Every component resolves its appearance from the nearest `Theme`. Your own widgets read it the same way:

```dart
final theme = Theme.of(context);

theme.colorScheme.primary;   // the palette
theme.textTheme.p;           // the type scale
theme.radius;                // the base corner radius
theme.style;                 // the active style preset
```

## Color schemes

Sixteen schemes ship in light and dark: blue, gray, green, mauve, mist, neutral, olive, orange, red, rose, slate (the default), stone, taupe, violet, yellow, and zinc.

```dart
FinesseApp(
  theme: ThemeData(
    colorScheme: const ZincColorScheme.light(),
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ZincColorScheme.dark(),
  ),
)
```

To let users pick a palette at runtime, resolve one by name with `ColorScheme.fromName`:

```dart
final scheme = ColorScheme.fromName(
  'rose',
  brightness: Brightness.dark,
);
```

## Customizing a scheme

A scheme is a value. Override individual slots where you construct it, and carry your own colors in the `custom` map so they lerp and switch with the rest of the theme.

```dart
ThemeData(
  colorScheme: const SlateColorScheme.light(
    primary: Color(0xFF16A34A),
    custom: {
      'highlight': Color(0xFFFACC15),
    },
  ),
)

// Read it back anywhere:
Theme.of(context).colorScheme.custom['highlight'];
```

An extension keeps custom colors as convenient as the built-in ones:

```dart
extension AppColors on ColorScheme {
  Color get highlight => custom['highlight']!;
}
```

## Component themes

Every component has a theme slot on `ThemeData`: `primaryButtonTheme`, `cardTheme`, `textFieldTheme`, and so on. Values you pass are merged over what the style derives, so an override touches exactly the property you name:

```dart
ThemeData(
  primaryButtonTheme: const ButtonTheme(
    backgroundColor: Color(0xFF16A34A),
  ),
)
```

## Radius

The theme carries one base radius, the `md` step of the scale. Everything else derives from it: at the default 8 the scale runs sm 6, md 8, lg 10, xl 14, 2xl 16, 3xl 24, 4xl 32, and each component picks the step its style prescribes.

```dart
ThemeData(
  radius: const BorderRadius.all(Radius.circular(10)),
)
```

## Menu appearance

The shadcn theme editor's menu options are theme settings here too. `menuColorScheme` renders menu surfaces on another palette (pass the dark counterpart for the "Inverted" look), `menuTranslucent` gives them the blurred 70% finish, and `menuAccent` picks how strongly rows highlight.

```dart
ThemeData(
  menuColorScheme: const SlateColorScheme.dark(),
  menuTranslucent: true,
  menuAccent: MenuAccent.bold,
)
```

## Focus rings

Focus is shown as an outward ring, like shadcn/ui. Set `disableSecondaryBorder: true` to switch to the alternative treatment: a 2px border inside the control, which keeps focus visible where an outward ring would be clipped.

```dart
ThemeData(
  disableSecondaryBorder: true,
)
```

## Interop with Material and Cupertino

`package:finesse/finesse.dart` does not import Material or Cupertino. To use their widgets in a finesse app, import `package:finesse/material.dart` too and wrap the app in a `FinesseMaterial`. It derives a Material theme from the finesse theme (Cupertino widgets read theirs from it), adds a transparent `Material`, and adds the Material and Cupertino localizations when no ancestor provides them:

```dart
import 'package:finesse/material.dart';
import 'package:finesse/finesse.dart';

FinesseApp(
  themeMode: ThemeMode.system,
  builder: (context, child) => FinesseMaterial(child: child!),
  home: const HomePage(),
)
```

`FinesseMaterial.themeBuilder` adjusts the derived `ThemeData`. Inside a `ThemeScope`, a `FinesseMaterial` follows that scope's theme.

To put finesse widgets inside your own `MaterialApp` or `CupertinoApp`, use `FinesseApp.custom`. Theme the app with `materialThemeFrom` and wrap its `builder` in a `FinesseAppBuilder`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finesse/material.dart';
import 'package:finesse/finesse.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseApp.custom(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const SlateColorScheme.dark(),
      ),
      appBuilder: (context) {
        return MaterialApp(
          theme: materialThemeFrom(Theme.of(context)),
          localizationsDelegates: const [
            GlobalFinesseLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) => FinesseAppBuilder(child: child!),
        );
      },
    );
  }
}
```

If the app needs the `Router` API, use `MaterialApp.router` or `CupertinoApp.router` inside `appBuilder`.
