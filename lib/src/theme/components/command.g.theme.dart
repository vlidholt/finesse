// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'command.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$CommandTheme {
  bool get canMerge => true;

  static CommandTheme? lerp(CommandTheme? a, CommandTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return CommandTheme(
      liquidGlass: t < 0.5 ? a.liquidGlass : b.liquidGlass,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      searchPadding: EdgeInsetsGeometry.lerp(
        a.searchPadding,
        b.searchPadding,
        t,
      ),
      optionsPadding: EdgeInsetsGeometry.lerp(
        a.optionsPadding,
        b.optionsPadding,
        t,
      ),
      groupHeadingStyle: TextStyle.lerp(
        a.groupHeadingStyle,
        b.groupHeadingStyle,
        t,
      ),
      groupHeadingPadding: EdgeInsetsGeometry.lerp(
        a.groupHeadingPadding,
        b.groupHeadingPadding,
        t,
      ),
      itemPadding: EdgeInsetsGeometry.lerp(a.itemPadding, b.itemPadding, t),
      itemTextStyle: TextStyle.lerp(a.itemTextStyle, b.itemTextStyle, t),
      itemSelectedBackgroundColor: Color.lerp(
        a.itemSelectedBackgroundColor,
        b.itemSelectedBackgroundColor,
        t,
      ),
      itemSelectedForegroundColor: Color.lerp(
        a.itemSelectedForegroundColor,
        b.itemSelectedForegroundColor,
        t,
      ),
      itemForegroundColor: Color.lerp(
        a.itemForegroundColor,
        b.itemForegroundColor,
        t,
      ),
      itemBorderRadius: BorderRadiusGeometry.lerp(
        a.itemBorderRadius,
        b.itemBorderRadius,
        t,
      ),
      itemGap: lerpDouble$(a.itemGap, b.itemGap, t),
      height: lerpDouble$(a.height, b.height, t),
      width: lerpDouble$(a.width, b.width, t),
      emptyPadding: EdgeInsetsGeometry.lerp(a.emptyPadding, b.emptyPadding, t),
      emptyTextStyle: TextStyle.lerp(a.emptyTextStyle, b.emptyTextStyle, t),
      searchDecoration: FinesseDecoration.lerp(
        a.searchDecoration,
        b.searchDecoration,
        t,
      ),
      searchHeight: lerpDouble$(a.searchHeight, b.searchHeight, t),
      searchIconColor: Color.lerp(a.searchIconColor, b.searchIconColor, t),
      searchIconSize: lerpDouble$(a.searchIconSize, b.searchIconSize, t),
      searchGap: lerpDouble$(a.searchGap, b.searchGap, t),
      searchInputPadding: EdgeInsetsGeometry.lerp(
        a.searchInputPadding,
        b.searchInputPadding,
        t,
      ),
      listMaxHeight: lerpDouble$(a.listMaxHeight, b.listMaxHeight, t),
      groupPadding: EdgeInsetsGeometry.lerp(a.groupPadding, b.groupPadding, t),
      dialogItemBorderRadius: BorderRadiusGeometry.lerp(
        a.dialogItemBorderRadius,
        b.dialogItemBorderRadius,
        t,
      ),
      itemIconSize: lerpDouble$(a.itemIconSize, b.itemIconSize, t),
      surfaceFilter: t < 0.5 ? a.surfaceFilter : b.surfaceFilter,
    );
  }

  CommandTheme copyWith({
    LiquidGlassMode? liquidGlass,
    Color? backgroundColor,
    FinesseDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? searchPadding,
    EdgeInsetsGeometry? optionsPadding,
    TextStyle? groupHeadingStyle,
    EdgeInsetsGeometry? groupHeadingPadding,
    EdgeInsetsGeometry? itemPadding,
    TextStyle? itemTextStyle,
    Color? itemSelectedBackgroundColor,
    Color? itemSelectedForegroundColor,
    Color? itemForegroundColor,
    BorderRadiusGeometry? itemBorderRadius,
    double? itemGap,
    double? height,
    double? width,
    EdgeInsetsGeometry? emptyPadding,
    TextStyle? emptyTextStyle,
    FinesseDecoration? searchDecoration,
    double? searchHeight,
    Color? searchIconColor,
    double? searchIconSize,
    double? searchGap,
    EdgeInsetsGeometry? searchInputPadding,
    double? listMaxHeight,
    EdgeInsetsGeometry? groupPadding,
    BorderRadiusGeometry? dialogItemBorderRadius,
    double? itemIconSize,
    ImageFilter? surfaceFilter,
  }) {
    final _this = (this as CommandTheme);

    return CommandTheme(
      liquidGlass: liquidGlass ?? _this.liquidGlass,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      decoration: decoration ?? _this.decoration,
      padding: padding ?? _this.padding,
      searchPadding: searchPadding ?? _this.searchPadding,
      optionsPadding: optionsPadding ?? _this.optionsPadding,
      groupHeadingStyle: groupHeadingStyle ?? _this.groupHeadingStyle,
      groupHeadingPadding: groupHeadingPadding ?? _this.groupHeadingPadding,
      itemPadding: itemPadding ?? _this.itemPadding,
      itemTextStyle: itemTextStyle ?? _this.itemTextStyle,
      itemSelectedBackgroundColor:
          itemSelectedBackgroundColor ?? _this.itemSelectedBackgroundColor,
      itemSelectedForegroundColor:
          itemSelectedForegroundColor ?? _this.itemSelectedForegroundColor,
      itemForegroundColor: itemForegroundColor ?? _this.itemForegroundColor,
      itemBorderRadius: itemBorderRadius ?? _this.itemBorderRadius,
      itemGap: itemGap ?? _this.itemGap,
      height: height ?? _this.height,
      width: width ?? _this.width,
      emptyPadding: emptyPadding ?? _this.emptyPadding,
      emptyTextStyle: emptyTextStyle ?? _this.emptyTextStyle,
      searchDecoration: searchDecoration ?? _this.searchDecoration,
      searchHeight: searchHeight ?? _this.searchHeight,
      searchIconColor: searchIconColor ?? _this.searchIconColor,
      searchIconSize: searchIconSize ?? _this.searchIconSize,
      searchGap: searchGap ?? _this.searchGap,
      searchInputPadding: searchInputPadding ?? _this.searchInputPadding,
      listMaxHeight: listMaxHeight ?? _this.listMaxHeight,
      groupPadding: groupPadding ?? _this.groupPadding,
      dialogItemBorderRadius:
          dialogItemBorderRadius ?? _this.dialogItemBorderRadius,
      itemIconSize: itemIconSize ?? _this.itemIconSize,
      surfaceFilter: surfaceFilter ?? _this.surfaceFilter,
    );
  }

  CommandTheme merge(CommandTheme? other) {
    final _this = (this as CommandTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      liquidGlass: other.liquidGlass,
      backgroundColor: other.backgroundColor,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      padding: other.padding,
      searchPadding: other.searchPadding,
      optionsPadding: other.optionsPadding,
      groupHeadingStyle:
          _this.groupHeadingStyle?.merge(other.groupHeadingStyle) ??
          other.groupHeadingStyle,
      groupHeadingPadding: other.groupHeadingPadding,
      itemPadding: other.itemPadding,
      itemTextStyle:
          _this.itemTextStyle?.merge(other.itemTextStyle) ??
          other.itemTextStyle,
      itemSelectedBackgroundColor: other.itemSelectedBackgroundColor,
      itemSelectedForegroundColor: other.itemSelectedForegroundColor,
      itemForegroundColor: other.itemForegroundColor,
      itemBorderRadius: other.itemBorderRadius,
      itemGap: other.itemGap,
      height: other.height,
      width: other.width,
      emptyPadding: other.emptyPadding,
      emptyTextStyle:
          _this.emptyTextStyle?.merge(other.emptyTextStyle) ??
          other.emptyTextStyle,
      searchDecoration:
          _this.searchDecoration?.merge(other.searchDecoration) ??
          other.searchDecoration,
      searchHeight: other.searchHeight,
      searchIconColor: other.searchIconColor,
      searchIconSize: other.searchIconSize,
      searchGap: other.searchGap,
      searchInputPadding: other.searchInputPadding,
      listMaxHeight: other.listMaxHeight,
      groupPadding: other.groupPadding,
      dialogItemBorderRadius: other.dialogItemBorderRadius,
      itemIconSize: other.itemIconSize,
      surfaceFilter: other.surfaceFilter,
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

    final _this = (this as CommandTheme);
    final _other = (other as CommandTheme);

    return _other.liquidGlass == _this.liquidGlass &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.decoration == _this.decoration &&
        _other.padding == _this.padding &&
        _other.searchPadding == _this.searchPadding &&
        _other.optionsPadding == _this.optionsPadding &&
        _other.groupHeadingStyle == _this.groupHeadingStyle &&
        _other.groupHeadingPadding == _this.groupHeadingPadding &&
        _other.itemPadding == _this.itemPadding &&
        _other.itemTextStyle == _this.itemTextStyle &&
        _other.itemSelectedBackgroundColor ==
            _this.itemSelectedBackgroundColor &&
        _other.itemSelectedForegroundColor ==
            _this.itemSelectedForegroundColor &&
        _other.itemForegroundColor == _this.itemForegroundColor &&
        _other.itemBorderRadius == _this.itemBorderRadius &&
        _other.itemGap == _this.itemGap &&
        _other.height == _this.height &&
        _other.width == _this.width &&
        _other.emptyPadding == _this.emptyPadding &&
        _other.emptyTextStyle == _this.emptyTextStyle &&
        _other.searchDecoration == _this.searchDecoration &&
        _other.searchHeight == _this.searchHeight &&
        _other.searchIconColor == _this.searchIconColor &&
        _other.searchIconSize == _this.searchIconSize &&
        _other.searchGap == _this.searchGap &&
        _other.searchInputPadding == _this.searchInputPadding &&
        _other.listMaxHeight == _this.listMaxHeight &&
        _other.groupPadding == _this.groupPadding &&
        _other.dialogItemBorderRadius == _this.dialogItemBorderRadius &&
        _other.itemIconSize == _this.itemIconSize &&
        _other.surfaceFilter == _this.surfaceFilter;
  }

  @override
  int get hashCode {
    final _this = (this as CommandTheme);

    return Object.hashAll([
      runtimeType,
      _this.liquidGlass,
      _this.backgroundColor,
      _this.decoration,
      _this.padding,
      _this.searchPadding,
      _this.optionsPadding,
      _this.groupHeadingStyle,
      _this.groupHeadingPadding,
      _this.itemPadding,
      _this.itemTextStyle,
      _this.itemSelectedBackgroundColor,
      _this.itemSelectedForegroundColor,
      _this.itemForegroundColor,
      _this.itemBorderRadius,
      _this.itemGap,
      _this.height,
      _this.width,
      _this.emptyPadding,
      _this.emptyTextStyle,
      _this.searchDecoration,
      _this.searchHeight,
      _this.searchIconColor,
      _this.searchIconSize,
      _this.searchGap,
      _this.searchInputPadding,
      _this.listMaxHeight,
      _this.groupPadding,
      _this.dialogItemBorderRadius,
      _this.itemIconSize,
      _this.surfaceFilter,
    ]);
  }
}
