import 'dart:math' as math;

import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// A spring, described the way a designer reads one: how long it takes and
/// how much it bounces.
///
/// It is the value type behind every moving or scaling transition in the
/// package. Unlike a curve with a fixed duration, a spring keeps the velocity
/// it had when it is retargeted, so an interrupted transition turns around
/// without a jump.
///
/// [duration] is the *perceptual* duration: the time after which the motion
/// reads as finished (about 98.5% of the way for a spring without bounce).
/// The simulation itself runs a little longer while it settles; see
/// [settleDuration].
///
/// ```dart
/// const MotionSpring(duration: Duration(milliseconds: 250))
/// const MotionSpring(duration: Duration(milliseconds: 400), bounce: .25)
/// ```
///
/// It compares by value and has a const constructor, so it can sit in a
/// theme. `SpringDescription` — Flutter's own type, which [description]
/// returns — has no `==`.
@immutable
class MotionSpring {
  /// Creates a spring that takes [duration] and overshoots by [bounce].
  ///
  /// A [bounce] of 0 is critically damped: the fastest spring that never
  /// overshoots. Values up to 1 overshoot more; negative values are
  /// overdamped and slower to arrive.
  const MotionSpring({
    this.duration = const Duration(milliseconds: 250),
    this.bounce = 0,
  }) : assert(bounce > -1 && bounce < 1, 'bounce must be between -1 and 1');

  /// A spring that arrives at once. Driving anything with it is a jump.
  ///
  /// It is what every spring of a [Motion] becomes when motion is switched
  /// off or reduced.
  static const instant = MotionSpring(duration: Duration.zero);

  /// The perceptual duration: when the motion reads as finished.
  final Duration duration;

  /// How much the spring overshoots, from 0 (not at all) towards 1.
  final double bounce;

  /// Whether this spring arrives at once; see [instant].
  bool get isInstant => duration <= Duration.zero;

  /// The mass, stiffness and damping Flutter's simulations take.
  ///
  /// The same conversion as `SpringDescription.withDurationAndBounce`.
  SpringDescription get description {
    assert(!isInstant, 'An instant spring has no description.');
    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    final stiffness = math.pow(2 * math.pi / seconds, 2).toDouble();
    final damping = bounce >= 0
        ? 4 * math.pi * (1 - bounce) / seconds
        : 4 * math.pi / (seconds * (1 + bounce));
    return SpringDescription(mass: 1, stiffness: stiffness, damping: damping);
  }

  /// The length of this spring as a fixed-duration animation: the time
  /// after which less than half a percent of the travel is left. A little
  /// longer than [duration]; [curve] runs over exactly this.
  ///
  /// Kept short on purpose. An entrance timed by it should not hold input
  /// back for a tail nobody can see.
  Duration get settleDuration {
    if (isInstant) return Duration.zero;
    // The rate the slowest part of the motion decays at, relative to the
    // undamped frequency: the envelope of a bouncy spring, the slow pole of
    // an overdamped one.
    final ratio = bounce >= 0 ? 1 - bounce : 1 / (1 + bounce);
    final rate = bounce >= 0 ? ratio : ratio - math.sqrt(ratio * ratio - 1);
    final factor = math.max(1.2, .86 / rate);
    return Duration(microseconds: (duration.inMicroseconds * factor).round());
  }

  /// This spring as a [Curve] over [settleDuration], for an animation that
  /// has to take a curve and a duration — a `flutter_animate` effect, an
  /// implicit Flutter animation.
  ///
  /// A curve cannot carry velocity over an interruption; drive the motion
  /// with a `SpringController` or a `SpringBuilder` when it can be
  /// interrupted.
  Curve get curve => MotionSpringCurve(this);

  /// A simulation from [start] to [end], starting at [velocity] (in units
  /// per second), that ends exactly on [end].
  ///
  /// [tolerance] is the distance from [end] at which the motion counts as
  /// finished.
  SpringSimulation simulation({
    required double start,
    required double end,
    double velocity = 0,
    double tolerance = 1e-3,
  }) {
    final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
    return SpringSimulation(
      description,
      start,
      end,
      velocity,
      snapToEnd: true,
      tolerance: Tolerance(
        distance: tolerance,
        // The speed the spring still has when it is `tolerance` away.
        velocity: tolerance * 2 * math.pi / seconds,
      ),
    );
  }

  /// Creates a copy with the given fields replaced.
  MotionSpring copyWith({Duration? duration, double? bounce}) => MotionSpring(
    duration: duration ?? this.duration,
    bounce: bounce ?? this.bounce,
  );

