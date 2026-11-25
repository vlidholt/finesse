// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'popover.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$PopoverTheme {
  bool get canMerge => true;

  static PopoverTheme? lerp(PopoverTheme? a, PopoverTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return PopoverTheme(
      liquidGlass: t < 0.5 ? a.liquidGlass : b.liquidGlass,
      shadows: t < 0.5 ? a.shadows : b.shadows,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      anchor: t < 0.5 ? a.anchor : b.anchor,
      filter: t < 0.5 ? a.filter : b.filter,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      showArrow: t < 0.5 ? a.showArrow : b.showArrow,
      arrowSize: lerpDouble$(a.arrowSize, b.arrowSize, t),
      arrowRadius: lerpDouble$(a.arrowRadius, b.arrowRadius, t),
    );
  }

  PopoverTheme copyWith({
    LiquidGlassMode? liquidGlass,
    List<BoxShadow>? shadows,
    EdgeInsetsGeometry? padding,
    FinesseDecoration? decoration,
    AnchorBase? anchor,
    ImageFilter? filter,
    TextStyle? textStyle,
    bool? showArrow,
    double? arrowSize,
    double? arrowRadius,
  }) {
    final _this = (this as PopoverTheme);

    return PopoverTheme(
      liquidGlass: liquidGlass ?? _this.liquidGlass,
      shadows: shadows ?? _this.shadows,
      padding: padding ?? _this.padding,
      decoration: decoration ?? _this.decoration,
      anchor: anchor ?? _this.anchor,
      filter: filter ?? _this.filter,
      textStyle: textStyle ?? _this.textStyle,
      showArrow: showArrow ?? _this.showArrow,
      arrowSize: arrowSize ?? _this.arrowSize,
      arrowRadius: arrowRadius ?? _this.arrowRadius,
    );
  }

  PopoverTheme merge(PopoverTheme? other) {
    final _this = (this as PopoverTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      liquidGlass: other.liquidGlass,
      shadows: other.shadows,
      padding: other.padding,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      anchor: other.anchor,
      filter: other.filter,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      showArrow: other.showArrow,
      arrowSize: other.arrowSize,
      arrowRadius: other.arrowRadius,
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

    final _this = (this as PopoverTheme);
    final _other = (other as PopoverTheme);

    return _other.liquidGlass == _this.liquidGlass &&
        _other.shadows == _this.shadows &&
        _other.padding == _this.padding &&
        _other.decoration == _this.decoration &&
        _other.anchor == _this.anchor &&
        _other.filter == _this.filter &&
        _other.textStyle == _this.textStyle &&
        _other.showArrow == _this.showArrow &&
        _other.arrowSize == _this.arrowSize &&
        _other.arrowRadius == _this.arrowRadius;
  }

  @override
  int get hashCode {
    final _this = (this as PopoverTheme);

    return Object.hash(
      runtimeType,
      _this.liquidGlass,
      _this.shadows,
      _this.padding,
      _this.decoration,
      _this.anchor,
      _this.filter,
      _this.textStyle,
      _this.showArrow,
      _this.arrowSize,
      _this.arrowRadius,
    );
  }
}
