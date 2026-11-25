import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'refresh_indicator.g.theme.dart';

/// The theme of `RefreshIndicator`: every value the widget does not set
/// itself.
@themeGen
@immutable
class RefreshIndicatorTheme with _$RefreshIndicatorTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const RefreshIndicatorTheme({
    bool canMerge = true,
    this.size,
    this.strokeWidth,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.triggerDistance,
    this.displacement,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The diameter of the circle.
  final double? size;

  /// The thickness of the ring inside the circle.
  final double? strokeWidth;

  /// The colour of the ring.
  final Color? color;

  /// The fill of the circle.
  final Color? backgroundColor;

  /// The colour of the circle's hairline outline.
  final Color? borderColor;

  /// How far the list has to be pulled, in logical pixels, before letting
  /// go refreshes.
  final double? triggerDistance;

  /// The gap between the edge the circle comes from and the circle while
  /// it rests there, refreshing.
  final double? displacement;

  /// Linearly interpolates between two themes.
  static RefreshIndicatorTheme? lerp(
    RefreshIndicatorTheme? a,
    RefreshIndicatorTheme? b,
    double t,
  ) => _$RefreshIndicatorTheme.lerp(a, b, t);
}
