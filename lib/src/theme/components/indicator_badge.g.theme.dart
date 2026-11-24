// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'indicator_badge.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$IndicatorBadgeTheme {
  bool get canMerge => true;

  static IndicatorBadgeTheme? lerp(
    IndicatorBadgeTheme? a,
    IndicatorBadgeTheme? b,
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

    return IndicatorBadgeTheme(
      size: lerpDouble$(a.size, b.size, t),
      dotSize: lerpDouble$(a.dotSize, b.dotSize, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      ringColor: Color.lerp(a.ringColor, b.ringColor, t),
      ringWidth: lerpDouble$(a.ringWidth, b.ringWidth, t),
    );
  }

  IndicatorBadgeTheme copyWith({
    double? size,
    double? dotSize,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? foregroundColor,
    TextStyle? textStyle,
    Color? ringColor,
    double? ringWidth,
  }) {
    final _this = (this as IndicatorBadgeTheme);

    return IndicatorBadgeTheme(
      size: size ?? _this.size,
      dotSize: dotSize ?? _this.dotSize,
      padding: padding ?? _this.padding,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      textStyle: textStyle ?? _this.textStyle,
      ringColor: ringColor ?? _this.ringColor,
      ringWidth: ringWidth ?? _this.ringWidth,
    );
  }

  IndicatorBadgeTheme merge(IndicatorBadgeTheme? other) {
    final _this = (this as IndicatorBadgeTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      dotSize: other.dotSize,
      padding: other.padding,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      ringColor: other.ringColor,
      ringWidth: other.ringWidth,
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

    final _this = (this as IndicatorBadgeTheme);
    final _other = (other as IndicatorBadgeTheme);

    return _other.size == _this.size &&
        _other.dotSize == _this.dotSize &&
        _other.padding == _this.padding &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.textStyle == _this.textStyle &&
        _other.ringColor == _this.ringColor &&
        _other.ringWidth == _this.ringWidth;
  }

  @override
  int get hashCode {
    final _this = (this as IndicatorBadgeTheme);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.dotSize,
      _this.padding,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.textStyle,
      _this.ringColor,
      _this.ringWidth,
    );
  }
}
