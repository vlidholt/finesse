# Charts

Line, bar and donut charts and sparklines in the theme's chart colours, with round ticks, a tooltip on hover, touch and the keyboard, and values that grow into place.

## Line chart

`LineChart` draws a `ChartSeries` per line over `labels`. Each series takes the next of the scheme's `chart1`…`chart5` (shades of green unless `ThemeData(chartPalette:)` picks another palette) unless it names a `color`; `area` fills under the line, fading to the baseline. `ChartLegend` takes the same list. Hover, touch or Tab into the chart: the tooltip follows the pointer, and the arrow keys step from point to point.

```dart
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
```

## Curves, steps and numbers

`interpolation` joins the points with a smooth curve that never overshoots them, straight lines or steps; `dots` marks each point. With `xValues` instead of `labels` the points are spaced by their value and the x axis gets round ticks. `valueFormatter` and `xFormatter` write the numbers.

```dart
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
```

## Bar chart

`BarChart` stands the series side by side per category, the ends rounded to the style's row radius. Give it new data and every bar moves from where it was, the axis with it.

```dart
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
```

## Stacked and horizontal bars

`stacked: true` piles the series into one bar and rounds only the end of the stack. `direction: Axis.horizontal` lays the bars on their sides with the categories down the side, for long names or a ranking.

```dart
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
```

## Donut chart

`DonutChart` shares out its `ChartSegment`s clockwise from the top, parted by small gaps. `center` puts a widget in the hole; `holeRatio: 0` makes a pie. The segment under the pointer comes out of the ring.

```dart
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
```

## Sparkline

A small line with no axes, for a stat tile or a table row. It spans its own lowest to highest value, so a small change shows, and is 96 × 32 unless its parent sets a size.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A sparkline beside a number shows where it is heading. It sizes itself
/// in a row and takes any colour.
class ChartsSparklineExample extends StatelessWidget {
  const ChartsSparklineExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      const StatTile(
        value: Text('2,350'),
        label: Text('Visitors'),
        trailing: Sparkline(
          values: [12, 18, 15, 22, 19, 28, 31],
          semanticLabel: 'Visitors this week',
        ),
      ),
      StatTile(
        value: const Text('38%'),
        label: const Text('Bounce rate'),
        trailing: Sparkline(
          values: const [46, 44, 45, 41, 42, 39, 38],
          color: theme.colorScheme.success,
          semanticLabel: 'Bounce rate this week',
        ),
      ),
    ];
    final mobile = theme.formFactor == FormFactor.mobile;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: mobile
          ? UnaColumn(gap: GapSize.md, children: tiles)
          : UnaRow(
              gap: GapSize.md,
              children: [for (final tile in tiles) Expanded(child: tile)],
            ),
    );
  }
}
```
