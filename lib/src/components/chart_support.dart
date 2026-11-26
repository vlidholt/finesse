import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Intl, NumberFormat;
import 'package:una/src/components/chart_data.dart';
import 'package:una/src/components/surface.dart';
import 'package:una/src/raw_components/pressable.dart' show FocusRing;
import 'package:una/src/theme/components/chart.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/haptics.dart';
import 'package:una/src/utils/spring.dart';

// The pieces the charts share: the value scale and its round ticks, number
// formatting, the colour of an entry, the line through a series' points,
// and the interaction — hover, touch, keys, semantics — and the tooltip
// that follows it. None of it is exported.

/// A value axis: the range a chart plots, widened to round numbers, and the
/// ticks along it.
@internal
@immutable
class ChartScale {
  /// Creates a scale over [min]…[max] with [ticks] every [step].
  const ChartScale({
    required this.min,
    required this.max,
    required this.step,
    required this.ticks,
  });

  /// The lowest value plotted.
  final double min;

  /// The highest value plotted.
  final double max;

  /// The distance between two ticks.
  final double step;

  /// The tick values, lowest first, each a multiple of [step].
  final List<double> ticks;

  /// Where [value] falls between [min] (0) and [max] (1).
  double fraction(double value) => max == min ? 0 : (value - min) / (max - min);

  @override
  bool operator ==(Object other) =>
      other is ChartScale &&
      other.min == min &&
      other.max == max &&
      other.step == step;

  @override
  int get hashCode => Object.hash(min, max, step);

  @override
  String toString() => 'ChartScale($min…$max by $step)';
}

/// The round step nearest to dividing [span] into [count] parts: 1, 2 or 5
/// times a power of ten (d3's `tickIncrement`).
double _niceStep(double span, int count) {
  final raw = span / math.max(1, count);
  final magnitude = math
      .pow(10, (math.log(raw) / math.ln10).floor())
      .toDouble();
  final error = raw / magnitude;
  final factor = error >= math.sqrt(50)
      ? 10
      : error >= math.sqrt(10)
      ? 5
      : error >= math.sqrt2
      ? 2
      : 1;
  return magnitude * factor;
}

/// A [step]'s decimal places: 0 for 5 or 50, 1 for 0.5, 2 for 0.25.
int _decimalsOf(double step) {
  for (var d = 0; d < 10; d++) {
    final scaled = step * math.pow(10, d);
    if ((scaled - scaled.roundToDouble()).abs() < 1e-6 * scaled.abs()) {
      return d;
    }
  }
  return 10;
}

/// The scale that holds every value between [low] and [high], widened to
/// round numbers, with about [count] ticks.
///
/// A range of one value is widened around it, so a flat series still has
/// a scale (a series of zeros plots on 0…1).
@internal
ChartScale niceScale(double low, double high, {int count = 5}) {
  assert(low.isFinite && high.isFinite, 'A chart plots finite values');
  var lo = math.min(low, high);
  var hi = math.max(low, high);
  if (lo == hi) {
    if (lo == 0) {
      hi = 1;
    } else if (lo > 0) {
      lo = 0;
    } else {
      hi = 0;
    }
  }
  final intervals = math.max(1, count - 1);
  var step = _niceStep(hi - lo, intervals);
  var min = (lo / step).floor() * step;
  var max = (hi / step).ceil() * step;
  // Rounding outward can leave far more ticks than asked for on a range
  // that only just crosses a step; take the next step up then.
  if ((max - min) / step > intervals * 2) {
    step = _niceStep(max - min, intervals);
    min = (lo / step).floor() * step;
    max = (hi / step).ceil() * step;
  }
  final decimals = _decimalsOf(step);
  double round(double v) =>
      double.parse(v.toStringAsFixed(math.min(decimals + 1, 20)));
  final count0 = ((max - min) / step).round();
  return ChartScale(
    min: round(min),
    max: round(max),
    step: step,
    ticks: [for (var i = 0; i <= count0; i++) round(min + step * i)],
  );
}

