import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Says where the content below it grows from: the point of its own box that
/// faces whatever opened it.
///
/// An overlay places one around its content — a popover that opens below
/// its trigger grows from [Alignment.topCenter], a submenu to the right of
/// its parent from [Alignment.centerLeft] — and an [EntranceEffect] or an
/// [Entrance] inside reads it. Without one they grow from the centre.
class MotionOrigin extends InheritedWidget {
  /// Places the origin [alignment] above [child].
  const MotionOrigin({
    required this.alignment,
    required super.child,
    super.key,
  });

  /// The point of the content's box it grows from.
  final Alignment alignment;

  /// The origin above [context], or null when there is none.
  static Alignment? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MotionOrigin>()?.alignment;

  @override
  bool updateShouldNotify(MotionOrigin oldWidget) =>
      alignment != oldWidget.alignment;
}

/// Paints [child] part of the way into view: faded, scaled about [origin]
/// and pulled towards it.
///
/// The one transform behind [EntranceEffect] and [Entrance]. [progress] runs
/// from 0 (hidden) to 1 (in place) and may overshoot; the fade is finished
/// by `fadeEnd` of the way, so the content is readable well before it
/// settles.
class _EntranceTransition extends StatelessWidget {
  const _EntranceTransition({
    required this.progress,
    required this.child,
    this.origin,
    this.scale,
    this.travel,
    this.fade = true,
  });

  final Animation<double> progress;
  final Alignment? origin;
  final double? scale;
  final double? travel;
  final bool fade;
  final Widget child;

  static const _fadeEnd = .6;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final effectiveOrigin =
        origin ?? MotionOrigin.maybeOf(context) ?? Alignment.center;
    // Reduced motion leaves the fade and nothing else.
    final fromScale = motion.reduced ? 1.0 : (scale ?? motion.overlayScale);
    final distance = motion.reduced ? 0.0 : (travel ?? motion.overlayTravel);
    // Away from the origin is into place, so the content starts pulled
    // towards it.
    final direction = Offset(effectiveOrigin.x, effectiveOrigin.y);
    Widget result = AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final t = progress.value;
        final currentScale = fromScale + (1 - fromScale) * t;
        final offset = direction * (distance * (1 - t));
        return Transform(
          transform: Matrix4.identity()
            ..translateByDouble(offset.dx, offset.dy, 0, 1)
            ..scaleByDouble(currentScale, currentScale, 1, 1),
          alignment: effectiveOrigin,
          child: child,
        );
      },
      child: child,
    );
    if (fade) {
      result = FadeTransition(
        opacity: progress.drive(const _FadeTween(_fadeEnd)),
        child: result,
      );
    }
    return result;
  }
}

class _FadeTween extends Animatable<double> {
  const _FadeTween(this.end);

  final double end;

  @override
  double transform(double t) => (t / end).clamp(0.0, 1.0);
}

/// The entrance of an overlay, as a `flutter_animate` effect: the content
/// fades in while it grows from the edge that faces its anchor and travels
/// a few pixels away from it.
///
/// It is const and reads everything else when it builds, so it can sit in a
/// theme's `effects:` list:
///
/// * the origin from the nearest [MotionOrigin] (or [origin], or the
///   centre);
/// * the starting scale and the travel from the theme's `Motion.overlayScale`
///   and `Motion.overlayTravel`, unless [scale] and [travel] are given;
/// * and with reduced motion it is a plain fade.
///
/// Played in reverse it is the exit. Give the controller a shorter
/// `reverseDuration` so the overlay leaves faster than it arrives.
///
/// ```dart
/// const [
///   EntranceEffect(
///     duration: Duration(milliseconds: 220),
///     curve: MotionSpringCurve(MotionSpring()),
///   ),
/// ]
/// ```
///
/// A duration and a curve in a const list cannot follow the theme's motion
/// tokens; [EntranceEffect.forMotion] returns a list that does, and returns
/// the *same* list for equal tokens, which a theme needs (effects have no
/// `==`).
@immutable
class EntranceEffect extends Effect<double> {
  /// Creates an entrance effect.
  const EntranceEffect({
    super.delay,
    super.duration,
    super.curve,
    this.origin,
    this.scale,
    this.travel,
    this.fade = true,
  }) : super(begin: 0, end: 1);

