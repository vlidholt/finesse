import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/liquid_glass/liquid_glass_theme.dart';

part 'navigation_rail.g.theme.dart';

/// The look of `NavigationScaffold`'s rail layout
/// (`NavigationLayout.rail`): the destinations down the start edge of a
/// wide screen.
@themeGen
@immutable
class NavigationRailTheme with _$NavigationRailTheme {
  /// Creates a navigation rail theme.
  const NavigationRailTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.width,
    this.extendedWidth,
    this.itemHeight,
    this.extendedItemHeight,
    this.iconSize,
    this.gap,
    this.padding,
    this.labelStyle,
    this.extendedLabelStyle,
    this.foregroundColor,
    this.selectedIconColor,
    this.selectedLabelColor,
    this.hoverColor,
    this.indicatorColor,
    this.indicatorWidth,
    this.indicatorInset,
    this.backgroundColor,
    this.borderColor,
    this.blur,
    this.saturation,
    this.actionSize,
    this.actionBackgroundColor,
    this.actionForegroundColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether the navigation rail draws with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// The rail's width with its labels under the icons.
  final double? width;

  /// The rail's width when it is extended, with its labels beside the
  /// icons.
  final double? extendedWidth;

  /// The height of a destination with its label under the icon.
  final double? itemHeight;

  /// The height of a destination with its label beside the icon.
  final double? extendedItemHeight;

  /// The size of a destination's icon.
  final double? iconSize;

  /// The gap between a destination's icon and its label, in both
  /// arrangements.
  final double? gap;

  /// The space above the first and below the last thing in the rail, on
  /// top of the safe area.
  final double? padding;

  /// The style of a label under an icon.
  final TextStyle? labelStyle;

  /// The style of a label beside an icon.
  final TextStyle? extendedLabelStyle;

  /// The colour of a destination that is neither selected nor hovered.
  final Color? foregroundColor;

  /// The colour of the selected destination's icon.
  final Color? selectedIconColor;

  /// The colour of the selected destination's label.
  final Color? selectedLabelColor;

  /// The colour of a hovered destination.
  final Color? hoverColor;

  /// The colour of the line beside the selected destination.
  final Color? indicatorColor;

  /// The width of the line beside the selected destination.
  final double? indicatorWidth;

  /// How far the line stops short of the destination's top and bottom.
  final double? indicatorInset;

  /// The rail's fill: the bar colour, translucent in a glass style.
  final Color? backgroundColor;

  /// The colour of the hairline along the rail's inner edge.
  final Color? borderColor;

  /// The blur of what scrolls behind a translucent rail.
  final double? blur;

  /// The saturation of what scrolls behind a translucent rail.
  final double? saturation;

  /// The size of the round primary action at the top of the rail.
  final double? actionSize;

  /// The fill of the primary action.
  final Color? actionBackgroundColor;

  /// The colour of the primary action's icon and label.
  final Color? actionForegroundColor;

  /// Linearly interpolates between [a] and [b] by [t].
  static NavigationRailTheme? lerp(
    NavigationRailTheme? a,
    NavigationRailTheme? b,
    double t,
  ) => _$NavigationRailTheme.lerp(a, b, t);
}
