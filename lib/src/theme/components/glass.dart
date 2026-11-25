import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'glass.g.theme.dart';

/// The theme of `Glass`: every value the widget does not set itself.
@themeGen
@immutable
class GlassTheme with _$GlassTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const GlassTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.blur,
    this.saturation,
    this.color,
    this.opacity,
    this.strongOpacity,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether `Glass` draws with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// The sigma of the backdrop blur.
  final double? blur;

  /// How much the backdrop is saturated; 1 leaves it alone.
  final double? saturation;

  /// The tint laid over the blurred backdrop, before [opacity] is applied.
  final Color? color;

  /// The tint's opacity at `GlassLevel.regular`.
  final double? opacity;

  /// The tint's opacity at `GlassLevel.strong`.
  final double? strongOpacity;

  /// The colour of the hairline around the surface.
  final Color? borderColor;

  /// The width of the hairline around the surface.
  final double? borderWidth;

  /// The corner radius.
  final BorderRadius? borderRadius;

  /// Linearly interpolates between two themes.
  static GlassTheme? lerp(GlassTheme? a, GlassTheme? b, double t) =>
      _$GlassTheme.lerp(a, b, t);
}
