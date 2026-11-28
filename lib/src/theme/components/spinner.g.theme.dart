// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'spinner.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$SpinnerTheme {
  bool get canMerge => true;

  static SpinnerTheme? lerp(SpinnerTheme? a, SpinnerTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return SpinnerTheme(
      variant: t < 0.5 ? a.variant : b.variant,
      color: Color.lerp(a.color, b.color, t),
      trackColor: Color.lerp(a.trackColor, b.trackColor, t),
      size: lerpDouble$(a.size, b.size, t),
      strokeWidth: lerpDouble$(a.strokeWidth, b.strokeWidth, t),
      duration: lerpDuration$(a.duration, b.duration, t),
    );
  }

  SpinnerTheme copyWith({
    SpinnerVariant? variant,
    Color? color,
    Color? trackColor,
    double? size,
    double? strokeWidth,
    Duration? duration,
  }) {
    final _this = (this as SpinnerTheme);

    return SpinnerTheme(
      variant: variant ?? _this.variant,
      color: color ?? _this.color,
      trackColor: trackColor ?? _this.trackColor,
      size: size ?? _this.size,
      strokeWidth: strokeWidth ?? _this.strokeWidth,
      duration: duration ?? _this.duration,
    );
  }

  SpinnerTheme merge(SpinnerTheme? other) {
    final _this = (this as SpinnerTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      variant: other.variant,
      color: other.color,
      trackColor: other.trackColor,
      size: other.size,
      strokeWidth: other.strokeWidth,
      duration: other.duration,
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

    final _this = (this as SpinnerTheme);
    final _other = (other as SpinnerTheme);

    return _other.variant == _this.variant &&
        _other.color == _this.color &&
        _other.trackColor == _this.trackColor &&
        _other.size == _this.size &&
        _other.strokeWidth == _this.strokeWidth &&
        _other.duration == _this.duration;
  }

  @override
  int get hashCode {
    final _this = (this as SpinnerTheme);

    return Object.hash(
      runtimeType,
      _this.variant,
      _this.color,
      _this.trackColor,
      _this.size,
      _this.strokeWidth,
      _this.duration,
    );
  }
}
