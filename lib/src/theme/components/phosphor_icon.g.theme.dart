// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'phosphor_icon.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$PhosphorIconTheme {
  bool get canMerge => true;

  static PhosphorIconTheme? lerp(
    PhosphorIconTheme? a,
    PhosphorIconTheme? b,
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

    return PhosphorIconTheme(
      referenceSize: lerpDouble$(a.referenceSize, b.referenceSize, t),
      strength: lerpDouble$(a.strength, b.strength, t),
    );
  }

  PhosphorIconTheme copyWith({double? referenceSize, double? strength}) {
    final _this = (this as PhosphorIconTheme);

    return PhosphorIconTheme(
      referenceSize: referenceSize ?? _this.referenceSize,
      strength: strength ?? _this.strength,
    );
  }

  PhosphorIconTheme merge(PhosphorIconTheme? other) {
    final _this = (this as PhosphorIconTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      referenceSize: other.referenceSize,
      strength: other.strength,
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

    final _this = (this as PhosphorIconTheme);
    final _other = (other as PhosphorIconTheme);

    return _other.referenceSize == _this.referenceSize &&
        _other.strength == _this.strength;
  }

  @override
  int get hashCode {
    final _this = (this as PhosphorIconTheme);

    return Object.hash(runtimeType, _this.referenceSize, _this.strength);
  }
}
