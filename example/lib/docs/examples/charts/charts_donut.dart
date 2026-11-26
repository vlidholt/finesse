import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Shares of a whole, with the total in the hole. `holeRatio: 0` makes a
/// pie.
class ChartsDonutExample extends StatelessWidget {
  const ChartsDonutExample({super.key});

  static const browsers = [
    ChartSegment(label: 'Chrome', value: 275),
    ChartSegment(label: 'Safari', value: 200),
    ChartSegment(label: 'Firefox', value: 187),
    ChartSegment(label: 'Edge', value: 173),
    ChartSegment(label: 'Other', value: 90),
  ];

  static const storage = [
    ChartSegment(label: 'Photos', value: 28),
    ChartSegment(label: 'Apps', value: 19),
    ChartSegment(label: 'Messages', value: 11),
    ChartSegment(label: 'System', value: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = browsers.fold<double>(0, (sum, s) => sum + s.value);
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: Card(
            title: const Text('Browsers'),
            description: const Text('Visitors this month'),
            child: UnaColumn(
              gap: GapSize.lg,
              children: [
                SizedBox(
                  height: 200,
                  child: DonutChart(
                    segments: browsers,
                    semanticLabel: 'Visitors by browser',
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NumberFormat.decimalPattern().format(total),
                          style: theme.textTheme.h3,
                        ),
                        Text('Visitors', style: theme.textTheme.caption),
                      ],
                    ),
                  ),
                ),
                const ChartLegend(entries: browsers),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 280,
          child: Card(
            title: Text('Storage'),
            description: Text('64 GB used'),
            child: UnaColumn(
              gap: GapSize.lg,
              children: [
                SizedBox(
                  height: 200,
                  child: DonutChart(
                    holeRatio: 0,
                    segments: storage,
                    semanticLabel: 'Storage by kind',
                  ),
                ),
                ChartLegend(entries: storage),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
