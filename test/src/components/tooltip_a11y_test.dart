import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(1, 1));
  addTearDown(gesture.removePointer);
  return gesture;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Widget _page({String? semanticMessage}) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Button(onPressed: () {}, child: const Text('Elsewhere')),
      const SizedBox(height: 80),
      Tooltip(
        semanticMessage: semanticMessage,
        // A long message, so the bubble is wide enough to point at.
        builder: (context) => const Text('A tip that is wide enough'),
        child: Button(onPressed: () {}, child: const Text('Trigger')),
      ),
    ],
  ),
);

void main() {
  testWidgets('the keyboard focus on the child shows it, with no focus node '
      'given', (tester) async {
    await pumpUna(tester, _page());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(find.text('A tip that is wide enough'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(find.text('A tip that is wide enough'), findsOneWidget);

    // Shift+Tab back: it leaves.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await _settle(tester);
    expect(find.text('A tip that is wide enough'), findsNothing);
  });

  testWidgets('a tap that focuses the child does not pin it open', (
    tester,
  ) async {
    await pumpUna(tester, _page());
    await tester.tap(find.text('Trigger'));
    await _settle(tester);
    expect(find.text('A tip that is wide enough'), findsNothing);
  });

  testWidgets('the pointer can move onto the bubble without closing it', (
    tester,
  ) async {
    await pumpUna(tester, _page());
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Trigger')));
    await _settle(tester);
    final bubble = find.text('A tip that is wide enough');
    expect(bubble, findsOneWidget);

    // Off the trigger, across the gap and onto the bubble.
    await mouse.moveTo(tester.getCenter(bubble));
    await _settle(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(bubble, findsOneWidget);

    // Off both: it goes.
    await mouse.moveTo(const Offset(1, 1));
    await _settle(tester);
    expect(bubble, findsNothing);
  });

  testWidgets('Escape closes a tooltip the pointer shows, with the focus '
      'somewhere else', (tester) async {
    await pumpUna(tester, _page());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(
      Focus.of(tester.element(find.text('Elsewhere'))).hasFocus,
      isTrue,
    );
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Trigger')));
    await _settle(tester);
    expect(find.text('A tip that is wide enough'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.text('A tip that is wide enough'), findsNothing);
  });

  testWidgets('Escape with no tooltip showing is left to others', (
    tester,
  ) async {
    await pumpUna(tester, _page());
    final result = await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(result, isFalse);
  });

  testWidgets('semanticMessage reaches the child as its tooltip', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, _page(semanticMessage: 'A tip'));
    expect(
      tester.getSemantics(find.text('Trigger')),
      isSemantics(label: 'Trigger', tooltip: 'A tip', isButton: true),
    );
    handle.dispose();
  });
}
