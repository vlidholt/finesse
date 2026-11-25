// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'text_selection.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$TextSelectionTheme {
  bool get canMerge => true;

  static TextSelectionTheme? lerp(
    TextSelectionTheme? a,
    TextSelectionTheme? b,
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

    return TextSelectionTheme(
      handleColor: Color.lerp(a.handleColor, b.handleColor, t),
      handleSize: lerpDouble$(a.handleSize, b.handleSize, t),
      handleStemWidth: lerpDouble$(a.handleStemWidth, b.handleStemWidth, t),
      toolbarHeight: lerpDouble$(a.toolbarHeight, b.toolbarHeight, t),
      toolbarDecoration: FinesseDecoration.lerp(
        a.toolbarDecoration,
        b.toolbarDecoration,
        t,
      ),
      toolbarItemPadding: EdgeInsetsGeometry.lerp(
        a.toolbarItemPadding,
        b.toolbarItemPadding,
        t,
      ),
      toolbarTextStyle: TextStyle.lerp(
        a.toolbarTextStyle,
        b.toolbarTextStyle,
        t,
      ),
      toolbarDividerColor: Color.lerp(
        a.toolbarDividerColor,
        b.toolbarDividerColor,
        t,
      ),
      toolbarPressedColor: Color.lerp(
        a.toolbarPressedColor,
        b.toolbarPressedColor,
        t,
      ),
      toolbarGap: lerpDouble$(a.toolbarGap, b.toolbarGap, t),
      magnifierSize: Size.lerp(a.magnifierSize, b.magnifierSize, t),
      magnifierScale: lerpDouble$(a.magnifierScale, b.magnifierScale, t),
      magnifierBorderRadius: BorderRadius.lerp(
        a.magnifierBorderRadius,
        b.magnifierBorderRadius,
        t,
      ),
      magnifierBorderColor: Color.lerp(
        a.magnifierBorderColor,
        b.magnifierBorderColor,
        t,
      ),
      magnifierShadows: t < 0.5 ? a.magnifierShadows : b.magnifierShadows,
    );
  }

  TextSelectionTheme copyWith({
    Color? handleColor,
    double? handleSize,
    double? handleStemWidth,
    double? toolbarHeight,
    FinesseDecoration? toolbarDecoration,
    EdgeInsetsGeometry? toolbarItemPadding,
    TextStyle? toolbarTextStyle,
    Color? toolbarDividerColor,
    Color? toolbarPressedColor,
    double? toolbarGap,
    Size? magnifierSize,
    double? magnifierScale,
    BorderRadius? magnifierBorderRadius,
    Color? magnifierBorderColor,
    List<BoxShadow>? magnifierShadows,
  }) {
    final _this = (this as TextSelectionTheme);

    return TextSelectionTheme(
      handleColor: handleColor ?? _this.handleColor,
      handleSize: handleSize ?? _this.handleSize,
      handleStemWidth: handleStemWidth ?? _this.handleStemWidth,
      toolbarHeight: toolbarHeight ?? _this.toolbarHeight,
      toolbarDecoration: toolbarDecoration ?? _this.toolbarDecoration,
      toolbarItemPadding: toolbarItemPadding ?? _this.toolbarItemPadding,
      toolbarTextStyle: toolbarTextStyle ?? _this.toolbarTextStyle,
      toolbarDividerColor: toolbarDividerColor ?? _this.toolbarDividerColor,
      toolbarPressedColor: toolbarPressedColor ?? _this.toolbarPressedColor,
      toolbarGap: toolbarGap ?? _this.toolbarGap,
      magnifierSize: magnifierSize ?? _this.magnifierSize,
      magnifierScale: magnifierScale ?? _this.magnifierScale,
      magnifierBorderRadius:
          magnifierBorderRadius ?? _this.magnifierBorderRadius,
      magnifierBorderColor: magnifierBorderColor ?? _this.magnifierBorderColor,
      magnifierShadows: magnifierShadows ?? _this.magnifierShadows,
    );
  }

  TextSelectionTheme merge(TextSelectionTheme? other) {
    final _this = (this as TextSelectionTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      handleColor: other.handleColor,
      handleSize: other.handleSize,
      handleStemWidth: other.handleStemWidth,
      toolbarHeight: other.toolbarHeight,
      toolbarDecoration:
          _this.toolbarDecoration?.merge(other.toolbarDecoration) ??
          other.toolbarDecoration,
      toolbarItemPadding: other.toolbarItemPadding,
      toolbarTextStyle:
          _this.toolbarTextStyle?.merge(other.toolbarTextStyle) ??
          other.toolbarTextStyle,
      toolbarDividerColor: other.toolbarDividerColor,
      toolbarPressedColor: other.toolbarPressedColor,
      toolbarGap: other.toolbarGap,
      magnifierSize: other.magnifierSize,
      magnifierScale: other.magnifierScale,
      magnifierBorderRadius: other.magnifierBorderRadius,
      magnifierBorderColor: other.magnifierBorderColor,
      magnifierShadows: other.magnifierShadows,
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

    final _this = (this as TextSelectionTheme);
    final _other = (other as TextSelectionTheme);

    return _other.handleColor == _this.handleColor &&
        _other.handleSize == _this.handleSize &&
        _other.handleStemWidth == _this.handleStemWidth &&
        _other.toolbarHeight == _this.toolbarHeight &&
        _other.toolbarDecoration == _this.toolbarDecoration &&
        _other.toolbarItemPadding == _this.toolbarItemPadding &&
        _other.toolbarTextStyle == _this.toolbarTextStyle &&
        _other.toolbarDividerColor == _this.toolbarDividerColor &&
        _other.toolbarPressedColor == _this.toolbarPressedColor &&
        _other.toolbarGap == _this.toolbarGap &&
        _other.magnifierSize == _this.magnifierSize &&
        _other.magnifierScale == _this.magnifierScale &&
        _other.magnifierBorderRadius == _this.magnifierBorderRadius &&
        _other.magnifierBorderColor == _this.magnifierBorderColor &&
        _other.magnifierShadows == _this.magnifierShadows;
  }

  @override
  int get hashCode {
    final _this = (this as TextSelectionTheme);

    return Object.hash(
      runtimeType,
      _this.handleColor,
      _this.handleSize,
      _this.handleStemWidth,
      _this.toolbarHeight,
      _this.toolbarDecoration,
      _this.toolbarItemPadding,
      _this.toolbarTextStyle,
      _this.toolbarDividerColor,
      _this.toolbarPressedColor,
      _this.toolbarGap,
      _this.magnifierSize,
      _this.magnifierScale,
      _this.magnifierBorderRadius,
      _this.magnifierBorderColor,
      _this.magnifierShadows,
    );
  }
}
