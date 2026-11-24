// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'skeleton.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$SkeletonTheme {
  bool get canMerge => true;

  static SkeletonTheme? lerp(SkeletonTheme? a, SkeletonTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return SkeletonTheme(
      color: Color.lerp(a.color, b.color, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
      radius: BorderRadiusGeometry.lerp(a.radius, b.radius, t),
      duration: lerpDuration$(a.duration, b.duration, t),
      curve: t < 0.5 ? a.curve : b.curve,
      animate: t < 0.5 ? a.animate : b.animate,
      shimmer: t < 0.5 ? a.shimmer : b.shimmer,
    );
  }

  SkeletonTheme copyWith({
    Color? color,
    Color? highlightColor,
    BorderRadiusGeometry? radius,
    Duration? duration,
    Curve? curve,
    bool? animate,
    bool? shimmer,
  }) {
    final _this = (this as SkeletonTheme);

    return SkeletonTheme(
      color: color ?? _this.color,
      highlightColor: highlightColor ?? _this.highlightColor,
      radius: radius ?? _this.radius,
      duration: duration ?? _this.duration,
      curve: curve ?? _this.curve,
      animate: animate ?? _this.animate,
      shimmer: shimmer ?? _this.shimmer,
    );
  }

  SkeletonTheme merge(SkeletonTheme? other) {
    final _this = (this as SkeletonTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      color: other.color,
      highlightColor: other.highlightColor,
      radius: other.radius,
      duration: other.duration,
      curve: other.curve,
      animate: other.animate,
      shimmer: other.shimmer,
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

    final _this = (this as SkeletonTheme);
    final _other = (other as SkeletonTheme);

    return _other.color == _this.color &&
        _other.highlightColor == _this.highlightColor &&
        _other.radius == _this.radius &&
        _other.duration == _this.duration &&
        _other.curve == _this.curve &&
        _other.animate == _this.animate &&
        _other.shimmer == _this.shimmer;
  }

  @override
  int get hashCode {
    final _this = (this as SkeletonTheme);

    return Object.hash(
      runtimeType,
      _this.color,
      _this.highlightColor,
      _this.radius,
      _this.duration,
      _this.curve,
      _this.animate,
      _this.shimmer,
    );
  }
}
