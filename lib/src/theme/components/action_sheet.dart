import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'action_sheet.g.theme.dart';

/// The theme of `ActionSheet`: every value the widget does not set itself.
@themeGen
@immutable
class ActionSheetTheme with _$ActionSheetTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const ActionSheetTheme({
    bool canMerge = true,
    this.padding,
    this.rowHeight,
    this.rowPadding,
    this.rowBorderRadius,
    this.gap,
    this.iconSize,
    this.labelStyle,
    this.defaultLabelStyle,
    this.titleStyle,
    this.messageStyle,
    this.headerPadding,
    this.foregroundColor,
    this.destructiveColor,
    this.highlightColor,
    this.dividerColor,
    this.cancelColor,
    this.cancelGap,
    this.dialogConstraints,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The space between the action sheet and the surface it is shown on.
  final EdgeInsetsGeometry? padding;

  /// The least height of an action's row. A row grows with its label.
  final double? rowHeight;

  /// The space inside a row, around its icon and label.
  final EdgeInsetsGeometry? rowPadding;

  /// The corners of a row's highlight and of the cancel row.
  final BorderRadius? rowBorderRadius;

  /// The space between a row's icon and its label.
  final double? gap;

  /// The size of a row's icon.
  final double? iconSize;

  /// The text style of an action's label.
  final TextStyle? labelStyle;

  /// The text style of the default action's label, and of Cancel: the
  /// label's, heavier.
  final TextStyle? defaultLabelStyle;

  /// The text style of the title.
  final TextStyle? titleStyle;

  /// The text style of the message under the title.
  final TextStyle? messageStyle;

  /// The space around the title and message.
  final EdgeInsetsGeometry? headerPadding;

  /// The colour of an action's label and icon.
  final Color? foregroundColor;

  /// The colour of a destructive action's label and icon.
  final Color? destructiveColor;

  /// The fill of a row under the pointer, a finger or the keyboard focus.
  final Color? highlightColor;

  /// The colour of the hairlines between rows.
  final Color? dividerColor;

  /// The fill of the cancel row.
  final Color? cancelColor;

  /// The space between the actions and the cancel row.
  final double? cancelGap;

  /// The size limits of the dialog an action sheet is shown in on a
  /// desktop.
  final BoxConstraints? dialogConstraints;

  /// Linearly interpolates between [a] and [b] by [t].
  static ActionSheetTheme? lerp(
    ActionSheetTheme? a,
    ActionSheetTheme? b,
    double t,
  ) => _$ActionSheetTheme.lerp(a, b, t);
}
