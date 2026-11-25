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
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
    );
  }

  CollapsibleTheme copyWith({CrossAxisAlignment? crossAxisAlignment}) {
    final _this = (this as CollapsibleTheme);

    return CollapsibleTheme(
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

    return copyWith(crossAxisAlignment: other.crossAxisAlignment);
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

    return _other.crossAxisAlignment == _this.crossAxisAlignment;
  }

  @override
  int get hashCode {
    final _this = (this as CollapsibleTheme);

    return Object.hash(runtimeType, _this.crossAxisAlignment);
  }
}
