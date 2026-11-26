// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'otp_field.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$OtpFieldTheme {
  bool get canMerge => true;

  static OtpFieldTheme? lerp(OtpFieldTheme? a, OtpFieldTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return OtpFieldTheme(
      gap: lerpDouble$(a.gap, b.gap, t),
      style: TextStyle.lerp(a.style, b.style, t),
      width: lerpDouble$(a.width, b.width, t),
      height: lerpDouble$(a.height, b.height, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      decoration: UnaDecoration.lerp(a.decoration, b.decoration, t),
      firstBorderRadius: BorderRadius.lerp(
        a.firstBorderRadius,
        b.firstBorderRadius,
        t,
      ),
      lastBorderRadius: BorderRadius.lerp(
        a.lastBorderRadius,
        b.lastBorderRadius,
        t,
      ),
      singleBorderRadius: BorderRadius.lerp(
        a.singleBorderRadius,
        b.singleBorderRadius,
        t,
      ),
      middleBorderRadius: BorderRadius.lerp(
        a.middleBorderRadius,
        b.middleBorderRadius,
        t,
      ),
    );
  }

  OtpFieldTheme copyWith({
    double? gap,
    TextStyle? style,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    UnaDecoration? decoration,
    BorderRadius? firstBorderRadius,
    BorderRadius? lastBorderRadius,
    BorderRadius? singleBorderRadius,
    BorderRadius? middleBorderRadius,
  }) {
    final _this = (this as OtpFieldTheme);

    return OtpFieldTheme(
      gap: gap ?? _this.gap,
      style: style ?? _this.style,
      width: width ?? _this.width,
      height: height ?? _this.height,
      padding: padding ?? _this.padding,
      decoration: decoration ?? _this.decoration,
      firstBorderRadius: firstBorderRadius ?? _this.firstBorderRadius,
      lastBorderRadius: lastBorderRadius ?? _this.lastBorderRadius,
      singleBorderRadius: singleBorderRadius ?? _this.singleBorderRadius,
      middleBorderRadius: middleBorderRadius ?? _this.middleBorderRadius,
    );
  }

  OtpFieldTheme merge(OtpFieldTheme? other) {
    final _this = (this as OtpFieldTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      gap: other.gap,
      style: _this.style?.merge(other.style) ?? other.style,
      width: other.width,
      height: other.height,
      padding: other.padding,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      firstBorderRadius: other.firstBorderRadius,
      lastBorderRadius: other.lastBorderRadius,
      singleBorderRadius: other.singleBorderRadius,
      middleBorderRadius: other.middleBorderRadius,
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

    final _this = (this as OtpFieldTheme);
    final _other = (other as OtpFieldTheme);

    return _other.gap == _this.gap &&
        _other.style == _this.style &&
        _other.width == _this.width &&
        _other.height == _this.height &&
        _other.padding == _this.padding &&
        _other.decoration == _this.decoration &&
        _other.firstBorderRadius == _this.firstBorderRadius &&
        _other.lastBorderRadius == _this.lastBorderRadius &&
        _other.singleBorderRadius == _this.singleBorderRadius &&
        _other.middleBorderRadius == _this.middleBorderRadius;
  }

  @override
  int get hashCode {
    final _this = (this as OtpFieldTheme);

    return Object.hash(
      runtimeType,
      _this.gap,
      _this.style,
      _this.width,
      _this.height,
      _this.padding,
      _this.decoration,
      _this.firstBorderRadius,
      _this.lastBorderRadius,
      _this.singleBorderRadius,
      _this.middleBorderRadius,
    );
  }
}
