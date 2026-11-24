import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';

void main() {
  testWidgets(
    'toggling enabled with a shared states controller does not notify '
    'listeners during build',
    (tester) async {
      final controller = WidgetStatesController();
      addTearDown(controller.dispose);
      var enabled = true;
      late StateSetter setOuter;

      await tester.pumpWidget(
        FinesseApp(
          home: Column(
            children: [
              // A listener on the same controller outside the subtree that
              // rebuilds, as a context menu item's trailing icon can be. A
              // notification from the button's didUpdateWidget marks it dirty
              // from outside its own build.
              ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, states, _) => Text(
                  states.contains(WidgetState.disabled) ? 'off' : 'on',
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  setOuter = setState;
                  return Button(
                    enabled: enabled,
                    statesController: controller,
                    onPressed: () {},
                    child: const Text('button'),
                  );
                },
              ),
            ],
          ),
        ),
      );

      setOuter(() => enabled = false);
      await tester.pump();
      expect(tester.takeException(), isNull);
      // The listener catches up on the next frame.
      await tester.pump();
      expect(find.text('off'), findsOneWidget);

      setOuter(() => enabled = true);
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('on'), findsOneWidget);
    },
  );

  testWidgets('an external WidgetStatesController follows hover, press, focus '
      'and disabled, and its listeners are told of each', (tester) async {
    final controller = WidgetStatesController();
    addTearDown(controller.dispose);
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    // WidgetStatesController changes its set in place, so a listener that
    // wants to know what flipped keeps its own copy of what it last saw.
    var seen = <WidgetState>{...controller.value};
    final changes = <String>[];
    controller.addListener(() {
      final now = controller.value;
      for (final state in now.difference(seen)) {
        changes.add('+${state.name}');
      }
      for (final state in seen.difference(now)) {
        changes.add('-${state.name}');
      }
      seen = {...now};
    });

    var enabled = true;
    late StateSetter setOuter;
    await tester.pumpWidget(
      FinesseApp(
        home: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return Button(
                enabled: enabled,
                statesController: controller,
                focusNode: focusNode,
                onPressed: () {},
                child: const Text('button'),
              );
            },
          ),
        ),
      ),
    );
    expect(controller.value, isEmpty);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.text('button')));
    await tester.pump();
    expect(controller.value, {WidgetState.hovered});

    await gesture.down(tester.getCenter(find.text('button')));
    await tester.pump();
    expect(controller.value, {WidgetState.hovered, WidgetState.pressed});
    await gesture.up();
    await tester.pump();
    expect(controller.value, {WidgetState.hovered});

    await gesture.moveTo(Offset.zero);
    await tester.pump();
    expect(controller.value, isEmpty);

    focusNode.requestFocus();
    await tester.pump();
    expect(controller.value, {WidgetState.focused});
    focusNode.unfocus();
    await tester.pump();
    expect(controller.value, isEmpty);

    setOuter(() => enabled = false);
    await tester.pump();
    await tester.pump();
    expect(controller.value, {WidgetState.disabled});

    expect(changes, [
      '+hovered',
      '+pressed',
      '-pressed',
      '-hovered',
      '+focused',
      '-focused',
      '+disabled',
    ]);
  });

  testWidgets('the button restyles when its controller changes in place', (
    tester,
  ) async {
    // WidgetStatesController.update mutates the set it already holds; the
    // button must not depend on being handed a different one.
    final controller = WidgetStatesController();
    addTearDown(controller.dispose);
    const rest = Color(0xff102030);
    const hover = Color(0xff405060);

    await tester.pumpWidget(
      FinesseApp(
        home: Center(
          child: Button(
            statesController: controller,
            backgroundColor: rest,
            hoverBackgroundColor: hover,
            onPressed: () {},
            child: const Text('button'),
          ),
        ),
      ),
    );

    bool painted(Color color) => tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(Button),
            matching: find.byType(DecoratedBox),
          ),
        )
        .any((box) => boxDecorationOf(box.decoration)?.color == color);

    expect(painted(rest), isTrue);
    expect(painted(hover), isFalse);

    final before = controller.value;
    controller.update(WidgetState.hovered, true);
    expect(identical(controller.value, before), isTrue);
    await tester.pump();
    expect(painted(hover), isTrue);
    expect(painted(rest), isFalse);

    controller.update(WidgetState.hovered, false);
    await tester.pump();
    expect(painted(rest), isTrue);
  });
}
