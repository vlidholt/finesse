// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'accordion.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$AccordionTheme {
  bool get canMerge => true;

  static AccordionTheme? lerp(AccordionTheme? a, AccordionTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return AccordionTheme(
      icon: t < 0.5 ? a.icon : b.icon,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      underlineTitleOnHover: t < 0.5
          ? a.underlineTitleOnHover
          : b.underlineTitleOnHover,
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      maintainState: t < 0.5 ? a.maintainState : b.maintainState,
    );
  }

  AccordionTheme copyWith({
    Widget? icon,
    EdgeInsetsGeometry? padding,
    bool? underlineTitleOnHover,
    TextStyle? titleStyle,
    bool? maintainState,
  }) {
    final _this = (this as AccordionTheme);

    return AccordionTheme(
      icon: icon ?? _this.icon,
      padding: padding ?? _this.padding,
      underlineTitleOnHover:
          underlineTitleOnHover ?? _this.underlineTitleOnHover,
      titleStyle: titleStyle ?? _this.titleStyle,
      maintainState: maintainState ?? _this.maintainState,
    );
  }

  AccordionTheme merge(AccordionTheme? other) {
    final _this = (this as AccordionTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      icon: other.icon,
      padding: other.padding,
      underlineTitleOnHover: other.underlineTitleOnHover,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      maintainState: other.maintainState,
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

    final _this = (this as AccordionTheme);
    final _other = (other as AccordionTheme);

    return _other.icon == _this.icon &&
        _other.padding == _this.padding &&
        _other.underlineTitleOnHover == _this.underlineTitleOnHover &&
        _other.titleStyle == _this.titleStyle &&
        _other.maintainState == _this.maintainState;
  }

  @override
  int get hashCode {
    final _this = (this as AccordionTheme);

    return Object.hash(
      runtimeType,
      _this.icon,
      _this.padding,
      _this.underlineTitleOnHover,
      _this.titleStyle,
      _this.maintainState,
    );
  }
}
