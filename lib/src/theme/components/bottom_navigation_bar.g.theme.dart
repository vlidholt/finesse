// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'bottom_navigation_bar.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$BottomNavigationBarTheme {
  bool get canMerge => true;

  static BottomNavigationBarTheme? lerp(
    BottomNavigationBarTheme? a,
    BottomNavigationBarTheme? b,
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

    return BottomNavigationBarTheme(
      floating: t < 0.5 ? a.floating : b.floating,
      itemWidth: lerpDouble$(a.itemWidth, b.itemWidth, t),
      itemHeight: lerpDouble$(a.itemHeight, b.itemHeight, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      actionIconSize: lerpDouble$(a.actionIconSize, b.actionIconSize, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      margin: EdgeInsetsGeometry.lerp(a.margin, b.margin, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      radius: BorderRadius.lerp(a.radius, b.radius, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      rimColor: Color.lerp(a.rimColor, b.rimColor, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      blur: lerpDouble$(a.blur, b.blur, t),
      saturation: lerpDouble$(a.saturation, b.saturation, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      selectedForegroundColor: Color.lerp(
        a.selectedForegroundColor,
        b.selectedForegroundColor,
        t,
      ),
      selectedBackgroundColor: Color.lerp(
        a.selectedBackgroundColor,
        b.selectedBackgroundColor,
        t,
      ),
      actionBackgroundColor: Color.lerp(
        a.actionBackgroundColor,
        b.actionBackgroundColor,
        t,
      ),
      actionForegroundColor: Color.lerp(
        a.actionForegroundColor,
        b.actionForegroundColor,
        t,
      ),
      showLabels: t < 0.5 ? a.showLabels : b.showLabels,
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      labeledItemWidth: lerpDouble$(a.labeledItemWidth, b.labeledItemWidth, t),
    );
  }

  BottomNavigationBarTheme copyWith({
    bool? floating,
    double? itemWidth,
    double? itemHeight,
    double? iconSize,
    double? actionIconSize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? gap,
    BorderRadius? radius,
    Color? backgroundColor,
    Color? borderColor,
    Color? rimColor,
    List<BoxShadow>? shadows,
    double? blur,
    double? saturation,
    Color? foregroundColor,
    Color? selectedForegroundColor,
    Color? selectedBackgroundColor,
    Color? actionBackgroundColor,
    Color? actionForegroundColor,
    bool? showLabels,
    TextStyle? labelStyle,
    double? labeledItemWidth,
  }) {
    final _this = (this as BottomNavigationBarTheme);

    return BottomNavigationBarTheme(
      floating: floating ?? _this.floating,
      itemWidth: itemWidth ?? _this.itemWidth,
      itemHeight: itemHeight ?? _this.itemHeight,
      iconSize: iconSize ?? _this.iconSize,
      actionIconSize: actionIconSize ?? _this.actionIconSize,
      padding: padding ?? _this.padding,
      margin: margin ?? _this.margin,
      gap: gap ?? _this.gap,
      radius: radius ?? _this.radius,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      borderColor: borderColor ?? _this.borderColor,
      rimColor: rimColor ?? _this.rimColor,
      shadows: shadows ?? _this.shadows,
      blur: blur ?? _this.blur,
      saturation: saturation ?? _this.saturation,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      selectedForegroundColor:
          selectedForegroundColor ?? _this.selectedForegroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? _this.selectedBackgroundColor,
      actionBackgroundColor:
          actionBackgroundColor ?? _this.actionBackgroundColor,
      actionForegroundColor:
          actionForegroundColor ?? _this.actionForegroundColor,
      showLabels: showLabels ?? _this.showLabels,
      labelStyle: labelStyle ?? _this.labelStyle,
      labeledItemWidth: labeledItemWidth ?? _this.labeledItemWidth,
    );
  }

  BottomNavigationBarTheme merge(BottomNavigationBarTheme? other) {
    final _this = (this as BottomNavigationBarTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      floating: other.floating,
      itemWidth: other.itemWidth,
      itemHeight: other.itemHeight,
      iconSize: other.iconSize,
      actionIconSize: other.actionIconSize,
      padding: other.padding,
      margin: other.margin,
      gap: other.gap,
      radius: other.radius,
      backgroundColor: other.backgroundColor,
      borderColor: other.borderColor,
      rimColor: other.rimColor,
      shadows: other.shadows,
      blur: other.blur,
      saturation: other.saturation,
      foregroundColor: other.foregroundColor,
      selectedForegroundColor: other.selectedForegroundColor,
      selectedBackgroundColor: other.selectedBackgroundColor,
      actionBackgroundColor: other.actionBackgroundColor,
      actionForegroundColor: other.actionForegroundColor,
      showLabels: other.showLabels,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      labeledItemWidth: other.labeledItemWidth,
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

    final _this = (this as BottomNavigationBarTheme);
    final _other = (other as BottomNavigationBarTheme);

    return _other.floating == _this.floating &&
        _other.itemWidth == _this.itemWidth &&
        _other.itemHeight == _this.itemHeight &&
        _other.iconSize == _this.iconSize &&
        _other.actionIconSize == _this.actionIconSize &&
        _other.padding == _this.padding &&
        _other.margin == _this.margin &&
        _other.gap == _this.gap &&
        _other.radius == _this.radius &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.rimColor == _this.rimColor &&
        _other.shadows == _this.shadows &&
        _other.blur == _this.blur &&
        _other.saturation == _this.saturation &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.selectedForegroundColor == _this.selectedForegroundColor &&
        _other.selectedBackgroundColor == _this.selectedBackgroundColor &&
        _other.actionBackgroundColor == _this.actionBackgroundColor &&
        _other.actionForegroundColor == _this.actionForegroundColor &&
        _other.showLabels == _this.showLabels &&
        _other.labelStyle == _this.labelStyle &&
        _other.labeledItemWidth == _this.labeledItemWidth;
  }

  @override
  int get hashCode {
    final _this = (this as BottomNavigationBarTheme);

    return Object.hashAll([
      runtimeType,
      _this.floating,
      _this.itemWidth,
      _this.itemHeight,
      _this.iconSize,
      _this.actionIconSize,
      _this.padding,
      _this.margin,
      _this.gap,
      _this.radius,
      _this.backgroundColor,
      _this.borderColor,
      _this.rimColor,
      _this.shadows,
      _this.blur,
      _this.saturation,
      _this.foregroundColor,
      _this.selectedForegroundColor,
      _this.selectedBackgroundColor,
      _this.actionBackgroundColor,
      _this.actionForegroundColor,
      _this.showLabels,
      _this.labelStyle,
      _this.labeledItemWidth,
    ]);
  }
}
