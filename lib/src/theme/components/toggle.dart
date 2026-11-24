import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'toggle.g.theme.dart';

/// {@template ToggleTheme}
/// Theme for the `Toggle` widget.
/// {@endtemplate}
@themeGen
@immutable
class ToggleTheme with _$ToggleTheme {
  /// {@macro ToggleTheme}
  const ToggleTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.selectedBackgroundColor,
    this.selectedHoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.selectedForegroundColor,
    this.padding,
    this.decoration,
    this.textStyle,
    this.gap,
    this.height,
    this.iconSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Toggle.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Toggle.hoverBackgroundColor}
  final Color? hoverBackgroundColor;

  /// {@macro Toggle.selectedBackgroundColor}
  final Color? selectedBackgroundColor;

  /// {@macro Toggle.selectedHoverBackgroundColor}
  final Color? selectedHoverBackgroundColor;

  /// {@macro Toggle.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Toggle.hoverForegroundColor}
  final Color? hoverForegroundColor;

  /// {@macro Toggle.selectedForegroundColor}
  final Color? selectedForegroundColor;

  /// {@macro Toggle.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Toggle.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Toggle.textStyle}
  final TextStyle? textStyle;

  /// The gap between the leading icon and the label.
  final double? gap;

  /// The height of the toggle.
  final double? height;

  /// The size of the toggle's icons. Defaults to 16.
  final double? iconSize;

  /// Linearly interpolates between [a] and [b] by [t].
  static ToggleTheme? lerp(
    ToggleTheme? a,
    ToggleTheme? b,
    double t,
  ) => _$ToggleTheme.lerp(a, b, t);
}
