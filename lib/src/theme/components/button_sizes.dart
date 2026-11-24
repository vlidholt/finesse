// The theme for an individual size of Button.
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'button_sizes.g.theme.dart';

/// {@template ButtonSizeTheme}
/// The metrics of one `Button` size: its height, padding and icon size.
/// {@endtemplate}
@themeGen
@immutable
class ButtonSizeTheme with _$ButtonSizeTheme {
  /// {@macro ButtonSizeTheme}
  const ButtonSizeTheme({
    bool canMerge = true,
    required this.height,
    required this.padding,
    this.width,
    this.iconSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The button's height.
  final double height;

  /// The padding around the button's content.
  final EdgeInsetsGeometry padding;

  /// A fixed width. The icon sizes set it to make a square button. Null lets
  /// the button size itself to its content.
  final double? width;

  /// Size handed to icons inside the button, shadcn's
  /// `[&_svg:not([class*='size-'])]:size-4`.
  ///
  /// Null falls back to the ambient [IconTheme]; an icon that sets its own
  /// size always wins, as the `:not` in the reference selector does.
  final double? iconSize;

  /// Linearly interpolates between [a] and [b] by [t].
  static ButtonSizeTheme? lerp(
    ButtonSizeTheme? a,
    ButtonSizeTheme? b,
    double t,
  ) {
    return _$ButtonSizeTheme.lerp(a, b, t);
  }
}

/// {@template ButtonSizesTheme}
/// The theme for the predefined sizes of Button.
/// {@endtemplate}
@themeGen
@immutable
class ButtonSizesTheme with _$ButtonSizesTheme {
  /// {@macro ButtonSizesTheme}
  const ButtonSizesTheme({
    bool canMerge = true,
    this.regular,
    this.sm,
    this.lg,
    this.icon,
    this.iconSm,
    this.iconLg,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The default size, shadcn's `size-default`.
  final ButtonSizeTheme? regular;

  /// The small size, shadcn's `size-sm`.
  final ButtonSizeTheme? sm;

  /// The large size, shadcn's `size-lg`.
  final ButtonSizeTheme? lg;

  /// The square sizes, shadcn's `size-icon`, `size-icon-sm` and
  /// `size-icon-lg`.
  ///
  /// Separate from [sm]/[lg] because the reference sizes an icon button's
  /// glyph independently of a text button's at the same step.
  final ButtonSizeTheme? icon;

  /// The small square size, shadcn's `size-icon-sm`. See [icon].
  final ButtonSizeTheme? iconSm;

  /// The large square size, shadcn's `size-icon-lg`. See [icon].
  final ButtonSizeTheme? iconLg;

  /// Linearly interpolates between [a] and [b] by [t].
  static ButtonSizesTheme? lerp(
    ButtonSizesTheme? a,
    ButtonSizesTheme? b,
    double t,
  ) => _$ButtonSizesTheme.lerp(a, b, t);
}
