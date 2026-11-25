import 'package:disco/disco.dart';
import 'package:example/common/app_shell.dart';
import 'package:example/common/app_state.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/docs/docs.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/jobs_board_view.dart';
import 'package:finesse/finesse.dart';
import 'package:finesse/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

export 'package:example/common/app_state.dart';
export 'package:example/strand/navigation.dart'
    show StrandDestination, strandDestinationProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SolidartConfig.devToolsEnabled = false;
  // Together, not one after the other: each is a round trip to the
  // network, and the first frame waits for both.
  await Future.wait([
    // The docs' code blocks need the Dart grammar and highlighter theme.
    CodeHighlighter.ensureInitialized(),
    // finesse bundles no fonts. Fetch the editor's default face before the
    // first frame, so the app does not open in the fallback font and then
    // reflow.
    EditorFont.byTitle(const ThemeEditorConfig().fontTitle).load(
      timeout: const Duration(seconds: 3),
    ),
  ]);
  runApp(const App());
}

/// Every app-level provider: the state in `common/app_state.dart` and
/// Strand's selected destination. They sit above [FinesseApp], so every
/// route can read them.
final appProviders = <InstantiableProvider>[
  appSectionProvider,
  themeModeProvider,
  directionalityProvider,
  themeConfigProvider,
  themeEditorOpenProvider,
  strandDestinationProvider,
  strandSessionProvider,
  jobsViewProvider,
];

/// Named styles the app adds on top of whatever the editor produces — an
/// example of extending [TextTheme]; see the `/typography` page for how
/// they are read back.
Map<String, TextStyle> appCustomTextStyles(Brightness brightness) => {
  'myCustomStyle': TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: brightness == Brightness.light
        ? const Color(0xFF2196F3)
        : const Color(0xFF4CAF50),
  ),
};

/// The example app: Strand, the social network the default theme was
/// designed for, with the component library and the theme editor one menu
/// away.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// The themes built from [_builtFrom]. Each bakes some fifty component
  /// themes, so they are rebuilt when the configuration changes and not when
  /// the window is resized or the editor panel is toggled.
  ThemeEditorConfig? _builtFrom;
  late ThemeData _theme;
  late ThemeData _darkTheme;

  void _buildThemes(ThemeEditorConfig config) {
    // The text scale is applied through `MediaQuery` below, not through the
    // theme; leaving it out of the key keeps a drag of that slider from
    // building two themes per tick.
    final key = config.copyWith(textScale: 1);
    if (key == _builtFrom) return;
    _builtFrom = key;
    _theme = key
        .copyWith(brightness: Brightness.light)
        .build(customTextStyles: appCustomTextStyles(Brightness.light));
    _darkTheme = key
        .copyWith(brightness: Brightness.dark)
        .build(customTextStyles: appCustomTextStyles(Brightness.dark));
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      providers: appProviders,
      child: SignalBuilder(
        builder: (context, _) {
          final themeMode = themeModeProvider.of(context).value;
          final directionality = directionalityProvider.of(context).value;
          // Both themes come from the editor's configuration, so the panel
          // restyles the whole app — Strand and the component library alike.
          final config = themeConfigProvider.of(context).value;
          final editorOpen = themeEditorOpenProvider.of(context).value;
          _buildThemes(config);
          final theme = _theme;
          final darkTheme = _darkTheme;

          return LayoutBuilder(
            builder: (context, constraints) {
              // FinesseApp would pick the form factor from the window. The
              // docked editor takes a slice of it, so pick from the width
              // the page is left with: docking the panel beside a
              // medium-width window shows the phone layout it has room for.
              // The editor can also pin one; `AppShell` then gives that
              // layout a box it fits in.
              return FinesseApp(
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: theme,
                darkTheme: darkTheme,
                formFactor: AppShell.formFactorFor(
                  constraints.maxWidth,
                  editorOpen: editorOpen,
                  mode: config.formFactor,
                  breakpoint: theme.breakpoints.md.value,
                ),
                home: const AppShell(),
                builder: (context, child) {
                  // The docs and the theme editor use a few Material widgets
                  // (Slider, SelectionArea); FinesseMaterial themes them from
                  // the finesse theme and adds their localizations.
                  return Directionality(
                    textDirection: directionality,
                    // The editor's text scale applies to the whole app; the
                    // customizer panel resets it for its own chrome.
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(config.textScale),
                      ),
                      child: FinesseMaterial(child: child!),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
