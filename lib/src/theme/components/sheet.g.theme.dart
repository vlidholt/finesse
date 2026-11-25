// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'sheet.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$SheetTheme {
  bool get canMerge => true;

  static SheetTheme? lerp(SheetTheme? a, SheetTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return SheetTheme(
      side: t < 0.5 ? a.side : b.side,
      constraints: BoxConstraints.lerp(a.constraints, b.constraints, t),
      backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
      filter: t < 0.5 ? a.filter : b.filter,
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
      border: BoxBorder.lerp(a.border, b.border, t),
      shadows: t < 0.5 ? a.shadows : b.shadows,
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      gap: lerpDouble$(a.gap, b.gap, t),
      actionsGap: lerpDouble$(a.actionsGap, b.actionsGap, t),
      titleStyle: TextStyle.lerp(a.titleStyle, b.titleStyle, t),
      descriptionStyle: TextStyle.lerp(
        a.descriptionStyle,
        b.descriptionStyle,
        t,
      ),
      scrollable: t < 0.5 ? a.scrollable : b.scrollable,
      useSafeArea: t < 0.5 ? a.useSafeArea : b.useSafeArea,
      titlePinned: t < 0.5 ? a.titlePinned : b.titlePinned,
      descriptionPinned: t < 0.5 ? a.descriptionPinned : b.descriptionPinned,
      actionsPinned: t < 0.5 ? a.actionsPinned : b.actionsPinned,
      showCloseButton: t < 0.5 ? a.showCloseButton : b.showCloseButton,
      closeIcon: t < 0.5 ? a.closeIcon : b.closeIcon,
      closeIconPosition: Position.lerp(
        a.closeIconPosition,
        b.closeIconPosition,
        t,
      ),
      draggable: t < 0.5 ? a.draggable : b.draggable,
      showDragHandle: t < 0.5 ? a.showDragHandle : b.showDragHandle,
      dragHandleColor: Color.lerp(a.dragHandleColor, b.dragHandleColor, t),
      dragHandleWidth: lerpDouble$(a.dragHandleWidth, b.dragHandleWidth, t),
      dragHandleHeight: lerpDouble$(a.dragHandleHeight, b.dragHandleHeight, t),
      dragHandleRadius: BorderRadius.lerp(
        a.dragHandleRadius,
        b.dragHandleRadius,
        t,
      ),
    );
  }

  SheetTheme copyWith({
    SheetSide? side,
    BoxConstraints? constraints,
    Color? backgroundColor,
    ImageFilter? filter,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? shadows,
    EdgeInsetsGeometry? padding,
    double? gap,
    double? actionsGap,
    TextStyle? titleStyle,
    TextStyle? descriptionStyle,
    bool? scrollable,
    bool? useSafeArea,
    bool? titlePinned,
    bool? descriptionPinned,
    bool? actionsPinned,
    bool? showCloseButton,
    Widget? closeIcon,
    Position? closeIconPosition,
    bool? draggable,
    bool? showDragHandle,
    Color? dragHandleColor,
    double? dragHandleWidth,
    double? dragHandleHeight,
    BorderRadius? dragHandleRadius,
  }) {
    final _this = (this as SheetTheme);

    return SheetTheme(
      side: side ?? _this.side,
      constraints: constraints ?? _this.constraints,
      backgroundColor: backgroundColor ?? _this.backgroundColor,
      filter: filter ?? _this.filter,
      borderRadius: borderRadius ?? _this.borderRadius,
      border: border ?? _this.border,
      shadows: shadows ?? _this.shadows,
      padding: padding ?? _this.padding,
      gap: gap ?? _this.gap,
      actionsGap: actionsGap ?? _this.actionsGap,
      titleStyle: titleStyle ?? _this.titleStyle,
      descriptionStyle: descriptionStyle ?? _this.descriptionStyle,
      scrollable: scrollable ?? _this.scrollable,
      useSafeArea: useSafeArea ?? _this.useSafeArea,
      titlePinned: titlePinned ?? _this.titlePinned,
      descriptionPinned: descriptionPinned ?? _this.descriptionPinned,
      actionsPinned: actionsPinned ?? _this.actionsPinned,
      showCloseButton: showCloseButton ?? _this.showCloseButton,
      closeIcon: closeIcon ?? _this.closeIcon,
      closeIconPosition: closeIconPosition ?? _this.closeIconPosition,
      draggable: draggable ?? _this.draggable,
      showDragHandle: showDragHandle ?? _this.showDragHandle,
      dragHandleColor: dragHandleColor ?? _this.dragHandleColor,
      dragHandleWidth: dragHandleWidth ?? _this.dragHandleWidth,
      dragHandleHeight: dragHandleHeight ?? _this.dragHandleHeight,
      dragHandleRadius: dragHandleRadius ?? _this.dragHandleRadius,
    );
  }

  SheetTheme merge(SheetTheme? other) {
    final _this = (this as SheetTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      side: other.side,
      constraints: other.constraints,
      backgroundColor: other.backgroundColor,
      filter: other.filter,
      borderRadius: other.borderRadius,
      border: other.border,
      shadows: other.shadows,
      padding: other.padding,
      gap: other.gap,
      actionsGap: other.actionsGap,
      titleStyle: _this.titleStyle?.merge(other.titleStyle) ?? other.titleStyle,
      descriptionStyle:
          _this.descriptionStyle?.merge(other.descriptionStyle) ??
          other.descriptionStyle,
      scrollable: other.scrollable,
      useSafeArea: other.useSafeArea,
      titlePinned: other.titlePinned,
      descriptionPinned: other.descriptionPinned,
      actionsPinned: other.actionsPinned,
      showCloseButton: other.showCloseButton,
      closeIcon: other.closeIcon,
      closeIconPosition: other.closeIconPosition,
      draggable: other.draggable,
      showDragHandle: other.showDragHandle,
      dragHandleColor: other.dragHandleColor,
      dragHandleWidth: other.dragHandleWidth,
      dragHandleHeight: other.dragHandleHeight,
      dragHandleRadius: other.dragHandleRadius,
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

    final _this = (this as SheetTheme);
    final _other = (other as SheetTheme);

    return _other.side == _this.side &&
        _other.constraints == _this.constraints &&
        _other.backgroundColor == _this.backgroundColor &&
        _other.filter == _this.filter &&
        _other.borderRadius == _this.borderRadius &&
        _other.border == _this.border &&
        _other.shadows == _this.shadows &&
        _other.padding == _this.padding &&
        _other.gap == _this.gap &&
        _other.actionsGap == _this.actionsGap &&
        _other.titleStyle == _this.titleStyle &&
        _other.descriptionStyle == _this.descriptionStyle &&
        _other.scrollable == _this.scrollable &&
        _other.useSafeArea == _this.useSafeArea &&
        _other.titlePinned == _this.titlePinned &&
        _other.descriptionPinned == _this.descriptionPinned &&
        _other.actionsPinned == _this.actionsPinned &&
        _other.showCloseButton == _this.showCloseButton &&
        _other.closeIcon == _this.closeIcon &&
        _other.closeIconPosition == _this.closeIconPosition &&
        _other.draggable == _this.draggable &&
        _other.showDragHandle == _this.showDragHandle &&
        _other.dragHandleColor == _this.dragHandleColor &&
        _other.dragHandleWidth == _this.dragHandleWidth &&
        _other.dragHandleHeight == _this.dragHandleHeight &&
        _other.dragHandleRadius == _this.dragHandleRadius;
  }

  @override
  int get hashCode {
    final _this = (this as SheetTheme);

    return Object.hashAll([
      runtimeType,
      _this.side,
      _this.constraints,
      _this.backgroundColor,
      _this.filter,
      _this.borderRadius,
      _this.border,
      _this.shadows,
      _this.padding,
      _this.gap,
      _this.actionsGap,
      _this.titleStyle,
      _this.descriptionStyle,
      _this.scrollable,
      _this.useSafeArea,
      _this.titlePinned,
      _this.descriptionPinned,
      _this.actionsPinned,
      _this.showCloseButton,
      _this.closeIcon,
      _this.closeIconPosition,
      _this.draggable,
      _this.showDragHandle,
      _this.dragHandleColor,
      _this.dragHandleWidth,
      _this.dragHandleHeight,
      _this.dragHandleRadius,
    ]);
  }
}
