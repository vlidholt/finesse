import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/charts/charts_bar.dart';
import 'package:example/docs/examples/charts/charts_bar_stacked.dart';
import 'package:example/docs/examples/charts/charts_donut.dart';
import 'package:example/docs/examples/charts/charts_line.dart';
import 'package:example/docs/examples/charts/charts_line_styles.dart';
import 'package:example/docs/examples/charts/charts_sparkline.dart';

final chartsDoc = ComponentDoc(
  slug: 'charts',
  title: 'Charts',
  description:
      'Line, bar and donut charts and sparklines in the theme\'s chart '
      'colours, with round ticks, a tooltip on hover, touch and the '
      'keyboard, and values that grow into place.',
  examples: [
    ComponentExample(
      id: 'charts_line',
      title: 'Line chart',
      description:
          '`LineChart` draws a `ChartSeries` per line over `labels`. Each '
          'series takes the next of the scheme\'s `chart1`…`chart5` unless '
          'it names a `color`; `area` fills under the line, fading to the '
          'baseline. `ChartLegend` takes the same list. Hover, touch or Tab '
          'into the chart: the tooltip follows the pointer, and the arrow '
          'keys step from point to point.',
      minPreviewHeight: 420,
      builder: (_) => const ChartsLineExample(),
    ),
    ComponentExample(
      id: 'charts_line_styles',
      title: 'Curves, steps and numbers',
      description:
          '`interpolation` joins the points with a smooth curve that never '
          'overshoots them, straight lines or steps; `dots` marks each '
          'point. With `xValues` instead of `labels` the points are spaced '
          'by their value and the x axis gets round ticks. '
          '`valueFormatter` and `xFormatter` write the numbers.',
      minPreviewHeight: 320,
      builder: (_) => const ChartsLineStylesExample(),
    ),
    ComponentExample(
      id: 'charts_bar',
      title: 'Bar chart',
      description:
          '`BarChart` stands the series side by side per category, the '
          'ends rounded to the style\'s row radius. Give it new data and '
          'every bar moves from where it was, the axis with it.',
      minPreviewHeight: 420,
      builder: (_) => const ChartsBarExample(),
    ),
    ComponentExample(
      id: 'charts_bar_stacked',
      title: 'Stacked and horizontal bars',
      description:
          '`stacked: true` piles the series into one bar and rounds only '
          'the end of the stack. `direction: Axis.horizontal` lays the bars '
          'on their sides with the categories down the side, for long '
          'names or a ranking.',
      minPreviewHeight: 380,
      builder: (_) => const ChartsBarStackedExample(),
    ),
    ComponentExample(
      id: 'charts_donut',
      title: 'Donut chart',
      description:
          '`DonutChart` shares out its `ChartSegment`s clockwise from the '
          'top, parted by small gaps. `center` puts a widget in the hole; '
          '`holeRatio: 0` makes a pie. The segment under the pointer comes '
          'out of the ring.',
      minPreviewHeight: 420,
      builder: (_) => const ChartsDonutExample(),
    ),
    ComponentExample(
      id: 'charts_sparkline',
      title: 'Sparkline',
      description:
          'A small line with no axes, for a stat tile or a table row. It '
          'spans its own lowest to highest value, so a small change shows, '
          'and is 96 × 32 unless its parent sets a size.',
      minPreviewHeight: 200,
      builder: (_) => const ChartsSparklineExample(),
    ),
  ],
);
