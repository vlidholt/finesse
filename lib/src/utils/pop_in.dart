import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/utils/spring.dart';

/// Pops a small thing into view on a spring and takes it out again: a check
/// mark, a radio dot, a badge.
///
/// While [visible], the child scales up from [scale] with the theme's
/// `Motion.bouncy` — a little past its size and back — fading in over the
/// first half. With [wipe] it is also revealed from its leading edge, which
/// makes a check mark read as being drawn. Hiding it runs the same in
/// reverse on `Motion.snappy`, without the bounce, and removes the child
/// once it is gone.
///
/// It starts in the state it is built in without animating, and with
/// reduced motion it simply appears and disappears.
///
/// ```dart
/// PopIn(visible: checked, wipe: true, child: const PhosphorIcon(check))
/// ```
///
/// Only paint is animated; give the child a fixed box if the space it
/// leaves when hidden matters.
class PopIn extends StatelessWidget {
  /// Creates a pop-in around [child].
  const PopIn({
    required this.visible,
    required this.child,
    this.scale = .5,
    this.wipe = false,
    this.spring,
    this.alignment = Alignment.center,
    super.key,
  });

  /// Whether the child is shown.
  final bool visible;

  /// The scale the child grows from and shrinks to.
  final double scale;

  /// Whether the child is also revealed from its leading edge.
  final bool wipe;

  /// The spring of the entrance. Defaults to the theme's `Motion.bouncy`.
  final MotionSpring? spring;

  /// The point the child grows from.
  final AlignmentGeometry alignment;

  /// The widget to pop in.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    return SpringBuilder(
      value: visible ? 1 : 0,
      spring: visible ? (spring ?? motion.bouncy) : motion.snappy,
      builder: (context, t, child) {
        if (t <= 0) return const SizedBox.shrink();
        // One tree for the whole entrance. The fade ends half way and the
        // wipe when the spring first passes 1, then the spring overshoots
        // and comes back under it: a wrapper that was only there while it
        // had something to do would re-parent the child at each of those
        // moments, and build it from scratch each time. A full opacity and
        // a clip that is switched off cost no layer.
        final wiping = wipe && t < 1;
        return Opacity(
          opacity: (t * 2).clamp(0.0, 1.0),
          child: ClipRect(
            clipper: wiping ? _WipeClipper(t, direction) : null,
            clipBehavior: wiping ? Clip.hardEdge : Clip.none,
            child: Transform.scale(
              scale: scale + (1 - scale) * t,
              alignment: alignment,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _WipeClipper extends CustomClipper<Rect> {
  const _WipeClipper(this.fraction, this.direction);

  final double fraction;
  final TextDirection direction;

  @override
  Rect getClip(Size size) {
    final width = size.width * fraction;
    return direction == TextDirection.ltr
        ? Rect.fromLTWH(0, 0, width, size.height)
        : Rect.fromLTWH(size.width - width, 0, width, size.height);
  }

  @override
  bool shouldReclip(_WipeClipper oldClipper) =>
      oldClipper.fraction != fraction || oldClipper.direction != direction;
}

/// Gives its child a quick pop — up in scale and back — whenever [value]
/// changes: a counter that ticked, a status that flipped.
///
/// Nothing plays when it is first built. The pop is one spring impulse on
/// the theme's `Motion.bouncy`, and it is paint only. A second change
/// mid-pop pushes the child back up to the top of the pop rather than
/// starting over or adding a whole pop on top, so a value that changes many
/// times a second holds the child at its peak and lets it go when the
/// changes stop. With reduced motion there is no pop.
///
/// ```dart
/// PopOnChange(value: unread, child: Text('$unread'))
/// ```
class PopOnChange extends StatefulWidget {
  /// Creates a pop that plays when [value] changes.
  const PopOnChange({
    required this.value,
    required this.child,
    this.scale,
    this.spring,
    this.alignment = Alignment.center,
    super.key,
  });

  /// What the pop watches. Compared with `==`.
  final Object? value;

  /// The scale at the top of the pop. Defaults to a growth six times the
  /// theme's press shrink (1.18 for `Motion.lively`).
  final double? scale;

  /// The spring the pop rides. Defaults to the theme's `Motion.bouncy`.
  final MotionSpring? spring;

  /// The point the child grows from.
  final AlignmentGeometry alignment;

  /// The widget that pops.
  final Widget child;

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange>
    with SingleTickerProviderStateMixin {
  // 0 at rest; about 1 at the top of a pop.
  late final _pop = SpringController(vsync: this);

  @override
  void didUpdateWidget(PopOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    final spring = widget.spring ?? Motion.of(context).bouncy;
    if (spring.isInstant) return;
    // An impulse, not a target: the speed that carries a critically damped
    // spring to 1 before it comes back to rest on 0.
    final seconds =
        spring.duration.inMicroseconds / Duration.microsecondsPerSecond;
    final kick = 2 * math.pi / seconds * math.e;
    // Mid-pop, only what is still missing to the top: impulses that added
    // up would carry a value changing every frame to several times the
    // scale that was asked for. A pop on its way up is never slowed.
    final missing = (1 - _pop.value).clamp(0.0, 1.0);
    _pop.animateTo(
      0,
      spring: spring,
      velocity: math.max(_pop.velocity, kick * missing),
    );
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final peak = widget.scale ?? 1 + (1 - motion.pressScale) * 6;
    return AnimatedBuilder(
      animation: _pop.animation,
      builder: (context, child) => Transform.scale(
        scale: 1 + (peak - 1) * _pop.value,
        alignment: widget.alignment,
        child: child,
      ),
      child: widget.child,
    );
  }
}
