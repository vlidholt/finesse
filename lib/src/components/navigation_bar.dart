import 'dart:ui' as ui;

import 'package:finesse/src/components/indicator_badge.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:finesse/src/utils/shadow.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:flutter/widgets.dart';

/// One place a [NavigationBar] or [BottomNavigationBar] can take the user.
@immutable
class NavigationDestination {
  /// Creates a destination.
  const NavigationDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
    this.showBadge = false,
    this.showInTopBar = true,
    this.showInBottomBar = true,
  });

  /// The icon, usually an [Icon]. Any widget works — a bottom bar's "me"
  /// destination is often an avatar.
  final Widget icon;

  /// The icon while the destination is selected, usually the filled version
  /// of [icon]. Defaults to [icon].
  final Widget? selectedIcon;

  /// The destination's name. A top bar shows it under the icon; a bottom bar
  /// reads it to assistive technology.
  final String label;

  /// A count shown as a badge on the icon; null or zero shows none.
  final int? badgeCount;

  /// Whether to show a dot badge when there is no [badgeCount].
  final bool showBadge;

  /// Whether a `NavigationScaffold` lists the destination in its top bar.
  final bool showInTopBar;

  /// Whether a `NavigationScaffold` lists the destination in its bottom bar.
  final bool showInBottomBar;
}

/// The primary action in the middle of a [BottomNavigationBar]: compose,
/// create, scan.
@immutable
class NavigationAction {
  /// Creates an action.
  const NavigationAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// The action's icon.
  final Widget icon;

  /// The action's name, read to assistive technology.
  final String label;

  /// Called when the action is tapped.
  final VoidCallback? onPressed;
}

Widget _badged(NavigationDestination destination, Widget icon, Offset offset) {
  final count = destination.badgeCount ?? 0;
  // The badge stays in the tree while it has nothing to show, so it pops
  // in when the first notification arrives and out when the last is read.
  return IndicatorBadge(
    count: count > 0 || !destination.showBadge ? count : null,
    visible: count > 0 || destination.showBadge,
    offset: offset,
    child: icon,
  );
}

/// A destination's icon, changing from [icon] to [selectedIcon] — usually
/// from the regular weight to the filled one — as a cross-fade with a small
/// pop, and in [color], which fades.
///
/// Both icons are in the tree only while one fades into the other; at rest
/// there is the one that shows. They are keyed, so the one that stays keeps
/// its state — an avatar does not reload — when the other comes or goes.
/// Deselecting only fades: the pop belongs to the destination the user
/// chose.
class _DestinationIcon extends StatelessWidget {
  const _DestinationIcon({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.color,
    required this.size,
  });

  final bool selected;
  final Widget icon;
  final Widget? selectedIcon;
  final Color color;
  final double size;

