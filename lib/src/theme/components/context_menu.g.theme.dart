// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'context_menu.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ContextMenuTheme {
  bool get canMerge => true;

  static ContextMenuTheme? lerp(
    ContextMenuTheme? a,
    ContextMenuTheme? b,
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

    return ContextMenuTheme(
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      leadingPadding: EdgeInsetsGeometry.lerp(
        a.leadingPadding,
        b.leadingPadding,
        t,
      ),
      trailingPadding: EdgeInsetsGeometry.lerp(
        a.trailingPadding,
        b.trailingPadding,
        t,
      ),
      itemPadding: EdgeInsetsGeometry.lerp(a.itemPadding, b.itemPadding, t),
      insetPadding: EdgeInsetsGeometry.lerp(a.insetPadding, b.insetPadding, t),
      anchor: t < 0.5 ? a.anchor : b.anchor,
      showDelay: lerpDuration$(a.showDelay, b.showDelay, t),
      height: lerpDouble$(a.height, b.height, t),
      buttonVariant: t < 0.5 ? a.buttonVariant : b.buttonVariant,
      itemDecoration: FinesseDecoration.lerp(
        a.itemDecoration,
        b.itemDecoration,
        t,
      ),
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t),
      selectedTextStyle: TextStyle.lerp(
        a.selectedTextStyle,
        b.selectedTextStyle,
        t,
      ),
      trailingTextStyle: TextStyle.lerp(
        a.trailingTextStyle,
        b.trailingTextStyle,
        t,
      ),
      selectedTrailingTextStyle: TextStyle.lerp(
        a.selectedTrailingTextStyle,
        b.selectedTrailingTextStyle,
        t,
      ),
      destructiveForegroundColor: Color.lerp(
        a.destructiveForegroundColor,
        b.destructiveForegroundColor,
        t,
      ),
      destructiveSelectedBackgroundColor: Color.lerp(
        a.destructiveSelectedBackgroundColor,
        b.destructiveSelectedBackgroundColor,
        t,
      ),
      itemConstraints: BoxConstraints.lerp(
        a.itemConstraints,
        b.itemConstraints,
        t,
      ),
      subMenuPadding: EdgeInsetsGeometry.lerp(
        a.subMenuPadding,
        b.subMenuPadding,
        t,
      ),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      selectedBackgroundColor: Color.lerp(
        a.selectedBackgroundColor,
        b.selectedBackgroundColor,
        t,
      ),
      closeOnTap: t < 0.5 ? a.closeOnTap : b.closeOnTap,
      shadows: t < 0.5 ? a.shadows : b.shadows,
      decoration: FinesseDecoration.lerp(a.decoration, b.decoration, t),
      filter: t < 0.5 ? a.filter : b.filter,
      indicatorSize: lerpDouble$(a.indicatorSize, b.indicatorSize, t),
      labelTextStyle: TextStyle.lerp(a.labelTextStyle, b.labelTextStyle, t),
      labelPadding: EdgeInsetsGeometry.lerp(a.labelPadding, b.labelPadding, t),
      shortcutTextStyle: TextStyle.lerp(
        a.shortcutTextStyle,
        b.shortcutTextStyle,
        t,
      ),
      dividerColor: Color.lerp(a.dividerColor, b.dividerColor, t),
      dividerMargin: EdgeInsetsGeometry.lerp(
        a.dividerMargin,
        b.dividerMargin,
        t,
      ),
    );
  }

  ContextMenuTheme copyWith({
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? leadingPadding,
    EdgeInsetsGeometry? trailingPadding,
    EdgeInsetsGeometry? itemPadding,
    EdgeInsetsGeometry? insetPadding,
    AnchorBase? anchor,
    Duration? showDelay,
    double? height,
    ButtonVariant? buttonVariant,
    FinesseDecoration? itemDecoration,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    TextStyle? trailingTextStyle,
    TextStyle? selectedTrailingTextStyle,
    Color? destructiveForegroundColor,
    Color? destructiveSelectedBackgroundColor,
    BoxConstraints? itemConstraints,
    EdgeInsetsGeometry? subMenuPadding,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    bool? closeOnTap,
    List<BoxShadow>? shadows,
    FinesseDecoration? decoration,
    ImageFilter? filter,
    double? indicatorSize,
    TextStyle? labelTextStyle,
    EdgeInsetsGeometry? labelPadding,
    TextStyle? shortcutTextStyle,
    Color? dividerColor,
    EdgeInsetsGeometry? dividerMargin,
  }) {
    final _this = (this as ContextMenuTheme);

    return ContextMenuTheme(
      constraints: constraints ?? _this.constraints,
      padding: padding ?? _this.padding,
      leadingPadding: leadingPadding ?? _this.leadingPadding,
      trailingPadding: trailingPadding ?? _this.trailingPadding,
      itemPadding: itemPadding ?? _this.itemPadding,
      insetPadding: insetPadding ?? _this.insetPadding,
      anchor: anchor ?? _this.anchor,
      showDelay: showDelay ?? _this.showDelay,
      height: height ?? _this.height,
      buttonVariant: buttonVariant ?? _this.buttonVariant,
      itemDecoration: itemDecoration ?? _this.itemDecoration,
      textStyle: textStyle ?? _this.textStyle,
      selectedTextStyle: selectedTextStyle ?? _this.selectedTextStyle,
      trailingTextStyle: trailingTextStyle ?? _this.trailingTextStyle,
      selectedTrailingTextStyle:
          selectedTrailingTextStyle ?? _this.selectedTrailingTextStyle,
      destructiveForegroundColor:
          destructiveForegroundColor ?? _this.destructiveForegroundColor,
      destructiveSelectedBackgroundColor:
          destructiveSelectedBackgroundColor ??
          _this.destructiveSelectedBackgroundColor,
      itemConstraints: itemConstraints ?? _this.itemConstraints,
      subMenuPadding: subMenuPadding ?? _this.subMenuPadding,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? _this.selectedBackgroundColor,
      closeOnTap: closeOnTap ?? _this.closeOnTap,
      shadows: shadows ?? _this.shadows,
      decoration: decoration ?? _this.decoration,
      filter: filter ?? _this.filter,
      indicatorSize: indicatorSize ?? _this.indicatorSize,
      labelTextStyle: labelTextStyle ?? _this.labelTextStyle,
      labelPadding: labelPadding ?? _this.labelPadding,
      shortcutTextStyle: shortcutTextStyle ?? _this.shortcutTextStyle,
      dividerColor: dividerColor ?? _this.dividerColor,
      dividerMargin: dividerMargin ?? _this.dividerMargin,
    );
  }

  ContextMenuTheme merge(ContextMenuTheme? other) {
    final _this = (this as ContextMenuTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      constraints: other.constraints,
      padding: other.padding,
      leadingPadding: other.leadingPadding,
      trailingPadding: other.trailingPadding,
      itemPadding: other.itemPadding,
      insetPadding: other.insetPadding,
      anchor: other.anchor,
      showDelay: other.showDelay,
      height: other.height,
      buttonVariant: other.buttonVariant,
      itemDecoration:
          _this.itemDecoration?.merge(other.itemDecoration) ??
          other.itemDecoration,
      textStyle: _this.textStyle?.merge(other.textStyle) ?? other.textStyle,
      selectedTextStyle:
          _this.selectedTextStyle?.merge(other.selectedTextStyle) ??
          other.selectedTextStyle,
      trailingTextStyle:
          _this.trailingTextStyle?.merge(other.trailingTextStyle) ??
          other.trailingTextStyle,
      selectedTrailingTextStyle:
          _this.selectedTrailingTextStyle?.merge(
            other.selectedTrailingTextStyle,
          ) ??
          other.selectedTrailingTextStyle,
      destructiveForegroundColor: other.destructiveForegroundColor,
      destructiveSelectedBackgroundColor:
          other.destructiveSelectedBackgroundColor,
      itemConstraints: other.itemConstraints,
      subMenuPadding: other.subMenuPadding,
      backgroundColor: other.backgroundColor,
      selectedBackgroundColor: other.selectedBackgroundColor,
      closeOnTap: other.closeOnTap,
      shadows: other.shadows,
      decoration: _this.decoration?.merge(other.decoration) ?? other.decoration,
      filter: other.filter,
      indicatorSize: other.indicatorSize,
      labelTextStyle:
          _this.labelTextStyle?.merge(other.labelTextStyle) ??
          other.labelTextStyle,
      labelPadding: other.labelPadding,
      shortcutTextStyle:
          _this.shortcutTextStyle?.merge(other.shortcutTextStyle) ??
          other.shortcutTextStyle,
      dividerColor: other.dividerColor,
      dividerMargin: other.dividerMargin,
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

    final _this = (this as ContextMenuTheme);
    final _other = (other as ContextMenuTheme);

    return _other.constraints == _this.constraints &&
        _other.padding == _this.padding &&
        _other.leadingPadding == _this.leadingPadding &&
        _other.trailingPadding == _this.trailingPadding &&
        _other.itemPadding == _this.itemPadding &&
        _other.insetPadding == _this.insetPadding &&
        _other.anchor == _this.anchor &&
        _other.showDelay == _this.showDelay &&
        _other.height == _this.height &&
        _other.buttonVariant == _this.buttonVariant &&
        _other.itemDecoration == _this.itemDecoration &&
        _other.textStyle == _this.textStyle &&
        _other.selectedTextStyle == _this.selectedTextStyle &&
        _other.trailingTextStyle == _this.trailingTextStyle &&
        _other.selectedTrailingTextStyle == _this.selectedTrailingTextStyle &&
        _other.destructiveForegroundColor == _this.destructiveForegroundColor &&
        _other.destructiveSelectedBackgroundColor ==
            _this.destructiveSelectedBackgroundColor &&
        _other.itemConstraints == _this.itemConstraints &&
        _other.subMenuPadding == _this.subMenuPadding &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.selectedBackgroundColor == _this.selectedBackgroundColor &&
        _other.closeOnTap == _this.closeOnTap &&
        _other.shadows == _this.shadows &&
        _other.decoration == _this.decoration &&
        _other.filter == _this.filter &&
        _other.indicatorSize == _this.indicatorSize &&
        _other.labelTextStyle == _this.labelTextStyle &&
        _other.labelPadding == _this.labelPadding &&
        _other.shortcutTextStyle == _this.shortcutTextStyle &&
        _other.dividerColor == _this.dividerColor &&
        _other.dividerMargin == _this.dividerMargin;
  }

  @override
  int get hashCode {
    final _this = (this as ContextMenuTheme);

    return Object.hashAll([
      runtimeType,
      _this.constraints,
      _this.padding,
      _this.leadingPadding,
      _this.trailingPadding,
      _this.itemPadding,
      _this.insetPadding,
      _this.anchor,
      _this.showDelay,
      _this.height,
      _this.buttonVariant,
      _this.itemDecoration,
      _this.textStyle,
      _this.selectedTextStyle,
      _this.trailingTextStyle,
      _this.selectedTrailingTextStyle,
      _this.destructiveForegroundColor,
      _this.destructiveSelectedBackgroundColor,
      _this.itemConstraints,
      _this.subMenuPadding,
      _this.backgroundColor,
      _this.selectedBackgroundColor,
      _this.closeOnTap,
      _this.shadows,
      _this.decoration,
      _this.filter,
      _this.indicatorSize,
      _this.labelTextStyle,
      _this.labelPadding,
      _this.shortcutTextStyle,
      _this.dividerColor,
      _this.dividerMargin,
    ]);
  }
}
