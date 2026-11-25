import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A popover opened from inside another one is drawn in the overlay,
/// outside the first one's box. A tap on it is still not a tap outside the
/// popovers around it — and a tap on one of those is a tap outside it.
void main() {
  Future<void> settle(WidgetTester tester) async {
    // Frame by frame: an overlay whose anchor is in another overlay only
    // shows once that one has begun to arrive.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('choosing in a select inside a popover keeps the popover', (
    tester,
  ) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    String? chosen;
    await tester.pumpWidget(
      FinesseApp(
        home: Align(
          alignment: const Alignment(0, -.8),
          child: Popover(
            controller: controller,
            builder: (context) => SizedBox(
              width: 240,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filters'),
                  Select<String>(
                    placeholder: const Text('Pick'),
                    onChanged: (value) => chosen = value,
                    options: const [
                      SelectOption(value: 'a', child: Text('Apple')),
                      SelectOption(value: 'b', child: Text('Banana')),
                    ],
                    selectedOptionBuilder: (context, value) => Text(value),
                  ),
                ],
              ),
            ),
            child: const Text('Trigger'),
          ),
        ),
      ),
    );
    controller.open();
    await settle(tester);
    await tester.tap(find.text('Pick'));
    await settle(tester);
    expect(find.text('Banana'), findsOneWidget);

    await tester.tap(find.text('Banana'));
    await settle(tester);
    expect(chosen, 'b');
    expect(controller.isOpen, isTrue, reason: 'the popover closed');
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Apple'), findsNothing, reason: 'the list stayed');
  });

  testWidgets('a tap on the outer popover closes the inner one only', (
    tester,
  ) async {
    final outer = PopoverController();
    final inner = PopoverController();
    addTearDown(outer.dispose);
    addTearDown(inner.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: Align(
          alignment: const Alignment(0, -.8),
          child: Popover(
            controller: outer,
            builder: (context) => SizedBox(
              width: 240,
              height: 120,
              child: Column(
                children: [
                  const Text('Outer'),
                  Popover(
                    controller: inner,
                    builder: (context) => const Text('Inner'),
                    child: const Text('Inner trigger'),
                  ),
                ],
              ),
            ),
            child: const Text('Trigger'),
          ),
        ),
      ),
    );
    outer.open();
    await settle(tester);
    inner.open();
    await settle(tester);
    expect(find.text('Inner'), findsOneWidget);

    // On the inner popover: inside both.
    await tester.tap(find.text('Inner'));
    await settle(tester);
    expect(inner.isOpen, isTrue);
    expect(outer.isOpen, isTrue);

    // On the outer one: outside the inner.
    await tester.tap(find.text('Outer'));
    await settle(tester);
    expect(inner.isOpen, isFalse);
    expect(outer.isOpen, isTrue);

    // Outside both.
    await tester.tapAt(const Offset(5, 590));
    await settle(tester);
    expect(outer.isOpen, isFalse);
  });

  testWidgets('three deep, a tap on the innermost is inside all of them', (
    tester,
  ) async {
    final controllers = [
      for (var i = 0; i < 3; i++) PopoverController(),
    ];
    for (final controller in controllers) {
      addTearDown(controller.dispose);
    }
    Widget level(int i) => Popover(
      controller: controllers[i],
      builder: (context) => SizedBox(
        width: 160,
        height: 60,
        child: Column(
          children: [
            Text('Level $i'),
            if (i < 2) level(i + 1),
          ],
        ),
      ),
      child: Text('Trigger $i'),
    );
    await tester.pumpWidget(
      FinesseApp(
        home: Align(alignment: const Alignment(0, -.9), child: level(0)),
      ),
    );
    for (final controller in controllers) {
      controller.open();
      await settle(tester);
    }
    await tester.tap(find.text('Level 2'));
    await settle(tester);
    expect([for (final c in controllers) c.isOpen], [true, true, true]);

    await tester.tap(find.text('Level 0'));
    await settle(tester);
    expect([for (final c in controllers) c.isOpen], [true, false, false]);
  });

  testWidgets('a menu in a popover closes on its own, and leaves the popover', (
    tester,
  ) async {
    final controller = PopoverController();
    addTearDown(controller.dispose);
    var pressed = 0;
    await tester.pumpWidget(
      FinesseApp(
        home: Align(
          alignment: const Alignment(0, -.8),
          child: Popover(
            controller: controller,
            builder: (context) => SizedBox(
              width: 240,
              child: DropdownMenu(
                items: [
                  MenuItem(
                    onPressed: () => pressed++,
                    child: const Text('Rename'),
                  ),
                ],
                builder: (context, menu, _) => Button.outline(
                  onPressed: menu.toggle,
                  child: const Text('More'),
                ),
              ),
            ),
            child: const Text('Trigger'),
          ),
        ),
      ),
    );
    controller.open();
    await settle(tester);
    await tester.tap(find.text('More'));
    await settle(tester);
    await tester.tap(find.text('Rename'));
    await settle(tester);
    expect(pressed, 1);
    expect(find.text('Rename'), findsNothing);
    expect(controller.isOpen, isTrue);
  });

  group('PopoverController.openAt', () {
    testWidgets('opens a popover with its corner at the point, and open() '
        'takes it back to its anchor', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(motion: Motion.none),
          home: Align(
            alignment: Alignment.topLeft,
            child: Popover(
              controller: controller,
              padding: EdgeInsets.zero,
              builder: (context) => const SizedBox(
                key: Key('content'),
                width: 100,
                height: 40,
              ),
              child: const SizedBox(width: 80, height: 30),
            ),
          ),
        ),
      );
      controller.openAt(const Offset(300, 200));
      await settle(tester);
      expect(controller.position, const Offset(300, 200));
      final at = tester.getTopLeft(find.byKey(const Key('content')));
      // Its corner, give or take the surface's hairline.
      expect(at.dx, closeTo(300, 2));
      expect(at.dy, closeTo(200, 2));

      // Moved while open.
      controller.openAt(const Offset(400, 300));
      await settle(tester);
      final moved = tester.getTopLeft(find.byKey(const Key('content')));
      expect(moved.dx, closeTo(400, 2));
      expect(moved.dy, closeTo(300, 2));

      controller.close();
      await settle(tester);
      controller.open();
      await settle(tester);
      expect(controller.position, isNull);
      // Below its child again.
      final anchored = tester.getTopLeft(find.byKey(const Key('content')));
      expect(anchored.dy, closeTo(34, 3));
      expect(anchored.dx, lessThan(100));
    });

    test('notifies when it opens and when it moves, not otherwise', () {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      var notified = 0;
      controller
        ..addListener(() => notified++)
        ..openAt(const Offset(10, 10));
      expect(notified, 1);
      controller.openAt(const Offset(10, 10));
      expect(notified, 1);
      controller.openAt(const Offset(20, 10));
      expect(notified, 2);
      controller.close();
      expect(notified, 3);
      controller.setOpen(true);
      expect(controller.position, isNull);
      expect(notified, 4);
    });
  });
}
