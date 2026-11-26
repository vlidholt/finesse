import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

part 'table.g.theme.dart';

/// {@template TableTheme}
/// Theme for the `UnaTable` widget.
/// {@endtemplate}
@themeGen
@immutable
class TableTheme with _$TableTheme {
  /// {@macro TableTheme}
  const TableTheme({
    bool canMerge = true,
    this.diagonalDragBehavior,
    this.dragStartBehavior,
    this.keyboardDismissBehavior,
    this.columnBuilder,
    this.rowBuilder,
    this.cellAlignment,
    this.cellHeight,
    this.cellPadding,
    this.cellStyle,
    this.cellHeaderStyle,
    this.cellFooterStyle,
    this.rowHoverColor,
    this.rowSelectedColor,
    this.footerColor,
    this.footerHoverColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro UnaTable.diagonalDragBehavior}
  final DiagonalDragBehavior? diagonalDragBehavior;

  /// {@macro UnaTable.dragStartBehavior}
  final DragStartBehavior? dragStartBehavior;

  /// {@macro UnaTable.keyboardDismissBehavior}
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// {@macro UnaTable.columnBuilder}
  final TableSpanBuilder? columnBuilder;

  /// {@macro UnaTable.rowBuilder}
  final TableSpanBuilder? rowBuilder;

  /// {@macro UnaTableCell.alignment}
  final Alignment? cellAlignment;

  /// {@macro UnaTableCell.height}
  final double? cellHeight;

  /// {@macro UnaTableCell.padding}
  final EdgeInsetsGeometry? cellPadding;

  /// Text style of header cells. Defaults to the text theme's `muted` at
  /// medium weight.
  final TextStyle? cellHeaderStyle;

  /// Text style of body cells. Defaults to the text theme's `muted`.
  final TextStyle? cellStyle;

  /// Text style of footer cells. Defaults to the text theme's `muted` at
  /// medium weight.
  final TextStyle? cellFooterStyle;

  /// The wash behind the row under the pointer. Defaults to half the
  /// scheme's `muted` colour, shadcn's `hover:bg-muted/50`.
  final Color? rowHoverColor;

  /// The fill of a selected row; see `UnaTable.rowSelected`. Defaults
  /// to the scheme's `muted` colour, `data-[state=selected]:bg-muted`.
  final Color? rowSelectedColor;

  /// The fill of the footer row. Defaults to half the scheme's `muted`
  /// colour, `bg-muted/50`.
  final Color? footerColor;

  /// The fill of the footer row under the pointer. Defaults to the scheme's
  /// `muted` colour.
  final Color? footerHoverColor;

  /// Linearly interpolates between [a] and [b] by [t].
  static TableTheme? lerp(
    TableTheme? a,
    TableTheme? b,
    double t,
  ) => _$TableTheme.lerp(a, b, t);
}
