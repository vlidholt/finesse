import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'empty.g.theme.dart';

/// {@template EmptyTheme}
/// Theme for the `Empty` widget.
/// {@endtemplate}
@themeGen
@immutable
class EmptyTheme with _$EmptyTheme {
  /// {@macro EmptyTheme}
  const EmptyTheme({
    bool canMerge = true,
    this.padding,
    this.gap,
    this.iconSize,
    this.iconColor,
    this.titleStyle,
    this.descriptionStyle,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Empty.padding}
  final EdgeInsetsGeometry? padding;

  /// The vertical gap between the icon, title, description and actions.
  final double? gap;

  /// {@macro Empty.iconSize}
  final double? iconSize;

  /// The color applied to the icon.
  final Color? iconColor;

  /// {@macro Empty.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro Empty.descriptionStyle}
  final TextStyle? descriptionStyle;

  /// {@macro Empty.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Empty.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// Linearly interpolates between [a] and [b] by [t].
  static EmptyTheme? lerp(
    EmptyTheme? a,
    EmptyTheme? b,
    double t,
  ) => _$EmptyTheme.lerp(a, b, t);
}
