import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'badge.g.theme.dart';

/// {@template BadgeTheme}
/// Theme for the `Badge` widget.
/// {@endtemplate}
@themeGen
@immutable
class BadgeTheme with _$BadgeTheme {
  /// {@macro BadgeTheme}
  const BadgeTheme({
    bool canMerge = true,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.textStyle,
    this.iconSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Badge.borderRadius}
  final BorderRadius? borderRadius;

  /// The colour of the badge's outline; null draws none.
  final Color? borderColor;

  /// {@macro Badge.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Badge.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Badge.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Badge.textStyle}
  final TextStyle? textStyle;

  /// The size of the badge's icons. Defaults to 12.
  final double? iconSize;

  /// Linearly interpolates between [a] and [b] by [t].
  static BadgeTheme? lerp(
    BadgeTheme? a,
    BadgeTheme? b,
    double t,
  ) => _$BadgeTheme.lerp(a, b, t);
}
