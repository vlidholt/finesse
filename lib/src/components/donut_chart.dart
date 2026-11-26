import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/chart_data.dart';
import 'package:una/src/components/chart_support.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/theme/color_scheme/base.dart';
import 'package:una/src/theme/components/chart.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/spring.dart';

/// Parts of a whole as segments of a ring, with an optional label in the
/// middle: a share of traffic, a budget, a breakdown.
///
/// ```dart
/// DonutChart(
///   segments: const [
///     ChartSegment(label: 'Chrome', value: 275),
///     ChartSegment(label: 'Safari', value: 200),
///     ChartSegment(label: 'Firefox', value: 187),
///   ],
///   center: const Text('662'),
/// )
/// ```
///
/// Each segment takes its share of the sum of all of them, clockwise from
/// the top, and the next colour of the theme's chart palette unless it
/// names its own. Segments are parted by a small gap and their corners
/// rounded, by `ChartTheme.segmentGap` and `segmentRadius`. A [holeRatio]
/// of 0 makes a pie.
///
/// Hovering or touching a segment pulls it out of the ring and shows its
/// label and value in a tooltip. With the keyboard focus the arrow keys
/// step from segment to segment; assistive technology reads each segment's
/// value and share.
///
/// The ring sweeps round when the chart first appears, and a change of data
/// moves each segment to its new share, on the theme's motion.
///
/// The chart is square: as large as the side it is held to (a `SizedBox`
/// of a height, an `Expanded`) allows, and otherwise `ChartTheme.height`
/// (240), or less where there is less room.
class DonutChart extends StatefulWidget {
  /// Creates a donut of [segments].
  const DonutChart({
    required this.segments,
    this.center,
    this.holeRatio,
    this.valueFormatter,
    this.semanticLabel,
    super.key,
  }) : assert(
         holeRatio == null || (holeRatio >= 0 && holeRatio < 1),
         'holeRatio is a fraction of the radius, from 0 up to 1',
       );

  /// The segments, clockwise from the top.
  final List<ChartSegment> segments;

  /// A widget in the hole: a total, a label. Its text defaults to the
  /// foreground colour; it is given the largest square the hole holds.
  final Widget? center;

  /// The radius of the hole as a fraction of the chart's: 0 is a pie.
  /// Defaults to `ChartTheme.holeRatio` (0.6).
  final double? holeRatio;

  /// Writes a value for the tooltip and assistive technology. Defaults to
  /// the locale's number format, to two decimals.
  final ChartValueFormatter? valueFormatter;

  /// What the chart shows, for assistive technology. Defaults to "Donut
  /// chart".
  final String? semanticLabel;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with TickerProviderStateMixin {
  /// The sweep of the ring: 0 to 1 as it first appears.
  late final _sweep = SpringController(vsync: this);

  /// A change of data, from [_from] to [_to].
  late final _change = SpringController(vsync: this, value: 1);

  /// How far the active segment has come out of the ring.
  late final _grow = SpringController(vsync: this);

  late final _repaint = Listenable.merge([
    _sweep.animation,
    _change.animation,
    _grow.animation,
  ]);

  List<double> _from = const [];
  late List<double> _to = _valuesOf(widget);
  bool _entered = false;
  ChartActive? _active;

  static List<double> _valuesOf(DonutChart widget) => [
    for (final s in widget.segments) s.value,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entered) return;
    _entered = true;
    _from = _to;
    _sweep.animateTo(1, spring: Motion.of(context).smooth.scaled(2));
  }

