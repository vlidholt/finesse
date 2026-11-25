// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'wheel_picker.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$WheelPickerTheme {
  bool get canMerge => true;

  static WheelPickerTheme? lerp(
    WheelPickerTheme? a,
    WheelPickerTheme? b,
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

    return WheelPickerTheme(
      itemExtent: lerpDouble$(a.itemExtent, b.itemExtent, t),
      itemPadding: EdgeInsetsGeometry.lerp(a.itemPadding, b.itemPadding, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      selectedTextStyle: TextStyle.lerp(
        a.selectedTextStyle,
        b.selectedTextStyle,
        t,
      ),
      disabledOpacity: lerpDouble$(a.disabledOpacity, b.disabledOpacity, t),
      lensColor: Color.lerp(a.lensColor, b.lensColor, t),
      lensBorderColor: Color.lerp(a.lensBorderColor, b.lensBorderColor, t),
      lensBorderWidth: lerpDouble$(a.lensBorderWidth, b.lensBorderWidth, t),
      lensRadius: BorderRadius.lerp(a.lensRadius, b.lensRadius, t),
      lensMagnification: lerpDouble$(
        a.lensMagnification,
        b.lensMagnification,
        t,
      ),
      curvature: lerpDouble$(a.curvature, b.curvature, t),
      edgeFade: lerpDouble$(a.edgeFade, b.edgeFade, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      groupPadding: EdgeInsetsGeometry.lerp(a.groupPadding, b.groupPadding, t),
    );
  }

  WheelPickerTheme copyWith({
    double? itemExtent,
    EdgeInsetsGeometry? itemPadding,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    double? disabledOpacity,
    Color? lensColor,
    Color? lensBorderColor,
    double? lensBorderWidth,
    BorderRadius? lensRadius,
    double? lensMagnification,
    double? curvature,
    double? edgeFade,
    double? gap,
    EdgeInsetsGeometry? groupPadding,
  }) {
    final _this = (this as WheelPickerTheme);

    return WheelPickerTheme(
      itemExtent: itemExtent ?? _this.itemExtent,
      itemPadding: itemPadding ?? _this.itemPadding,
      textStyle: textStyle ?? _this.textStyle,
      selectedTextStyle: selectedTextStyle ?? _this.selectedTextStyle,
      disabledOpacity: disabledOpacity ?? _this.disabledOpacity,
      lensColor: lensColor ?? _this.lensColor,
      lensBorderColor: lensBorderColor ?? _this.lensBorderColor,
      lensBorderWidth: lensBorderWidth ?? _this.lensBorderWidth,
      lensRadius: lensRadius ?? _this.lensRadius,
      lensMagnification: lensMagnification ?? _this.lensMagnification,
      curvature: curvature ?? _this.curvature,
      edgeFade: edgeFade ?? _this.edgeFade,
      gap: gap ?? _this.gap,
      groupPadding: groupPadding ?? _this.groupPadding,
    );
  }

  WheelPickerTheme merge(WheelPickerTheme? other) {
    final _this = (this as WheelPickerTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      itemExtent: other.itemExtent,
      itemPadding: other.itemPadding,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      selectedTextStyle:
          _this.selectedTextStyle?.merge(other.selectedTextStyle) ??
          other.selectedTextStyle,
      disabledOpacity: other.disabledOpacity,
      lensColor: other.lensColor,
      lensBorderColor: other.lensBorderColor,
      lensBorderWidth: other.lensBorderWidth,
      lensRadius: other.lensRadius,
      lensMagnification: other.lensMagnification,
      curvature: other.curvature,
      edgeFade: other.edgeFade,
      gap: other.gap,
      groupPadding: other.groupPadding,
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

    final _this = (this as WheelPickerTheme);
    final _other = (other as WheelPickerTheme);

    return _other.itemExtent == _this.itemExtent &&
        _other.itemPadding == _this.itemPadding &&
        _other.textStyle == _this.textStyle &&
        _other.selectedTextStyle == _this.selectedTextStyle &&
        _other.disabledOpacity == _this.disabledOpacity &&
        _other.lensColor == _this.lensColor &&
        _other.lensBorderColor == _this.lensBorderColor &&
        _other.lensBorderWidth == _this.lensBorderWidth &&
        _other.lensRadius == _this.lensRadius &&
        _other.lensMagnification == _this.lensMagnification &&
        _other.curvature == _this.curvature &&
        _other.edgeFade == _this.edgeFade &&
        _other.gap == _this.gap &&
        _other.groupPadding == _this.groupPadding;
  }

  @override
  int get hashCode {
    final _this = (this as WheelPickerTheme);

    return Object.hash(
      runtimeType,
      _this.itemExtent,
      _this.itemPadding,
      _this.textStyle,
      _this.selectedTextStyle,
      _this.disabledOpacity,
      _this.lensColor,
      _this.lensBorderColor,
      _this.lensBorderWidth,
      _this.lensRadius,
      _this.lensMagnification,
      _this.curvature,
      _this.edgeFade,
      _this.gap,
      _this.groupPadding,
    );
  }
}
