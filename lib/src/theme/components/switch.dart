import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'switch.g.theme.dart';

/// {@template SwitchTheme}
/// Theme for the `Switch` widget.
/// {@endtemplate}
@themeGen
@immutable
class SwitchTheme with _$SwitchTheme {
  /// {@macro SwitchTheme}
  const SwitchTheme({
    bool canMerge = true,
    this.thumbColor,
    this.uncheckedTrackColor,
    this.checkedTrackColor,
    this.width,
    this.height,
    this.margin,
    this.duration,
    this.decoration,
    this.padding,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Switch.thumbColor}
  final Color? thumbColor;

  /// {@macro Switch.uncheckedTrackColor}
  final Color? uncheckedTrackColor;

  /// {@macro Switch.checkedTrackColor}
  final Color? checkedTrackColor;

  /// {@macro Switch.width}
  final double? width;

  /// {@macro Switch.height}
  final double? height;

  /// {@macro Switch.margin}
  final double? margin;

  /// {@macro Switch.duration}
  final Duration? duration;

  /// {@macro Switch.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Switch.padding}
  final EdgeInsetsGeometry? padding;

  /// Linearly interpolates between [a] and [b] by [t].
  static SwitchTheme? lerp(
    SwitchTheme? a,
    SwitchTheme? b,
    double t,
  ) => _$SwitchTheme.lerp(a, b, t);
}
