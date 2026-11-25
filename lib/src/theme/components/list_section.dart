import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'list_section.g.theme.dart';

/// The theme of `ListSection`: every value the widget does not set itself.
///
/// The card a section's rows sit on is a `Card`, so its outline, shadow and
/// glass come from the `CardTheme`; this theme holds what is the section's
/// own.
@themeGen
@immutable
class ListSectionTheme with _$ListSectionTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const ListSectionTheme({
    bool canMerge = true,
    this.margin,
    this.backgroundColor,
    this.radius,
    this.headerStyle,
    this.footerStyle,
    this.headerPadding,
    this.footerPadding,
    this.tilePadding,
    this.minTileHeight,
    this.dividerColor,
    this.dividerThickness,
    this.pressedColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The space around the whole section: header, rows and footer.
  final EdgeInsetsGeometry? margin;

  /// The fill of the card under the rows. Null uses the card theme's.
  final Color? backgroundColor;

  /// The corners of the card under the rows. Null uses the card theme's.
  final BorderRadius? radius;

  /// The style of the header: the theme's overline role in the muted
  /// colour.
  final TextStyle? headerStyle;

  /// The style of the footer: a muted caption.
  final TextStyle? footerStyle;

  /// The padding around the header. Its horizontal part lines the header up
  /// with the rows' text.
  final EdgeInsetsGeometry? headerPadding;

  /// The padding around the footer.
  final EdgeInsetsGeometry? footerPadding;

  /// The padding of a `ListTile` inside a section, in place of the list
  /// tile theme's.
  final EdgeInsetsGeometry? tilePadding;

  /// The least height of a `ListTile` inside a section: a touch target on a
  /// phone.
  final double? minTileHeight;

  /// The colour of the hairline between two rows.
  final Color? dividerColor;

  /// The thickness of the hairline between two rows.
  final double? dividerThickness;

  /// The fill of a row while it is pressed. Rows of a section do not scale
  /// under a press; they darken.
  final Color? pressedColor;

  /// Linearly interpolates between two themes.
  static ListSectionTheme? lerp(
    ListSectionTheme? a,
    ListSectionTheme? b,
    double t,
  ) => _$ListSectionTheme.lerp(a, b, t);
}
