import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A chosen row shows that it was chosen before the menu goes: its
/// highlight blinks off and on, as a macOS menu's does, and only then does
/// the menu close and the row's callback run. Without motion there is no
/// blink.
void main() {
  Future<PopoverController> pumpMenu(
    WidgetTester tester, {
    required VoidCallback onOpen,
    Motion? motion,
  }) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = PopoverController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      UnaApp(
        theme: ThemeData(motion: motion),
        formFactor: FormFactor.desktop,
        home: Align(
          alignment: Alignment.topLeft,
          child: DropdownMenu(
            controller: controller,
            items: [
              MenuItem(onPressed: onOpen, child: const Text('Open')),
              MenuItem(onPressed: () {}, child: const Text('Save')),
            ],
            builder: (context, controller, _) => const Text('Anchor'),
          ),
        ),
      ),
    );
    controller.open();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    return controller;
  }

  Color? fillOf(WidgetTester tester, String label) => tester
      .widget<Decorator>(
        find
            .descendant(
              of: find.ancestor(
                of: find.text(label),
                matching: find.byType(Button),
              ),
              matching: find.byType(Decorator),
            )
            .first,
      )
      .decoration
      ?.color;

  testWidgets('the row blinks, then the menu closes and the callback runs', (
    tester,
  ) async {
    var opened = 0;
    final menu = await pumpMenu(tester, onOpen: () => opened++);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(find.text('Open')));
    await tester.pump();
    final highlight = fillOf(tester, 'Open');
    expect(highlight, isNotNull);

    await mouse.down(tester.getCenter(find.text('Open')));
    await mouse.up();
    await tester.pump();
    // Off first: the row is back at rest for a moment.
    expect(opened, 0);
    expect(menu.isOpen, isTrue);
    expect(fillOf(tester, 'Open'), isNot(highlight));

    // Then lit again, and still nothing has happened.
    await tester.pump(const Duration(milliseconds: 60));
    expect(fillOf(tester, 'Open'), highlight);
    expect(opened, 0);

    // Then the menu goes and the row does what it does — once.
    await tester.pump(const Duration(milliseconds: 100));
    expect(opened, 1);
    expect(menu.isOpen, isFalse);
    await tester.pump(const Duration(milliseconds: 400));
    expect(opened, 1);
  });

  testWidgets('a second row cannot be chosen during the blink', (
    tester,
  ) async {
    var opened = 0;
    await pumpMenu(tester, onOpen: () => opened++);
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.tap(find.text('Open'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(opened, 1);
  });

  testWidgets('without motion the menu closes at once', (tester) async {
    var opened = 0;
    final menu = await pumpMenu(
      tester,
      onOpen: () => opened++,
      motion: Motion.none,
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(opened, 1);
    expect(menu.isOpen, isFalse);
  });
}
