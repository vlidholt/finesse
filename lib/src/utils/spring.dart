import 'dart:math' as math;

import 'package:finesse/src/theme/motion.dart';
import 'package:flutter/widgets.dart';

/// Drives one number with [MotionSpring]s.
///
/// It is the explicit counterpart of [SpringBuilder], for a `State` that
/// animates several values or needs to hand the animation to a render
/// object. Retargeting with [animateTo] while the value is moving keeps the
/// velocity it has, so the motion turns around instead of restarting.
///
/// ```dart
/// late final _offset = SpringController(vsync: this);
///
/// void _open() => _offset.animateTo(1, spring: Motion.of(context).smooth);
/// ```
///
/// Listen to [animation]; dispose the controller with the state.
class SpringController {
  /// Creates a controller at rest on [value].
  ///
  /// [tolerance] is how close to its target the value has to be to count as
  /// arrived: the default suits a value between 0 and 1; pass about 0.05 for
  /// one in logical pixels.
  SpringController({
    required TickerProvider vsync,
    double value = 0,
    this.tolerance = 1e-3,
  }) : _controller = AnimationController.unbounded(vsync: vsync, value: value),
       _target = value;

  final AnimationController _controller;
  double _target;

  /// The distance from the target at which the value counts as arrived.
  final double tolerance;

  /// The animated value, as an [Animation] to listen to or to hand to a
  /// transition widget.
  Animation<double> get animation => _controller;

  /// The current value.
  double get value => _controller.value;

  /// The value the controller is heading for, or resting on.
  double get target => _target;

  /// The current speed, in units per second.
  double get velocity => _controller.isAnimating ? _controller.velocity : 0;

  /// Whether the value is still moving.
  bool get isAnimating => _controller.isAnimating;

  /// Moves the value to [target] with [spring], starting from the velocity
  /// it has now, or from [velocity] when given — the speed of a fling, say.
  ///
  /// An instant [spring] jumps. The future completes when the value comes to
  /// rest and is cancelled when the motion is retargeted.
  TickerFuture animateTo(
    double target, {
    required MotionSpring spring,
    double? velocity,
  }) {
    final from = value;
    final startVelocity = velocity ?? this.velocity;
    _target = target;
    if (spring.isInstant ||
        ((from - target).abs() < tolerance &&
            startVelocity.abs() < tolerance)) {
      jumpTo(target);
      return TickerFuture.complete();
    }
    return _controller.animateWith(
      spring.simulation(
        start: from,
        end: target,
        velocity: startVelocity,
        tolerance: tolerance,
      ),
    );
  }

  /// Moves both the value and its target by [delta] without disturbing the
  /// motion: what is left of the travel, and its velocity, stay as they are.
  ///
  /// For a target that was moved by layout rather than by the user — the
  /// selected tab shifting when the window is resized — which the value
  /// should follow rigidly. [spring] continues the motion in flight.
  void shiftBy(double delta, {required MotionSpring spring}) {
    if (delta == 0) return;
    if (!isAnimating || spring.isInstant) {
      jumpTo(_target + delta);
      return;
    }
    final startVelocity = velocity;
    final from = value + delta;
    _target += delta;
    _controller.animateWith(
      spring.simulation(
        start: from,
        end: _target,
        velocity: startVelocity,
        tolerance: tolerance,
      ),
    );
  }

  /// Puts the value on [value] at once and stops any motion.
  void jumpTo(double value) {
    _target = value;
    _controller
      ..stop()
      ..value = value;
  }

  /// Stops the motion where it is. The value it stopped on becomes the
  /// target.
  void stop() {
    _controller.stop();
    _target = _controller.value;
  }

  /// Releases the ticker. Call it from the state's `dispose`.
  void dispose() => _controller.dispose();
}

/// Builds a widget from a number that follows [value] on a spring.
///
/// The spring-driven counterpart of `TweenAnimationBuilder`: whenever
/// [value] changes, the number handed to [builder] travels to it with
/// [spring], keeping its velocity when the target changes mid-flight. It
/// starts on [value] without animating, and jumps when motion is reduced or
/// switched off.
///
/// ```dart
/// SpringBuilder(
///   value: expanded ? 1 : 0,
///   builder: (context, t, child) => Transform.rotate(
///     angle: t * math.pi,
///     child: child,
///   ),
///   child: const PhosphorIcon(PhosphorIconsRegular.caretDown),
/// )
/// ```
///
/// [builder] runs on every frame of the motion, so keep it to transforms
/// and opacity and pass the static part of the subtree as [child]. A value
/// that overshoots — a bouncy spring — goes past its target for a moment:
/// clamp it where that matters (an opacity).
class SpringBuilder extends StatefulWidget {
  /// Creates a spring-driven builder.
  const SpringBuilder({
    required this.value,
    required this.builder,
    this.spring,
    this.tolerance = 1e-3,
    this.onEnd,
    this.child,
    super.key,
  });

