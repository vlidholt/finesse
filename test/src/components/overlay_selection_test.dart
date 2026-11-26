import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// An overlay is not part of the text selection of the page it opens from.
///
/// A popover's content is built under its anchor, so a `SelectionArea`
/// around the page — every docs page has one — took the text of an open
/// menu, hover card or tooltip into its selection: the right click that
/// opened a context menu, or the long press that opened a hover card,
/// selected the words under it, and Select All painted the selection
/// highlight over every row of the menu.
void main() {
  testWidgets('select all on the page leaves an open menu out', (
    tester,
  ) async {
    SelectedContent? selected;
    final controller = PopoverController();
    addTearDown(controller.dispose);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await pumpUna(
      tester,
      SelectionArea(
        focusNode: focus,
        onSelectionChanged: (content) => selected = content,
        child: Column(
          children: [
            const Text('Page'),
            ContextMenu(
              controller: controller,
              requestFocus: false,
              items: const [
                MenuItem(child: Text('Back')),
                MenuItem(child: Text('Reload')),
              ],
              child: const Text('Anchor'),
            ),
            Popover(
              controller: controller,
              requestFocus: false,
              builder: (context) => const Text('Card text'),
              child: const Text('Card anchor'),
            ),
          ],
        ),
      ),
    );
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('Back'), findsOneWidget);

    focus.requestFocus();
    await tester.pump();
    final control =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
    await tester.sendKeyDownEvent(
      control ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(
      control ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    );
    await tester.pump();

    expect(selected?.plainText, contains('Page'));
    expect(selected?.plainText, isNot(contains('Back')));
    expect(selected?.plainText, isNot(contains('Card text')));
  });

  testWidgets('a right click on a menu row does not select its text', (
    tester,
  ) async {
    SelectedContent? selected;
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await pumpUna(
      tester,
      SelectionArea(
        onSelectionChanged: (content) => selected = content,
        child: ContextMenu(
          controller: controller,
          items: const [MenuItem(child: Text('Back'))],
          child: const Text('Anchor'),
        ),
      ),
    );
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tapAt(
      tester.getCenter(find.text('Back')),
      buttons: kSecondaryButton,
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(selected?.plainText ?? '', isEmpty);
  });
}
