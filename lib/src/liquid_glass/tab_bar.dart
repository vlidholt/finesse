import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:una/src/liquid_glass/liquid_glass.dart';
import 'package:una/src/theme/theme.dart';

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

/// The package's `GlassTabBar.bottom` in una's colours, type and size:
/// a floating capsule whose selection is a lens of glass that slides and
/// stretches from tab to tab, with an optional [action] on a capsule of its
/// own beside it.
///
/// As on iOS 26 the capsule is as wide as its tabs, not as the screen: with
/// an [action] the tabs sit at the start and the action at the end with the
/// free space between them, and without one the capsule is centred. Only
/// when the tabs do not fit do they share what there is.
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

  /// The index of the selected tab, or null when none is: no lens shows,
  /// and every tab is drawn unselected.
  final int? selectedIndex;

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

  /// The width of one tab: an icon with room for the lens around it, or a
  /// label with its own padding, whichever is wider.
  @visibleForTesting
  double naturalTabWidth(BuildContext context) {
    // The lens is a capsule round the icon; iOS leaves about an icon's
    // width either side of it.
    var width = math.max(iconSize * 2.3, barHeight - 8);
    if (showLabels) {
      final style = Theme.of(context).textTheme.caption;
      final scaler = MediaQuery.textScalerOf(context);
      for (final tab in tabs) {
        final painter = TextPainter(
          text: TextSpan(text: tab.label, style: style),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        width = math.max(width, painter.width + 24);
        painter.dispose();
      }
    }
    return width.ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = theme.textTheme.caption;
    final action = this.action;
    final onSelected = this.onSelected;
    final selected = selectedIndex;
    // The lens grows past the bar while it moves; the bar keeps that much
    // room above and below itself, taken out of its margin.
    const lensRoom = 8.0;
    final tabWidth = naturalTabWidth(context);
    Widget bar = lg.GlassTabBar.bottom(
      tabs: [
        for (final tab in tabs)
          lg.GlassTab(
            icon: tab.icon,
            // With nothing selected the first tab stands in for the
            // package's selection, drawn as it is at rest.
            activeIcon: selected == null ? tab.icon : tab.activeIcon,
            label: showLabels ? tab.label : null,
            semanticLabel: tab.label,
          ),
      ],
      selectedIndex: selected ?? 0,
      showIndicator: selected != null,
      tabWidth: tabWidth,
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
      selectedIconColor: selected == null ? unselectedColor : selectedColor,
      unselectedIconColor: unselectedColor,
      selectedLabelColor: selected == null ? unselectedColor : selectedColor,
      unselectedLabelColor: unselectedColor,
    );
    if (action == null) {
      // The package puts the capsule at the start of the width it is
      // given; given only the capsule's, it is centred.
      bar = Center(
        child: SizedBox(
          width: tabWidth * tabs.length + 2 * horizontalMargin,
          child: bar,
        ),
      );
    }
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