/// Ticks for a numeric x axis: round values inside [low]…[high], which is
/// not widened (the first and last points stay at the ends of the plot).
@internal
List<double> innerTicks(double low, double high, {int count = 5}) {
  if (high <= low) return [low];
  final step = _niceStep(high - low, math.max(1, count - 1));
  final decimals = _decimalsOf(step);
  final first = (low / step).ceil();
  final last = (high / step).floor();
  return [
    for (var i = first; i <= last; i++)
      double.parse((i * step).toStringAsFixed(math.min(decimals + 1, 20))),
  ];
}

/// Number formats per locale, so a chart rebuilt on hover makes none.
final Map<(String?, int, bool), NumberFormat> _formats = {};

NumberFormat _format(String? locale, int decimals, {bool compact = false}) {
  return _formats.putIfAbsent((locale, decimals, compact), () {
    // A locale intl has no numbers for falls back to its default.
    final known = Intl.verifiedLocale(
      locale,
      NumberFormat.localeExists,
      onFailure: (_) => null,
    );
    final format = compact
        ? NumberFormat.compact(locale: known)
        : NumberFormat.decimalPattern(known);
    if (!compact) {
      format
        ..minimumFractionDigits = 0
        ..maximumFractionDigits = decimals;
    }
    return format;
  });
}

/// How the charts write their numbers when the app gives no formatter.
@internal
class ChartNumbers {
  /// The formats of [context]'s locale.
  ChartNumbers.of(BuildContext context)
    : _locale = Localizations.maybeLocaleOf(context)?.toLanguageTag();

  final String? _locale;

  /// A value as a tooltip shows it: grouped, up to two decimals.
  String value(double value) => _format(_locale, 2).format(value);

  /// A tick label on a scale stepping by [step]: as many decimals as the
  /// step has, and compact (`12K`) once the numbers are long.
  String tick(double value, double step, double largest) {
    if (largest.abs() >= 10000 && step >= 1000) {
      return _format(_locale, 0, compact: true).format(value);
    }
    return _format(_locale, _decimalsOf(step)).format(value);
  }
}

/// The colour of the [index]th entry of a chart.
@internal
Color chartColor(ThemeData theme, ChartEntry entry, int index) {
  final color = entry.color;
  if (color != null) return color;
  final palette = theme.chartTheme.palette ?? theme.colorScheme.charts;
  return palette[index % palette.length];
}

/// The line through [points], left to right in the order given, joined as
/// [interpolation] says.
///
/// [LineInterpolation.monotone] is d3's `curveMonotoneX` (Steffen's
/// method): each piece stays between the values at its ends, so the curve
/// never invents a peak or a dip the data does not have.
@internal
Path chartLinePath(
  List<Offset> points,
  LineInterpolation interpolation, {
  Path? into,
}) {
  final path = into ?? Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.dx, points.first.dy);
  if (points.length == 1) return path;
  switch (interpolation) {
    case LineInterpolation.linear:
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
    case LineInterpolation.step:
      for (var i = 1; i < points.length; i++) {
        final a = points[i - 1];
        final b = points[i];
        final mid = (a.dx + b.dx) / 2;
        path
          ..lineTo(mid, a.dy)
          ..lineTo(mid, b.dy)
          ..lineTo(b.dx, b.dy);
      }
    case LineInterpolation.monotone:
      final n = points.length;
      if (n == 2) {
        path.lineTo(points[1].dx, points[1].dy);
        return path;
      }
      final h = [
        for (var i = 0; i < n - 1; i++) points[i + 1].dx - points[i].dx,
      ];
      final s = [
        for (var i = 0; i < n - 1; i++)
          (points[i + 1].dy - points[i].dy) /
              (h[i] == 0 ? double.infinity : h[i]),
      ];
      double sign(double v) => v < 0 ? -1 : (v > 0 ? 1 : 0);
      final m = List<double>.filled(n, 0);
      for (var i = 1; i < n - 1; i++) {
        final h0 = h[i - 1];
        final h1 = h[i];
        if (h0 + h1 == 0) continue;
        final p = (s[i - 1] * h1 + s[i] * h0) / (h0 + h1);
        m[i] =
            (sign(s[i - 1]) + sign(s[i])) *
            math.min(
              math.min(s[i - 1].abs(), s[i].abs()),
              .5 * p.abs(),
            );
      }
      // The ends take the slope that keeps the first and last pieces
      // monotone: d3's `slope2`.
      m[0] = h[0] == 0 ? 0 : (3 * s[0] - m[1]) / 2;
      m[n - 1] = h[n - 2] == 0 ? 0 : (3 * s[n - 2] - m[n - 2]) / 2;
      // Keep the end slopes from overshooting either.
      if (sign(m[0]) != sign(s[0])) m[0] = 0;
      if (sign(m[n - 1]) != sign(s[n - 2])) m[n - 1] = 0;
      for (var i = 0; i < n - 1; i++) {
        final a = points[i];
        final b = points[i + 1];
        final third = h[i] / 3;
        path.cubicTo(
          a.dx + third,
          a.dy + m[i] * third,
          b.dx - third,
          b.dy - m[i + 1] * third,
          b.dx,
          b.dy,
        );
      }
  }
  return path;
}

