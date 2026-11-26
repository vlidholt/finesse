import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A tooltip listens for what shows it itself: a mouse over its child, and
/// a long press with a finger or a pen. The child is not re-themed to carry
/// a callback down, so it can be any widget and costs no theme of its own.
void main() {
  Future<void> play(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('the child of a tooltip sees the ambient theme itself', (
    tester,
  ) async {
    late ThemeData outside;
    late ThemeData inside;
    await tester.pumpWidget(
      UnaApp(
        home: Builder(
          builder: (context) {
            outside = Theme.of(context);
            return Center(
              child: Tooltip(
                builder: (context) => const Text('Tip'),
                child: Builder(
                  builder: (context) {
                    inside = Theme.of(context);
                    return const Text('Trigger');
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
    // Not a copy: a copy is a run of the theme factory per tooltip, and a
    // `Theme` whose dependents compare every component theme.
    expect(inside, same(outside));
    expect(
      find.descendant(
        of: find.byType(Tooltip),
        matching: find.byType(Theme),
      ),
      findsNothing,
    );
  });

  testWidgets('a long press with a finger shows it for as long as it is '
      'held, whatever the child is', (tester) async {
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: Tooltip(
            builder: (context) => const Text('Tip'),
            // Nothing that listens for gestures.
            child: const Text('Trigger'),
          ),
        ),
      ),
    );
    final finger = await tester.startGesture(
      tester.getCenter(find.text('Trigger')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tip'), findsNothing);
    await tester.pump(kLongPressTimeout);
    await play(tester);
    expect(find.text('Tip'), findsOneWidget);

    await finger.up();
    await play(tester);
    expect(find.text('Tip'), findsNothing);
  });

  testWidgets('a tap presses the button and shows nothing', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: Tooltip(
            builder: (context) => const Text('Tip'),
            child: Button(
              onPressed: () => pressed++,
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Go'));
    await play(tester);
    expect(pressed, 1);
    expect(find.text('Tip'), findsNothing);
  });

  testWidgets('held on a button, the long press shows the tooltip and the '
      'button is not pressed', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: Tooltip(
            builder: (context) => const Text('Tip'),
            child: Button(
              onPressed: () => pressed++,
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    );
    final finger = await tester.startGesture(
      tester.getCenter(find.text('Go')),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await play(tester);
    expect(find.text('Tip'), findsOneWidget);
    await finger.up();
    await play(tester);
    expect(pressed, 0);
    expect(find.text('Tip'), findsNothing);
  });

  testWidgets('a mouse held down is not a long press', (tester) async {
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: Tooltip(
            // Long after the press would have counted.
            waitDuration: const Duration(seconds: 5),
            builder: (context) => const Text('Tip'),
            child: const Text('Trigger'),
          ),
        ),
      ),
    );
    final mouse = await tester.startGesture(
      tester.getCenter(find.text('Trigger')),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await play(tester);
    expect(find.text('Tip'), findsNothing);
    await mouse.up();
    await mouse.removePointer();
    await tester.pump(const Duration(seconds: 6));
    await play(tester);
  });

  testWidgets('longPressDuration says how long the press has to be', (
    tester,
  ) async {
    await tester.pumpWidget(
      UnaApp(
        home: Center(
          child: Tooltip(
            longPressDuration: const Duration(milliseconds: 100),
            builder: (context) => const Text('Tip'),
            child: const Text('Trigger'),
          ),
        ),
      ),
    );
    final finger = await tester.startGesture(
      tester.getCenter(find.text('Trigger')),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await play(tester);
    expect(find.text('Tip'), findsOneWidget);
    await finger.up();
    await play(tester);
  });
}
