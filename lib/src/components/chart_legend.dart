import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/src/components/chart_data.dart';
import 'package:una/src/components/chart_support.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';

/// The key to a chart: a colour swatch and a name per series or segment.
///
/// ```dart
/// Column(
///   children: [
///     LineChart(labels: months, series: series),
///     ChartLegend(entries: series),
///   ],
/// )
/// ```
///
/// Give it the same list the chart has, in the same order: an entry with no
/// colour of its own takes the palette colour of its place in the list, as
/// it does in the chart. The entries wrap onto more lines when they do not
/// fit, and follow the reading direction.
class ChartLegend extends StatelessWidget {
  /// Creates a legend for [entries].
  const ChartLegend({
    required this.entries,
    this.alignment = WrapAlignment.center,
    super.key,
  });

  /// The series of a line or bar chart, or the segments of a donut.
  final List<ChartEntry> entries;

  /// How the entries are placed along each line.
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final chart = theme.chartTheme;
    final swatch = chart.legendSwatchSize ?? 10;
    final radius = BorderRadius.circular(
      math.min(swatch / 4, chart.barRadius ?? 2.5),
    );
    final style = chart.legendTextStyle ?? theme.textTheme.caption;
    return Wrap(
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: chart.legendSpacing ?? 16,
      runSpacing: 6,
      children: [
        for (final (i, entry) in entries.indexed)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: chartColor(theme, entry, i),
                  borderRadius: radius,
                ),
                child: SizedBox.square(dimension: swatch),
              ),
              Text(entry.label, style: style),
            ],
          ),
      ],
    );
  }
}
