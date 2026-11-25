// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'refresh_indicator.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$RefreshIndicatorTheme {
  bool get canMerge => true;

  static RefreshIndicatorTheme? lerp(
    RefreshIndicatorTheme? a,
    RefreshIndicatorTheme? b,
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

    return RefreshIndicatorTheme(
      size: lerpDouble$(a.size, b.size, t),
      strokeWidth: lerpDouble$(a.strokeWidth, b.strokeWidth, t),
      color: Color.lerp(a.color, b.color, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      triggerDistance: lerpDouble$(a.triggerDistance, b.triggerDistance, t),
      displacement: lerpDouble$(a.displacement, b.displacement, t),
    );
  }

  RefreshIndicatorTheme copyWith({
    double? size,
    double? strokeWidth,
    Color? color,
    Color? backgroundColor,
    Color? borderColor,
    double? triggerDistance,
    double? displacement,
  }) {
    final _this = (this as RefreshIndicatorTheme);

    return RefreshIndicatorTheme(
      size: size ?? _this.size,
      strokeWidth: strokeWidth ?? _this.strokeWidth,
      color: color ?? _this.color,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      borderColor: borderColor ?? _this.borderColor,
      triggerDistance: triggerDistance ?? _this.triggerDistance,
      displacement: displacement ?? _this.displacement,
    );
  }

  RefreshIndicatorTheme merge(RefreshIndicatorTheme? other) {
    final _this = (this as RefreshIndicatorTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      strokeWidth: other.strokeWidth,
      color: other.color,
      backgroundColor: other.backgroundColor,
      borderColor: other.borderColor,
      triggerDistance: other.triggerDistance,
      displacement: other.displacement,
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

    final _this = (this as RefreshIndicatorTheme);
    final _other = (other as RefreshIndicatorTheme);

    return _other.size == _this.size &&
        _other.strokeWidth == _this.strokeWidth &&
        _other.color == _this.color &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.triggerDistance == _this.triggerDistance &&
        _other.displacement == _this.displacement;
  }

  @override
  int get hashCode {
    final _this = (this as RefreshIndicatorTheme);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.strokeWidth,
      _this.color,
      _this.backgroundColor,
      _this.borderColor,
      _this.triggerDistance,
      _this.displacement,
    );
  }
}