  /// The value to rest on. A change starts the motion.
  final double value;

  /// The spring to move with. Defaults to the theme's `Motion.snappy`.
  final MotionSpring? spring;

  /// The distance from [value] at which the motion counts as finished; see
  /// `SpringController.tolerance`.
  final double tolerance;

  /// Called when the number comes to rest on [value].
  final VoidCallback? onEnd;

  /// Builds the widget from the animated number.
  final ValueWidgetBuilder<double> builder;

  /// The part of the subtree that does not depend on the number.
  final Widget? child;

  @override
  State<SpringBuilder> createState() => _SpringBuilderState();
}

class _SpringBuilderState extends State<SpringBuilder>
    with SingleTickerProviderStateMixin {
  late final _controller = SpringController(
    vsync: this,
    value: widget.value,
    tolerance: widget.tolerance,
  );

  @override
  void didUpdateWidget(SpringBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.target) {
      final spring = widget.spring ?? Motion.of(context).snappy;
      _controller.animateTo(widget.value, spring: spring).whenComplete(() {
        if (mounted && _controller.target == widget.value) {
          widget.onEnd?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.animation,
      builder: (context, child) =>
          widget.builder(context, _controller.value, child),
      child: widget.child,
    );
  }
}

/// Scales its child down while it is [pressed] and springs it back on
/// release: the touch response of a button.
///
/// The scale is a paint-time transform. The child's layout, its hit-test
/// area and everything around it stay exactly where they are.
///
/// ```dart
/// PressScale(
///   pressed: states.contains(WidgetState.pressed),
///   child: content,
/// )
/// ```
///
/// A tap is often over before a frame has shown it: the press and the
/// release arrive together, and the child is never built pressed at all. So
/// that it is still acknowledged, a release that comes before the child has
/// visibly moved gives it a short pulse — down and back — instead of
/// nothing. Count the taps in [taps] and a tap that never showed as a press
/// pulses too. [pulse] turns both off.
///
/// Pass `pressed: false` for a disabled control: it must not respond. With
/// reduced motion, or a [scale] of 1, the child is painted as it is.
class PressScale extends StatefulWidget {
  /// Creates a press response around [child].
  const PressScale({
    required this.pressed,
    required this.child,
    this.scale,
    this.spring,
    this.alignment = Alignment.center,
    this.pulse = true,
    this.taps = 0,
    super.key,
  });

  /// Whether the child is being pressed.
  final bool pressed;

  /// The number of completed taps so far. Increment it from the tap
  /// handler: a change while the child is not [pressed] plays the pulse, so
  /// a click that was down and up within one frame is still acknowledged.
  final int taps;

  /// The scale of the pressed child. Defaults to the theme's
  /// `Motion.pressScale`; pass `Motion.surfacePressScale` for a card or a
  /// row, where the same factor would move the edges much further.
  final double? scale;

  /// The spring of the press and of the release. Defaults to the theme's
  /// `Motion.snappy`.
  final MotionSpring? spring;

  /// The point the child shrinks towards.
  final AlignmentGeometry alignment;

  /// Whether a press released before it showed still plays a short pulse.
  final bool pulse;

  /// The widget that responds.
  final Widget child;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  // 0 at rest, 1 fully pressed.
  late final _press = SpringController(
    vsync: this,
    value: widget.pressed ? 1 : 0,
  );

  @override
  void didUpdateWidget(PressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tapped = widget.taps != oldWidget.taps;
    if (widget.pressed == oldWidget.pressed && !tapped) return;
    final spring = widget.spring ?? Motion.of(context).snappy;
    if (widget.pressed) {
      _press.animateTo(1, spring: spring);
    } else if (widget.pulse && !spring.isInstant && _press.value < .5) {
      // Released before the press showed. Send it on towards "pressed" with
      // the speed that peaks most of the way there, and let the spring
      // bring it back: one continuous dip, and no timer to hold it down.
      final seconds =
          spring.duration.inMicroseconds / Duration.microsecondsPerSecond;
      final kick = (.8 - _press.value) * 2 * math.pi / seconds * math.e;
      _press.animateTo(
        0,
        spring: spring,
        velocity: math.max(_press.velocity, kick),
      );
    } else {
      _press.animateTo(0, spring: spring);
    }
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pressedScale = widget.scale ?? Motion.of(context).pressScale;
    // The same widgets whatever the motion, so the child keeps its state
    // when reduced motion is switched on or off. An identity transform
    // paints its child directly and costs no layer.
    return AnimatedBuilder(
      animation: _press.animation,
      builder: (context, child) => Transform.scale(
        scale: 1 + (pressedScale - 1) * _press.value,
        alignment: widget.alignment,
        child: child,
      ),
      child: widget.child,
    );
  }
}
