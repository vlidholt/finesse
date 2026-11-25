// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'app_bar.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$AppBarTheme {
  bool get canMerge => true;

  static AppBarTheme? lerp(AppBarTheme? a, AppBarTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return AppBarTheme(
      height: lerpDouble$(a.height, b.height, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      foregroundColor: Color.lerp(a.foregroundColor, b.foregroundColor, t),
      borderColor: Color.lerp(a.borderColor, b.borderColor, t),
      blur: lerpDouble$(a.blur, b.blur, t),
      saturation: lerpDouble$(a.saturation, b.saturation, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      maxWidth: lerpDouble$(a.maxWidth, b.maxWidth, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      centerTitle: t < 0.5 ? a.centerTitle : b.centerTitle,
      surfaceBehavior: t < 0.5 ? a.surfaceBehavior : b.surfaceBehavior,
      largeTitleStyle: TextStyle.lerp(a.largeTitleStyle, b.largeTitleStyle, t),
      expandedHeight: lerpDouble$(a.expandedHeight, b.expandedHeight, t),
    );
  }

  AppBarTheme copyWith({
    double? height,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    double? blur,
    double? saturation,
    EdgeInsetsGeometry? padding,
    double? maxWidth,
    double? gap,
    TextStyle? titleStyle,
    bool? centerTitle,
    AppBarSurfaceBehavior? surfaceBehavior,
    TextStyle? largeTitleStyle,
    double? expandedHeight,
  }) {
    final _this = (this as AppBarTheme);

    return AppBarTheme(
      height: height ?? _this.height,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      foregroundColor: foregroundColor ?? _this.foregroundColor,
      borderColor: borderColor ?? _this.borderColor,
      blur: blur ?? _this.blur,
      saturation: saturation ?? _this.saturation,
      padding: padding ?? _this.padding,
      maxWidth: maxWidth ?? _this.maxWidth,
      gap: gap ?? _this.gap,
      titleStyle: titleStyle ?? _this.titleStyle,
      centerTitle: centerTitle ?? _this.centerTitle,
      surfaceBehavior: surfaceBehavior ?? _this.surfaceBehavior,
      largeTitleStyle: largeTitleStyle ?? _this.largeTitleStyle,
      expandedHeight: expandedHeight ?? _this.expandedHeight,
    );
  }

  AppBarTheme merge(AppBarTheme? other) {
    final _this = (this as AppBarTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      height: other.height,
      backgroundColor: other.backgroundColor,
      foregroundColor: other.foregroundColor,
      borderColor: other.borderColor,
      blur: other.blur,
      saturation: other.saturation,
      padding: other.padding,
      maxWidth: other.maxWidth,
      gap: other.gap,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      centerTitle: other.centerTitle,
      surfaceBehavior: other.surfaceBehavior,
      largeTitleStyle:
          _this.largeTitleStyle?.merge(other.largeTitleStyle) ??
          other.largeTitleStyle,
      expandedHeight: other.expandedHeight,
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

    final _this = (this as AppBarTheme);
    final _other = (other as AppBarTheme);

    return _other.height == _this.height &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.foregroundColor == _this.foregroundColor &&
        _other.borderColor == _this.borderColor &&
        _other.blur == _this.blur &&
        _other.saturation == _this.saturation &&
        _other.padding == _this.padding &&
        _other.maxWidth == _this.maxWidth &&
        _other.gap == _this.gap &&
        _other.titleStyle == _this.titleStyle &&
        _other.centerTitle == _this.centerTitle &&
        _other.surfaceBehavior == _this.surfaceBehavior &&
        _other.largeTitleStyle == _this.largeTitleStyle &&
        _other.expandedHeight == _this.expandedHeight;
  }

  @override
  int get hashCode {
    final _this = (this as AppBarTheme);

    return Object.hash(
      runtimeType,
      _this.height,
      _this.backgroundColor,
      _this.foregroundColor,
      _this.borderColor,
      _this.blur,
      _this.saturation,
      _this.padding,
      _this.maxWidth,
      _this.gap,
      _this.titleStyle,
      _this.centerTitle,
      _this.surfaceBehavior,
      _this.largeTitleStyle,
      _this.expandedHeight,
    );
  }
}
