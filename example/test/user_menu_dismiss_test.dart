import 'package:example/common/app_shell.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/strand/widgets/user_menu.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The account menu must be gone once one of its entries has been chosen —
/// whatever the entry does to the app around it.
///
/// "Browse components" switches the app to the component library. Strand
/// stays alive in an `IndexedStack` with its tickers disabled, and the menu
/// — whose overlay lives in the page navigator, above both sections — used
/// to stay on screen over the library: its exit animation never ran, and
/// with its anchor off stage nothing could close it.
void main() {
  setUpAll(setUpFonts);

  Future<void> openMenu(WidgetTester tester) async {
    // The avatar pill in the app bar: the one caret in it.
    await tester.tap(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(PhosphorIconsRegular.caretDown),
      ),
    );
    await settle(tester);
    expect(find.text('Browse components'), findsOneWidget);
  }

  /// No menu anywhere. Off-stage elements count: the menu is painted in the
  /// page navigator's overlay, but its element hangs under its anchor, in
  /// the Strand section — which is off stage once the library shows, and a
  /// finder that skipped it would call a menu still on screen "gone".
  void expectMenuGone(WidgetTester tester) {
    expect(find.byType(MenuItem, skipOffstage: false), findsNothing);
    expect(tester.takeException(), isNull);
  }

  testWidgets('Browse components closes the menu and shows the library', (
    tester,
  ) async {
    await pumpApp(tester);
    await openMenu(tester);

    await tester.tap(find.text('Browse components'));
    await settle(tester);

    expect(sectionSignal(tester).value, AppSection.components);
    expect(find.byType(ComponentsSection), findsOneWidget);
    expectMenuGone(tester);

    // Back on Strand the menu is closed, and opens again.
    sectionSignal(tester).value = AppSection.strand;
    await settle(tester);
    expectMenuGone(tester);
    await openMenu(tester);
  });

  testWidgets('every other entry closes it too', (tester) async {
    await pumpApp(tester);

    await openMenu(tester);
    await tester.tap(find.text('View profile'));
    await settle(tester);
    expectMenuGone(tester);

    await openMenu(tester);
    await tester.tap(find.text('Dark mode'));
    await settle(tester);
    expectMenuGone(tester);
    expect(find.text('Light mode'), findsNothing);

    // Docking the editor narrows the page; the menu's anchor moves, or
    // goes altogether when the page falls back to the phone layout.
    await openMenu(tester);
    await tester.tap(find.text('Open theme editor'));
    await settle(tester, frames: 20);
    expect(find.byType(ThemeCustomizerPanel), findsOneWidget);
    expectMenuGone(tester);
  });

  testWidgets('the editor toggle on a window that turns to the phone layout', (
    tester,
  ) async {
    // 1000 wide is a desktop; with the 360-point panel docked the page is
    // a phone, so the avatar pill — the menu's anchor — is unmounted.
    await pumpApp(tester, size: const Size(1000, 900));
    await openMenu(tester);
    await tester.tap(find.text('Open theme editor'));
    await settle(tester, frames: 24);
    expect(editorOpenSignal(tester).value, isTrue);
    expectMenuGone(tester);
    expect(find.byType(UserMenu), findsNothing);
  });

  testWidgets('a tap outside and Escape still close an open menu', (
    tester,
  ) async {
    await pumpApp(tester);
    await openMenu(tester);
    await tester.tapAt(const Offset(20, 600));
    await settle(tester);
    expectMenuGone(tester);
    expect(find.byType(DropdownMenu), findsWidgets);
  });
}
