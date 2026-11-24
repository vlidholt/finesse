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
    this.shape,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.padding,
    this.cursor,
    this.textStyle,
    this.iconSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Badge.shape}
  final ShapeBorder? shape;

  /// {@macro Badge.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Badge.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Badge.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Badge.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Badge.cursor}
  final MouseCursor? cursor;

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
