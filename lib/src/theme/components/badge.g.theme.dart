// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'badge.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$BadgeTheme {
  bool get canMerge => true;

  static BadgeTheme? lerp(BadgeTheme? a, BadgeTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return BadgeTheme(
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
    );
  }

  BadgeTheme copyWith({
    BorderRadius? borderRadius,
    Color? borderColor,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    double? iconSize,
  }) {
    final _this = (this as BadgeTheme);

    return BadgeTheme(
      borderRadius: borderRadius ?? _this.borderRadius,
      borderColor: borderColor ?? _this.borderColor,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      padding: padding ?? _this.padding,
      textStyle: textStyle ?? _this.textStyle,
      iconSize: iconSize ?? _this.iconSize,
    );
  }

  BadgeTheme merge(BadgeTheme? other) {
    final _this = (this as BadgeTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      borderRadius: other.borderRadius,
      borderColor: other.borderColor,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      padding: other.padding,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      iconSize: other.iconSize,
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

    final _this = (this as BadgeTheme);
    final _other = (other as BadgeTheme);

    return _other.borderRadius == _this.borderRadius &&
        _other.borderColor == _this.borderColor &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.padding == _this.padding &&
        _other.textStyle == _this.textStyle &&
        _other.iconSize == _this.iconSize;
  }

  @override
  int get hashCode {
    final _this = (this as BadgeTheme);

    return Object.hash(
      runtimeType,
      _this.borderRadius,
      _this.borderColor,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.padding,
      _this.textStyle,
      _this.iconSize,
    );
  }
}
