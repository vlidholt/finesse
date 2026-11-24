import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:flutter/rendering.dart' show OverflowBoxFit;
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
    this.overhang = .35,
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

  /// How far the badge hangs outside the corner it is pinned to, as a
  /// fraction of its own size. The default suits a count on an icon; 0 keeps
  /// the badge inside [child]'s bounds, flush with the corner — a presence
  /// dot on a round avatar.
  final double overhang;

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
    // Built even while hidden: the badge pops out, so what it showed has to
    // stay on screen for the length of its exit.

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
    // It pops in when it appears and out when it goes, and pops once when
    // the count changes. A badge that is there from the start is simply
    // there.
    badge = PopIn(
      visible: shown,
      scale: .3,
      child: PopOnChange(value: count, child: badge),
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
              // The badge overhangs its child, so it must not be laid out
              // inside the child's size: a `99+` pill is wider than the 24px
              // icon it sits on, and squeezed into 24px it clips its own
              // digits. It keeps its natural size and stays anchored to the
              // same corner.
              child: OverflowBox(
                alignment: resolved,
                minWidth: 0,
                minHeight: 0,
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                fit: OverflowBoxFit.deferToChild,
                child: FractionalTranslation(
                  // Aligned, the badge sits inside the corner it is pinned
                  // to; push it part of the way out so it overlaps the
                  // child's edge.
                  translation: Offset(
                    resolved.x * overhang,
                    resolved.y * overhang,
                  ),
                  child: badge,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
