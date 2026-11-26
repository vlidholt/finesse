import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/spring.dart';

/// How a [PageIndicator] is drawn.
enum PageIndicatorVariant {
  /// Dots on the page, in the theme's colours.
  plain,

  /// White dots on a dark capsule, for an indicator laid over a photograph
  /// or anything else the theme's colours would not read on.
  overlay,
}

/// A row of dots, one per page, with a pill on the current one: where you
/// are in a carousel, an onboarding flow, a gallery.
///
/// ```dart
/// PageIndicator(
///   count: photos.length,
///   index: current,
///   onSelected: (index) => controller.animateToPage(index),
/// )
/// ```
///
/// The pill glides to a new [index] on the theme's snappy spring. Given the
/// [controller] of the `PageView` it describes, it follows the pages under
/// the finger instead: the pill hands its length over to the next dot as
/// the page is dragged across.
///
/// With more than [maxVisible] pages only a window of dots is shown; it
/// follows the current page, and the dots at an edge with more beyond it
/// shrink.
///
/// With [onSelected] a tap on a dot picks its page, the indicator takes the
/// keyboard focus and the arrow keys step through the pages; assistive
/// technology hears "Page 2 of 5" and can step either way.
class PageIndicator extends StatefulWidget {
  /// Creates a page indicator.
  const PageIndicator({
    required this.count,
    required this.index,
    this.controller,
    this.onSelected,
    this.maxVisible = 7,
    this.axis = Axis.horizontal,
    this.variant = PageIndicatorVariant.plain,
    this.color,
    this.activeColor,
    this.semanticLabel,
    super.key,
  }) : assert(count >= 0, 'count is not negative'),
       assert(maxVisible >= 3, 'maxVisible is at least 3');

  /// The number of pages.
  final int count;

  /// The current page: what assistive technology reads and where the
  /// arrow keys step from. It also places the pill, unless a [controller]
  /// is attached to a page view, which then does. Keep it current either
  /// way.
  final int index;

  /// The controller of the page view the indicator describes, for a pill
  /// that follows a drag. Its page is taken modulo [count], so it may be
  /// the controller of an endless view.
  final PageController? controller;

  /// Called with a page when its dot is tapped, or when the arrow keys or
  /// assistive technology step to it. Null makes the indicator a picture.
  final ValueChanged<int>? onSelected;

  /// The most dots shown at once.
  final int maxVisible;

  /// The direction the dots run in.
  final Axis axis;

  /// How the indicator is drawn.
  final PageIndicatorVariant variant;

  /// The colour of the other pages' dots. Defaults to the theme's.
  final Color? color;

  /// The colour of the current page's pill. Defaults to the theme's.
  final Color? activeColor;

