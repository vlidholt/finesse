import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:finesse/src/components/navigation_bar.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/arrow_key_focus.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

/// The destinations of an app down the start edge of a wide screen: an
/// icon over a small label, with a line beside the selected one.
///
/// ```dart
/// Row(
///   children: [
///     NavigationRail(
///       selectedIndex: index,
///       onDestinationSelected: (i) => setState(() => index = i),
///       destinations: destinations,
///     ),
///     Expanded(child: pages[index]),
///   ],
/// )
/// ```
///
/// It is the middle ground between a `BottomNavigationBar` on a phone and
/// a `NavigationBar` across the top of a desktop window: a tablet, or a
/// desktop app whose top bar is busy. `NavigationScaffold` places one with
/// `NavigationLayout.rail`.
///
/// With [extended] the labels sit beside the icons and the rail is as wide
/// as a narrow sidebar; changing it morphs one arrangement into the other
/// on the theme's `Motion.smooth`. The line beside the selected destination
/// is one shape that travels, as it does in the other bars.
///
/// The rail has the bars' fill — translucent in a glass style, though not
/// frosted: it lies beside the page, not over it, unless its theme gives it
/// a `blur` — with a hairline along its inner edge, and keeps clear of
/// the safe area. Destinations that do not fit scroll; [leading], [action]
/// and [trailing] stay put. Up and Down move the focus between the
/// destinations.
class NavigationRail extends StatelessWidget {
  /// Creates a navigation rail.
  const NavigationRail({
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.action,
    this.extended = false,
    this.width,
    super.key,
  });

  /// The destinations, from the top.
  final List<NavigationDestination> destinations;

  /// The index of the selected destination, or null or out of range for
  /// none.
  final int? selectedIndex;

  /// Called with the index of the destination that was chosen.
  final ValueChanged<int>? onDestinationSelected;

  /// Shown at the top of the rail, above the destinations: a logo, a menu
  /// button. It is centred over the icons.
  final Widget? leading;

  /// Shown at the bottom of the rail: settings, an avatar. It is centred
  /// under the icons.
  final Widget? trailing;

  /// A primary action between [leading] and the destinations: a round
  /// button, which carries its label when the rail is [extended].
  final NavigationAction? action;

  /// Whether the labels sit beside the icons, in a wider rail.
  final bool extended;

  /// The rail's width while it is not [extended]. Defaults to the theme's.
  final double? width;

  /// The width a [NavigationRail] takes in [context], including the safe
  /// area at the start edge and its hairline.
  static double widthOf(BuildContext context, {bool extended = false}) {
    final rail = Theme.of(context).navigationRailTheme;
    final padding = MediaQuery.paddingOf(context);
    final inset = Directionality.of(context) == TextDirection.rtl
        ? padding.right
        : padding.left;
    return (extended ? rail.extendedWidth ?? 220 : rail.width ?? 72) +
        inset +
        1;
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return SpringBuilder(
      value: extended ? 1 : 0,
      spring: motion.smooth,
      builder: (context, value, _) => _Rail(
        rail: this,
        // A smooth spring does not overshoot; this is for one that does.
        t: value.clamp(0.0, 1.0),
      ),
    );
  }
}

/// The rail, [t] of the way from icons-over-labels to labels-beside-icons.
class _Rail extends StatelessWidget {
  const _Rail({required this.rail, required this.t});

