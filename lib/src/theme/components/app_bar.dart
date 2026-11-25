import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'app_bar.g.theme.dart';

/// When an app bar shows its surface: the fill, the hairline under it and
/// the blur of what scrolls beneath.
enum AppBarSurfaceBehavior {
  /// The surface is always there.
  always,

  /// The bar is bare while the page is at its top and takes its surface
  /// once content has scrolled under it — the way a large title sits on
  /// the page until the page moves.
  whenScrolled,
}

/// The theme of `AppBar`: every value the widget does not set itself.
@themeGen
@immutable
class AppBarTheme with _$AppBarTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const AppBarTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.blur,
    this.saturation,
    this.padding,
    this.maxWidth,
    this.gap,
    this.titleStyle,
    this.centerTitle,
    this.surfaceBehavior,
    this.largeTitleStyle,
    this.expandedHeight,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether the app bar draws with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// The bar's height, not counting the safe area above it.
  final double? height;

  /// The bar's fill. A translucent colour blurs what scrolls beneath.
  final Color? backgroundColor;

  /// The colour of the bar's icons and text.
  final Color? foregroundColor;

  /// The colour of the hairline under the bar.
  final Color? borderColor;

  /// The sigma of the backdrop blur under a translucent bar.
  final double? blur;

  /// How much the backdrop is saturated.
  final double? saturation;

  /// Padding around the bar's content.
  final EdgeInsetsGeometry? padding;

  /// The widest the bar's content grows before it is centred.
  final double? maxWidth;

  /// The gap between the bar's leading, middle and trailing parts.
  final double? gap;

  /// The style of the bar's title.
  final TextStyle? titleStyle;

  /// Whether the title is centred in the bar rather than set after the
  /// leading widget.
  final bool? centerTitle;

  /// When the bar shows its surface.
  final AppBarSurfaceBehavior? surfaceBehavior;

  /// The style of the large title of a `SliverAppBar.large`.
  final TextStyle? largeTitleStyle;

  /// The height of the area under the toolbar of a `SliverAppBar.large`
  /// while it is fully expanded. Null fits the large title, with the layout
  /// gap above and below it.
  final double? expandedHeight;

  /// Linearly interpolates between two themes.
  static AppBarTheme? lerp(AppBarTheme? a, AppBarTheme? b, double t) =>
      _$AppBarTheme.lerp(a, b, t);
}
