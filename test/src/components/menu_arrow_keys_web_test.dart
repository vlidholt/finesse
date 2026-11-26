// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  // The web's default shortcuts scroll with the arrow keys rather than move
  // the focus, so a menu that left the arrows to the defaults could not be
  // walked in a browser. `menu_arrow_keys_test.dart` holds the same on the
  // VM with a copy of the web's shortcut map; this is the real one.
  testWidgets('the arrow keys walk a menu and a select in the browser', (
    tester,
  ) async {
    final menu = PopoverController();
    final select = PopoverController();
    addTearDown(menu.dispose);
    addTearDown(select.dispose);
    await tester.pumpWidget(
      UnaApp(
        home: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu(
              controller: menu,
              items: [
                MenuItem(onPressed: () {}, child: const Text('One')),
                MenuItem(onPressed: () {}, child: const Text('Two')),
              ],
              builder: (context, controller, _) => const Text('Anchor'),
            ),
            Select<String>(
              onChanged: (_) {},
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

    menu.open();
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
    menu.close();
    await settle();

    select.open();
    await settle();
    expect(focused('Apple'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('Banana'), isTrue);
  });

  // A menu shown with `showMenu` is in a route of its own, and its checkable
  // rows, labels and dividers are rows like any other to the arrows.
  testWidgets('the arrow keys walk a menu shown at a point in the browser', (
    tester,
  ) async {
    late BuildContext page;
    await tester.pumpWidget(
      UnaApp(
        home: Builder(
          builder: (context) {
            page = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    bool focused(String label) =>
        Focus.of(tester.element(find.text(label))).hasFocus;
    showMenu<void>(
      context: page,
      position: const Offset(40, 40),
      items: [
        const MenuLabel(child: Text('View')),
        MenuCheckboxItem(
          checked: true,
          onChanged: (_) {},
          child: const Text('Grid'),
        ),
        const MenuDivider(),
        MenuRadioGroup<int>(
          value: 1,
          onChanged: (_) {},
          children: const [
            MenuRadioItem(value: 1, child: Text('Small')),
            MenuRadioItem(value: 2, child: Text('Large')),
          ],
        ),
      ],
    ).ignore();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('Grid'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('Small'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused('Large'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(focused('Small'), isTrue);
  });
}
