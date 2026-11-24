import 'package:finesse/src/components/indicator_badge.dart';
import 'package:finesse/src/raw_components/pressable.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/backdrop.dart';
import 'package:finesse/src/utils/shadow.dart';
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

  /// Whether a [NavigationScaffold] lists the destination in its top bar.
  final bool showInTopBar;

  /// Whether a [NavigationScaffold] lists the destination in its bottom bar.
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
  if (count <= 0 && !destination.showBadge) return icon;
  return IndicatorBadge(
    count: count > 0 ? count : null,
    offset: offset,
    child: icon,
  );
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
///       icon: Icon(PhosphorIconsRegular.house),
///       selectedIcon: Icon(PhosphorIconsFill.house),
///       label: 'Home',
///     ),
///     NavigationDestination(
///       icon: Icon(PhosphorIconsRegular.chatCircleDots),
///       label: 'Messages',
///       badgeCount: 3,
///     ),
///   ],
/// )
/// ```
///
/// It is meant for an [AppBar]'s `middle` and fills the bar's height, so the
/// selection indicator sits on the bar's bottom edge. On a phone use a
/// [BottomNavigationBar]; a [NavigationScaffold] switches between the two.
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
    final barHeight = height ?? theme.appBarTheme.height ?? 64;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        height: barHeight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, destination) in destinations.indexed)
              Pressable(
                selected: index == selectedIndex,
                onPressed: onDestinationSelected == null
                    ? null
                    : () => onDestinationSelected!(index),
                builder: (context, states) {
                  final selected = index == selectedIndex;
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
                  final inset = nav.indicatorInset ?? 12;
                  final indicator = nav.indicatorHeight ?? 3;
                  return FocusRing(
                    visible: states.contains(WidgetState.focused),
                    borderRadius: theme.radius,
                    child: SizedBox(
                      width: nav.itemWidth ?? 88,
                      height: barHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: nav.gap ?? 4,
                            children: [
                              IconTheme.merge(
                                data: IconThemeData(
                                  size: nav.iconSize ?? 24,
                                  color: iconColor,
                                ),
                                child: _badged(
                                  destination,
                                  selected
                                      ? destination.selectedIcon ??
                                            destination.icon
                                      : destination.icon,
                                  const Offset(4, 0),
                                ),
                              ),
                              Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: (nav.labelStyle ?? theme.textTheme.small)
                                    .copyWith(color: labelColor),
                              ),
                            ],
                          ),
                          if (selected)
                            PositionedDirectional(
                              start: inset,
                              end: inset,
                              // Over the app bar's own hairline.
                              bottom: -1,
                              height: indicator,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color:
                                      nav.indicatorColor ??
                                      theme.colorScheme.tint,
                                  borderRadius: BorderRadius.circular(
                                    indicator,
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
          ],
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
///     icon: const Icon(PhosphorIconsRegular.plus),
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
/// respects the bottom safe area. Put it in a [Scaffold] so the page scrolls
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
  /// margin and the bottom safe area. A [Scaffold] uses it to inset its body.
  static double heightOf(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.bottomNavigationBarTheme;
    final padding = (bar.padding ?? const EdgeInsets.all(6)).resolve(
      Directionality.of(context),
    );
    final floating = bar.floating ?? true;
    final margin = floating
        ? (bar.margin ?? EdgeInsets.zero).resolve(Directionality.of(context))
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = theme.bottomNavigationBarTheme;
    final isFloating = floating ?? bar.floating ?? true;
    final radius = isFloating
        ? bar.radius ?? theme.radii.full
        : BorderRadius.zero;
    final itemRadius = isFloating ? theme.radii.full : theme.radii.lg;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    Widget item({
      required Widget icon,
      required String label,
      required VoidCallback? onPressed,
      required bool selected,
      Color? background,
      Color? foreground,
      double? iconSize,
    }) {
      final child = Pressable(
        selected: selected,
        onPressed: onPressed,
        semanticLabel: label,
        builder: (context, states) {
          final hovered = states.contains(WidgetState.hovered);
          final color =
              background ??
              (selected
                  ? bar.selectedBackgroundColor ?? theme.colorScheme.accent
                  : hovered
                  ? theme.colorScheme.muted
                  : const Color(0x00000000));
          return FocusRing(
            visible: states.contains(WidgetState.focused),
            borderRadius: itemRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isFloating ? bar.itemWidth ?? 52 : null,
              height: bar.itemHeight ?? 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: itemRadius,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  size: iconSize ?? bar.iconSize ?? 26,
                  color:
                      foreground ??
                      (selected
                          ? bar.selectedForegroundColor ??
                                theme.colorScheme.tint
                          : bar.foregroundColor ??
                                theme.colorScheme.foregroundSubtle),
                ),
                child: ExcludeSemantics(child: icon),
              ),
            ),
          );
        },
      );
      return isFloating ? child : Expanded(child: child);
    }

    final actionIndex = (destinations.length / 2).ceil();
    final children = <Widget>[
      for (final (index, destination) in destinations.indexed) ...[
        if (action != null && index == actionIndex)
          item(
            icon: action!.icon,
            label: action!.label,
            onPressed: action!.onPressed,
            selected: false,
            background: bar.actionBackgroundColor ?? theme.colorScheme.primary,
            foreground:
                bar.actionForegroundColor ??
                theme.colorScheme.primaryForeground,
            iconSize: bar.actionIconSize ?? 22,
          ),
        item(
          icon: _badged(
            destination,
            index == selectedIndex
                ? destination.selectedIcon ?? destination.icon
                : destination.icon,
            Offset.zero,
          ),
          label: destination.label,
          onPressed: onDestinationSelected == null
              ? null
              : () => onDestinationSelected!(index),
          selected: index == selectedIndex,
        ),
      ],
      if (action != null && actionIndex >= destinations.length)
        item(
          icon: action!.icon,
          label: action!.label,
          onPressed: action!.onPressed,
          selected: false,
          background: bar.actionBackgroundColor ?? theme.colorScheme.primary,
          foreground:
              bar.actionForegroundColor ?? theme.colorScheme.primaryForeground,
          iconSize: bar.actionIconSize ?? 22,
        ),
    ];

    final surface = Backdrop(
      blur: bar.blur ?? 0,
      saturation: bar.saturation ?? 1,
      borderRadius: radius,
      child: Container(
        padding: (bar.padding ?? const EdgeInsets.all(6)).add(
          EdgeInsets.only(bottom: isFloating ? 0 : bottomInset),
        ),
        decoration: BoxDecoration(
          color: bar.backgroundColor ?? theme.colorScheme.card,
          borderRadius: radius,
          border: isFloating
              ? Border.all(color: bar.borderColor ?? theme.colorScheme.border)
              : Border(
                  top: BorderSide(
                    color: bar.borderColor ?? theme.colorScheme.border,
                  ),
                ),
        ),
        child: Row(
          mainAxisSize: isFloating ? MainAxisSize.min : MainAxisSize.max,
          spacing: bar.gap ?? 4,
          children: children,
        ),
      ),
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
          decoration: ShadowDecoration.box(
            borderRadius: radius,
            shadows: theme.style.floatingShadow,
          ),
          child: semantic,
        ),
      ),
    );
  }
}
