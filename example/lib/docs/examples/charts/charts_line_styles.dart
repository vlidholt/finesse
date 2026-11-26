import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// How a line joins its points, whether it marks them, and a line over
/// numbers rather than categories: the points are spaced by their value.
class ChartsLineStylesExample extends StatefulWidget {
  const ChartsLineStylesExample({super.key});

  @override
  State<ChartsLineStylesExample> createState() =>
      _ChartsLineStylesExampleState();
}

class _ChartsLineStylesExampleState extends State<ChartsLineStylesExample> {
  LineInterpolation interpolation = LineInterpolation.monotone;
  bool dots = true;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: UnaColumn(
        gap: GapSize.lg,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedControl<LineInterpolation>(
                value: interpolation,
                onChanged: (value) => setState(() => interpolation = value),
                segments: const [
                  Segment(
                    value: LineInterpolation.monotone,
                    label: Text('Curve'),
                  ),
                  Segment(
                    value: LineInterpolation.linear,
                    label: Text('Straight'),
                  ),
                  Segment(value: LineInterpolation.step, label: Text('Step')),
                ],
              ),
              Switch(
                value: dots,
                onChanged: (value) => setState(() => dots = value),
                label: const Text('Dots'),
              ),
            ],
          ),
          SizedBox(
            height: 220,
            child: LineChart(
              // Response time against load.
              xValues: const [10, 20, 40, 80, 120, 160, 200],
              xFormatter: (rps) => '${rps.round()} rps',
              valueFormatter: (ms) => '${ms.round()} ms',
              interpolation: interpolation,
              dots: dots,
              series: const [
                ChartSeries(
                  label: 'p50',
                  values: [42, 44, 47, 55, 68, 90, 131],
                ),
                ChartSeries(
                  label: 'p95',
                  values: [88, 91, 102, 130, 176, 248, 362],
                ),
              ],
              semanticLabel: 'Response time by load',
            ),
          ),
        ],
      ),
    );
  }
}
