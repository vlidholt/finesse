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
    this.successColor,
    this.successBackgroundColor,
    this.warningColor,
    this.warningBackgroundColor,
    this.infoColor,
    this.infoBackgroundColor,
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

  /// The colour of a success alert's icon and edge. Read from the primary
  /// alert theme: the tinted variants are that alert in another colour.
  final Color? successColor;

  /// The fill of a success alert.
  final Color? successBackgroundColor;

  /// The colour of a warning alert's icon and edge.
  final Color? warningColor;

  /// The fill of a warning alert.
  final Color? warningBackgroundColor;

  /// The colour of an info alert's icon and edge.
  final Color? infoColor;

  /// The fill of an info alert.
  final Color? infoBackgroundColor;

  /// Linearly interpolates between [a] and [b] by [t].
  static AlertTheme? lerp(
    AlertTheme? a,
    AlertTheme? b,
    double t,
  ) => _$AlertTheme.lerp(a, b, t);
}
