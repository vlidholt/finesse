# Installation and app setup

Add `finesse` to your project:

```bash
flutter pub add finesse
```

Everything ships through one import: components, theme, motion and the
Phosphor icons. Nothing else is needed, and a finesse app imports neither
Material nor Cupertino.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
```

## FinesseApp

`FinesseApp` takes the place of `MaterialApp`. It installs the theme, the
localizations, the navigator with `FinessePageRoute` transitions, the
scroll behaviour, the toaster and the overlay layer the floating
components use. With no theme it uses the teal colour scheme and the
`finesse` style, and lays itself out for a desktop or a phone from the
window width (see [form-factors.md](form-factors.md)).

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FinesseApp(
      title: 'My app',
      theme: ThemeData(),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
```

- `themeMode` is finesse's own `ThemeMode` (`system`, `light`, `dark`).
  A switch between themes is one rebuild and a short cross-fade.
- An app on the `Router` API uses `FinesseApp.router(routerConfig: ...)`.
- `FinesseApp.custom` puts finesse inside a `MaterialApp` or `CupertinoApp`
  of your own (see [theming.md](theming.md)).
- The package's strings (Cancel, Back, the date picker's labels...) are
  localized into some 80 languages by `GlobalFinesseLocalizations`, which
  `FinesseApp` adds. Pass `locale` / `supportedLocales` as usual; read a
  string with `FinesseLocalizations.of(context)`.

## A first screen

A screen is a `Scaffold` with an `AppBar`. Its content goes in a
`PageContainer`, which supplies the page margins and the maximum width,
and its rhythm comes from the gap scale:

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
          children: [
            const Card(
              title: Text('Welcome'),
              description: Text('Everything here follows the theme.'),
            ),
            Button(
              leading: const PhosphorIcon(PhosphorIconsRegular.plus),
              onPressed: () {},
              child: const Text('New post'),
            ),
          ],
        ),
      ),
    );
  }
}
```

The bars are laid over the body, and the body's `MediaQuery` padding
includes their heights, so a `PageContainer`, a `ListView` or a `SafeArea`
clears them without being told. An app with several top-level
destinations uses `NavigationScaffold` instead; see
[app-structure.md](app-structure.md).

## Next

- [theming.md](theming.md) and [styles.md](styles.md): colours, styles,
  component overrides.
- [layout.md](layout.md): the gap scale, rows, columns and padding.
- [icons.md](icons.md): the Phosphor classes and `PhosphorIcon`.
- Each page under `components/` pairs a description with the example
  source that ships in the example app.
