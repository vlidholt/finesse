import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';
import 'package:una/src/theme/components/decorator.dart';

part 'chart.g.theme.dart';

/// {@template ChartTheme}
/// The theme of `LineChart`, `BarChart`, `DonutChart`, `Sparkline` and
/// `ChartLegend`: every value the charts do not take themselves.
///
/// The series colours are the colour scheme's `chart1`…`chart5` unless
/// [palette] says otherwise; the tooltip is a popover surface (glass in the
/// `fluid` style); gridlines are the scheme's `border`.
/// {@endtemplate}
@themeGen
@immutable
class ChartTheme with _$ChartTheme {
  /// {@macro ChartTheme}
  const ChartTheme({
    bool canMerge = true,
    this.palette,
    this.gridColor,
    this.gridWidth,
    this.axisTextStyle,
    this.axisGap,
    this.tickCount,
    this.cursorColor,
    this.cursorWidth,
    this.highlightColor,
    this.lineWidth,
    this.dotRadius,
    this.activeDotRadius,
    this.dotBorderColor,
    this.areaOpacity,
    this.barRadius,
    this.barGap,
    this.categoryGap,
    this.maxBarThickness,
    this.segmentGap,
    this.segmentRadius,
    this.holeRatio,
    this.activeSegmentGrowth,
    this.tooltipDecoration,
    this.tooltipPadding,
    this.tooltipLabelStyle,
    this.tooltipTextStyle,
    this.tooltipValueStyle,
    this.tooltipOffset,
    this.legendTextStyle,
    this.legendSwatchSize,
    this.legendSpacing,
    this.height,
    this.sparklineLineWidth,
    this.sparklineSize,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The colours of the series, in order; a chart with more series than
  /// colours starts again from the first. Null is the colour scheme's
  /// `charts` (`chart1`…`chart5`).
  final List<Color>? palette;

  /// The colour of the horizontal gridlines (vertical in a horizontal bar
  /// chart): the scheme's `border`.
  final Color? gridColor;

  /// The width of a gridline. A hairline, 1.
  final double? gridWidth;

  /// The style of the tick labels: the text theme's `caption`, which is the
  /// muted colour, with tabular figures.
  final TextStyle? axisTextStyle;

  /// The space between a tick label and the plot.
  final double? axisGap;

  /// How many value ticks a chart aims for. The ticks are round numbers, so
  /// the count is a target, not a promise. 5 by default.
  final int? tickCount;

  /// The colour of the vertical line a line chart draws at the point under
  /// the pointer.
  final Color? cursorColor;

  /// The width of that line.
  final double? cursorWidth;

  /// The band painted behind the bars of the category under the pointer:
  /// the scheme's `muted`.
  final Color? highlightColor;

  /// The width of a line chart's lines.
  final double? lineWidth;

  /// The radius of a line chart's dots, when it shows them.
  final double? dotRadius;

  /// The radius of the dot on each line at the point under the pointer.
  final double? activeDotRadius;

  /// The ring around a dot, which keeps it apart from its line and from the
  /// lines it crosses: the scheme's `card`.
  final Color? dotBorderColor;

  /// The opacity of an area's fill at the line; it fades to nothing at the
  /// baseline.
  final double? areaOpacity;

  /// The corner radius of the end of a bar, away from the baseline. A
  /// stack rounds only its outer end. Never more than half the bar's
  /// thickness.
  final double? barRadius;

  /// The space between the bars of one category in a grouped bar chart.
  final double? barGap;

  /// The fraction of each category's band left empty around its bars,
  /// from 0 (bars touch) to below 1.
  final double? categoryGap;

  /// The thickest a bar gets on a wide chart.
  final double? maxBarThickness;

  /// The width of the gap between two segments of a donut.
  final double? segmentGap;

  /// The corner radius of a donut's segments.
  final double? segmentRadius;

  /// The radius of a donut's hole as a fraction of its own: 0 is a pie.
  final double? holeRatio;

  /// How far the segment under the pointer grows out of the ring.
  final double? activeSegmentGrowth;

  /// The tooltip's fill, outline, radius and shadow: a popover surface, at
  /// a tighter radius.
  final UnaDecoration? tooltipDecoration;

  /// The space inside the tooltip.
  final EdgeInsetsGeometry? tooltipPadding;

  /// The style of the tooltip's title: the category, or a segment's label.
  final TextStyle? tooltipLabelStyle;

  /// The style of a series' name in the tooltip.
  final TextStyle? tooltipTextStyle;

  /// The style of a value in the tooltip.
  final TextStyle? tooltipValueStyle;

  /// The distance between the tooltip and the point it describes.
  final double? tooltipOffset;

  /// The style of a legend's labels.
  final TextStyle? legendTextStyle;

  /// The side of a legend's colour swatch.
  final double? legendSwatchSize;

  /// The space between two entries of a legend.
  final double? legendSpacing;

  /// The height of a line or bar chart, and the side of a donut, that is
  /// free to choose its size: one its parent does not hold to a height.
  final double? height;

  /// The width of a sparkline's line.
  final double? sparklineLineWidth;

  /// The size of a sparkline its parent does not hold to a size.
  final Size? sparklineSize;

  /// Linearly interpolates between [a] and [b] by [t].
  static ChartTheme? lerp(ChartTheme? a, ChartTheme? b, double t) =>
      _$ChartTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const palette would never equal its own rebuild. Compare the list
  // by value, then let the generated `==` compare everything else against a
  // copy that shares it.
  @override
  bool operator ==(Object other) =>
      other is ChartTheme &&
      listEquals(palette, other.palette) &&
      super == other.copyWith(palette: palette);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(palette ?? const []),
  );
}
