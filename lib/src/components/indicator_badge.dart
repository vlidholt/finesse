import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A small count or dot pinned to the corner of another widget: unread
/// messages on an icon, presence on an avatar.
///
/// ```dart
/// IndicatorBadge(
///   count: 3,
///   child: const Icon(PhosphorIconsRegular.chatCircleDots),
/// )
/// ```
///
/// With a [count] (or a custom [label]) the badge is a pill; with neither it
/// is a dot. A ring in the colour of the surface behind it — the theme's card
/// colour unless [ringColor] says otherwise — keeps it legible on top of
/// [child]. Without a [child] the badge is laid out on its own, which is how
/// an unread count sits at the end of a list row.
class IndicatorBadge extends StatelessWidget {
  /// Creates a badge over [child].
  const IndicatorBadge({
    this.child,
    this.count,
    this.label,
    this.maxCount = 99,
    this.showZero = false,
    this.visible = true,
    this.alignment = AlignmentDirectional.topEnd,
    this.offset = Offset.zero,
    this.color,
    this.foregroundColor,
    this.ringColor,
    this.ringWidth,
    this.size,
    this.semanticLabel,
    super.key,
  });

  /// The widget the badge is pinned to. Null lays the badge out by itself.
  final Widget? child;

  /// The number shown. Above [maxCount] it reads `99+`.
  final int? count;

  /// Content shown instead of [count].
  final Widget? label;

  /// The largest [count] shown in full.
  final int maxCount;

  /// Whether a [count] of zero still shows the badge.
  final bool showZero;

  /// Whether the badge is shown at all.
  final bool visible;

  /// The corner of [child] the badge's centre is pinned towards.
  final AlignmentGeometry alignment;

  /// A nudge from that corner, in logical pixels. Positive x moves towards
  /// the end, positive y downwards.
  final Offset offset;

  /// The badge's fill. Defaults to the theme's destructive colour.
  final Color? color;

  /// The colour of the count.
  final Color? foregroundColor;

  /// The colour of the ring around the badge.
  final Color? ringColor;

  /// The width of the ring around the badge; 0 removes it.
  final double? ringWidth;

  /// The badge's height (and a dot's diameter).
  final double? size;

  /// What assistive technology reads for the badge, such as
  /// `'3 unread messages'`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeTheme = theme.indicatorBadgeTheme;
    final hasCount = count != null && (count! > 0 || showZero);
    final isDot = label == null && count == null;
    final shown = visible && (isDot || label != null || hasCount);
    if (!shown) return child ?? const SizedBox.shrink();

    final ring = ringWidth ?? badgeTheme.ringWidth ?? 2;
    final fill =
        color ?? badgeTheme.backgroundColor ?? theme.colorScheme.destructive;
    final decoration = ShapeDecoration(
      color: fill,
      shape: StadiumBorder(
        side: ring > 0
            ? BorderSide(
                color:
                    ringColor ?? badgeTheme.ringColor ?? theme.colorScheme.card,
                width: ring,
                strokeAlign: BorderSide.strokeAlignOutside,
              )
            : BorderSide.none,
      ),
    );

    Widget badge;
    if (isDot) {
      final diameter = size ?? badgeTheme.dotSize ?? 10;
      badge = DecoratedBox(
        decoration: decoration,
        child: SizedBox.square(dimension: diameter),
      );
    } else {
      final height = size ?? badgeTheme.size ?? 18;
      final style = (badgeTheme.textStyle ?? theme.textTheme.small).copyWith(
        color:
            foregroundColor ??
            badgeTheme.foregroundColor ??
            theme.colorScheme.destructiveForeground,
      );
      badge = DecoratedBox(
        decoration: decoration,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: height, minHeight: height),
          child: Padding(
            padding:
                badgeTheme.padding ?? const EdgeInsets.symmetric(horizontal: 5),
            child: DefaultTextStyle.merge(
              style: style,
              textAlign: TextAlign.center,
              maxLines: 1,
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child:
                    label ?? Text(count! > maxCount ? '$maxCount+' : '$count'),
              ),
            ),
          ),
        ),
      );
    }
    badge = Semantics(
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: badge,
    );

    final target = child;
    if (target == null) return badge;

    final resolved = alignment.resolve(Directionality.of(context));
    final direction = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        target,
        Positioned.fill(
          child: Align(
            alignment: resolved,
            child: Transform.translate(
              offset: Offset(offset.dx * direction, offset.dy),
              child: FractionalTranslation(
                // Centre the badge on the corner it is pinned to, then pull
                // it a third of the way back in so it overlaps the child.
                translation: Offset(resolved.x * .35, resolved.y * .35),
                child: badge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
