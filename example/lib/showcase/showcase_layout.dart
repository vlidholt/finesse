import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// The showcase's column grid: how many columns the page has room for, and
/// where each one starts.
///
/// Everything on the page is placed on it — the header, the rows of wide
/// cards and the masonry of the rest — so a card two columns wide is
/// exactly two columns and the gutter between them, and its edges meet the
/// edges of the cards above and below it at every width.
@immutable
class ShowcaseColumns {
  /// The grid for a page [width] wide, with [gap] between columns.
  factory ShowcaseColumns.of(double width, double gap) => ShowcaseColumns._(
    count: width >= 1040
        ? 3
        : width >= 680
        ? 2
        : 1,
    gap: gap,
    width: width,
  );

  const ShowcaseColumns._({
    required this.count,
    required this.gap,
    required this.width,
  });

  /// How many columns there are.
  final int count;

  /// The gutter between two columns, and between two cards in a column.
  final double gap;

  /// The width of the whole grid.
  final double width;

  /// The width of one column.
  double get column => (width - gap * (count - 1)) / count;

  /// The width of something [columns] columns wide: the columns and the
  /// gutters between them.
  double span(int columns) {
    final n = columns.clamp(1, count);
    return column * n + gap * (n - 1);
  }

  /// Where column [index] starts, from the start edge.
  double start(int index) => index * (column + gap);

  @override
  bool operator ==(Object other) =>
      other is ShowcaseColumns &&
      other.count == count &&
      other.gap == gap &&
      other.width == width;

  @override
  int get hashCode => Object.hash(count, gap, width);
}

/// A row of [children] on the grid, each as many columns wide as its entry
/// in [spans] says, all as tall as the tallest.
class ShowcaseSpanRow extends StatelessWidget {
  const ShowcaseSpanRow({
    required this.columns,
    required this.spans,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.key,
  }) : assert(spans.length == children.length, 'One span per child');

  final ShowcaseColumns columns;
  final List<int> spans;
  final List<Widget> children;

  /// How the children share the row's height: stretched to the tallest by
  /// default.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: crossAxisAlignment,
      spacing: columns.gap,
      children: [
        for (final (i, child) in children.indexed)
          SizedBox(width: columns.span(spans[i]), child: child),
      ],
    );
    return crossAxisAlignment == CrossAxisAlignment.stretch
        ? IntrinsicHeight(child: row)
        : row;
  }
}

/// Cards in the grid's columns, each put at the foot of the shortest column
/// so far (the first of them on a tie), so the columns end close together
/// and the order still reads across. Columns that end within two gutters
/// of each other end level: the last card of each is made as much taller.
///
/// Every child is one column wide. The children keep their place in the
/// tree whatever the number of columns, so a card keeps its state when the
/// window is resized.
class ShowcaseMasonry extends MultiChildRenderObjectWidget {
  const ShowcaseMasonry({
    required this.columns,
    required super.children,
    super.key,
  });

  final ShowcaseColumns columns;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMasonry(
    count: columns.count,
    gap: columns.gap,
    textDirection: Directionality.of(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    renderObject as _RenderMasonry
      ..count = columns.count
      ..gap = columns.gap
      ..textDirection = Directionality.of(context);
  }
}

class _MasonryParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderMasonry extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MasonryParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _MasonryParentData> {
  _RenderMasonry({
    required this._count,
    required this._gap,
    required this._textDirection,
  });

  int get count => _count;
  int _count;
  set count(int value) {
    if (value == _count) return;
    _count = value;
    markNeedsLayout();
  }

  double get gap => _gap;
  double _gap;
  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MasonryParentData) {
      child.parentData = _MasonryParentData();
    }
  }

  /// Places every child for a grid [width] wide, sizing each with [size],
  /// and returns the height of the tallest column. With [lasts], each
  /// child's offset is written as well, and [lasts] is filled with the
  /// last child of each column and where that column ends.
  double _arrange(
    double width,
    double Function(RenderBox child, double width) size, {
    List<(RenderBox, double)?>? lasts,
  }) {
    final grid = ShowcaseColumns._(count: _count, gap: _gap, width: width);
    final bottoms = List<double>.filled(_count, 0);
    final ends = List<(RenderBox, double)?>.filled(_count, null);
    var child = firstChild;
    while (child != null) {
      var column = 0;
      for (var c = 1; c < _count; c++) {
        if (bottoms[c] < bottoms[column]) column = c;
      }
      final height = size(child, grid.column);
      if (lasts != null) {
        final start = grid.start(column);
        final x = _textDirection == TextDirection.ltr
            ? start
            : width - start - grid.column;
        (child.parentData! as _MasonryParentData).offset = Offset(
          x,
          bottoms[column],
        );
        ends[column] = (child, bottoms[column] + height);
      }
      bottoms[column] += height + _gap;
      child = childAfter(child);
    }
    lasts?.addAll(ends);
    return childCount == 0 ? 0 : bottoms.reduce(math.max) - _gap;
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final lasts = <(RenderBox, double)?>[];
    final height = _arrange(width, (child, column) {
      child.layout(
        BoxConstraints.tightFor(width: column),
        parentUsesSize: true,
      );
      return child.size.height;
    }, lasts: lasts);
    // Columns that end within two gutters of the longest are made to end
    // with it, their last card that much taller, so a row under them
    // starts one gutter below every column. Further apart, a card would
    // show a hole of its own instead.
    for (final last in lasts) {
      if (last == null) continue;
      final (child, end) = last;
      final slack = height - end;
      if (slack <= 0 || slack > _gap * 2) continue;
      child.layout(
        BoxConstraints.tightFor(
          width: child.size.width,
          height: child.size.height + slack,
        ),
        parentUsesSize: true,
      );
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = _arrange(
      width,
      (child, column) =>
          child.getDryLayout(BoxConstraints.tightFor(width: column)).height,
    );
    return constraints.constrain(Size(width, height));
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _arrange(width, (child, column) => child.getMinIntrinsicHeight(column));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _arrange(width, (child, column) => child.getMaxIntrinsicHeight(column));

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
}
