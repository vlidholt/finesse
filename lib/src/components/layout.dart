import 'package:finesse/src/theme/components/layout.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Empty space between two children of a [Row], [Column] or [Flex], measured
/// in steps on the theme's spacing scale.
///
/// shadcn/ui expresses the space between elements as `gap-2`, `space-y-4` and
/// so on — a multiple of one variable rather than a pixel count. [Gap] is
/// the same idea: it sizes itself along whichever axis the enclosing flex runs,
/// so the same widget works in a row and a column, and the whole layout
/// rescales with `ThemeData.spacing`.
///
/// ```dart
/// Column(
///   children: [
///     const Text('Title'),
///     const Gap(2), // 8px with the default 4px step
///     const Text('Body'),
///   ],
/// )
/// ```
///
/// Outside a flex it lays out as a square of the same size.
class Gap extends LeafRenderObjectWidget {
  /// Creates a gap of [steps] steps on the spacing scale.
  const Gap(this.steps, {super.key, this.crossAxisSteps})
    : _raw = false,
      size = null;

  /// Creates a gap of a named [size] on the theme's gap scale.
  ///
  /// Unlike a step count, a named gap follows the form factor: `GapSize.lg`
  /// is 16 on a desktop and 12 on a phone in the default style.
  const Gap.size(GapSize this.size, {super.key})
    : steps = 0,
      crossAxisSteps = null,
      _raw = false;

  /// The theme's `xs` gap: between an icon and its label.
  const Gap.xs({Key? key}) : this.size(GapSize.xs, key: key);

  /// The theme's `sm` gap: between related controls.
  const Gap.sm({Key? key}) : this.size(GapSize.sm, key: key);

  /// The theme's `md` gap: between the rows of a group.
  const Gap.md({Key? key}) : this.size(GapSize.md, key: key);

  /// The theme's `lg` gap: between cards and sections.
  const Gap.lg({Key? key}) : this.size(GapSize.lg, key: key);

  /// The theme's `xl` gap: between the columns of a page.
  const Gap.xl({Key? key}) : this.size(GapSize.xl, key: key);

  /// Creates a gap of an explicit number of logical pixels, bypassing the
  /// scale.
  ///
  /// Useful when a design calls for a value that is deliberately off-scale.
  const Gap.raw(double pixels, {super.key, double? crossAxisExtent})
    : steps = pixels,
      crossAxisSteps = crossAxisExtent,
      _raw = true,
      size = null;

  /// The named size, for a gap made with [Gap.size] or one of its
  /// shorthands.
  final GapSize? size;

  /// How many steps of space to insert along the main axis.
  final double steps;

  /// How much space to occupy along the cross axis, in steps.
  ///
  /// Defaults to null, meaning the gap takes no cross-axis space of its own.
  final double? crossAxisSteps;

  final bool _raw;

  double _resolve(BuildContext context, double value) {
    if (_raw) return value;
    final theme = Theme.of(context);
    final named = size;
    return named == null ? theme.spacing(value) : theme.layoutTheme.gap(named);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGap(
      mainAxisExtent: _resolve(context, steps),
      crossAxisExtent: crossAxisSteps == null
          ? null
          : _resolve(context, crossAxisSteps!),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderGap)
      ..mainAxisExtent = _resolve(context, steps)
      ..crossAxisExtent = crossAxisSteps == null
          ? null
          : _resolve(context, crossAxisSteps!);
  }
}

class _RenderGap extends RenderBox {
  _RenderGap({required double mainAxisExtent, double? crossAxisExtent})
    : _mainAxisExtent = mainAxisExtent,
      _crossAxisExtent = crossAxisExtent;

  double get mainAxisExtent => _mainAxisExtent;
  double _mainAxisExtent;
  set mainAxisExtent(double value) {
    if (_mainAxisExtent == value) return;
    _mainAxisExtent = value;
    markNeedsLayout();
  }

  double? get crossAxisExtent => _crossAxisExtent;
  double? _crossAxisExtent;
  set crossAxisExtent(double? value) {
    if (_crossAxisExtent == value) return;
    _crossAxisExtent = value;
    markNeedsLayout();
  }

  /// The direction of the enclosing flex, or null when there isn't one.
  Axis? get _parentDirection {
    final parentNode = parent;
    return parentNode is RenderFlex ? parentNode.direction : null;
  }

  Size _computeSize(BoxConstraints constraints) {
    final cross = _crossAxisExtent ?? 0;
    final size = switch (_parentDirection) {
      Axis.horizontal => Size(_mainAxisExtent, cross),
      Axis.vertical => Size(cross, _mainAxisExtent),
      // Not in a flex: a square, which is the least surprising fallback.
      null => Size.square(_mainAxisExtent),
    };
    return constraints.constrain(size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _computeSize(constraints);

  @override
  void performLayout() => size = _computeSize(constraints);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _parentDirection == Axis.vertical
      ? (_crossAxisExtent ?? 0)
      : mainAxisExtent;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      computeMinIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _parentDirection == Axis.horizontal
      ? (_crossAxisExtent ?? 0)
      : mainAxisExtent;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);
}

/// [Padding] measured in steps on the theme's spacing scale.
///
/// The named constructors mirror [EdgeInsets], so `FinessePadding.symmetric(
/// horizontal: 6, vertical: 4)` is shadcn's `px-6 py-4`.
class FinessePadding extends StatelessWidget {
  /// The same number of steps on every side.
  const FinessePadding.all(double steps, {super.key, required this.child})
    : _left = steps,
      _top = steps,
      _right = steps,
      _bottom = steps,
      _start = null,
      _end = null;

