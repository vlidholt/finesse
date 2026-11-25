import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

const _menubar = Align(
  alignment: Alignment.topLeft,
  child: Menubar(
    items: [
      MenubarItem(
        items: [MenuItem(child: Text('New file'))],
        child: Text('File'),
      ),
      MenubarItem(
        items: [MenuItem(child: Text('Undo'))],
        child: Text('Edit'),
      ),
    ],
  ),
);

Future<void> _frames(WidgetTester tester, [int count = 30]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('tapping another menubar menu switches to it', (tester) async {
    await tester.pumpWidget(const FinesseApp(home: _menubar));

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('New file'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('New file'), findsNothing);
  });

  group('a menu that closes itself leaves the menubar closed', () {
    Future<TestGesture> openFile(WidgetTester tester) async {
      await pumpFinesse(tester, _menubar);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(700, 700));
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('File')));
      await mouse.down(tester.getCenter(find.text('File')));
      await mouse.up();
      await _frames(tester);
      expect(find.text('New file'), findsOneWidget);
      return mouse;
    }

    testWidgets('after a row is chosen, hovering another trigger opens '
        'nothing', (tester) async {
      final mouse = await openFile(tester);
      await mouse.moveTo(tester.getCenter(find.text('New file')));
      await mouse.down(tester.getCenter(find.text('New file')));
      await mouse.up();
      await _frames(tester);
      expect(find.text('New file'), findsNothing);

      await mouse.moveTo(tester.getCenter(find.text('Edit')));
      await _frames(tester);
      expect(find.text('Undo'), findsNothing);
    });

    testWidgets('after Escape, it stays closed and hovering another trigger '
        'opens nothing', (tester) async {
      final mouse = await openFile(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _frames(tester);
      expect(find.text('New file'), findsNothing);

      await mouse.moveTo(tester.getCenter(find.text('Edit')));
      await _frames(tester);
      expect(find.text('Undo'), findsNothing);
      expect(find.text('New file'), findsNothing);
    });

    testWidgets('opened from the keyboard, Escape closes it for good', (
      tester,
    ) async {
      await pumpFinesse(tester, _menubar);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await _frames(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _frames(tester);
      expect(find.text('New file'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _frames(tester);
      expect(find.text('New file'), findsNothing);
    });
  });
}
