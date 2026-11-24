import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'sonner.g.theme.dart';

/// {@template SonnerTheme}
/// Theme for the `Sonner` widget.
/// {@endtemplate}
@themeGen
@immutable
class SonnerTheme with _$SonnerTheme {
  /// {@macro SonnerTheme}
  const SonnerTheme({
    bool canMerge = true,
    this.maxVisibleToasts,
    this.alignment,
    this.padding,
    this.expandedGap,
    this.collapsedGap,
    this.scaleFactor,
    this.animationDuration,
    this.animationCurve,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Sonner.visible_toasts_amount}
  final int? maxVisibleToasts;

  /// {@macro Sonner.alignment}
  final AlignmentGeometry? alignment;

  /// {@macro Sonner.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Sonner.expandedGap}
  final double? expandedGap;

  /// {@macro Sonner.collapsedGap}
  final double? collapsedGap;

  /// {@macro Sonner.scaleFactor}
  final double? scaleFactor;

  /// {@macro Sonner.animationDuration}
  final Duration? animationDuration;

  /// {@macro Sonner.animationCurve}
  final Curve? animationCurve;

  /// Linearly interpolates between [a] and [b] by [t].
  static SonnerTheme? lerp(
    SonnerTheme? a,
    SonnerTheme? b,
    double t,
  ) => _$SonnerTheme.lerp(a, b, t);
}
