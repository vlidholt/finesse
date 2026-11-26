import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// Escape closes one layer of a menu tree at a time, innermost first: the
/// submenu the focus is in, then the menu it hangs from.
void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<PopoverController> openTree(WidgetTester tester) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      UnaApp(
        home: Align(
          alignment: const Alignment(-.6, -.6),
          child: DropdownMenu(
            controller: controller,
            items: const [
              MenuItem(child: Text('Open')),
              MenuItem(
                items: [
                  MenuItem(child: Text('Email')),
                  MenuItem(child: Text('Link')),
                ],
                child: Text('Share'),
              ),
              MenuItem(child: Text('Delete')),
            ],
            builder: (context, controller, _) => Button.outline(
              onPressed: controller.toggle,
              child: const Text('More'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('More'));
    await settle(tester);
    // Down to the row with a submenu, which opens it, and into it.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);
    expect(find.text('Email'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
    return controller;
  }

  bool focusIn(WidgetTester tester, String label) {
    final focus = FocusManager.instance.primaryFocus?.context;
    if (focus == null) return false;
    var found = false;
    void visit(Element element) {
      if (found) return;
      final widget = element.widget;
      if (widget is Text && widget.data == label) found = true;
      element.visitChildren(visit);
    }

    (focus as Element).visitChildren(visit);
    return found;
  }

  testWidgets('with the focus in a submenu, one press closes the submenu '
      'and the next the menu', (tester) async {
    final controller = await openTree(tester);
    expect(focusIn(tester, 'Email'), isTrue, reason: 'not in the submenu');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Email'), findsNothing, reason: 'the submenu is open');
    expect(find.text('Share'), findsOneWidget, reason: 'the menu closed');
    expect(controller.isOpen, isTrue);
    // The focus is back on the row the submenu hangs from.
    expect(focusIn(tester, 'Share'), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(controller.isOpen, isFalse);
    expect(find.text('Share'), findsNothing);
  });

  testWidgets('a submenu closed with Escape opens again from its row', (
    tester,
  ) async {
    await openTree(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Email'), findsNothing);

    // The arrow that leads into it opens it again.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester);
    expect(find.text('Email'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);
    expect(find.text('Email'), findsNothing);
    // And so does leaving the row and coming back to it.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await settle(tester);
    expect(find.text('Email'), findsOneWidget);
  });
}
