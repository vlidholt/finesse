import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Bars side by side per category. New data moves each bar from where it
/// was, and the axis with it.
class ChartsBarExample extends StatefulWidget {
  const ChartsBarExample({super.key});

  @override
  State<ChartsBarExample> createState() => _ChartsBarExampleState();
}

class _ChartsBarExampleState extends State<ChartsBarExample> {
  static const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  final random = math.Random(7);
  List<ChartSeries> series = const [
    ChartSeries(label: 'Desktop', values: [186, 305, 237, 73, 209, 214]),
    ChartSeries(label: 'Mobile', values: [80, 200, 120, 190, 130, 140]),
  ];

  void shuffle() {
    setState(() {
      series = [
        for (final s in series)
          ChartSeries(
            label: s.label,
            values: [
              for (var i = 0; i < months.length; i++)
                (40 + random.nextInt(360)).toDouble(),
            ],
          ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Card(
        title: const Text('Sessions'),
        description: const Text('By device, January – June'),
        action: Button.outline(
          onPressed: shuffle,
          leading: const PhosphorIcon(PhosphorIconsRegular.shuffle),
          child: const Text('New data'),
        ),
        child: UnaColumn(
          gap: GapSize.md,
          children: [
            BarChart(
              labels: months,
              series: series,
              semanticLabel: 'Sessions by month',
            ),
            ChartLegend(entries: series),
          ],
        ),
      ),
    );
  }
}