  /// What assistive technology reads for the indicator, in place of the
  /// localized "Page 2 of 5".
  final String? semanticLabel;

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator>
    with SingleTickerProviderStateMixin {
  late final _position = SpringController(
    vsync: this,
    value: widget.index.toDouble(),
  );

  /// Notifies the painter of the pill moving, whichever of the two drives
  /// it.
  late Listenable _repaint = _merge();

  Listenable _merge() => Listenable.merge([
    _position.animation,
    ?widget.controller,
  ]);

  @override
  void didUpdateWidget(PageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      _repaint = _merge();
    }
    if (widget.index != oldWidget.index) {
      _position.animateTo(
        widget.index.toDouble(),
        spring: Motion.of(context).snappy,
      );
    }
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  /// Where the pill is, in pages: the page view's when one is attached and
  /// laid out, else the spring's.
  double _page() {
    final count = widget.count;
    if (count == 0) return 0;
    final controller = widget.controller;
    if (controller != null &&
        controller.hasClients &&
        controller.positions.length == 1 &&
        controller.position.hasContentDimensions) {
      final page = controller.page;
      if (page != null) return page % count;
    }
    return _position.value.clamp(0.0, count - 1.0);
  }

  /// The page the indicator stands on, for keys, taps and assistive
  /// technology: the widget's own [PageIndicator.index], which the parent
  /// keeps current, not the pill's place mid-drag.
  int get _current =>
      widget.count == 0 ? 0 : widget.index.clamp(0, widget.count - 1);

  void _step(int delta) {
    final onSelected = widget.onSelected;
    if (onSelected == null || widget.count == 0) return;
    final next = (_current + delta).clamp(0, widget.count - 1);
    if (next != _current) onSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final carousel = theme.carouselTheme;
    final overlay = widget.variant == PageIndicatorVariant.overlay;
    final direction = Directionality.of(context);
    final count = widget.count;

    final geometry = _DotGeometry(
      count: count,
      maxVisible: widget.maxVisible,
      dot: carousel.dotSize ?? 6,
      active: carousel.activeDotExtent ?? 18,
      gap: carousel.dotSpacing ?? 6,
    );
    final horizontal = widget.axis == Axis.horizontal;
    final size = horizontal
        ? Size(geometry.extent, geometry.dot)
        : Size(geometry.dot, geometry.extent);

    Widget dots = RepaintBoundary(
      child: CustomPaint(
        size: size,
        painter: _DotsPainter(
          geometry: geometry,
          page: _page,
          axis: widget.axis,
          textDirection: direction,
          color:
              widget.color ??
              (overlay ? carousel.overlayDotColor : carousel.dotColor) ??
              theme.colorScheme.border,
          activeColor:
              widget.activeColor ??
              (overlay
                  ? carousel.overlayActiveDotColor
                  : carousel.activeDotColor) ??
              theme.colorScheme.tint,
          repaint: _repaint,
        ),
      ),
    );

    if (overlay) {
      dots = DecoratedBox(
        decoration: ShapeDecoration(
          color: carousel.overlayColor ?? const Color(0x8A09090B),
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding:
              carousel.overlayPadding ??
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: dots,
        ),
      );
    }

    final strings = UnaLocalizations.of(context).carousel;
    String label(int index) => strings.page(page: index + 1, count: count);
    final current = _current;
    final onSelected = widget.onSelected;

    if (onSelected == null || count == 0) {
      return Semantics(
        label: widget.semanticLabel ?? (count == 0 ? null : label(current)),
        child: dots,
      );
    }

    // Towards the end of the pages, in the reading direction.
    final forward = horizontal
        ? (direction == TextDirection.ltr
              ? LogicalKeyboardKey.arrowRight
              : LogicalKeyboardKey.arrowLeft)
        : LogicalKeyboardKey.arrowDown;
    final back = horizontal
        ? (direction == TextDirection.ltr
              ? LogicalKeyboardKey.arrowLeft
              : LogicalKeyboardKey.arrowRight)
        : LogicalKeyboardKey.arrowUp;

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      value: label(current),
      increasedValue: current < count - 1 ? label(current + 1) : null,
      decreasedValue: current > 0 ? label(current - 1) : null,
      onIncrease: current < count - 1 ? () => _step(1) : null,
      onDecrease: current > 0 ? () => _step(-1) : null,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        shortcuts: {
          SingleActivator(forward): const _StepIntent(1),
          SingleActivator(back): const _StepIntent(-1),
        },
        actions: {
          _StepIntent: CallbackAction<_StepIntent>(
            onInvoke: (intent) {
              _step(intent.delta);
              return null;
            },
          ),
        },
        onShowFocusHighlight: (value) {
          if (_focused != value) setState(() => _focused = value);
        },
        child: FocusRing(
          visible: _focused,
          borderRadius: theme.radii.full,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTapUp: (details) {
              final along = horizontal
                  ? (direction == TextDirection.ltr
                        ? details.localPosition.dx
                        : context.size!.width - details.localPosition.dx)
                  : details.localPosition.dy;
              // The capsule's padding is part of the tap target.
              final inset = overlay
                  ? (carousel.overlayPadding ??
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ))
                        .resolve(direction)
                  : EdgeInsets.zero;
              // A parent that stretches the indicator centres the strip.
              final box = context.size!;
              final content =
                  geometry.extent +
                  (horizontal ? inset.horizontal : inset.vertical);
              final centring =
                  math.max(0, (horizontal ? box.width : box.height) - content) /
                  2;
              final before = !horizontal
                  ? inset.top
                  : direction == TextDirection.ltr
                  ? inset.left
                  : inset.right;
              final start = centring + before;
              final index = geometry.indexAt(along - start, _page());
              if (index != current) onSelected(index);
            },
            // A dot is small; the whole strip is at least as tall as a
            // finger needs when it is the target.
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: horizontal ? 24 : 0,
                minWidth: horizontal ? 0 : 24,
              ),
              child: Center(widthFactor: 1, heightFactor: 1, child: dots),
            ),
          ),
        ),
      ),
    );
  }

  bool _focused = false;
}

class _StepIntent extends Intent {
  const _StepIntent(this.delta);

  final int delta;
}

/// Where each dot of a page indicator is, for a given position of the pill.
@immutable
class _DotGeometry {
  const _DotGeometry({
    required this.count,
    required this.maxVisible,
    required this.dot,
    required this.active,
    required this.gap,
  });

  final int count;
  final int maxVisible;
  final double dot;
  final double active;
  final double gap;

  int get visible => math.min(count, maxVisible);

  /// The length of the strip: every visible dot, their gaps, and the one
  /// pill's extra length — wherever the pill is, so nothing around the
  /// indicator moves.
  double get extent =>
      visible == 0 ? 0 : visible * dot + (visible - 1) * gap + (active - dot);

