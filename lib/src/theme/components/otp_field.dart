import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/theme/components/decorator.dart';

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
    this.firstBorderRadius,
    this.lastBorderRadius,
    this.singleBorderRadius,
    this.middleBorderRadius,
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
  final UnaDecoration? decoration;

  /// {@macro OtpFieldSlot.firstBorderRadius}
  final BorderRadius? firstBorderRadius;

  /// {@macro OtpFieldSlot.lastBorderRadius}
  final BorderRadius? lastBorderRadius;

  /// {@macro OtpFieldSlot.singleBorderRadius}
  final BorderRadius? singleBorderRadius;

  /// {@macro OtpFieldSlot.middleBorderRadius}
  final BorderRadius? middleBorderRadius;

  /// Linearly interpolates between [a] and [b] by [t].
  static OtpFieldTheme? lerp(
    OtpFieldTheme? a,
    OtpFieldTheme? b,
    double t,
  ) => _$OtpFieldTheme.lerp(a, b, t);
}