  /// Steps on the horizontal and vertical axes.
  const FinessePadding.symmetric({
    super.key,
    required this.child,
    double horizontal = 0,
    double vertical = 0,
  }) : _left = horizontal,
       _right = horizontal,
       _top = vertical,
       _bottom = vertical,
       _start = null,
       _end = null;

  /// Steps on individually chosen sides.
  const FinessePadding.only({
    super.key,
    required this.child,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) : _left = left,
       _top = top,
       _right = right,
       _bottom = bottom,
       _start = null,
       _end = null;

  /// Steps on direction-relative sides, resolved against the ambient
  /// [Directionality].
  const FinessePadding.directional({
    super.key,
    required this.child,
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) : _start = start,
       _end = end,
       _top = top,
       _bottom = bottom,
       _left = null,
       _right = null;

  /// The widget to pad.
  final Widget child;

  final double? _left;
  final double? _right;
  final double? _start;
  final double? _end;
  final double _top;
  final double _bottom;

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;
    final padding = _start != null
        ? spacing.directional(
            start: _start,
            top: _top,
            end: _end!,
            bottom: _bottom,
          )
        : spacing.only(
            left: _left!,
            top: _top,
            right: _right!,
            bottom: _bottom,
          );
    return Padding(padding: padding, child: child);
  }
}

/// A [Column] whose `spacing` is expressed in steps on the theme's spacing
/// scale.
///
/// Equivalent to shadcn's `flex flex-col gap-N`.
class FinesseColumn extends StatelessWidget {
  /// Creates a column with [spacing] steps between its [children].
  const FinesseColumn({
    super.key,
    this.spacing = 0,
    this.gap,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.children = const [],
  });

  /// The gap between children, in steps.
  final double spacing;

  /// The space between children as a named step of the theme's gap scale.
  ///
  /// Takes precedence over [spacing], and follows the form factor.
  final GapSize? gap;

  /// How the children are placed vertically. Defaults to
  /// [MainAxisAlignment.start].
  final MainAxisAlignment mainAxisAlignment;

  /// How much height the column takes. Defaults to [MainAxisSize.max].
  final MainAxisSize mainAxisSize;

  /// How the children are placed horizontally. Defaults to
  /// [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// The direction used to resolve `start` and `end` in [crossAxisAlignment].
  /// Defaults to the ambient [Directionality].
  final TextDirection? textDirection;

  /// The order the children are laid out in. Defaults to
  /// [VerticalDirection.down].
  final VerticalDirection verticalDirection;

  /// The baseline to align to when [crossAxisAlignment] is
  /// [CrossAxisAlignment.baseline].
  final TextBaseline? textBaseline;

  /// The widgets in the column.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      spacing: gap == null
          ? theme.spacing(spacing)
          : theme.layoutTheme.gap(gap!),
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}

/// A [Row] whose `spacing` is expressed in steps on the theme's spacing scale.
///
/// Equivalent to shadcn's `flex items-center gap-N`.
class FinesseRow extends StatelessWidget {
  /// Creates a row with [spacing] steps between its [children].
  const FinesseRow({
    super.key,
    this.spacing = 0,
    this.gap,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.children = const [],
  });

  /// The gap between children, in steps.
  final double spacing;

  /// The space between children as a named step of the theme's gap scale.
  ///
  /// Takes precedence over [spacing], and follows the form factor.
  final GapSize? gap;

  /// How the children are placed horizontally. Defaults to
  /// [MainAxisAlignment.start].
  final MainAxisAlignment mainAxisAlignment;

  /// How much width the row takes. Defaults to [MainAxisSize.max].
  final MainAxisSize mainAxisSize;

  /// How the children are placed vertically. Defaults to
  /// [CrossAxisAlignment.center].
  final CrossAxisAlignment crossAxisAlignment;

  /// The order the children are laid out in. Defaults to the ambient
  /// [Directionality].
  final TextDirection? textDirection;

  /// The direction used to resolve `start` and `end` in [crossAxisAlignment].
  /// Defaults to [VerticalDirection.down].
  final VerticalDirection verticalDirection;

  /// The baseline to align to when [crossAxisAlignment] is
  /// [CrossAxisAlignment.baseline].
  final TextBaseline? textBaseline;

  /// The widgets in the row.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      spacing: gap == null
          ? theme.spacing(spacing)
          : theme.layoutTheme.gap(gap!),
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );
  }
}
