import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/chart_support.dart';
import 'package:una/src/components/donut_chart.dart' show donutSegmentPath;
import 'package:una/una.dart';

import '../../una_harness.dart';

const _labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const _series = [
  ChartSeries(label: 'Desktop', values: [186, 305, 237, 73, 209, 214]),
  ChartSeries(label: 'Mobile', values: [80, 200, 120, 190, 130, 140]),
];
const _segments = [
  ChartSegment(label: 'Chrome', value: 275),
  ChartSegment(label: 'Safari', value: 200),
  ChartSegment(label: 'Firefox', value: 125),
];

Widget _sized(Widget chart, {double width = 600, double? height = 300}) {
  return Align(
    alignment: Alignment.topLeft,
    child: SizedBox(width: width, height: height, child: chart),
  );
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(-10, -10));
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Lets an entrance or a change of data run out.
Future<void> _settleChart(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('niceScale', () {
    test('rounds out to round ticks', () {
      final scale = niceScale(0, 305);
      expect(scale.min, 0);
      expect(scale.max, 400);
      expect(scale.ticks, [0, 100, 200, 300, 400]);
    });

    test('takes in negative values', () {
      final scale = niceScale(-37, 82);
      expect(scale.min, -40);
      expect(scale.max, 100);
      expect(scale.step, 20);
      expect(scale.ticks.first, -40);
      expect(scale.ticks.last, 100);
      expect(scale.ticks, contains(0));
    });

    test('keeps decimals clean', () {
      final scale = niceScale(0, .93);
      expect(scale.ticks, [0, .2, .4, .6, .8, 1]);
    });

    test('widens a flat range', () {
      expect(niceScale(0, 0).max, 1);
      expect(niceScale(5, 5).min, 0);
      expect(niceScale(-5, -5).max, 0);
    });

    test('about the asked-for number of ticks', () {
      for (final (lo, hi) in [(0.0, 7.0), (0.0, 1234.0), (13.0, 977.0)]) {
        for (final count in [3, 5, 8]) {
          final ticks = niceScale(lo, hi, count: count).ticks;
          expect(
            ticks.length,
            inInclusiveRange(2, count * 2 + 1),
            reason: '$lo…$hi, $count',
          );
        }
      }
    });

    test('inner ticks stay inside the range', () {
      expect(innerTicks(3, 97), [20, 40, 60, 80]);
      expect(innerTicks(0, 1), [0, .2, .4, .6, .8, 1]);
    });
  });

  group('the line through the points', () {
    test('a monotone curve never overshoots its points', () {
      const points = [
        Offset(0, 100),
        Offset(50, 20),
        Offset(100, 20),
        Offset(150, 90),
        Offset(200, 10),
      ];
      final path = chartLinePath(points, LineInterpolation.monotone);
      final bounds = path.getBounds();
      // The control points of the cubics stay inside the data's own box,
      // so the curve does too.
      expect(bounds.top, greaterThanOrEqualTo(10 - 1e-6));
      expect(bounds.bottom, lessThanOrEqualTo(100 + 1e-6));
      // And it is flat between two equal values.
      final metric = path.computeMetrics().first;
      for (var d = 0.0; d < metric.length; d += 2) {
        final p = metric.getTangentForOffset(d)!.position;
        if (p.dx > 50 && p.dx < 100) expect(p.dy, closeTo(20, .01));
      }
    });
  });

  group('ChartTheme', () {
    test('draws with the scheme', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final chart = theme.chartTheme;
        expect(chart.gridColor, theme.colorScheme.border);
        expect(chart.palette, isNull);
        expect(chart.cursorColor, theme.colorScheme.borderStrong);
        expect(chart.tooltipDecoration?.color, isNotNull);
        expect(chart.axisTextStyle?.color, theme.colorScheme.mutedForeground);
      }
    });

    test('square styles draw square bars', () {
      expect(ThemeData(style: StyleTokens.sharp).chartTheme.barRadius, 0);
      expect(
        ThemeData(style: StyleTokens.fluid).chartTheme.barRadius,
        greaterThan(0),
      );
    });

    test('two builds of a theme are equal, palette and all', () {
      expect(ThemeData().chartTheme, ThemeData().chartTheme);
      ChartTheme build() => ChartTheme(
        palette: [
          for (final c in [0xff112233]) Color(c),
        ],
      );
      expect(build(), build());
      expect(build().hashCode, build().hashCode);
      expect(
        ThemeData(chartTheme: build()),
        ThemeData(chartTheme: build()),
      );
    });

    test('a palette colours the series in order', () {
      const red = Color(0xffff0000);
      const blue = Color(0xff0000ff);
      final theme = ThemeData(
        chartTheme: const ChartTheme(palette: [red, blue]),
      );
      expect(chartColor(theme, _series[0], 0), red);
      expect(chartColor(theme, _series[1], 1), blue);
      expect(chartColor(theme, _series[0], 2), red);
      expect(
        chartColor(
          theme,
          const ChartSeries(label: 'x', values: [], color: blue),
          0,
        ),
        blue,
      );
      expect(
        chartColor(ThemeData(), _series[1], 1),
        ThemeData().colorScheme.chart2,
      );
    });
  });

  group('layout', () {
    testWidgets('fills its width and takes the theme height when open', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: LineChart(labels: _labels, series: _series),
          ),
        ),
      );
      expect(tester.getSize(find.byType(LineChart)), const Size(420, 240));
    });

    testWidgets('fills a bounded height', (tester) async {
      await pumpUna(
        tester,
        _sized(const BarChart(labels: _labels, series: _series), height: 180),
      );
      expect(tester.getSize(find.byType(BarChart)), const Size(600, 180));
    });

    testWidgets('a donut is square', (tester) async {
      await pumpUna(
        tester,
        _sized(const DonutChart(segments: _segments), height: 200),
      );
      expect(
        tester.getSize(
          find
              .descendant(
                of: find.byType(DonutChart),
                matching: find.byType(SizedBox),
              )
              .first,
        ),
        const Size(200, 200),
      );
    });

    testWidgets('a sparkline takes its own size in a row', (tester) async {
      await pumpUna(
        tester,
        const Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Sparkline(values: [1, 3, 2, 5]),
            ],
          ),
        ),
      );
      final theme = ThemeData();
      expect(
        tester.getSize(find.byType(Sparkline)),
        theme.chartTheme.sparklineSize,
      );
    });

    testWidgets('survives every layout, narrow and wide', (tester) async {
      for (final width in [120.0, 360.0, 900.0]) {
        await expectBuildsInEveryLayout(
          tester,
          (_) => SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: const Column(
                  children: [
                    LineChart(labels: _labels, series: _series, area: true),
                    BarChart(labels: _labels, series: _series, stacked: true),
                    BarChart(
                      labels: _labels,
                      series: _series,
                      direction: Axis.horizontal,
                    ),
                    DonutChart(segments: _segments, center: Text('600')),
                    ChartLegend(entries: _series),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });

    testWidgets('an empty chart builds', (tester) async {
      await pumpUna(
        tester,
        const Column(
          children: [
            SizedBox(
              width: 300,
              child: LineChart(labels: [], series: []),
            ),
            SizedBox(
              width: 300,
              child: BarChart(labels: [], series: []),
            ),
            SizedBox(width: 120, child: DonutChart(segments: [])),
            Sparkline(values: []),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('the tooltip', () {
    testWidgets('follows the pointer from point to point', (tester) async {
      await pumpUna(
        tester,
        _sized(const LineChart(labels: _labels, series: _series)),
      );
      await _settleChart(tester);
      expect(find.text('305'), findsNothing);

      final rect = tester.getRect(find.byType(LineChart));
      final mouse = await _mouse(tester);
      // The second of six points, along a plot that starts after the
      // y labels.
      await mouse.moveTo(Offset(rect.left + rect.width * .25, rect.center.dy));
      await tester.pump();
      expect(find.text('Feb'), findsWidgets);
      expect(find.text('305'), findsOneWidget);
      expect(find.text('200'), findsWidgets);

      await mouse.moveTo(Offset(rect.right - 4, rect.center.dy));
      await tester.pump();
      expect(find.text('214'), findsOneWidget);
      expect(find.text('305'), findsNothing);

      await mouse.moveTo(const Offset(-10, -10));
      await tester.pump();
      expect(find.text('214'), findsNothing);
    });

    testWidgets('formats values with valueFormatter', (tester) async {
      await pumpUna(
        tester,
        _sized(
          BarChart(
            labels: _labels,
            series: _series,
            valueFormatter: (v) => '\$${v.round()}',
          ),
        ),
      );
      await _settleChart(tester);
      final rect = tester.getRect(find.byType(BarChart));
      final mouse = await _mouse(tester);
      await mouse.moveTo(Offset(rect.right - 10, rect.center.dy));
      await tester.pump();
      expect(find.text(r'$214'), findsOneWidget);
      expect(find.text(r'$140'), findsOneWidget);
    });

    testWidgets('a touch shows it until a tap elsewhere', (tester) async {
      await pumpUna(
        tester,
        Column(
          children: [
            _sized(const BarChart(labels: _labels, series: _series)),
            const SizedBox(width: 50, height: 50),
          ],
        ),
      );
      await _settleChart(tester);
      final rect = tester.getRect(find.byType(BarChart));
      await tester.tapAt(Offset(rect.right - 10, rect.center.dy));
      await tester.pump();
      expect(find.text('214'), findsOneWidget);
      await tester.tapAt(Offset(rect.left + 5, rect.bottom + 25));
      await tester.pump();
      expect(find.text('214'), findsNothing);
    });

    testWidgets('a donut names the segment under the pointer', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _sized(const DonutChart(segments: _segments), width: 300, height: 300),
      );
      await _settleChart(tester);
      final rect = tester.getRect(find.byType(DonutChart));
      final side = math.min(rect.width, rect.height);
      final mouse = await _mouse(tester);
      // Chrome is the first 46% of the ring, clockwise from the top: a
      // point to the right of the centre, on the ring.
      final center = rect.topLeft + Offset(side / 2, side / 2);
      await mouse.moveTo(center + Offset(side * .4, 0));
      await tester.pump();
      expect(find.text('Chrome'), findsOneWidget);
      expect(find.text('275'), findsOneWidget);
      // The hole is no segment.
      await mouse.moveTo(center);
      await tester.pump();
      expect(find.text('Chrome'), findsNothing);
    });
  });

  group('the keyboard', () {
    Future<void> focusChart(WidgetTester tester) async {
      tester.binding.focusManager.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => tester.binding.focusManager.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }

    testWidgets('Tab shows the first point; the arrows step', (tester) async {
      await pumpUna(
        tester,
        _sized(const LineChart(labels: _labels, series: _series)),
      );
      await _settleChart(tester);
      await focusChart(tester);
      expect(find.text('186'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('305'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(find.text('214'), findsOneWidget);
      // It stops at the end.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('214'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(find.text('186'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.text('186'), findsNothing);
    });

    testWidgets('the arrows follow a right-to-left reading direction', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _sized(const BarChart(labels: _labels, series: _series)),
        textDirection: TextDirection.rtl,
      );
      await _settleChart(tester);
      await focusChart(tester);
      expect(find.text('186'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(find.text('186'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(find.text('305'), findsOneWidget);
    });

    testWidgets('horizontal bars step up and down', (tester) async {
      await pumpUna(
        tester,
        _sized(
          const BarChart(
            labels: _labels,
            series: _series,
            direction: Axis.horizontal,
          ),
        ),
      );
      await _settleChart(tester);
      await focusChart(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(find.text('305'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(find.text('186'), findsOneWidget);
    });

    testWidgets('Escape with nothing shown is left to the page', (
      tester,
    ) async {
      var escaped = 0;
      await pumpUna(
        tester,
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              escaped++;
            }
            return KeyEventResult.ignored;
          },
          child: _sized(const LineChart(labels: _labels, series: _series)),
        ),
      );
      await focusChart(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(escaped, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      expect(escaped, 1);
    });
  });

  group('semantics', () {
    testWidgets('reads the chart and steps through it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        _sized(const LineChart(labels: _labels, series: _series)),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Line chart'));
      expect(node.label, 'Line chart');
      expect(node.value, '6 points, Jan to Jun');
      expect(node.increasedValue, 'Jan: Desktop 186, Mobile 80');
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.increase),
        isTrue,
      );

      tester.semantics.performAction(
        find.semantics.byLabel('Line chart'),
        SemanticsAction.increase,
      );
      await tester.pump();
      final stepped = tester.getSemantics(
        find.bySemanticsLabel('Line chart'),
      );
      expect(stepped.value, 'Jan: Desktop 186, Mobile 80');
      expect(stepped.increasedValue, 'Feb: Desktop 305, Mobile 200');
      handle.dispose();
    });

    testWidgets('a donut gives each share', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        _sized(
          const DonutChart(segments: _segments, semanticLabel: 'Browsers'),
          height: 200,
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Browsers'));
      expect(node.label, 'Browsers');
      expect(node.value, contains('Chrome: 275 (46%)'));
      handle.dispose();
    });

    testWidgets('a sparkline reads its ends', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(
          child: Sparkline(values: [12, 18, 31], semanticLabel: 'Visitors'),
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('Visitors'));
      expect(node.label, 'Visitors');
      expect(node.value, '3 points, 12 to 31');
      handle.dispose();
    });
  });

  group('motion', () {
    testWidgets('a frame of the entrance builds nothing', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UnaApp(
          formFactor: FormFactor.desktop,
          home: _sized(
            const Column(
              children: [
                Expanded(
                  child: LineChart(labels: _labels, series: _series),
                ),
                Expanded(
                  child: BarChart(labels: _labels, series: _series),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.binding.hasScheduledFrame, isTrue);

      var builds = 0;
      final painted = <String>[];
      debugOnRebuildDirtyWidget = (element, builtOnce) => builds++;
      debugOnProfilePaint = (object) {
        if (object.isRepaintBoundary && !object.debugNeedsPaint) return;
        painted.add('${object.runtimeType}');
      };
      addTearDown(() {
        debugOnRebuildDirtyWidget = null;
        debugOnProfilePaint = null;
      });
      await tester.pump(const Duration(milliseconds: 50));
      debugOnRebuildDirtyWidget = null;
      debugOnProfilePaint = null;

      expect(builds, 0);
      expect(painted, ['RenderCustomPaint', 'RenderCustomPaint']);
    });

    testWidgets('values grow from the baseline and settle', (tester) async {
      await pumpUna(
        tester,
        _sized(const BarChart(labels: _labels, series: _series)),
        // pumpUna settles for 500 ms; start the clock again.
      );
      // A new chart: rebuild with another key.
      await tester.pumpWidget(
        UnaApp(
          formFactor: FormFactor.desktop,
          home: _sized(
            const BarChart(
              key: Key('again'),
              labels: _labels,
              series: _series,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isTrue);
      await _settleChart(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a change of data moves, and the same data does not', (
      tester,
    ) async {
      Widget chart(List<double> values) => UnaApp(
        formFactor: FormFactor.desktop,
        home: _sized(
          LineChart(
            labels: _labels,
            series: [ChartSeries(label: 'A', values: values)],
          ),
        ),
      );
      await tester.pumpWidget(chart([1, 2, 3, 4, 5, 6]));
      await _settleChart(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.hasScheduledFrame, isFalse);

      // Equal, but a new list: nothing to animate.
      await tester.pumpWidget(chart([1, 2, 3, 4, 5, 6]));
      expect(tester.binding.hasScheduledFrame, isFalse);

      await tester.pumpWidget(chart([6, 5, 4, 3, 2, 1]));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('reduced motion shows the values at once', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UnaApp(
          formFactor: FormFactor.desktop,
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: _sized(
              const Column(
                children: [
                  Expanded(
                    child: LineChart(labels: _labels, series: _series),
                  ),
                  Expanded(child: DonutChart(segments: _segments)),
                  Sparkline(values: [1, 2, 3]),
                ],
              ),
            ),
          ),
        ),
      );
      await settle(tester);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group('right to left', () {
    testWidgets('the first category is on the right', (tester) async {
      await pumpUna(
        tester,
        _sized(const BarChart(labels: _labels, series: _series)),
        textDirection: TextDirection.rtl,
      );
      await _settleChart(tester);
      final rect = tester.getRect(find.byType(BarChart));
      final mouse = await _mouse(tester);
      // The value labels are on the right now, so a little way in.
      await mouse.moveTo(Offset(rect.right - 60, rect.center.dy));
      await tester.pump();
      expect(find.text('186'), findsOneWidget);
      await mouse.moveTo(Offset(rect.left + 20, rect.center.dy));
      await tester.pump();
      expect(find.text('214'), findsOneWidget);
    });
  });

  group('donut segments', () {
    test('stay inside the ring', () {
      const center = Offset(100, 100);
      final path = donutSegmentPath(
        center: center,
        inner: 50,
        outer: 90,
        start: -math.pi / 2,
        sweep: 1.2,
        gap: 2,
        corner: 6,
      )!;
      expect(path.contains(const Offset(150, 9)), isFalse);
      expect(path.contains(const Offset(99, 30)), isFalse);
      // The gap keeps the start edge off the radius it starts from.
      expect(path.contains(const Offset(100.5, 30)), isFalse);
      expect(path.contains(const Offset(130, 25)), isTrue);
    });

    test('a sliver the gap swallows is not drawn', () {
      expect(
        donutSegmentPath(
          center: Offset.zero,
          inner: 50,
          outer: 90,
          start: 0,
          sweep: .01,
          gap: 4,
          corner: 4,
        ),
        isNull,
      );
    });

    test('a pie has no hole', () {
      final path = donutSegmentPath(
        center: const Offset(100, 100),
        inner: 0,
        outer: 90,
        start: 0,
        sweep: math.pi / 2,
        gap: 2,
        corner: 4,
      )!;
      expect(path.contains(const Offset(110, 110)), isTrue);
    });
  });

  testWidgets('a chart given no width says so', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final onError = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await tester.pumpWidget(
        const UnaApp(
          home: Row(
            children: [LineChart(labels: _labels, series: _series)],
          ),
        ),
      );
    } finally {
      FlutterError.onError = onError;
    }
    expect('${errors.first.exception}', contains('unbounded width'));
  });

  testWidgets('the legend names every entry', (tester) async {
    await pumpUna(tester, const Center(child: ChartLegend(entries: _series)));
    expect(find.text('Desktop'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
  });
}
