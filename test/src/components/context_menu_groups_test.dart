import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every context menu used to share one tap-region group, so a tap on another
/// menu's trigger counted as "inside" and the open menu never closed.
void main() {
  Future<void> pumpMenus(
    WidgetTester tester,
    FinesseContextMenuController a,
    FinesseContextMenuController b,
  ) async {
    await tester.pumpWidget(
      FinesseApp(
        home: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ContextMenu(
              controller: a,
              items: const [ContextMenuItem(child: Text('a item'))],
              child: const SizedBox(width: 80, height: 40, child: Text('A')),
            ),
            ContextMenu(
              controller: b,
              items: const [ContextMenuItem(child: Text('b item'))],
              child: const SizedBox(width: 80, height: 40, child: Text('B')),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets("a tap on another menu's trigger closes the open menu", (
    tester,
  ) async {
    final a = FinesseContextMenuController();
    final b = FinesseContextMenuController();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    await pumpMenus(tester, a, b);

    a.show();
    await tester.pumpAndSettle();
    expect(find.text('a item'), findsOneWidget);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(a.isOpen, isFalse);
  });
}
