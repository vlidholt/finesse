import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A divider of a [ResizablePanelGroup] is a window splitter: a Tab stop
/// that the arrow keys move, Home and End take to the ends, Enter collapses
/// and restores, and assistive technology reads and adjusts.
void main() {
  Widget group(
    ResizableController controller, {
    Axis axis = Axis.horizontal,
  }) => SizedBox(
    width: 400,
    height: 400,
    child: ResizablePanelGroup(
      controller: controller,
      axis: axis,
      children: const [
        ResizablePanel(
          id: 'a',
          defaultSize: .5,
          minSize: .2,
          maxSize: .8,
          child: Text('a'),
        ),
        ResizablePanel(id: 'b', defaultSize: .5, child: Text('b')),
      ],
    ),
  );

  Future<void> focusDivider(WidgetTester tester) async {
    // The divider's own focus node, the only Tab stop in the group.
    final node = FocusManager.instance.rootScope.descendants.firstWhere(
      (node) =>
          node.canRequestFocus &&
          node.context != null &&
          find
              .ancestor(
                of: find.byElementPredicate((e) => e == node.context),
                matching: find.byType(ResizablePanelGroup),
              )
              .evaluate()
              .isNotEmpty,
    );
    node.requestFocus();
    await tester.pump();
  }

  double first(ResizableController controller) => controller.sizes.first;

  testWidgets('the arrow keys move the divider a step, mirrored in RTL', (
    tester,
  ) async {
    for (final rtl in [false, true]) {
      final controller = ResizableController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        Center(child: group(controller)),
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      );
      await focusDivider(tester);

      // Towards the end of the row grows the first panel.
      await tester.sendKeyEvent(
        rtl ? LogicalKeyboardKey.arrowLeft : LogicalKeyboardKey.arrowRight,
      );
      await tester.pump();
      expect(first(controller), closeTo(.55, 1e-6), reason: 'rtl: $rtl');
      await tester.sendKeyEvent(
        rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft,
      );
      await tester.sendKeyEvent(
        rtl ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft,
      );
      await tester.pump();
      expect(first(controller), closeTo(.45, 1e-6), reason: 'rtl: $rtl');
      // The other axis is not this divider's.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(first(controller), closeTo(.45, 1e-6), reason: 'rtl: $rtl');

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('a column moves with up and down', (tester) async {
    final controller = ResizableController();
    addTearDown(controller.dispose);
    await pumpUna(
      tester,
      Center(child: group(controller, axis: Axis.vertical)),
    );
    await focusDivider(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(first(controller), closeTo(.55, 1e-6));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(first(controller), closeTo(.5, 1e-6));
  });

  testWidgets('Home and End go to the limits; Enter collapses and restores', (
    tester,
  ) async {
    final controller = ResizableController();
    addTearDown(controller.dispose);
    await pumpUna(tester, Center(child: group(controller)));
    await focusDivider(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(first(controller), closeTo(.8, 1e-6));
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(first(controller), closeTo(.2, 1e-6));

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(first(controller), closeTo(.25, 1e-6));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(first(controller), closeTo(.2, 1e-6));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(first(controller), closeTo(.25, 1e-6));
  });

  testWidgets('assistive technology reads and adjusts the divider', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = ResizableController();
    addTearDown(controller.dispose);
    await pumpUna(tester, Center(child: group(controller)));

    final divider = find.semantics.byLabel('Resize panel');
    expect(divider, findsOne);
    var node = divider.evaluate().single;
    expect(
      node,
      containsSemantics(
        label: 'Resize panel',
        value: '50%',
        increasedValue: '55%',
        decreasedValue: '45%',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        isFocusable: true,
      ),
    );

    tester.semantics.increase(divider);
    await tester.pump();
    expect(first(controller), closeTo(.55, 1e-6));
    node = divider.evaluate().single;
    expect(node, containsSemantics(value: '55%'));
    tester.semantics.decrease(divider);
    tester.semantics.decrease(divider);
    await tester.pump();
    expect(first(controller), closeTo(.45, 1e-6));
    handle.dispose();
  });

  testWidgets('the divider takes a pointer over at least 24 points', (
    tester,
  ) async {
    final controller = ResizableController();
    addTearDown(controller.dispose);
    await pumpUna(tester, Center(child: group(controller)));
    final region = find.descendant(
      of: find.byType(ResizablePanelGroup),
      matching: find.byType(GestureDetector),
    );
    expect(tester.getSize(region.first).width, greaterThanOrEqualTo(24));

    // A drag that starts 10 points beside the line still moves it.
    final line = tester.getCenter(region.first);
    await tester.dragFrom(line + const Offset(-10, 0), const Offset(80, 0));
    await tester.pump();
    expect(first(controller), greaterThan(.6));
    // The double-tap recognizer's timer.
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a collapsed panel has no Tab stops', (tester) async {
    final controller = ResizableController();
    addTearDown(controller.dispose);
    await pumpUna(
      tester,
      Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: ResizablePanelGroup(
            controller: controller,
            children: [
              ResizablePanel(
                id: 'a',
                defaultSize: .5,
                child: Button(onPressed: () {}, child: const Text('In a')),
              ),
              const ResizablePanel(id: 'b', defaultSize: .5, child: Text('b')),
            ],
          ),
        ),
      ),
    );
    FocusNode buttonNode() => Focus.of(
      tester.element(find.text('In a', skipOffstage: false)),
    );
    expect(buttonNode().canRequestFocus, isTrue);

    controller.setSizes([0, 1]);
    await tester.pump();
    expect(buttonNode().canRequestFocus, isFalse);
  });
}
