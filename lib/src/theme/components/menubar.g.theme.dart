// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'menubar.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$MenubarTheme {
  bool get canMerge => true;

  static MenubarTheme? lerp(MenubarTheme? a, MenubarTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return MenubarTheme(
      borderRadius: BorderRadiusGeometry.lerp(
        a.borderRadius,
        b.borderRadius,
        t,
      ),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      border: UnaBorder.lerp(a.border, b.border, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      contextMenuPadding: EdgeInsetsGeometry.lerp(
        a.contextMenuPadding,
        b.contextMenuPadding,
        t,
      ),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      decoration: UnaDecoration.lerp(a.decoration, b.decoration, t),
      filter: t < 0.5 ? a.filter : b.filter,
      anchor: t < 0.5 ? a.anchor : b.anchor,
      buttonVariant: t < 0.5 ? a.buttonVariant : b.buttonVariant,
      buttonSize: t < 0.5 ? a.buttonSize : b.buttonSize,
      buttonMouseCursor: t < 0.5 ? a.buttonMouseCursor : b.buttonMouseCursor,
      buttonWidth: lerpDouble$(a.buttonWidth, b.buttonWidth, t),
      buttonHeight: lerpDouble$(a.buttonHeight, b.buttonHeight, t),
      buttonPadding: EdgeInsetsGeometry.lerp(
        a.buttonPadding,
        b.buttonPadding,
        t,
      ),
      buttonBackgroundColor: Color.lerp(
        a.buttonBackgroundColor,
        b.buttonBackgroundColor,
        t,
      ),
      buttonSelectedBackgroundColor: Color.lerp(
        a.buttonSelectedBackgroundColor,
        b.buttonSelectedBackgroundColor,
        t,
      ),
      buttonHoverBackgroundColor: Color.lerp(
        a.buttonHoverBackgroundColor,
        b.buttonHoverBackgroundColor,
        t,
      ),
      buttonForegroundColor: Color.lerp(
        a.buttonForegroundColor,
        b.buttonForegroundColor,
        t,
      ),
      buttonHoverForegroundColor: Color.lerp(
        a.buttonHoverForegroundColor,
        b.buttonHoverForegroundColor,
        t,
      ),
      buttonPressedBackgroundColor: Color.lerp(
        a.buttonPressedBackgroundColor,
        b.buttonPressedBackgroundColor,
        t,
      ),
      buttonPressedForegroundColor: Color.lerp(
        a.buttonPressedForegroundColor,
        b.buttonPressedForegroundColor,
        t,
      ),
      buttonShadows: t < 0.5 ? a.buttonShadows : b.buttonShadows,
      stripShadows: t < 0.5 ? a.stripShadows : b.stripShadows,
      buttonGradient: Gradient.lerp(a.buttonGradient, b.buttonGradient, t),
      buttonTextDecoration: t < 0.5
          ? a.buttonTextDecoration
          : b.buttonTextDecoration,
      buttonHoverTextDecoration: t < 0.5
          ? a.buttonHoverTextDecoration
          : b.buttonHoverTextDecoration,
      buttonDecoration: UnaDecoration.lerp(
        a.buttonDecoration,
        b.buttonDecoration,
        t,
      ),
      buttonGap: lerpDouble$(a.buttonGap, b.buttonGap, t),
      buttonMainAxisAlignment: t < 0.5
          ? a.buttonMainAxisAlignment
          : b.buttonMainAxisAlignment,
      buttonCrossAxisAlignment: t < 0.5
          ? a.buttonCrossAxisAlignment
          : b.buttonCrossAxisAlignment,
      buttonExpands: t < 0.5 ? a.buttonExpands : b.buttonExpands,
      selectOnHover: t < 0.5 ? a.selectOnHover : b.selectOnHover,
    );
  }

  MenubarTheme copyWith({
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    UnaBorder? border,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? contextMenuPadding,
    List<BoxShadow>? shadows,
    UnaDecoration? decoration,
    ImageFilter? filter,
    AnchorBase? anchor,
    ButtonVariant? buttonVariant,
    ButtonSize? buttonSize,
    MouseCursor? buttonMouseCursor,
    double? buttonWidth,
    double? buttonHeight,
    EdgeInsetsGeometry? buttonPadding,
    Color? buttonBackgroundColor,
    Color? buttonSelectedBackgroundColor,
    Color? buttonHoverBackgroundColor,
    Color? buttonForegroundColor,
    Color? buttonHoverForegroundColor,
    Color? buttonPressedBackgroundColor,
    Color? buttonPressedForegroundColor,
    List<BoxShadow>? buttonShadows,
    List<BoxShadow>? stripShadows,
    Gradient? buttonGradient,
    TextDecoration? buttonTextDecoration,
    TextDecoration? buttonHoverTextDecoration,
    UnaDecoration? buttonDecoration,
    double? buttonGap,
    MainAxisAlignment? buttonMainAxisAlignment,
    CrossAxisAlignment? buttonCrossAxisAlignment,
    bool? buttonExpands,
    bool? selectOnHover,
  }) {
    final _this = (this as MenubarTheme);

    return MenubarTheme(
      borderRadius: borderRadius ?? _this.borderRadius,
      padding: padding ?? _this.padding,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      border: border ?? _this.border,
      constraints: constraints ?? _this.constraints,
      contextMenuPadding: contextMenuPadding ?? _this.contextMenuPadding,
      shadows: shadows ?? _this.shadows,
      decoration: decoration ?? _this.decoration,
      filter: filter ?? _this.filter,
      anchor: anchor ?? _this.anchor,
      buttonVariant: buttonVariant ?? _this.buttonVariant,
      buttonSize: buttonSize ?? _this.buttonSize,
      buttonMouseCursor: buttonMouseCursor ?? _this.buttonMouseCursor,
      buttonWidth: buttonWidth ?? _this.buttonWidth,
      buttonHeight: buttonHeight ?? _this.buttonHeight,
      buttonPadding: buttonPadding ?? _this.buttonPadding,
      buttonBackgroundColor:
          buttonBackgroundColor ?? _this.buttonBackgroundColor,
      buttonSelectedBackgroundColor:
          buttonSelectedBackgroundColor ?? _this.buttonSelectedBackgroundColor,
      buttonHoverBackgroundColor:
          buttonHoverBackgroundColor ?? _this.buttonHoverBackgroundColor,
      buttonForegroundColor:
          buttonForegroundColor ?? _this.buttonForegroundColor,
      buttonHoverForegroundColor:
          buttonHoverForegroundColor ?? _this.buttonHoverForegroundColor,
      buttonPressedBackgroundColor:
          buttonPressedBackgroundColor ?? _this.buttonPressedBackgroundColor,
      buttonPressedForegroundColor:
          buttonPressedForegroundColor ?? _this.buttonPressedForegroundColor,
      buttonShadows: buttonShadows ?? _this.buttonShadows,
      stripShadows: stripShadows ?? _this.stripShadows,
      buttonGradient: buttonGradient ?? _this.buttonGradient,
      buttonTextDecoration: buttonTextDecoration ?? _this.buttonTextDecoration,
      buttonHoverTextDecoration:
          buttonHoverTextDecoration ?? _this.buttonHoverTextDecoration,
      buttonDecoration: buttonDecoration ?? _this.buttonDecoration,
      buttonGap: buttonGap ?? _this.buttonGap,
      buttonMainAxisAlignment:
          buttonMainAxisAlignment ?? _this.buttonMainAxisAlignment,
      buttonCrossAxisAlignment:
          buttonCrossAxisAlignment ?? _this.buttonCrossAxisAlignment,
      buttonExpands: buttonExpands ?? _this.buttonExpands,
      selectOnHover: selectOnHover ?? _this.selectOnHover,
    );
  }

  MenubarTheme merge(MenubarTheme? other) {
    final _this = (this as MenubarTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      borderRadius: other.borderRadius,
      padding: other.padding,
      backgroundColor: other.backgroundColor,
      border: _this.border?.merge(other.border) ?? other.border,
      constraints: other.constraints,
      contextMenuPadding: other.contextMenuPadding,
      shadows: other.shadows,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      filter: other.filter,
      anchor: other.anchor,
      buttonVariant: other.buttonVariant,
      buttonSize: other.buttonSize,
      buttonMouseCursor: other.buttonMouseCursor,
      buttonWidth: other.buttonWidth,
      buttonHeight: other.buttonHeight,
      buttonPadding: other.buttonPadding,
      buttonBackgroundColor: other.buttonBackgroundColor,
      buttonSelectedBackgroundColor: other.buttonSelectedBackgroundColor,
      buttonHoverBackgroundColor: other.buttonHoverBackgroundColor,
      buttonForegroundColor: other.buttonForegroundColor,
      buttonHoverForegroundColor: other.buttonHoverForegroundColor,
      buttonPressedBackgroundColor: other.buttonPressedBackgroundColor,
      buttonPressedForegroundColor: other.buttonPressedForegroundColor,
      buttonShadows: other.buttonShadows,
      stripShadows: other.stripShadows,
      buttonGradient: other.buttonGradient,
      buttonTextDecoration: other.buttonTextDecoration,
      buttonHoverTextDecoration: other.buttonHoverTextDecoration,
      buttonDecoration:
          _this.buttonDecoration?.merge(other.buttonDecoration) ??
          other.buttonDecoration,
      buttonGap: other.buttonGap,
      buttonMainAxisAlignment: other.buttonMainAxisAlignment,
      buttonCrossAxisAlignment: other.buttonCrossAxisAlignment,
      buttonExpands: other.buttonExpands,
      selectOnHover: other.selectOnHover,
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

    final _this = (this as MenubarTheme);
    final _other = (other as MenubarTheme);

    return _other.borderRadius == _this.borderRadius &&
        _other.padding == _this.padding &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.border == _this.border &&
        _other.constraints == _this.constraints &&
        _other.contextMenuPadding == _this.contextMenuPadding &&
        _other.shadows == _this.shadows &&
        _other.decoration == _this.decoration &&
        _other.filter == _this.filter &&
        _other.anchor == _this.anchor &&
        _other.buttonVariant == _this.buttonVariant &&
        _other.buttonSize == _this.buttonSize &&
        _other.buttonMouseCursor == _this.buttonMouseCursor &&
        _other.buttonWidth == _this.buttonWidth &&
        _other.buttonHeight == _this.buttonHeight &&
        _other.buttonPadding == _this.buttonPadding &&
        _other.buttonBackgroundColor == _this.buttonBackgroundColor &&
        _other.buttonSelectedBackgroundColor ==
            _this.buttonSelectedBackgroundColor &&
        _other.buttonHoverBackgroundColor == _this.buttonHoverBackgroundColor &&
        _other.buttonForegroundColor == _this.buttonForegroundColor &&
        _other.buttonHoverForegroundColor == _this.buttonHoverForegroundColor &&
        _other.buttonPressedBackgroundColor ==
            _this.buttonPressedBackgroundColor &&
        _other.buttonPressedForegroundColor ==
            _this.buttonPressedForegroundColor &&
        _other.buttonShadows == _this.buttonShadows &&
        _other.stripShadows == _this.stripShadows &&
        _other.buttonGradient == _this.buttonGradient &&
        _other.buttonTextDecoration == _this.buttonTextDecoration &&
        _other.buttonHoverTextDecoration == _this.buttonHoverTextDecoration &&
        _other.buttonDecoration == _this.buttonDecoration &&
        _other.buttonGap == _this.buttonGap &&
        _other.buttonMainAxisAlignment == _this.buttonMainAxisAlignment &&
        _other.buttonCrossAxisAlignment == _this.buttonCrossAxisAlignment &&
        _other.buttonExpands == _this.buttonExpands &&
        _other.selectOnHover == _this.selectOnHover;
  }

  @override
  int get hashCode {
    final _this = (this as MenubarTheme);

    return Object.hashAll([
      runtimeType,
      _this.borderRadius,
      _this.padding,
      _this.backgroundColor,
      _this.border,
      _this.constraints,
      _this.contextMenuPadding,
      _this.shadows,
      _this.decoration,
      _this.filter,
      _this.anchor,
      _this.buttonVariant,
      _this.buttonSize,
      _this.buttonMouseCursor,
      _this.buttonWidth,
      _this.buttonHeight,
      _this.buttonPadding,
      _this.buttonBackgroundColor,
      _this.buttonSelectedBackgroundColor,
      _this.buttonHoverBackgroundColor,
      _this.buttonForegroundColor,
      _this.buttonHoverForegroundColor,
      _this.buttonPressedBackgroundColor,
      _this.buttonPressedForegroundColor,
      _this.buttonShadows,
      _this.stripShadows,
      _this.buttonGradient,
      _this.buttonTextDecoration,
      _this.buttonHoverTextDecoration,
      _this.buttonDecoration,
      _this.buttonGap,
      _this.buttonMainAxisAlignment,
      _this.buttonCrossAxisAlignment,
      _this.buttonExpands,
      _this.selectOnHover,
    ]);
  }
}
