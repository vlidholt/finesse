import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Turns a chart's value into the text a tooltip, an axis or assistive
/// technology shows for it: a currency, a unit, a percentage.
typedef ChartValueFormatter = String Function(double value);

/// Something a chart draws in one colour and names in its tooltip and
/// legend: a [ChartSeries] of a line or bar chart, or a [ChartSegment] of a
/// donut.
@immutable
sealed class ChartEntry {
  const ChartEntry({required this.label, this.color});

  /// What the entry is, as the tooltip, the legend and assistive technology
  /// name it.
  final String label;

  /// The entry's colour. Null takes the next colour of the chart theme's
  /// palette — the colour scheme's `chart1`…`chart5` — by the entry's place
  /// in its chart.
  final Color? color;
}

/// One series of a `LineChart` or `BarChart`: a value per category.
///
/// ```dart
/// const ChartSeries(label: 'Desktop', values: [186, 305, 237, 73, 209, 214])
/// ```
///
/// [values] has a value per x position of its chart, in order: per label,
/// or per `xValues` entry of a line chart.
class ChartSeries extends ChartEntry {
  /// Creates a series named [label] with a value per category.
  const ChartSeries({required super.label, required this.values, super.color});

  /// The values, one per x position, in order. Every value is finite.
  final List<double> values;

  @override
  bool operator ==(Object other) =>
      other is ChartSeries &&
      other.label == label &&
      other.color == color &&
      listEquals(other.values, values);

  @override
  int get hashCode => Object.hash(label, color, Object.hashAll(values));

  @override
  String toString() => 'ChartSeries($label, $values)';
}

/// One segment of a `DonutChart`: a part of the whole.
///
/// ```dart
/// const ChartSegment(label: 'Chrome', value: 275)
/// ```
class ChartSegment extends ChartEntry {
  /// Creates a segment named [label] worth [value].
  const ChartSegment({required super.label, required this.value, super.color})
    : assert(value >= 0, 'A segment is not worth less than nothing');

  /// What the segment is worth. The donut gives each segment its share of
  /// the sum of all of them.
  final double value;

  @override
  bool operator ==(Object other) =>
      other is ChartSegment &&
      other.label == label &&
      other.color == color &&
      other.value == value;

  @override
  int get hashCode => Object.hash(label, color, value);

  @override
  String toString() => 'ChartSegment($label, $value)';
}

/// How a `LineChart` or `Sparkline` joins its points.
enum LineInterpolation {
  /// A smooth curve through every point that never overshoots it: between
  /// two points it stays between their values (a monotone cubic).
  monotone,

  /// Straight lines from point to point.
  linear,

  /// A step at each point, halfway between it and its neighbours.
  step,
}
