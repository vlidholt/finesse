import 'package:finesse/src/liquid_glass/liquid_glass.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

/// A destination of a [LiquidGlassTabBar].
@immutable
class LiquidGlassTab {
  /// Creates a tab.
  const LiquidGlassTab({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  /// The icon, already badged.
  final Widget icon;

  /// The icon while selected.
  final Widget? activeIcon;

  /// The tab's name: shown under the icon when the bar shows labels, and
  /// announced either way.
  final String label;
}

/// The button a [LiquidGlassTabBar] floats beside its tabs, on a capsule
/// of its own: iOS 26's split bottom bar.
@immutable
class LiquidGlassTabAction {
  /// Creates the bar's separate button.
  const LiquidGlassTabAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  /// The icon.
  final Widget icon;

  /// What a screen reader announces.
  final String label;

  /// Called when the button is pressed; null disables it.
  final VoidCallback? onPressed;
}

/// The package's `GlassTabBar.bottom` in finesse's colours, type and size:
/// a floating capsule whose selection is a lens of glass that slides and
/// stretches from tab to tab, with an optional [action] on a capsule of its
/// own beside it.
///
/// Built by `BottomNavigationBar` when Liquid Glass is active; not public.
class LiquidGlassTabBar extends StatelessWidget {
  /// Creates a Liquid Glass tab bar.
  const LiquidGlassTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.barHeight,
    required this.iconSize,
    required this.selectedColor,
    required this.unselectedColor,
    this.action,
    this.showLabels = false,
    this.horizontalMargin = 16,
    this.bottomMargin = 22,
    super.key,
  });

  /// The tabs.
  final List<LiquidGlassTab> tabs;

  /// The index of the selected tab.
  final int selectedIndex;

  /// Called with the index of the tab tapped; null disables the bar.
  final ValueChanged<int>? onSelected;

  /// The button beside the tabs, or null for none.
  final LiquidGlassTabAction? action;

  /// The height of the capsule.
  final double barHeight;

  /// The size of the tabs' icons.
  final double iconSize;

  /// The colour of the selected tab's icon and label.
  final Color selectedColor;

  /// The colour of the other tabs.
  final Color unselectedColor;

  /// Whether the tabs show their labels under their icons.
  final bool showLabels;

  /// The space between the bar and the sides of the screen.
  final double horizontalMargin;

  /// The space between the bar and the bottom safe area.
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = theme.textTheme.caption;
    final action = this.action;
    final onSelected = this.onSelected;
    // The lens grows past the bar while it moves; the bar keeps that much
    // room above and below itself, taken out of its margin.
    const lensRoom = 8.0;
    final bar = lg.GlassTabBar.bottom(
      tabs: [
        for (final tab in tabs)
          lg.GlassTab(
            icon: tab.icon,
            activeIcon: tab.activeIcon,
            label: showLabels ? tab.label : null,
            semanticLabel: tab.label,
          ),
      ],
      selectedIndex: selectedIndex,
      onTabSelected: onSelected ?? (_) {},
      extraButton: action == null
          ? null
          : lg.GlassTabBarExtraButton(
              icon: action.icon,
              label: action.label,
              onTap: action.onPressed ?? () {},
              enabled: action.onPressed != null,
              size: barHeight,
            ),
      barHeight: barHeight,
      horizontalPadding: horizontalMargin,
      verticalPadding: lensRoom,
      iconSize: iconSize,
      labelFontSize: label.fontSize ?? 11,
      textStyle: label,
      selectedIconColor: selectedColor,
      unselectedIconColor: unselectedColor,
      selectedLabelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
    );
    final bottom =
        MediaQuery.paddingOf(context).bottom +
        (bottomMargin - lensRoom).clamp(0.0, double.infinity);
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: LiquidGlassBridge(
        child: IgnorePointer(ignoring: onSelected == null, child: bar),
      ),
    );
  }
}