/// One line of a chart's tooltip: a swatch, a name and a value.
@internal
typedef ChartTooltipRow = ({Color color, String label, String value});

/// The contents of a chart's tooltip, on a popover surface: an optional
/// [title] over a row per series.
@internal
class ChartTooltip extends StatelessWidget {
  /// Creates a tooltip with [rows] under [title].
  const ChartTooltip({required this.rows, this.title, super.key});

  /// The category, or null for none.
  final String? title;

  /// The rows, a swatch, a name and a value each.
  final List<ChartTooltipRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chart = theme.chartTheme;
    final swatch = chart.legendSwatchSize ?? 10;
    final caption = theme.textTheme.caption;
    final swatchRadius = BorderRadius.circular(
      math.min(swatch / 4, chart.barRadius ?? 2.5),
    );
    return Surface(
      padding: chart.tooltipPadding,
      decoration: chart.tooltipDecoration,
      child: ConstrainedBox(
        // `min-w-32`.
        constraints: const BoxConstraints(minWidth: 128),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: chart.tooltipLabelStyle ?? caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              for (final row in rows)
                Row(
                  spacing: 8,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: row.color,
                        borderRadius: swatchRadius,
                      ),
                      child: SizedBox.square(dimension: swatch),
                    ),
                    Expanded(
                      child: Text(
                        row.label,
                        style: chart.tooltipTextStyle ?? caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      row.value,
                      style: chart.tooltipValueStyle ?? caption,
                      maxLines: 1,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Places a chart's tooltip beside [anchor] and lets it glide from point
/// to point on the theme's snappy spring.
///
/// The tooltip goes on the trailing side of the anchor, [ChartTheme.
/// tooltipOffset] away, and on the leading side when it does not fit; it
/// is centred on the anchor's height and kept inside the chart. The glide
/// is laid out, not built: a frame of it moves the tooltip and nothing
/// else.
@internal
class ChartTooltipLayer extends StatefulWidget {
  /// Creates the layer; with a null [anchor] it shows nothing.
  const ChartTooltipLayer({
    required this.anchor,
    required this.child,
    this.clearance = 0,
    super.key,
  });

  /// The point the tooltip describes, in the chart's coordinates.
  final Offset? anchor;

  /// How far either side of [anchor] the thing it describes reaches (half
  /// a group of bars), which the tooltip keeps clear of.
  final double clearance;

  /// The tooltip.
  final Widget? child;

  @override
  State<ChartTooltipLayer> createState() => _ChartTooltipLayerState();
}

class _ChartTooltipLayerState extends State<ChartTooltipLayer>
    with TickerProviderStateMixin {
  late final _x = SpringController(vsync: this, tolerance: .05);
  late final _y = SpringController(vsync: this, tolerance: .05);
  late final _moved = Listenable.merge([_x.animation, _y.animation]);
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _place(animate: false);
  }

  @override
  void didUpdateWidget(ChartTooltipLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.anchor != oldWidget.anchor) _place(animate: _shown);
  }

  void _place({required bool animate}) {
    final anchor = widget.anchor;
    if (anchor == null) {
      _shown = false;
      return;
    }
    if (!animate) {
      _x.jumpTo(anchor.dx);
      _y.jumpTo(anchor.dy);
    } else {
      final spring = Motion.of(context).snappy;
      _x.animateTo(anchor.dx, spring: spring);
      _y.animateTo(anchor.dy, spring: spring);
    }
    _shown = true;
  }

  @override
  void dispose() {
    _x.dispose();
    _y.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (widget.anchor == null || child == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomSingleChildLayout(
          delegate: _TooltipLayout(
            x: _x.animation,
            y: _y.animation,
            offset: Theme.of(context).chartTheme.tooltipOffset ?? 12,
            clearance: widget.clearance,
            textDirection: Directionality.of(context),
            relayout: _moved,
          ),
          child: RepaintBoundary(child: child),
        ),
      ),
    );
  }
}

class _TooltipLayout extends SingleChildLayoutDelegate {
  _TooltipLayout({
    required this.x,
    required this.y,
    required this.offset,
    required this.clearance,
    required this.textDirection,
    required Listenable relayout,
  }) : super(relayout: relayout);

