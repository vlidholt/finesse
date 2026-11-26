import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/chart_data.dart';
import 'package:una/src/components/chart_support.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/theme/color_scheme/base.dart';
import 'package:una/src/theme/components/chart.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/spring.dart';

// What `LineChart` and `BarChart` share: series over categories, a value
// axis with round ticks, gridlines, the tooltip and the keyboard, and the
// entrance and the change of data, painted from one spring.

/// What a [CartesianChart] draws.
@internal
enum CartesianKind {
  /// A line per series.
  line,

  /// A bar per series and category.
  bar,
}

/// A chart of series over categories: the state behind `LineChart` and
/// `BarChart`.
@internal
class CartesianChart extends StatefulWidget {
  /// Creates the chart.
  const CartesianChart({
    required this.kind,
    required this.series,
    required this.name,
    this.labels,
    this.xValues,
    this.valueFormatter,
    this.tickFormatter,
    this.xFormatter,
    this.minValue,
    this.maxValue,
    this.showGrid = true,
    this.showXAxis = true,
    this.showYAxis = true,
    this.semanticLabel,
    this.interpolation = LineInterpolation.monotone,
    this.area = false,
    this.dots = false,
    this.stacked = false,
    this.direction = Axis.vertical,
    super.key,
  });

  /// Lines or bars.
  final CartesianKind kind;

  /// The series.
  final List<ChartSeries> series;

  /// The widget's name, for error messages.
  final String name;

  /// A label per category.
  final List<String>? labels;

  /// A number per point, for a line chart over numbers.
  final List<double>? xValues;

  /// Writes a value.
  final ChartValueFormatter? valueFormatter;

  /// Writes a tick of the value axis.
  final ChartValueFormatter? tickFormatter;

  /// Writes an x value.
  final ChartValueFormatter? xFormatter;

  /// The lowest value of the value axis.
  final double? minValue;

  /// The highest value of the value axis.
  final double? maxValue;

  /// Whether gridlines are drawn at the value ticks.
  final bool showGrid;

  /// Whether the labels along the bottom are shown.
  final bool showXAxis;

  /// Whether the labels along the side are shown.
  final bool showYAxis;

  /// What the chart shows, for assistive technology.
  final String? semanticLabel;

  /// How a line joins its points.
  final LineInterpolation interpolation;

  /// Whether a line fills the area under it.
  final bool area;

  /// Whether a line marks each point with a dot.
  final bool dots;

  /// Whether a bar chart stacks its series.
  final bool stacked;

  /// The direction bars grow in.
  final Axis direction;

  /// How many points there are.
  int get count =>
      labels?.length ??
      xValues?.length ??
      series.fold(0, (n, s) => math.max(n, s.values.length));

  @override
  State<CartesianChart> createState() => _CartesianChartState();
}

/// A tick label, laid out, with the value or index it labels.
class _Label {
  _Label(this.painter, this.at);

  final TextPainter painter;

  /// The value (on the value axis) or the position (on the category axis)
  /// the label sits at.
  final double at;
}

/// Where everything goes, for one size and one set of data. Coordinates
/// are logical: left to right as in a left-to-right reading direction; the
/// painter mirrors them for a right-to-left one.
class _Geometry {
  _Geometry({
    required this.size,
    required this.plot,
    required this.positions,
    required this.band,
    required this.scale,
    required this.valueLabels,
    required this.categoryLabels,
    this.numeric,
  });

  final Size size;
  final Rect plot;

  /// Where each point sits along the category axis: an x for a line or a
  /// column chart, a y for a horizontal bar chart.
  final List<double> positions;

  /// The space each category has along the category axis (bars).
  final double band;

  final ChartScale scale;
  final List<_Label> valueLabels;
  final List<_Label> categoryLabels;

  /// For a line over numbers: the x range, and where its ends are drawn.
  final ({double min, double max, double start, double end})? numeric;

  /// The position along the category axis of x value [x], on a numeric
  /// axis.
  double numericPosition(double x) {
    final r = numeric!;
    final span = r.max - r.min;
    return span == 0
        ? r.start
        : r.start + (x - r.min) / span * (r.end - r.start);
  }

  void dispose() {
    for (final label in valueLabels) {
      label.painter.dispose();
    }
    for (final label in categoryLabels) {
      label.painter.dispose();
    }
  }
}

