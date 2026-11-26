import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/utils/border.dart';

part 'card.g.theme.dart';

/// {@template CardTheme}
/// Theme for the `Card` widget.
/// {@endtemplate}
@themeGen
@immutable
class CardTheme with _$CardTheme {
  /// {@macro CardTheme}
  const CardTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.border,
    this.shadows,
    this.width,
    this.height,
    this.rowMainAxisAlignment,
    this.rowCrossAxisAlignment,
    this.columnMainAxisAlignment,
    this.columnCrossAxisAlignment,
    this.rowMainAxisSize,
    this.columnMainAxisSize,
    this.clipBehavior,
    this.titleStyle,
    this.descriptionStyle,
    this.gap,
    this.sectionGap,
    this.blur,
    this.saturation,
    this.pressScale,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The padding inside the card, surrounding all content.
  /// Defaults to EdgeInsets.all(24) if not specified.
  final EdgeInsetsGeometry? padding;

  /// The background color of the card.
  /// Defaults to the theme’s card color if not specified.
  final Color? backgroundColor;

  /// The border radius of the card’s corners.
  /// Defaults to the theme’s radius if not specified.
  final BorderRadius? borderRadius;

  /// The border surrounding the card.
  /// Defaults to a border with the theme’s border color if not specified.
  final UnaBorder? border;

  /// The list of box shadows applied to the card for elevation.
  /// Defaults to the theme’s card shadows if not specified.
  final List<BoxShadow>? shadows;

  /// The explicit width of the card.
  /// If null, the card sizes to its content or constraints.
  final double? width;

  /// The explicit height of the card.
  /// If null, the card sizes to its content or constraints.
  final double? height;

  /// The main axis alignment of the card’s row (horizontal).
  /// Defaults to [MainAxisAlignment.spaceBetween] if not specified.
  final MainAxisAlignment? rowMainAxisAlignment;

  /// The cross axis alignment of the card’s row (vertical).
  /// Defaults to [CrossAxisAlignment.start] if not specified.
  final CrossAxisAlignment? rowCrossAxisAlignment;

  /// The main axis alignment of the card’s column (vertical).
  /// Defaults to [MainAxisAlignment.start] if not specified.
  final MainAxisAlignment? columnMainAxisAlignment;

  /// The cross axis alignment of the card’s column (horizontal).
  /// Defaults to [CrossAxisAlignment.start] if not specified.
  final CrossAxisAlignment? columnCrossAxisAlignment;

  /// The main axis size of the card’s row.
  /// Defaults to [MainAxisSize.min] if not specified.
  final MainAxisSize? rowMainAxisSize;

  /// The main axis size of the card’s column.
  /// Defaults to [MainAxisSize.min] if not specified.
  final MainAxisSize? columnMainAxisSize;

  /// The clip behavior of the card, controlling how content is clipped.
  /// Defaults to [Clip.antiAlias] if not specified.
  final Clip? clipBehavior;

  /// The text style of the card's `title`.
  final TextStyle? titleStyle;

  /// The text style of the card's `description`.
  final TextStyle? descriptionStyle;

  /// The vertical space between the title, description, content and footer.
  final double? gap;

  /// The space between a card's sections — header, content and footer —
  /// shadcn's `gap-(--card-spacing)`. [gap] stays the small gap between the
  /// title and its description. Null falls back to [gap].
  final double? sectionGap;

  /// The sigma of the backdrop blur behind a translucent card; 0 for none.
  final double? blur;

  /// How much a blurred card saturates its backdrop; 1 leaves it alone.
  final double? saturation;

  /// The scale of a pressable card while it is pressed; a paint-time
  /// transform that springs back on release. Defaults to the theme's
  /// `Motion.surfacePressScale`; 1 disables it.
  final double? pressScale;

  /// Linearly interpolates between [a] and [b] by [t].
  static CardTheme? lerp(
    CardTheme? a,
    CardTheme? b,
    double t,
  ) => _$CardTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is CardTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
