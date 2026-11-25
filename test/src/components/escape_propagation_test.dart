import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A closed tooltip, popover or select must not swallow Escape: it has to
/// reach the dialog around it. An open one closes itself and stops there.
void main() {
  Future<void> openDialog(WidgetTester tester, Widget content) async {
    await tester.pumpWidget(
      FinesseApp(
        home: Builder(
          builder: (context) => Center(
            child: Button(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => Dialog(
                  title: const Text('Dialog'),
                  child: content,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog'), findsOneWidget);
  }

  Future<void> pressEscape(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  }

  testWidgets('Escape on a closed tooltip trigger closes the dialog', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await openDialog(
      tester,
      Tooltip(
        builder: (_) => const Text('tip'),
        child: Button(
          focusNode: focusNode,
          onPressed: () {},
          child: const Text('trigger'),
        ),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();

    await pressEscape(tester);
    expect(find.text('Dialog'), findsNothing);
  });

  testWidgets('Escape closes an open popover first, then the dialog', (
    tester,
  ) async {
    final controller = PopoverController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);
    await openDialog(
      tester,
      Popover(
        controller: controller,
        builder: (_) => const Text('content'),
        child: Button(
          focusNode: focusNode,
          onPressed: controller.toggle,
          child: const Text('trigger'),
        ),
      ),
    );
    focusNode.requestFocus();
    controller.open();
    await tester.pumpAndSettle();
    expect(controller.isOpen, isTrue);

    await pressEscape(tester);
    expect(controller.isOpen, isFalse);
    expect(find.text('Dialog'), findsOneWidget);

    focusNode.requestFocus();
    await tester.pump();
    await pressEscape(tester);
    expect(find.text('Dialog'), findsNothing);
  });

  testWidgets("DismissShortcut does the same for an app's own panel", (
    tester,
  ) async {
    // Through the package's public library, which is all an app can import:
    // this file sees nothing under `src/`.
    var open = true;
    var dismissed = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await openDialog(
      tester,
      DismissShortcut(
        isActive: () => open,
        onDismiss: () {
          dismissed++;
          open = false;
        },
        child: TextField(focusNode: focusNode),
      ),
    );
    focusNode.requestFocus();
    await tester.pump();

    // Open: Escape closes the panel and stops there. Nothing was rebuilt
    // in between — the shortcut asks when the key arrives.
    await pressEscape(tester);
    expect(dismissed, 1);
    expect(find.text('Dialog'), findsOneWidget);

    // Closed: the same key now reaches the dialog.
    expect(focusNode.hasFocus, isTrue);
    await pressEscape(tester);
    expect(dismissed, 1);
    expect(find.text('Dialog'), findsNothing);
  });

  group('DismissShortcut reports the key', () {
    Future<FocusNode> pumpPanel(
      WidgetTester tester, {
      required bool Function() isActive,
      required VoidCallback onDismiss,
      bool Function()? outerActive,
      VoidCallback? onOuterDismiss,
    }) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      Widget child = DismissShortcut(
        isActive: isActive,
        onDismiss: onDismiss,
        child: Focus(focusNode: focusNode, child: const SizedBox.square()),
      );
      if (outerActive != null) {
        child = DismissShortcut(
          isActive: outerActive,
          onDismiss: onOuterDismiss!,
          child: child,
        );
      }
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: child),
      );
      focusNode.requestFocus();
      await tester.pump();
      return focusNode;
    }

    testWidgets('as handled when it dismissed something', (tester) async {
      // The callback closes the panel, so by the time the framework asks
      // whether the key was consumed the shortcut is inactive again. The
      // answer has to be about the press that was just handled.
      var open = true;
      var dismissed = 0;
      await pumpPanel(
        tester,
        isActive: () => open,
        onDismiss: () {
          dismissed++;
          open = false;
        },
      );

      final handled = await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(dismissed, 1);
      expect(
        handled,
        isTrue,
        reason: 'the Escape that closed the panel went on to the platform',
      );
    });

    testWidgets('as unhandled while inactive', (tester) async {
      var dismissed = 0;
      await pumpPanel(
        tester,
        isActive: () => false,
        onDismiss: () => dismissed++,
      );

      final handled = await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(dismissed, 0);
      expect(handled, isFalse);
    });

    testWidgets('one press closes one layer, innermost first', (
      tester,
    ) async {
      var innerOpen = true;
      var outerOpen = true;
      final order = <String>[];
      await pumpPanel(
        tester,
        isActive: () => innerOpen,
        onDismiss: () {
          order.add('inner');
          innerOpen = false;
        },
        outerActive: () => outerOpen,
        onOuterDismiss: () {
          order.add('outer');
          outerOpen = false;
        },
      );

      // The inner one takes the first press and the outer one never hears
      // of it; with the inner one closed, the next press is the outer's.
      expect(await tester.sendKeyEvent(LogicalKeyboardKey.escape), isTrue);
      expect(order, ['inner']);
      expect(await tester.sendKeyEvent(LogicalKeyboardKey.escape), isTrue);
      expect(order, ['inner', 'outer']);
      // Nothing left to close: the key is the platform's.
      expect(await tester.sendKeyEvent(LogicalKeyboardKey.escape), isFalse);
      expect(order, ['inner', 'outer']);
    });
  });
}
