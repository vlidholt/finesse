// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'button.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ButtonTheme {
  bool get canMerge => true;

  static ButtonTheme? lerp(ButtonTheme? a, ButtonTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ButtonTheme(
      mouseCursor: t < 0.5 ? a.mouseCursor : b.mouseCursor,
      size: t < 0.5 ? a.size : b.size,
      sizesTheme: ButtonSizesTheme.lerp(a.sizesTheme, b.sizesTheme, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      hoverBackgroundColor: Color.lerp(
        a.hoverBackgroundColor,
        b.hoverBackgroundColor,
        t,
      ),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      hoverForegroundColor: Color.lerp(
        a.hoverForegroundColor,
        b.hoverForegroundColor,
        t,
      ),
      pressedBackgroundColor: Color.lerp(
        a.pressedBackgroundColor,
        b.pressedBackgroundColor,
        t,
      ),
      pressedForegroundColor: Color.lerp(
        a.pressedForegroundColor,
        b.pressedForegroundColor,
        t,
      ),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      textDecoration: t < 0.5 ? a.textDecoration : b.textDecoration,
      hoverTextDecoration: t < 0.5
          ? a.hoverTextDecoration
          : b.hoverTextDecoration,
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      width: lerpDouble$(a.width, b.width, t),
      height: lerpDouble$(a.height, b.height, t),
      longPressDuration: lerpDuration$(
        a.longPressDuration,
        b.longPressDuration,
        t,
      ),
      hoverStrategies: t < 0.5 ? a.hoverStrategies : b.hoverStrategies,
      mainAxisAlignment: t < 0.5 ? a.mainAxisAlignment : b.mainAxisAlignment,
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
      gap: lerpDouble$(a.gap, b.gap, t),
      expands: t < 0.5 ? a.expands : b.expands,
      pressedOffset: Offset.lerp(a.pressedOffset, b.pressedOffset, t),
      pressAnimationDuration: lerpDuration$(
        a.pressAnimationDuration,
        b.pressAnimationDuration,
        t,
      ),
      pressScale: lerpDouble$(a.pressScale, b.pressScale, t),
      transitionDuration: lerpDuration$(
        a.transitionDuration,
        b.transitionDuration,
        t,
      ),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
    );
  }

  ButtonTheme copyWith({
    MouseCursor? mouseCursor,
    ButtonSize? size,
    ButtonSizesTheme? sizesTheme,
    Color? backgroundColor,
    Color? hoverBackgroundColor,
    Color? foregroundColor,
    Color? hoverForegroundColor,
    Color? pressedBackgroundColor,
    Color? pressedForegroundColor,
    List<BoxShadow>? shadows,
    Gradient? gradient,
    TextDecoration? textDecoration,
    TextDecoration? hoverTextDecoration,
    FinesseDecoration? decoration,
    double? width,
    double? height,
    Duration? longPressDuration,
    HoverStrategies? hoverStrategies,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    double? gap,
    bool? expands,
    Offset? pressedOffset,
    Duration? pressAnimationDuration,
    double? pressScale,
    Duration? transitionDuration,
    TextStyle? textStyle,
  }) {
    final _this = (this as ButtonTheme);

    return ButtonTheme(
      mouseCursor: mouseCursor ?? _this.mouseCursor,
      size: size ?? _this.size,
      sizesTheme: sizesTheme ?? _this.sizesTheme,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      hoverBackgroundColor: hoverBackgroundColor ?? _this.hoverBackgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      hoverForegroundColor: hoverForegroundColor ?? _this.hoverForegroundColor,
      pressedBackgroundColor:
          pressedBackgroundColor ?? _this.pressedBackgroundColor,
      pressedForegroundColor:
          pressedForegroundColor ?? _this.pressedForegroundColor,
      shadows: shadows ?? _this.shadows,
      gradient: gradient ?? _this.gradient,
      textDecoration: textDecoration ?? _this.textDecoration,
      hoverTextDecoration: hoverTextDecoration ?? _this.hoverTextDecoration,
      decoration: decoration ?? _this.decoration,
      width: width ?? _this.width,
      height: height ?? _this.height,
      longPressDuration: longPressDuration ?? _this.longPressDuration,
      hoverStrategies: hoverStrategies ?? _this.hoverStrategies,
      mainAxisAlignment: mainAxisAlignment ?? _this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? _this.crossAxisAlignment,
      gap: gap ?? _this.gap,
      expands: expands ?? _this.expands,
      pressedOffset: pressedOffset ?? _this.pressedOffset,
      pressAnimationDuration:
          pressAnimationDuration ?? _this.pressAnimationDuration,
      pressScale: pressScale ?? _this.pressScale,
      transitionDuration: transitionDuration ?? _this.transitionDuration,
      textStyle: textStyle ?? _this.textStyle,
    );
  }

  ButtonTheme merge(ButtonTheme? other) {
    final _this = (this as ButtonTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      mouseCursor: other.mouseCursor,
      size: other.size,
      sizesTheme: _this.sizesTheme?.merge(other.sizesTheme) ?? other.sizesTheme,
      backgroundColor: other.backgroundColor,
      hoverBackgroundColor: other.hoverBackgroundColor,
      foregroundColor: other.foregroundColor,
      hoverForegroundColor: other.hoverForegroundColor,
      pressedBackgroundColor: other.pressedBackgroundColor,
      pressedForegroundColor: other.pressedForegroundColor,
      shadows: other.shadows,
      gradient: other.gradient,
      textDecoration: other.textDecoration,
      hoverTextDecoration: other.hoverTextDecoration,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      width: other.width,
      height: other.height,
      longPressDuration: other.longPressDuration,
      hoverStrategies: other.hoverStrategies,
      mainAxisAlignment: other.mainAxisAlignment,
      crossAxisAlignment: other.crossAxisAlignment,
      gap: other.gap,
      expands: other.expands,
      pressedOffset: other.pressedOffset,
      pressAnimationDuration: other.pressAnimationDuration,
      pressScale: other.pressScale,
      transitionDuration: other.transitionDuration,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
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

    final _this = (this as ButtonTheme);
    final _other = (other as ButtonTheme);

    return _other.mouseCursor == _this.mouseCursor &&
        _other.size == _this.size &&
        _other.sizesTheme == _this.sizesTheme &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.hoverBackgroundColor == _this.hoverBackgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.hoverForegroundColor == _this.hoverForegroundColor &&
        _other.pressedBackgroundColor == _this.pressedBackgroundColor &&
        _other.pressedForegroundColor == _this.pressedForegroundColor &&
        _other.shadows == _this.shadows &&
        _other.gradient == _this.gradient &&
        _other.textDecoration == _this.textDecoration &&
        _other.hoverTextDecoration == _this.hoverTextDecoration &&
        _other.decoration == _this.decoration &&
        _other.width == _this.width &&
        _other.height == _this.height &&
        _other.longPressDuration == _this.longPressDuration &&
        _other.hoverStrategies == _this.hoverStrategies &&
        _other.mainAxisAlignment == _this.mainAxisAlignment &&
        _other.crossAxisAlignment == _this.crossAxisAlignment &&
        _other.gap == _this.gap &&
        _other.expands == _this.expands &&
        _other.pressedOffset == _this.pressedOffset &&
        _other.pressAnimationDuration == _this.pressAnimationDuration &&
        _other.pressScale == _this.pressScale &&
        _other.transitionDuration == _this.transitionDuration &&
        _other.textStyle == _this.textStyle;
  }

  @override
  int get hashCode {
    final _this = (this as ButtonTheme);

    return Object.hashAll([
      runtimeType,
      _this.mouseCursor,
      _this.size,
      _this.sizesTheme,
      _this.backgroundColor,
      _this.hoverBackgroundColor,
      _this.foregroundColor,
      _this.hoverForegroundColor,
      _this.pressedBackgroundColor,
      _this.pressedForegroundColor,
      _this.shadows,
      _this.gradient,
      _this.textDecoration,
      _this.hoverTextDecoration,
      _this.decoration,
      _this.width,
      _this.height,
      _this.longPressDuration,
      _this.hoverStrategies,
      _this.mainAxisAlignment,
      _this.crossAxisAlignment,
      _this.gap,
      _this.expands,
      _this.pressedOffset,
      _this.pressAnimationDuration,
      _this.pressScale,
      _this.transitionDuration,
      _this.textStyle,
    ]);
  }
}
