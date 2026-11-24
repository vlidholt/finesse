import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'textarea.g.theme.dart';

/// {@template TextareaTheme}
/// Theme for the `Textarea` widget.
/// {@endtemplate}
@themeGen
@immutable
class TextareaTheme with _$TextareaTheme {
  /// {@macro TextareaTheme}
  const TextareaTheme({
    bool canMerge = true,
    this.decoration,
    this.padding,
    this.style,
    this.placeholderStyle,
    this.placeholderAlignment,
    this.alignment,
    this.inputPadding,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.gap,
    this.constraints,
    this.minHeight,
    this.maxHeight,
    this.resizable,
    this.resizeHandleBuilder,
    this.scrollbarPadding,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Textarea.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Textarea.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Textarea.style}
  final TextStyle? style;

  /// {@macro Textarea.placeholderStyle}
  final TextStyle? placeholderStyle;

  /// {@macro Textarea.placeholderAlignment}
  final AlignmentGeometry? placeholderAlignment;

  /// {@macro Textarea.alignment}
  final AlignmentGeometry? alignment;

  /// {@macro Textarea.inputPadding}
  final EdgeInsetsGeometry? inputPadding;

  /// {@macro Textarea.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Textarea.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Textarea.gap}
  final double? gap;

  /// {@macro Textarea.constraints}
  final BoxConstraints? constraints;

  /// {@macro Textarea.minHeight}
  final double? minHeight;

  /// {@macro Textarea.maxHeight}
  final double? maxHeight;

  /// {@macro Textarea.resizable}
  final bool? resizable;

  /// {@macro Textarea.resizeHandleBuilder}
  final WidgetBuilder? resizeHandleBuilder;

  /// {@macro Textarea.scrollbarPadding}
  final EdgeInsetsGeometry? scrollbarPadding;

  /// Linearly interpolates between [a] and [b] by [t].
  static TextareaTheme? lerp(
    TextareaTheme? a,
    TextareaTheme? b,
    double t,
  ) => _$TextareaTheme.lerp(a, b, t);
}
