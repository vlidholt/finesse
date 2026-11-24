import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'alert.g.theme.dart';

/// {@template AlertTheme}
/// Theme for the `Alert` widget.
/// {@endtemplate}
@themeGen
@immutable
class AlertTheme with _$AlertTheme {
  /// {@macro AlertTheme}
  const AlertTheme({
    bool canMerge = true,
    this.decoration,
    this.iconPadding,
    this.iconColor,
    this.iconSize,
    this.titleStyle,
    this.descriptionStyle,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.gap,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Alert.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Alert.iconPadding}
  final EdgeInsetsGeometry? iconPadding;

  /// {@macro Alert.iconColor}
  final Color? iconColor;

  /// {@macro Alert.title}
  final TextStyle? titleStyle;

  /// {@macro Alert.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Alert.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Alert.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Alert.iconSize}
  final double? iconSize;

  /// {@macro Alert.gap}
  final double? gap;

  /// Linearly interpolates between [a] and [b] by [t].
  static AlertTheme? lerp(
    AlertTheme? a,
    AlertTheme? b,
    double t,
  ) => _$AlertTheme.lerp(a, b, t);
}
