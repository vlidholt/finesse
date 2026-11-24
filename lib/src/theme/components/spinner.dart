import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'spinner.g.theme.dart';

/// {@template SpinnerTheme}
/// Theme for the `Spinner` widget.
/// {@endtemplate}
@themeGen
@immutable
class SpinnerTheme with _$SpinnerTheme {
  /// {@macro SpinnerTheme}
  const SpinnerTheme({
    bool canMerge = true,
    this.color,
    this.trackColor,
    this.size,
    this.strokeWidth,
    this.duration,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Spinner.color}
  final Color? color;

  /// {@macro Spinner.trackColor}
  final Color? trackColor;

  /// {@macro Spinner.size}
  final double? size;

  /// {@macro Spinner.strokeWidth}
  final double? strokeWidth;

  /// {@macro Spinner.duration}
  final Duration? duration;

  /// Linearly interpolates between [a] and [b] by [t].
  static SpinnerTheme? lerp(
    SpinnerTheme? a,
    SpinnerTheme? b,
    double t,
  ) => _$SpinnerTheme.lerp(a, b, t);
}
