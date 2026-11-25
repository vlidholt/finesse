// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'list_tile.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ListTileTheme {
  bool get canMerge => true;

  static ListTileTheme? lerp(ListTileTheme? a, ListTileTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ListTileTheme(
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      titleGap: lerpDouble$(a.titleGap, b.titleGap, t),
      radius: BorderRadius.lerp(a.radius, b.radius, t),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      subtitleStyle: TextStyle.lerp(a.subtitleStyle, b.subtitleStyle, t),
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t),
      selectedColor: Color.lerp(a.selectedColor, b.selectedColor, t),
      pressScale: lerpDouble$(a.pressScale, b.pressScale, t),
      valueStyle: TextStyle.lerp(a.valueStyle, b.valueStyle, t),
      chevronColor: Color.lerp(a.chevronColor, b.chevronColor, t),
      chevronSize: lerpDouble$(a.chevronSize, b.chevronSize, t),
      destructiveColor: Color.lerp(a.destructiveColor, b.destructiveColor, t),
    );
  }

  ListTileTheme copyWith({
    EdgeInsetsGeometry? padding,
    double? gap,
    double? titleGap,
    BorderRadius? radius,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    Color? hoverColor,
    Color? selectedColor,
    double? pressScale,
    TextStyle? valueStyle,
    Color? chevronColor,
    double? chevronSize,
    Color? destructiveColor,
  }) {
    final _this = (this as ListTileTheme);

    return ListTileTheme(
      padding: padding ?? _this.padding,
      gap: gap ?? _this.gap,
      titleGap: titleGap ?? _this.titleGap,
      radius: radius ?? _this.radius,
      titleStyle: titleStyle ?? _this.titleStyle,
      subtitleStyle: subtitleStyle ?? _this.subtitleStyle,
      hoverColor: hoverColor ?? _this.hoverColor,
      selectedColor: selectedColor ?? _this.selectedColor,
      pressScale: pressScale ?? _this.pressScale,
      valueStyle: valueStyle ?? _this.valueStyle,
      chevronColor: chevronColor ?? _this.chevronColor,
      chevronSize: chevronSize ?? _this.chevronSize,
      destructiveColor: destructiveColor ?? _this.destructiveColor,
    );
  }

  ListTileTheme merge(ListTileTheme? other) {
    final _this = (this as ListTileTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      padding: other.padding,
      gap: other.gap,
      titleGap: other.titleGap,
      radius: other.radius,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      subtitleStyle:
          _this.subtitleStyle?.merge(other.subtitleStyle) ??
          other.subtitleStyle,
      hoverColor: other.hoverColor,
      selectedColor: other.selectedColor,
      pressScale: other.pressScale,
      valueStyle: _this.valueStyle?.merge(other.valueStyle) ?? other.valueStyle,
      chevronColor: other.chevronColor,
      chevronSize: other.chevronSize,
      destructiveColor: other.destructiveColor,
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

    final _this = (this as ListTileTheme);
    final _other = (other as ListTileTheme);

    return _other.padding == _this.padding &&
        _other.gap == _this.gap &&
        _other.titleGap == _this.titleGap &&
        _other.radius == _this.radius &&
        _other.titleStyle == _this.titleStyle &&
        _other.subtitleStyle == _this.subtitleStyle &&
        _other.hoverColor == _this.hoverColor &&
        _other.selectedColor == _this.selectedColor &&
        _other.pressScale == _this.pressScale &&
        _other.valueStyle == _this.valueStyle &&
        _other.chevronColor == _this.chevronColor &&
        _other.chevronSize == _this.chevronSize &&
        _other.destructiveColor == _this.destructiveColor;
  }

  @override
  int get hashCode {
    final _this = (this as ListTileTheme);

    return Object.hash(
      runtimeType,
      _this.padding,
      _this.gap,
      _this.titleGap,
      _this.radius,
      _this.titleStyle,
      _this.subtitleStyle,
      _this.hoverColor,
      _this.selectedColor,
      _this.pressScale,
      _this.valueStyle,
      _this.chevronColor,
      _this.chevronSize,
      _this.destructiveColor,
    );
  }
}
