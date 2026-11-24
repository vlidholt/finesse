import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'text_field.g.theme.dart';

/// {@template TextFieldTheme}
/// Theme for the `TextField` widget.
/// {@endtemplate}
@themeGen
@immutable
class TextFieldTheme with _$TextFieldTheme {
  /// {@macro TextFieldTheme}
  const TextFieldTheme({
    bool canMerge = true,
    this.decoration,
    this.padding,
    this.style,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.placeholderStyle,
    this.alignment,
    this.placeholderAlignment,
    this.inputPadding,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.gap,
    this.constraints,
    this.scrollbarPadding,
    this.verticalGap,
    this.useBrowserContextMenu,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro TextField.decoration}
  final FinesseDecoration? decoration;

  /// {@macro TextField.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro TextField.style}
  final TextStyle? style;

  /// {@macro TextField.cursorColor}
  final Color? cursorColor;

  /// {@macro TextField.cursorWidth}
  final double? cursorWidth;

  /// {@macro TextField.cursorHeight}
  final double? cursorHeight;

  /// {@macro TextField.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro TextField.cursorOpacityAnimates}
  final bool? cursorOpacityAnimates;

  /// {@macro TextField.placeholderStyle}
  final TextStyle? placeholderStyle;

  /// {@macro TextField.alignment}
  final AlignmentGeometry? alignment;

  /// {@macro TextField.placeholderAlignment}
  final AlignmentGeometry? placeholderAlignment;

  /// {@macro TextField.inputPadding}
  final EdgeInsetsGeometry? inputPadding;

  /// {@macro TextField.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro TextField.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro TextField.gap}
  final double? gap;

  /// {@macro TextField.constraints}
  final BoxConstraints? constraints;

  /// {@macro TextField.scrollbarPadding}
  final EdgeInsetsGeometry? scrollbarPadding;

  /// {@macro TextField.verticalGap}
  final double? verticalGap;

  /// {@macro TextField.useBrowserContextMenu}
  final bool? useBrowserContextMenu;

  /// Linearly interpolates between [a] and [b] by [t].
  static TextFieldTheme? lerp(
    TextFieldTheme? a,
    TextFieldTheme? b,
    double t,
  ) => _$TextFieldTheme.lerp(a, b, t);
}