  /// The point of the content's box it grows from. Defaults to the nearest
  /// [MotionOrigin], then to the centre.
  final Alignment? origin;

  /// The scale the content starts at. Defaults to the theme's
  /// `Motion.overlayScale`.
  final double? scale;

  /// How far, in logical pixels, the content travels away from its origin.
  /// Defaults to the theme's `Motion.overlayTravel`.
  final double? travel;

  /// Whether the content fades in as well.
  final bool fade;

  static final _cache = <(Motion, MotionSpring?), List<Effect<dynamic>>>{};

  /// The entrance for [motion]: one [EntranceEffect] on [spring] (the
  /// motion's `snappy` spring when null), as long as the spring takes to
  /// settle.
  ///
  /// Equal arguments return the identical list, so a theme built twice from
  /// the same style compares equal.
  static List<Effect<dynamic>> forMotion(
    Motion motion, {
    MotionSpring? spring,
  }) {
    return _cache[(motion, spring)] ??= List.unmodifiable(
      _entrance(motion, spring ?? motion.snappy),
    );
  }

  static List<Effect<dynamic>> _entrance(Motion motion, MotionSpring spring) {
    final reduced = motion.reduced || spring.isInstant;
    final duration = reduced ? motion.fast : spring.settleDuration;
    // No motion at all leaves nothing to play, rather than an effect of no
    // length.
    if (duration <= Duration.zero) return const [];
    return [
      EntranceEffect(
        duration: duration,
        curve: reduced ? motion.standard : spring.curve,
        // A reduced entrance is a fade wherever it ends up being built.
        scale: reduced ? 1 : null,
        travel: reduced ? 0 : null,
      ),
    ];
  }

  static final _fadeCache = <Motion, List<Effect<dynamic>>>{};

  /// A plain short fade for [motion], with no growth and no travel: the
  /// entrance of an overlay that *replaces* one already showing — the next
  /// menu of a menubar, the tooltip of the neighbouring button — where a
  /// second full entrance would read as a flicker.
  ///
  /// Like [forMotion] it returns the identical list for equal tokens.
  static List<Effect<dynamic>> fadeFor(Motion motion) {
    return _fadeCache[motion] ??= List.unmodifiable([
      if (motion.fast > Duration.zero)
        EntranceEffect(
          duration: motion.fast,
          curve: motion.standard,
          scale: 1,
          travel: 0,
        ),
    ]);
  }

  /// The fade of this entrance on its own, or null when it does not
  /// [fade].
  ///
  /// For a host that applies the fade some other way than an opacity layer
  /// around the child — `FinesseAnimate.fadeThroughBackdrop` hands it to a
  /// glass surface — and builds the rest with [buildMotion].
  Animation<double>? fadeAnimation(
    AnimationController controller,
    EffectEntry entry,
  ) {
    if (!fade) return null;
    return EntranceProgress._entry(
      controller,
      entry,
      _FadeCurve(entry.curve, _EntranceTransition._fadeEnd),
    );
  }

  /// Builds the growth and travel of this entrance without its fade; see
  /// [fadeAnimation].
  Widget buildMotion(
    BuildContext context,
    Widget child,
    AnimationController controller,
    EffectEntry entry,
  ) {
    return _EntranceTransition(
      progress: EntranceProgress._entry(controller, entry, entry.curve),
      origin: origin,
      scale: scale,
      travel: travel,
      fade: false,
      child: child,
    );
  }

  @override
  Widget build(
    BuildContext context,
    Widget child,
    AnimationController controller,
    EffectEntry entry,
  ) {
    final motion = buildMotion(context, child, controller, entry);
    final opacity = fadeAnimation(controller, entry);
    if (opacity == null) return motion;
    return FadeTransition(opacity: opacity, child: motion);
  }
}

