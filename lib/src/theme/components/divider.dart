import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'divider.g.theme.dart';

/// {@template DividerTheme}
/// Theme for the `Divider` widget.
/// {@endtemplate}
@themeGen
@immutable
class DividerTheme with _$DividerTheme {
  /// {@macro DividerTheme}
  const DividerTheme({
    bool canMerge = true,
    this.verticalMargin,
    this.horizontalMargin,
    this.thickness,
    this.color,
    this.radius,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Divider.color}
  final Color? color;

  /// {@macro Divider.thickness}
  final double? thickness;

  /// The margin (or space) around the vertical divider.
  final EdgeInsetsGeometry? verticalMargin;

  /// The margin (or space) around the horizontal divider.
  final EdgeInsetsGeometry? horizontalMargin;

  /// {@macro Divider.radius}
  final BorderRadiusGeometry? radius;

  /// Linearly interpolates between [a] and [b] by [t].
  static DividerTheme? lerp(
    DividerTheme? a,
    DividerTheme? b,
    double t,
  ) => _$DividerTheme.lerp(a, b, t);
}
