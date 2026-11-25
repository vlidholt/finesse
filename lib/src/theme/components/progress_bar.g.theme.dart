// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'progress_bar.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ProgressBarTheme {
  bool get canMerge => true;

  static ProgressBarTheme? lerp(
    ProgressBarTheme? a,
    ProgressBarTheme? b,
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

    return ProgressBarTheme(
      trackColor: Color.lerp(a.trackColor, b.trackColor, t),
      color: Color.lerp(a.color, b.color, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      innerBorderRadius: BorderRadius.lerp(
        a.innerBorderRadius,
        b.innerBorderRadius,
        t,
      ),
      spring: t < 0.5 ? a.spring : b.spring,
      height: lerpDouble$(a.height, b.height, t),
    );
  }

  ProgressBarTheme copyWith({
    Color? trackColor,
    Color? color,
    BorderRadius? borderRadius,
    BorderRadius? innerBorderRadius,
    MotionSpring? spring,
    double? height,
  }) {
    final _this = (this as ProgressBarTheme);

    return ProgressBarTheme(
      trackColor: trackColor ?? _this.trackColor,
      color: color ?? _this.color,
      borderRadius: borderRadius ?? _this.borderRadius,
      innerBorderRadius: innerBorderRadius ?? _this.innerBorderRadius,
      spring: spring ?? _this.spring,
      height: height ?? _this.height,
    );
  }

  ProgressBarTheme merge(ProgressBarTheme? other) {
    final _this = (this as ProgressBarTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      trackColor: other.trackColor,
      color: other.color,
      borderRadius: other.borderRadius,
      innerBorderRadius: other.innerBorderRadius,
      spring: other.spring,
      height: other.height,
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

    final _this = (this as ProgressBarTheme);
    final _other = (other as ProgressBarTheme);

    return _other.trackColor == _this.trackColor &&
        _other.color == _this.color &&
        _other.borderRadius == _this.borderRadius &&
        _other.innerBorderRadius == _this.innerBorderRadius &&
        _other.spring == _this.spring &&
        _other.height == _this.height;
  }

  @override
  int get hashCode {
    final _this = (this as ProgressBarTheme);

    return Object.hash(
      runtimeType,
      _this.trackColor,
      _this.color,
      _this.borderRadius,
      _this.innerBorderRadius,
      _this.spring,
      _this.height,
    );
  }
}
