// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'action_sheet.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ActionSheetTheme {
  bool get canMerge => true;

  static ActionSheetTheme? lerp(
    ActionSheetTheme? a,
    ActionSheetTheme? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ActionSheetTheme(
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      rowHeight: lerpDouble$(a.rowHeight, b.rowHeight, t),
      rowPadding: EdgeInsetsGeometry.lerp(a.rowPadding, b.rowPadding, t),
      rowBorderRadius: BorderRadius.lerp(
        a.rowBorderRadius,
        b.rowBorderRadius,
        t,
      ),
      gap: lerpDouble$(a.gap, b.gap, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      defaultLabelStyle: TextStyle.lerp(
        a.defaultLabelStyle,
        b.defaultLabelStyle,
        t,
      ),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      messageStyle: TextStyle.lerp(a.messageStyle, b.messageStyle, t),
      headerPadding: EdgeInsetsGeometry.lerp(
        a.headerPadding,
        b.headerPadding,
        t,
      ),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      destructiveColor: Color.lerp(a.destructiveColor, b.destructiveColor, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t),
      cancelColor: Color.lerp(a.cancelColor, b.cancelColor, t),
      cancelGap: lerpDouble$(a.cancelGap, b.cancelGap, t),
      dialogConstraints: BoxConstraints.lerp(
        a.dialogConstraints,
        b.dialogConstraints,
        t,
      ),
    );
  }

  ActionSheetTheme copyWith({
    EdgeInsetsGeometry? padding,
    double? rowHeight,
    EdgeInsetsGeometry? rowPadding,
    BorderRadius? rowBorderRadius,
    double? gap,
    double? iconSize,
    TextStyle? labelStyle,
    TextStyle? defaultLabelStyle,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    EdgeInsetsGeometry? headerPadding,
    Color? foregroundColor,
    Color? destructiveColor,
    Color? highlightColor,
    Color? dividerColor,
    Color? cancelColor,
    double? cancelGap,
    BoxConstraints? dialogConstraints,
  }) {
    final _this = (this as ActionSheetTheme);

    return ActionSheetTheme(
      padding: padding ?? _this.padding,
      rowHeight: rowHeight ?? _this.rowHeight,
      rowPadding: rowPadding ?? _this.rowPadding,
      rowBorderRadius: rowBorderRadius ?? _this.rowBorderRadius,
      gap: gap ?? _this.gap,
      iconSize: iconSize ?? _this.iconSize,
      labelStyle: labelStyle ?? _this.labelStyle,
      defaultLabelStyle: defaultLabelStyle ?? _this.defaultLabelStyle,
      titleStyle: titleStyle ?? _this.titleStyle,
      messageStyle: messageStyle ?? _this.messageStyle,
      headerPadding: headerPadding ?? _this.headerPadding,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      destructiveColor: destructiveColor ?? _this.destructiveColor,
      highlightColor: highlightColor ?? _this.highlightColor,
      dividerColor: dividerColor ?? _this.dividerColor,
      cancelColor: cancelColor ?? _this.cancelColor,
      cancelGap: cancelGap ?? _this.cancelGap,
      dialogConstraints: dialogConstraints ?? _this.dialogConstraints,
    );
  }

  ActionSheetTheme merge(ActionSheetTheme? other) {
    final _this = (this as ActionSheetTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      padding: other.padding,
      rowHeight: other.rowHeight,
      rowPadding: other.rowPadding,
      rowBorderRadius: other.rowBorderRadius,
      gap: other.gap,
      iconSize: other.iconSize,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      defaultLabelStyle:
          _this.defaultLabelStyle?.merge(other.defaultLabelStyle) ??
          other.defaultLabelStyle,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      messageStyle:
          _this.messageStyle?.merge(other.messageStyle) ?? other.messageStyle,
      headerPadding: other.headerPadding,
      foregroundColor: other.foregroundColor,
      destructiveColor: other.destructiveColor,
      highlightColor: other.highlightColor,
      dividerColor: other.dividerColor,
      cancelColor: other.cancelColor,
      cancelGap: other.cancelGap,
      dialogConstraints: other.dialogConstraints,
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

    final _this = (this as ActionSheetTheme);
    final _other = (other as ActionSheetTheme);

    return _other.padding == _this.padding &&
        _other.rowHeight == _this.rowHeight &&
        _other.rowPadding == _this.rowPadding &&
        _other.rowBorderRadius == _this.rowBorderRadius &&
        _other.gap == _this.gap &&
        _other.iconSize == _this.iconSize &&
        _other.labelStyle == _this.labelStyle &&
        _other.defaultLabelStyle == _this.defaultLabelStyle &&
        _other.titleStyle == _this.titleStyle &&
        _other.messageStyle == _this.messageStyle &&
        _other.headerPadding == _this.headerPadding &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.destructiveColor == _this.destructiveColor &&
        _other.highlightColor == _this.highlightColor &&
        _other.dividerColor == _this.dividerColor &&
        _other.cancelColor == _this.cancelColor &&
        _other.cancelGap == _this.cancelGap &&
        _other.dialogConstraints == _this.dialogConstraints;
  }

  @override
  int get hashCode {
    final _this = (this as ActionSheetTheme);

    return Object.hash(
      runtimeType,
      _this.padding,
      _this.rowHeight,
      _this.rowPadding,
      _this.rowBorderRadius,
      _this.gap,
      _this.iconSize,
      _this.labelStyle,
      _this.defaultLabelStyle,
      _this.titleStyle,
      _this.messageStyle,
      _this.headerPadding,
      _this.foregroundColor,
      _this.destructiveColor,
      _this.highlightColor,
      _this.dividerColor,
      _this.cancelColor,
      _this.cancelGap,
      _this.dialogConstraints,
    );
  }
}
