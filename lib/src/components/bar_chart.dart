import 'package:flutter/widgets.dart';
import 'package:una/src/components/cartesian_chart.dart';
import 'package:una/src/components/chart_data.dart';

/// One or more series drawn as bars per category, side by side or stacked,
/// with round ticks, gridlines and a tooltip.
///
/// ```dart
/// BarChart(
///   labels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
///   series: const [
///     ChartSeries(label: 'Desktop', values: [186, 305, 237, 73, 209, 214]),
///     ChartSeries(label: 'Mobile', values: [80, 200, 120, 190, 130, 140]),
///   ],
/// )
/// ```
///
/// Each series takes the next colour of the theme's chart palette
/// (`ColorScheme.chart1`…`chart5`) unless it names its own. A bar's end is
/// rounded by `ChartTheme.barRadius` (the style's row radius); a [stacked]
/// chart rounds only the end of each stack. Negative values grow the other
/// way from the zero line.
///
/// [direction] [Axis.horizontal] lays the bars on their sides, the
/// categories down the side: for long category names, or a ranking.
///
/// Hovering, touching or dragging across the chart highlights a category
/// and shows a tooltip with every series' value. With the keyboard focus
/// the arrow keys step from category to category (left and right, or up
/// and down for horizontal bars), Home and End go to the ends and Escape
/// puts the tooltip away; assistive technology reads the category and
/// steps with its increase and decrease actions.
///
/// The bars grow from the baseline when the chart first appears, and a
/// change of data moves from the old values to the new, on the theme's
/// motion (`Motion.of`); with reduced motion they are simply there.
///
/// The chart fills the width it is given, which must be bounded. Its
/// height is the one it is held to (a `SizedBox`, an `Expanded`), and
/// `ChartTheme.height` (240) where it is free to choose. In a
/// right-to-left reading direction the categories run from the right.
class BarChart extends StatelessWidget {
  /// Creates a bar chart of [series] over [labels].
  const BarChart({
    required this.series,
    required this.labels,
    this.stacked = false,
    this.direction = Axis.vertical,
    this.valueFormatter,
    this.tickFormatter,
    this.minValue,
    this.maxValue,
    this.showGrid = true,
    this.showXAxis = true,
    this.showYAxis = true,
    this.semanticLabel,
    super.key,
  });

  /// The series, each with a value per category.
  final List<ChartSeries> series;

  /// A label per category.
  final List<String> labels;

  /// Whether the series are stacked into one bar per category instead of
  /// standing side by side.
  final bool stacked;

  /// The direction the bars grow in: up from the bottom by default, or
  /// across from the side with [Axis.horizontal].
  final Axis direction;

  /// Writes a value for the tooltip and assistive technology (a currency,
  /// a unit). Defaults to the locale's number format, to two decimals.
  final ChartValueFormatter? valueFormatter;

  /// Writes a tick of the value axis. Defaults to as many decimals as the
  /// ticks' step has, compact (`12K`) for large numbers.
  final ChartValueFormatter? tickFormatter;

  /// The low end of the value axis. Defaults to zero, or the round number
  /// below the lowest value when that is negative.
  final double? minValue;

  /// The high end of the value axis. Defaults to the round number above the
  /// highest value (or the highest stack).
  final double? maxValue;

  /// Whether a gridline is drawn at each value tick.
  final bool showGrid;

  /// Whether the labels along the bottom are shown: the categories, or the
  /// value ticks of a horizontal chart.
  final bool showXAxis;

  /// Whether the labels along the side are shown: the value ticks, or the
  /// categories of a horizontal chart.
  final bool showYAxis;

  /// What the chart shows, for assistive technology. Defaults to "Bar
  /// chart".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CartesianChart(
      kind: CartesianKind.bar,
      name: 'BarChart',
      series: series,
      labels: labels,
      stacked: stacked,
      direction: direction,
      valueFormatter: valueFormatter,
      tickFormatter: tickFormatter,
      minValue: minValue,
      maxValue: maxValue,
      showGrid: showGrid,
      showXAxis: showXAxis,
      showYAxis: showYAxis,
      semanticLabel: semanticLabel,
    );
  }
}