class _CartesianChartState extends State<CartesianChart>
    with SingleTickerProviderStateMixin {
  late final _progress = SpringController(vsync: this, value: 1);

  /// The values the change in flight starts from, and the scale it starts
  /// on.
  List<List<double>> _from = const [];
  ChartScale? _fromScale;

  /// The values and scale it heads for.
  List<List<double>> _to = const [];
  late ChartScale _scale;

  bool _entered = false;
  ChartActive? _active;

  _Geometry? _geometry;
  Object? _geometryKey;

  bool get _horizontalBars =>
      widget.kind == CartesianKind.bar && widget.direction == Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _to = _valuesOf(widget);
    _scale = _scaleOf(widget, tickCount: 5);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickCount = Theme.of(context).chartTheme.tickCount ?? 5;
    final scale = _scaleOf(widget, tickCount: tickCount);
    if (!_entered) {
      _entered = true;
      _scale = scale;
      // The entrance: every value grows from the baseline, on a spring
      // twice the length of a surface's, which reads as the data arriving
      // rather than a control responding.
      final baseline = _baseline(scale);
      _from = [
        for (final s in _to) List<double>.filled(s.length, baseline),
      ];
      _fromScale = scale;
      _progress.jumpTo(0);
      _progress.animateTo(1, spring: Motion.of(context).smooth.scaled(2));
    } else if (scale != _scale) {
      _retarget(_to, scale);
    }
  }

  @override
  void didUpdateWidget(CartesianChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        !listEquals(widget.series, oldWidget.series) ||
        widget.stacked != oldWidget.stacked ||
        widget.minValue != oldWidget.minValue ||
        widget.maxValue != oldWidget.maxValue;
    if (changed) {
      final tickCount = Theme.of(context).chartTheme.tickCount ?? 5;
      _retarget(_valuesOf(widget), _scaleOf(widget, tickCount: tickCount));
    }
    if (_active != null && _active!.index >= widget.count) _active = null;
  }

  /// Starts a change from what is on screen now to [values] on [scale].
  void _retarget(List<List<double>> values, ChartScale scale) {
    final t = _progress.value;
    final fromScale = _lerpScale(_fromScale ?? _scale, _scale, t);
    final baseline = _baseline(fromScale);
    _from = [
      for (var s = 0; s < values.length; s++)
        [
          for (var i = 0; i < values[s].length; i++)
            _lerpValue(_from, _to, s, i, t, baseline),
        ],
    ];
    _fromScale = fromScale;
    _to = values;
    _scale = scale;
    _progress.jumpTo(0);
    _progress.animateTo(1, spring: Motion.of(context).smooth);
  }

  static double _lerpValue(
    List<List<double>> from,
    List<List<double>> to,
    int s,
    int i,
    double t,
    double baseline,
  ) {
    double at(List<List<double>> values) =>
        s < values.length && i < values[s].length ? values[s][i] : baseline;
    final a = at(from);
    return a + (at(to) - a) * t;
  }

  static ChartScale _lerpScale(ChartScale a, ChartScale b, double t) {
    if (t >= 1) return b;
    return ChartScale(
      min: ui.lerpDouble(a.min, b.min, t)!,
      max: ui.lerpDouble(a.max, b.max, t)!,
      step: b.step,
      ticks: b.ticks,
    );
  }

  static double _baseline(ChartScale scale) => 0.0.clamp(scale.min, scale.max);

  static List<List<double>> _valuesOf(CartesianChart widget) => [
    for (final s in widget.series) List<double>.of(s.values),
  ];

  static ChartScale _scaleOf(CartesianChart widget, {required int tickCount}) {
    var lo = 0.0;
    var hi = 0.0;
    final count = widget.count;
    if (widget.kind == CartesianKind.bar && widget.stacked) {
      for (var i = 0; i < count; i++) {
        var up = 0.0;
        var down = 0.0;
        for (final s in widget.series) {
          if (i >= s.values.length) continue;
          final v = s.values[i];
          if (v >= 0) {
            up += v;
          } else {
            down += v;
          }
        }
        hi = math.max(hi, up);
        lo = math.min(lo, down);
      }
    } else {
      for (final s in widget.series) {
        for (final v in s.values) {
          hi = math.max(hi, v);
          lo = math.min(lo, v);
        }
      }
    }
    final minValue = widget.minValue;
    final maxValue = widget.maxValue;
    final nice = niceScale(minValue ?? lo, maxValue ?? hi, count: tickCount);
    if (minValue == null && maxValue == null) return nice;
    final min = minValue ?? nice.min;
    final max = maxValue ?? nice.max;
    return ChartScale(
      min: min,
      max: max,
      step: nice.step,
      ticks: [
        for (final t in nice.ticks)
          if (t >= min - 1e-9 && t <= max + 1e-9) t,
      ],
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    _geometry?.dispose();
    super.dispose();
  }

  String _formatValue(double v) =>
      widget.valueFormatter?.call(v) ?? ChartNumbers.of(context).value(v);

  String _title(int index) {
    final labels = widget.labels;
    if (labels != null && index < labels.length) return labels[index];
    final xs = widget.xValues;
    if (xs != null && index < xs.length) {
      return widget.xFormatter?.call(xs[index]) ??
          ChartNumbers.of(context).value(xs[index]);
    }
    return '${index + 1}';
  }

  String _describe(int index) {
    final values = [
      for (final s in widget.series)
        if (index < s.values.length)
          '${s.label} ${_formatValue(s.values[index])}',
    ];
    return '${_title(index)}: ${values.join(', ')}';
  }

  /// Lays out the axes and places the points for [size].
  _Geometry _layout(Size size, ThemeData theme) {
    final chart = theme.chartTheme;
    final count = widget.count;
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    final style = chart.axisTextStyle ?? theme.textTheme.caption;
    final gap = chart.axisGap ?? 8;
    final numbers = ChartNumbers.of(context);
    final scale = _scale;
    final largest = math.max(scale.max.abs(), scale.min.abs());

    TextPainter paint(String text, {double? maxWidth}) {
      return TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 1,
        ellipsis: maxWidth == null ? null : '…',
      )..layout(maxWidth: maxWidth ?? double.infinity);
    }

    final lineHeight = paint('0').height;

    // The value axis.
    final valueAxis = _horizontalBars ? widget.showXAxis : widget.showYAxis;
    final valueLabels = <_Label>[
      if (valueAxis)
        for (final tick in scale.ticks)
          _Label(
            paint(
              widget.tickFormatter?.call(tick) ??
                  numbers.tick(tick, scale.step, largest),
            ),
            tick,
          ),
    ];

    // The category axis: a label per category, or round numbers along a
    // numeric one.
    final categoryAxis = _horizontalBars ? widget.showYAxis : widget.showXAxis;
    final xValues = widget.kind == CartesianKind.line ? widget.xValues : null;
    final xMin = xValues == null || xValues.isEmpty
        ? 0.0
        : xValues.reduce(math.min);
    final xMax = xValues == null || xValues.isEmpty
        ? 0.0
        : xValues.reduce(math.max);
    final categoryTexts = <(String, double)>[
      if (categoryAxis)
        if (xValues != null)
          for (final x in innerTicks(xMin, xMax, count: 6))
            (widget.xFormatter?.call(x) ?? numbers.value(x), x)
        else
          for (var i = 0; i < count; i++) (_title(i), i.toDouble()),
    ];
    final categoryMaxWidth = _horizontalBars ? size.width * .4 : null;
    final categoryPainters = [
      for (final (text, at) in categoryTexts)
        _Label(paint(text, maxWidth: categoryMaxWidth), at),
    ];

    final dotPad = widget.kind == CartesianKind.line
        ? (chart.activeDotRadius ?? 4.5) + 2
        : 0.0;
    double widest(Iterable<_Label> labels) =>
        labels.fold(0, (w, l) => math.max(w, l.painter.width));

    final Rect plot;
    final List<double> positions;
    double band;
    ({double min, double max, double start, double end})? numeric;
    if (!_horizontalBars) {
      final left = valueLabels.isEmpty ? 0.0 : widest(valueLabels) + gap;
      final top = math.max(valueLabels.isEmpty ? 0.0 : lineHeight / 2, dotPad);
      final bottom = categoryPainters.isEmpty
          ? math.max(dotPad, valueLabels.isEmpty ? 0.0 : lineHeight / 2)
          : lineHeight + gap;
      var padStart = dotPad;
      var padEnd = dotPad;
      if (widget.kind == CartesianKind.line && categoryPainters.isNotEmpty) {
        // The first and last labels are centred on the ends of the line;
        // keep them inside the chart.
        final first = categoryPainters.first.painter.width / 2;
        final last = categoryPainters.last.painter.width / 2;
        padStart = math.max(padStart, first - left);
        padEnd = math.max(padEnd, last);
      }
      plot = Rect.fromLTRB(
        left,
        top,
        math.max(left, size.width),
        math.max(top, size.height - bottom),
      );
      if (widget.kind == CartesianKind.line) {
        final start = plot.left + padStart;
        final end = math.max(start, plot.right - padEnd);
        band = 0;
        if (xValues != null) {
          final span = xMax - xMin;
          numeric = (min: xMin, max: xMax, start: start, end: end);
          positions = [
            for (final x in xValues)
              start + (span == 0 ? 0 : (x - xMin) / span) * (end - start),
          ];
        } else {
          positions = [
            for (var i = 0; i < count; i++)
              start + (end - start) * (count == 1 ? .5 : i / (count - 1)),
          ];
        }
      } else {
        band = count == 0 ? 0 : plot.width / count;
        positions = [
          for (var i = 0; i < count; i++) plot.left + band * (i + .5),
        ];
      }
    } else {
      final left = categoryPainters.isEmpty
          ? 0.0
          : widest(categoryPainters) + gap;
      final bottom = valueLabels.isEmpty ? 0.0 : lineHeight + gap;
      final right = valueLabels.isEmpty
          ? 0.0
          : valueLabels.last.painter.width / 2;
      plot = Rect.fromLTRB(
        left,
        0,
        math.max(left, size.width - right),
        math.max(0, size.height - bottom),
      );
      band = count == 0 ? 0 : plot.height / count;
      positions = [for (var i = 0; i < count; i++) plot.top + band * (i + .5)];
    }

    // Along the bottom of a horizontal chart, the value labels sit side by
    // side: keep every other one, or fewer, until they no longer touch.
    var shownValueLabels = valueLabels;
    if (_horizontalBars && valueLabels.length > 1) {
      final spacing = plot.width / (scale.max - scale.min) * scale.step;
      final every = spacing <= 0
          ? valueLabels.length
          : ((widest(valueLabels) + gap) / spacing).ceil();
      if (every > 1) {
        shownValueLabels = [];
        for (final label in valueLabels) {
          // Counted from zero, so the baseline keeps its label.
          final step = ((label.at - scale.min) / scale.step).round();
          if (step % every == 0) {
            shownValueLabels.add(label);
          } else {
            label.painter.dispose();
          }
        }
      }
    }

    // Thin out the category labels until they no longer touch.
    var categoryLabels = categoryPainters;
    if (categoryLabels.length > 1) {
      final double spacing;
      final double extent;
      if (numeric != null) {
        final span = numeric.max - numeric.min;
        final step = categoryLabels[1].at - categoryLabels[0].at;
        spacing = span == 0
            ? double.infinity
            : step / span * (numeric.end - numeric.start);
        extent = widest(categoryLabels) + gap;
      } else if (_horizontalBars) {
        spacing = band;
        extent = lineHeight;
      } else {
        spacing = positions.length > 1
            ? positions[1] - positions[0]
            : plot.width;
        extent = widest(categoryLabels) + gap;
      }
      final every = spacing <= 0
          ? categoryLabels.length
          : (extent / spacing).ceil();
      if (every > 1) {
        final kept = <_Label>[];
        for (final (i, label) in categoryLabels.indexed) {
          if (i % every == 0) {
            kept.add(label);
          } else {
            label.painter.dispose();
          }
        }
        categoryLabels = kept;
      }
    }

    return _Geometry(
      size: size,
      plot: plot,
      positions: positions,
      band: band,
      scale: scale,
      valueLabels: shownValueLabels,
      categoryLabels: categoryLabels,
      numeric: numeric,
    );
  }

  _Geometry _geometryFor(Size size, ThemeData theme) {
    final key = (
      size,
      _scale,
      widget.kind,
      widget.direction,
      widget.showXAxis,
      widget.showYAxis,
      Object.hashAll(widget.labels ?? const []),
      Object.hashAll(widget.xValues ?? const []),
      widget.series.length,
      widget.count,
      theme.chartTheme,
      theme.textTheme.caption,
      MediaQuery.textScalerOf(context),
      Directionality.of(context),
      Localizations.maybeLocaleOf(context),
    );
    if (_geometry != null && key == _geometryKey) return _geometry!;
    _geometry?.dispose();
    _geometryKey = key;
    return _geometry = _layout(size, theme);
  }

  int? _indexAt(Offset position) {
    final geometry = _geometry;
    if (geometry == null || geometry.positions.isEmpty) return null;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final logical = rtl
        ? Offset(geometry.size.width - position.dx, position.dy)
        : position;
    final along = _horizontalBars ? logical.dy : logical.dx;
    if (widget.kind == CartesianKind.bar) {
      final start = _horizontalBars ? geometry.plot.top : geometry.plot.left;
      final end = _horizontalBars ? geometry.plot.bottom : geometry.plot.right;
      if (along < start || along > end || geometry.band <= 0) return null;
      return ((along - start) / geometry.band).floor().clamp(
        0,
        geometry.positions.length - 1,
      );
    }
    var best = 0;
    var bestDistance = double.infinity;
    for (final (i, x) in geometry.positions.indexed) {
      final d = (x - along).abs();
      if (d < bestDistance) {
        best = i;
        bestDistance = d;
      }
    }
    return best;
  }

  /// Where the tooltip points, in the chart's own coordinates.
  Offset? _anchor(ChartActive? active, _Geometry geometry) {
    if (active == null || active.index >= geometry.positions.length) {
      return null;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    double physicalX(double x) => rtl ? geometry.size.width - x : x;
    final i = active.index;
    final scale = geometry.scale;
    var top = 0.0;
    for (final s in _to) {
      if (i >= s.length) continue;
      if (widget.kind == CartesianKind.bar && widget.stacked) {
        if (s[i] >= 0) top += s[i];
      } else {
        top = math.max(top, s[i]);
      }
    }
    final extreme = scale.fraction(top.clamp(scale.min, scale.max));
    final pointer = active.pointer;
    final position = geometry.positions[i];
    if (_horizontalBars) {
      final x = geometry.plot.left + extreme * geometry.plot.width;
      return Offset(pointer?.dx ?? physicalX(x), position);
    }
    final y = geometry.plot.bottom - extreme * geometry.plot.height;
    return Offset(physicalX(position), pointer?.dy ?? y);
  }

  Widget? _tooltip(ThemeData theme) {
    final active = _active;
    if (active == null) return null;
    final i = active.index;
    return ChartTooltip(
      title: _title(i),
      rows: [
        for (final (s, series) in widget.series.indexed)
          if (i < series.values.length)
            (
              color: chartColor(theme, series, s),
              label: series.label,
              value: _formatValue(series.values[i]),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final chart = theme.chartTheme;
    final strings = UnaLocalizations.of(context);
    final count = widget.count;
    assert(
      widget.series.every((s) => s.values.length == count),
      '${widget.name}: every series has a value per x position ($count)',
    );
    final colors = [
      for (final (i, s) in widget.series.indexed) chartColor(theme, s, i),
    ];
    final label =
        widget.semanticLabel ??
        (widget.kind == CartesianKind.line
            ? strings.chart.line
            : strings.chart.bar);
    final summary = count == 0
        ? ''
        : strings.chart.range(
            count: count,
            first: _title(0),
            last: _title(count - 1),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = chartSize(constraints, chart.height ?? 240, widget.name);
        final geometry = _geometryFor(size, theme);
        return ChartInteraction(
          count: count,
          active: _active?.index,
          onActiveChanged: (active) => setState(() => _active = active),
          indexAt: _indexAt,
          describe: _describe,
          label: label,
          summary: summary,
          axis: _horizontalBars ? Axis.vertical : Axis.horizontal,
          borderRadius: theme.radii.md,
          child: SizedBox.fromSize(
            size: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  // Painted, not built: a frame of the entrance or of a
                  // change of data repaints this layer and nothing else.
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _CartesianPainter(
                        kind: widget.kind,
                        horizontal: _horizontalBars,
                        stacked: widget.stacked,
                        geometry: geometry,
                        progress: _progress.animation,
                        from: _from,
                        to: _to,
                        fromScale: _fromScale ?? _scale,
                        colors: colors,
                        theme: chart,
                        scheme: theme.colorScheme,
                        active: _active?.index,
                        showGrid: widget.showGrid,
                        interpolation: widget.interpolation,
                        area: widget.area,
                        dots: widget.dots,
                        textDirection: Directionality.of(context),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ChartTooltipLayer(
                    anchor: _anchor(_active, geometry),
                    // Bars keep the tooltip clear of their whole group; a
                    // line's point is a dot.
                    clearance:
                        widget.kind == CartesianKind.bar && !_horizontalBars
                        ? geometry.band / 2
                        : 0,
                    child: _tooltip(theme),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CartesianPainter extends CustomPainter {
  _CartesianPainter({
    required this.kind,
    required this.horizontal,
    required this.stacked,
    required this.geometry,
    required this.progress,
    required this.from,
    required this.to,
    required this.fromScale,
    required this.colors,
    required this.theme,
    required this.scheme,
    required this.active,
    required this.showGrid,
    required this.interpolation,
    required this.area,
    required this.dots,
    required this.textDirection,
  }) : super(repaint: progress);

  final CartesianKind kind;
  final bool horizontal;
  final bool stacked;
  final _Geometry geometry;
  final Animation<double> progress;
  final List<List<double>> from;
  final List<List<double>> to;
  final ChartScale fromScale;
  final List<Color> colors;
  final ChartTheme theme;
  final ColorScheme scheme;
  final int? active;
  final bool showGrid;
  final LineInterpolation interpolation;
  final bool area;
  final bool dots;
  final TextDirection textDirection;

  bool get _rtl => textDirection == TextDirection.rtl;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final g = geometry;
    final scale = t >= 1
        ? g.scale
        : ChartScale(
            min: ui.lerpDouble(fromScale.min, g.scale.min, t)!,
            max: ui.lerpDouble(fromScale.max, g.scale.max, t)!,
            step: g.scale.step,
            ticks: g.scale.ticks,
          );
    final baseline = 0.0.clamp(scale.min, scale.max);
    final values = [
      for (var s = 0; s < to.length; s++)
        [
          for (var i = 0; i < to[s].length; i++)
            _CartesianChartState._lerpValue(from, to, s, i, t, baseline),
        ],
    ];

    // Shapes are drawn in logical coordinates and mirrored for a
    // right-to-left reading direction; text is placed afterwards, the
    // right way round.
    canvas.save();
    if (_rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    if (showGrid) _paintGrid(canvas, scale);
    if (kind == CartesianKind.line) {
      _paintLines(canvas, values, scale, baseline);
    } else {
      _paintBars(canvas, values, scale, baseline);
    }
    canvas.restore();
    _paintLabels(canvas, scale);
  }

  /// The pixel along the value axis for [v], in logical coordinates.
  double _valuePixel(double v, ChartScale scale) {
    final f = scale.fraction(v);
    final plot = geometry.plot;
    return horizontal
        ? plot.left + f * plot.width
        : plot.bottom - f * plot.height;
  }

  void _paintGrid(Canvas canvas, ChartScale scale) {
    final plot = geometry.plot;
    final paint = Paint()
      ..color = theme.gridColor ?? scheme.border
      ..strokeWidth = theme.gridWidth ?? 1;
    for (final tick in geometry.scale.ticks) {
      if (tick < scale.min - 1e-9 || tick > scale.max + 1e-9) continue;
      // Snapped to the middle of a pixel row, so a hairline stays one.
      final p = _valuePixel(tick, scale);
      final at =
          (p * 2).round() / 2 + (paint.strokeWidth.round().isOdd ? .5 : 0);
      if (horizontal) {
        canvas.drawLine(Offset(at, plot.top), Offset(at, plot.bottom), paint);
      } else {
        canvas.drawLine(Offset(plot.left, at), Offset(plot.right, at), paint);
      }
    }
  }

  void _paintLines(
    Canvas canvas,
    List<List<double>> values,
    ChartScale scale,
    double baseline,
  ) {
    final g = geometry;
    final plot = g.plot;
    final lineWidth = theme.lineWidth ?? 2;
    final ring = theme.dotBorderColor ?? scheme.card;
    final active = this.active;

    if (active != null && active < g.positions.length) {
      final x = g.positions[active];
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = theme.cursorColor ?? scheme.borderStrong
          ..strokeWidth = theme.cursorWidth ?? 1,
      );
    }

    final baseY = _valuePixel(baseline, scale);
    final pointsOf = [
      for (final series in values)
        [
          for (var i = 0; i < series.length && i < g.positions.length; i++)
            Offset(g.positions[i], _valuePixel(series[i], scale)),
        ],
    ];

    // The first series is the one that matters most: it is drawn last, on
    // top of the others.
    for (var s = values.length - 1; s >= 0; s--) {
      final points = pointsOf[s];
      if (points.isEmpty) continue;
      final color = colors[s];
      final line = chartLinePath(points, interpolation);
      if (area && points.length > 1) {
        final top = points.fold(baseY, (y, p) => math.min(y, p.dy));
        final fill = Path.from(line)
          ..lineTo(points.last.dx, baseY)
          ..lineTo(points.first.dx, baseY)
          ..close();
        final opacity = theme.areaOpacity ?? .3;
        canvas.drawPath(
          fill,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, math.min(top, baseY - 1)),
              Offset(0, baseY),
              [
                color.withValues(alpha: color.a * opacity),
                color.withValues(alpha: 0),
              ],
            ),
        );
      }
      canvas.drawPath(
        line,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lineWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
      if (dots || points.length == 1) {
        final r = theme.dotRadius ?? 3;
        for (final p in points) {
          canvas
            ..drawCircle(p, r + 1.5, Paint()..color = ring)
            ..drawCircle(p, r, Paint()..color = color);
        }
      }
    }

    if (active != null) {
      final r = theme.activeDotRadius ?? 4.5;
      for (var s = values.length - 1; s >= 0; s--) {
        if (active >= pointsOf[s].length) continue;
        final p = pointsOf[s][active];
        canvas
          ..drawCircle(p, r + 2, Paint()..color = ring)
          ..drawCircle(p, r, Paint()..color = colors[s]);
      }
    }
  }

  void _paintBars(
    Canvas canvas,
    List<List<double>> values,
    ChartScale scale,
    double baseline,
  ) {
    final g = geometry;
    final plot = g.plot;
    final n = values.length;
    if (n == 0 || g.band <= 0) return;
    final categoryGap = (theme.categoryGap ?? .2).clamp(0.0, .95);
    final barGap = theme.barGap ?? 4;
    final maxBar = theme.maxBarThickness ?? 48;
    final radius = theme.barRadius ?? 0;
    final room = g.band * (1 - categoryGap);

    final active = this.active;
    if (active != null && active < g.positions.length) {
      // The category under the pointer sits on a soft band.
      final extent = math.min(g.band, room + g.band * categoryGap / 2);
      final c = g.positions[active];
      final rect = horizontal
          ? Rect.fromLTRB(plot.left, c - extent / 2, plot.right, c + extent / 2)
          : Rect.fromLTRB(
              c - extent / 2,
              plot.top,
              c + extent / 2,
              plot.bottom,
            );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = theme.highlightColor ?? scheme.muted,
      );
    }

    final double thickness;
    final double groupExtent;
    var gapBetween = barGap;
    if (stacked) {
      thickness = math.min(room, maxBar);
      groupExtent = thickness;
    } else {
      if ((room - gapBetween * (n - 1)) / n < 2) gapBetween = 0;
      thickness = math.min(maxBar, (room - gapBetween * (n - 1)) / n);
      groupExtent = thickness * n + gapBetween * (n - 1);
    }
    final base = _valuePixel(baseline, scale);

    void bar(double start, double from, double to, Color color, bool round) {
      // [from] and [to] are pixels along the value axis; [start] the
      // bar's leading edge along the category axis.
      final length = (to - from).abs();
      if (length < .01) return;
      final r = round
          ? Radius.circular(
              math.min(radius, math.min(thickness / 2, length)),
            )
          : Radius.zero;
      final RRect shape;
      if (horizontal) {
        final rect = Rect.fromLTRB(
          math.min(from, to),
          start,
          math.max(from, to),
          start + thickness,
        );
        final towardsEnd = to >= from;
        shape = RRect.fromRectAndCorners(
          rect,
          topRight: towardsEnd ? r : Radius.zero,
          bottomRight: towardsEnd ? r : Radius.zero,
          topLeft: towardsEnd ? Radius.zero : r,
          bottomLeft: towardsEnd ? Radius.zero : r,
        );
      } else {
        final rect = Rect.fromLTRB(
          start,
          math.min(from, to),
          start + thickness,
          math.max(from, to),
        );
        final up = to <= from;
        shape = RRect.fromRectAndCorners(
          rect,
          topLeft: up ? r : Radius.zero,
          topRight: up ? r : Radius.zero,
          bottomLeft: up ? Radius.zero : r,
          bottomRight: up ? Radius.zero : r,
        );
      }
      canvas.drawRRect(shape, Paint()..color = color);
    }

    for (var i = 0; i < g.positions.length; i++) {
      final groupStart = g.positions[i] - groupExtent / 2;
      if (stacked) {
        // The outermost bar of each direction rounds its end.
        var lastUp = -1;
        var lastDown = -1;
        for (var s = 0; s < n; s++) {
          if (i >= values[s].length) continue;
          if (values[s][i] > 0) lastUp = s;
          if (values[s][i] < 0) lastDown = s;
        }
        var up = baseline;
        var down = baseline;
        for (var s = 0; s < n; s++) {
          if (i >= values[s].length) continue;
          final v = values[s][i];
          if (v >= 0) {
            bar(
              groupStart,
              _valuePixel(up, scale),
              _valuePixel(up + v, scale),
              colors[s],
              s == lastUp,
            );
            up += v;
          } else {
            bar(
              groupStart,
              _valuePixel(down, scale),
              _valuePixel(down + v, scale),
              colors[s],
              s == lastDown,
            );
            down += v;
          }
        }
      } else {
        for (var s = 0; s < n; s++) {
          if (i >= values[s].length) continue;
          bar(
            groupStart + s * (thickness + gapBetween),
            base,
            _valuePixel(values[s][i], scale),
            colors[s],
            true,
          );
        }
      }
    }
  }

  void _paintLabels(Canvas canvas, ChartScale scale) {
    final g = geometry;
    final plot = g.plot;
    final gap = theme.axisGap ?? 8;
    final width = g.size.width;

    // Places [painter] with its [align]ment point (logical) at [x], [y];
    // mirrored for a right-to-left reading direction.
    void place(TextPainter painter, double x, double y, double align) {
      final physicalX = _rtl ? width - x : x;
      final physicalAlign = _rtl ? 1 - align : align;
      var left = physicalX - painter.width * physicalAlign;
      left = left.clamp(0, math.max(0, width - painter.width)).toDouble();
      painter.paint(canvas, Offset(left, y));
    }

    for (final label in g.valueLabels) {
      final v = label.at;
      if (v < scale.min - 1e-9 || v > scale.max + 1e-9) continue;
      final p = _valuePixel(v, scale);
      final painter = label.painter;
      if (horizontal) {
        place(painter, p, plot.bottom + gap, .5);
      } else {
        place(painter, plot.left - gap, p - painter.height / 2, 1);
      }
    }

    for (final label in g.categoryLabels) {
      final painter = label.painter;
      final double position;
      if (g.numeric != null) {
        position = g.numericPosition(label.at);
      } else {
        final i = label.at.round();
        if (i >= g.positions.length) continue;
        position = g.positions[i];
      }
      if (horizontal) {
        place(painter, plot.left - gap, position - painter.height / 2, 1);
      } else {
        place(painter, position, plot.bottom + gap, .5);
      }
    }
  }

  @override
  bool shouldRepaint(_CartesianPainter old) =>
      old.geometry != geometry ||
      old.progress != progress ||
      old.from != from ||
      old.to != to ||
      old.fromScale != fromScale ||
      !listEquals(old.colors, colors) ||
      old.theme != theme ||
      old.scheme != scheme ||
      old.active != active ||
      old.showGrid != showGrid ||
      old.interpolation != interpolation ||
      old.area != area ||
      old.dots != dots ||
      old.textDirection != textDirection;
}
