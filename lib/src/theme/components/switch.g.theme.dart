// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'switch.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$SwitchTheme {
  bool get canMerge => true;

  static SwitchTheme? lerp(SwitchTheme? a, SwitchTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return SwitchTheme(
      thumbColor: Color.lerp(a.thumbColor, b.thumbColor, t),
      uncheckedTrackColor: Color.lerp(
        a.uncheckedTrackColor,
        b.uncheckedTrackColor,
        t,
      ),
      checkedTrackColor: Color.lerp(
        a.checkedTrackColor,
        b.checkedTrackColor,
        t,
      ),
      width: lerpDouble$(a.width, b.width, t),
      height: lerpDouble$(a.height, b.height, t),
      margin: lerpDouble$(a.margin, b.margin, t),
      thumbStretch: lerpDouble$(a.thumbStretch, b.thumbStretch, t),
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
    );
  }

  SwitchTheme copyWith({
    Color? thumbColor,
    Color? uncheckedTrackColor,
    Color? checkedTrackColor,
    double? width,
    double? height,
    double? margin,
    double? thumbStretch,
    FinesseDecoration? decoration,
    EdgeInsetsGeometry? padding,
  }) {
    final _this = (this as SwitchTheme);

    return SwitchTheme(
      thumbColor: thumbColor ?? _this.thumbColor,
      uncheckedTrackColor: uncheckedTrackColor ?? _this.uncheckedTrackColor,
      checkedTrackColor: checkedTrackColor ?? _this.checkedTrackColor,
      width: width ?? _this.width,
      height: height ?? _this.height,
      margin: margin ?? _this.margin,
      thumbStretch: thumbStretch ?? _this.thumbStretch,
      decoration: decoration ?? _this.decoration,
      padding: padding ?? _this.padding,
    );
  }

  SwitchTheme merge(SwitchTheme? other) {
    final _this = (this as SwitchTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      thumbColor: other.thumbColor,
      uncheckedTrackColor: other.uncheckedTrackColor,
      checkedTrackColor: other.checkedTrackColor,
      width: other.width,
      height: other.height,
      margin: other.margin,
      thumbStretch: other.thumbStretch,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      padding: other.padding,
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

    final _this = (this as SwitchTheme);
    final _other = (other as SwitchTheme);

    return _other.thumbColor == _this.thumbColor &&
        _other.uncheckedTrackColor == _this.uncheckedTrackColor &&
        _other.checkedTrackColor == _this.checkedTrackColor &&
        _other.width == _this.width &&
        _other.height == _this.height &&
        _other.margin == _this.margin &&
        _other.thumbStretch == _this.thumbStretch &&
        _other.decoration == _this.decoration &&
        _other.padding == _this.padding;
  }

  @override
  int get hashCode {
    final _this = (this as SwitchTheme);

    return Object.hash(
      runtimeType,
      _this.thumbColor,
      _this.uncheckedTrackColor,
      _this.checkedTrackColor,
      _this.width,
      _this.height,
      _this.margin,
      _this.thumbStretch,
      _this.decoration,
      _this.padding,
    );
  }
}