/// The curve of an entrance's fade: [curve], finished by [end] of the way.
@immutable
class _FadeCurve extends Curve {
  const _FadeCurve(this.curve, this.end);

  final Curve curve;
  final double end;

  @override
  double transformInternal(double t) =>
      (curve.transform(t) / end).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      other is _FadeCurve && other.curve == curve && other.end == end;

  @override
  int get hashCode => Object.hash(curve, end);
}

/// One leg of an entrance: where its progress was when the controller last
/// turned around, and which way it has been going since.
class _Leg {
  bool reversing = false;
  double fromT = 0;
  double fromP = 0;
  double lastT = 0;
  double lastP = 0;

  double valueAt(double t, AnimationStatus status, Curve curve) {
    final nowReversing = switch (status) {
      AnimationStatus.forward || AnimationStatus.completed => false,
      AnimationStatus.reverse => true,
      // At rest on zero either reading gives zero; keep the leg.
      AnimationStatus.dismissed => reversing,
    };
    if (nowReversing != reversing) {
      reversing = nowReversing;
      fromT = lastT;
      fromP = lastP;
    }
    double p;
    if (reversing) {
      // Set from outside to somewhere this leg never was: start over.
      if (t > fromT) {
        fromT = 1;
        fromP = 1;
      }
      // Out is a straight line in time from wherever it was: it starts to
      // go at once, where the entrance played backwards would hold still
      // for most of its length and then vanish.
      p = fromT <= 0 ? 0 : fromP * (t / fromT);
    } else {
      if (t < fromT) {
        fromT = 0;
        fromP = 0;
      }
      if (fromT <= 0) {
        p = curve.transform(t);
      } else {
        // Turned around part-way out: the rest of the curve, rescaled to
        // run from where it is to in place.
        final c0 = curve.transform(fromT);
        final rest = 1 - c0;
        p = rest.abs() < 1e-6
            ? (fromT >= 1 ? 1 : fromP + (1 - fromP) * (t - fromT) / (1 - fromT))
            : fromP + (1 - fromP) * (curve.transform(t) - c0) / rest;
      }
    }
    lastT = t;
    lastP = p;
    return p;
  }
}

/// The progress of an entrance on the animation that drives it: [curve] on
/// the way in, and a straight line back from wherever it had got to on the
/// way out — without a jump when the animation turns around mid-flight.
///
/// It is what an [EntranceEffect] plays on its controller, and it does the
/// same for a route's `animation`:
///
/// ```dart
/// final progress = EntranceProgress(
///   animation,
///   curve: Motion.of(context).snappy.curve,
/// );
/// ```
///
/// Why not a `CurvedAnimation`? Played backwards, a curve that arrives
/// quickly and then settles holds still for most of the exit and vanishes
/// at the end, and a `reverseCurve` jumps when the direction changes
/// part-way. Here the exit starts at once from the current value, and an
/// exit that is turned around again finishes the rest of the curve from
/// where it is.
///
/// The value runs from 0 to 1 and may overshoot 1 with a bouncy curve.
///
/// A transition is rebuilt with a new animation whenever its widget
/// rebuilds, so the turning points are kept with [parent], shared by every
/// progress with the same curve and interval.
class EntranceProgress extends Animation<double>
    with AnimationWithParentMixin<double> {
  /// Creates the progress of an entrance driven by [parent], which runs
  /// from 0 to 1. [begin] and [end] are the part of [parent]'s range the
  /// entrance plays over.
  EntranceProgress(
    this.parent, {
    required this.curve,
    double begin = 0,
    double end = 1,
  }) : _begin = begin,
       _end = end {
    final legs = _legs[parent] ??= {};
    _leg = legs[(curve, _begin, _end)] ??= _Leg();
  }

  EntranceProgress._entry(
    AnimationController controller,
    EffectEntry entry,
    Curve curve,
  ) : this(
        controller,
        curve: curve,
        begin: _ratio(controller, entry.begin, 0),
        end: _ratio(controller, entry.end, 1),
      );

  static final _legs = Expando<Map<(Curve, double, double), _Leg>>();

  static double _ratio(
    AnimationController controller,
    Duration at,
    double fallback,
  ) {
    final total = controller.duration?.inMicroseconds ?? 0;
    return total <= 0 ? fallback : at.inMicroseconds / total;
  }

  @override
  final Animation<double> parent;

  /// The curve of the way in.
  final Curve curve;

  final double _begin;
  final double _end;
  late final _Leg _leg;

  @override
  double get value {
    final span = _end - _begin;
    final t = span <= 0
        ? (parent.value >= _end ? 1.0 : 0.0)
        : ((parent.value - _begin) / span).clamp(0.0, 1.0);
    return _leg.valueAt(t, parent.status, curve);
  }
}

