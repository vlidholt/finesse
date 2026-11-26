// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'toast.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ToastTheme {
  bool get canMerge => true;

  static ToastTheme? lerp(ToastTheme? a, ToastTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ToastTheme(
      liquidGlass: t < 0.5 ? a.liquidGlass : b.liquidGlass,
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      filter: t < 0.5 ? a.filter : b.filter,
      border: UnaBorder.lerp(a.border, b.border, t),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      descriptionStyle: TextStyle.lerp(
        a.descriptionStyle,
        b.descriptionStyle,
        t,
      ),
      iconSize: lerpDouble$(a.iconSize, b.iconSize, t),
      successColor: Color.lerp(a.successColor, b.successColor, t),
      warningColor: Color.lerp(a.warningColor, b.warningColor, t),
      destructiveColor: Color.lerp(a.destructiveColor, b.destructiveColor, t),
      loadingColor: Color.lerp(a.loadingColor, b.loadingColor, t),
      statusTintOpacity: lerpDouble$(
        a.statusTintOpacity,
        b.statusTintOpacity,
        t,
      ),
      duration: lerpDuration$(a.duration, b.duration, t),
    );
  }

  ToastTheme copyWith({
    LiquidGlassMode? liquidGlass,
    Color? backgroundColor,
    ImageFilter? filter,
    UnaBorder? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    EdgeInsetsGeometry? padding,
    double? gap,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    double? iconSize,
    Color? successColor,
    Color? warningColor,
    Color? destructiveColor,
    Color? loadingColor,
    double? statusTintOpacity,
    Duration? duration,
  }) {
    final _this = (this as ToastTheme);

    return ToastTheme(
      liquidGlass: liquidGlass ?? _this.liquidGlass,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      filter: filter ?? _this.filter,
      border: border ?? _this.border,
      borderRadius: borderRadius ?? _this.borderRadius,
      shadows: shadows ?? _this.shadows,
      padding: padding ?? _this.padding,
      gap: gap ?? _this.gap,
      titleStyle: titleStyle ?? _this.titleStyle,
      descriptionStyle: descriptionStyle ?? _this.descriptionStyle,
      iconSize: iconSize ?? _this.iconSize,
      successColor: successColor ?? _this.successColor,
      warningColor: warningColor ?? _this.warningColor,
      destructiveColor: destructiveColor ?? _this.destructiveColor,
      loadingColor: loadingColor ?? _this.loadingColor,
      statusTintOpacity: statusTintOpacity ?? _this.statusTintOpacity,
      duration: duration ?? _this.duration,
    );
  }

  ToastTheme merge(ToastTheme? other) {
    final _this = (this as ToastTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      liquidGlass: other.liquidGlass,
      backgroundColor: other.backgroundColor,
      filter: other.filter,
      border: _this.border?.merge(other.border) ?? other.border,
      borderRadius: other.borderRadius,
      shadows: other.shadows,
      padding: other.padding,
      gap: other.gap,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      descriptionStyle:
          _this.descriptionStyle?.merge(other.descriptionStyle) ??
          other.descriptionStyle,
      iconSize: other.iconSize,
      successColor: other.successColor,
      warningColor: other.warningColor,
      destructiveColor: other.destructiveColor,
      loadingColor: other.loadingColor,
      statusTintOpacity: other.statusTintOpacity,
      duration: other.duration,
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

    final _this = (this as ToastTheme);
    final _other = (other as ToastTheme);

    return _other.liquidGlass == _this.liquidGlass &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.filter == _this.filter &&
        _other.border == _this.border &&
        _other.borderRadius == _this.borderRadius &&
        _other.shadows == _this.shadows &&
        _other.padding == _this.padding &&
        _other.gap == _this.gap &&
        _other.titleStyle == _this.titleStyle &&
        _other.descriptionStyle == _this.descriptionStyle &&
        _other.iconSize == _this.iconSize &&
        _other.successColor == _this.successColor &&
        _other.warningColor == _this.warningColor &&
        _other.destructiveColor == _this.destructiveColor &&
        _other.loadingColor == _this.loadingColor &&
        _other.statusTintOpacity == _this.statusTintOpacity &&
        _other.duration == _this.duration;
  }

  @override
  int get hashCode {
    final _this = (this as ToastTheme);

    return Object.hash(
      runtimeType,
      _this.liquidGlass,
      _this.backgroundColor,
      _this.filter,
      _this.border,
      _this.borderRadius,
      _this.shadows,
      _this.padding,
      _this.gap,
      _this.titleStyle,
      _this.descriptionStyle,
      _this.iconSize,
      _this.successColor,
      _this.warningColor,
      _this.destructiveColor,
      _this.loadingColor,
      _this.statusTintOpacity,
      _this.duration,
    );
  }
}

mixin _$ToasterTheme {
  bool get canMerge => true;

  static ToasterTheme? lerp(ToasterTheme? a, ToasterTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ToasterTheme(
      alignment: AlignmentGeometry.lerp(a.alignment, b.alignment, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      width: lerpDouble$(a.width, b.width, t),
      maxVisible: t < 0.5 ? a.maxVisible : b.maxVisible,
      gap: lerpDouble$(a.gap, b.gap, t),
      stackOffset: lerpDouble$(a.stackOffset, b.stackOffset, t),
      stackScale: lerpDouble$(a.stackScale, b.stackScale, t),
    );
  }

  ToasterTheme copyWith({
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    double? width,
    int? maxVisible,
    double? gap,
    double? stackOffset,
    double? stackScale,
  }) {
    final _this = (this as ToasterTheme);

    return ToasterTheme(
      alignment: alignment ?? _this.alignment,
      padding: padding ?? _this.padding,
      width: width ?? _this.width,
      maxVisible: maxVisible ?? _this.maxVisible,
      gap: gap ?? _this.gap,
      stackOffset: stackOffset ?? _this.stackOffset,
      stackScale: stackScale ?? _this.stackScale,
    );
  }

  ToasterTheme merge(ToasterTheme? other) {
    final _this = (this as ToasterTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      alignment: other.alignment,
      padding: other.padding,
      width: other.width,
      maxVisible: other.maxVisible,
      gap: other.gap,
      stackOffset: other.stackOffset,
      stackScale: other.stackScale,
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

    final _this = (this as ToasterTheme);
    final _other = (other as ToasterTheme);

    return _other.alignment == _this.alignment &&
        _other.padding == _this.padding &&
        _other.width == _this.width &&
        _other.maxVisible == _this.maxVisible &&
        _other.gap == _this.gap &&
        _other.stackOffset == _this.stackOffset &&
        _other.stackScale == _this.stackScale;
  }

  @override
  int get hashCode {
    final _this = (this as ToasterTheme);

    return Object.hash(
      runtimeType,
      _this.alignment,
      _this.padding,
      _this.width,
      _this.maxVisible,
      _this.gap,
      _this.stackOffset,
      _this.stackScale,
    );
  }
}
