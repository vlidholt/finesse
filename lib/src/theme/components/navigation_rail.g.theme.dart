// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'navigation_rail.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$NavigationRailTheme {
  bool get canMerge => true;

  static NavigationRailTheme? lerp(
    NavigationRailTheme? a,
    NavigationRailTheme? b,
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

    return NavigationRailTheme(
      width: lerpDouble$(a.width, b.width, t),
      extendedWidth: lerpDouble$(a.extendedWidth, b.extendedWidth, t),
      itemHeight: lerpDouble$(a.itemHeight, b.itemHeight, t),
      extendedItemHeight: lerpDouble$(
        a.extendedItemHeight,
        b.extendedItemHeight,
        t,
      ),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      padding: lerpDouble$(a.padding, b.padding, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      extendedLabelStyle: TextStyle.lerp(
        a.extendedLabelStyle,
        b.extendedLabelStyle,
        t,
      ),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      selectedIconColor: Color.lerp(
        a.selectedIconColor,
        b.selectedIconColor,
        t,
      ),
      selectedLabelColor: Color.lerp(
        a.selectedLabelColor,
        b.selectedLabelColor,
        t,
      ),
      hoverColor: Color.lerp(a.hoverColor, b.hoverColor, t),
      indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t),
      indicatorWidth: lerpDouble$(a.indicatorWidth, b.indicatorWidth, t),
      indicatorInset: lerpDouble$(a.indicatorInset, b.indicatorInset, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      blur: lerpDouble$(a.blur, b.blur, t),
      saturation: lerpDouble$(a.saturation, b.saturation, t),
      actionSize: lerpDouble$(a.actionSize, b.actionSize, t),
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
    );
  }

  NavigationRailTheme copyWith({
    double? width,
    double? extendedWidth,
    double? itemHeight,
    double? extendedItemHeight,
    double? iconSize,
    double? gap,
    double? padding,
    TextStyle? labelStyle,
    TextStyle? extendedLabelStyle,
    Color? foregroundColor,
    Color? selectedIconColor,
    Color? selectedLabelColor,
    Color? hoverColor,
    Color? indicatorColor,
    double? indicatorWidth,
    double? indicatorInset,
    Color? backgroundColor,
    Color? borderColor,
    double? blur,
    double? saturation,
    double? actionSize,
    Color? actionBackgroundColor,
    Color? actionForegroundColor,
  }) {
    final _this = (this as NavigationRailTheme);

    return NavigationRailTheme(
      width: width ?? _this.width,
      extendedWidth: extendedWidth ?? _this.extendedWidth,
      itemHeight: itemHeight ?? _this.itemHeight,
      extendedItemHeight: extendedItemHeight ?? _this.extendedItemHeight,
      iconSize: iconSize ?? _this.iconSize,
      gap: gap ?? _this.gap,
      padding: padding ?? _this.padding,
      labelStyle: labelStyle ?? _this.labelStyle,
      extendedLabelStyle: extendedLabelStyle ?? _this.extendedLabelStyle,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      selectedIconColor: selectedIconColor ?? _this.selectedIconColor,
      selectedLabelColor: selectedLabelColor ?? _this.selectedLabelColor,
      hoverColor: hoverColor ?? _this.hoverColor,
      indicatorColor: indicatorColor ?? _this.indicatorColor,
      indicatorWidth: indicatorWidth ?? _this.indicatorWidth,
      indicatorInset: indicatorInset ?? _this.indicatorInset,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      borderColor: borderColor ?? _this.borderColor,
      blur: blur ?? _this.blur,
      saturation: saturation ?? _this.saturation,
      actionSize: actionSize ?? _this.actionSize,
      actionBackgroundColor:
          actionBackgroundColor ?? _this.actionBackgroundColor,
      actionForegroundColor:
          actionForegroundColor ?? _this.actionForegroundColor,
    );
  }

  NavigationRailTheme merge(NavigationRailTheme? other) {
    final _this = (this as NavigationRailTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      width: other.width,
      extendedWidth: other.extendedWidth,
      itemHeight: other.itemHeight,
      extendedItemHeight: other.extendedItemHeight,
      iconSize: other.iconSize,
      gap: other.gap,
      padding: other.padding,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      extendedLabelStyle:
          _this.extendedLabelStyle?.merge(other.extendedLabelStyle) ??
          other.extendedLabelStyle,
      foregroundColor: other.foregroundColor,
      selectedIconColor: other.selectedIconColor,
      selectedLabelColor: other.selectedLabelColor,
      hoverColor: other.hoverColor,
      indicatorColor: other.indicatorColor,
      indicatorWidth: other.indicatorWidth,
      indicatorInset: other.indicatorInset,
      backgroundColor: other.backgroundColor,
      borderColor: other.borderColor,
      blur: other.blur,
      saturation: other.saturation,
      actionSize: other.actionSize,
      actionBackgroundColor: other.actionBackgroundColor,
      actionForegroundColor: other.actionForegroundColor,
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

    final _this = (this as NavigationRailTheme);
    final _other = (other as NavigationRailTheme);

    return _other.width == _this.width &&
        _other.extendedWidth == _this.extendedWidth &&
        _other.itemHeight == _this.itemHeight &&
        _other.extendedItemHeight == _this.extendedItemHeight &&
        _other.iconSize == _this.iconSize &&
        _other.gap == _this.gap &&
        _other.padding == _this.padding &&
        _other.labelStyle == _this.labelStyle &&
        _other.extendedLabelStyle == _this.extendedLabelStyle &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.selectedIconColor == _this.selectedIconColor &&
        _other.selectedLabelColor == _this.selectedLabelColor &&
        _other.hoverColor == _this.hoverColor &&
        _other.indicatorColor == _this.indicatorColor &&
        _other.indicatorWidth == _this.indicatorWidth &&
        _other.indicatorInset == _this.indicatorInset &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.blur == _this.blur &&
        _other.saturation == _this.saturation &&
        _other.actionSize == _this.actionSize &&
        _other.actionBackgroundColor == _this.actionBackgroundColor &&
        _other.actionForegroundColor == _this.actionForegroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as NavigationRailTheme);

    return Object.hashAll([
      runtimeType,
      _this.width,
      _this.extendedWidth,
      _this.itemHeight,
      _this.extendedItemHeight,
      _this.iconSize,
      _this.gap,
      _this.padding,
      _this.labelStyle,
      _this.extendedLabelStyle,
      _this.foregroundColor,
      _this.selectedIconColor,
      _this.selectedLabelColor,
      _this.hoverColor,
      _this.indicatorColor,
      _this.indicatorWidth,
      _this.indicatorInset,
      _this.backgroundColor,
      _this.borderColor,
      _this.blur,
      _this.saturation,
      _this.actionSize,
      _this.actionBackgroundColor,
      _this.actionForegroundColor,
    ]);
  }
}