  /// How much of the pill dot [index] is, 0 to 1, with the pill at [page].
  /// The distance is round the ring of pages, so an endless view hands the
  /// pill from the last dot to the first.
  double activity(int index, double page) {
    var distance = (index - page).abs();
    if (count > 1) distance = math.min(distance, count - distance);
    return (1 - distance).clamp(0.0, 1.0);
  }

  /// The first dot of the window, in dots: the window keeps the pill in
  /// its middle and stops at either end of the pages.
  double windowStart(double page) {
    if (count <= maxVisible) return 0;
    return (page - (maxVisible - 1) / 2).clamp(
      0.0,
      (count - maxVisible).toDouble(),
    );
  }

  /// The scale of dot [index]: 1 inside the window, smaller at an edge
  /// that has pages beyond it, and nothing outside.
  double scale(int index, double page) {
    if (count <= maxVisible) return 1;
    final start = windowStart(page);
    final fromStart = index - start;
    final fromEnd = (start + maxVisible - 1) - index;
    final atStart = start > 0 ? ((fromStart + 1) / 2.5) : 1.0;
    final atEnd = start < count - maxVisible ? ((fromEnd + 1) / 2.5) : 1.0;
    if (fromStart < -1 || fromEnd < -1) return 0;
    return math.min(atStart, atEnd).clamp(0.0, 1.0);
  }

  /// Calls [visit] with the start and length of every dot that shows, along
  /// the strip.
  void layout(
    double page,
    void Function(int index, double start, double length, double scale) visit,
  ) {
    if (count == 0) return;
    final start = windowStart(page);
    final scroll = start * (dot + gap);
    var x = -scroll;
    for (var i = 0; i < count; i++) {
      final length = dot + (active - dot) * activity(i, page);
      if (x + length >= -dot && x <= extent + dot) {
        final s = scale(i, page);
        if (s > 0) visit(i, x, length, s);
      }
      x += length + gap;
    }
  }

  /// The page whose dot is nearest [along] the strip.
  int indexAt(double along, double page) {
    var best = 0;
    var bestDistance = double.infinity;
    layout(page, (index, start, length, scale) {
      final distance = (along - (start + length / 2)).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = index;
      }
    });
    return best;
  }

  @override
  bool operator ==(Object other) =>
      other is _DotGeometry &&
      other.count == count &&
      other.maxVisible == maxVisible &&
      other.dot == dot &&
      other.active == active &&
      other.gap == gap;

  @override
  int get hashCode => Object.hash(count, maxVisible, dot, active, gap);
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({
    required this.geometry,
    required this.page,
    required this.axis,
    required this.textDirection,
    required this.color,
    required this.activeColor,
    super.repaint,
  });

  final _DotGeometry geometry;

  /// Asked at paint time: the pill moves without the indicator rebuilding.
  final double Function() page;
  final Axis axis;
  final TextDirection textDirection;
  final Color color;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final horizontal = axis == Axis.horizontal;
    final mirrored = horizontal && textDirection == TextDirection.rtl;
    final extent = geometry.extent;
    final page = this.page();
    final paint = Paint();
    // More dots than fit are a window onto a longer strip.
    if (geometry.count > geometry.maxVisible) {
      canvas.clipRect(Offset.zero & size);
    }
    geometry.layout(page, (index, start, length, scale) {
      final thickness = geometry.dot * scale;
      final scaled = length * scale;
      // Scaled about its own centre.
      var along = start + (length - scaled) / 2;
      if (mirrored) along = extent - along - scaled;
      final across = (geometry.dot - thickness) / 2;
      final rect = horizontal
          ? Rect.fromLTWH(along, across, scaled, thickness)
          : Rect.fromLTWH(across, along, thickness, scaled);
      // A cross-fade: one of the two may be translucent.
      paint.color = AnimatedFill.lerp(
        color,
        activeColor,
        geometry.activity(index, page),
      )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(thickness / 2)),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(_DotsPainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.page != page ||
      oldDelegate.axis != axis ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.color != color ||
      oldDelegate.activeColor != activeColor;
}

/// The geometry of a page indicator's dots, for tests: the start, length
/// and scale of each dot that shows with the pill at [page].
@visibleForTesting
List<({int index, double start, double length, double scale})>
debugPageIndicatorDots({
  required int count,
  required double page,
  int maxVisible = 7,
  double dot = 6,
  double active = 18,
  double gap = 6,
}) {
  final dots = <({int index, double start, double length, double scale})>[];
  _DotGeometry(
    count: count,
    maxVisible: maxVisible,
    dot: dot,
    active: active,
    gap: gap,
  ).layout(
    page,
    (index, start, length, scale) => dots.add(
      (index: index, start: start, length: length, scale: scale),
    ),
  );
  return dots;
}
