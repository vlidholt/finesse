// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'dialog.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$DialogTheme {
  bool get canMerge => true;

  static DialogTheme? lerp(DialogTheme? a, DialogTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return DialogTheme(
      showCloseButton: t < 0.5 ? a.showCloseButton : b.showCloseButton,
      closeIcon: t < 0.5 ? a.closeIcon : b.closeIcon,
      closeIconPosition: Position.lerp(
        a.closeIconPosition,
        b.closeIconPosition,
        t,
      ),
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      actionsAxis: t < 0.5 ? a.actionsAxis : b.actionsAxis,
      actionsMainAxisSize: t < 0.5
          ? a.actionsMainAxisSize
          : b.actionsMainAxisSize,
      actionsMainAxisAlignment: t < 0.5
          ? a.actionsMainAxisAlignment
          : b.actionsMainAxisAlignment,
      actionsVerticalDirection: t < 0.5
          ? a.actionsVerticalDirection
          : b.actionsVerticalDirection,
      border: BoxBorder.lerp(a.border, b.border, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      filter: t < 0.5 ? a.filter : b.filter,
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      descriptionStyle: TextStyle.lerp(
        a.descriptionStyle,
        b.descriptionStyle,
        t,
      ),
      titleTextAlign: t < 0.5 ? a.titleTextAlign : b.titleTextAlign,
      descriptionTextAlign: t < 0.5
          ? a.descriptionTextAlign
          : b.descriptionTextAlign,
      alignment: Alignment.lerp(a.alignment, b.alignment, t),
      mainAxisAlignment: t < 0.5 ? a.mainAxisAlignment : b.mainAxisAlignment,
      crossAxisAlignment: t < 0.5 ? a.crossAxisAlignment : b.crossAxisAlignment,
      scrollable: t < 0.5 ? a.scrollable : b.scrollable,
      scrollPadding: EdgeInsetsGeometry.lerp(
        a.scrollPadding,
        b.scrollPadding,
        t,
      ),
      actionsGap: lerpDouble$(a.actionsGap, b.actionsGap, t),
      useSafeArea: t < 0.5 ? a.useSafeArea : b.useSafeArea,
      titlePinned: t < 0.5 ? a.titlePinned : b.titlePinned,
      descriptionPinned: t < 0.5 ? a.descriptionPinned : b.descriptionPinned,
      actionsPinned: t < 0.5 ? a.actionsPinned : b.actionsPinned,
      barrierColor: Color.lerp(a.barrierColor, b.barrierColor, t),
      barrierBlurSigma: lerpDouble$(a.barrierBlurSigma, b.barrierBlurSigma, t),
    );
  }

  DialogTheme copyWith({
    bool? showCloseButton,
    Widget? closeIcon,
    Position? closeIconPosition,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    double? gap,
    BoxConstraints? constraints,
    Axis? actionsAxis,
    MainAxisSize? actionsMainAxisSize,
    MainAxisAlignment? actionsMainAxisAlignment,
    VerticalDirection? actionsVerticalDirection,
    BoxBorder? border,
    List<BoxShadow>? shadows,
    ImageFilter? filter,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    TextAlign? titleTextAlign,
    TextAlign? descriptionTextAlign,
    Alignment? alignment,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    bool? scrollable,
    EdgeInsetsGeometry? scrollPadding,
    double? actionsGap,
    bool? useSafeArea,
    bool? titlePinned,
    bool? descriptionPinned,
    bool? actionsPinned,
    Color? barrierColor,
    double? barrierBlurSigma,
  }) {
    final _this = (this as DialogTheme);

    return DialogTheme(
      showCloseButton: showCloseButton ?? _this.showCloseButton,
      closeIcon: closeIcon ?? _this.closeIcon,
      closeIconPosition: closeIconPosition ?? _this.closeIconPosition,
      borderRadius: borderRadius ?? _this.borderRadius,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      padding: padding ?? _this.padding,
      gap: gap ?? _this.gap,
      constraints: constraints ?? _this.constraints,
      actionsAxis: actionsAxis ?? _this.actionsAxis,
      actionsMainAxisSize: actionsMainAxisSize ?? _this.actionsMainAxisSize,
      actionsMainAxisAlignment:
          actionsMainAxisAlignment ?? _this.actionsMainAxisAlignment,
      actionsVerticalDirection:
          actionsVerticalDirection ?? _this.actionsVerticalDirection,
      border: border ?? _this.border,
      shadows: shadows ?? _this.shadows,
      filter: filter ?? _this.filter,
      titleStyle: titleStyle ?? _this.titleStyle,
      descriptionStyle: descriptionStyle ?? _this.descriptionStyle,
      titleTextAlign: titleTextAlign ?? _this.titleTextAlign,
      descriptionTextAlign: descriptionTextAlign ?? _this.descriptionTextAlign,
      alignment: alignment ?? _this.alignment,
      mainAxisAlignment: mainAxisAlignment ?? _this.mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment ?? _this.crossAxisAlignment,
      scrollable: scrollable ?? _this.scrollable,
      scrollPadding: scrollPadding ?? _this.scrollPadding,
      actionsGap: actionsGap ?? _this.actionsGap,
      useSafeArea: useSafeArea ?? _this.useSafeArea,
      titlePinned: titlePinned ?? _this.titlePinned,
      descriptionPinned: descriptionPinned ?? _this.descriptionPinned,
      actionsPinned: actionsPinned ?? _this.actionsPinned,
      barrierColor: barrierColor ?? _this.barrierColor,
      barrierBlurSigma: barrierBlurSigma ?? _this.barrierBlurSigma,
    );
  }

  DialogTheme merge(DialogTheme? other) {
    final _this = (this as DialogTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      showCloseButton: other.showCloseButton,
      closeIcon: other.closeIcon,
      closeIconPosition: other.closeIconPosition,
      borderRadius: other.borderRadius,
      backgroundColor: other.backgroundColor,
      padding: other.padding,
      gap: other.gap,
      constraints: other.constraints,
      actionsAxis: other.actionsAxis,
      actionsMainAxisSize: other.actionsMainAxisSize,
      actionsMainAxisAlignment: other.actionsMainAxisAlignment,
      actionsVerticalDirection: other.actionsVerticalDirection,
      border: other.border,
      shadows: other.shadows,
      filter: other.filter,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      descriptionStyle:
          _this.descriptionStyle?.merge(other.descriptionStyle) ??
          other.descriptionStyle,
      titleTextAlign: other.titleTextAlign,
      descriptionTextAlign: other.descriptionTextAlign,
      alignment: other.alignment,
      mainAxisAlignment: other.mainAxisAlignment,
      crossAxisAlignment: other.crossAxisAlignment,
      scrollable: other.scrollable,
      scrollPadding: other.scrollPadding,
      actionsGap: other.actionsGap,
      useSafeArea: other.useSafeArea,
      titlePinned: other.titlePinned,
      descriptionPinned: other.descriptionPinned,
      actionsPinned: other.actionsPinned,
      barrierColor: other.barrierColor,
      barrierBlurSigma: other.barrierBlurSigma,
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

    final _this = (this as DialogTheme);
    final _other = (other as DialogTheme);

    return _other.showCloseButton == _this.showCloseButton &&
        _other.closeIcon == _this.closeIcon &&
        _other.closeIconPosition == _this.closeIconPosition &&
        _other.borderRadius == _this.borderRadius &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.padding == _this.padding &&
        _other.gap == _this.gap &&
        _other.constraints == _this.constraints &&
        _other.actionsAxis == _this.actionsAxis &&
        _other.actionsMainAxisSize == _this.actionsMainAxisSize &&
        _other.actionsMainAxisAlignment == _this.actionsMainAxisAlignment &&
        _other.actionsVerticalDirection == _this.actionsVerticalDirection &&
        _other.border == _this.border &&
        _other.shadows == _this.shadows &&
        _other.filter == _this.filter &&
        _other.titleStyle == _this.titleStyle &&
        _other.descriptionStyle == _this.descriptionStyle &&
        _other.titleTextAlign == _this.titleTextAlign &&
        _other.descriptionTextAlign == _this.descriptionTextAlign &&
        _other.alignment == _this.alignment &&
        _other.mainAxisAlignment == _this.mainAxisAlignment &&
        _other.crossAxisAlignment == _this.crossAxisAlignment &&
        _other.scrollable == _this.scrollable &&
        _other.scrollPadding == _this.scrollPadding &&
        _other.actionsGap == _this.actionsGap &&
        _other.useSafeArea == _this.useSafeArea &&
        _other.titlePinned == _this.titlePinned &&
        _other.descriptionPinned == _this.descriptionPinned &&
        _other.actionsPinned == _this.actionsPinned &&
        _other.barrierColor == _this.barrierColor &&
        _other.barrierBlurSigma == _this.barrierBlurSigma;
  }

  @override
  int get hashCode {
    final _this = (this as DialogTheme);

    return Object.hashAll([
      runtimeType,
      _this.showCloseButton,
      _this.closeIcon,
      _this.closeIconPosition,
      _this.borderRadius,
      _this.backgroundColor,
      _this.padding,
      _this.gap,
      _this.constraints,
      _this.actionsAxis,
      _this.actionsMainAxisSize,
      _this.actionsMainAxisAlignment,
      _this.actionsVerticalDirection,
      _this.border,
      _this.shadows,
      _this.filter,
      _this.titleStyle,
      _this.descriptionStyle,
      _this.titleTextAlign,
      _this.descriptionTextAlign,
      _this.alignment,
      _this.mainAxisAlignment,
      _this.crossAxisAlignment,
      _this.scrollable,
      _this.scrollPadding,
      _this.actionsGap,
      _this.useSafeArea,
      _this.titlePinned,
      _this.descriptionPinned,
      _this.actionsPinned,
      _this.barrierColor,
      _this.barrierBlurSigma,
    ]);
  }
}
