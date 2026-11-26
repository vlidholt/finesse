import 'dart:ui' show CheckedState, SemanticsRole;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// What a screen reader is told a menu is: a menu of menu items, of which
/// some are checkboxes and radio buttons that are checked or not, under a
/// menu bar where there is one.
void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// The node that carries [label], and the roles of its ancestors.
  (SemanticsNode, List<SemanticsRole>) nodeOf(
    WidgetTester tester,
    String label,
  ) {
    final node = tester.getSemantics(find.text(label));
    final above = <SemanticsRole>[];
    for (var n = node.parent; n != null; n = n.parent) {
      final role = n.getSemanticsData().role;
      if (role != SemanticsRole.none) above.add(role);
    }
    return (node, above);
  }

  testWidgets('a menu, its items, and the checked state of the checkable '
      'ones', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      UnaApp(
        home: Align(
          alignment: const Alignment(-.6, -.6),
          child: DropdownMenu(
            items: [
              const MenuItem(child: Text('Rename')),
              MenuCheckboxItem(
                checked: true,
                onChanged: (_) {},
                child: const Text('Show hidden'),
              ),
              MenuRadioGroup<String>(
                value: 'name',
                onChanged: (_) {},
                children: const [
                  MenuRadioItem(value: 'name', child: Text('By name')),
                  MenuRadioItem(value: 'date', child: Text('By date')),
                ],
              ),
              const MenuItem(
                items: [MenuItem(child: Text('Email'))],
                child: Text('Share'),
              ),
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

    final (rename, aboveRename) = nodeOf(tester, 'Rename');
    final renameData = rename.getSemanticsData();
    expect(renameData.role, SemanticsRole.menuItem);
    expect(renameData.label, 'Rename');
    expect(renameData.hasAction(SemanticsAction.tap), isTrue);
    expect(aboveRename, contains(SemanticsRole.menu));

    final hidden = nodeOf(tester, 'Show hidden').$1.getSemanticsData();
    expect(hidden.role, SemanticsRole.menuItemCheckbox);
    expect(hidden.flagsCollection.isChecked, CheckedState.isTrue);

    final byName = nodeOf(tester, 'By name').$1.getSemanticsData();
    expect(byName.role, SemanticsRole.menuItemRadio);
    expect(byName.flagsCollection.isChecked, CheckedState.isTrue);
    expect(byName.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    final byDate = nodeOf(tester, 'By date').$1.getSemanticsData();
    expect(byDate.role, SemanticsRole.menuItemRadio);
    expect(byDate.flagsCollection.isChecked, CheckedState.isFalse);

    // A submenu is a menu of its own, with its own items.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Share')));
    await settle(tester);
    final (email, aboveEmail) = nodeOf(tester, 'Email');
    expect(email.getSemanticsData().role, SemanticsRole.menuItem);
    expect(aboveEmail, contains(SemanticsRole.menu));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('a menu bar, with its triggers as menu items', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const UnaApp(
        home: Align(
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
        ),
      ),
    );
    final (file, above) = nodeOf(tester, 'File');
    final data = file.getSemanticsData();
    expect(data.role, SemanticsRole.menuItem);
    expect(data.label, 'File');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(above, contains(SemanticsRole.menuBar));

    await tester.tap(find.text('File'));
    await settle(tester);
    final (item, aboveItem) = nodeOf(tester, 'New file');
    expect(item.getSemanticsData().role, SemanticsRole.menuItem);
    expect(aboveItem, contains(SemanticsRole.menu));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });
}
