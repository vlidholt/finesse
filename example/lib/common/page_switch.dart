import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Brings a page in when [value] changes: it rises out of the page colour
/// while it slides a few pixels in from the side it comes from.
///
/// It is the transition between Strand's destinations, between Strand and
/// the component library, and between the pages of the docs browser. Like
/// the package's `ContentSwitch` it only animates what comes *in* — [child]
/// is in its place, laid out and interactive, from the first frame — and
/// only paints.
///
/// The difference is how it fades. A page is full of glass, and a backdrop
/// filter under an opacity layer loses its backdrop while the layer fades
/// (see "Floating surfaces are glass too" in the repository's notes). So
/// the page is never made translucent: a cover in the page's own colour
/// lies over it and fades *out*. On a page that is that colour underneath —
/// every page here — the two look the same.
///
/// The cover never hides the page completely, either. The old page is gone
/// the moment the new one is switched to, and a frame of bare background
/// between the two reads as a flash; so the new page is there from the
/// first frame, washed out, and clears from that.
///
/// The direction follows the values: one that compares greater than the
/// last comes from the end side (or from below, on a vertical [axis]), a
/// smaller one from the start. With reduced motion the slide is dropped and
/// a short fade is left; with `Motion.none` nothing plays.
class PageSwitch extends StatefulWidget {
  const PageSwitch({
    required this.value,
    required this.child,
    this.axis = Axis.horizontal,
    this.color,
    super.key,
  });

  /// What the page stands for: an index, so its order gives the direction.
  final int value;

  /// The axis the page slides along.
  final Axis axis;

  /// The colour the page rises out of. Defaults to the theme's background.
  final Color? color;

  /// The page. It should keep its own state across a switch — an
  /// `IndexedStack`, say — because this widget keeps nothing.
  final Widget child;

  @override
  State<PageSwitch> createState() => _PageSwitchState();
}

class _PageSwitchState extends State<PageSwitch>
    with SingleTickerProviderStateMixin {
  /// How strongly the cover washes the page out when the switch begins.
  static const _coverOpacity = .6;

  // At rest on 1: the page is simply there.
  late final _controller = AnimationController(vsync: this, value: 1);
  double _sign = 1;

  @override
  void didUpdateWidget(PageSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) return;
    _sign = widget.value > oldWidget.value ? 1 : -1;
    final duration = Motion.of(context).normal;
    if (duration == Duration.zero) return;
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    final distance = motion.reduced ? 0.0 : motion.overlayTravel * 2;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final horizontal = widget.axis == Axis.horizontal;
    final progress = _controller.drive(CurveTween(curve: motion.emphasized));
    return Stack(
      fit: StackFit.passthrough,
      children: [
        AnimatedBuilder(
          animation: progress,
          builder: (context, child) {
            final travel =
                distance *
                _sign *
                (horizontal && rtl ? -1 : 1) *
                (1 - progress.value);
            return Transform.translate(
              offset: horizontal ? Offset(travel, 0) : Offset(0, travel),
              child: child,
            );
          },
          child: widget.child,
        ),
        // The cover. It takes no pointers, so the page under it is live
        // from the first frame.
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: ReverseAnimation(
                progress,
              ).drive(Tween(begin: 0, end: _coverOpacity)),
              child: ColoredBox(
                color: widget.color ?? theme.colorScheme.background,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
