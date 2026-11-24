import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'indicator_badge.g.theme.dart';

/// The theme of `IndicatorBadge`: every value the widget does not set itself.
@themeGen
@immutable
class IndicatorBadgeTheme with _$IndicatorBadgeTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const IndicatorBadgeTheme({
    bool canMerge = true,
    this.size,
    this.dotSize,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.ringColor,
    this.ringWidth,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The height, and minimum width, of a badge that shows a count.
  final double? size;

  /// The diameter of a badge with no count.
  final double? dotSize;

  /// Padding around the count.
  final EdgeInsetsGeometry? padding;

  /// The badge's fill.
  final Color? backgroundColor;

  /// The colour of the count.
  final Color? foregroundColor;

  /// The style of the count.
  final TextStyle? textStyle;

  /// The colour of the ring that separates the badge from what it sits
  /// on.
  final Color? ringColor;

  /// The width of that ring.
  final double? ringWidth;

  /// Linearly interpolates between two themes.
  static IndicatorBadgeTheme? lerp(
    IndicatorBadgeTheme? a,
    IndicatorBadgeTheme? b,
    double t,
  ) => _$IndicatorBadgeTheme.lerp(a, b, t);
}
