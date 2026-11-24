// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'table.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$TableTheme {
  bool get canMerge => true;

  static TableTheme? lerp(TableTheme? a, TableTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return TableTheme(
      diagonalDragBehavior: t < 0.5
          ? a.diagonalDragBehavior
          : b.diagonalDragBehavior,
      dragStartBehavior: t < 0.5 ? a.dragStartBehavior : b.dragStartBehavior,
      keyboardDismissBehavior: t < 0.5
          ? a.keyboardDismissBehavior
          : b.keyboardDismissBehavior,
      columnBuilder: t < 0.5 ? a.columnBuilder : b.columnBuilder,
      rowBuilder: t < 0.5 ? a.rowBuilder : b.rowBuilder,
      cellAlignment: Alignment.lerp(a.cellAlignment, b.cellAlignment, t),
      cellHeight: lerpDouble$(a.cellHeight, b.cellHeight, t),
      cellPadding: EdgeInsetsGeometry.lerp(a.cellPadding, b.cellPadding, t),
      cellHeaderStyle: TextStyle.lerp(a.cellHeaderStyle, b.cellHeaderStyle, t),
      cellStyle: TextStyle.lerp(a.cellStyle, b.cellStyle, t),
      cellFooterStyle: TextStyle.lerp(a.cellFooterStyle, b.cellFooterStyle, t),
      rowHoverColor: Color.lerp(a.rowHoverColor, b.rowHoverColor, t),
      rowSelectedColor: Color.lerp(a.rowSelectedColor, b.rowSelectedColor, t),
      footerColor: Color.lerp(a.footerColor, b.footerColor, t),
      footerHoverColor: Color.lerp(a.footerHoverColor, b.footerHoverColor, t),
    );
  }

  TableTheme copyWith({
    DiagonalDragBehavior? diagonalDragBehavior,
    DragStartBehavior? dragStartBehavior,
    ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior,
    Span? Function(int)? columnBuilder,
    Span? Function(int)? rowBuilder,
    Alignment? cellAlignment,
    double? cellHeight,
    EdgeInsetsGeometry? cellPadding,
    TextStyle? cellHeaderStyle,
    TextStyle? cellStyle,
    TextStyle? cellFooterStyle,
    Color? rowHoverColor,
    Color? rowSelectedColor,
    Color? footerColor,
    Color? footerHoverColor,
  }) {
    final _this = (this as TableTheme);

    return TableTheme(
      diagonalDragBehavior: diagonalDragBehavior ?? _this.diagonalDragBehavior,
      dragStartBehavior: dragStartBehavior ?? _this.dragStartBehavior,
      keyboardDismissBehavior:
          keyboardDismissBehavior ?? _this.keyboardDismissBehavior,
      columnBuilder: columnBuilder ?? _this.columnBuilder,
      rowBuilder: rowBuilder ?? _this.rowBuilder,
      cellAlignment: cellAlignment ?? _this.cellAlignment,
      cellHeight: cellHeight ?? _this.cellHeight,
      cellPadding: cellPadding ?? _this.cellPadding,
      cellHeaderStyle: cellHeaderStyle ?? _this.cellHeaderStyle,
      cellStyle: cellStyle ?? _this.cellStyle,
      cellFooterStyle: cellFooterStyle ?? _this.cellFooterStyle,
      rowHoverColor: rowHoverColor ?? _this.rowHoverColor,
      rowSelectedColor: rowSelectedColor ?? _this.rowSelectedColor,
      footerColor: footerColor ?? _this.footerColor,
      footerHoverColor: footerHoverColor ?? _this.footerHoverColor,
    );
  }

  TableTheme merge(TableTheme? other) {
    final _this = (this as TableTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      diagonalDragBehavior: other.diagonalDragBehavior,
      dragStartBehavior: other.dragStartBehavior,
      keyboardDismissBehavior: other.keyboardDismissBehavior,
      columnBuilder: other.columnBuilder,
      rowBuilder: other.rowBuilder,
      cellAlignment: other.cellAlignment,
      cellHeight: other.cellHeight,
      cellPadding: other.cellPadding,
      cellHeaderStyle:
          _this.cellHeaderStyle?.merge(other.cellHeaderStyle) ??
          other.cellHeaderStyle,
      cellStyle: _this.cellStyle?.merge(other.cellStyle) ?? other.cellStyle,
      cellFooterStyle:
          _this.cellFooterStyle?.merge(other.cellFooterStyle) ??
          other.cellFooterStyle,
      rowHoverColor: other.rowHoverColor,
      rowSelectedColor: other.rowSelectedColor,
      footerColor: other.footerColor,
      footerHoverColor: other.footerHoverColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other.runtimeType != runtimeType) {
      return false;
    }

    final _this = (this as TableTheme);
    final _other = (other as TableTheme);

    return _other.diagonalDragBehavior == _this.diagonalDragBehavior &&
        _other.dragStartBehavior == _this.dragStartBehavior &&
        _other.keyboardDismissBehavior == _this.keyboardDismissBehavior &&
        _other.columnBuilder == _this.columnBuilder &&
        _other.rowBuilder == _this.rowBuilder &&
        _other.cellAlignment == _this.cellAlignment &&
        _other.cellHeight == _this.cellHeight &&
        _other.cellPadding == _this.cellPadding &&
        _other.cellHeaderStyle == _this.cellHeaderStyle &&
        _other.cellStyle == _this.cellStyle &&
        _other.cellFooterStyle == _this.cellFooterStyle &&
        _other.rowHoverColor == _this.rowHoverColor &&
        _other.rowSelectedColor == _this.rowSelectedColor &&
        _other.footerColor == _this.footerColor &&
        _other.footerHoverColor == _this.footerHoverColor;
  }

  @override
  int get hashCode {
    final _this = (this as TableTheme);

    return Object.hash(
      runtimeType,
      _this.diagonalDragBehavior,
      _this.dragStartBehavior,
      _this.keyboardDismissBehavior,
      _this.columnBuilder,
      _this.rowBuilder,
      _this.cellAlignment,
      _this.cellHeight,
      _this.cellPadding,
      _this.cellHeaderStyle,
      _this.cellStyle,
      _this.cellFooterStyle,
      _this.rowHoverColor,
      _this.rowSelectedColor,
      _this.footerColor,
      _this.footerHoverColor,
    );
  }
}