  static const _restKey = ValueKey('rest');
  static const _selectedKey = ValueKey('selected');

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    // How far the icon grows at the top of the pop: four times the press
    // shrink, so a style with a calmer press pops less and reduced motion
    // not at all.
    final pop = (1 - motion.pressScale) * 4;
    final filled = selectedIcon;
    return AnimatedColorBuilder(
      color: color,
      duration: motion.fast,
      curve: motion.standard,
      builder: (context, color, child) => IconTheme.merge(
        data: IconThemeData(size: size, color: color),
        child: child!,
      ),
      child: SpringBuilder(
        value: selected ? 1 : 0,
        spring: selected ? motion.bouncy : motion.snappy,
        builder: (context, value, _) {
          final t = value.clamp(0.0, 1.0);
          // Up and back over the course of the change, and only on the way
          // in: 4t(1 − t) is 0 at both ends and 1 half-way.
          final scale = selected ? 1 + pop * 4 * t * (1 - t) : 1.0;
          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (filled == null || t < 1)
                  KeyedSubtree(
                    key: _restKey,
                    child: Opacity(
                      opacity: filled == null ? 1 : 1 - t,
                      child: icon,
                    ),
                  ),
                if (filled != null && t > 0)
                  KeyedSubtree(
                    key: _selectedKey,
                    child: Opacity(opacity: t, child: filled),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A row of destinations for the top of a wide screen: an icon over a label,
/// with a bar under the selected one.
///
/// ```dart
/// NavigationBar(
///   selectedIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
///   destinations: const [
///     NavigationDestination(
///       icon: PhosphorIcon(PhosphorIconsRegular.house),
///       selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
///       label: 'Home',
///     ),
///     NavigationDestination(
///       icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
///       label: 'Messages',
///       badgeCount: 3,
///     ),
///   ],
/// )
/// ```
///
/// It is meant for an `AppBar`'s `middle` and fills the bar's height, so the
/// selection indicator sits on the bar's bottom edge. On a phone use a
/// [BottomNavigationBar]; a `NavigationScaffold` switches between the two.
class NavigationBar extends StatelessWidget {
  /// Creates a top navigation bar.
  const NavigationBar({
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.height,
    super.key,
  });

  /// The destinations, in order.
  final List<NavigationDestination> destinations;

  /// The index of the selected destination, or null or out of range for
  /// none.
  final int? selectedIndex;

  /// Called with the index of the destination that was tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// The bar's height. Defaults to the app bar's.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nav = theme.navigationBarTheme;
    final motion = Motion.of(context);
    final barHeight = height ?? theme.appBarTheme.height ?? 64;
    final inset = nav.indicatorInset ?? 12;
    final indicatorHeight = nav.indicatorHeight ?? 3;
    final indicator = BoxDecoration(
      color: nav.indicatorColor ?? theme.colorScheme.tint,
      borderRadius: BorderRadius.circular(indicatorHeight),
    );

    Widget item(int index, NavigationDestination destination) {
      final selected = index == selectedIndex;
      return SizedBox(
        width: nav.itemWidth ?? 88,
        height: barHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Pressable(
                selected: selected,
                onPressed: onDestinationSelected == null
                    ? null
                    : () => onDestinationSelected!(index),
                builder: (context, states) {
                  final hovered = states.contains(WidgetState.hovered);
                  final rest =
                      nav.foregroundColor ?? theme.colorScheme.mutedForeground;
                  final iconColor = selected
                      ? nav.selectedIconColor ?? theme.colorScheme.tint
                      : hovered
                      ? nav.hoverColor ?? theme.colorScheme.foreground
                      : rest;
                  final labelColor = selected
                      ? nav.selectedLabelColor ?? theme.colorScheme.foreground
                      : hovered
                      ? nav.hoverColor ?? theme.colorScheme.foreground
                      : rest;
                  final labelStyle = nav.labelStyle ?? theme.textTheme.small;
                  return FocusRing(
                    visible: states.contains(WidgetState.focused),
                    borderRadius: theme.radius,
                    // The app bar clips for its backdrop blur, which would
                    // cut an outside ring off at the top and bottom.
                    inset: true,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: nav.gap ?? 4,
                        children: [
                          _badged(
                            destination,
                            _DestinationIcon(
                              selected: selected,
                              icon: destination.icon,
                              selectedIcon: destination.selectedIcon,
                              color: iconColor,
                              size: nav.iconSize ?? 24,
                            ),
                            const Offset(4, 0),
                          ),
                          AnimatedColorBuilder(
                            color: labelColor,
                            duration: motion.fast,
                            curve: motion.standard,
                            builder: (context, color, _) => Text(
                              destination.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: labelStyle.copyWith(color: color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Where the bar under the destinations goes when this one is
            // selected. It is painted once, by the row, and travels. Outside
            // the pressable, so a press does not shrink its end of the bar.
            PositionedDirectional(
              start: inset,
              end: inset,
              // Over the app bar's own hairline.
              bottom: -1,
              height: indicatorHeight,
              child: IgnorePointer(
                child: MovingIndicatorTarget(
                  selected: selected,
                  decoration: indicator,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        height: barHeight,
        // In front of the destinations, so the bar also covers the app
        // bar's hairline.
        child: MovingIndicator(
          position: DecorationPosition.foreground,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, destination) in destinations.indexed)
                item(index, destination),
            ],
          ),
        ),
      ),
    );
  }
}

/// The destinations at the bottom of a phone screen, with an optional
/// primary [action] in the middle.
///
/// ```dart
/// BottomNavigationBar(
///   selectedIndex: index,
///   onDestinationSelected: (i) => setState(() => index = i),
///   action: NavigationAction(
///     icon: const PhosphorIcon(PhosphorIconsRegular.plus),
///     label: 'Create post',
///     onPressed: _compose,
///   ),
///   destinations: destinations,
/// )
/// ```
///
/// In a style whose bottom bar floats — Finesse's default — it is a glass
/// pill hovering above the page, as wide as its destinations; otherwise it
/// spans the bottom edge and shares the width between them. Either way it
/// respects the bottom safe area. Put it in a `Scaffold` so the page scrolls
/// beneath it.
class BottomNavigationBar extends StatelessWidget {
  /// Creates a bottom navigation bar.
  const BottomNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.action,
    this.floating,
    super.key,
  });

  /// The destinations, in order.
  final List<NavigationDestination> destinations;

  /// The index of the selected destination, or null or out of range for
  /// none.
  final int? selectedIndex;

  /// Called with the index of the destination that was tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// A primary action shown between the two halves of [destinations].
  final NavigationAction? action;

  /// Whether the bar floats as a pill. Defaults to the theme's.
  final bool? floating;

  /// The height a [BottomNavigationBar] takes in [context], including its
  /// margin and the bottom safe area. A `Scaffold` uses it to inset its body.
  static double heightOf(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.bottomNavigationBarTheme;
    final padding = (bar.padding ?? const EdgeInsets.all(6)).resolve(
      Directionality.of(context),
    );
    final floating = bar.floating ?? true;
    final margin = floating
        ? (bar.margin ?? const EdgeInsets.only(bottom: 22)).resolve(
            Directionality.of(context),
          )
        : EdgeInsets.zero;
    return (bar.itemHeight ?? 48) +
        padding.vertical +
        margin.vertical +
        MediaQuery.paddingOf(context).bottom +
        // The outline: all round a floating pill, along the top of a docked
        // bar.
        (floating ? 2 : 1);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => _build(context, constraints.maxWidth),
  );

  Widget _build(BuildContext context, double maxWidth) {
    final theme = Theme.of(context);
    final bar = theme.bottomNavigationBarTheme;
    final isFloating = floating ?? bar.floating ?? true;
    final barPadding = (bar.padding ?? const EdgeInsets.all(6)).resolve(
      Directionality.of(context),
    );
    final gap = bar.gap ?? 4;
    // A floating bar is as wide as its items, but never wider than the
    // screen: on a narrow phone the items give up width evenly rather than
    // overflow.
    final itemCount = destinations.length + (action == null ? 0 : 1);
    var itemWidth = bar.itemWidth ?? 52;
    if (isFloating && maxWidth.isFinite && itemCount > 0) {
      const sideMargin = 16.0;
      final available =
          maxWidth -
          2 * sideMargin -
          barPadding.horizontal -
          2 -
          gap * (itemCount - 1);
      final fit = available / itemCount;
      if (fit < itemWidth) itemWidth = fit < 0 ? 0 : fit;
    }
    final radius = isFloating
        ? bar.radius ?? theme.radii.full
        : BorderRadius.zero;
    final itemRadius = isFloating ? theme.radii.full : theme.radii.lg;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // The lens: one pill behind the selected destination, painted by the
    // row and travelling between them.
    final lens = BoxDecoration(
      color: bar.selectedBackgroundColor ?? theme.colorScheme.accent,
      borderRadius: itemRadius,
    );

    Widget item({
      required Widget Function(Color color, double size) icon,
      required String label,
      required VoidCallback? onPressed,
      required bool? selected,
      String? value,
      Color? background,
      Color? foreground,
      double? iconSize,
    }) {
      final isSelected = selected ?? false;
      Widget child = Pressable(
        selected: selected,
        onPressed: onPressed,
        semanticLabel: label,
        semanticValue: value,
        builder: (context, states) {
          final hovered = states.contains(WidgetState.hovered);
          // The selected destination's fill is the lens behind it; only
          // the hover wash and the action's own fill are painted here. The
          // wash stays on a hovered destination that becomes selected:
          // taking it away while the lens is still on its way would flash
          // the bar's own colour through for a few frames.
          final color =
              background ??
              (hovered ? theme.colorScheme.muted : const Color(0x00000000));
          return FocusRing(
            visible: states.contains(WidgetState.focused),
            borderRadius: itemRadius,
            inset: true,
            child: SizedBox(
              width: isFloating ? itemWidth : null,
              height: bar.itemHeight ?? 48,
              // A cross-fade, not `Color.lerp`: from nothing to the wash
              // that one passes through a half-opaque dark grey, which is
              // the flash a tap on a destination used to make.
              child: AnimatedFill(
                color: color,
                borderRadius: itemRadius,
                child: Center(
                  child: ExcludeSemantics(
                    child: icon(
                      foreground ??
                          (isSelected
                              ? bar.selectedForegroundColor ??
                                    theme.colorScheme.tint
                              : bar.foregroundColor ??
                                    theme.colorScheme.foregroundSubtle),
                      iconSize ?? bar.iconSize ?? 26,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      if (selected != null) {
        // Around the pressable, not inside it: a press shrinks the icon,
        // not the lens under it.
        child = MovingIndicatorTarget(
          selected: isSelected,
          decoration: lens,
          child: child,
        );
      }
      return isFloating ? child : Expanded(child: child);
    }

    Widget actionIcon(Color color, double size) => IconTheme.merge(
      data: IconThemeData(size: size, color: color),
      child: action!.icon,
    );

    final actionIndex = (destinations.length / 2).ceil();
    final children = <Widget>[
      for (final (index, destination) in destinations.indexed) ...[
        if (action != null && index == actionIndex)
          item(
            icon: actionIcon,
            label: action!.label,
            onPressed: action!.onPressed,
            selected: null,
            background: bar.actionBackgroundColor ?? theme.colorScheme.primary,
            foreground:
                bar.actionForegroundColor ??
                theme.colorScheme.primaryForeground,
            iconSize: bar.actionIconSize ?? 22,
          ),
        item(
          icon: (color, size) => _badged(
            destination,
            _DestinationIcon(
              selected: index == selectedIndex,
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              color: color,
              size: size,
            ),
            Offset.zero,
          ),
          label: destination.label,
          value: (destination.badgeCount ?? 0) > 0
              ? '${destination.badgeCount}'
              : null,
          onPressed: onDestinationSelected == null
              ? null
              : () => onDestinationSelected!(index),
          selected: index == selectedIndex,
        ),
      ],
      if (action != null && actionIndex >= destinations.length)
        item(
          icon: actionIcon,
          label: action!.label,
          onPressed: action!.onPressed,
          selected: null,
          background: bar.actionBackgroundColor ?? theme.colorScheme.primary,
          foreground:
              bar.actionForegroundColor ?? theme.colorScheme.primaryForeground,
          iconSize: bar.actionIconSize ?? 22,
        ),
    ];

    final borderColor = bar.borderColor ?? theme.colorScheme.border;
    // A floating bar's hairline can catch the light along its top edge;
    // see [BottomNavigationBarTheme.rimColor].
    final rimColor = isFloating ? bar.rimColor : null;
    Widget content = Container(
      padding: (bar.padding ?? const EdgeInsets.all(6)).add(
        EdgeInsets.only(bottom: isFloating ? 0 : bottomInset),
      ),
      decoration: BoxDecoration(
        color: bar.backgroundColor ?? theme.colorScheme.card,
        borderRadius: radius,
        border: isFloating
            // With a rim the hairline is painted over the bar, below; the
            // border still takes its point of layout.
            ? Border.all(
                color: rimColor == null ? borderColor : const Color(0x00000000),
              )
            : Border(top: BorderSide(color: borderColor)),
      ),
      child: MovingIndicator(
        child: Row(
          mainAxisSize: isFloating ? MainAxisSize.min : MainAxisSize.max,
          spacing: gap,
          children: children,
        ),
      ),
    );
    if (rimColor != null) {
      content = CustomPaint(
        foregroundPainter: _RimPainter(
          radius: radius,
          color: borderColor,
          rimColor: rimColor,
        ),
        child: content,
      );
    }
    final surface = Backdrop(
      blur: bar.blur ?? 0,
      saturation: bar.saturation ?? 1,
      borderRadius: radius,
      child: content,
    );

    final semantic = Semantics(
      container: true,
      explicitChildNodes: true,
      child: surface,
    );
    if (!isFloating) return semantic;
    return Padding(
      padding: (bar.margin ?? const EdgeInsets.only(bottom: 22)).add(
        EdgeInsets.only(bottom: bottomInset),
      ),
      child: Center(
        heightFactor: 1,
        child: DecoratedBox(
          // Outside the clip, and after the bar: a shadow painted first
          // would be sampled by the filter and blurred back into the glass.
          position: DecorationPosition.foreground,
          decoration: ShadowDecoration.box(
            borderRadius: radius,
            shadows: bar.shadows ?? theme.style.floatingShadow,
          ),
          child: semantic,
        ),
      ),
    );
  }
}

/// The hairline of a floating bar, brighter along its top edge: [rimColor]
/// at the top, fading into [color] by the middle of the bar — the way light
/// from above catches the rim of a sheet of glass.
class _RimPainter extends CustomPainter {
  const _RimPainter({
    required this.radius,
    required this.color,
    required this.rimColor,
  });

  final BorderRadius radius;
  final Color color;
  final Color rimColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // A one-point stroke centred half a point inside the edge: where
    // `Border.all` paints its hairline.
    final outline = radius.toRRect(Offset.zero & size).deflate(.5);
    canvas.drawRRect(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          [rimColor, color],
          const [0, .55],
        ),
    );
  }

  @override
  bool shouldRepaint(_RimPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.color != color ||
      oldDelegate.rimColor != rimColor;
}
