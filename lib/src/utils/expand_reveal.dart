import 'package:flutter/widgets.dart';

/// Shows [factor] of its child's height, from the top, with the child
/// fading in as it is uncovered: the body of an accordion or a collapsible
/// part-way open.
///
/// At 0 the child takes no height and is invisible; at 1 it is laid out and
/// painted as it is. In between its height grows while it fades in and
/// settles [travel] logical pixels down into place. Drive [factor] with a
/// `SpringBuilder` or an animation; a value past 1 (a spring overshooting)
/// is treated as 1.
///
/// The height is laid out on every change, as any change of size must be;
/// the fade and the slide are paint only.
class ExpandReveal extends StatelessWidget {
  /// Creates a partly revealed [child].
  const ExpandReveal({
    required this.factor,
    required this.child,
    this.travel = 0,
    this.fade = true,
    this.alignment = AlignmentDirectional.topStart,
    super.key,
  });

  /// How much of the child's height shows, from 0 to 1.
  final double factor;

  /// How far above its place the child starts, in logical pixels.
  final double travel;

  /// Whether the child fades in as it is revealed.
  final bool fade;

  /// The edge the child is anchored to while it is cut off.
  final AlignmentGeometry alignment;

  /// The widget to reveal.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = factor.clamp(0.0, 1.0);
    // The same widgets at every factor, so the child's state survives the
    // whole transition; fully open, each of them is a no-op.
    return ClipRect(
      clipBehavior: t < 1 ? Clip.hardEdge : Clip.none,
      child: Align(
        alignment: alignment,
        heightFactor: t,
        child: Opacity(
          // The first sliver of height shows nothing readable anyway; the
          // fade runs over the rest.
          opacity: fade ? ((t - .15) / .85).clamp(0.0, 1.0) : 1,
          child: Transform.translate(
            offset: Offset(0, -travel * (1 - t)),
            child: child,
          ),
        ),
      ),
    );
  }
}
