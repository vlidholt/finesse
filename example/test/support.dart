import 'package:example/common/app_shell.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// The designs' two canvases.
const desktopSize = Size(1440, 900);
const mobileSize = Size(390, 844);

/// The `setUpAll` of every test that builds the app or the theme editor.
///
/// Turns off google_fonts' network fetching — there is no network in tests;
/// the log lines it prints for each face it cannot fetch are noise — and
/// loads the one editor font it *can* find.
///
/// The editor's font picker builds a preview style for every font it
/// offers, and `GoogleFonts.getFont` starts loading a face as soon as it is
/// asked for a style. For JetBrains Mono that succeeds without a network,
/// because the example bundles the same files for its code blocks. The load
/// is real I/O, so it finishes at an arbitrary point after the panel first
/// opens, and the engine's "fonts changed" message then schedules a frame.
/// When that lands after a test's last pump, the test fails with "An
/// animation is still running even after the widget tree was disposed" —
/// which is what made the first panel-opening test of each file fail.
/// Loading the face once, up front, leaves nothing to arrive later.
Future<void> setUpFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await EditorFont.byTitle('JetBrains Mono').load(
    timeout: const Duration(seconds: 5),
  );
}

/// Pumps fixed frames. `pumpAndSettle` is unusable in this app: spinners,
/// skeletons and progress bars in the docs animate forever.
Future<void> settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Pumps the whole [App] in a window of [size] logical pixels.
Future<void> pumpApp(
  WidgetTester tester, {
  Size size = desktopSize,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const App());
  await settle(tester, frames: 8);
}

/// A context below the app's providers.
BuildContext appContext(WidgetTester tester) =>
    tester.element(find.byType(AppShell));

Signal<AppSection> sectionSignal(WidgetTester tester) =>
    appSectionProvider.of(appContext(tester));

Signal<bool> editorOpenSignal(WidgetTester tester) =>
    themeEditorOpenProvider.of(appContext(tester));

/// Opens the theme editor panel, as the menus' "Open theme editor" does.
Future<void> openThemeEditor(WidgetTester tester) async {
  editorOpenSignal(tester).value = true;
  await settle(tester);
  expect(find.byType(ThemeCustomizerPanel), findsOneWidget);
}

/// Switches to the component library, as the menus' "Browse components"
/// does.
Future<void> openComponentLibrary(WidgetTester tester) async {
  sectionSignal(tester).value = AppSection.components;
  await settle(tester);
}
