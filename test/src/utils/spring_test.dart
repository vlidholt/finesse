import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _frame = Duration(milliseconds: 16);

Widget _app(Widget child, {bool reduceMotion = false, Motion? motion}) {
  return FinesseApp(
    theme: motion == null ? null : ThemeData(motion: motion),
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

void main() {
  group('SpringBuilder', () {
    Future<List<double>> run(
      WidgetTester tester, {
      MotionSpring? spring,
      bool reduceMotion = false,
      int frames = 60,
    }) async {
      final values = <double>[];
      Widget build(double value) => _app(
        SpringBuilder(
          value: value,
          spring: spring,
          builder: (context, v, child) {
            values.add(v);
            return const SizedBox(width: 10, height: 10);
          },
        ),
        reduceMotion: reduceMotion,
      );
      await tester.pumpWidget(build(0));
      await tester.pump(const Duration(milliseconds: 300));
      values.clear();
      await tester.pumpWidget(build(1));
      for (var i = 0; i < frames; i++) {
        await tester.pump(_frame);
      }
      return values;
    }

    testWidgets('starts on its value without animating', (tester) async {
      final values = <double>[];
      await tester.pumpWidget(
        _app(
          SpringBuilder(
            value: 1,
            builder: (context, v, child) {
              values.add(v);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(values, everyElement(1));
    });

    testWidgets('travels monotonically to its target and stops there', (
      tester,
    ) async {
      final values = await run(
        tester,
        spring: const MotionSpring(),
      );
      expect(values.first, lessThan(.2));
      expect(values.last, 1);
      for (var i = 1; i < values.length; i++) {
        expect(
          values[i],
          greaterThanOrEqualTo(values[i - 1]),
          reason: 'frame $i went backwards: $values',
        );
      }
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a bouncy spring overshoots and still settles', (
      tester,
    ) async {
      final values = await run(
        tester,
        spring: const MotionSpring(bounce: .3),
      );
      expect(values.reduce((a, b) => a > b ? a : b), greaterThan(1));
      expect(values.last, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('an interruption turns around without a jump', (tester) async {
      final values = <double>[];
      Widget build(double value) => _app(
        SpringBuilder(
          value: value,
          spring: const MotionSpring(),
          builder: (context, v, child) {
            values.add(v);
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(build(0));
      await tester.pumpWidget(build(1));
      for (var i = 0; i < 5; i++) {
        await tester.pump(_frame);
      }
      final atInterruption = values.last;
      expect(atInterruption, inExclusiveRange(.1, .9));
      values.clear();
      await tester.pumpWidget(build(0));
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
      }
      // No frame moves further than the fastest frame of an uninterrupted
      // run could: the value never teleports.
      var previous = atInterruption;
      for (final v in values) {
        expect((v - previous).abs(), lessThan(.25), reason: '$values');
        previous = v;
      }
      // It keeps the velocity it had: the first frame after the turn still
      // moves up before the spring pulls it back.
      expect(values[1], greaterThan(atInterruption));
      expect(values.last, 0);
    });

    testWidgets('jumps when motion is reduced', (tester) async {
      final values = await run(tester, reduceMotion: true, frames: 2);
      expect(values, everyElement(1));
    });

    testWidgets('jumps when the theme has no motion', (tester) async {
      final values = <double>[];
      Widget build(double value) => _app(
        SpringBuilder(
          value: value,
          builder: (context, v, child) {
            values.add(v);
            return const SizedBox();
          },
        ),
        motion: Motion.none,
      );
      await tester.pumpWidget(build(0));
      await tester.pump(const Duration(milliseconds: 300));
      values.clear();
      await tester.pumpWidget(build(1));
      await tester.pump(_frame);
      expect(values, everyElement(1));
      await tester.pumpAndSettle();
    });
  });

  group('PressScale', () {
    double scaleOf(WidgetTester tester) {
      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(PressScale),
          matching: find.byType(Transform),
        ),
      );
      return transform.transform.storage[0];
    }

    Widget build({required bool pressed, bool reduceMotion = false}) => _app(
      PressScale(
        pressed: pressed,
        spring: const MotionSpring(),
        scale: .9,
        child: const SizedBox(width: 100, height: 40),
      ),
      reduceMotion: reduceMotion,
    );

    testWidgets('scales down while pressed and back on release, without '
        'touching layout', (tester) async {
      await tester.pumpWidget(build(pressed: false));
      expect(scaleOf(tester), 1);
      final size = tester.getSize(find.byType(PressScale));

      await tester.pumpWidget(build(pressed: true));
      var previous = 1.0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        final scale = scaleOf(tester);
        expect(scale, lessThanOrEqualTo(previous + 1e-9));
        previous = scale;
        expect(tester.getSize(find.byType(PressScale)), size);
      }
      expect(previous, closeTo(.9, 1e-6));

      await tester.pumpWidget(build(pressed: false));
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        final scale = scaleOf(tester);
        expect(scale, greaterThanOrEqualTo(previous - 1e-9));
        previous = scale;
      }
      expect(previous, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('does nothing with reduced motion', (tester) async {
      await tester.pumpWidget(build(pressed: false, reduceMotion: true));
      await tester.pumpWidget(
        _app(
          const PressScale(
            pressed: true,
            child: SizedBox(width: 100, height: 40),
          ),
          reduceMotion: true,
        ),
      );
      await tester.pump(_frame);
      expect(scaleOf(tester), 1);
    });
  });

  group('Entrance', () {
    double opacityOf(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find.descendant(
            of: find.byType(Entrance),
            matching: find.byType(FadeTransition),
          ),
        )
        .opacity
        .value;

    testWidgets('fades and grows in on first build, monotonically', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const Entrance(child: SizedBox(width: 100, height: 40))),
      );
      expect(opacityOf(tester), 0);
      var previous = 0.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        final opacity = opacityOf(tester);
        expect(opacity, greaterThanOrEqualTo(previous));
        previous = opacity;
      }
      expect(previous, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('with appear false it is simply there', (tester) async {
      await tester.pumpWidget(
        _app(
          const Entrance(
            appear: false,
            child: SizedBox(width: 100, height: 40),
          ),
        ),
      );
      expect(opacityOf(tester), 1);
      await tester.pumpAndSettle();
      expect(opacityOf(tester), 1);
    });

    testWidgets('leaves when hidden, reports it, and ignores pointers', (
      tester,
    ) async {
      var hidden = 0;
      Widget build({required bool visible}) => _app(
        Entrance(
          visible: visible,
          appear: false,
          onHidden: () => hidden++,
          child: const SizedBox(width: 100, height: 40),
        ),
      );
      await tester.pumpWidget(build(visible: true));
      await tester.pumpWidget(build(visible: false));
      expect(
        tester
            .widget<IgnorePointer>(
              find.descendant(
                of: find.byType(Entrance),
                matching: find.byType(IgnorePointer),
              ),
            )
            .ignoring,
        isTrue,
      );
      var previous = 1.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        final opacity = opacityOf(tester);
        expect(opacity, lessThanOrEqualTo(previous));
        previous = opacity;
      }
      expect(previous, 0);
      expect(hidden, 1);
    });

    testWidgets('grows from the MotionOrigin above it', (tester) async {
      await tester.pumpWidget(
        _app(
          const MotionOrigin(
            alignment: Alignment.topLeft,
            child: Entrance(child: SizedBox(width: 100, height: 40)),
          ),
        ),
      );
      await tester.pump(_frame);
      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(Entrance),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.alignment, Alignment.topLeft);
      // Pulled towards the origin: up and to the left.
      final translation = transform.transform.getTranslation();
      expect(translation.x, lessThan(0));
      expect(translation.y, lessThan(0));
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion leaves a plain fade', (tester) async {
      await tester.pumpWidget(
        _app(
          const Entrance(child: SizedBox(width: 100, height: 40)),
          reduceMotion: true,
        ),
      );
      await tester.pump(_frame);
      final transform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(Entrance),
          matching: find.byType(Transform),
        ),
      );
      expect(transform.transform, Matrix4.identity());
      expect(opacityOf(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(opacityOf(tester), 1);
    });
  });

  group('EntranceEffect', () {
    test('forMotion returns the identical list for equal tokens', () {
      final a = EntranceEffect.forMotion(Motion.lively);
      final b = EntranceEffect.forMotion(Motion.lively.copyWith());
      expect(identical(a, b), isTrue);
      expect(
        identical(a, EntranceEffect.forMotion(Motion.calm)),
        isFalse,
      );
      expect(a.single.duration, Motion.lively.snappy.settleDuration);
    });

    testWidgets('plays in an Animate, grows from the origin', (tester) async {
      await tester.pumpWidget(
        _app(
          MotionOrigin(
            alignment: Alignment.bottomCenter,
            child: Animate(
              effects: EntranceEffect.forMotion(Motion.lively),
              child: const SizedBox(width: 100, height: 40),
            ),
          ),
        ),
      );
      await tester.pump(_frame);
      await tester.pump(_frame);
      final entrance = find.descendant(
        of: find.byType(MotionOrigin),
        matching: find.byType(Transform),
      );
      final transform = tester.widget<Transform>(entrance);
      expect(transform.alignment, Alignment.bottomCenter);
      expect(transform.transform.storage[0], lessThan(1));
      // Pulled down, towards the origin.
      expect(transform.transform.getTranslation().y, greaterThan(0));
      await tester.pumpAndSettle();
      expect(tester.widget<Transform>(entrance).transform, Matrix4.identity());
    });
  });
}
