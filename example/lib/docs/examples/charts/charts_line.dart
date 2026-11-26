import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Two series over six months, the area under each line filled, with a
/// legend below. Hover, touch or Tab into the chart to read the values.
class ChartsLineExample extends StatelessWidget {
  const ChartsLineExample({super.key});

  static const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const series = [
    ChartSeries(label: 'Desktop', values: [186, 305, 237, 73, 209, 214]),
    ChartSeries(label: 'Mobile', values: [80, 200, 120, 190, 130, 140]),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: const Card(
        title: Text('Visitors'),
        description: Text('January – June 2026'),
        child: UnaColumn(
          gap: GapSize.md,
          children: [
            LineChart(
              labels: months,
              series: series,
              area: true,
              semanticLabel: 'Visitors by month',
            ),
            ChartLegend(entries: series),
          ],
        ),
      ),
    );
  }
}
