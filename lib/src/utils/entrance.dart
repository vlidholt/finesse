import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

/// Says where the content below it grows from: the point of its own box that
/// faces whatever opened it.
///
/// An overlay places one around its content — a popover that opens below
/// its trigger grows from [Alignment.topCenter], a submenu to the right of
/// its parent from [Alignment.centerLeft] — and the overlay's entrance or
/// an [Entrance] inside reads it. Without one they grow from the centre.
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
/// The one transform behind [OverlayEntrance] and [Entrance]. [progress]
/// runs from 0 (hidden) to 1 (in place) and may overshoot; the fade is
/// finished by `fadeEnd` of the way, so the content is readable well before
/// it settles.
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

/// What stands for [curve] where curves are compared: the four numbers of
/// a [Cubic], which has no equality of its own, and the curve itself
/// otherwise. `Motion` compares its curves the same way.
Object _comparable(Curve curve) =>
    curve is Cubic ? (curve.a, curve.b, curve.c, curve.d) : curve;

/// How an overlay arrives: for how long, on which curve, from what scale and
/// how far.
///
/// The package's overlays — popovers, menus, tooltips, dialogs — build one
/// from the theme's [Motion] and hand it to an [OverlayEntrance]. It is a
/// value: two built from equal tokens are equal, so nothing has to be kept
/// to tell whether the entrance changed.
///
/// Internal: it is not exported from `package:finesse/finesse.dart`. An app
/// animates its own content with [Entrance].
@immutable
class EntranceSpec {
  /// Creates the description of an entrance.
  const EntranceSpec({
    required this.duration,
    required this.curve,
    this.scale,
    this.travel,
  });

  /// The entrance for [motion]: a fade with a little growth and travel on
  /// [spring] (the motion's `snappy` spring when null), as long as the
  /// spring takes to settle. With reduced motion, or an instant spring, it
  /// is a short fade; with no motion at all it is [isInstant].
  factory EntranceSpec.of(Motion motion, {MotionSpring? spring}) {
    final effectiveSpring = spring ?? motion.snappy;
    final reduced = motion.reduced || effectiveSpring.isInstant;
    return EntranceSpec(
      duration: reduced ? motion.fast : effectiveSpring.settleDuration,
      curve: reduced ? motion.standard : effectiveSpring.curve,
      // A reduced entrance is a fade wherever it ends up being built.
      scale: reduced ? 1 : null,
      travel: reduced ? 0 : null,
    );
  }

  /// A plain short fade for [motion], with no growth and no travel: the
  /// entrance of an overlay that *replaces* one already showing — the next
  /// menu of a menubar, the tooltip of the neighbouring button — where a
  /// second full entrance would read as a flicker.
  factory EntranceSpec.fade(Motion motion) => EntranceSpec(
    duration: motion.fast,
    curve: motion.standard,
    scale: 1,
    travel: 0,
  );

  /// How long the entrance takes.
  final Duration duration;

  /// The curve of the way in. The way out is a straight line; see
  /// [EntranceProgress].
  final Curve curve;

  /// The scale the content starts at. Null is the theme's
  /// `Motion.overlayScale`, read where the entrance is built.
  final double? scale;

  /// How far, in logical pixels, the content travels away from its origin.
  /// Null is the theme's `Motion.overlayTravel`.
  final double? travel;

  /// Whether there is nothing to play: the overlay is simply there.
  bool get isInstant => duration <= Duration.zero;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntranceSpec &&
          other.duration == duration &&
          _comparable(other.curve) == _comparable(curve) &&
          other.scale == scale &&
          other.travel == travel;

  @override
  int get hashCode => Object.hash(duration, _comparable(curve), scale, travel);

  @override
  String toString() =>
      'EntranceSpec(${duration.inMilliseconds}ms, $curve, '
      'scale: $scale, travel: $travel)';
}

