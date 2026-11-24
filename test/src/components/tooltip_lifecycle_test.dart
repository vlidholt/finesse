import 'dart:ui' show PointerDeviceKind;

import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(1, 1));
  addTearDown(gesture.removePointer);
  return gesture;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
  await tester.pump();
}

/// Onto the trigger and off again before the tooltip's second frame.
Future<void> _brush(WidgetTester tester, TestGesture mouse, Offset at) async {
  await mouse.moveTo(at);
  await mouse.moveTo(const Offset(1, 1));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
  await tester.pump(const Duration(milliseconds: 16));
  // Long after the pointer left.
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
}

double _opacity(WidgetTester tester, Finder content) {
  var opacity = 1.0;
  RenderObject? node = tester.renderObject(content);
  while (node != null) {
    if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
    if (node is RenderOpacity) opacity *= node.opacity;
    node = node.parent;
  }
  return opacity;
}

Widget _app(
  FocusNode focus, {
  ThemeData? theme,
  List<Effect<dynamic>>? effects,
  Duration? reverseDuration,
}) => FinesseApp(
  theme: theme ?? ThemeData(style: StyleTokens.nova),
  home: Center(
    child: Tooltip(
      focusNode: focus,
      effects: effects,
      reverseDuration: reverseDuration,
      builder: (context) => const Text('Tip'),
      child: Button(
        focusNode: focus,
        onPressed: () {},
        child: const Text('Trigger'),
      ),
    ),
  ),
);

void main() {
  // A tooltip closes through an awaited exit animation. Closed any other
  // way — focus lost, Escape — its controller used to stay at 1, so the
  // next exit was a real animation; started before the overlay was built,
  // it was cancelled by the entrance, and a cancelled ticker future never
  // completes: nothing was left to close the tooltip.
  group('a tooltip does not outstay the pointer', () {
    testWidgets('after an ordinary exit, a brush leaves nothing behind', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_app(focus));
      final mouse = await _mouse(tester);
      final trigger = tester.getCenter(find.text('Trigger'));

      await mouse.moveTo(trigger);
      await _settle(tester);
      expect(find.text('Tip'), findsOneWidget);
      await mouse.moveTo(const Offset(1, 1));
      await _settle(tester);
      expect(find.text('Tip'), findsNothing);

      await _brush(tester, mouse, trigger);
      expect(find.text('Tip'), findsNothing);
    });

    testWidgets('shown by focus and hidden by losing it, then brushed', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_app(focus));
      final mouse = await _mouse(tester);
      final trigger = tester.getCenter(find.text('Trigger'));

      focus.requestFocus();
      await _settle(tester);
      expect(find.text('Tip'), findsOneWidget);
      focus.unfocus();
      await _settle(tester);
      expect(find.text('Tip'), findsNothing);

      await _brush(tester, mouse, trigger);
      expect(focus.hasFocus, isFalse);
      expect(find.text('Tip'), findsNothing);
    });

    testWidgets('dismissed with Escape, then brushed', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(_app(focus));
      final mouse = await _mouse(tester);
      final trigger = tester.getCenter(find.text('Trigger'));

      await mouse.moveTo(trigger);
      await _settle(tester);
      expect(find.text('Tip'), findsOneWidget);

      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.text('Tip'), findsNothing);
      focus.unfocus();
      await mouse.moveTo(const Offset(1, 1));
      await _settle(tester);
      expect(find.text('Tip'), findsNothing);

      await _brush(tester, mouse, trigger);
      expect(find.text('Tip'), findsNothing);
    });

    testWidgets('after a close with no exit, the next showing plays its '
        'entrance from the start', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _app(
          focus,
          effects: const [
            FadeEffect(duration: Duration(seconds: 1), curve: Curves.linear),
          ],
        ),
      );
      focus.requestFocus();
      await _settle(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(_opacity(tester, find.text('Tip')), 1);
      focus.unfocus();
      await _settle(tester);
      expect(find.text('Tip'), findsNothing);

      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Trigger')));
      await tester.pump();
      await tester.pump();
      // The frame the overlay is first painted on: not yet in.
      expect(_opacity(tester, find.text('Tip')), lessThan(.1));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('an exit cut short by something other than the pointer '
        'still closes it', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      const slow = [
        FadeEffect(duration: Duration(seconds: 1), curve: Curves.linear),
      ];
      const slower = [
        FadeEffect(duration: Duration(seconds: 2), curve: Curves.linear),
      ];
      const leave = Duration(milliseconds: 400);
      await tester.pumpWidget(
        _app(focus, effects: slow, reverseDuration: leave),
      );
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Trigger')));
      await _settle(tester);
      await tester.pump(const Duration(seconds: 2));
      expect(_opacity(tester, find.text('Tip')), 1);

      await mouse.moveTo(const Offset(1, 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // Effects of another length restart the animate widget, which takes
      // the controller away from the exit.
      await tester.pumpWidget(
        _app(focus, effects: slower, reverseDuration: leave),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('Tip'), findsNothing);
    });
  });

  // `Tooltip.duration` and `TooltipTheme.duration` were written to the
  // controller and overwritten by the animate widget; they are gone. The
  // entrance is as long as its effects, the exit is `reverseDuration`.
  group('the length of a tooltip’s animations', () {
    testWidgets('the entrance takes the duration of its effects', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _app(
          focus,
          effects: const [
            FadeEffect(duration: Duration(seconds: 2), curve: Curves.linear),
          ],
        ),
      );
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Trigger')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(_opacity(tester, find.text('Tip')), closeTo(.3, .05));
      await tester.pump(const Duration(seconds: 3));
      expect(_opacity(tester, find.text('Tip')), 1);
    });

    testWidgets('the exit takes reverseDuration, from the widget or the '
        'theme', (tester) async {
      for (final fromTheme in [false, true]) {
        final focus = FocusNode();
        addTearDown(focus.dispose);
        const leave = Duration(seconds: 1);
        final base = ThemeData(style: StyleTokens.nova);
        await tester.pumpWidget(
          _app(
            focus,
            theme: fromTheme
                ? base.copyWith(
                    tooltipTheme: const TooltipTheme(reverseDuration: leave),
                  )
                : base,
            effects: const [
              FadeEffect(
                duration: Duration(milliseconds: 100),
                curve: Curves.linear,
              ),
            ],
            reverseDuration: fromTheme ? null : leave,
          ),
        );
        final mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: const Offset(1, 1));
        await mouse.moveTo(tester.getCenter(find.text('Trigger')));
        await _settle(tester);
        await tester.pump(const Duration(seconds: 1));
        expect(_opacity(tester, find.text('Tip')), 1);

        await mouse.moveTo(const Offset(1, 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          _opacity(tester, find.text('Tip')),
          closeTo(.5, .05),
          reason: fromTheme ? 'from the theme' : 'from the widget',
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(find.text('Tip'), findsNothing);
        await mouse.removePointer();
        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}
