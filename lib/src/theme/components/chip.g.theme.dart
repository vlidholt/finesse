// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'chip.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ChipTheme {
  bool get canMerge => true;

  static ChipTheme? lerp(ChipTheme? a, ChipTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ChipTheme(
      height: lerpDouble$(a.height, b.height, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      radius: BorderRadius.lerp(a.radius, b.radius, t),
      borderWidth: lerpDouble$(a.borderWidth, b.borderWidth, t),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      hoverBackgroundColor: Color.lerp(
        a.hoverBackgroundColor,
        b.hoverBackgroundColor,
        t,
      ),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      selectedBackgroundColor: Color.lerp(
        a.selectedBackgroundColor,
        b.selectedBackgroundColor,
        t,
      ),
      selectedForegroundColor: Color.lerp(
        a.selectedForegroundColor,
        b.selectedForegroundColor,
        t,
      ),
      selectedBorderColor: Color.lerp(
        a.selectedBorderColor,
        b.selectedBorderColor,
        t,
      ),
      showCheckmark: t < 0.5 ? a.showCheckmark : b.showCheckmark,
      groupSpacing: lerpDouble$(a.groupSpacing, b.groupSpacing, t),
      groupRunSpacing: lerpDouble$(a.groupRunSpacing, b.groupRunSpacing, t),
      groupFade: lerpDouble$(a.groupFade, b.groupFade, t),
    );
  }

  ChipTheme copyWith({
    double? height,
    EdgeInsetsGeometry? padding,
    double? gap,
    double? iconSize,
    BorderRadius? radius,
    double? borderWidth,
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? hoverBackgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    Color? selectedBackgroundColor,
    Color? selectedForegroundColor,
    Color? selectedBorderColor,
    bool? showCheckmark,
    double? groupSpacing,
    double? groupRunSpacing,
    double? groupFade,
  }) {
    final _this = (this as ChipTheme);

    return ChipTheme(
      height: height ?? _this.height,
      padding: padding ?? _this.padding,
      gap: gap ?? _this.gap,
      iconSize: iconSize ?? _this.iconSize,
      radius: radius ?? _this.radius,
      borderWidth: borderWidth ?? _this.borderWidth,
      textStyle: textStyle ?? _this.textStyle,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      hoverBackgroundColor: hoverBackgroundColor ?? _this.hoverBackgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      borderColor: borderColor ?? _this.borderColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? _this.selectedBackgroundColor,
      selectedForegroundColor:
          selectedForegroundColor ?? _this.selectedForegroundColor,
      selectedBorderColor: selectedBorderColor ?? _this.selectedBorderColor,
      showCheckmark: showCheckmark ?? _this.showCheckmark,
      groupSpacing: groupSpacing ?? _this.groupSpacing,
      groupRunSpacing: groupRunSpacing ?? _this.groupRunSpacing,
      groupFade: groupFade ?? _this.groupFade,
    );
  }

  ChipTheme merge(ChipTheme? other) {
    final _this = (this as ChipTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      height: other.height,
      padding: other.padding,
      gap: other.gap,
      iconSize: other.iconSize,
      radius: other.radius,
      borderWidth: other.borderWidth,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      backgroundColor: other.backgroundColor,
      hoverBackgroundColor: other.hoverBackgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      selectedBackgroundColor: other.selectedBackgroundColor,
      selectedForegroundColor: other.selectedForegroundColor,
      selectedBorderColor: other.selectedBorderColor,
      showCheckmark: other.showCheckmark,
      groupSpacing: other.groupSpacing,
      groupRunSpacing: other.groupRunSpacing,
      groupFade: other.groupFade,
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

    final _this = (this as ChipTheme);
    final _other = (other as ChipTheme);

    return _other.height == _this.height &&
        _other.padding == _this.padding &&
        _other.gap == _this.gap &&
        _other.iconSize == _this.iconSize &&
        _other.radius == _this.radius &&
        _other.borderWidth == _this.borderWidth &&
        _other.textStyle == _this.textStyle &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.hoverBackgroundColor == _this.hoverBackgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.selectedBackgroundColor == _this.selectedBackgroundColor &&
        _other.selectedForegroundColor == _this.selectedForegroundColor &&
        _other.selectedBorderColor == _this.selectedBorderColor &&
        _other.showCheckmark == _this.showCheckmark &&
        _other.groupSpacing == _this.groupSpacing &&
        _other.groupRunSpacing == _this.groupRunSpacing &&
        _other.groupFade == _this.groupFade;
  }

  @override
  int get hashCode {
    final _this = (this as ChipTheme);

    return Object.hash(
      runtimeType,
      _this.height,
      _this.padding,
      _this.gap,
      _this.iconSize,
      _this.radius,
      _this.borderWidth,
      _this.textStyle,
      _this.backgroundColor,
      _this.hoverBackgroundColor,
      _this.foregroundColor,
      _this.borderColor,
      _this.selectedBackgroundColor,
      _this.selectedForegroundColor,
      _this.selectedBorderColor,
      _this.showCheckmark,
      _this.groupSpacing,
      _this.groupRunSpacing,
      _this.groupFade,
    );
  }
}
