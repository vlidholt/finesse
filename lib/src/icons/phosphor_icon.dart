import 'package:flutter/widgets.dart';
import 'package:una/src/icons/thickened_glyph.dart';
import 'package:una/src/theme/components/phosphor_icon.dart';
import 'package:una/src/theme/theme.dart';

/// An [Icon] that keeps a small Phosphor icon's line from thinning with its
/// size.
///
/// ```dart
/// const PhosphorIcon(PhosphorIconsRegular.house)
/// ```
///
/// The regular Phosphor weight draws its line a sixteenth of the icon's
/// size: 1.5 logical pixels at 24, 1 at 16 and 0.75 at 12, so small icons
/// look thin beside large ones. This widget resolves its size exactly as an
/// [Icon] does — its own [size], else the ambient [IconTheme]'s, scaled
/// with the text when [applyTextScaling] says so — and, for a
/// `PhosphorIconsRegular` icon smaller than the theme's
/// `PhosphorIconTheme.referenceSize` (24), draws the regular glyph with a
/// fine outline of its own colour around it. The outline adds to every
/// line what `PhosphorIconTheme.strength` says it should make up: at the
/// default 0.5, 1.25 pixels at 16 and 1.125 at 12. The thickening is
/// continuous, so two neighbouring sizes never differ by a step, and it
/// uses the regular font alone.
///
/// Only `PhosphorIconsRegular` icons are thickened. An icon of
/// `PhosphorIconsBold`, `Light`, `Thin` or `Fill` is the caller's own
/// choice of weight and is drawn as given, as is an icon from any other
/// font, an icon at or above the reference size, and every icon under a
/// theme whose strength is 0. For those this is an [Icon] in every
/// respect. To pin one small regular icon to the font's own line, use a
/// plain [Icon].
///
/// The icon's box is the same as an [Icon]'s. The outline is not clipped
/// to it: where a glyph touches the edge of its square, half the outline —
/// a fifth of a pixel at most by default — is painted outside.
///
/// ## In tests
///
/// A `PhosphorIcon` *is* an [Icon] and [icon] is the constant it was
/// given, and it builds no second [Icon] beneath itself. So
/// `find.byIcon(PhosphorIconsRegular.house)` and `find.widgetWithIcon`
/// find it, once, and `tester.widget<Icon>(...)` reads it.
/// `find.byType(Icon)` does not: that finder matches the exact type, so use
/// `find.byType(PhosphorIcon)`, or `find.bySubtype<Icon>()` for both. A
/// thickened icon has no `RichText` beneath it; it paints its glyph itself.
class PhosphorIcon extends Icon {
  /// Creates an icon; every parameter is [Icon]'s.
  const PhosphorIcon(
    super.icon, {
    super.key,
    super.size,
    super.fill,
    super.weight,
    super.grade,
    super.opticalSize,
    super.color,
    super.shadows,
    super.semanticLabel,
    super.textDirection,
    super.applyTextScaling,
    super.blendMode,
    super.fontWeight,
  });

  static const double _negligible = .01;

  /// Whether [icon] is a glyph of `PhosphorIconsRegular`: the only icons
  /// whose line is thickened.
  static bool adapts(IconData icon) =>
      icon.fontFamily == 'PhosphorRegular' && icon.fontPackage == 'una';

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    if (icon == null || !adapts(icon)) return super.build(context);
    final policy =
        Theme.maybeOf(context)?.phosphorIconTheme ?? const PhosphorIconTheme();

    // From here to the style, this is Icon.build: the same size, colour and
    // font, so that the glyph beneath the outline is the one an Icon draws.
    final iconTheme = IconTheme.of(context);
    final scales = applyTextScaling ?? iconTheme.applyTextScaling ?? false;
    final nominal = size ?? iconTheme.size ?? kDefaultFontSize;
    final iconSize = scales
        ? MediaQuery.textScalerOf(context).scale(nominal)
        : nominal;

    // Under a hundredth of a pixel there is nothing to see, and a second
    // paint is not worth it.
    final outline = policy.extraStroke(iconSize);
    if (!(outline >= _negligible)) return super.build(context);

    assert(
      this.textDirection != null || debugCheckHasDirectionality(context),
      'A PhosphorIcon needs a text direction.',
    );
    final textDirection = this.textDirection ?? Directionality.of(context);
    final iconFill = fill ?? iconTheme.fill;
    final iconWeight = weight ?? iconTheme.weight;
    final iconGrade = grade ?? iconTheme.grade;
    final iconOpticalSize = opticalSize ?? iconTheme.opticalSize;
    final opacity = iconTheme.opacity ?? 1.0;
    var iconColor = color ?? iconTheme.color!;
    if (opacity != 1.0) {
      iconColor = iconColor.withValues(alpha: iconColor.a * opacity);
    }

    Widget glyph = ThickenedGlyph(
      glyph: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        inherit: false,
        fontVariations: [
          if (iconFill != null) FontVariation('FILL', iconFill),
          if (iconWeight != null) FontVariation('wght', iconWeight),
          if (iconGrade != null) FontVariation('GRAD', iconGrade),
          if (iconOpticalSize != null) FontVariation('opsz', iconOpticalSize),
        ],
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        fontWeight: fontWeight,
        package: icon.fontPackage,
        fontFamilyFallback: icon.fontFamilyFallback,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      color: iconColor,
      outline: outline,
      textDirection: textDirection,
      shadows: shadows ?? iconTheme.shadows,
      blendMode: blendMode,
    );

    if (icon.matchTextDirection && textDirection == TextDirection.rtl) {
      glyph = Transform.flip(
        flipX: true,
        transformHitTests: false,
        child: glyph,
      );
    }

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(width: iconSize, height: iconSize, child: glyph),
      ),
    );
  }
}
