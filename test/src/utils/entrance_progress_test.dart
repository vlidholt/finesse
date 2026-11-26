import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/utils/entrance.dart';
import 'package:una/una.dart';

/// [EntranceProgress] is the timing under every overlay entrance and the
/// page route: a curve on the way in, a straight line on the way out, and
/// no jump when the direction changes part-way.
void main() {
  const curve = MotionSpringCurve(MotionSpring());

  AnimationController controllerOf(WidgetTester tester) {
    final controller = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 120),
    );
    addTearDown(controller.dispose);
    return controller;
  }

  testWidgets('forward it is the curve', (tester) async {
    final controller = controllerOf(tester);
    final progress = EntranceProgress(controller, curve: curve);
    expect(progress.value, 0);
    for (final t in [.1, .25, .5, .75]) {
      controller.forward(from: t);
      expect(progress.value, closeTo(curve.transform(t), 1e-9));
    }
    controller.value = 1;
    expect(progress.value, 1);
  });

  testWidgets('back from the end it is a straight line in time', (
    tester,
  ) async {
    final controller = controllerOf(tester)..value = 1;
    final progress = EntranceProgress(controller, curve: curve);
    expect(progress.value, 1);
    controller.reverse();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    expect(progress.value, closeTo(.75, 1e-6));
    await tester.pump(const Duration(milliseconds: 30));
    expect(progress.value, closeTo(.5, 1e-6));
    // Played backwards, the curve would still be all but in place here.
    expect(curve.transform(.5), greaterThan(.85));
    await tester.pump(const Duration(milliseconds: 60));
    expect(progress.value, 0);
    controller.stop();
  });

  testWidgets('turned around mid-flight, either way, it carries on from '
      'where it is', (tester) async {
    final controller = controllerOf(tester);
    final progress = EntranceProgress(controller, curve: curve);
    final values = <double>[];
    controller.forward();
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      values.add(progress.value);
    }
    final top = values.last;
    controller.reverse();
    for (var i = 0; i < 2; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      values.add(progress.value);
    }
    final bottom = values.last;
    expect(bottom, lessThan(top));
    controller.forward();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      values.add(progress.value);
    }
    expect(values.last, 1);
    // No frame anywhere moves more than a fraction of the range.
    for (var i = 1; i < values.length; i++) {
      expect(
        (values[i] - values[i - 1]).abs(),
        lessThan(.3),
        reason: 'frame $i of $values',
      );
    }
    // After the last turn it only rises.
    final rising = values.sublist(8);
    for (var i = 1; i < rising.length; i++) {
      expect(rising[i], greaterThanOrEqualTo(rising[i - 1] - 1e-9));
    }
  });

  testWidgets('a rebuilt progress shares the turning point of the one it '
      'replaces', (tester) async {
    final controller = controllerOf(tester)..value = 1;
    final first = EntranceProgress(controller, curve: curve);
    expect(first.value, 1);
    controller.reverse();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final seen = first.value;
    // What a widget rebuilding mid-exit creates.
    final second = EntranceProgress(controller, curve: curve);
    expect(second.value, seen);
    await tester.pump(const Duration(milliseconds: 30));
    expect(second.value, closeTo(.25, 1e-6));
    controller.stop();
  });

  testWidgets('plays over its part of the range', (tester) async {
    final controller = controllerOf(tester);
    final progress = EntranceProgress(
      controller,
      curve: Curves.linear,
      begin: .5,
    );
    controller.forward(from: .25);
    expect(progress.value, 0);
    controller.forward(from: .75);
    expect(progress.value, closeTo(.5, 1e-9));
    controller.stop();
  });

  test('the entrance for no motion is instant', () {
    expect(EntranceSpec.of(Motion.none).isInstant, isTrue);
    expect(EntranceSpec.fade(Motion.none).isInstant, isTrue);
    // Reduced motion leaves a short fade with nothing else in it.
    final reduced = EntranceSpec.of(Motion.lively.reduce());
    expect(reduced.duration, Motion.lively.fast);
    expect(reduced.scale, 1);
    expect(reduced.travel, 0);
    // And equal tokens give the equal values a theme needs.
    expect(
      EntranceSpec.fade(Motion.lively),
      EntranceSpec.fade(Motion.lively.copyWith()),
    );
  });
}
