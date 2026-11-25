import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'wheel_picker.g.theme.dart';

/// The theme of `WheelPicker` and `WheelPickerGroup`: every value the
/// widgets do not set themselves.
@themeGen
@immutable
class WheelPickerTheme with _$WheelPickerTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const WheelPickerTheme({
    bool canMerge = true,
    this.itemExtent,
    this.itemPadding,
    this.textStyle,
    this.selectedTextStyle,
    this.disabledOpacity,
    this.lensColor,
    this.lensBorderColor,
    this.lensBorderWidth,
    this.lensRadius,
    this.lensMagnification,
    this.curvature,
    this.edgeFade,
    this.gap,
    this.groupPadding,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The height of one row, and of the lens. It is a floor: the row grows
  /// with the text scale.
  final double? itemExtent;

  /// The room on either side of a label, inside the wheel.
  final EdgeInsetsGeometry? itemPadding;

  /// The style of the rows outside the lens.
  final TextStyle? textStyle;

  /// The style of the row under the lens.
  final TextStyle? selectedTextStyle;

  /// How much of its colour a disabled row keeps, from 0 to 1.
  final double? disabledOpacity;

  /// The fill of the lens, the band that marks the selected row.
  final Color? lensColor;

  /// The hairline around the lens.
  final Color? lensBorderColor;

  /// The width of the hairline around the lens; 0 for none.
  final double? lensBorderWidth;

  /// The corners of the lens.
  final BorderRadius? lensRadius;

  /// How much larger the row under the lens is drawn; 1 is no
  /// magnification.
  final double? lensMagnification;

  /// How strongly the rows turn away towards the top and bottom, from 0 (a
  /// flat list) to 1 (a drum seen from close by).
  final double? curvature;

  /// The part of the wheel's half-height, from 0 to 1, over which the rows
  /// fade out towards the top and the bottom edge.
  final double? edgeFade;

  /// The gap between two wheels of a `WheelPickerGroup`.
  final double? gap;

  /// The room between the edges of a `WheelPickerGroup`'s lens and its
  /// outermost wheels.
  final EdgeInsetsGeometry? groupPadding;

  /// Linearly interpolates between two themes.
  static WheelPickerTheme? lerp(
    WheelPickerTheme? a,
    WheelPickerTheme? b,
    double t,
  ) => _$WheelPickerTheme.lerp(a, b, t);
}