  /// This spring made slower by [factor]: 1.5 takes half as long again.
  MotionSpring scaled(double factor) => isInstant || factor == 1
      ? this
      : copyWith(
          duration: Duration(
            microseconds: (duration.inMicroseconds * factor).round(),
          ),
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotionSpring &&
          other.duration == duration &&
          other.bounce == bounce;

  @override
  int get hashCode => Object.hash(duration, bounce);

  @override
  String toString() =>
      'MotionSpring(${duration.inMilliseconds}ms, bounce: $bounce)';
}

/// A [MotionSpring] as a [Curve]: the spring's position from 0 to 1 over its
/// `settleDuration`, ending exactly on 1.
///
/// Const and compared by value, so it can be the `curve` of a const effect in
/// a theme.
@immutable
class MotionSpringCurve extends Curve {
  /// Creates the curve of [spring].
  const MotionSpringCurve(this.spring);

  /// The spring this curve samples.
  final MotionSpring spring;

  @override
  double transformInternal(double t) {
    if (spring.isInstant) return 1;
    final total =
        spring.settleDuration.inMicroseconds / Duration.microsecondsPerSecond;
    final simulation = spring.simulation(start: 0, end: 1);
    // Scaled by where the spring is when the curve ends, so the last frame
    // lands on 1 instead of jumping the half percent that was left.
    return simulation.x(t * total) / simulation.x(total);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotionSpringCurve && other.spring == spring;

  @override
  int get hashCode => spring.hashCode;

  @override
  String toString() => 'MotionSpringCurve($spring)';
}

/// The motion vocabulary of a style: the durations, curves and springs every
/// component animates with.
///
/// A style carries one (`StyleTokens.motion`), so `finesse` is lively and the
/// shadcn styles are calmer, and `ThemeData(motion: ...)` replaces it for a
/// whole app — [Motion.none] switches every transition off. Components do not
/// read it from the theme directly: they call [Motion.of], which also honours
/// the platform's reduced-motion setting.
///
/// ```dart
/// final motion = Motion.of(context);
/// SpringBuilder(
///   value: open ? 1 : 0,
///   spring: motion.smooth,
///   builder: (context, t, child) => Opacity(opacity: t, child: child),
///   child: panel,
/// )
/// ```
///
/// What each token is for:
///
/// * [fast], [normal] and [slow] time fades and colour changes, with
///   [standard] (a change in place), [emphasized] (something arriving) and
///   [exit] (something leaving).
/// * [snappy], [smooth] and [bouncy] move and scale things: [snappy] for
///   touch response and selection indicators, [smooth] for surfaces (sheets,
///   panels, accordions), [bouncy] for small delights (a thumb, a badge, a
///   check mark).
/// * [pressScale] and [surfacePressScale] are how far a pressed control and
///   a pressed surface shrink; [indicatorStretch] is how far a travelling
///   selection indicator stretches; [overlayScale] and [overlayTravel] shape
///   an overlay growing out of its anchor.
@immutable
class Motion {
  /// Creates a motion vocabulary. The defaults are [Motion.calm].
  const Motion({
    this.fast = const Duration(milliseconds: 120),
    this.normal = const Duration(milliseconds: 200),
    this.slow = const Duration(milliseconds: 320),
    this.standard = const Cubic(.2, 0, 0, 1),
    this.emphasized = const Cubic(.16, 1, .3, 1),
    this.exit = const Cubic(.4, 0, 1, 1),
    this.snappy = const MotionSpring(duration: Duration(milliseconds: 220)),
    this.smooth = const MotionSpring(duration: Duration(milliseconds: 320)),
    this.bouncy = const MotionSpring(
      duration: Duration(milliseconds: 300),
      bounce: .12,
    ),
    this.pressScale = .98,
    this.surfacePressScale = .995,
    this.indicatorStretch = .2,
    this.overlayScale = .96,
    this.overlayTravel = 4,
    this.shimmer = false,
    this.reduced = false,
  });

  /// The motion of the `finesse` style: quick springs with a little life in
  /// them, a clear press response and a selection indicator that stretches
  /// as it travels.
  static const lively = Motion(
    snappy: MotionSpring(duration: Duration(milliseconds: 240), bounce: .08),
    smooth: MotionSpring(duration: Duration(milliseconds: 360)),
    bouncy: MotionSpring(duration: Duration(milliseconds: 360), bounce: .28),
    pressScale: .97,
    surfacePressScale: .99,
    indicatorStretch: .35,
    overlayScale: .94,
    overlayTravel: 6,
    shimmer: true,
  );

  /// The motion of the shadcn styles: the same vocabulary with shorter
  /// travel, almost no overshoot and a fainter press.
  static const calm = Motion();

  /// No motion at all: every duration is zero, every spring is
  /// [MotionSpring.instant] and nothing scales, stretches or travels.
  static const none = Motion(
    fast: Duration.zero,
    normal: Duration.zero,
    slow: Duration.zero,
    standard: Curves.linear,
    emphasized: Curves.linear,
    exit: Curves.linear,
    snappy: MotionSpring.instant,
    smooth: MotionSpring.instant,
    bouncy: MotionSpring.instant,
    pressScale: 1,
    surfacePressScale: 1,
    indicatorStretch: 0,
    overlayScale: 1,
    overlayTravel: 0,
    reduced: true,
  );

