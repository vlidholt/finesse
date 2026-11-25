// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'board.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$BoardTheme {
  bool get canMerge => true;

  static BoardTheme? lerp(BoardTheme? a, BoardTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return BoardTheme(
      columnWidth: lerpDouble$(a.columnWidth, b.columnWidth, t),
      columnMinWidth: lerpDouble$(a.columnMinWidth, b.columnMinWidth, t),
      columnMaxWidth: lerpDouble$(a.columnMaxWidth, b.columnMaxWidth, t),
      columnViewportFraction: lerpDouble$(
        a.columnViewportFraction,
        b.columnViewportFraction,
        t,
      ),
      columnGap: lerpDouble$(a.columnGap, b.columnGap, t),
      itemGap: lerpDouble$(a.itemGap, b.itemGap, t),
      padding: EdgeInsetsGeometry.lerp(a.padding, b.padding, t),
      columnPadding: EdgeInsetsGeometry.lerp(
        a.columnPadding,
        b.columnPadding,
        t,
      ),
      headerPadding: EdgeInsetsGeometry.lerp(
        a.headerPadding,
        b.headerPadding,
        t,
      ),
      footerPadding: EdgeInsetsGeometry.lerp(
        a.footerPadding,
        b.footerPadding,
        t,
      ),
      columnBorderRadius: BorderRadius.lerp(
        a.columnBorderRadius,
        b.columnBorderRadius,
        t,
      ),
      columnColor: Color.lerp(a.columnColor, b.columnColor, t),
      columnBorderColor: Color.lerp(
        a.columnBorderColor,
        b.columnBorderColor,
        t,
      ),
      targetColumnColor: Color.lerp(
        a.targetColumnColor,
        b.targetColumnColor,
        t,
      ),
      targetColumnBorderColor: Color.lerp(
        a.targetColumnBorderColor,
        b.targetColumnBorderColor,
        t,
      ),
      refusedColumnColor: Color.lerp(
        a.refusedColumnColor,
        b.refusedColumnColor,
        t,
      ),
      refusedColumnBorderColor: Color.lerp(
        a.refusedColumnBorderColor,
        b.refusedColumnBorderColor,
        t,
      ),
      headerTextStyle: TextStyle.lerp(a.headerTextStyle, b.headerTextStyle, t),
      countTextStyle: TextStyle.lerp(a.countTextStyle, b.countTextStyle, t),
      countColor: Color.lerp(a.countColor, b.countColor, t),
      countForegroundColor: Color.lerp(
        a.countForegroundColor,
        b.countForegroundColor,
        t,
      ),
      fullCountColor: Color.lerp(a.fullCountColor, b.fullCountColor, t),
      fullCountForegroundColor: Color.lerp(
        a.fullCountForegroundColor,
        b.fullCountForegroundColor,
        t,
      ),
      itemColor: Color.lerp(a.itemColor, b.itemColor, t),
      itemPadding: EdgeInsetsGeometry.lerp(a.itemPadding, b.itemPadding, t),
      itemBorderRadius: BorderRadius.lerp(
        a.itemBorderRadius,
        b.itemBorderRadius,
        t,
      ),
      itemShadows: t < 0.5 ? a.itemShadows : b.itemShadows,
      placeholderColor: Color.lerp(a.placeholderColor, b.placeholderColor, t),
      placeholderBorderColor: Color.lerp(
        a.placeholderBorderColor,
        b.placeholderBorderColor,
        t,
      ),
      emptyHeight: lerpDouble$(a.emptyHeight, b.emptyHeight, t),
      dragScale: lerpDouble$(a.dragScale, b.dragScale, t),
      dragTilt: lerpDouble$(a.dragTilt, b.dragTilt, t),
      landScale: lerpDouble$(a.landScale, b.landScale, t),
      dragShadows: t < 0.5 ? a.dragShadows : b.dragShadows,
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
      highlightDuration: lerpDuration$(
        a.highlightDuration,
        b.highlightDuration,
        t,
      ),
      liftSpring: t < 0.5 ? a.liftSpring : b.liftSpring,
      shiftSpring: t < 0.5 ? a.shiftSpring : b.shiftSpring,
      dropSpring: t < 0.5 ? a.dropSpring : b.dropSpring,
      landSpring: t < 0.5 ? a.landSpring : b.landSpring,
      autoScrollExtent: lerpDouble$(a.autoScrollExtent, b.autoScrollExtent, t),
      autoScrollSpeed: lerpDouble$(a.autoScrollSpeed, b.autoScrollSpeed, t),
      snap: t < 0.5 ? a.snap : b.snap,
    );
  }

  BoardTheme copyWith({
    double? columnWidth,
    double? columnMinWidth,
    double? columnMaxWidth,
    double? columnViewportFraction,
    double? columnGap,
    double? itemGap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? columnPadding,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? footerPadding,
    BorderRadius? columnBorderRadius,
    Color? columnColor,
    Color? columnBorderColor,
    Color? targetColumnColor,
    Color? targetColumnBorderColor,
    Color? refusedColumnColor,
    Color? refusedColumnBorderColor,
    TextStyle? headerTextStyle,
    TextStyle? countTextStyle,
    Color? countColor,
    Color? countForegroundColor,
    Color? fullCountColor,
    Color? fullCountForegroundColor,
    Color? itemColor,
    EdgeInsetsGeometry? itemPadding,
    BorderRadius? itemBorderRadius,
    List<BoxShadow>? itemShadows,
    Color? placeholderColor,
    Color? placeholderBorderColor,
    double? emptyHeight,
    double? dragScale,
    double? dragTilt,
    double? landScale,
    List<BoxShadow>? dragShadows,
    Color? highlightColor,
    Duration? highlightDuration,
    MotionSpring? liftSpring,
    MotionSpring? shiftSpring,
    MotionSpring? dropSpring,
    MotionSpring? landSpring,
    double? autoScrollExtent,
    double? autoScrollSpeed,
    bool? snap,
  }) {
    final _this = (this as BoardTheme);

    return BoardTheme(
      columnWidth: columnWidth ?? _this.columnWidth,
      columnMinWidth: columnMinWidth ?? _this.columnMinWidth,
      columnMaxWidth: columnMaxWidth ?? _this.columnMaxWidth,
      columnViewportFraction:
          columnViewportFraction ?? _this.columnViewportFraction,
      columnGap: columnGap ?? _this.columnGap,
      itemGap: itemGap ?? _this.itemGap,
      padding: padding ?? _this.padding,
      columnPadding: columnPadding ?? _this.columnPadding,
      headerPadding: headerPadding ?? _this.headerPadding,
      footerPadding: footerPadding ?? _this.footerPadding,
      columnBorderRadius: columnBorderRadius ?? _this.columnBorderRadius,
      columnColor: columnColor ?? _this.columnColor,
      columnBorderColor: columnBorderColor ?? _this.columnBorderColor,
      targetColumnColor: targetColumnColor ?? _this.targetColumnColor,
      targetColumnBorderColor:
          targetColumnBorderColor ?? _this.targetColumnBorderColor,
      refusedColumnColor: refusedColumnColor ?? _this.refusedColumnColor,
      refusedColumnBorderColor:
          refusedColumnBorderColor ?? _this.refusedColumnBorderColor,
      headerTextStyle: headerTextStyle ?? _this.headerTextStyle,
      countTextStyle: countTextStyle ?? _this.countTextStyle,
      countColor: countColor ?? _this.countColor,
      countForegroundColor: countForegroundColor ?? _this.countForegroundColor,
      fullCountColor: fullCountColor ?? _this.fullCountColor,
      fullCountForegroundColor:
          fullCountForegroundColor ?? _this.fullCountForegroundColor,
      itemColor: itemColor ?? _this.itemColor,
      itemPadding: itemPadding ?? _this.itemPadding,
      itemBorderRadius: itemBorderRadius ?? _this.itemBorderRadius,
      itemShadows: itemShadows ?? _this.itemShadows,
      placeholderColor: placeholderColor ?? _this.placeholderColor,
      placeholderBorderColor:
          placeholderBorderColor ?? _this.placeholderBorderColor,
      emptyHeight: emptyHeight ?? _this.emptyHeight,
      dragScale: dragScale ?? _this.dragScale,
      dragTilt: dragTilt ?? _this.dragTilt,
      landScale: landScale ?? _this.landScale,
      dragShadows: dragShadows ?? _this.dragShadows,
      highlightColor: highlightColor ?? _this.highlightColor,
      highlightDuration: highlightDuration ?? _this.highlightDuration,
      liftSpring: liftSpring ?? _this.liftSpring,
      shiftSpring: shiftSpring ?? _this.shiftSpring,
      dropSpring: dropSpring ?? _this.dropSpring,
      landSpring: landSpring ?? _this.landSpring,
      autoScrollExtent: autoScrollExtent ?? _this.autoScrollExtent,
      autoScrollSpeed: autoScrollSpeed ?? _this.autoScrollSpeed,
      snap: snap ?? _this.snap,
    );
  }

  BoardTheme merge(BoardTheme? other) {
    final _this = (this as BoardTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      columnWidth: other.columnWidth,
      columnMinWidth: other.columnMinWidth,
      columnMaxWidth: other.columnMaxWidth,
      columnViewportFraction: other.columnViewportFraction,
      columnGap: other.columnGap,
      itemGap: other.itemGap,
      padding: other.padding,
      columnPadding: other.columnPadding,
      headerPadding: other.headerPadding,
      footerPadding: other.footerPadding,
      columnBorderRadius: other.columnBorderRadius,
      columnColor: other.columnColor,
      columnBorderColor: other.columnBorderColor,
      targetColumnColor: other.targetColumnColor,
      targetColumnBorderColor: other.targetColumnBorderColor,
      refusedColumnColor: other.refusedColumnColor,
      refusedColumnBorderColor: other.refusedColumnBorderColor,
      headerTextStyle:
          _this.headerTextStyle?.merge(other.headerTextStyle) ??
          other.headerTextStyle,
      countTextStyle:
          _this.countTextStyle?.merge(other.countTextStyle) ??
          other.countTextStyle,
      countColor: other.countColor,
      countForegroundColor: other.countForegroundColor,
      fullCountColor: other.fullCountColor,
      fullCountForegroundColor: other.fullCountForegroundColor,
      itemColor: other.itemColor,
      itemPadding: other.itemPadding,
      itemBorderRadius: other.itemBorderRadius,
      itemShadows: other.itemShadows,
      placeholderColor: other.placeholderColor,
      placeholderBorderColor: other.placeholderBorderColor,
      emptyHeight: other.emptyHeight,
      dragScale: other.dragScale,
      dragTilt: other.dragTilt,
      landScale: other.landScale,
      dragShadows: other.dragShadows,
      highlightColor: other.highlightColor,
      highlightDuration: other.highlightDuration,
      liftSpring: other.liftSpring,
      shiftSpring: other.shiftSpring,
      dropSpring: other.dropSpring,
      landSpring: other.landSpring,
      autoScrollExtent: other.autoScrollExtent,
      autoScrollSpeed: other.autoScrollSpeed,
      snap: other.snap,
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

    final _this = (this as BoardTheme);
    final _other = (other as BoardTheme);

    return _other.columnWidth == _this.columnWidth &&
        _other.columnMinWidth == _this.columnMinWidth &&
        _other.columnMaxWidth == _this.columnMaxWidth &&
        _other.columnViewportFraction == _this.columnViewportFraction &&
        _other.columnGap == _this.columnGap &&
        _other.itemGap == _this.itemGap &&
        _other.padding == _this.padding &&
        _other.columnPadding == _this.columnPadding &&
        _other.headerPadding == _this.headerPadding &&
        _other.footerPadding == _this.footerPadding &&
        _other.columnBorderRadius == _this.columnBorderRadius &&
        _other.columnColor == _this.columnColor &&
        _other.columnBorderColor == _this.columnBorderColor &&
        _other.targetColumnColor == _this.targetColumnColor &&
        _other.targetColumnBorderColor == _this.targetColumnBorderColor &&
        _other.refusedColumnColor == _this.refusedColumnColor &&
        _other.refusedColumnBorderColor == _this.refusedColumnBorderColor &&
        _other.headerTextStyle == _this.headerTextStyle &&
        _other.countTextStyle == _this.countTextStyle &&
        _other.countColor == _this.countColor &&
        _other.countForegroundColor == _this.countForegroundColor &&
        _other.fullCountColor == _this.fullCountColor &&
        _other.fullCountForegroundColor == _this.fullCountForegroundColor &&
        _other.itemColor == _this.itemColor &&
        _other.itemPadding == _this.itemPadding &&
        _other.itemBorderRadius == _this.itemBorderRadius &&
        _other.itemShadows == _this.itemShadows &&
        _other.placeholderColor == _this.placeholderColor &&
        _other.placeholderBorderColor == _this.placeholderBorderColor &&
        _other.emptyHeight == _this.emptyHeight &&
        _other.dragScale == _this.dragScale &&
        _other.dragTilt == _this.dragTilt &&
        _other.landScale == _this.landScale &&
        _other.dragShadows == _this.dragShadows &&
        _other.highlightColor == _this.highlightColor &&
        _other.highlightDuration == _this.highlightDuration &&
        _other.liftSpring == _this.liftSpring &&
        _other.shiftSpring == _this.shiftSpring &&
        _other.dropSpring == _this.dropSpring &&
        _other.landSpring == _this.landSpring &&
        _other.autoScrollExtent == _this.autoScrollExtent &&
        _other.autoScrollSpeed == _this.autoScrollSpeed &&
        _other.snap == _this.snap;
  }

  @override
  int get hashCode {
    final _this = (this as BoardTheme);

    return Object.hashAll([
      runtimeType,
      _this.columnWidth,
      _this.columnMinWidth,
      _this.columnMaxWidth,
      _this.columnViewportFraction,
      _this.columnGap,
      _this.itemGap,
      _this.padding,
      _this.columnPadding,
      _this.headerPadding,
      _this.footerPadding,
      _this.columnBorderRadius,
      _this.columnColor,
      _this.columnBorderColor,
      _this.targetColumnColor,
      _this.targetColumnBorderColor,
      _this.refusedColumnColor,
      _this.refusedColumnBorderColor,
      _this.headerTextStyle,
      _this.countTextStyle,
      _this.countColor,
      _this.countForegroundColor,
      _this.fullCountColor,
      _this.fullCountForegroundColor,
      _this.itemColor,
      _this.itemPadding,
      _this.itemBorderRadius,
      _this.itemShadows,
      _this.placeholderColor,
      _this.placeholderBorderColor,
      _this.emptyHeight,
      _this.dragScale,
      _this.dragTilt,
      _this.landScale,
      _this.dragShadows,
      _this.highlightColor,
      _this.highlightDuration,
      _this.liftSpring,
      _this.shiftSpring,
      _this.dropSpring,
      _this.landSpring,
      _this.autoScrollExtent,
      _this.autoScrollSpeed,
      _this.snap,
    ]);
  }
}
