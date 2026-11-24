import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'chip.g.theme.dart';

/// The theme of `Chip`: every value the widget does not set itself.
@themeGen
@immutable
class ChipTheme with _$ChipTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const ChipTheme({
    bool canMerge = true,
    this.height,
    this.padding,
    this.gap,
    this.iconSize,
    this.radius,
    this.borderWidth,
    this.textStyle,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
    this.selectedBorderColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The chip's height.
  final double? height;

  /// Padding around the chip's content.
  final EdgeInsetsGeometry? padding;

  /// The gap between the chip's icon and label.
  final double? gap;

  /// The size of icons inside the chip.
  final double? iconSize;

  /// The corner radius.
  final BorderRadius? radius;

  /// The width of the chip's outline.
  final double? borderWidth;

  /// The label's style.
  final TextStyle? textStyle;

  /// The fill of an unselected chip.
  final Color? backgroundColor;

  /// The fill of an unselected chip under the pointer.
  final Color? hoverBackgroundColor;

  /// The colour of an unselected chip's content.
  final Color? foregroundColor;

  /// The outline of an unselected chip.
  final Color? borderColor;

  /// The fill of a selected chip.
  final Color? selectedBackgroundColor;

  /// The colour of a selected chip's content.
  final Color? selectedForegroundColor;

  /// The outline of a selected chip.
  final Color? selectedBorderColor;

  /// Linearly interpolates between two themes.
  static ChipTheme? lerp(ChipTheme? a, ChipTheme? b, double t) =>
      _$ChipTheme.lerp(a, b, t);
}
