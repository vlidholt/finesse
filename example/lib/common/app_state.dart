import 'package:disco/disco.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:una/una.dart';

/// The app-wide state: light or dark, text direction, and the theme the
/// editor has configured.
///
/// All of it is provided above `UnaApp` (see `App` in `main.dart`), so
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

/// The two halves of the app, switched from the top bar.
enum AppSection {
  /// The components at their best, on one page: what the app opens on.
  showcase('Showcase'),

  /// The reference: a page per component and guide.
  components('Components');

  const AppSection(this.label);

  final String label;
}

/// Which section the app starts on. The showcase; tests about the docs
/// browser start on the reference.
AppSection initialAppSection = AppSection.showcase;

/// Whether the editor opens by itself when the app starts in a window wide
/// enough for a desktop page beside it. Tests that open it themselves turn
/// this off.
bool openEditorOnDesktop = true;

/// The section showing.
final appSectionProvider = Provider((_) => Signal(initialAppSection));

/// Every provider above, for the `ProviderScope` at the root of the app (and
/// of a test that pumps part of it).
final appProviders = <Provider<Object>>[
  themeModeProvider,
  directionalityProvider,
  themeConfigProvider,
  themeEditorOpenProvider,
  appSectionProvider,
];

/// Flips between light and dark.
void toggleThemeMode(BuildContext context) {
  themeModeProvider
      .of(context)
      .updateValue(
        (mode) => mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
      );
}
