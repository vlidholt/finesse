// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'glass.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$GlassTheme {
  bool get canMerge => true;

  static GlassTheme? lerp(GlassTheme? a, GlassTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return GlassTheme(
      liquidGlass: t < 0.5 ? a.liquidGlass : b.liquidGlass,
      blur: lerpDouble$(a.blur, b.blur, t),
      saturation: lerpDouble$(a.saturation, b.saturation, t),
      color: Color.lerp(a.color, b.color, t),
      opacity: lerpDouble$(a.opacity, b.opacity, t),
      strongOpacity: lerpDouble$(a.strongOpacity, b.strongOpacity, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      borderWidth: lerpDouble$(a.borderWidth, b.borderWidth, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
    );
  }

  GlassTheme copyWith({
    LiquidGlassMode? liquidGlass,
    double? blur,
    double? saturation,
    Color? color,
    double? opacity,
    double? strongOpacity,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
  }) {
    final _this = (this as GlassTheme);

    return GlassTheme(
      liquidGlass: liquidGlass ?? _this.liquidGlass,
      blur: blur ?? _this.blur,
      saturation: saturation ?? _this.saturation,
      color: color ?? _this.color,
      opacity: opacity ?? _this.opacity,
      strongOpacity: strongOpacity ?? _this.strongOpacity,
      borderColor: borderColor ?? _this.borderColor,
      borderWidth: borderWidth ?? _this.borderWidth,
      borderRadius: borderRadius ?? _this.borderRadius,
    );
  }

  GlassTheme merge(GlassTheme? other) {
    final _this = (this as GlassTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      liquidGlass: other.liquidGlass,
      blur: other.blur,
      saturation: other.saturation,
      color: other.color,
      opacity: other.opacity,
      strongOpacity: other.strongOpacity,
      borderColor: other.borderColor,
      borderWidth: other.borderWidth,
      borderRadius: other.borderRadius,
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

    final _this = (this as GlassTheme);
    final _other = (other as GlassTheme);

    return _other.liquidGlass == _this.liquidGlass &&
        _other.blur == _this.blur &&
        _other.saturation == _this.saturation &&
        _other.color == _this.color &&
        _other.opacity == _this.opacity &&
        _other.strongOpacity == _this.strongOpacity &&
        _other.borderColor == _this.borderColor &&
        _other.borderWidth == _this.borderWidth &&
        _other.borderRadius == _this.borderRadius;
  }

  @override
  int get hashCode {
    final _this = (this as GlassTheme);

    return Object.hash(
      runtimeType,
      _this.liquidGlass,
      _this.blur,
      _this.saturation,
      _this.color,
      _this.opacity,
      _this.strongOpacity,
      _this.borderColor,
      _this.borderWidth,
      _this.borderRadius,
    );
  }
}