  final Animation<double> x;
  final Animation<double> y;
  final double offset;
  final double clearance;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final ax = x.value;
    final ay = y.value;
    final reach = offset + clearance;
    final after = ax + reach;
    final before = ax - reach - childSize.width;
    final fitsAfter = after + childSize.width <= size.width;
    final fitsBefore = before >= 0;
    final maxLeft = math.max(0, size.width - childSize.width).toDouble();
    final maxTop = math.max(0, size.height - childSize.height).toDouble();
    if (!fitsAfter && !fitsBefore) {
      // A chart too narrow for the tooltip beside the point has it above
      // the point instead (below, when there is no room above), so it
      // still does not cover it.
      final above = ay - offset - childSize.height;
      return Offset(
        (ax - childSize.width / 2).clamp(0, maxLeft),
        above >= 0 ? above : ay + offset,
      );
    }
    final double left;
    if (textDirection == TextDirection.ltr) {
      left = fitsAfter ? after : before;
    } else {
      left = fitsBefore ? before : after;
    }
    return Offset(left, (ay - childSize.height / 2).clamp(0, maxTop));
  }

  @override
  bool shouldRelayout(_TooltipLayout oldDelegate) =>
      oldDelegate.x != x ||
      oldDelegate.y != y ||
      oldDelegate.offset != offset ||
      oldDelegate.clearance != clearance ||
      oldDelegate.textDirection != textDirection;
}

/// The point of a chart the user is looking at, and how they got there.
@internal
typedef ChartActive = ({int index, Offset? pointer});

/// The interaction every chart has: the pointer, a finger and the keyboard
/// pick a point (or a bar, or a segment), and assistive technology reads
/// and steps through them.
///
/// The chart owns the picked point ([active]) and is told of every change
/// through [onActiveChanged]; this widget turns input into indices with
/// [indexAt] and describes them with [describe].
@internal
class ChartInteraction extends StatefulWidget {
  /// Creates the interaction around [child].
  const ChartInteraction({
    required this.count,
    required this.active,
    required this.onActiveChanged,
    required this.indexAt,
    required this.describe,
    required this.label,
    required this.summary,
    required this.child,
    this.axis = Axis.horizontal,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  /// How many points there are to step through.
  final int count;

  /// The point picked, or null for none.
  final int? active;

  /// Called with the newly picked point, or null when none is.
  final ValueChanged<ChartActive?> onActiveChanged;

  /// The point under a position, in the chart's coordinates, or null for
  /// none.
  final int? Function(Offset position) indexAt;

  /// A point, by its index, as text: its category and values.
  final String Function(int index) describe;

  /// What the chart is, for assistive technology.
  final String label;

  /// The chart as a whole, read while no point is picked.
  final String summary;

  /// The axis the points run along, which says which arrow keys step: left
  /// and right along a horizontal one (mirrored in a right-to-left
  /// reading direction), up and down along a vertical one.
  final Axis axis;

  /// The corners of the focus ring.
  final BorderRadius borderRadius;

  /// The chart.
  final Widget child;

  @override
  State<ChartInteraction> createState() => _ChartInteractionState();
}

class _ChartInteractionState extends State<ChartInteraction> {
  final _focusNode = FocusNode(debugLabel: 'Chart');
  bool _hovering = false;
  bool _focused = false;
  bool _keyboard = false;
  bool _dragByTouch = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused == _focused) return;
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    setState(() {
      _focused = focused;
      _keyboard = focused && keyboard;
    });
    if (focused && keyboard && widget.active == null && widget.count > 0) {
      // Arriving by Tab shows where the arrows start from.
      _pick(0);
    } else if (!focused && !_hovering && widget.active != null) {
      widget.onActiveChanged(null);
    }
  }

