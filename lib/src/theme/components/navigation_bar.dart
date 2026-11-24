import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'navigation_bar.g.theme.dart';

/// The theme of `NavigationBar`: every value the widget does not set itself.
@themeGen
@immutable
class NavigationBarTheme with _$NavigationBarTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const NavigationBarTheme({
    bool canMerge = true,
    this.itemWidth,
    this.iconSize,
    this.gap,
    this.labelStyle,
    this.foregroundColor,
    this.selectedIconColor,
    this.selectedLabelColor,
    this.hoverColor,
    this.indicatorColor,
    this.indicatorHeight,
    this.indicatorInset,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The width of one destination.
  final double? itemWidth;

  /// The size of a destination's icon.
  final double? iconSize;

  /// The gap between a destination's icon and label.
  final double? gap;

  /// The style of a destination's label.
  final TextStyle? labelStyle;

  /// The colour of an unselected destination.
  final Color? foregroundColor;

  /// The colour of the selected destination's icon.
  final Color? selectedIconColor;

  /// The colour of the selected destination's label.
  final Color? selectedLabelColor;

  /// The colour of an unselected destination under the pointer.
  final Color? hoverColor;

  /// The colour of the bar under the selected destination.
  final Color? indicatorColor;

  /// The thickness of the bar under the selected destination.
  final double? indicatorHeight;

  /// How far the indicator stops short of each edge of the destination.
  final double? indicatorInset;

  /// Linearly interpolates between two themes.
  static NavigationBarTheme? lerp(
    NavigationBarTheme? a,
    NavigationBarTheme? b,
    double t,
  ) => _$NavigationBarTheme.lerp(a, b, t);
}
