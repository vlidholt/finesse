import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// Every context menu used to share one tap-region group, so a tap on another
/// menu's trigger counted as "inside" and the open menu never closed.
void main() {
  Future<void> pumpMenus(
    WidgetTester tester,
    PopoverController a,
    PopoverController b,
  ) async {
    await tester.pumpWidget(
      UnaApp(
        home: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ContextMenu(
              controller: a,
              items: const [MenuItem(child: Text('a item'))],
              child: const SizedBox(width: 80, height: 40, child: Text('A')),
            ),
            ContextMenu(
              controller: b,
              items: const [MenuItem(child: Text('b item'))],
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
    final a = PopoverController();
    final b = PopoverController();
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    await pumpMenus(tester, a, b);

    a.open();
    await tester.pumpAndSettle();
    expect(find.text('a item'), findsOneWidget);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(a.isOpen, isFalse);
  });
}
