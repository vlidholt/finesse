import 'package:flutter/foundation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;

// The package's own types that a LiquidGlassTheme is configured with. They
// are reached through this library, so no una file outside
// lib/src/liquid_glass/ imports the package.
export 'package:liquid_glass_widgets/liquid_glass_widgets.dart'
    show GlassQuality, GlassStyle, GlassThemeSettings;

/// When una draws a component with Liquid Glass instead of its own
/// frosted glass.
enum LiquidGlassMode {
  /// Liquid Glass on Apple platforms — iOS and macOS, natively or in a
  /// browser — and frosted glass everywhere else.
  auto,

  /// Liquid Glass on every platform.
  always,

  /// Never Liquid Glass: una's own frosted glass everywhere.
  never,
}

/// How una uses Liquid Glass: where it switches to it, and the
/// `liquid_glass_widgets` options it passes on.
///
/// ```dart
/// ThemeData(
///   liquidGlass: const LiquidGlassTheme(mode: LiquidGlassMode.always),
/// )
/// ```
///
/// [mode] decides for the whole theme; a component theme's own
/// `liquidGlass` (`AppBarTheme(liquidGlass: LiquidGlassMode.never)`) decides
/// for that component. Liquid Glass is never used when the system asks for
/// more contrast (see [respectSystemAccessibility]) or when its shaders
/// failed to load; una's frosted glass stands in.
///
/// The glass is tinted from the una colour scheme. [light] and [dark]
/// override any of the package's material settings on top of that, for
/// the brightness each names.
@immutable
class LiquidGlassTheme {
  /// Creates a Liquid Glass configuration.
  const LiquidGlassTheme({
    this.mode = LiquidGlassMode.auto,
    this.style = lg.GlassStyle.ios27,
    this.quality,
    this.adaptiveQuality = false,
    this.respectSystemAccessibility = true,
    this.tintFromColorScheme = true,
    this.webScrollEdge = false,
    this.light,
    this.dark,
  });

  /// Where Liquid Glass is used. Defaults to [LiquidGlassMode.auto].
  final LiquidGlassMode mode;

  /// The generation of the material: `GlassStyle.ios27` (the default) or
  /// `GlassStyle.ios26`. `GlassStyle.classic` is the package's earlier look.
  final lg.GlassStyle style;

  /// The rendering quality, or null for the package's own choice per
  /// component: `premium` for bars, overlays and lens controls, `standard`
  /// for the rest.
  ///
  /// `premium` needs Impeller's shader filters; where they are missing (the
  /// web, Skia) the package falls back to `standard` by itself.
  final lg.GlassQuality? quality;

  /// Whether the package measures frame times and lowers the quality on a
  /// device that cannot keep up. Experimental in the package.
  final bool adaptiveQuality;

  /// Whether Liquid Glass gives way to una's frosted glass when the
  /// system asks for more contrast (Increase Contrast on iOS and macOS, high
  /// contrast elsewhere), and whether the package honours Reduce Motion.
  final bool respectSystemAccessibility;

  /// Whether the glass takes its tint from the una colour scheme's bar
  /// colour. False keeps the package's own neutral tint.
  final bool tintFromColorScheme;

  /// Whether a Liquid Glass top bar keeps its soft scroll edge where the
  /// renderer has no shader image filters — every browser.
  ///
  /// The edge is the page under the bar blurred more the nearer it is to
  /// the top and faded into the page colour. On Impeller the package draws
  /// that graduated blur in one pass. A browser cannot, so there the bar is
  /// a solid bar by default (false): no blur and no transparency, which
  /// costs nothing. True draws the edge there as well, with una's own
  /// shader over a small snapshot of the page under the bar, taken every
  /// frame the edge shows. That copy of the page is the price: smooth to
  /// the eye, but more of a phone's frames come late while a page scrolls.
  ///
  /// A bar whose own `liquidGlass` is `LiquidGlassMode.always` asks for the
  /// glass outright and keeps the edge either way.
  final bool webScrollEdge;

  /// Material settings for a light theme, over the package's and the
  /// scheme's. Null fields keep theirs.
  final lg.GlassThemeSettings? light;

  /// Material settings for a dark theme, over the package's and the
  /// scheme's. Null fields keep theirs.
  final lg.GlassThemeSettings? dark;

  /// A copy with the given fields replaced.
  LiquidGlassTheme copyWith({
    LiquidGlassMode? mode,
    lg.GlassStyle? style,
    lg.GlassQuality? quality,
    bool? adaptiveQuality,
    bool? respectSystemAccessibility,
    bool? tintFromColorScheme,
    bool? webScrollEdge,
    lg.GlassThemeSettings? light,
    lg.GlassThemeSettings? dark,
  }) {
    return LiquidGlassTheme(
      mode: mode ?? this.mode,
      style: style ?? this.style,
      quality: quality ?? this.quality,
      adaptiveQuality: adaptiveQuality ?? this.adaptiveQuality,
      respectSystemAccessibility:
          respectSystemAccessibility ?? this.respectSystemAccessibility,
      tintFromColorScheme: tintFromColorScheme ?? this.tintFromColorScheme,
      webScrollEdge: webScrollEdge ?? this.webScrollEdge,
      light: light ?? this.light,
      dark: dark ?? this.dark,
    );
  }

  /// Liquid Glass is switched, not interpolated: [a] until halfway, then
  /// [b].
  static LiquidGlassTheme? lerp(
    LiquidGlassTheme? a,
    LiquidGlassTheme? b,
    double t,
  ) => t < .5 ? a : b;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidGlassTheme &&
          other.mode == mode &&
          other.style == style &&
          other.quality == quality &&
          other.adaptiveQuality == adaptiveQuality &&
          other.respectSystemAccessibility == respectSystemAccessibility &&
          other.tintFromColorScheme == tintFromColorScheme &&
          other.webScrollEdge == webScrollEdge &&
          other.light == light &&
          other.dark == dark;

  @override
  int get hashCode => Object.hash(
    mode,
    style,
    quality,
    adaptiveQuality,
    respectSystemAccessibility,
    tintFromColorScheme,
    webScrollEdge,
    light,
    dark,
  );

  @override
  String toString() =>
      'LiquidGlassTheme(mode: ${mode.name}, style: ${style.name}, '
      'quality: ${quality?.name})';
}
