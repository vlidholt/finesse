// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'navigation_bar.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$NavigationBarTheme {
  bool get canMerge => true;

  static NavigationBarTheme? lerp(
    NavigationBarTheme? a,
    NavigationBarTheme? b,
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

    return NavigationBarTheme(
      itemWidth: lerpDouble$(a.itemWidth, b.itemWidth, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
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
      indicatorHeight: lerpDouble$(a.indicatorHeight, b.indicatorHeight, t),
      indicatorInset: lerpDouble$(a.indicatorInset, b.indicatorInset, t),
    );
  }

  NavigationBarTheme copyWith({
    double? itemWidth,
    double? iconSize,
    double? gap,
    TextStyle? labelStyle,
    Color? foregroundColor,
    Color? selectedIconColor,
    Color? selectedLabelColor,
    Color? hoverColor,
    Color? indicatorColor,
    double? indicatorHeight,
    double? indicatorInset,
  }) {
    final _this = (this as NavigationBarTheme);

    return NavigationBarTheme(
      itemWidth: itemWidth ?? _this.itemWidth,
      iconSize: iconSize ?? _this.iconSize,
      gap: gap ?? _this.gap,
      labelStyle: labelStyle ?? _this.labelStyle,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      selectedIconColor: selectedIconColor ?? _this.selectedIconColor,
      selectedLabelColor: selectedLabelColor ?? _this.selectedLabelColor,
      hoverColor: hoverColor ?? _this.hoverColor,
      indicatorColor: indicatorColor ?? _this.indicatorColor,
      indicatorHeight: indicatorHeight ?? _this.indicatorHeight,
      indicatorInset: indicatorInset ?? _this.indicatorInset,
    );
  }

  NavigationBarTheme merge(NavigationBarTheme? other) {
    final _this = (this as NavigationBarTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      itemWidth: other.itemWidth,
      iconSize: other.iconSize,
      gap: other.gap,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
      foregroundColor: other.foregroundColor,
      selectedIconColor: other.selectedIconColor,
      selectedLabelColor: other.selectedLabelColor,
      hoverColor: other.hoverColor,
      indicatorColor: other.indicatorColor,
      indicatorHeight: other.indicatorHeight,
      indicatorInset: other.indicatorInset,
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

    final _this = (this as NavigationBarTheme);
    final _other = (other as NavigationBarTheme);

    return _other.itemWidth == _this.itemWidth &&
        _other.iconSize == _this.iconSize &&
        _other.gap == _this.gap &&
        _other.labelStyle == _this.labelStyle &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.selectedIconColor == _this.selectedIconColor &&
        _other.selectedLabelColor == _this.selectedLabelColor &&
        _other.hoverColor == _this.hoverColor &&
        _other.indicatorColor == _this.indicatorColor &&
        _other.indicatorHeight == _this.indicatorHeight &&
        _other.indicatorInset == _this.indicatorInset;
  }

  @override
  int get hashCode {
    final _this = (this as NavigationBarTheme);

    return Object.hash(
      runtimeType,
      _this.itemWidth,
      _this.iconSize,
      _this.gap,
      _this.labelStyle,
      _this.foregroundColor,
      _this.selectedIconColor,
      _this.selectedLabelColor,
      _this.hoverColor,
      _this.indicatorColor,
      _this.indicatorHeight,
      _this.indicatorInset,
    );
  }
}
