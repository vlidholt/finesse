import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/utils/border.dart';

part 'kbd.g.theme.dart';

/// {@template KbdTheme}
/// Theme for the `Kbd` widget.
/// {@endtemplate}
@themeGen
@immutable
class KbdTheme with _$KbdTheme {
  /// {@macro KbdTheme}
  const KbdTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.padding,
    this.textStyle,
    this.gap,
    this.minWidth,
    this.height,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Kbd.backgroundColor}
  final Color? backgroundColor;

  /// {@macro Kbd.foregroundColor}
  final Color? foregroundColor;

  /// {@macro Kbd.border}
  final UnaBorder? border;

  /// {@macro Kbd.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Kbd.textStyle}
  final TextStyle? textStyle;

  /// The gap between adjacent keys in a `Kbd` group.
  final double? gap;

  /// The minimum width of a single key cap.
  final double? minWidth;

  /// The height of a single key cap, shadcn's `h-5`.
  ///
  /// A key cap has a fixed height so it stays key-shaped wherever it is put —
  /// inside a button, a table row, or a line of prose.
  final double? height;

  /// Linearly interpolates between [a] and [b] by [t].
  static KbdTheme? lerp(KbdTheme? a, KbdTheme? b, double t) =>
      _$KbdTheme.lerp(a, b, t);
}
