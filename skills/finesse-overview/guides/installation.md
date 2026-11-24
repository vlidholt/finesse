# Installation

Add `finesse` to your project from the command line:

```bash
flutter pub add finesse
```

Everything ships through one import: components, theme, Phosphor icons, and animation effects.

```dart
import 'package:finesse/finesse.dart';
```

## Set up FinesseApp

`FinesseApp` takes the place of `MaterialApp`. It installs the theme, localizations, navigation, and the overlay layer the floating components use. With no arguments it uses the teal color scheme and the `finesse` style, and lays itself out for a desktop or a phone from the window width (see [form-factors.md](form-factors.md)).

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

Components are plain widgets. Icons come from the bundled Phosphor set:

```dart
Button(
  leading: const Icon(PhosphorIconsRegular.envelopeSimple),
  onPressed: () {},
  child: const Text('Login with Email'),
)
```

Icon constants are named after the icon, in a class per weight. `PhosphorIconsFill.envelopeSimple` is the same icon filled, for a selected state. See [icons.md](icons.md).

## A first screen

A screen is a `Scaffold` with an `AppBar`. Its content goes in a `PageContainer`, which supplies the page margins and the maximum width, and its vertical rhythm comes from the gap scale:

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar(title: Text('Home')),
      body: PageContainer(
        scrollable: true,
        child: FinesseColumn(
          gap: GapSize.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Card(title: Text('Welcome')),
          ],
        ),
      ),
    );
  }
}
```

The bars are laid over the body, and the body's `MediaQuery` padding includes their heights, so a `PageContainer`, a `ListView` or a `SafeArea` clears them without being told. An app with several top-level destinations uses `NavigationScaffold` instead: destinations in the app bar on a desktop, in a bottom bar on a phone. See [scaffold.md](../components/scaffold.md).

## Spacing

Use the named gaps between components, `FinesseColumn(gap: GapSize.lg)` or `const Gap.md()`, rather than pixel counts: they follow the form factor. `FinessePadding` keeps insets on the theme's spacing scale. It has no plain constructor, only `FinessePadding.all`, `.symmetric`, `.only`, and `.directional`, and their arguments are steps, not logical pixels:

```dart
FinessePadding.symmetric(
  horizontal: 6, // 24 at the default 4px step
  vertical: 4, // 16
  child: const Text('Inset by the theme spacing scale'),
)
```

See [layout.md](layout.md) for both scales.

From here, [theming.md](theming.md) and [styles.md](styles.md) cover how to make it yours, and each page under `components/` pairs a description with the actual example source that ships in the example app.
