import 'package:flutter/widgets.dart';

/// Lerps between two colours without passing through a darker one when a
/// side is missing or fully transparent.
///
/// `Color.lerp` treats "no colour" as transparent *black*, so a fill fading
/// in over a light surface is grey halfway — the dark flash of a hover
/// state. Here a null or zero-alpha side takes the other side's colour at
/// zero alpha, so only the opacity changes.
Color? lerpColorThroughAlpha(Color? a, Color? b, double t) {
  final from = a == null || a.a == 0 ? b?.withValues(alpha: 0) : a;
  final to = b == null || b.a == 0 ? a?.withValues(alpha: 0) : b;
  return Color.lerp(from, to, t);
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
class AnimatedColorBuilder extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final target = color;
    return TweenAnimationBuilder<Color?>(
      // The builder asserts a non-null end; "no colour" is transparent on
      // the way and null again once it has arrived.
      tween: MotionColorTween(end: target ?? const Color(0x00000000)),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => builder(
        context,
        target == null && (value == null || value.a == 0) ? null : value,
        child,
      ),
      child: child,
    );
  }
}
