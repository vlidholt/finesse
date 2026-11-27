import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

Widget _menubar({TextDirection direction = TextDirection.ltr}) =>
    Directionality(
      textDirection: direction,
      child: const Align(
        alignment: AlignmentDirectional.topStart,
        child: Menubar(
          items: [
            MenubarItem(
              items: [
                MenuItem(child: Text('New file')),
                MenuItem(
                  items: [MenuItem(child: Text('Recent one'))],
                  child: Text('Open recent'),
                ),
              ],
              child: Text('File'),
            ),
            MenubarItem(
              items: [MenuItem(child: Text('Undo'))],
              child: Text('Edit'),
            ),
            MenubarItem(
              enabled: false,
              items: [MenuItem(child: Text('Zoom'))],
              child: Text('View'),
            ),
            MenubarItem(
              items: [MenuItem(child: Text('About'))],
              child: Text('Help'),
            ),
          ],
        ),
      ),
    );

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
bool _focused(WidgetTester tester, String label) {
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

void main() {
  testWidgets('Tab marks a trigger without opening its menu', (tester) async {
    await pumpUna(tester, _menubar());
    await _key(tester, LogicalKeyboardKey.tab);
    expect(_focused(tester, 'File'), isTrue);
    expect(find.text('New file'), findsNothing);

    await _key(tester, LogicalKeyboardKey.tab);
    expect(_focused(tester, 'Edit'), isTrue);
    expect(find.text('Undo'), findsNothing);
  });

  for (final key in [
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.arrowDown,
  ]) {
    testWidgets("${key.keyLabel} opens the focused trigger's menu, with its "
        'first row focused', (tester) async {
      await pumpUna(tester, _menubar());
      await _key(tester, LogicalKeyboardKey.tab);
      await _key(tester, key);
      expect(find.text('New file'), findsOneWidget);
      expect(_focused(tester, 'New file'), isTrue);
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        isNot('ContextMenu content'),
      );
    });
  }

  testWidgets('Right and Left move to the next and previous menu, past a '
      'disabled one and round the ends', (tester) async {
    await pumpUna(tester, _menubar());
    await _key(tester, LogicalKeyboardKey.tab);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(find.text('New file'), findsOneWidget);

    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('New file'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);
    expect(_focused(tester, 'Undo'), isTrue);

    // View is disabled.
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('Zoom'), findsNothing);
    expect(find.text('About'), findsOneWidget);

    // Round the end.
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('About'), findsNothing);
    expect(find.text('New file'), findsOneWidget);

    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('New file'), findsNothing);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('Right on a row with a submenu goes into the submenu, and Left '
      'there comes back to the row', (tester) async {
    await pumpUna(tester, _menubar());
    await _key(tester, LogicalKeyboardKey.tab);
    await _key(tester, LogicalKeyboardKey.enter);
    await _key(tester, LogicalKeyboardKey.arrowDown);
    expect(_focused(tester, 'Open recent'), isTrue);

    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(tester, 'Recent one'), isTrue);
    expect(find.text('Undo'), findsNothing);

    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focused(tester, 'Open recent'), isTrue);
    expect(find.text('New file'), findsOneWidget);
  });

  testWidgets('right to left, Left is the next menu', (tester) async {
    await pumpUna(tester, _menubar(direction: TextDirection.rtl));
    await _key(tester, LogicalKeyboardKey.tab);
    await _key(tester, LogicalKeyboardKey.enter);
    await _key(tester, LogicalKeyboardKey.arrowLeft);
    expect(find.text('Undo'), findsOneWidget);
    await _key(tester, LogicalKeyboardKey.arrowRight);
    expect(find.text('New file'), findsOneWidget);
  });

  testWidgets('Tab in an open menu closes it and moves to the next trigger', (
    tester,
  ) async {
    await pumpUna(tester, _menubar());
    await _key(tester, LogicalKeyboardKey.tab);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(find.text('New file'), findsOneWidget);

    await _key(tester, LogicalKeyboardKey.tab);
    await _frames(tester, 30);
    expect(find.text('New file'), findsNothing);
    expect(find.text('Undo'), findsNothing);
    expect(_focused(tester, 'Edit'), isTrue);
  });

  testWidgets('a trigger says whether its menu is open', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, _menubar());
    expect(
      tester.getSemantics(find.text('File')),
      isSemantics(role: SemanticsRole.menuItem, isExpanded: false),
    );
    await _key(tester, LogicalKeyboardKey.tab);
    await _key(tester, LogicalKeyboardKey.enter);
    expect(
      tester.getSemantics(find.text('File')),
      isSemantics(role: SemanticsRole.menuItem, isExpanded: true),
    );
    handle.dispose();
  });
}
