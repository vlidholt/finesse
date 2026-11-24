import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

part 'table.g.theme.dart';

/// {@template TableTheme}
/// Theme for the `FinesseTable` widget.
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
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro FinesseTable.diagonalDragBehavior}
  final DiagonalDragBehavior? diagonalDragBehavior;

  /// {@macro FinesseTable.dragStartBehavior}
  final DragStartBehavior? dragStartBehavior;

  /// {@macro FinesseTable.keyboardDismissBehavior}
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// {@macro FinesseTable.columnBuilder}
  final TableSpanBuilder? columnBuilder;

  /// {@macro FinesseTable.rowBuilder}
  final TableSpanBuilder? rowBuilder;

  /// {@macro FinesseTableCell.alignment}
  final Alignment? cellAlignment;

  /// {@macro FinesseTableCell.height}
  final double? cellHeight;

  /// {@macro FinesseTableCell.padding}
  final EdgeInsetsGeometry? cellPadding;

  /// Text style of header cells. Defaults to the text theme's `muted` at
  /// medium weight.
  final TextStyle? cellHeaderStyle;

  /// Text style of body cells. Defaults to the text theme's `muted`.
  final TextStyle? cellStyle;

  /// Text style of footer cells. Defaults to the text theme's `muted` at
  /// medium weight.
  final TextStyle? cellFooterStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static TableTheme? lerp(
    TableTheme? a,
    TableTheme? b,
    double t,
  ) => _$TableTheme.lerp(a, b, t);
}
