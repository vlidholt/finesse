import 'package:flutter/widgets.dart';

/// Adds [fallback] to [TextStyle].
extension TextStyleExtension on TextStyle {
  /// Returns a new TextStyle where any null property is replaced by the
  /// corresponding property if passed as a parameter. If both are null, the
  /// property remains null.
  TextStyle fallback({
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    TextOverflow? overflow,
  }) {
    // Only the values this style is missing are passed on, and through
    // `copyWith` rather than a new `TextStyle`: a style that resolves its
    // family per weight (`BuilderTextStyle`) has to stay one, and `inherit`
    // has to survive.
    T? missing<T>(T? currentValue, T? newValue) =>
        currentValue == null ? newValue : null;

    return copyWith(
      color: missing(this.color, color),
      backgroundColor: missing(this.backgroundColor, backgroundColor),
      fontSize: missing(this.fontSize, fontSize),
      fontWeight: missing(this.fontWeight, fontWeight),
      fontStyle: missing(this.fontStyle, fontStyle),
      letterSpacing: missing(this.letterSpacing, letterSpacing),
      wordSpacing: missing(this.wordSpacing, wordSpacing),
      textBaseline: missing(this.textBaseline, textBaseline),
      height: missing(this.height, height),
      leadingDistribution: missing(
        this.leadingDistribution,
        leadingDistribution,
      ),
      locale: missing(this.locale, locale),
      foreground: missing(this.foreground, foreground),
      background: missing(this.background, background),
      shadows: missing(this.shadows, shadows),
      fontFeatures: missing(this.fontFeatures, fontFeatures),
      fontVariations: missing(this.fontVariations, fontVariations),
      decoration: missing(this.decoration, decoration),
      decorationColor: missing(this.decorationColor, decorationColor),
      decorationStyle: missing(this.decorationStyle, decorationStyle),
      decorationThickness: missing(
        this.decorationThickness,
        decorationThickness,
      ),
      debugLabel: missing(this.debugLabel, debugLabel),
      fontFamily: missing(this.fontFamily, fontFamily),
      fontFamilyFallback: missing(this.fontFamilyFallback, fontFamilyFallback),
      overflow: missing(this.overflow, overflow),
    );
  }
}
