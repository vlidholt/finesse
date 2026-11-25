import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// On the web the app's default shortcuts do not bind the arrow keys to
/// directional focus — they scroll — so a list that relied on those
/// defaults to move between its rows could be entered with the keyboard
/// and then not walked: in a browser the arrows did nothing in a menu or a
/// select. The lists handle the arrows themselves.
///
/// These run on the VM with the web's shortcut map, so the suite catches it
/// without a browser; `menu_arrow_keys_web_test.dart` holds the same in
/// Chrome, on the real map.
const _webShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.enter): ButtonActivateIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): ButtonActivateIntent(),
  SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
  SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
  SingleActivator(LogicalKeyboardKey.tab, shift: true): PreviousFocusIntent(),
  SingleActivator(LogicalKeyboardKey.arrowUp): ScrollIntent(
    direction: AxisDirection.up,
  ),
  SingleActivator(LogicalKeyboardKey.arrowDown): ScrollIntent(
    direction: AxisDirection.down,
  ),
  SingleActivator(LogicalKeyboardKey.arrowLeft): ScrollIntent(
    direction: AxisDirection.left,
  ),
  SingleActivator(LogicalKeyboardKey.arrowRight): ScrollIntent(
    direction: AxisDirection.right,
  ),
};

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  bool focused(WidgetTester tester, String label) =>
      Focus.of(tester.element(find.text(label))).hasFocus;

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  for (final web in [false, true]) {
    final where = web ? "with the web's shortcuts" : 'with the defaults';

    testWidgets('the arrows walk a menu, stopping at either end — $where', (
      tester,
    ) async {
      final menu = FinesseContextMenuController();
      addTearDown(menu.dispose);
      await tester.pumpWidget(
        FinesseApp(
          shortcuts: web ? _webShortcuts : null,
          home: Center(
            child: DropdownMenu(
              controller: menu,
              items: [
                MenuItem(onPressed: () {}, child: const Text('One')),
                MenuItem(onPressed: () {}, child: const Text('Two')),
                MenuItem(onPressed: () {}, child: const Text('Three')),
              ],
              builder: (context, controller, _) => const Text('Anchor'),
            ),
          ),
        ),
      );
      menu.open();
      await settle(tester);

      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'One'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Two'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Three'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Three'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(focused(tester, 'Two'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowUp);
      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(focused(tester, 'One'), isTrue);
    });

    testWidgets('the arrows walk a menu shown at a point, past its labels '
        'and dividers and through its checkable rows — $where', (tester) async {
      late BuildContext page;
      await tester.pumpWidget(
        FinesseApp(
          shortcuts: web ? _webShortcuts : null,
          home: Builder(
            builder: (context) {
              page = context;
              return const SizedBox.expand();
            },
          ),
        ),
      );
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
          MenuItem(onPressed: () {}, child: const Text('Reset')),
        ],
      ).ignore();
      await settle(tester);

      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Grid'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Small'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Large'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Reset'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowUp);
      await press(tester, LogicalKeyboardKey.arrowUp);
      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(focused(tester, 'Grid'), isTrue);

      await press(tester, LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Grid'), findsNothing);
    });

    testWidgets("the arrows walk a select's options — $where", (tester) async {
      final popover = PopoverController();
      addTearDown(popover.dispose);
      String? chosen;
      await tester.pumpWidget(
        FinesseApp(
          shortcuts: web ? _webShortcuts : null,
          home: Center(
            child: Select<String>(
              controller: popover,
              initialValue: 'a',
              onChanged: (value) => chosen = value,
              options: const [
                SelectOption(value: 'a', child: Text('Apple')),
                SelectOption(value: 'b', child: Text('Banana')),
                SelectOption(value: 'c', child: Text('Cherry')),
              ],
              selectedOptionBuilder: (context, value) => Text('is $value'),
            ),
          ),
        ),
      );
      popover.open();
      await settle(tester);
      // The selected option has the focus when the list opens.
      expect(focused(tester, 'Apple'), isTrue);

      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Banana'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Cherry'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowDown);
      expect(focused(tester, 'Cherry'), isTrue);
      await press(tester, LogicalKeyboardKey.arrowUp);
      expect(focused(tester, 'Banana'), isTrue);

      await press(tester, LogicalKeyboardKey.enter);
      await settle(tester);
      expect(chosen, 'b');
    });
  }
}
