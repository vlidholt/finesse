import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Stacked bars round only the end of each stack; horizontal bars put
/// long category names down the side.
class ChartsBarStackedExample extends StatelessWidget {
  const ChartsBarStackedExample({super.key});

  static const quarters = ['Q1', 'Q2', 'Q3', 'Q4'];
  static const revenue = [
    ChartSeries(label: 'Subscriptions', values: [42, 51, 58, 66]),
    ChartSeries(label: 'Services', values: [18, 22, 19, 27]),
    ChartSeries(label: 'Hardware', values: [9, 12, 15, 11]),
  ];

  @override
  Widget build(BuildContext context) {
    final cards = [
      Card(
        title: const Text('Revenue'),
        description: const Text('2026, in millions'),
        child: UnaColumn(
          gap: GapSize.md,
          children: [
            SizedBox(
              height: 220,
              child: BarChart(
                labels: quarters,
                series: revenue,
                stacked: true,
                valueFormatter: (v) => '\$${v.round()}M',
                semanticLabel: 'Revenue by quarter',
              ),
            ),
            const ChartLegend(entries: revenue),
          ],
        ),
      ),
      const Card(
        title: Text('Top pages'),
        description: Text('Views this week'),
        child: SizedBox(
          height: 220,
          child: BarChart(
            direction: Axis.horizontal,
            showGrid: false,
            labels: ['/pricing', '/docs/install', '/blog', '/careers'],
            series: [
              ChartSeries(label: 'Views', values: [4820, 3960, 2410, 1280]),
            ],
            semanticLabel: 'Views by page',
          ),
        ),
      ),
    ];
    // Side by side on a desktop, one above the other on a phone.
    final mobile = Theme.of(context).formFactor == FormFactor.mobile;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: mobile
          ? UnaColumn(gap: GapSize.lg, children: cards)
          : UnaRow(
              gap: GapSize.lg,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final card in cards) Expanded(child: card)],
            ),
    );
  }
}
