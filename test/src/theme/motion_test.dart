import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MotionSpring', () {
    test('compares by value', () {
      expect(
        const MotionSpring(duration: Duration(milliseconds: 300), bounce: .2),
        // Not const on purpose: two instances, one value.
        // ignore: prefer_const_constructors
        MotionSpring(duration: Duration(milliseconds: 300), bounce: .2),
      );
      expect(
        const MotionSpring(),
        isNot(const MotionSpring(bounce: .1)),
      );
    });

    test('reads as finished at its perceptual duration', () {
      const spring = MotionSpring();
      final simulation = spring.simulation(start: 0, end: 1);
      expect(simulation.x(.25), closeTo(1, .02));
      expect(simulation.x(.125), lessThan(.95));
      // By its settle duration less than half a percent is left.
      final settle = spring.settleDuration.inMicroseconds / 1e6;
      expect(simulation.x(settle), closeTo(1, .005));
      expect(spring.settleDuration, greaterThan(spring.duration));
      // And the simulation ends exactly on the target.
      expect(simulation.isDone(1), isTrue);
      expect(simulation.x(1), 1);
    });

    test('without bounce it never overshoots; with bounce it does', () {
      double peak(MotionSpring spring) {
        final simulation = spring.simulation(start: 0, end: 1);
        var max = 0.0;
        for (var t = 0.0; t < 2; t += .004) {
          final x = simulation.x(t);
          if (x > max) max = x;
        }
        return max;
      }

      expect(peak(const MotionSpring()), lessThanOrEqualTo(1));
      expect(peak(const MotionSpring(bounce: .3)), greaterThan(1.01));
      expect(peak(const MotionSpring(bounce: .3)), lessThan(1.2));
    });

    test('the curve runs from 0 to 1 and compares by value', () {
      const curve = MotionSpringCurve(MotionSpring());
      expect(curve.transform(0), 0);
      expect(curve.transform(1), 1);
      expect(curve.transform(.5), greaterThan(.8));
      // No pop at the end: the last few percent of the time cover almost
      // none of the distance.
      expect(curve.transform(.97), closeTo(1, .002));
      // Monotone for a spring without bounce.
      var previous = 0.0;
      for (var t = 0.0; t <= 1; t += .01) {
        final value = curve.transform(t);
        expect(value, greaterThanOrEqualTo(previous));
        previous = value;
      }
      expect(const MotionSpring().curve, curve);
      expect(MotionSpring.instant.curve.transform(.1), 1);
    });
  });

  group('Motion', () {
    test('compares by value and copies', () {
      expect(Motion.lively.copyWith(), Motion.lively);
      expect(Motion.lively, isNot(Motion.calm));
      expect(
        Motion.calm.copyWith(pressScale: .9),
        isNot(Motion.calm),
      );
      expect(Motion.calm.copyWith(pressScale: .9).pressScale, .9);
    });

    test('reduce takes the movement out and keeps a short fade', () {
      final reduced = Motion.lively.reduce();
      expect(reduced.reduced, isTrue);
      expect(reduced.snappy.isInstant, isTrue);
      expect(reduced.smooth.isInstant, isTrue);
      expect(reduced.bouncy.isInstant, isTrue);
      expect(reduced.pressScale, 1);
      expect(reduced.indicatorStretch, 0);
      expect(reduced.overlayScale, 1);
      expect(reduced.overlayTravel, 0);
      expect(reduced.slow, Motion.lively.fast);
      expect(reduced.reduce(), same(reduced));
    });

    test('none has no duration at all', () {
      expect(Motion.none.fast, Duration.zero);
      expect(Motion.none.slow, Duration.zero);
      expect(Motion.none.snappy.isInstant, isTrue);
      expect(Motion.none.reduced, isTrue);
    });
  });

  group('the theme', () {
    test('finesse is lively, the shadcn styles are calm', () {
      expect(StyleTokens.finesse.motion, Motion.lively);
      expect(StyleTokens.finesseMobile.motion, Motion.lively);
      expect(StyleTokens.nova.motion, Motion.calm);
      expect(StyleTokens.maia.motion, Motion.calm);
      expect(StyleTokens.lyra.motion, Motion.calm);
      expect(ThemeData().motion, Motion.lively);
      expect(ThemeData(style: StyleTokens.nova).motion, Motion.calm);
    });

    test('ThemeData(motion:) replaces the style motion on both form '
        'factors', () {
      final theme = ThemeData(motion: Motion.none);
      expect(theme.motion, Motion.none);
      expect(
        theme.withFormFactor(FormFactor.mobile).motion,
        Motion.none,
      );
      // Everything else about the style is untouched.
      expect(theme.style.buttonHeight, ThemeData().style.buttonHeight);
      expect(theme.primaryButtonTheme, ThemeData().primaryButtonTheme);
    });

    test('the override survives copyWith, and can be replaced', () {
      final theme = ThemeData(motion: Motion.none);
      expect(theme.copyWith(style: StyleTokens.lyra).motion, Motion.none);
      expect(
        theme.copyWith(radius: BorderRadius.zero).motion,
        Motion.none,
      );
      expect(theme.copyWith(motion: Motion.calm).motion, Motion.calm);
      expect(
        ThemeData().copyWith(motion: Motion.calm),
        ThemeData(motion: Motion.calm),
      );
    });

    test('a theme built twice with the same motion is equal', () {
      final custom = Motion.lively.copyWith(pressScale: .9);
      expect(ThemeData(motion: custom), ThemeData(motion: custom));
      expect(
        ThemeData(motion: Motion.lively),
        ThemeData(),
        reason: 'passing the style motion explicitly changes nothing',
      );
      expect(ThemeData(motion: custom), isNot(ThemeData()));
    });

    test('StyleTokens.copyWith(motion:) reaches the phone metrics', () {
      final style = StyleTokens.finesse.copyWith(motion: Motion.calm);
      expect(style.motion, Motion.calm);
      expect(style.forFormFactor(FormFactor.mobile).motion, Motion.calm);
    });

    testWidgets('Motion.of honours reduced motion', (tester) async {
      late Motion plain;
      late Motion reduced;
      await tester.pumpWidget(
        FinesseApp(
          home: Builder(
            builder: (context) {
              plain = Motion.of(context);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: Builder(
                  builder: (context) {
                    reduced = Motion.of(context);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );
      expect(plain, Motion.lively);
      expect(reduced, Motion.lively.reduce());
      expect(reduced.reduced, isTrue);
    });
  });
}
