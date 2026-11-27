import 'dart:ui' show Tristate;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

Future<void> _frames(WidgetTester tester, [int count = 20]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await _frames(tester);
}

/// Whether the primary focus is on the control that shows [label].
bool _focused(String label) {
  final node = FocusManager.instance.primaryFocus;
  // A scope, or a menu's content, holds every control below it.
  if (node is FocusScopeNode || node?.debugLabel == 'ContextMenu content') {
    return false;
  }
  final focus = node?.context;
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

Widget _dropdown() => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Button(onPressed: () {}, child: const Text('Before')),
    DropdownMenu(
      items: const [
        MenuItem(child: Text('Profile')),
        MenuItem(
          items: [MenuItem(child: Text('Email'))],
          child: Text('Share'),
        ),
      ],
      builder: (context, controller, _) =>
          Button(onPressed: controller.toggle, child: const Text('More')),
    ),
    Button(onPressed: () {}, child: const Text('After')),
  ],
);

void main() {
  group('a menu opened from the keyboard', () {
    testWidgets('focuses its first row', (tester) async {
      await pumpUna(tester, Center(child: _dropdown()));
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.tab);
      expect(_focused('More'), isTrue);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(find.text('Profile'), findsOneWidget);
      expect(_focused('Profile'), isTrue);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        isNot('ContextMenu content'),
      );
    });

    testWidgets('opened by a pointer, focuses the menu, not a row', (
      tester,
    ) async {
      await pumpUna(tester, Center(child: _dropdown()));
      await tester.tap(find.text('More'));
      await _frames(tester);
      expect(find.text('Profile'), findsOneWidget);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        'ContextMenu content',
      );
      // The arrows enter it at the top.
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_focused('Profile'), isTrue);
    });

    testWidgets('Tab closes it and moves on from the trigger', (tester) async {
      await pumpUna(tester, Center(child: _dropdown()));
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(_focused('Profile'), isTrue);

      await _key(tester, LogicalKeyboardKey.tab);
      await _frames(tester);
      expect(find.text('Profile'), findsNothing);
      expect(_focused('After'), isTrue);
    });

    testWidgets('Shift+Tab closes it and moves back from the trigger', (
      tester,
    ) async {
      await pumpUna(tester, Center(child: _dropdown()));
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.enter);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await _key(tester, LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await _frames(tester);
      expect(find.text('Profile'), findsNothing);
      expect(_focused('Before'), isTrue);
    });

    testWidgets('Left in a submenu closes it and goes back to its row', (
      tester,
    ) async {
      await pumpUna(tester, Center(child: _dropdown()));
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.enter);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(_focused('Email'), isTrue);

      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(find.text('Email'), findsNothing);
      expect(_focused('Share'), isTrue);
      expect(find.text('Profile'), findsOneWidget);
    });
  });

  group('open state', () {
    testWidgets("a dropdown's trigger says whether its menu is open", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, Center(child: _dropdown()));
      expect(
        tester.getSemantics(find.text('More')),
        isSemantics(label: 'More', isButton: true, isExpanded: false),
      );
      await tester.tap(find.text('More'));
      await _frames(tester);
      expect(
        tester.getSemantics(find.text('More')),
        isSemantics(label: 'More', isButton: true, isExpanded: true),
      );
      handle.dispose();
    });

    testWidgets('a row with a submenu says whether it is open', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, Center(child: _dropdown()));
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.enter);
      expect(
        tester.getSemantics(find.text('Share')),
        isSemantics(label: 'Share', isExpanded: false),
      );
      // A row without one says nothing about it.
      expect(
        tester
            .getSemantics(find.text('Profile'))
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        Tristate.none,
      );
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(
        tester.getSemantics(find.text('Share')),
        isSemantics(label: 'Share', isExpanded: true),
      );
      handle.dispose();
    });
  });

  group('ContextMenuRegion', () {
    Widget region() => Center(
      child: ContextMenuRegion(
        items: const [MenuItem(child: Text('Copy'))],
        child: Button(onPressed: () {}, child: const Text('Target')),
      ),
    );

    testWidgets('the context menu key opens it at the bottom start corner of '
        'the child', (tester) async {
      await pumpUna(tester, region());
      await _key(tester, LogicalKeyboardKey.tab);
      expect(_focused('Target'), isTrue);
      await _key(tester, LogicalKeyboardKey.contextMenu);
      expect(find.text('Copy'), findsOneWidget);
      final child = tester.getRect(
        find.ancestor(of: find.text('Target'), matching: find.byType(Button)),
      );
      final row = tester.getRect(find.text('Copy'));
      expect(row.top, greaterThanOrEqualTo(child.bottom - 1));
      expect((row.left - child.left).abs(), lessThan(24));
      expect(_focused('Copy'), isTrue);
    });

    testWidgets('so does Shift+F10, right to left at the bottom right', (
      tester,
    ) async {
      await pumpUna(tester, region(), textDirection: TextDirection.rtl);
      await _key(tester, LogicalKeyboardKey.tab);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await _key(tester, LogicalKeyboardKey.f10);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      expect(find.text('Copy'), findsOneWidget);
      final child = tester.getRect(
        find.ancestor(of: find.text('Target'), matching: find.byType(Button)),
      );
      final row = tester.getRect(find.text('Copy'));
      expect(row.top, greaterThanOrEqualTo(child.bottom - 1));
      expect((row.right - child.right).abs(), lessThan(24));
    });

    testWidgets('F10 alone opens nothing', (tester) async {
      await pumpUna(tester, region());
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, LogicalKeyboardKey.f10);
      expect(find.text('Copy'), findsNothing);
    });
  });
}
