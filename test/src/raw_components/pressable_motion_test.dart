import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// A [Pressable] acknowledges a press by itself: its content shrinks a
/// little while held and springs back, and a tap too quick to have been
/// built as a press still gets a pulse. Paint only, theme-driven, and off
/// for a disabled region.
const _frame = Duration(milliseconds: 16);

final _motion = Motion.lively.copyWith(snappy: const MotionSpring());

Widget _app(Widget child, {bool reduceMotion = false, Motion? motion}) {
  return UnaApp(
    theme: ThemeData(motion: motion ?? _motion),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
        ),
        child: Center(child: child),
      ),
    ),
  );
}

double _scale(WidgetTester tester) => tester
    .widget<Transform>(
      find
          .descendant(
            of: find.byType(Pressable),
            matching: find.byType(Transform),
          )
          .first,
    )
    .transform
    .storage[0];

Widget _pressable({
  VoidCallback? onPressed,
  double? pressScale,
  FocusNode? focusNode,
}) => Pressable(
  onPressed: onPressed,
  pressScale: pressScale,
  focusNode: focusNode,
  builder: (context, states) =>
      const SizedBox(key: Key('box'), width: 120, height: 48),
);

void main() {
  testWidgets('held, it shrinks to the theme press scale; released, it '
      'springs back — both in one movement, with layout untouched', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_pressable(onPressed: () {})));
    final rect = tester.getRect(find.byType(Pressable));
    expect(_scale(tester), 1);

    final gesture = await tester.startGesture(rect.center);
    await tester.pump();
    final down = <double>[];
    for (var i = 0; i < 30; i++) {
      down.add(_scale(tester));
      await tester.pump(_frame);
    }
    for (var i = 1; i < down.length; i++) {
      expect(down[i], lessThanOrEqualTo(down[i - 1] + 1e-9));
    }
    expect(down.last, closeTo(_motion.pressScale, 1e-4));
    // Paint only: the region and its content are where they were.
    expect(tester.getRect(find.byType(Pressable)), rect);
    expect(tester.getSize(find.byKey(const Key('box'))), const Size(120, 48));

    await gesture.up();
    await tester.pump();
    final up = <double>[];
    for (var i = 0; i < 30; i++) {
      up.add(_scale(tester));
      await tester.pump(_frame);
    }
    for (var i = 1; i < up.length; i++) {
      expect(up[i], greaterThanOrEqualTo(up[i - 1] - 1e-9));
    }
    expect(up.last, closeTo(1, 1e-6));
  });

  testWidgets('a tap that is over within a frame still pulses', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_app(_pressable(onPressed: () => taps++)));
    await tester.tap(find.byType(Pressable));
    var lowest = 1.0;
    for (var i = 0; i < 40; i++) {
      await tester.pump(_frame);
      final scale = _scale(tester);
      if (scale < lowest) lowest = scale;
    }
    expect(taps, 1);
    expect(lowest, lessThan(.995));
    expect(lowest, greaterThanOrEqualTo(_motion.pressScale - 1e-6));
    expect(_scale(tester), closeTo(1, 1e-6));
  });

  testWidgets('so does activating it from the keyboard', (tester) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    var taps = 0;
    await tester.pumpWidget(
      _app(_pressable(onPressed: () => taps++, focusNode: focusNode)),
    );
    focusNode.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    var lowest = 1.0;
    for (var i = 0; i < 40; i++) {
      await tester.pump(_frame);
      final scale = _scale(tester);
      if (scale < lowest) lowest = scale;
    }
    expect(taps, 1);
    expect(lowest, lessThan(.995));
  });

  testWidgets('pressScale sets the amount, and 1 switches it off', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_pressable(onPressed: () {}, pressScale: .9)),
    );
    var gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(_scale(tester), closeTo(.9, 1e-4));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.pumpWidget(_app(_pressable(onPressed: () {}, pressScale: 1)));
    gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(_frame);
      expect(_scale(tester), 1);
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('a disabled region does not respond', (tester) async {
    await tester.pumpWidget(_app(_pressable()));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Pressable)),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(_frame);
      expect(_scale(tester), 1);
    }
    await gesture.up();
    await tester.pump(_frame);
    expect(_scale(tester), 1);
  });

  testWidgets('with reduced motion, and with no motion, nothing moves', (
    tester,
  ) async {
    for (final app in [
      _app(_pressable(onPressed: () {}), reduceMotion: true),
      _app(_pressable(onPressed: () {}), motion: Motion.none),
    ]) {
      await tester.pumpWidget(app);
      // A change of theme is itself a 200 ms animation.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byType(Pressable));
      for (var i = 0; i < 12; i++) {
        await tester.pump(_frame);
        expect(_scale(tester), 1);
      }
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(_scale(tester), 1);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
    }
  });

  testWidgets('a card and a list tile give as surfaces do, and pulse on a '
      'quick tap', (tester) async {
    await tester.pumpWidget(
      _app(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              onTap: () {},
              child: const SizedBox(width: 200, height: 80),
            ),
            SizedBox(
              width: 200,
              child: ListTile(title: const Text('Row'), onTap: () {}),
            ),
          ],
        ),
      ),
    );
    for (final type in [Card, ListTile]) {
      double scale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.descendant(
                    of: find.byType(type),
                    matching: find.byType(Pressable),
                  ),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .storage[0];
      await tester.tap(find.byType(type));
      var lowest = 1.0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        if (scale() < lowest) lowest = scale();
      }
      // A pulse, and no deeper than a surface gives.
      expect(lowest, lessThan(1), reason: '$type');
      expect(
        lowest,
        greaterThanOrEqualTo(_motion.surfacePressScale - 1e-6),
        reason: '$type',
      );
      expect(scale(), closeTo(1, 1e-6));
    }
  });
}
