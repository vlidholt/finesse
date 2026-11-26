// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'alert.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$AlertTheme {
  bool get canMerge => true;

  static AlertTheme? lerp(AlertTheme? a, AlertTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return AlertTheme(
      decoration: UnaDecoration.lerp(a.decoration, b.decoration, t),
      iconPadding: EdgeInsetsGeometry.lerp(a.iconPadding, b.iconPadding, t),
      iconColor: Color.lerp(a.iconColor, b.iconColor, t),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      descriptionStyle: TextStyle.lerp(
        a.descriptionStyle,
        b.descriptionStyle,
        t,
      ),
      mainAxisAlignment: t < 0.5 ? a.mainAxisAlignment : b.mainAxisAlignment,
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      successColor: Color.lerp(a.successColor, b.successColor, t),
      successBackgroundColor: Color.lerp(
        a.successBackgroundColor,
        b.successBackgroundColor,
        t,
      ),
      warningColor: Color.lerp(a.warningColor, b.warningColor, t),
      warningBackgroundColor: Color.lerp(
        a.warningBackgroundColor,
        b.warningBackgroundColor,
        t,
      ),
      infoColor: Color.lerp(a.infoColor, b.infoColor, t),
      infoBackgroundColor: Color.lerp(
        a.infoBackgroundColor,
        b.infoBackgroundColor,
        t,
      ),
    );
  }

  AlertTheme copyWith({
    UnaDecoration? decoration,
    EdgeInsetsGeometry? iconPadding,
    Color? iconColor,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double? iconSize,
    double? gap,
    Color? successColor,
    Color? successBackgroundColor,
    Color? warningColor,
    Color? warningBackgroundColor,
    Color? infoColor,
    Color? infoBackgroundColor,
  }) {
    final _this = (this as AlertTheme);

    return AlertTheme(
      decoration: decoration ?? _this.decoration,
      iconPadding: iconPadding ?? _this.iconPadding,
      iconColor: iconColor ?? _this.iconColor,
      titleStyle: titleStyle ?? _this.titleStyle,
      descriptionStyle: descriptionStyle ?? _this.descriptionStyle,
      mainAxisAlignment: mainAxisAlignment ?? _this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? _this.crossAxisAlignment,
      iconSize: iconSize ?? _this.iconSize,
      gap: gap ?? _this.gap,
      successColor: successColor ?? _this.successColor,
      successBackgroundColor:
          successBackgroundColor ?? _this.successBackgroundColor,
      warningColor: warningColor ?? _this.warningColor,
      warningBackgroundColor:
          warningBackgroundColor ?? _this.warningBackgroundColor,
      infoColor: infoColor ?? _this.infoColor,
      infoBackgroundColor: infoBackgroundColor ?? _this.infoBackgroundColor,
    );
  }

  AlertTheme merge(AlertTheme? other) {
    final _this = (this as AlertTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      iconPadding: other.iconPadding,
      iconColor: other.iconColor,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      descriptionStyle:
          _this.descriptionStyle?.merge(other.descriptionStyle) ??
          other.descriptionStyle,
      mainAxisAlignment: other.mainAxisAlignment,
      crossAxisAlignment: other.crossAxisAlignment,
      iconSize: other.iconSize,
      gap: other.gap,
      successColor: other.successColor,
      successBackgroundColor: other.successBackgroundColor,
      warningColor: other.warningColor,
      warningBackgroundColor: other.warningBackgroundColor,
      infoColor: other.infoColor,
      infoBackgroundColor: other.infoBackgroundColor,
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

    final _this = (this as AlertTheme);
    final _other = (other as AlertTheme);

    return _other.decoration == _this.decoration &&
        _other.iconPadding == _this.iconPadding &&
        _other.iconColor == _this.iconColor &&
        _other.titleStyle == _this.titleStyle &&
        _other.descriptionStyle == _this.descriptionStyle &&
        _other.mainAxisAlignment == _this.mainAxisAlignment &&
        _other.crossAxisAlignment == _this.crossAxisAlignment &&
        _other.iconSize == _this.iconSize &&
        _other.gap == _this.gap &&
        _other.successColor == _this.successColor &&
        _other.successBackgroundColor == _this.successBackgroundColor &&
        _other.warningColor == _this.warningColor &&
        _other.warningBackgroundColor == _this.warningBackgroundColor &&
        _other.infoColor == _this.infoColor &&
        _other.infoBackgroundColor == _this.infoBackgroundColor;
  }

  @override
  int get hashCode {
    final _this = (this as AlertTheme);

    return Object.hash(
      runtimeType,
      _this.decoration,
      _this.iconPadding,
      _this.iconColor,
      _this.titleStyle,
      _this.descriptionStyle,
      _this.mainAxisAlignment,
      _this.crossAxisAlignment,
      _this.iconSize,
      _this.gap,
      _this.successColor,
      _this.successBackgroundColor,
      _this.warningColor,
      _this.warningBackgroundColor,
      _this.infoColor,
      _this.infoBackgroundColor,
    );
  }
}