/// Brings its child into view on a spring, and takes it out again: a fade
/// with a little growth from [origin] and a few pixels of travel.
///
/// With [visible] left true it is an entrance played once, when the widget
/// is first built — for something that appears in response to the user, like
/// an inline error or the result of a search. Toggle [visible] and it
/// leaves, faster than it arrived, and comes back; interrupting either
/// keeps the velocity it had.
///
/// ```dart
/// Entrance(child: Alert(title: Text('Saved')))
/// ```
///
/// Only paint is animated. A hidden child keeps its place in the layout;
/// collapse it yourself (an `AnimatedSize`, a `Collapsible`) when the space
/// should close too. While it is hidden or leaving it ignores pointers.
///
/// With reduced motion it is a plain short fade.
class Entrance extends StatefulWidget {
  /// Creates an entrance around [child].
  const Entrance({
    required this.child,
    this.visible = true,
    this.appear = true,
    this.origin,
    this.scale,
    this.travel,
    this.spring,
    this.onHidden,
    super.key,
  });

  /// Whether the child is shown. Changing it plays the entrance or the exit.
  final bool visible;

  /// Whether the entrance plays when the widget is first built with
  /// [visible] true. False starts it in place.
  final bool appear;

  /// The point of the child's box it grows from. Defaults to the nearest
  /// [MotionOrigin], then to the centre.
  final Alignment? origin;

  /// The scale the child starts at. Defaults to the theme's
  /// `Motion.overlayScale`.
  final double? scale;

  /// How far, in logical pixels, the child travels away from [origin].
  /// Defaults to the theme's `Motion.overlayTravel`.
  final double? travel;

  /// The spring of the entrance. The exit runs on the same spring, a third
  /// faster. Defaults to the theme's `Motion.smooth`.
  final MotionSpring? spring;

  /// Called when the exit has finished and the child is fully hidden.
  final VoidCallback? onHidden;

  /// The widget to bring in.
  final Widget child;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final _progress = SpringController(
    vsync: this,
    value: widget.visible && !widget.appear ? 1 : 0,
  );
  bool _started = false;

  void _run() {
    final motion = Motion.of(context);
    final spring = widget.spring ?? motion.smooth;
    if (widget.visible) {
      if (motion.reduced) {
        // A plain short fade: the transition takes the scale and travel out.
        _progress.animateTo(
          1,
          spring: MotionSpring(duration: motion.fast),
        );
      } else {
        _progress.animateTo(1, spring: spring);
      }
    } else {
      final exit = motion.reduced
          ? MotionSpring(duration: motion.fast)
          : spring.scaled(2 / 3);
      _progress.animateTo(0, spring: exit).whenComplete(() {
        if (mounted && !widget.visible) widget.onHidden?.call();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (widget.visible && widget.appear) _run();
    }
  }

  @override
  void didUpdateWidget(Entrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) _run();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.visible,
      child: _EntranceTransition(
        progress: _progress.animation,
        origin: widget.origin,
        scale: widget.scale,
        travel: widget.travel,
        child: widget.child,
      ),
    );
  }
}
