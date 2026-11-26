import 'package:flutter/widgets.dart';
import 'package:una/src/components/cartesian_chart.dart';
import 'package:una/src/components/chart_data.dart';

/// One or more series drawn as lines over categories or numbers, with
/// round ticks, gridlines and a tooltip.
///
/// ```dart
/// LineChart(
///   labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
///   series: const [
///     ChartSeries(label: 'Desktop', values: [186, 305, 237, 73, 209, 214]),
///     ChartSeries(label: 'Mobile', values: [80, 200, 120, 190, 130, 140]),
///   ],
///   area: true,
/// )
/// ```
///
/// Each series takes the next colour of the theme's chart palette
/// (`ColorScheme.chart1`…`chart5`) unless it names its own. The lines are
/// smooth curves that never overshoot a point ([LineInterpolation.
/// monotone]); [area] fills under each line with its colour, fading to
/// nothing at the baseline.
///
/// Hovering, touching or dragging across the chart shows a tooltip with the
/// category and every series' value, and a line at the point. With the
/// keyboard focus the arrow keys step from point to point, Home and End go
/// to the ends and Escape puts the tooltip away; assistive technology reads
/// the point and steps with its increase and decrease actions.
///
/// The values grow from the baseline when the chart first appears, and a
/// change of data moves from the old values to the new, on the theme's
/// motion (`Motion.of`); with reduced motion they are simply there.
///
/// The chart fills the width it is given, which must be bounded. Its
/// height is the one it is held to (a `SizedBox`, an `Expanded`), and
/// `ChartTheme.height` (240) where it is free to choose. In a
/// right-to-left reading direction the x axis runs from the right.
class LineChart extends StatelessWidget {
  /// Creates a line chart of [series] over [labels], or over [xValues].
  const LineChart({
    required this.series,
    this.labels,
    this.xValues,
    this.interpolation = LineInterpolation.monotone,
    this.area = false,
    this.dots = false,
    this.valueFormatter,
    this.tickFormatter,
    this.xFormatter,
    this.minValue,
    this.maxValue,
    this.showGrid = true,
    this.showXAxis = true,
    this.showYAxis = true,
    this.semanticLabel,
    super.key,
  }) : assert(
         labels == null || xValues == null,
         'A line chart is over categories (labels) or numbers (xValues)',
       );

  /// The series, each with a value per x position. The first is drawn on
  /// top.
  final List<ChartSeries> series;

  /// A label per x position, evenly spaced: months, days, names.
  final List<String>? labels;

  /// A number per x position, for a line over numbers rather than
  /// categories: the points are spaced by their values, in increasing
  /// order, and the x axis has round ticks of its own.
  final List<double>? xValues;

  /// How each line joins its points. A smooth curve that never overshoots
  /// by default.
  final LineInterpolation interpolation;

  /// Whether each line fills the area under it, in its colour fading to
  /// nothing at the baseline.
  final bool area;

  /// Whether each point is marked with a dot.
  final bool dots;

  /// Writes a value for the tooltip and assistive technology (a currency,
  /// a unit). Defaults to the locale's number format, to two decimals.
  final ChartValueFormatter? valueFormatter;

  /// Writes a tick of the y axis. Defaults to as many decimals as the
  /// ticks' step has, compact (`12K`) for large numbers.
  final ChartValueFormatter? tickFormatter;

  /// Writes an x value, for a chart over [xValues].
  final ChartValueFormatter? xFormatter;

  /// The bottom of the y axis. Defaults to zero, or the round number below
  /// the lowest value when that is negative.
  final double? minValue;

  /// The top of the y axis. Defaults to the round number above the highest
  /// value.
  final double? maxValue;

  /// Whether a gridline is drawn at each y tick.
  final bool showGrid;

  /// Whether the x labels are shown along the bottom.
  final bool showXAxis;

  /// Whether the y ticks are labelled along the side.
  final bool showYAxis;

  /// What the chart shows, for assistive technology. Defaults to "Line
  /// chart".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CartesianChart(
      kind: CartesianKind.line,
      name: 'LineChart',
      series: series,
      labels: labels,
      xValues: xValues,
      interpolation: interpolation,
      area: area,
      dots: dots,
      valueFormatter: valueFormatter,
      tickFormatter: tickFormatter,
      xFormatter: xFormatter,
      minValue: minValue,
      maxValue: maxValue,
      showGrid: showGrid,
      showXAxis: showXAxis,
      showYAxis: showYAxis,
      semanticLabel: semanticLabel,
    );
  }
}
