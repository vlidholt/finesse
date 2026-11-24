import 'package:finesse/src/theme/motion.dart';
import 'package:flutter/widgets.dart';

/// Brings new content in with a short fade and a slide from the side it
/// comes from, whenever [value] changes: the month of a calendar, the page
/// of a pager, the step of a wizard.
///
/// The widget does not keep the old content around. The new [child] takes
/// its place at once, in layout, and only *paints* part-way in — faded, and
/// offset by [offset] logical pixels — so nothing around it moves and a
/// change mid-transition simply starts again from the content now showing.
///
/// The direction follows the values: one that compares greater than the last
/// comes in from the end side (the right, in a left-to-right layout), a
/// smaller one from the start. Give [direction] to decide it yourself, or
/// for values that are not [Comparable].
///
/// ```dart
/// ContentSwitch(
///   value: month.year * 12 + month.month,
///   child: MonthGrid(month),
/// )
/// ```
///
/// Nothing plays on first build, and with reduced motion the slide is
/// dropped and a short fade is left.
class ContentSwitch extends StatefulWidget {
  /// Creates a transition that plays when [value] changes.
  const ContentSwitch({
    required this.value,
    required this.child,
    this.direction,
    this.axis = Axis.horizontal,
    this.offset,
    this.duration,
    this.curve,
    super.key,
  });

  /// What the content stands for. A change — by `==` — plays the transition.
  final Object value;

  /// Which side the new content comes from: positive for the end (or the
  /// bottom, on a vertical [axis]), negative for the start, 0 for a plain
  /// fade. Null compares [value] with the previous one.
  final int? direction;

  /// The axis the content slides along.
  final Axis axis;

  /// How far the content slides, in logical pixels. Defaults to twice the
  /// theme's `Motion.overlayTravel`.
  final double? offset;

  /// How long the transition takes. Defaults to the theme's `Motion.normal`.
  final Duration? duration;

  /// The curve of the transition. Defaults to the theme's
  /// `Motion.emphasized`.
  final Curve? curve;

  /// The current content.
  final Widget child;

  @override
  State<ContentSwitch> createState() => _ContentSwitchState();
}

class _ContentSwitchState extends State<ContentSwitch>
    with SingleTickerProviderStateMixin {
  // At rest on 1: the content is simply there.
  late final _controller = AnimationController(vsync: this, value: 1);
  double _sign = 1;

  @override
  void didUpdateWidget(ContentSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    final previous = oldWidget.value;
    final current = widget.value;
    final direction =
        widget.direction ??
        (previous is Comparable<Object?> &&
                current.runtimeType == previous.runtimeType
            ? previous.compareTo(current) > 0
                  ? -1
                  : 1
            : 1);
    _sign = direction.sign.toDouble();
    _controller
      ..duration = widget.duration ?? Motion.of(context).normal
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final distance = motion.reduced
        ? 0.0
        : (widget.offset ?? motion.overlayTravel * 2);
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final horizontal = widget.axis == Axis.horizontal;
    final animation = _controller.drive(
      CurveTween(curve: widget.curve ?? motion.emphasized),
    );
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final travel =
              distance *
              _sign *
              (horizontal && rtl ? -1 : 1) *
              (1 - animation.value);
          return Transform.translate(
            offset: horizontal ? Offset(travel, 0) : Offset(0, travel),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
