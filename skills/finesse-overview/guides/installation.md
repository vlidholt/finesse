# Installation

Add `finesse` to your project from the command line:

```bash
flutter pub add finesse
```

Everything ships through one import: components, theme, Lucide icons, and animation effects.

```dart
import 'package:finesse/finesse.dart';
```

## Set up FinesseApp

`FinesseApp` takes the place of `MaterialApp`. It installs the theme, localizations, navigation, and the overlay layer the floating components use. With no arguments it uses the slate color scheme and the nova style.

```dart
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
}
```

Apps that use the `Router` API use `FinesseApp.router` with the usual `routerConfig` or delegate parameters.

## Dark mode

Pass a `theme` and a `darkTheme`, and pick between them with `themeMode`. Follow the platform, or bind it to your own setting.

```dart
FinesseApp(
  themeMode: ThemeMode.system,
  theme: ThemeData(),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
  ),
  home: const HomePage(),
)
```

## Use the components

Components are plain widgets. Icons come from the bundled Lucide set:

```dart
Button(
  leading: const Icon(LucideIcons.mail),
  onPressed: () {},
  child: const Text('Login with Email'),
)
```

## Padding

Use `FinessePadding` instead of Flutter's `Padding` to keep insets on the theme's spacing scale. It has no plain constructor, only `FinessePadding.all`, `.symmetric`, `.only`, and `.directional`, and their arguments are steps, not logical pixels:

```dart
FinessePadding.symmetric(
  horizontal: 6, // px-6
  vertical: 4, // py-4
  child: const Text('Inset by the theme spacing scale'),
)
```

See [layout.md](layout.md#padding) for a full example.

From here, [theming.md](theming.md) and [styles.md](styles.md) cover how to make it yours, and each page under `components/` pairs a description with the actual example source that ships in the example app.
