import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'default_keyboard_toolbar.g.theme.dart';

/// {@template DefaultKeyboardToolbarTheme}
/// Theme for the `DefaultKeyboardToolbar` widget.
/// {@endtemplate}
@themeGen
@immutable
class DefaultKeyboardToolbarTheme with _$DefaultKeyboardToolbarTheme {
  /// {@macro DefaultKeyboardToolbarTheme}
  const DefaultKeyboardToolbarTheme({
    bool canMerge = true,
    this.backgroundColor,
    this.doneText,
    this.showPreviousButton,
    this.showNextButton,
    this.showDoneButton,
    this.hideThreshold,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro DefaultKeyboardToolbar.backgroundColor}
  final Color? backgroundColor;

  /// {@macro DefaultKeyboardToolbar.doneText}
  final String? doneText;

  /// {@macro DefaultKeyboardToolbar.showPreviousButton}
  final bool? showPreviousButton;

  /// {@macro DefaultKeyboardToolbar.showNextButton}
  final bool? showNextButton;

  /// {@macro DefaultKeyboardToolbar.showDoneButton}
  final bool? showDoneButton;

  /// {@macro KeyboardToolbar.hideThreshold}
  final double? hideThreshold;

  /// Linearly interpolates between [a] and [b] by [t].
  static DefaultKeyboardToolbarTheme? lerp(
    DefaultKeyboardToolbarTheme? a,
    DefaultKeyboardToolbarTheme? b,
    double t,
  ) => _$DefaultKeyboardToolbarTheme.lerp(a, b, t);
}