  @override
  void didUpdateWidget(DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_active != null && _active!.index >= widget.segments.length) {
      _active = null;
    }
    if (listEquals(widget.segments, oldWidget.segments)) return;
    final next = _valuesOf(widget);
    if (listEquals(next, _to)) return;
    final t = _change.value;
    _from = [
      for (var i = 0; i < next.length; i++) _lerp(_from, _to, i, t),
    ];
    _to = next;
    _change
      ..jumpTo(0)
      ..animateTo(1, spring: Motion.of(context).smooth);
  }

  static double _lerp(List<double> from, List<double> to, int i, double t) {
    final a = i < from.length ? from[i] : 0.0;
    final b = i < to.length ? to[i] : 0.0;
    return a + (b - a) * t;
  }

  @override
  void dispose() {
    _sweep.dispose();
    _change.dispose();
    _grow.dispose();
    super.dispose();
  }

  void _setActive(ChartActive? active) {
    final changed = active?.index != _active?.index;
    setState(() => _active = active);
    if (changed && active != null) {
      _grow
        ..jumpTo(0)
        ..animateTo(1, spring: Motion.of(context).snappy);
    }
  }

  double get _total => _to.fold(0, (sum, v) => sum + v);

  String _format(double v) =>
      widget.valueFormatter?.call(v) ?? ChartNumbers.of(context).value(v);

  String _percent(int index) {
    final total = _total;
    if (total <= 0) return '0%';
    return '${(_to[index] / total * 100).round()}%';
  }

  String _describe(int index) {
    final segment = widget.segments[index];
    return '${segment.label}: ${_format(segment.value)} (${_percent(index)})';
  }

  /// The geometry of the ring in a square of [side].
  ({Offset center, double outer, double inner}) _ring(
    double side,
    ChartTheme chart,
  ) {
    final growth = chart.activeSegmentGrowth ?? 6;
    final outer = math.max(0, side / 2 - growth).toDouble();
    final ratio = widget.holeRatio ?? chart.holeRatio ?? .6;
    return (
      center: Offset(side / 2, side / 2),
      outer: outer,
      inner: outer * ratio,
    );
  }

  int? _indexAt(Offset position, double side, ChartTheme chart) {
    final ring = _ring(side, chart);
    final d = position - ring.center;
    final distance = d.distance;
    final growth = chart.activeSegmentGrowth ?? 6;
    if (distance > ring.outer + growth || distance < ring.inner * .8) {
      return null;
    }
    final total = _total;
    if (total <= 0) return null;
    // Clockwise from the top, from 0 to one turn.
    var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (angle < 0) angle += math.pi * 2;
    final at = angle / (math.pi * 2) * total;
    var sum = 0.0;
    for (final (i, v) in _to.indexed) {
      sum += v;
      if (at <= sum && v > 0) return i;
    }
    return _to.length - 1;
  }

  Offset? _anchor(double side, ChartTheme chart) {
    final active = _active;
    if (active == null) return null;
    final pointer = active.pointer;
    if (pointer != null) return pointer;
    final total = _total;
    if (total <= 0) return null;
    final ring = _ring(side, chart);
    var before = 0.0;
    for (var i = 0; i < active.index; i++) {
      before += _to[i];
    }
    final mid =
        (before + _to[active.index] / 2) / total * math.pi * 2 - math.pi / 2;
    return ring.center + Offset.fromDirection(mid, ring.outer);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final chart = theme.chartTheme;
    final strings = UnaLocalizations.of(context);
    final segments = widget.segments;
    final colors = [
      for (final (i, s) in segments.indexed) chartColor(theme, s, i),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Square: the size it is held to, or the theme's chart height where
        // it is free to choose, never more than it is allowed.
        final preferred = chart.height ?? 240;
        final double side;
        if (constraints.hasTightWidth || constraints.hasTightHeight) {
          side = math.min(constraints.maxWidth, constraints.maxHeight);
        } else {
          side = math.min(
            preferred,
            math.min(constraints.maxWidth, constraints.maxHeight),
          );
        }
        final ring = _ring(side, chart);
        final active = _active;
        final center = widget.center;
        // The largest square inside the hole.
        final hole = ring.inner * math.sqrt2;
        return Center(
          widthFactor: 1,
          heightFactor: 1,
          child: ChartInteraction(
            count: segments.length,
            active: active?.index,
            onActiveChanged: _setActive,
            indexAt: (p) => _indexAt(p, side, chart),
            describe: _describe,
            label: widget.semanticLabel ?? strings.chart.donut,
            summary: [
              for (var i = 0; i < segments.length; i++) _describe(i),
            ].join(', '),
            borderRadius: BorderRadius.circular(side / 2),
            child: SizedBox.square(
              dimension: side,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _DonutPainter(
                          repaint: _repaint,
                          sweep: _sweep.animation,
                          change: _change.animation,
                          grow: _grow.animation,
                          from: _from,
                          to: _to,
                          colors: colors,
                          center: ring.center,
                          outer: ring.outer,
                          inner: ring.inner,
                          active: active?.index,
                          theme: chart,
                          scheme: theme.colorScheme,
                        ),
                      ),
                    ),
                  ),
                  if (center != null && hole > 0)
                    Center(
                      child: SizedBox.square(
                        dimension: hole,
                        child: Center(
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                            textAlign: TextAlign.center,
                            child: center,
                          ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: ChartTooltipLayer(
                      anchor: _anchor(side, chart),
                      child: active == null
                          ? null
                          : ChartTooltip(
                              rows: [
                                (
                                  color: colors[active.index],
                                  label: segments[active.index].label,
                                  value: _format(
                                    segments[active.index].value,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required Listenable repaint,
    required this.sweep,
    required this.change,
    required this.grow,
    required this.from,
    required this.to,
    required this.colors,
    required this.center,
    required this.outer,
    required this.inner,
    required this.active,
    required this.theme,
    required this.scheme,
  }) : super(repaint: repaint);

  final Animation<double> sweep;
  final Animation<double> change;
  final Animation<double> grow;
  final List<double> from;
  final List<double> to;
  final List<Color> colors;
  final Offset center;
  final double outer;
  final double inner;
  final int? active;
  final ChartTheme theme;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final t = change.value;
    final values = [
      for (var i = 0; i < to.length; i++)
        math.max(0, _DonutChartState._lerp(from, to, i, t)).toDouble(),
    ];
    final total = values.fold<double>(0, (sum, v) => sum + v);
    if (outer <= 0) return;
    if (total <= 0) {
      // Nothing to share out: the empty ring, so the chart keeps its place.
      final empty = Path()
        ..addOval(Rect.fromCircle(center: center, radius: outer));
      if (inner > 0) {
        empty
          ..addOval(Rect.fromCircle(center: center, radius: inner))
          ..fillType = PathFillType.evenOdd;
      }
      canvas.drawPath(empty, Paint()..color = scheme.muted);
      return;
    }
    final turn = math.pi * 2 * sweep.value.clamp(0.0, 1.0);
    final gap = theme.segmentGap ?? 2;
    final corner = theme.segmentRadius ?? 4;
    final growth = (theme.activeSegmentGrowth ?? 6) * grow.value;
    var start = -math.pi / 2;
    final shown = values.where((v) => v > 0).length;
    for (var i = 0; i < values.length; i++) {
      final angle = values[i] / total * turn;
      if (angle <= 0) continue;
      final path = donutSegmentPath(
        center: center,
        inner: inner,
        outer: outer + (i == active ? growth : 0),
        start: start,
        sweep: angle,
        // A single segment is the whole ring, with no gap in it.
        gap: shown > 1 ? gap : 0,
        corner: corner,
      );
      if (path != null) canvas.drawPath(path, Paint()..color = colors[i]);
      start += angle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.sweep != sweep ||
      old.change != change ||
      old.grow != grow ||
      old.from != from ||
      old.to != to ||
      !listEquals(old.colors, colors) ||
      old.center != center ||
      old.outer != outer ||
      old.inner != inner ||
      old.active != active ||
      old.theme != theme ||
      old.scheme != scheme;
}

/// The outline of one segment of a ring between radii [inner] and [outer],
/// from angle [start] through [sweep] (radians, clockwise from the x axis),
/// parted from its neighbours by a gap of [gap] with parallel edges and its
/// corners rounded by [corner]. Null when the gap leaves nothing.
@visibleForTesting
Path? donutSegmentPath({
  required Offset center,
  required double inner,
  required double outer,
  required double start,
  required double sweep,
  double gap = 0,
  double corner = 0,
}) {
  if (sweep <= 0 || outer <= inner) return null;
  final full = sweep >= math.pi * 2 - 1e-9;
  if (full) {
    final ring = Path()
      ..addOval(Rect.fromCircle(center: center, radius: outer));
    if (inner > 0) {
      ring
        ..addOval(Rect.fromCircle(center: center, radius: inner))
        ..fillType = PathFillType.evenOdd;
    }
    return ring;
  }
  final g = gap / 2;
  final end = start + sweep;
  Offset u(double a) => Offset(math.cos(a), math.sin(a));
  // The normal of an edge, pointing into the segment.
  Offset n(double a, {required bool atStart}) => atStart
      ? Offset(-math.sin(a), math.cos(a))
      : Offset(math.sin(a), -math.cos(a));

  // The corner radius that fits: no more than half the ring's thickness,
  // and small enough that the corners of one arc do not meet.
  var c = math.min(corner, (outer - inner) / 2);
  bool fits(double c) {
    // The outer corners' tangent points must not cross.
    final tOuter = (outer - c) * (outer - c) - (g + c) * (g + c);
    if (tOuter <= 0) return false;
    final angle = math.atan2(g + c, math.sqrt(tOuter)) * 2;
    if (angle >= sweep) return false;
    if (inner > 0) {
      final tInner = (inner + c) * (inner + c) - (g + c) * (g + c);
      if (tInner <= 0) return false;
      if (math.atan2(g + c, math.sqrt(tInner)) * 2 >= sweep) return false;
    }
    return true;
  }

  while (c > .25 && !fits(c)) {
    c /= 2;
  }
  if (c <= .25) c = 0;
  if (c == 0) {
    // Sharp corners: the edges are the radii shifted inward by the gap.
    final outerInset = outer <= g ? math.pi : math.asin(g / outer);
    if (outerInset * 2 >= sweep) return null;
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: outer),
        start + outerInset,
        sweep - outerInset * 2,
        true,
      );
    final innerInset = inner > g ? math.asin(g / inner) : null;
    if (inner > 0 && innerInset != null && innerInset * 2 < sweep) {
      path.arcTo(
        Rect.fromCircle(center: center, radius: inner),
        end - innerInset,
        -(sweep - innerInset * 2),
        false,
      );
    } else {
      // A pie's tip: where the two shifted edges meet.
      final half = sweep / 2;
      final tip = g / math.sin(math.min(half, math.pi / 2));
      path.lineTo(
        center.dx + math.cos(start + half) * tip,
        center.dy + math.sin(start + half) * tip,
      );
    }
    return path..close();
  }

  // A corner circle of radius c tangent to an edge (a radius shifted by g)
  // and to a circle of radius R, from outside it ([outside]) or from
  // inside.
  ({Offset onEdge, Offset onArc}) cornerAt(
    double a, {
    required bool atStart,
    required double radius,
    required bool outside,
  }) {
    final normal = n(a, atStart: atStart);
    final reach = outside ? radius + c : radius - c;
    final t = math.sqrt(math.max(0, reach * reach - (g + c) * (g + c)));
    final circle = u(a) * t + normal * (g + c);
    return (
      onEdge: center + u(a) * t + normal * g,
      onArc: center + circle * (radius / reach),
    );
  }

  final outerStart = cornerAt(
    start,
    atStart: true,
    radius: outer,
    outside: false,
  );
  final outerEnd = cornerAt(end, atStart: false, radius: outer, outside: false);
  final arcCorner = Radius.circular(c);
  double angleOf(Offset p) => (p - center).direction;
  double clockwise(double from, double to) {
    var d = to - from;
    while (d < 0) {
      d += math.pi * 2;
    }
    return d;
  }

  final path = Path()
    ..moveTo(outerStart.onEdge.dx, outerStart.onEdge.dy)
    ..arcToPoint(outerStart.onArc, radius: arcCorner);
  final outerFrom = angleOf(outerStart.onArc);
  path
    ..arcTo(
      Rect.fromCircle(center: center, radius: outer),
      outerFrom,
      clockwise(outerFrom, angleOf(outerEnd.onArc)),
      false,
    )
    ..arcToPoint(outerEnd.onEdge, radius: arcCorner);

  if (inner > 0) {
    final innerEnd = cornerAt(
      end,
      atStart: false,
      radius: inner,
      outside: true,
    );
    final innerStart = cornerAt(
      start,
      atStart: true,
      radius: inner,
      outside: true,
    );
    path
      ..lineTo(innerEnd.onEdge.dx, innerEnd.onEdge.dy)
      ..arcToPoint(innerEnd.onArc, radius: arcCorner);
    final innerFrom = angleOf(innerEnd.onArc);
    path
      ..arcTo(
        Rect.fromCircle(center: center, radius: inner),
        innerFrom,
        -clockwise(angleOf(innerStart.onArc), innerFrom),
        false,
      )
      ..arcToPoint(innerStart.onEdge, radius: arcCorner);
  } else {
    final half = sweep / 2;
    final tip = g / math.sin(math.min(half, math.pi / 2));
    path.lineTo(
      center.dx + math.cos(start + half) * tip,
      center.dy + math.sin(start + half) * tip,
    );
  }
  return path..close();
}
