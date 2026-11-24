import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'list_tile.g.theme.dart';

/// The theme of `ListTile`: every value the widget does not set itself.
@themeGen
@immutable
class ListTileTheme with _$ListTileTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const ListTileTheme({
    bool canMerge = true,
    this.padding,
    this.gap,
    this.titleGap,
    this.radius,
    this.titleStyle,
    this.subtitleStyle,
    this.hoverColor,
    this.selectedColor,
    this.pressScale,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Padding around the tile's content.
  final EdgeInsetsGeometry? padding;

  /// The gap between the leading widget, the text and the trailing
  /// widget.
  final double? gap;

  /// The gap between the title and the subtitle.
  final double? titleGap;

  /// The corner radius of the hover and selection highlight.
  final BorderRadius? radius;

  /// The title's style.
  final TextStyle? titleStyle;

  /// The subtitle's style.
  final TextStyle? subtitleStyle;

  /// The fill under the pointer.
  final Color? hoverColor;

  /// The fill of a selected tile.
  final Color? selectedColor;

  /// The scale of a tappable tile while it is pressed; a paint-time
  /// transform that springs back on release. Defaults to the theme's
  /// `Motion.surfacePressScale`; 1 disables it.
  final double? pressScale;

  /// Linearly interpolates between two themes.
  static ListTileTheme? lerp(ListTileTheme? a, ListTileTheme? b, double t) =>
      _$ListTileTheme.lerp(a, b, t);
}
