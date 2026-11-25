// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'icon_tile.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$IconTileTheme {
  bool get canMerge => true;

  static IconTileTheme? lerp(IconTileTheme? a, IconTileTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return IconTileTheme(
      size: lerpDouble$(a.size, b.size, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
    );
  }

  IconTileTheme copyWith({
    double? size,
    double? iconSize,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final _this = (this as IconTileTheme);

    return IconTileTheme(
      size: size ?? _this.size,
      iconSize: iconSize ?? _this.iconSize,
      borderRadius: borderRadius ?? _this.borderRadius,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
    );
  }

  IconTileTheme merge(IconTileTheme? other) {
    final _this = (this as IconTileTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      iconSize: other.iconSize,
      borderRadius: other.borderRadius,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
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

    final _this = (this as IconTileTheme);
    final _other = (other as IconTileTheme);

    return _other.size == _this.size &&
        _other.iconSize == _this.iconSize &&
        _other.borderRadius == _this.borderRadius &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as IconTileTheme);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.iconSize,
      _this.borderRadius,
      _this.backgroundColor,
      _this.foregroundColor,
    );
  }
}
