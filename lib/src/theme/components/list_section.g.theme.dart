// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'list_section.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ListSectionTheme {
  bool get canMerge => true;

  static ListSectionTheme? lerp(
    ListSectionTheme? a,
    ListSectionTheme? b,
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

    return ListSectionTheme(
      margin: EdgeInsetsGeometry.lerp(a.margin, b.margin, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      headerStyle: TextStyle.lerp(a.headerStyle, b.headerStyle, t),
      footerStyle: TextStyle.lerp(a.footerStyle, b.footerStyle, t),
      headerPadding: EdgeInsetsGeometry.lerp(
        a.headerPadding,
        b.headerPadding,
        t,
      ),
      footerPadding: EdgeInsetsGeometry.lerp(
        a.footerPadding,
        b.footerPadding,
        t,
      ),
      tilePadding: EdgeInsetsGeometry.lerp(a.tilePadding, b.tilePadding, t),
      minTileHeight: lerpDouble$(a.minTileHeight, b.minTileHeight, t),
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t),
      dividerThickness: lerpDouble$(a.dividerThickness, b.dividerThickness, t),
      pressedColor: Color.lerp(a.pressedColor, b.pressedColor, t),
    );
  }

  ListSectionTheme copyWith({
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    TextStyle? headerStyle,
    TextStyle? footerStyle,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? footerPadding,
    EdgeInsetsGeometry? tilePadding,
    double? minTileHeight,
    Color? dividerColor,
    double? dividerThickness,
    Color? pressedColor,
  }) {
    final _this = (this as ListSectionTheme);

    return ListSectionTheme(
      margin: margin ?? _this.margin,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      borderRadius: borderRadius ?? _this.borderRadius,
      headerStyle: headerStyle ?? _this.headerStyle,
      footerStyle: footerStyle ?? _this.footerStyle,
      headerPadding: headerPadding ?? _this.headerPadding,
      footerPadding: footerPadding ?? _this.footerPadding,
      tilePadding: tilePadding ?? _this.tilePadding,
      minTileHeight: minTileHeight ?? _this.minTileHeight,
      dividerColor: dividerColor ?? _this.dividerColor,
      dividerThickness: dividerThickness ?? _this.dividerThickness,
      pressedColor: pressedColor ?? _this.pressedColor,
    );
  }

  ListSectionTheme merge(ListSectionTheme? other) {
    final _this = (this as ListSectionTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      margin: other.margin,
      backgroundColor: other.backgroundColor,
      borderRadius: other.borderRadius,
      headerStyle:
          _this.headerStyle?.merge(other.headerStyle) ?? other.headerStyle,
      footerStyle:
          _this.footerStyle?.merge(other.footerStyle) ?? other.footerStyle,
      headerPadding: other.headerPadding,
      footerPadding: other.footerPadding,
      tilePadding: other.tilePadding,
      minTileHeight: other.minTileHeight,
      dividerColor: other.dividerColor,
      dividerThickness: other.dividerThickness,
      pressedColor: other.pressedColor,
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

    final _this = (this as ListSectionTheme);
    final _other = (other as ListSectionTheme);

    return _other.margin == _this.margin &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.borderRadius == _this.borderRadius &&
        _other.headerStyle == _this.headerStyle &&
        _other.footerStyle == _this.footerStyle &&
        _other.headerPadding == _this.headerPadding &&
        _other.footerPadding == _this.footerPadding &&
        _other.tilePadding == _this.tilePadding &&
        _other.minTileHeight == _this.minTileHeight &&
        _other.dividerColor == _this.dividerColor &&
        _other.dividerThickness == _this.dividerThickness &&
        _other.pressedColor == _this.pressedColor;
  }

  @override
  int get hashCode {
    final _this = (this as ListSectionTheme);

    return Object.hash(
      runtimeType,
      _this.margin,
      _this.backgroundColor,
      _this.borderRadius,
      _this.headerStyle,
      _this.footerStyle,
      _this.headerPadding,
      _this.footerPadding,
      _this.tilePadding,
      _this.minTileHeight,
      _this.dividerColor,
      _this.dividerThickness,
      _this.pressedColor,
    );
  }
}
