import 'package:flutter/widgets.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/skeleton_paint.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';

/// The shapes a [Skeleton] block can take from the theme.
enum _SkeletonShape { box, circle, avatar, button, chip }

/// {@template Skeleton}
/// A placeholder shown while content is loading.
///
/// A muted, rounded block that shimmers — a soft band of light sweeping
/// across it — in the `una` style, and pulses in the shadcn ones. Give it a
/// size the way you would any box — with a [SizedBox], a [width]/[height],
/// or by letting it fill its parent.
///
/// ```dart
/// const Skeleton(width: 200, height: 16)
/// ```
///
/// Every skeleton on screen moves to one clock, and the shimmer's band is
/// laid across the whole screen: a column of lines, an avatar beside them
/// and a card below shimmer as one surface, the band passing over each in
/// turn. The block is painted, not built, in a layer of its own; under
/// reduced motion it holds still.
///
/// The named constructors take their size and corners from the component
/// they stand in for — [Skeleton.avatar], [Skeleton.button],
/// [Skeleton.chip] — and `SkeletonText`, `SkeletonListTile`, `SkeletonCard`,
/// `SkeletonChatBubble` and `SkeletonTableRow` lay out whole placeholders
/// in the theme's own metrics.
///
/// Swap the real content in once it has loaded rather than nesting it
/// inside the skeleton; a skeleton is a stand-in, not a container.
/// {@endtemplate}
class Skeleton extends StatelessWidget {
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
  }) : _shape = _SkeletonShape.box,
       _buttonSize = null;

  /// A circular skeleton [size] across.
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
       borderRadius = null,
       _shape = _SkeletonShape.circle,
       _buttonSize = null;

  /// The placeholder of an `Avatar`: a circle the size the avatar theme
  /// gives one, or [size] across.
  const Skeleton.avatar({
    super.key,
    double? size,
    this.color,
    this.highlightColor,
    this.duration,
    this.curve,
    this.animate,
    this.shimmer,
  }) : width = size,
       height = size,
       borderRadius = null,
       child = null,
       _shape = _SkeletonShape.avatar,
       _buttonSize = null;

  /// The placeholder of a `Button` of [size]: its height and corners, and
  /// [width] wide (88 by default).
  const Skeleton.button({
    super.key,
    this.width,
    ButtonSize size = ButtonSize.regular,
    this.color,
    this.highlightColor,
    this.duration,
    this.curve,
    this.animate,
    this.shimmer,
  }) : height = null,
       borderRadius = null,
       child = null,
       _shape = _SkeletonShape.button,
       _buttonSize = size;

  /// The placeholder of a `Chip`: its height and corners, and [width] wide
  /// (72 by default).
  const Skeleton.chip({
    super.key,
    this.width,
    this.color,
    this.highlightColor,
    this.duration,
    this.curve,
    this.animate,
    this.shimmer,
  }) : height = null,
       borderRadius = null,
       child = null,
       _shape = _SkeletonShape.chip,
       _buttonSize = null;

  /// The width of the skeleton. Null means "as wide as the parent allows".
  final double? width;

  /// The height of the skeleton.
  final double? height;

  /// {@template Skeleton.color}
  /// The base color of the skeleton.
  /// {@endtemplate}
  final Color? color;

  /// {@template Skeleton.highlightColor}
  /// The colour of the shimmer's band, or the colour a pulse fades to.
  /// {@endtemplate}
  final Color? highlightColor;

  /// {@template Skeleton.borderRadius}
  /// The corner radius of the skeleton.
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadius;

  /// {@template Skeleton.duration}
  /// The duration of one pulse, or of one pass of the shimmer with the
  /// pause after it.
  /// {@endtemplate}
  final Duration? duration;

  /// {@template Skeleton.curve}
  /// The curve of the pulse, or of the shimmer's travel.
  /// {@endtemplate}
  final Curve? curve;

  /// {@template Skeleton.animate}
  /// Whether the skeleton moves, defaults to `true`.
  ///
  /// It never moves when the platform asks for reduced motion
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

  final _SkeletonShape _shape;
  final ButtonSize? _buttonSize;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final skeletonTheme = theme.skeletonTheme;
    final motion = Motion.of(context);

    final effectiveColor =
        color ?? skeletonTheme.color ?? theme.colorScheme.muted;
    final effectiveHighlightColor =
        highlightColor ??
        skeletonTheme.highlightColor ??
        effectiveColor.withValues(alpha: effectiveColor.a * .4);

    var effectiveWidth = width;
    var effectiveHeight = height;
    final BorderRadiusGeometry effectiveRadius;
    switch (_shape) {
      case _SkeletonShape.box:
        effectiveRadius =
            borderRadius ?? skeletonTheme.borderRadius ?? theme.radius;
      case _SkeletonShape.circle:
        effectiveRadius = theme.radii.full;
      case _SkeletonShape.avatar:
        final side = width ?? theme.avatarTheme.size?.shortestSide ?? 40;
        effectiveWidth = side;
        effectiveHeight = side;
        effectiveRadius = theme.radii.full;
      case _SkeletonShape.button:
        final sizes = theme.buttonSizesTheme;
        final metrics = switch (_buttonSize!) {
          ButtonSize.regular => sizes.regular,
          ButtonSize.sm => sizes.sm,
          ButtonSize.lg => sizes.lg,
        };
        effectiveWidth = width ?? 88;
        effectiveHeight = metrics?.height ?? 36;
        effectiveRadius = theme.radii.resolve(theme.style.buttonRadius);
      case _SkeletonShape.chip:
        effectiveWidth = width ?? 72;
        effectiveHeight = theme.chipTheme.height ?? 32;
        effectiveRadius = theme.chipTheme.borderRadius ?? theme.radii.full;
    }

    // A placeholder that moves for as long as it is on screen is exactly
    // what a reduced-motion setting asks to be spared.
    final moves = (animate ?? skeletonTheme.animate ?? true) && !motion.reduced;
    final shimmers = shimmer ?? skeletonTheme.shimmer ?? motion.shimmer;

    // The placeholder conveys nothing to a screen reader beyond "loading",
    // which the surrounding content is responsible for announcing.
    return ExcludeSemantics(
      child: SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: SkeletonPaint(
          color: effectiveColor,
          highlightColor: effectiveHighlightColor,
          borderRadius: effectiveRadius,
          motion: !moves
              ? SkeletonMotion.still
              : shimmers
              ? SkeletonMotion.shimmer
              : SkeletonMotion.pulse,
          period:
              duration ??
              skeletonTheme.duration ??
              const Duration(milliseconds: 1800),
          curve: curve ?? skeletonTheme.curve ?? Curves.easeInOut,
          child: child == null
              ? null
              : Visibility.maintain(visible: false, child: child!),
        ),
      ),
    );
  }
}