/// Plays an [EntranceSpec] around an overlay: the content fades in while it
/// grows from the edge that faces its anchor (the nearest [MotionOrigin])
/// and travels a few pixels away from it. Run backwards it is the exit — a
/// straight line from wherever it was, on the controller's
/// `reverseDuration`.
///
/// The fade is not an opacity layer around [child]. A backdrop filter does
/// not survive under one on every renderer, so the fade is offered through
/// a [BackdropFadeHost]: a glass surface in [child] takes it over and fades
/// itself inside its own filter, and when there is none the host fades the
/// child as usual.
///
/// With a [controller] the entrance plays on it, and this widget gives it
/// the length of the [spec] — an entrance started before this widget was
/// built ran on whatever length the controller had before. Without one it
/// keeps its own. Either way, [autoPlay] starts the entrance after the
/// frame that first builds this widget; an owner that starts it itself
/// passes false.
///
/// Internal: it is not exported from `package:finesse/finesse.dart`.
class OverlayEntrance extends StatefulWidget {
  /// Creates the entrance of an overlay.
  const OverlayEntrance({
    required this.spec,
    required this.child,
    this.controller,
    this.autoPlay = true,
    super.key,
  });

  /// What to play.
  final EntranceSpec spec;

  /// The controller the entrance plays on, or null for one of its own.
  final AnimationController? controller;

  /// Whether the entrance starts by itself, after the first frame.
  final bool autoPlay;

  /// The overlay.
  final Widget child;

  /// How far into view an entrance of [spec] playing on [controller] is
  /// painted now, under [motion]: the opacity of its fade and its scale.
  ///
  /// For an owner that replaces the entrance with an exit of its own: an
  /// exit that started from fully in view would first jump there.
  static ({double opacity, double scale}) paintedAt(
    Animation<double> controller,
    EntranceSpec spec,
    Motion motion,
  ) {
    if (spec.isInstant) return (opacity: 1, scale: 1);
    // The same progress as the entrance's own: the turning points are
    // shared per controller and curve.
    final progress = EntranceProgress(controller, curve: spec.curve).value;
    final opacity = EntranceProgress(
      controller,
      curve: _FadeCurve(spec.curve, _EntranceTransition._fadeEnd),
    ).value;
    final from = motion.reduced ? 1.0 : (spec.scale ?? motion.overlayScale);
    return (opacity: opacity, scale: from + (1 - from) * progress);
  }

  @override
  State<OverlayEntrance> createState() => _OverlayEntranceState();
}

class _OverlayEntranceState extends State<OverlayEntrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _own;

  AnimationController get _controller => widget.controller ?? _own!;

  EntranceProgress? _progress;
  EntranceProgress? _fade;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _own = AnimationController(vsync: this);
    _controller.duration = widget.spec.duration;
    if (widget.autoPlay) {
      // After the frame: the overlay is on screen before any of the
      // entrance has played.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(OverlayEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      if (widget.controller != null) {
        _own?.dispose();
        _own = null;
      } else {
        _own = AnimationController(vsync: this);
      }
      _progress = _fade = null;
    }
    if (_comparable(widget.spec.curve) != _comparable(oldWidget.spec.curve)) {
      _progress = _fade = null;
    }
    _controller.duration = widget.spec.duration;
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = widget.spec.curve;
    final progress = _progress ??= EntranceProgress(_controller, curve: curve);
    final fade = _fade ??= EntranceProgress(
      _controller,
      curve: _FadeCurve(curve, _EntranceTransition._fadeEnd),
    );
    return _EntranceTransition(
      progress: progress,
      scale: widget.spec.scale,
      travel: widget.spec.travel,
      fade: false,
      child: BackdropFadeHost(opacity: fade, child: widget.child),
    );
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
      other is _FadeCurve &&
      _comparable(other.curve) == _comparable(curve) &&
      other.end == end;

  @override
  int get hashCode => Object.hash(_comparable(curve), end);
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
/// It is what the package's overlays play on their controllers, and it does
/// the same for a route's `animation`:
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
    _leg = legs[(_comparable(curve), _begin, _end)] ??= _Leg();
  }

  static final _legs = Expando<Map<(Object, double, double), _Leg>>();

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
