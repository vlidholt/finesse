import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'navigation_menu.g.theme.dart';

/// The look of a `NavigationMenu`: a row of links and triggers, and the
/// panel that opens under it.
///
/// The triggers are ghost buttons and the panel is a popover, so their
/// colours, corners, glass and shadow come from the button and popover
/// themes; this theme holds what is the menu's own.
@themeGen
@immutable
class NavigationMenuTheme with _$NavigationMenuTheme {
  /// Creates a navigation menu theme; a null field falls back to the app
  /// theme's.
  const NavigationMenuTheme({
    bool canMerge = true,
    this.gap,
    this.selectedColor,
    this.panelOffset,
    this.panelPadding,
    this.panelMargin,
    this.linkPadding,
    this.linkBorderRadius,
    this.linkGap,
    this.linkHoverColor,
    this.linkSelectedColor,
    this.linkTitleStyle,
    this.linkDescriptionStyle,
    this.sheetLabelStyle,
    this.openDelay,
    this.closeDelay,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The space between two entries of the row.
  final double? gap;

  /// The fill behind the trigger whose panel is open, and behind an entry
  /// that is marked selected. It slides from one trigger to the next.
  final Color? selectedColor;

  /// How far under the row the panel opens.
  final double? panelOffset;

  /// The padding of the panel around its content.
  final EdgeInsetsGeometry? panelPadding;

  /// How far the panel keeps from the edges of the screen.
  final double? panelMargin;

  /// The padding of a `NavigationMenuLink`.
  final EdgeInsetsGeometry? linkPadding;

  /// The corners of a `NavigationMenuLink`'s highlight.
  final BorderRadius? linkBorderRadius;

  /// The space between a link's title and its description.
  final double? linkGap;

  /// The fill of a `NavigationMenuLink` under the pointer or the focus.
  final Color? linkHoverColor;

  /// The fill of a `NavigationMenuLink` that is marked selected.
  final Color? linkSelectedColor;

  /// The style of a link's title.
  final TextStyle? linkTitleStyle;

  /// The style of a link's description.
  final TextStyle? linkDescriptionStyle;

  /// The style of an entry's label above its content in the sheet a
  /// collapsed menu opens.
  final TextStyle? sheetLabelStyle;

  /// How long the pointer rests on a trigger before its panel opens. Once
  /// a panel is open, moving to another trigger switches at once.
  final Duration? openDelay;

  /// How long after the pointer has left the row and the panel the panel
  /// closes: long enough to cross the gap between the two.
  final Duration? closeDelay;

  /// Linearly interpolates between two themes.
  static NavigationMenuTheme? lerp(
    NavigationMenuTheme? a,
    NavigationMenuTheme? b,
    double t,
  ) => _$NavigationMenuTheme.lerp(a, b, t);
}
