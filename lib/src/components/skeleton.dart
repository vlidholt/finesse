import 'package:flutter/widgets.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';

/// {@template Skeleton}
/// A placeholder shown while content is loading.
///
/// Mirrors shadcn/ui's `Skeleton`: a muted, rounded block that pulses. Give it
/// a size the way you would any box — with a [SizedBox], a [width]/[height],
/// or by letting it fill its parent.
///
/// ```dart
/// const Skeleton(width: 200, height: 16)
/// ```
///
/// Wrap real content once it has loaded rather than nesting it inside the
/// skeleton; a skeleton is a stand-in, not a container.
/// {@endtemplate}
class Skeleton extends StatefulWidget {
  /// {@macro Skeleton}
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.color,
    this.highlightColor,
    this.borderRadius,
    this.duration,
    this.curve,
    this.animate,
    this.shimmer,
    this.child,
  });

  /// A circular skeleton, useful as an avatar placeholder.
  const Skeleton.circle({
    super.key,
    required double size,
    this.color,
    this.highlightColor,
    this.duration,
    this.curve,
    this.animate,
    this.shimmer,
    this.child,
  }) : width = size,
       height = size,
       borderRadius = const BorderRadius.all(Radius.circular(9999));

  /// The width of the skeleton. Null means "as wide as the parent allows".
  final double? width;

  /// The height of the skeleton.
  final double? height;

  /// {@template Skeleton.color}
  /// The base color of the skeleton.
  /// {@endtemplate}
  final Color? color;

  /// {@template Skeleton.highlightColor}
  /// The color the skeleton pulses towards.
  /// {@endtemplate}
  final Color? highlightColor;

  /// {@template Skeleton.borderRadius}
  /// The corner radius of the skeleton.
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadius;

  /// {@template Skeleton.duration}
  /// The duration of one full pulse.
  /// {@endtemplate}
  final Duration? duration;

  /// {@template Skeleton.curve}
  /// The curve of the pulse.
  /// {@endtemplate}
  final Curve? curve;

  /// {@template Skeleton.animate}
  /// Whether the skeleton pulses, defaults to `true`.
  ///
  /// It never animates when the platform asks for reduced motion
  /// (`MediaQuery.disableAnimationsOf`) or the theme's motion is switched
  /// off. Set it to `false` in tests and goldens, where a running animation
  /// would be a source of flake.
  /// {@endtemplate}
  final bool? animate;

  /// {@macro Skeleton.shimmer}
  final bool? shimmer;

  /// An optional child laid out inside the skeleton, used to size it.
  ///
  /// The child is hidden from both painting and semantics — it is only there
  /// to give the placeholder the shape of the content it stands in for.
  final Widget? child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  bool _animating = false;
  bool _shimmering = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(Skeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate ||
        widget.shimmer != oldWidget.shimmer ||
        widget.duration != oldWidget.duration) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final theme = Theme.of(context);
    _controller.duration =
        widget.duration ??
        theme.skeletonTheme.duration ??
        const Duration(milliseconds: 1500);

    // A placeholder that moves for as long as it is on screen is exactly
    // what a reduced-motion setting asks to be spared.
    final motion = Motion.of(context);
    final shouldAnimate =
        (widget.animate ?? theme.skeletonTheme.animate ?? true) &&
        !motion.reduced;
    final shimmers =
        widget.shimmer ?? theme.skeletonTheme.shimmer ?? motion.shimmer;
    if (shouldAnimate == _animating && shimmers == _shimmering) return;
    _animating = shouldAnimate;
    _shimmering = shimmers;
    if (shouldAnimate) {
      // A pulse goes there and back; a shimmer sweeps one way and starts
      // again.
      _controller.repeat(reverse: !shimmers);
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final skeletonTheme = theme.skeletonTheme;

    final effectiveColor =
        widget.color ?? skeletonTheme.color ?? theme.colorScheme.muted;
    final effectiveHighlightColor =
        widget.highlightColor ??
        skeletonTheme.highlightColor ??
        effectiveColor.withValues(alpha: .4);
    final effectiveRadius =
        widget.borderRadius ?? skeletonTheme.borderRadius ?? theme.radius;
    final effectiveCurve =
        widget.curve ?? skeletonTheme.curve ?? Curves.easeInOut;

    // The placeholder conveys nothing to a screen reader beyond "loading",
    // which the surrounding content is responsible for announcing.
    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = effectiveCurve.transform(_controller.value);
            if (_shimmering && _animating) {
              // A band of the highlight, one box wide, travelling from
              // just off the leading edge to just off the trailing one.
              final x = -3 + 4 * t;
              final sign = Directionality.maybeOf(context) == TextDirection.rtl
                  ? -1.0
                  : 1.0;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(sign * x, 0),
                    end: Alignment(sign * (x + 2), 0),
                    colors: [
                      effectiveColor,
                      effectiveHighlightColor,
                      effectiveColor,
                    ],
                  ),
                  borderRadius: effectiveRadius,
                ),
                child: child,
              );
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Color.lerp(
                  effectiveColor,
                  effectiveHighlightColor,
                  t,
                ),
                borderRadius: effectiveRadius,
              ),
              child: child,
            );
          },
          child: widget.child == null
              ? null
              : Visibility.maintain(
                  visible: false,
                  child: widget.child!,
                ),
        ),
      ),
    );
  }
}
