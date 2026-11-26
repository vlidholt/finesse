import 'package:flutter/widgets.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/theme.dart';

/// Lerps between two colours the way a cross-fade between them looks:
/// never through a colour darker (or lighter) than both.
///
/// `Color.lerp` lerps red, green, blue and alpha on their own, so between
/// colours of different opacity it is wrong in two ways. "No colour" is
/// transparent *black*, so a fill fading in over a light surface is grey
/// halfway. And between two translucent colours — a button's glass fill
/// and its hover wash, white at 80% and near-black at 4% — the colour
/// halfway is a mid-grey at 42%, far darker than either: the flicker of a
/// hover. Here each colour is weighed by its opacity (a premultiplied
/// lerp), so composited over anything the result moves linearly from one
/// look to the other; a null side is the other colour at zero opacity.
Color? lerpColorThroughAlpha(Color? a, Color? b, double t) {
  if (a == null && b == null) return null;
  final from = a ?? b!.withValues(alpha: 0);
  final to = b ?? a!.withValues(alpha: 0);
  final alpha = (from.a + (to.a - from.a) * t).clamp(0.0, 1.0);
  if (alpha == 0) return (t < .5 ? from : to).withValues(alpha: 0);
  double channel(double x, double y) =>
      ((x * from.a + (y * to.a - x * from.a) * t) / alpha).clamp(0.0, 1.0);
  return Color.from(
    alpha: alpha,
    red: channel(from.r, to.r),
    green: channel(from.g, to.g),
    blue: channel(from.b, to.b),
    colorSpace: to.colorSpace,
  );
}

/// A [Tween] of colours that lerps with [lerpColorThroughAlpha], for a
/// `TweenAnimationBuilder` that fades a fill in from nothing.
class MotionColorTween extends Tween<Color?> {
  /// Creates a colour tween. A null side is fully transparent.
  MotionColorTween({super.begin, super.end});

  @override
  Color? lerp(double t) => lerpColorThroughAlpha(begin, end, t);
}

/// Rebuilds with [color] whenever it changes, fading from the colour it had
/// over [duration].
///
/// The colour starts on [color] without animating, a change mid-fade carries
/// on from where the fade is, and a null or transparent colour fades as
/// opacity only (see [lerpColorThroughAlpha]). A zero [duration] changes it
/// at once.
///
/// So does a change of theme: a colour that is different because the theme
/// is (see [ThemeChange]) is taken at once. The fade is for a change of
/// state; an app that changes theme transitions as a whole, and a fill
/// chasing it would rebuild its subtree on every frame of that for nothing.
class AnimatedColorBuilder extends StatefulWidget {
  /// Creates an animated colour.
  const AnimatedColorBuilder({
    required this.color,
    required this.duration,
    required this.builder,
    this.curve = Curves.linear,
    this.child,
    super.key,
  });

  /// The colour to rest on.
  final Color? color;

  /// How long a change takes.
  final Duration duration;

  /// The curve of a change.
  final Curve curve;

  /// Builds the widget from the animated colour.
  final ValueWidgetBuilder<Color?> builder;

  /// The part of the subtree that does not depend on the colour.
  final Widget? child;

  @override
  State<AnimatedColorBuilder> createState() => _AnimatedColorBuilderState();
}

class _AnimatedColorBuilderState extends State<AnimatedColorBuilder> {
  final _theme = ThemeChange();

  @override
  Widget build(BuildContext context) {
    final target = widget.color;
    return TweenAnimationBuilder<Color?>(
      // The builder asserts a non-null end; "no colour" is transparent on
      // the way and null again once it has arrived.
      tween: MotionColorTween(end: target ?? const Color(0x00000000)),
      duration: _theme.changedFor(context) ? Duration.zero : widget.duration,
      curve: widget.curve,
      builder: (context, value, child) => widget.builder(
        context,
        target == null && (value == null || value.a == 0) ? null : value,
        child,
      ),
      child: widget.child,
    );
  }
}

/// Tells an implicit animation whether the build it is in was caused by a
/// change of theme.
///
/// A `State` keeps one and asks [changedFor] once per build (or per
/// `didUpdateWidget`). It answers true when the theme above is not the one
/// it saw the time before — the moment to take new colours at once instead
/// of fading to them.
class ThemeChange {
  ThemeData? _seen;
  bool _asked = false;

  /// Whether the theme above [context] has changed since this was last
  /// asked. False the first time. Does not make [context] depend on the
  /// theme: a widget whose colours come from it is rebuilt by whoever
  /// passes them.
  bool changedFor(BuildContext context) {
    final theme = Theme.maybeOf(context, listen: false);
    final seen = _seen;
    final first = !_asked;
    _asked = true;
    _seen = theme;
    if (first || identical(theme, seen)) return false;
    // Two equal themes are one theme: an app that builds its `ThemeData`
    // inline has a new instance on every rebuild.
    return theme != seen;
  }
}