  /// The motion to animate with at [context]: the theme's, or its
  /// [reduce]d form when the platform asks for reduced motion
  /// (`MediaQuery.disableAnimationsOf`).
  ///
  /// Every component reads its motion through this, never from the style
  /// directly, so the accessibility setting is honoured in one place.
  static Motion of(BuildContext context) {
    final motion = Theme.of(context).motion;
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false
        ? motion.reduce()
        : motion;
  }

  /// The duration of a quick change: a hover colour, a press, a small fade.
  final Duration fast;

  /// The duration of an ordinary fade or cross-fade.
  final Duration normal;

  /// The duration of a large or deliberate fade.
  final Duration slow;

  /// The curve of a change in place: ease in and out, weighted to the end.
  final Curve standard;

  /// The curve of something arriving: fast at first, then a long settle.
  final Curve emphasized;

  /// The curve of something leaving: it accelerates away.
  final Curve exit;

  /// The spring of touch response and of selection indicators.
  final MotionSpring snappy;

  /// The spring of surfaces: sheets, panels, accordions, toasts.
  final MotionSpring smooth;

  /// The spring of small delights: a switch thumb, a badge, a check mark.
  final MotionSpring bouncy;

  /// The scale of a pressed control: a button, a toggle, a chip. 1 is no
  /// press response.
  final double pressScale;

  /// The scale of a pressed surface: a card, a list tile. Closer to 1 than
  /// [pressScale], because the same factor moves a large surface further.
  final double surfacePressScale;

  /// How far a selection indicator stretches while it travels, as the extra
  /// time its trailing edge takes: 0 moves it rigidly, 0.5 lets the trailing
  /// edge take half as long again as the leading one.
  final double indicatorStretch;

  /// The scale an overlay grows from, out of the edge facing its anchor.
  final double overlayScale;

  /// How far, in logical pixels, an overlay travels away from its anchor as
  /// it appears.
  final double overlayTravel;

  /// Whether a loading placeholder shimmers — a highlight sweeping across
  /// it — rather than pulsing as a whole.
  final bool shimmer;

  /// Whether this is a reduced vocabulary — the result of [reduce], or
  /// [Motion.none]. A component that slides or scales checks it to fall back
  /// to a plain fade or an instant change.
  final bool reduced;

  /// This vocabulary with movement taken out, for the platform's
  /// reduced-motion setting: springs arrive at once, nothing scales,
  /// stretches or travels, and what is left is a short plain fade: [fast]
  /// for every duration and [standard] for every curve.
  Motion reduce() {
    if (reduced) return this;
    return Motion(
      fast: fast,
      normal: fast,
      slow: fast,
      standard: standard,
      emphasized: standard,
      exit: standard,
      snappy: MotionSpring.instant,
      smooth: MotionSpring.instant,
      bouncy: MotionSpring.instant,
      pressScale: 1,
      surfacePressScale: 1,
      indicatorStretch: 0,
      overlayScale: 1,
      overlayTravel: 0,
      shimmer: shimmer,
      reduced: true,
    );
  }

  /// Creates a copy with the given fields replaced.
  Motion copyWith({
    Duration? fast,
    Duration? normal,
    Duration? slow,
    Curve? standard,
    Curve? emphasized,
    Curve? exit,
    MotionSpring? snappy,
    MotionSpring? smooth,
    MotionSpring? bouncy,
    double? pressScale,
    double? surfacePressScale,
    double? indicatorStretch,
    double? overlayScale,
    double? overlayTravel,
    bool? shimmer,
    bool? reduced,
  }) => Motion(
    fast: fast ?? this.fast,
    normal: normal ?? this.normal,
    slow: slow ?? this.slow,
    standard: standard ?? this.standard,
    emphasized: emphasized ?? this.emphasized,
    exit: exit ?? this.exit,
    snappy: snappy ?? this.snappy,
    smooth: smooth ?? this.smooth,
    bouncy: bouncy ?? this.bouncy,
    pressScale: pressScale ?? this.pressScale,
    surfacePressScale: surfacePressScale ?? this.surfacePressScale,
    indicatorStretch: indicatorStretch ?? this.indicatorStretch,
    overlayScale: overlayScale ?? this.overlayScale,
    overlayTravel: overlayTravel ?? this.overlayTravel,
    shimmer: shimmer ?? this.shimmer,
    reduced: reduced ?? this.reduced,
  );

  List<Object?> get _props => [
    fast,
    normal,
    slow,
    standard,
    emphasized,
    exit,
    snappy,
    smooth,
    bouncy,
    pressScale,
    surfacePressScale,
    indicatorStretch,
    overlayScale,
    overlayTravel,
    shimmer,
    reduced,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Motion) return false;
    final a = _props;
    final b = other._props;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_props);

  @override
  String toString() {
    if (this == lively) return 'Motion.lively';
    if (this == calm) return 'Motion.calm';
    if (this == none) return 'Motion.none';
    return 'Motion(snappy: $snappy, smooth: $smooth, bouncy: $bouncy)';
  }
}
