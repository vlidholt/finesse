// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The web's default shortcuts scroll with the arrow keys rather than move
  // the focus, so a menu that left the arrows to the defaults could not be
  // walked in a browser. `menu_arrow_keys_test.dart` holds the same on the
  // VM with a copy of the web's shortcut map; this is the real one.
  testWidgets('the arrow keys walk a menu and a select in the browser', (
    tester,
  ) async {
    final menu = FinesseContextMenuController();
    final select = PopoverController();
    addTearDown(menu.dispose);
    addTearDown(select.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu(
              controller: menu,
              items: [
                ContextMenuItem(onPressed: () {}, child: const Text('One')),
                ContextMenuItem(onPressed: () {}, child: const Text('Two')),
              ],
              builder: (context, controller, _) => const Text('Anchor'),
            ),
            Select<String>(
              controller: select,
              initialValue: 'a',
              options: const [
                SelectOption(value: 'a', child: Text('Apple')),
                SelectOption(value: 'b', child: Text('Banana')),
              ],
              selectedOptionBuilder: (context, value) => Text('is $value'),
            ),
          ],
        ),
      ),
    );
    bool focused(String label) =>
        Focus.of(tester.element(find.text(label))).hasFocus;
    Future<void> settle() async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    menu.show();
    await settle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('One'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('Two'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(focused('One'), isTrue);
    menu.hide();
    await settle();

    select.show();
    await settle();
    expect(focused('Apple'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('Banana'), isTrue);
  });
}
