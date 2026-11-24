import 'package:flutter/widgets.dart';

/// A duotone Phosphor icon: the [primary] outline and the [secondary] shape
/// that is drawn beneath it at a low opacity.
///
/// The constants are in `PhosphorIconsDuotone`; a [PhosphorDuotoneIcon]
/// draws one.
@immutable
class PhosphorDuotoneIconData {
  /// Creates the data for a duotone icon from its two glyphs.
  ///
  /// [secondary] is null for the few icons that have no fill layer.
  const PhosphorDuotoneIconData(this.primary, [this.secondary]);

  /// The outline, drawn at full opacity.
  final IconData primary;

  /// The fill, drawn beneath [primary] at a low opacity, or null for an icon
  /// that is a single layer.
  final IconData? secondary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhosphorDuotoneIconData &&
          other.primary == primary &&
          other.secondary == secondary);

  @override
  int get hashCode => Object.hash(primary, secondary);
}

/// Draws a duotone Phosphor icon.
///
/// ```dart
/// const PhosphorDuotoneIcon(PhosphorIconsDuotone.bellRinging, size: 24)
/// ```
///
/// Size and colour default to the ambient [IconTheme], exactly as an [Icon]'s
/// do. The fill layer takes the same colour at [secondaryOpacity] unless
/// [secondaryColor] gives it its own.
class PhosphorDuotoneIcon extends StatelessWidget {
  /// Creates a duotone icon.
  const PhosphorDuotoneIcon(
    this.icon, {
    this.size,
    this.color,
    this.secondaryColor,
    this.secondaryOpacity = .2,
    this.semanticLabel,
    this.textDirection,
    super.key,
  }) : assert(
         secondaryOpacity >= 0 && secondaryOpacity <= 1,
         'secondaryOpacity must be between 0 and 1',
       );

  /// The icon to draw.
  final PhosphorDuotoneIconData icon;

  /// The icon's size in logical pixels. Defaults to the [IconTheme]'s.
  final double? size;

  /// The outline's colour. Defaults to the [IconTheme]'s.
  final Color? color;

  /// The fill's colour, before [secondaryOpacity]. Defaults to [color].
  final Color? secondaryColor;

  /// The opacity of the fill layer.
  final double secondaryOpacity;

  /// What assistive technology reads for the icon.
  final String? semanticLabel;

  /// The direction to draw the icon in, for one that mirrors.
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final primaryColor = color ?? theme.color;
    final fill = secondaryColor ?? primaryColor;
    final outline = Icon(
      icon.primary,
      size: size,
      color: primaryColor,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
    final secondary = icon.secondary;
    if (secondary == null) return outline;
    return Stack(
      alignment: Alignment.center,
      children: [
        ExcludeSemantics(
          child: Icon(
            secondary,
            size: size,
            color: fill?.withValues(alpha: fill.a * secondaryOpacity),
            textDirection: textDirection,
          ),
        ),
        outline,
      ],
    );
  }
}
