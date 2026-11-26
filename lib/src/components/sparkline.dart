import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/chart_data.dart';
import 'package:una/src/components/chart_support.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/spring.dart';

/// A small line, with no axes, that shows the shape of a series beside a
/// number: a stat tile's trend, a row of a table.
///
/// ```dart
/// StatTile(
///   value: const Text('2,350'),
///   label: const Text('Visitors'),
///   trailing: const Sparkline(values: [12, 18, 15, 22, 19, 28, 31]),
/// )
/// ```
///
/// The line spans the lowest to the highest value, so a small change shows;
/// [area] fades its colour down to the bottom. It takes the first colour of
/// the theme's chart palette unless given a [color].
///
/// It is `ChartTheme.sparklineSize` (96 × 32) unless its parent holds it to
/// a width or a height (a `SizedBox`, an `Expanded`). The
/// line grows from the bottom when it first appears and moves to new
/// values on the theme's motion. It has no tooltip: what it reads as is
/// [semanticLabel] and the first and last value.
class Sparkline extends StatefulWidget {
  /// Creates a sparkline of [values].
  const Sparkline({
    required this.values,
    this.color,
    this.area = true,
    this.interpolation = LineInterpolation.monotone,
    this.valueFormatter,
    this.semanticLabel,
    super.key,
  });

  /// The values, oldest first.
  final List<double> values;

  /// The colour of the line. Defaults to the palette's first.
  final Color? color;

  /// Whether the area under the line is filled, fading to nothing at the
  /// bottom.
  final bool area;

  /// How the line joins its points.
  final LineInterpolation interpolation;

  /// Writes a value for assistive technology.
  final ChartValueFormatter? valueFormatter;

  /// What the line shows, for assistive technology. Defaults to
  /// "Sparkline".
  final String? semanticLabel;

  @override
  State<Sparkline> createState() => _SparklineState();
}

class _SparklineState extends State<Sparkline>
    with SingleTickerProviderStateMixin {
  late final _progress = SpringController(vsync: this);
  List<double> _from = const [];
  late List<double> _to = List.of(widget.values);
  ({double min, double max})? _fromRange;
  bool _entered = false;

  static ({double min, double max}) _rangeOf(List<double> values) {
    if (values.isEmpty) return (min: 0, max: 1);
    var min = values.reduce(math.min);
    var max = values.reduce(math.max);
    if (min == max) {
      min -= 1;
      max += 1;
    }
    return (min: min, max: max);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entered) return;
    _entered = true;
    final range = _rangeOf(_to);
    _from = List.filled(_to.length, range.min);
    _fromRange = range;
    _progress.animateTo(1, spring: Motion.of(context).smooth.scaled(2));
  }

  @override
  void didUpdateWidget(Sparkline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(widget.values, oldWidget.values)) return;
    final t = _progress.value;
    final fromRange = _fromRange ?? _rangeOf(_to);
    final toRange = _rangeOf(_to);
    final range = (
      min: ui.lerpDouble(fromRange.min, toRange.min, t)!,
      max: ui.lerpDouble(fromRange.max, toRange.max, t)!,
    );
    final next = List<double>.of(widget.values);
    _from = [
      for (var i = 0; i < next.length; i++) _lerp(_from, _to, i, t, range.min),
    ];
    _fromRange = range;
    _to = next;
    _progress
      ..jumpTo(0)
      ..animateTo(1, spring: Motion.of(context).smooth);
  }

  static double _lerp(
    List<double> from,
    List<double> to,
    int i,
    double t,
    double fallback,
  ) {
    final a = i < from.length ? from[i] : fallback;
    final b = i < to.length ? to[i] : fallback;
    return a + (b - a) * t;
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final chart = theme.chartTheme;
    final strings = UnaLocalizations.of(context);
    final numbers = ChartNumbers.of(context);
    String format(double v) =>
        widget.valueFormatter?.call(v) ?? numbers.value(v);
    final values = widget.values;
    final color =
        widget.color ??
        (chart.palette ?? theme.colorScheme.charts).firstOrNull ??
        theme.colorScheme.primary;
    final fallback = chart.sparklineSize ?? const Size(96, 32);
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? strings.chart.sparkline,
      value: values.isEmpty
          ? null
          : strings.chart.range(
              count: values.length,
              first: format(values.first),
              last: format(values.last),
            ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Its own size, unless the parent holds it to one.
          final size = constraints.constrain(
            Size(
              constraints.hasTightWidth ? constraints.maxWidth : fallback.width,
              constraints.hasTightHeight
                  ? constraints.maxHeight
                  : fallback.height,
            ),
          );
          return SizedBox.fromSize(
            size: size,
            // Painted, not built: the entrance repaints this layer only.
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _SparklinePainter(
                  progress: _progress.animation,
                  from: _from,
                  to: _to,
                  fromRange: _fromRange ?? _rangeOf(_to),
                  toRange: _rangeOf(_to),
                  color: color,
                  lineWidth: chart.sparklineLineWidth ?? 1.5,
                  areaOpacity: chart.areaOpacity ?? .3,
                  area: widget.area,
                  interpolation: widget.interpolation,
                  rtl: Directionality.of(context) == TextDirection.rtl,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.progress,
    required this.from,
    required this.to,
    required this.fromRange,
    required this.toRange,
    required this.color,
    required this.lineWidth,
    required this.areaOpacity,
    required this.area,
    required this.interpolation,
    required this.rtl,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<double> from;
  final List<double> to;
  final ({double min, double max}) fromRange;
  final ({double min, double max}) toRange;
  final Color color;
  final double lineWidth;
  final double areaOpacity;
  final bool area;
  final LineInterpolation interpolation;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (to.isEmpty) return;
    final t = progress.value;
    final min = ui.lerpDouble(fromRange.min, toRange.min, t)!;
    final max = ui.lerpDouble(fromRange.max, toRange.max, t)!;
    // The line's own width is kept inside the box, so neither its peaks nor
    // its ends are cut off.
    final inset = lineWidth / 2 + .5;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      math.max(inset, size.width - inset),
      math.max(inset, size.height - inset),
    );
    final n = to.length;
    final points = [
      for (var i = 0; i < n; i++)
        () {
          final v = _SparklineState._lerp(from, to, i, t, min);
          final f = max == min ? .5 : (v - min) / (max - min);
          final x = n == 1
              ? rect.center.dx
              : rect.left + rect.width * i / (n - 1);
          return Offset(
            rtl ? size.width - x : x,
            rect.bottom - f.clamp(0.0, 1.0) * rect.height,
          );
        }(),
    ];
    final line = chartLinePath(points, interpolation);
    if (area && n > 1) {
      final fill = Path.from(line)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            Offset(0, size.height),
            [
              color.withValues(alpha: color.a * areaOpacity),
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
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress ||
      old.from != from ||
      old.to != to ||
      old.fromRange != fromRange ||
      old.toRange != toRange ||
      old.color != color ||
      old.lineWidth != lineWidth ||
      old.areaOpacity != areaOpacity ||
      old.area != area ||
      old.interpolation != interpolation ||
      old.rtl != rtl;
}
