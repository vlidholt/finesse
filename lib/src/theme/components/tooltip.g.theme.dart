// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'tooltip.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$TooltipTheme {
  bool get canMerge => true;

  static TooltipTheme? lerp(TooltipTheme? a, TooltipTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return TooltipTheme(
      waitDuration: lerpDuration$(a.waitDuration, b.waitDuration, t),
      showDuration: lerpDuration$(a.showDuration, b.showDuration, t),
      anchor: t < 0.5 ? a.anchor : b.anchor,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      hoverStrategies: t < 0.5 ? a.hoverStrategies : b.hoverStrategies,
      longPressDuration: lerpDuration$(
        a.longPressDuration,
        b.longPressDuration,
        t,
      ),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      maxWidth: lerpDouble$(a.maxWidth, b.maxWidth, t),
      showArrow: t < 0.5 ? a.showArrow : b.showArrow,
      arrowSize: lerpDouble$(a.arrowSize, b.arrowSize, t),
      arrowRadius: lerpDouble$(a.arrowRadius, b.arrowRadius, t),
      filter: t < 0.5 ? a.filter : b.filter,
    );
  }

  TooltipTheme copyWith({
    Duration? waitDuration,
    Duration? showDuration,
    AnchorBase? anchor,
    EdgeInsetsGeometry? padding,
    FinesseDecoration? decoration,
    HoverStrategies? hoverStrategies,
    Duration? longPressDuration,
    TextStyle? textStyle,
    double? maxWidth,
    bool? showArrow,
    double? arrowSize,
    double? arrowRadius,
    ImageFilter? filter,
  }) {
    final _this = (this as TooltipTheme);

    return TooltipTheme(
      waitDuration: waitDuration ?? _this.waitDuration,
      showDuration: showDuration ?? _this.showDuration,
      anchor: anchor ?? _this.anchor,
      padding: padding ?? _this.padding,
      decoration: decoration ?? _this.decoration,
      hoverStrategies: hoverStrategies ?? _this.hoverStrategies,
      longPressDuration: longPressDuration ?? _this.longPressDuration,
      textStyle: textStyle ?? _this.textStyle,
      maxWidth: maxWidth ?? _this.maxWidth,
      showArrow: showArrow ?? _this.showArrow,
      arrowSize: arrowSize ?? _this.arrowSize,
      arrowRadius: arrowRadius ?? _this.arrowRadius,
      filter: filter ?? _this.filter,
    );
  }

  TooltipTheme merge(TooltipTheme? other) {
    final _this = (this as TooltipTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      waitDuration: other.waitDuration,
      showDuration: other.showDuration,
      anchor: other.anchor,
      padding: other.padding,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      hoverStrategies: other.hoverStrategies,
      longPressDuration: other.longPressDuration,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      maxWidth: other.maxWidth,
      showArrow: other.showArrow,
      arrowSize: other.arrowSize,
      arrowRadius: other.arrowRadius,
      filter: other.filter,
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

    final _this = (this as TooltipTheme);
    final _other = (other as TooltipTheme);

    return _other.waitDuration == _this.waitDuration &&
        _other.showDuration == _this.showDuration &&
        _other.anchor == _this.anchor &&
        _other.padding == _this.padding &&
        _other.decoration == _this.decoration &&
        _other.hoverStrategies == _this.hoverStrategies &&
        _other.longPressDuration == _this.longPressDuration &&
        _other.textStyle == _this.textStyle &&
        _other.maxWidth == _this.maxWidth &&
        _other.showArrow == _this.showArrow &&
        _other.arrowSize == _this.arrowSize &&
        _other.arrowRadius == _this.arrowRadius &&
        _other.filter == _this.filter;
  }

  @override
  int get hashCode {
    final _this = (this as TooltipTheme);

    return Object.hash(
      runtimeType,
      _this.waitDuration,
      _this.showDuration,
      _this.anchor,
      _this.padding,
      _this.decoration,
      _this.hoverStrategies,
      _this.longPressDuration,
      _this.textStyle,
      _this.maxWidth,
      _this.showArrow,
      _this.arrowSize,
      _this.arrowRadius,
      _this.filter,
    );
  }
}
