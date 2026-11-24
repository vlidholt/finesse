import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'icon_tile.g.theme.dart';

/// The theme of `IconTile`: every value the widget does not set itself.
@themeGen
@immutable
class IconTileTheme with _$IconTileTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const IconTileTheme({
    bool canMerge = true,
    this.size,
    this.iconSize,
    this.radius,
    this.backgroundColor,
    this.foregroundColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The tile's width and height.
  final double? size;

  /// The size of the icon inside it.
  final double? iconSize;

  /// The corner radius.
  final BorderRadius? radius;

  /// The tile's fill.
  final Color? backgroundColor;

  /// The icon's colour.
  final Color? foregroundColor;

  /// Linearly interpolates between two themes.
  static IconTileTheme? lerp(IconTileTheme? a, IconTileTheme? b, double t) =>
      _$IconTileTheme.lerp(a, b, t);
}