  void _pick(int? index, {Offset? pointer, bool touch = false}) {
    if (index == null) {
      if (widget.active != null) widget.onActiveChanged(null);
      return;
    }
    if (touch && index != widget.active) Haptics.selection(context);
    widget.onActiveChanged((index: index, pointer: pointer));
  }

  void _pointerAt(Offset position, {bool touch = false}) {
    if (widget.count == 0) return;
    _pick(widget.indexAt(position), pointer: position, touch: touch);
  }

  int _wrap(int index) => index.clamp(0, widget.count - 1);

  void _step(int delta) {
    if (widget.count == 0) return;
    final active = widget.active;
    final next = active == null
        ? (delta > 0 ? 0 : widget.count - 1)
        : _wrap(active + delta);
    setState(() => _keyboard = true);
    _pick(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final horizontal = widget.axis == Axis.horizontal;
    int? delta;
    if (horizontal && key == LogicalKeyboardKey.arrowRight) {
      delta = rtl ? -1 : 1;
    } else if (horizontal && key == LogicalKeyboardKey.arrowLeft) {
      delta = rtl ? 1 : -1;
    } else if (!horizontal && key == LogicalKeyboardKey.arrowDown) {
      delta = 1;
    } else if (!horizontal && key == LogicalKeyboardKey.arrowUp) {
      delta = -1;
    }
    if (delta != null) {
      _step(delta);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home && widget.count > 0) {
      setState(() => _keyboard = true);
      _pick(0);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end && widget.count > 0) {
      setState(() => _keyboard = true);
      _pick(widget.count - 1);
      return KeyEventResult.handled;
    }
    // Escape is only ours while there is something to put away; otherwise
    // it belongs to whatever is around the chart (a dialog, a sheet).
    if (key == LogicalKeyboardKey.escape && widget.active != null) {
      _pick(null);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final count = widget.count;
    final hasPoints = count > 0;
    final next = active == null ? 0 : math.min(active + 1, count - 1);
    final previous = active == null ? count - 1 : math.max(active - 1, 0);
    return Semantics(
      container: true,
      label: widget.label,
      value: active == null ? widget.summary : widget.describe(active),
      increasedValue: hasPoints ? widget.describe(next) : null,
      decreasedValue: hasPoints ? widget.describe(previous) : null,
      onIncrease: hasPoints ? () => _pick(next) : null,
      onDecrease: hasPoints ? () => _pick(previous) : null,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _onKey,
        child: FocusRing(
          visible: _focused && _keyboard,
          borderRadius: widget.borderRadius,
          child: TapRegion(
            onTapOutside: (_) {
              if (!_focused) _pick(null);
            },
            child: MouseRegion(
              onEnter: (_) => _hovering = true,
              onHover: (event) {
                _keyboard = false;
                _pointerAt(event.localPosition);
              },
              onExit: (_) {
                _hovering = false;
                if (!_keyboard) _pick(null);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                // A touch picks a point and keeps it until the next touch
                // or a tap elsewhere; a horizontal drag scrubs through the
                // points, and a vertical one still scrolls the page.
                onTapDown: (details) => _pointerAt(
                  details.localPosition,
                  touch: details.kind == PointerDeviceKind.touch,
                ),
                onHorizontalDragStart: (details) {
                  _dragByTouch = details.kind == PointerDeviceKind.touch;
                  _pointerAt(details.localPosition, touch: _dragByTouch);
                },
                onHorizontalDragUpdate: (details) =>
                    _pointerAt(details.localPosition, touch: _dragByTouch),
                child: ExcludeSemantics(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The size a chart takes in [constraints]: all of a bounded width, and
/// the height it is held to, or [height] when it is free to choose (open,
/// or loose as under an `Align`): a chart has no natural height, and one
/// that grew to whatever it was allowed would fill a page.
@internal
Size chartSize(BoxConstraints constraints, double height, String chart) {
  assert(
    constraints.hasBoundedWidth,
    '$chart was given an unbounded width. A chart fills the width it is '
    'given; put it in a SizedBox or an Expanded, or anywhere with a width.',
  );
  return constraints.constrain(
    Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : height * 2,
      constraints.hasTightHeight ? constraints.maxHeight : height,
    ),
  );
}
