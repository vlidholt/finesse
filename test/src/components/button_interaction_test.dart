import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';

void main() {
  Widget wrap(Widget child) => FinesseApp(home: Center(child: child));

  group('hover is retained across a click', () {
    testWidgets('a mouse click does not clear the hover state', (tester) async {
      // Regression: on a device with no hover a press stands in for it and
      // a tap-up ends it. That fired for mouse clicks too, so the highlight
      // vanished mid-click even though the cursor had not moved.
      final changes = <bool>[];
      await tester.pumpWidget(
        wrap(
          Button(
            onPressed: () {},
            onHover: changes.add,
            child: const Text('Click me'),
          ),
        ),
      );

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.byType(Button)));
      await tester.pumpAndSettle();
      expect(changes, [true]);

      // Click without moving the pointer.
      await gesture.down(tester.getCenter(find.byType(Button)));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        changes,
        [true],
        reason: 'the pointer never left, so hover must still be true',
      );

      await gesture.moveTo(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(changes, [true, false]);
    });

    testWidgets('a finger held on the button shows what a pointer over it '
        'shows, and onHover is for the mouse', (tester) async {
      // A touch screen has no hover: the press is what answers the finger.
      const rest = Color(0xff102030);
      const hover = Color(0xffa0b0c0);
      final changes = <bool>[];
      await tester.pumpWidget(
        wrap(
          Button(
            style: const ButtonTheme(
              backgroundColor: rest,
              hoverBackgroundColor: hover,
            ),
            onPressed: () {},
            onHover: changes.add,
            child: const Text('Tap me'),
          ),
        ),
      );
      Color? fill() => tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(Button),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => boxDecorationOf(box.decoration)?.color)
          .nonNulls
          .first;
      expect(fill(), rest);

      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(fill(), hover);

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(fill(), rest);
      expect(changes, isEmpty);
      await tester.pumpAndSettle();
    });
  });

  group('press effect', () {
    // The press moves the button in paint, so the label's centre — which a
    // press scale around the button's centre leaves alone — shows it. The
    // shift is inside that scale, so it reads a few hundredths short.
    Offset Function() shiftOf(WidgetTester tester) {
      final rest = tester.getCenter(find.text('Press'));
      return () => tester.getCenter(find.text('Press')) - rest;
    }

    testWidgets('the button shifts down a pixel while pressed', (
      tester,
    ) async {
      // shadcn/ui applies `active:translate-y-px`.
      await tester.pumpWidget(
        wrap(Button(onPressed: () {}, child: const Text('Press'))),
      );
      final shift = shiftOf(tester);

      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(shift().dx, 0);
      expect(shift().dy, closeTo(1, .05));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(shift(), Offset.zero);
    });

    testWidgets('pressedOffset is in logical pixels, on both axes', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          Button(
            onPressed: () {},
            style: const ButtonTheme(
              pressedOffset: Offset(3, 2),
              pressScale: 1,
            ),
            child: const Text('Press'),
          ),
        ),
      );
      final shift = shiftOf(tester);
      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(shift().dx, moreOrLessEquals(3));
      expect(shift().dy, moreOrLessEquals(2));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('pressedOffset can be switched off', (tester) async {
      await tester.pumpWidget(
        wrap(
          Button(
            onPressed: () {},
            style: const ButtonTheme(pressedOffset: Offset.zero),
            child: const Text('Press'),
          ),
        ),
      );
      final shift = shiftOf(tester);
      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(shift(), Offset.zero);
      await gesture.up();
    });

    testWidgets('a button with a height of 0 shifts by the same pixel', (
      tester,
    ) async {
      // A height of 0 sizes the button to its content; the shift was a
      // fraction of the height, and so infinite.
      await tester.pumpWidget(
        wrap(
          Button(
            style: const ButtonTheme(height: 0),
            onPressed: () {},
            child: const Text('Press'),
          ),
        ),
      );
      final shift = shiftOf(tester);
      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      expect(shift().dy, closeTo(1, .05));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a disabled button does not shift', (tester) async {
      await tester.pumpWidget(
        wrap(
          Button(
            enabled: false,
            onPressed: () {},
            child: const Text('Press'),
          ),
        ),
      );
      final shift = shiftOf(tester);
      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(shift(), Offset.zero);
      await gesture.up();
    });

    testWidgets('a button with only a long press does not shift', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(Button(onLongPress: () {}, child: const Text('Press'))),
      );
      final shift = shiftOf(tester);
      final gesture = await tester.press(find.byType(Button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(shift(), Offset.zero);
      await gesture.up();
    });
  });
}
