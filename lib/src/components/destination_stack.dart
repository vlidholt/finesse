import 'package:flutter/widgets.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';

/// The pages of an app's destinations, one showing at a time, each kept
/// alive once it has been visited: its scroll offset, its half-filled form
/// and its own navigation are there when the user comes back.
///
/// ```dart
/// NavigationScaffold(
///   destinations: destinations,
///   selectedIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
///   body: DestinationStack(
///     index: index,
///     builders: [
///       (context) => const HomePage(),
///       (context) => const SearchPage(),
///       (context) => const ProfilePage(),
///     ],
///   ),
/// )
/// ```
///
/// A destination is built the first time it is shown, not before. While
/// another one shows, it is off stage: not painted, out of the focus order,
/// unread by a screen reader, and its animations stand still.
///
/// A change of [index] brings the new page in out of the page colour while
/// it slides a few pixels from the side its destination is on — the theme's
/// `Motion.normal`. Only the page coming in moves, and only its paint: it
/// is laid out and takes input from the first frame. The page is never made
/// translucent, which glass inside it would not survive; a wash of the page
/// colour over it fades out instead. With reduced motion the slide is
/// dropped, and with `Motion.none` the page is simply there.
///
/// For each destination to have its own stack of pushed pages, make each
/// builder return a `Navigator`, or use a router package's shell.
class DestinationStack extends StatefulWidget {
  /// Creates a stack of destinations showing the one at [index].
  const DestinationStack({
    required this.index,
    required this.builders,
    this.axis = Axis.horizontal,
    super.key,
  });

  /// The destination that shows.
  final int index;

  /// Builds each destination's page, in the order of the destinations.
  final List<WidgetBuilder> builders;

  /// The axis a page slides in along: horizontal for a bottom or a top
  /// bar, vertical for a rail, whose destinations are one above the other.
  final Axis axis;

  @override
  State<DestinationStack> createState() => _DestinationStackState();
}

class _DestinationStackState extends State<DestinationStack>
    with SingleTickerProviderStateMixin {
  /// How strongly the wash covers the page when the switch begins. Never
  /// all the way: a frame of bare background reads as a flash.
  static const _wash = .6;

  // At rest on 1: the page is simply there.
  late final _controller = AnimationController(vsync: this, value: 1);

  /// The destinations that have been shown, and so are built.
  late final _visited = <int>{widget.index};

  // +1 when the page now showing is after the previous one, -1 before.
  double _sign = 1;

  @override
  void didUpdateWidget(DestinationStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visited.removeWhere((index) => index >= widget.builders.length);
    if (widget.index == oldWidget.index) return;
    _visited.add(widget.index);
    _sign = widget.index > oldWidget.index ? 1 : -1;
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
    final color = theme.colorScheme.background;

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
          // A layer of its own, so a frame of the slide moves the page
          // rather than painting it.
          child: RepaintBoundary(
            child: IndexedStack(
              index: widget.index,
              sizing: StackFit.passthrough,
              children: [
                for (var i = 0; i < widget.builders.length; i++)
                  if (_visited.contains(i))
                    // An `IndexedStack` hides the others from paint, focus
                    // and `Visibility.of`, but leaves their tickers running.
                    TickerMode(
                      enabled: i == widget.index,
                      child: Builder(builder: widget.builders[i]),
                    )
                  else
                    const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        // The wash. It takes no pointers, so the page under it is live from
        // the first frame. One rectangle painted at the wash's opacity: a
        // `FadeTransition` around a `ColoredBox` would composite a layer
        // the size of the page to draw it.
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: progress,
                builder: (context, _) => ColoredBox(
                  color: color.withValues(
                    alpha: color.a * _wash * (1 - progress.value),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
