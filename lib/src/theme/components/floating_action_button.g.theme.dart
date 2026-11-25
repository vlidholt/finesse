// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'floating_action_button.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$FloatingActionButtonTheme {
  bool get canMerge => true;

  static FloatingActionButtonTheme? lerp(
    FloatingActionButtonTheme? a,
    FloatingActionButtonTheme? b,
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

    return FloatingActionButtonTheme(
      size: lerpDouble$(a.size, b.size, t),
      sizeSm: lerpDouble$(a.sizeSm, b.sizeSm, t),
      sizeLg: lerpDouble$(a.sizeLg, b.sizeLg, t),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      iconSizeSm: lerpDouble$(a.iconSizeSm, b.iconSizeSm, t),
      iconSizeLg: lerpDouble$(a.iconSizeLg, b.iconSizeLg, t),
      padding: lerpDouble$(a.padding, b.padding, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      secondaryBackgroundColor: Color.lerp(
        a.secondaryBackgroundColor,
        b.secondaryBackgroundColor,
        t,
      ),
      secondaryForegroundColor: Color.lerp(
        a.secondaryForegroundColor,
        b.secondaryForegroundColor,
        t,
      ),
      glassForegroundColor: Color.lerp(
        a.glassForegroundColor,
        b.glassForegroundColor,
        t,
      ),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
    );
  }

  FloatingActionButtonTheme copyWith({
    double? size,
    double? sizeSm,
    double? sizeLg,
    double? iconSize,
    double? iconSizeSm,
    double? iconSizeLg,
    double? padding,
    double? gap,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? secondaryBackgroundColor,
    Color? secondaryForegroundColor,
    Color? glassForegroundColor,
    List<BoxShadow>? shadows,
    TextStyle? labelStyle,
  }) {
    final _this = (this as FloatingActionButtonTheme);

    return FloatingActionButtonTheme(
      size: size ?? _this.size,
      sizeSm: sizeSm ?? _this.sizeSm,
      sizeLg: sizeLg ?? _this.sizeLg,
      iconSize: iconSize ?? _this.iconSize,
      iconSizeSm: iconSizeSm ?? _this.iconSizeSm,
      iconSizeLg: iconSizeLg ?? _this.iconSizeLg,
      padding: padding ?? _this.padding,
      gap: gap ?? _this.gap,
      borderRadius: borderRadius ?? _this.borderRadius,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      secondaryBackgroundColor:
          secondaryBackgroundColor ?? _this.secondaryBackgroundColor,
      secondaryForegroundColor:
          secondaryForegroundColor ?? _this.secondaryForegroundColor,
      glassForegroundColor: glassForegroundColor ?? _this.glassForegroundColor,
      shadows: shadows ?? _this.shadows,
      labelStyle: labelStyle ?? _this.labelStyle,
    );
  }

  FloatingActionButtonTheme merge(FloatingActionButtonTheme? other) {
    final _this = (this as FloatingActionButtonTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      size: other.size,
      sizeSm: other.sizeSm,
      sizeLg: other.sizeLg,
      iconSize: other.iconSize,
      iconSizeSm: other.iconSizeSm,
      iconSizeLg: other.iconSizeLg,
      padding: other.padding,
      gap: other.gap,
      borderRadius: other.borderRadius,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      secondaryBackgroundColor: other.secondaryBackgroundColor,
      secondaryForegroundColor: other.secondaryForegroundColor,
      glassForegroundColor: other.glassForegroundColor,
      shadows: other.shadows,
      labelStyle: _this.labelStyle?.merge(other.labelStyle) ?? other.labelStyle,
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

    final _this = (this as FloatingActionButtonTheme);
    final _other = (other as FloatingActionButtonTheme);

    return _other.size == _this.size &&
        _other.sizeSm == _this.sizeSm &&
        _other.sizeLg == _this.sizeLg &&
        _other.iconSize == _this.iconSize &&
        _other.iconSizeSm == _this.iconSizeSm &&
        _other.iconSizeLg == _this.iconSizeLg &&
        _other.padding == _this.padding &&
        _other.gap == _this.gap &&
        _other.borderRadius == _this.borderRadius &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.secondaryBackgroundColor == _this.secondaryBackgroundColor &&
        _other.secondaryForegroundColor == _this.secondaryForegroundColor &&
        _other.glassForegroundColor == _this.glassForegroundColor &&
        _other.shadows == _this.shadows &&
        _other.labelStyle == _this.labelStyle;
  }

  @override
  int get hashCode {
    final _this = (this as FloatingActionButtonTheme);

    return Object.hash(
      runtimeType,
      _this.size,
      _this.sizeSm,
      _this.sizeLg,
      _this.iconSize,
      _this.iconSizeSm,
      _this.iconSizeLg,
      _this.padding,
      _this.gap,
      _this.borderRadius,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.secondaryBackgroundColor,
      _this.secondaryForegroundColor,
      _this.glassForegroundColor,
      _this.shadows,
      _this.labelStyle,
    );
  }
}
