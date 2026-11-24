import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'scroll_area.g.theme.dart';

/// {@template ScrollAreaTheme}
/// Theme for `ScrollArea` and `Scrollbar`.
/// {@endtemplate}
@themeGen
@immutable
class ScrollAreaTheme with _$ScrollAreaTheme {
  /// {@macro ScrollAreaTheme}
  const ScrollAreaTheme({
    bool canMerge = true,
    this.thickness,
    this.crossAxisMargin,
    this.mainAxisMargin,
    this.radius,
    this.thumbColor,
    this.thumbVisibility,
    this.fadeDuration,
    this.timeToFade,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Scrollbar.thickness}
  final double? thickness;

  /// {@macro Scrollbar.crossAxisMargin}
  final double? crossAxisMargin;

  /// {@macro Scrollbar.mainAxisMargin}
  final double? mainAxisMargin;

  /// {@macro Scrollbar.radius}
  final Radius? radius;

  /// {@macro Scrollbar.thumbColor}
  final Color? thumbColor;

  /// {@macro Scrollbar.thumbVisibility}
  final bool? thumbVisibility;

  /// {@macro Scrollbar.fadeDuration}
  final Duration? fadeDuration;

  /// {@macro Scrollbar.timeToFade}
  final Duration? timeToFade;

  /// Linearly interpolates between [a] and [b] by [t].
  static ScrollAreaTheme? lerp(
    ScrollAreaTheme? a,
    ScrollAreaTheme? b,
    double t,
  ) => _$ScrollAreaTheme.lerp(a, b, t);
}
