// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element

part of 'chart.dart';

// **************************************************************************
// ThemeGenGenerator
// **************************************************************************

mixin _$ChartTheme {
  bool get canMerge => true;

  static ChartTheme? lerp(ChartTheme? a, ChartTheme? b, double t) {
    if (identical(a, b)) {
      return a;
    }

    if (a == null) {
      return t == 1.0 ? b : null;
    }

    if (b == null) {
      return t == 0.0 ? a : null;
    }

    return ChartTheme(
      palette: t < 0.5 ? a.palette : b.palette,
      gridColor: Color.lerp(a.gridColor, b.gridColor, t),
      gridWidth: lerpDouble$(a.gridWidth, b.gridWidth, t),
      axisTextStyle: TextStyle.lerp(a.axisTextStyle, b.axisTextStyle, t),
      axisGap: lerpDouble$(a.axisGap, b.axisGap, t),
      tickCount: t < 0.5 ? a.tickCount : b.tickCount,
      cursorColor: Color.lerp(a.cursorColor, b.cursorColor, t),
      cursorWidth: lerpDouble$(a.cursorWidth, b.cursorWidth, t),
      highlightColor: Color.lerp(a.highlightColor, b.highlightColor, t),
      lineWidth: lerpDouble$(a.lineWidth, b.lineWidth, t),
      dotRadius: lerpDouble$(a.dotRadius, b.dotRadius, t),
      activeDotRadius: lerpDouble$(a.activeDotRadius, b.activeDotRadius, t),
      dotBorderColor: Color.lerp(a.dotBorderColor, b.dotBorderColor, t),
      areaOpacity: lerpDouble$(a.areaOpacity, b.areaOpacity, t),
      barRadius: lerpDouble$(a.barRadius, b.barRadius, t),
      barGap: lerpDouble$(a.barGap, b.barGap, t),
      categoryGap: lerpDouble$(a.categoryGap, b.categoryGap, t),
      maxBarThickness: lerpDouble$(a.maxBarThickness, b.maxBarThickness, t),
      segmentGap: lerpDouble$(a.segmentGap, b.segmentGap, t),
      segmentRadius: lerpDouble$(a.segmentRadius, b.segmentRadius, t),
      holeRatio: lerpDouble$(a.holeRatio, b.holeRatio, t),
      activeSegmentGrowth: lerpDouble$(
        a.activeSegmentGrowth,
        b.activeSegmentGrowth,
        t,
      ),
      tooltipDecoration: UnaDecoration.lerp(
        a.tooltipDecoration,
        b.tooltipDecoration,
        t,
      ),
      tooltipPadding: EdgeInsetsGeometry.lerp(
        a.tooltipPadding,
        b.tooltipPadding,
        t,
      ),
      tooltipLabelStyle: TextStyle.lerp(
        a.tooltipLabelStyle,
        b.tooltipLabelStyle,
        t,
      ),
      tooltipTextStyle: TextStyle.lerp(
        a.tooltipTextStyle,
        b.tooltipTextStyle,
        t,
      ),
      tooltipValueStyle: TextStyle.lerp(
        a.tooltipValueStyle,
        b.tooltipValueStyle,
        t,
      ),
      tooltipOffset: lerpDouble$(a.tooltipOffset, b.tooltipOffset, t),
      legendTextStyle: TextStyle.lerp(a.legendTextStyle, b.legendTextStyle, t),
      legendSwatchSize: lerpDouble$(a.legendSwatchSize, b.legendSwatchSize, t),
      legendSpacing: lerpDouble$(a.legendSpacing, b.legendSpacing, t),
      height: lerpDouble$(a.height, b.height, t),
      sparklineLineWidth: lerpDouble$(
        a.sparklineLineWidth,
        b.sparklineLineWidth,
        t,
      ),
      sparklineSize: Size.lerp(a.sparklineSize, b.sparklineSize, t),
    );
  }

  ChartTheme copyWith({
    List<Color>? palette,
    Color? gridColor,
    double? gridWidth,
    TextStyle? axisTextStyle,
    double? axisGap,
    int? tickCount,
    Color? cursorColor,
    double? cursorWidth,
    Color? highlightColor,
    double? lineWidth,
    double? dotRadius,
    double? activeDotRadius,
    Color? dotBorderColor,
    double? areaOpacity,
    double? barRadius,
    double? barGap,
    double? categoryGap,
    double? maxBarThickness,
    double? segmentGap,
    double? segmentRadius,
    double? holeRatio,
    double? activeSegmentGrowth,
    UnaDecoration? tooltipDecoration,
    EdgeInsetsGeometry? tooltipPadding,
    TextStyle? tooltipLabelStyle,
    TextStyle? tooltipTextStyle,
    TextStyle? tooltipValueStyle,
    double? tooltipOffset,
    TextStyle? legendTextStyle,
    double? legendSwatchSize,
    double? legendSpacing,
    double? height,
    double? sparklineLineWidth,
    Size? sparklineSize,
  }) {
    final _this = (this as ChartTheme);

    return ChartTheme(
      palette: palette ?? _this.palette,
      gridColor: gridColor ?? _this.gridColor,
      gridWidth: gridWidth ?? _this.gridWidth,
      axisTextStyle: axisTextStyle ?? _this.axisTextStyle,
      axisGap: axisGap ?? _this.axisGap,
      tickCount: tickCount ?? _this.tickCount,
      cursorColor: cursorColor ?? _this.cursorColor,
      cursorWidth: cursorWidth ?? _this.cursorWidth,
      highlightColor: highlightColor ?? _this.highlightColor,
      lineWidth: lineWidth ?? _this.lineWidth,
      dotRadius: dotRadius ?? _this.dotRadius,
      activeDotRadius: activeDotRadius ?? _this.activeDotRadius,
      dotBorderColor: dotBorderColor ?? _this.dotBorderColor,
      areaOpacity: areaOpacity ?? _this.areaOpacity,
      barRadius: barRadius ?? _this.barRadius,
      barGap: barGap ?? _this.barGap,
      categoryGap: categoryGap ?? _this.categoryGap,
      maxBarThickness: maxBarThickness ?? _this.maxBarThickness,
      segmentGap: segmentGap ?? _this.segmentGap,
      segmentRadius: segmentRadius ?? _this.segmentRadius,
      holeRatio: holeRatio ?? _this.holeRatio,
      activeSegmentGrowth: activeSegmentGrowth ?? _this.activeSegmentGrowth,
      tooltipDecoration: tooltipDecoration ?? _this.tooltipDecoration,
      tooltipPadding: tooltipPadding ?? _this.tooltipPadding,
      tooltipLabelStyle: tooltipLabelStyle ?? _this.tooltipLabelStyle,
      tooltipTextStyle: tooltipTextStyle ?? _this.tooltipTextStyle,
      tooltipValueStyle: tooltipValueStyle ?? _this.tooltipValueStyle,
      tooltipOffset: tooltipOffset ?? _this.tooltipOffset,
      legendTextStyle: legendTextStyle ?? _this.legendTextStyle,
      legendSwatchSize: legendSwatchSize ?? _this.legendSwatchSize,
      legendSpacing: legendSpacing ?? _this.legendSpacing,
      height: height ?? _this.height,
      sparklineLineWidth: sparklineLineWidth ?? _this.sparklineLineWidth,
      sparklineSize: sparklineSize ?? _this.sparklineSize,
    );
  }

  ChartTheme merge(ChartTheme? other) {
    final _this = (this as ChartTheme);

    if (other == null || identical(_this, other)) {
      return _this;
    }

    if (!other.canMerge) {
      return other;
    }

    return copyWith(
      palette: other.palette,
      gridColor: other.gridColor,
      gridWidth: other.gridWidth,
      axisTextStyle:
          _this.axisTextStyle?.merge(other.axisTextStyle) ??
          other.axisTextStyle,
      axisGap: other.axisGap,
      tickCount: other.tickCount,
      cursorColor: other.cursorColor,
      cursorWidth: other.cursorWidth,
      highlightColor: other.highlightColor,
      lineWidth: other.lineWidth,
      dotRadius: other.dotRadius,
      activeDotRadius: other.activeDotRadius,
      dotBorderColor: other.dotBorderColor,
      areaOpacity: other.areaOpacity,
      barRadius: other.barRadius,
      barGap: other.barGap,
      categoryGap: other.categoryGap,
      maxBarThickness: other.maxBarThickness,
      segmentGap: other.segmentGap,
      segmentRadius: other.segmentRadius,
      holeRatio: other.holeRatio,
      activeSegmentGrowth: other.activeSegmentGrowth,
      tooltipDecoration:
          _this.tooltipDecoration?.merge(other.tooltipDecoration) ??
          other.tooltipDecoration,
      tooltipPadding: other.tooltipPadding,
      tooltipLabelStyle:
          _this.tooltipLabelStyle?.merge(other.tooltipLabelStyle) ??
          other.tooltipLabelStyle,
      tooltipTextStyle:
          _this.tooltipTextStyle?.merge(other.tooltipTextStyle) ??
          other.tooltipTextStyle,
      tooltipValueStyle:
          _this.tooltipValueStyle?.merge(other.tooltipValueStyle) ??
          other.tooltipValueStyle,
      tooltipOffset: other.tooltipOffset,
      legendTextStyle:
          _this.legendTextStyle?.merge(other.legendTextStyle) ??
          other.legendTextStyle,
      legendSwatchSize: other.legendSwatchSize,
      legendSpacing: other.legendSpacing,
      height: other.height,
      sparklineLineWidth: other.sparklineLineWidth,
      sparklineSize: other.sparklineSize,
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

    final _this = (this as ChartTheme);
    final _other = (other as ChartTheme);

    return _other.palette == _this.palette &&
        _other.gridColor == _this.gridColor &&
        _other.gridWidth == _this.gridWidth &&
        _other.axisTextStyle == _this.axisTextStyle &&
        _other.axisGap == _this.axisGap &&
        _other.tickCount == _this.tickCount &&
        _other.cursorColor == _this.cursorColor &&
        _other.cursorWidth == _this.cursorWidth &&
        _other.highlightColor == _this.highlightColor &&
        _other.lineWidth == _this.lineWidth &&
        _other.dotRadius == _this.dotRadius &&
        _other.activeDotRadius == _this.activeDotRadius &&
        _other.dotBorderColor == _this.dotBorderColor &&
        _other.areaOpacity == _this.areaOpacity &&
        _other.barRadius == _this.barRadius &&
        _other.barGap == _this.barGap &&
        _other.categoryGap == _this.categoryGap &&
        _other.maxBarThickness == _this.maxBarThickness &&
        _other.segmentGap == _this.segmentGap &&
        _other.segmentRadius == _this.segmentRadius &&
        _other.holeRatio == _this.holeRatio &&
        _other.activeSegmentGrowth == _this.activeSegmentGrowth &&
        _other.tooltipDecoration == _this.tooltipDecoration &&
        _other.tooltipPadding == _this.tooltipPadding &&
        _other.tooltipLabelStyle == _this.tooltipLabelStyle &&
        _other.tooltipTextStyle == _this.tooltipTextStyle &&
        _other.tooltipValueStyle == _this.tooltipValueStyle &&
        _other.tooltipOffset == _this.tooltipOffset &&
        _other.legendTextStyle == _this.legendTextStyle &&
        _other.legendSwatchSize == _this.legendSwatchSize &&
        _other.legendSpacing == _this.legendSpacing &&
        _other.height == _this.height &&
        _other.sparklineLineWidth == _this.sparklineLineWidth &&
        _other.sparklineSize == _this.sparklineSize;
  }

  @override
  int get hashCode {
    final _this = (this as ChartTheme);

    return Object.hashAll([
      runtimeType,
      _this.palette,
      _this.gridColor,
      _this.gridWidth,
      _this.axisTextStyle,
      _this.axisGap,
      _this.tickCount,
      _this.cursorColor,
      _this.cursorWidth,
      _this.highlightColor,
      _this.lineWidth,
      _this.dotRadius,
      _this.activeDotRadius,
      _this.dotBorderColor,
      _this.areaOpacity,
      _this.barRadius,
      _this.barGap,
      _this.categoryGap,
      _this.maxBarThickness,
      _this.segmentGap,
      _this.segmentRadius,
      _this.holeRatio,
      _this.activeSegmentGrowth,
      _this.tooltipDecoration,
      _this.tooltipPadding,
      _this.tooltipLabelStyle,
      _this.tooltipTextStyle,
      _this.tooltipValueStyle,
      _this.tooltipOffset,
      _this.legendTextStyle,
      _this.legendSwatchSize,
      _this.legendSpacing,
      _this.height,
      _this.sparklineLineWidth,
      _this.sparklineSize,
    ]);
  }
}
