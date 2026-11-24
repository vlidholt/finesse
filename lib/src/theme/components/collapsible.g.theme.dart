// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'collapsible.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$CollapsibleTheme {
  bool get canMerge => true;

  static CollapsibleTheme? lerp(
    CollapsibleTheme? a,
    CollapsibleTheme? b,
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

    return CollapsibleTheme(
      duration: lerpDuration$(a.duration, b.duration, t),
      curve: t < 0.5 ? a.curve : b.curve,
      reverseDuration: lerpDuration$(a.reverseDuration, b.reverseDuration, t),
      reverseCurve: t < 0.5 ? a.reverseCurve : b.reverseCurve,
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
    );
  }

  CollapsibleTheme copyWith({
    Duration? duration,
    Curve? curve,
    Duration? reverseDuration,
    Curve? reverseCurve,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    final _this = (this as CollapsibleTheme);

    return CollapsibleTheme(
      duration: duration ?? _this.duration,
      curve: curve ?? _this.curve,
      reverseDuration: reverseDuration ?? _this.reverseDuration,
      reverseCurve: reverseCurve ?? _this.reverseCurve,
      crossAxisAlignment: crossAxisAlignment ?? _this.crossAxisAlignment,
    );
  }

  CollapsibleTheme merge(CollapsibleTheme? other) {
    final _this = (this as CollapsibleTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      duration: other.duration,
      curve: other.curve,
      reverseDuration: other.reverseDuration,
      reverseCurve: other.reverseCurve,
      crossAxisAlignment: other.crossAxisAlignment,
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

    final _this = (this as CollapsibleTheme);
    final _other = (other as CollapsibleTheme);

    return _other.duration == _this.duration &&
        _other.curve == _this.curve &&
        _other.reverseDuration == _this.reverseDuration &&
        _other.reverseCurve == _this.reverseCurve &&
        _other.crossAxisAlignment == _this.crossAxisAlignment;
  }

  @override
  int get hashCode {
    final _this = (this as CollapsibleTheme);

    return Object.hash(
      runtimeType,
      _this.duration,
      _this.curve,
      _this.reverseDuration,
      _this.reverseCurve,
      _this.crossAxisAlignment,
    );
  }
}
