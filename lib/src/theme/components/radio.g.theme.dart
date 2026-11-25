// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'radio.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$RadioTheme {
  bool get canMerge => true;

  static RadioTheme? lerp(RadioTheme? a, RadioTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return RadioTheme(
      color: Color.lerp(a.color, b.color, t),
      size: lerpDouble$(a.size, b.size, t),
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      checkedDecoration: FinesseDecoration.lerp(
        a.checkedDecoration,
        b.checkedDecoration,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      circleSize: lerpDouble$(a.circleSize, b.circleSize, t),
      axis: t < 0.5 ? a.axis : b.axis,
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      runSpacing: lerpDouble$(a.runSpacing, b.runSpacing, t),
      alignment: t < 0.5 ? a.alignment : b.alignment,
      runAlignment: t < 0.5 ? a.runAlignment : b.runAlignment,
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
      radioPadding: EdgeInsetsGeometry.lerp(a.radioPadding, b.radioPadding, t),
    );
  }

  RadioTheme copyWith({
    Color? color,
    double? size,
    FinesseDecoration? decoration,
    FinesseDecoration? checkedDecoration,
    EdgeInsetsGeometry? padding,
    double? circleSize,
    Axis? axis,
    double? spacing,
    double? runSpacing,
    WrapAlignment? alignment,
    WrapAlignment? runAlignment,
    WrapCrossAlignment? crossAxisAlignment,
    EdgeInsetsGeometry? radioPadding,
  }) {
    final _this = (this as RadioTheme);

    return RadioTheme(
      color: color ?? _this.color,
      size: size ?? _this.size,
      decoration: decoration ?? _this.decoration,
      checkedDecoration: checkedDecoration ?? _this.checkedDecoration,
      padding: padding ?? _this.padding,
      circleSize: circleSize ?? _this.circleSize,
      axis: axis ?? _this.axis,
      spacing: spacing ?? _this.spacing,
      runSpacing: runSpacing ?? _this.runSpacing,
      alignment: alignment ?? _this.alignment,
      runAlignment: runAlignment ?? _this.runAlignment,
      crossAxisAlignment: crossAxisAlignment ?? _this.crossAxisAlignment,
      radioPadding: radioPadding ?? _this.radioPadding,
    );
  }

  RadioTheme merge(RadioTheme? other) {
    final _this = (this as RadioTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      color: other.color,
      size: other.size,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      checkedDecoration:
          _this.checkedDecoration?.merge(other.checkedDecoration) ??
          other.checkedDecoration,
      padding: other.padding,
      circleSize: other.circleSize,
      axis: other.axis,
      spacing: other.spacing,
      runSpacing: other.runSpacing,
      alignment: other.alignment,
      runAlignment: other.runAlignment,
      crossAxisAlignment: other.crossAxisAlignment,
      radioPadding: other.radioPadding,
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

    final _this = (this as RadioTheme);
    final _other = (other as RadioTheme);

    return _other.color == _this.color &&
        _other.size == _this.size &&
        _other.decoration == _this.decoration &&
        _other.checkedDecoration == _this.checkedDecoration &&
        _other.padding == _this.padding &&
        _other.circleSize == _this.circleSize &&
        _other.axis == _this.axis &&
        _other.spacing == _this.spacing &&
        _other.runSpacing == _this.runSpacing &&
        _other.alignment == _this.alignment &&
        _other.runAlignment == _this.runAlignment &&
        _other.crossAxisAlignment == _this.crossAxisAlignment &&
        _other.radioPadding == _this.radioPadding;
  }

  @override
  int get hashCode {
    final _this = (this as RadioTheme);

    return Object.hash(
      runtimeType,
      _this.color,
      _this.size,
      _this.decoration,
      _this.checkedDecoration,
      _this.padding,
      _this.circleSize,
      _this.axis,
      _this.spacing,
      _this.runSpacing,
      _this.alignment,
      _this.runAlignment,
      _this.crossAxisAlignment,
      _this.radioPadding,
    );
  }
}
