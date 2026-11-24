import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'skeleton.g.theme.dart';

/// {@template SkeletonTheme}
/// Theme for the `Skeleton` widget.
/// {@endtemplate}
@themeGen
@immutable
class SkeletonTheme with _$SkeletonTheme {
  /// {@macro SkeletonTheme}
  const SkeletonTheme({
    bool canMerge = true,
    this.color,
    this.highlightColor,
    this.radius,
    this.duration,
    this.curve,
    this.animate,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Skeleton.color}
  final Color? color;

  /// {@macro Skeleton.highlightColor}
  final Color? highlightColor;

  /// {@macro Skeleton.radius}
  final BorderRadiusGeometry? radius;

  /// {@macro Skeleton.duration}
  final Duration? duration;

  /// {@macro Skeleton.curve}
  final Curve? curve;

  /// {@macro Skeleton.animate}
  final bool? animate;

  /// Linearly interpolates between [a] and [b] by [t].
  static SkeletonTheme? lerp(
    SkeletonTheme? a,
    SkeletonTheme? b,
    double t,
  ) => _$SkeletonTheme.lerp(a, b, t);
}
