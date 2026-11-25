import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'slider.g.theme.dart';

/// {@template SliderTheme}
/// Theme for the `Slider` widget.
/// {@endtemplate}
@themeGen
@immutable
class SliderTheme with _$SliderTheme {
  /// {@macro SliderTheme}
  const SliderTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.min,
    this.max,
    this.mouseCursor,
    this.disabledMouseCursor,
    this.thumbColor,
    this.disabledThumbColor,
    this.thumbBorderColor,
    this.disabledThumbBorderColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.disabledActiveTrackColor,
    this.disabledInactiveTrackColor,
    this.trackHeight,
    this.thumbRadius,
    this.thumbPressScale,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether the slider draws with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// {@macro Slider.min}
  final double? min;

  /// {@macro Slider.max}
  final double? max;

  /// {@macro Slider.mouseCursor}
  final MouseCursor? mouseCursor;

  /// {@macro Slider.disabledMouseCursor}
  final MouseCursor? disabledMouseCursor;

  /// {@macro Slider.thumbColor}
  final Color? thumbColor;

  /// {@macro Slider.disabledThumbColor}
  final Color? disabledThumbColor;

  /// {@macro Slider.thumbBorderColor}
  final Color? thumbBorderColor;

  /// {@macro Slider.disabledThumbBorderColor}
  final Color? disabledThumbBorderColor;

  /// {@macro Slider.activeTrackColor}
  final Color? activeTrackColor;

  /// {@macro Slider.inactiveTrackColor}
  final Color? inactiveTrackColor;

  /// {@macro Slider.disabledActiveTrackColor}
  final Color? disabledActiveTrackColor;

  /// {@macro Slider.disabledInactiveTrackColor}
  final Color? disabledInactiveTrackColor;

  /// {@macro Slider.trackHeight}
  final double? trackHeight;

  /// {@macro Slider.thumbRadius}
  final double? thumbRadius;

  /// The scale of a thumb while it is dragged; a paint-time transform that
  /// springs back on release. Defaults to a growth four times the theme's
  /// press shrink (1.12 for `Motion.lively`); 1 disables it.
  final double? thumbPressScale;

  /// Linearly interpolates between [a] and [b] by [t].
  static SliderTheme? lerp(
    SliderTheme? a,
    SliderTheme? b,
    double t,
  ) => _$SliderTheme.lerp(a, b, t);
}
