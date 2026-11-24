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
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      color: Color.lerp(a.color, b.color, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      innerBorderRadius: BorderRadius.lerp(
        a.innerBorderRadius,
        b.innerBorderRadius,
        t,
      ),
      spring: t < 0.5 ? a.spring : b.spring,
      minHeight: lerpDouble$(a.minHeight, b.minHeight, t),
    );
  }

  ProgressBarTheme copyWith({
    Color? backgroundColor,
    Color? color,
    BorderRadius? borderRadius,
    BorderRadius? innerBorderRadius,
    MotionSpring? spring,
    double? minHeight,
  }) {
    final _this = (this as ProgressBarTheme);

    return ProgressBarTheme(
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      color: color ?? _this.color,
      borderRadius: borderRadius ?? _this.borderRadius,
      innerBorderRadius: innerBorderRadius ?? _this.innerBorderRadius,
      spring: spring ?? _this.spring,
      minHeight: minHeight ?? _this.minHeight,
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
      backgroundColor: other.backgroundColor,
      color: other.color,
      borderRadius: other.borderRadius,
      innerBorderRadius: other.innerBorderRadius,
      spring: other.spring,
      minHeight: other.minHeight,
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

    return _other.backgroundColor == _this.backgroundColor &&
        _other.color == _this.color &&
        _other.borderRadius == _this.borderRadius &&
        _other.innerBorderRadius == _this.innerBorderRadius &&
        _other.spring == _this.spring &&
        _other.minHeight == _this.minHeight;
  }

  @override
  int get hashCode {
    final _this = (this as ProgressBarTheme);

    return Object.hash(
      runtimeType,
      _this.backgroundColor,
      _this.color,
      _this.borderRadius,
      _this.innerBorderRadius,
      _this.spring,
      _this.minHeight,
    );
  }
}
