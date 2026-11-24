import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'checkbox.g.theme.dart';

/// {@template CheckboxTheme}
/// Theme for the `Checkbox` widget.
/// {@endtemplate}
@themeGen
@immutable
class CheckboxTheme with _$CheckboxTheme {
  /// {@macro CheckboxTheme}
  const CheckboxTheme({
    bool canMerge = true,
    this.color,
    this.uncheckedColor,
    this.duration,
    this.decoration,
    this.checkedDecoration,
    this.size,
    this.padding,
    this.crossAxisAlignment,
    this.checkboxPadding,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Checkbox.color}
  final Color? color;

  /// {@macro Checkbox.uncheckedColor}
  final Color? uncheckedColor;

  /// {@macro Checkbox.size}
  final double? size;

  /// {@macro Checkbox.duration}
  final Duration? duration;

  /// {@macro Checkbox.decoration}
  final FinesseDecoration? decoration;

  /// The decoration while checked, when it differs from [decoration] —
  /// shadcn recolours the outline with the fill (`data-checked:border-primary`)
  /// so a checked control has no pale halo. Null means "same as [decoration]".
  final FinesseDecoration? checkedDecoration;

  /// {@macro Checkbox.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Checkbox.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Checkbox.checkboxPadding}
  final EdgeInsetsGeometry? checkboxPadding;

  /// Linearly interpolates between [a] and [b] by [t].
  static CheckboxTheme? lerp(
    CheckboxTheme? a,
    CheckboxTheme? b,
    double t,
  ) => _$CheckboxTheme.lerp(a, b, t);
}
