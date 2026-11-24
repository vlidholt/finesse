import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'otp_field.g.theme.dart';

/// {@template OtpFieldTheme}
/// Theme for the `OtpField` widget.
/// {@endtemplate}
@themeGen
@immutable
class OtpFieldTheme with _$OtpFieldTheme {
  /// {@macro OtpFieldTheme}
  const OtpFieldTheme({
    bool canMerge = true,
    this.gap,
    this.style,
    this.width,
    this.height,
    this.padding,
    this.decoration,
    this.firstRadius,
    this.lastRadius,
    this.singleRadius,
    this.middleRadius,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro OtpField.gap}
  final double? gap;

  /// {@macro OtpFieldSlot.style}
  final TextStyle? style;

  /// {@macro OtpFieldSlot.width}
  final double? width;

  /// {@macro OtpFieldSlot.height}
  final double? height;

  /// {@macro OtpFieldSlot.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro OtpFieldSlot.decoration}
  final FinesseDecoration? decoration;

  /// {@macro OtpFieldSlot.firstRadius}
  final BorderRadius? firstRadius;

  /// {@macro OtpFieldSlot.lastRadius}
  final BorderRadius? lastRadius;

  /// {@macro OtpFieldSlot.singleRadius}
  final BorderRadius? singleRadius;

  /// {@macro OtpFieldSlot.middleRadius}
  final BorderRadius? middleRadius;

  /// Linearly interpolates between [a] and [b] by [t].
  static OtpFieldTheme? lerp(
    OtpFieldTheme? a,
    OtpFieldTheme? b,
    double t,
  ) => _$OtpFieldTheme.lerp(a, b, t);
}
