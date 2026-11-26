import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/theme/motion.dart';

part 'progress_bar.g.theme.dart';

/// {@template ProgressBarTheme}
/// Theme for the `ProgressBar` widget.
/// {@endtemplate}
@themeGen
@immutable
class ProgressBarTheme with _$ProgressBarTheme {
  /// {@macro ProgressBarTheme}
  const ProgressBarTheme({
    bool canMerge = true,
    this.trackColor,
    this.color,
    this.borderRadius,
    this.innerBorderRadius,
    this.spring,
    this.height,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro ProgressBar.trackColor}
  final Color? trackColor;

  /// {@macro ProgressBar.color}
  final Color? color;

  /// {@macro ProgressBar.borderRadius}
  final BorderRadius? borderRadius;

  /// {@macro ProgressBar.innerBorderRadius}
  final BorderRadius? innerBorderRadius;

  /// The spring a determinate bar glides to a new value with. Defaults to the
  /// theme's `Motion.smooth`; `MotionSpring.instant` moves it at once.
  final MotionSpring? spring;

  /// {@macro ProgressBar.height}
  final double? height;

  /// Linearly interpolates between [a] and [b] by [t].
  static ProgressBarTheme? lerp(
    ProgressBarTheme? a,
    ProgressBarTheme? b,
    double t,
  ) => _$ProgressBarTheme.lerp(a, b, t);
}
