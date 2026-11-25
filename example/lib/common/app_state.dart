import 'package:disco/disco.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

/// The app-wide state: light or dark, text direction, and the theme the
/// editor has configured.
///
/// All of it is provided above `FinesseApp` (see `App` in `main.dart`), so
/// every route — including full-screen ones a screen pushes — can read it.

final themeModeProvider = Provider((_) => Signal(ThemeMode.light));

final directionalityProvider = Provider((context) => Signal(TextDirection.ltr));

/// The theme the whole app is built from, edited by the customizer panel.
///
/// Compared by value, not by identity: a write here rebuilds two full
/// [ThemeData]s and restarts a 200 ms lerp across every component theme,
/// which is far too expensive to spend on a `copyWith` that changed nothing.
final themeConfigProvider = Provider(
  (_) => Signal(
    const ThemeEditorConfig(),
    comparator: (a, b) => a == b,
  ),
);

/// Whether that panel is docked beside the app.
final themeEditorOpenProvider = Provider((_) => Signal(false));

/// Every provider above, for the `ProviderScope` at the root of the app (and
/// of a test that pumps part of it).
final appProviders = <Provider<Object>>[
  themeModeProvider,
  directionalityProvider,
  themeConfigProvider,
  themeEditorOpenProvider,
];

/// Flips between light and dark.
void toggleThemeMode(BuildContext context) {
  themeModeProvider
      .of(context)
      .updateValue(
        (mode) => mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
}