  final NavigationRail rail;
  final double t;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.navigationRailTheme;
    final compact = rail.width ?? style.width ?? 72;
    final wide = math.max(style.extendedWidth ?? 220, compact);
    final width = lerpDouble(compact, wide, t)!;
    final safe = MediaQuery.paddingOf(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final edge = style.padding ?? 8;
    final gap = theme.layoutTheme.gap(GapSize.sm);
    final selected = rail.selectedIndex;

    Widget slot(Widget child) => SizedBox(
      width: width,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: compact,
          child: Center(child: child),
        ),
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Backdrop(
        blur: style.blur ?? 0,
        saturation: style.saturation ?? 1,
        child: Container(
          // The hairline is added to the width rather than taken from it.
          width: width + (rtl ? safe.right : safe.left) + 1,
          padding: EdgeInsetsDirectional.only(
            start: rtl ? safe.right : safe.left,
            top: safe.top + edge,
            bottom: safe.bottom + edge,
          ),
          decoration: BoxDecoration(
            color: style.backgroundColor ?? theme.colorScheme.card,
            border: BorderDirectional(
              end: BorderSide(
                color: style.borderColor ?? theme.colorScheme.border,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (rail.leading != null) ...[
                slot(rail.leading!),
                SizedBox(height: gap),
              ],
              if (rail.action != null) ...[
                _RailAction(
                  action: rail.action!,
                  t: t,
                  width: width,
                  compact: compact,
                ),
                SizedBox(height: gap),
              ],
              Expanded(
                // The destinations scroll when the rail is too short for
                // them; the line is inside, so it scrolls along.
                child: SingleChildScrollView(
                  child: ArrowKeyFocus(
                    child: FocusTraversalGroup(
                      child: MovingIndicator(
                        position: DecorationPosition.foreground,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final (index, destination)
                                in rail.destinations.indexed)
                              _RailItem(
                                destination: destination,
                                selected: index == selected,
                                onPressed: rail.onDestinationSelected == null
                                    ? null
                                    : () => rail.onDestinationSelected!(index),
                                t: t,
                                width: width,
                                compact: compact,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (rail.trailing != null) ...[
                SizedBox(height: gap),
                slot(rail.trailing!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// How tall one line of [style] is at the ambient text scale.
double _lineHeight(BuildContext context, TextStyle style) {
  final size = style.fontSize ?? 14;
  return MediaQuery.textScalerOf(context).scale(size) * (style.height ?? 1.2);
}

/// One destination. The icon keeps its place over the middle of the narrow
/// rail in both arrangements and only moves up or down; the label under it
/// fades out as the one beside it fades in.
class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.selected,
    required this.onPressed,
    required this.t,
    required this.width,
    required this.compact,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback? onPressed;
  final double t;
  final double width;
  final double compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.navigationRailTheme;
    final motion = Motion.of(context);
    final scheme = theme.colorScheme;
    final iconSize = style.iconSize ?? 24;
    final gap = style.gap ?? 4;
    final labelStyle = style.labelStyle ?? theme.textTheme.caption;
    final wideLabelStyle = style.extendedLabelStyle ?? theme.textTheme.small;
    final labelLine = _lineHeight(context, labelStyle);
    final wideLine = _lineHeight(context, wideLabelStyle);
    // A style height is a floor: scaled text makes the item taller.
    final block = iconSize + gap + labelLine;
    final tall = math.max(style.itemHeight ?? 64, block + 4 * gap);
    final short = math.max(
      style.extendedItemHeight ?? 44,
      math.max(iconSize, wideLine) + 2 * gap,
    );
    final height = lerpDouble(tall, short, t)!;
    final iconTop = lerpDouble((tall - block) / 2, (short - iconSize) / 2, t)!;
    final inset = style.indicatorInset ?? 12;
    final indicatorWidth = style.indicatorWidth ?? 3;
    final badge = destination.badgeCount ?? 0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Pressable(
              selected: selected,
              onPressed: onPressed,
              semanticLabel: destination.label,
              semanticValue: badge > 0 ? '$badge' : null,
              builder: (context, states) {
                final hovered = states.contains(WidgetState.hovered);
                final rest = style.foregroundColor ?? scheme.mutedForeground;
                final hover = style.hoverColor ?? scheme.foreground;
                final iconColor = selected
                    ? style.selectedIconColor ?? scheme.tint
                    : hovered
                    ? hover
                    : rest;
                final labelColor = selected
                    ? style.selectedLabelColor ?? scheme.foreground
                    : hovered
                    ? hover
                    : rest;
                return FocusRing(
                  visible: states.contains(WidgetState.focused),
                  borderRadius: theme.radius,
                  // The rail clips when it has a backdrop blur.
                  inset: true,
                  child: AnimatedColorBuilder(
                    color: labelColor,
                    duration: motion.fast,
                    curve: motion.standard,
                    builder: (context, color, _) => Stack(
                      children: [
                        PositionedDirectional(
                          start: 0,
                          width: compact,
                          top: iconTop,
                          height: iconSize,
                          child: Center(
                            child: badgedDestinationIcon(
                              destination,
                              DestinationIcon(
                                selected: selected,
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                color: iconColor,
                                size: iconSize,
                              ),
                              const Offset(4, 0),
                            ),
                          ),
                        ),
                        if (t < 1)
                          PositionedDirectional(
                            start: 2,
                            width: compact - 4,
                            top: iconTop + iconSize + gap,
                            child: Opacity(
                              opacity: 1 - t,
                              child: Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: labelStyle.copyWith(color: color),
                              ),
                            ),
                          ),
                        if (t > 0)
                          PositionedDirectional(
                            start: compact / 2 + iconSize / 2 + 3 * gap,
                            end: 3 * gap,
                            top: 0,
                            bottom: 0,
                            child: Opacity(
                              opacity: t,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  destination.label,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: wideLabelStyle.copyWith(color: color),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Where the line goes when this destination is selected. It is
          // painted once, by the rail, and travels. Outside the pressable,
          // so a press does not shrink its end of the line.
          PositionedDirectional(
            start: 0,
            top: math.min(inset, height / 4),
            bottom: math.min(inset, height / 4),
            width: indicatorWidth,
            child: IgnorePointer(
              child: MovingIndicatorTarget(
                selected: selected,
                decoration: BoxDecoration(
                  color: style.indicatorColor ?? scheme.tint,
                  borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(indicatorWidth),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The rail's primary action: a round button under the leading widget,
/// which grows into a pill with its label as the rail extends.
class _RailAction extends StatelessWidget {
  const _RailAction({
    required this.action,
    required this.t,
    required this.width,
    required this.compact,
  });

  final NavigationAction action;
  final double t;
  final double width;
  final double compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.navigationRailTheme;
    final scheme = theme.colorScheme;
    final size = style.actionSize ?? 44;
    final margin = math.max<double>((compact - size) / 2, 0);
    final background = style.actionBackgroundColor ?? scheme.primary;
    final foreground = style.actionForegroundColor ?? scheme.primaryForeground;
    final labelStyle = (style.extendedLabelStyle ?? theme.textTheme.small)
        .copyWith(color: foreground, fontWeight: FontWeight.w600);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          PositionedDirectional(
            start: margin,
            width: math.max(width - 2 * margin, size),
            top: 0,
            bottom: 0,
            child: Pressable(
              onPressed: action.onPressed,
              semanticLabel: action.label,
              builder: (context, states) {
                final hovered = states.contains(WidgetState.hovered);
                return FocusRing(
                  visible: states.contains(WidgetState.focused),
                  borderRadius: theme.radii.full,
                  child: AnimatedFill(
                    color: hovered
                        ? Color.alphaBlend(
                            foreground.withValues(alpha: .12),
                            background,
                          )
                        : background,
                    borderRadius: theme.radii.full,
                    child: Stack(
                      children: [
                        PositionedDirectional(
                          start: 0,
                          width: size,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: IconTheme.merge(
                              data: IconThemeData(
                                size: (style.iconSize ?? 24) - 4,
                                color: foreground,
                              ),
                              child: ExcludeSemantics(child: action.icon),
                            ),
                          ),
                        ),
                        if (t > 0)
                          PositionedDirectional(
                            start: size - 4,
                            end: size / 3,
                            top: 0,
                            bottom: 0,
                            child: Opacity(
                              opacity: t,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  action.label,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: labelStyle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
