import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'bottom_navigation_bar.g.theme.dart';

/// The theme of `BottomNavigationBar`: every value the widget does not set
/// itself.
@themeGen
@immutable
class BottomNavigationBarTheme with _$BottomNavigationBarTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const BottomNavigationBarTheme({
    bool canMerge = true,
    this.floating,
    this.itemWidth,
    this.itemHeight,
    this.iconSize,
    this.actionIconSize,
    this.padding,
    this.margin,
    this.gap,
    this.radius,
    this.backgroundColor,
    this.borderColor,
    this.blur,
    this.saturation,
    this.foregroundColor,
    this.selectedForegroundColor,
    this.selectedBackgroundColor,
    this.actionBackgroundColor,
    this.actionForegroundColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether the bar floats as a pill above the page instead of spanning
  /// the bottom edge.
  final bool? floating;

  /// The width of one destination.
  final double? itemWidth;

  /// The height of one destination.
  final double? itemHeight;

  /// The size of a destination's icon.
  final double? iconSize;

  /// The size of the central action's icon.
  final double? actionIconSize;

  /// Padding inside the bar.
  final EdgeInsetsGeometry? padding;

  /// The space between a floating bar and the screen edge.
  final EdgeInsetsGeometry? margin;

  /// The gap between destinations.
  final double? gap;

  /// The bar's corner radius when it floats.
  final BorderRadius? radius;

  /// The bar's fill.
  final Color? backgroundColor;

  /// The colour of the bar's hairline.
  final Color? borderColor;

  /// The sigma of the backdrop blur under a translucent bar.
  final double? blur;

  /// How much the backdrop is saturated.
  final double? saturation;

  /// The colour of an unselected destination.
  final Color? foregroundColor;

  /// The colour of the selected destination.
  final Color? selectedForegroundColor;

  /// The fill behind the selected destination.
  final Color? selectedBackgroundColor;

  /// The fill of the central action.
  final Color? actionBackgroundColor;

  /// The colour of the central action's icon.
  final Color? actionForegroundColor;

  /// Linearly interpolates between two themes.
  static BottomNavigationBarTheme? lerp(
    BottomNavigationBarTheme? a,
    BottomNavigationBarTheme? b,
    double t,
  ) => _$BottomNavigationBarTheme.lerp(a, b, t);
}
