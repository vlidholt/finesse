// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'checkbox.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$CheckboxTheme {
  bool get canMerge => true;

  static CheckboxTheme? lerp(CheckboxTheme? a, CheckboxTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return CheckboxTheme(
      color: Color.lerp(a.color, b.color, t),
      uncheckedColor: Color.lerp(a.uncheckedColor, b.uncheckedColor, t),
      size: lerpDouble$(a.size, b.size, t),
      decoration: UnaDecoration.lerp(a.decoration, b.decoration, t),
      checkedDecoration: UnaDecoration.lerp(
        a.checkedDecoration,
        b.checkedDecoration,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
      checkboxPadding: EdgeInsetsGeometry.lerp(
        a.checkboxPadding,
        b.checkboxPadding,
        t,
      ),
    );
  }

  CheckboxTheme copyWith({
    Color? color,
    Color? uncheckedColor,
    double? size,
    UnaDecoration? decoration,
    UnaDecoration? checkedDecoration,
    EdgeInsetsGeometry? padding,
    CrossAxisAlignment? crossAxisAlignment,
    EdgeInsetsGeometry? checkboxPadding,
  }) {
    final _this = (this as CheckboxTheme);

    return CheckboxTheme(
      color: color ?? _this.color,
      uncheckedColor: uncheckedColor ?? _this.uncheckedColor,
      size: size ?? _this.size,
      decoration: decoration ?? _this.decoration,
      checkedDecoration: checkedDecoration ?? _this.checkedDecoration,
      padding: padding ?? _this.padding,
      crossAxisAlignment: crossAxisAlignment ?? _this.crossAxisAlignment,
      checkboxPadding: checkboxPadding ?? _this.checkboxPadding,
    );
  }

  CheckboxTheme merge(CheckboxTheme? other) {
    final _this = (this as CheckboxTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      color: other.color,
      uncheckedColor: other.uncheckedColor,
      size: other.size,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      checkedDecoration:
          _this.checkedDecoration?.merge(other.checkedDecoration) ??
          other.checkedDecoration,
      padding: other.padding,
      crossAxisAlignment: other.crossAxisAlignment,
      checkboxPadding: other.checkboxPadding,
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

    final _this = (this as CheckboxTheme);
    final _other = (other as CheckboxTheme);

    return _other.color == _this.color &&
        _other.uncheckedColor == _this.uncheckedColor &&
        _other.size == _this.size &&
        _other.decoration == _this.decoration &&
        _other.checkedDecoration == _this.checkedDecoration &&
        _other.padding == _this.padding &&
        _other.crossAxisAlignment == _this.crossAxisAlignment &&
        _other.checkboxPadding == _this.checkboxPadding;
  }

  @override
  int get hashCode {
    final _this = (this as CheckboxTheme);

    return Object.hash(
      runtimeType,
      _this.color,
      _this.uncheckedColor,
      _this.size,
      _this.decoration,
      _this.checkedDecoration,
      _this.padding,
      _this.crossAxisAlignment,
      _this.checkboxPadding,
    );
  }
}
