// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'timeline.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$TimelineTheme {
  bool get canMerge => true;

  static TimelineTheme? lerp(TimelineTheme? a, TimelineTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return TimelineTheme(
      lineColor: Color.lerp(a.lineColor, b.lineColor, t),
      lineWidth: lerpDouble$(a.lineWidth, b.lineWidth, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      spacing: lerpDouble$(a.spacing, b.spacing, t),
      lineGap: lerpDouble$(a.lineGap, b.lineGap, t),
    );
  }

  TimelineTheme copyWith({
    Color? lineColor,
    double? lineWidth,
    double? gap,
    double? spacing,
    double? lineGap,
  }) {
    final _this = (this as TimelineTheme);

    return TimelineTheme(
      lineColor: lineColor ?? _this.lineColor,
      lineWidth: lineWidth ?? _this.lineWidth,
      gap: gap ?? _this.gap,
      spacing: spacing ?? _this.spacing,
      lineGap: lineGap ?? _this.lineGap,
    );
  }

  TimelineTheme merge(TimelineTheme? other) {
    final _this = (this as TimelineTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      lineColor: other.lineColor,
      lineWidth: other.lineWidth,
      gap: other.gap,
      spacing: other.spacing,
      lineGap: other.lineGap,
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

    final _this = (this as TimelineTheme);
    final _other = (other as TimelineTheme);

    return _other.lineColor == _this.lineColor &&
        _other.lineWidth == _this.lineWidth &&
        _other.gap == _this.gap &&
        _other.spacing == _this.spacing &&
        _other.lineGap == _this.lineGap;
  }

  @override
  int get hashCode {
    final _this = (this as TimelineTheme);

    return Object.hash(
      runtimeType,
      _this.lineColor,
      _this.lineWidth,
      _this.gap,
      _this.spacing,
      _this.lineGap,
    );
  }
}
