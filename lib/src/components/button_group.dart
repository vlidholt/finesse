import 'dart:math' as math;

import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Joins buttons into one control: a toolbar cluster, a split button, a
/// stepper's minus and plus around its value.
///
/// ```dart
/// ButtonGroup(
///   children: [
///     Button.outline(onPressed: _archive, child: const Text('Archive')),
///     Button.outline(onPressed: _report, child: const Text('Report')),
///     IconButton.outline(
///       tooltip: 'More',
///       onPressed: _more,
///       icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
///     ),
///   ],
/// )
/// ```
///
/// The children keep their own variant and size. What the group changes is
/// where they meet: the corners between two children are squared, and two
/// outlined children share one hairline instead of drawing one each.
/// `Button`, `IconButton` and `Toggle` do that by themselves inside a
/// group; a control of your own reads its place from [ButtonGroupScope].
///
/// Children that have no outline — primary, secondary — run into each
/// other; put a [ButtonGroupSeparator] between them. A [ButtonGroupText]
/// is a label that sits in the group like a button: a unit, a prefix.
///
/// A child can be a button wrapped in something that is not one — a
/// `DropdownMenu` around the trigger of a split button, a `Tooltip` — and
/// still takes its place; each child should hold one such control.
///
/// Every child is as tall as the tallest (as wide as the widest, on a
/// vertical [axis]), and the one that has the keyboard focus is painted
/// last, so its focus ring lies over its neighbours rather than under the
/// next one.
class ButtonGroup extends StatefulWidget {
  /// Creates a group of joined buttons.
  const ButtonGroup({
    required this.children,
    this.axis = Axis.horizontal,
    this.semanticLabel,
    super.key,
  });

  /// The controls to join, in order.
  final List<Widget> children;

  /// The direction the children are laid out in.
  final Axis axis;

  /// What assistive technology calls the group.
  final String? semanticLabel;

  @override
  State<ButtonGroup> createState() => _ButtonGroupState();
}

class _ButtonGroupState extends State<ButtonGroup> {
  int? _focused;

  void _setFocused(int index, bool focused) {
    if (!mounted) return;
    if (focused) {
      if (_focused != index) setState(() => _focused = index);
    } else if (_focused == index) {
      setState(() => _focused = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: _ButtonGroupLayout(
        axis: widget.axis,
        textDirection: Directionality.of(context),
        paintLast: _focused != null && _focused! < count ? _focused : null,
        children: [
          for (final (index, child) in widget.children.indexed)
            _ButtonGroupSlot(
              axis: widget.axis,
              isFirst: index == 0,
              isLast: index == count - 1,
              onFocusChange: (focused) => _setFocused(index, focused),
              child: child,
            ),
        ],
      ),
    );
  }
}

/// One child of a group: tells it its place and hears of its focus.
class _ButtonGroupSlot extends StatefulWidget {
  const _ButtonGroupSlot({
    required this.axis,
    required this.isFirst,
    required this.isLast,
    required this.onFocusChange,
    required this.child,
  });

  final Axis axis;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<bool> onFocusChange;
  final Widget child;

  @override
  State<_ButtonGroupSlot> createState() => _ButtonGroupSlotState();
}

class _ButtonGroupSlotState extends State<_ButtonGroupSlot> {
  /// The control that took this place. A menu opened from a button in the
  /// group is built below the button's own place in the tree; its rows are
  /// buttons too, and must not be squared off as if they were in the group.
  Element? _claimant;

  bool _claim(Element element) {
    final claimant = _claimant;
    if (claimant == null || !claimant.mounted || identical(claimant, element)) {
      _claimant = element;
      return true;
    }
    return false;
  }

  /// Gives the place up when its control is deactivated. A control replaced
  /// by one of another type is still mounted while its successor is built,
  /// and would otherwise keep the place from it until something rebuilt the
  /// successor again.
  void _release(Element element) {
    if (identical(_claimant, element)) _claimant = null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: widget.onFocusChange,
      child: ButtonGroupScope._(
        axis: widget.axis,
        isFirst: widget.isFirst,
        isLast: widget.isLast,
        slot: this,
        child: widget.child,
      ),
    );
  }
}

/// The place of a control in a [ButtonGroup].
///
/// `Button`, `IconButton`, `Toggle`, [ButtonGroupText] and
/// [ButtonGroupSeparator] read it to join their neighbours. A control of
/// your own does the same:
///
/// ```dart
/// final group = ButtonGroupScope.maybeOf(context);
/// final decoration = group == null
///     ? myDecoration
///     : group.join(myDecoration, Directionality.of(context));
/// ```
///
/// Each child of a group has one place, and the first control built under
/// it takes it: [maybeOf] returns null to anything built under the same
/// child afterwards — the rows of a menu the control opens, for one.
class ButtonGroupScope extends InheritedWidget {
  const ButtonGroupScope._({
    required this.axis,
    required this.isFirst,
    required this.isLast,
    required _ButtonGroupSlotState slot,
    required super.child,
  }) : _slot = slot;

  /// The direction the group is laid out in.
  final Axis axis;

  /// Whether the control is the first of the group: its leading corners
  /// stay round and it keeps its leading edge.
  final bool isFirst;

  /// Whether the control is the last of the group: its trailing corners
  /// stay round.
  final bool isLast;

  final _ButtonGroupSlotState _slot;

  @override
  InheritedElement createElement() => _ButtonGroupScopeElement(this);

  /// The place of the control at [context] in the nearest [ButtonGroup], or
  /// null when it is not in one, or its place is already taken.
  static ButtonGroupScope? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ButtonGroupScope>();
    if (scope == null) return null;
    return scope._slot._claim(context as Element) ? scope : null;
  }

  /// The place of whatever is at [context], without taking it: for a part
  /// of the group that is not a control, like a separator.
  static ButtonGroupScope? _peek(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ButtonGroupScope>();

  /// Whether [context] is somewhere under a child of a [ButtonGroup]. It
  /// takes no place: for a wrapper that only needs to know.
  static bool isWithin(BuildContext context) => _peek(context) != null;

  /// [decoration] as it is drawn at this place in the group.
  ///
  /// The corners towards a neighbour are squared, on the outline and on the
  /// focus ring alike. A control that is not the first gives up the edge
  /// towards the one before it, so two outlines meet in one hairline — the
  /// other's — and takes the width of that edge as padding instead, so its
  /// content stays exactly where it was. A focused border of its own (the
  /// inside focus ring) keeps all four sides.
  ///
  /// [fallback] is the decoration [decoration] is merged over when it is
  /// drawn, usually the theme's `decoration`: an outline or a ring that
  /// [decoration] leaves to it is joined too.
  FinesseDecoration join(
    FinesseDecoration decoration,
    TextDirection textDirection, {
    FinesseDecoration? fallback,
  }) {
    final merged = fallback == null ? decoration : fallback.merge(decoration);
    final horizontal = axis == Axis.horizontal;
    final ltr = textDirection == TextDirection.ltr;

    BorderRadiusGeometry? squared(BorderRadiusGeometry? radius) {
      if (radius == null) return null;
      final resolved = radius.resolve(textDirection);
      // The corners on the side of the previous child, and of the next.
      final keepBefore = isFirst;
      final keepAfter = isLast;
      if (horizontal) {
        final keepLeft = ltr ? keepBefore : keepAfter;
        final keepRight = ltr ? keepAfter : keepBefore;
        return resolved.copyWith(
          topLeft: keepLeft ? null : Radius.zero,
          bottomLeft: keepLeft ? null : Radius.zero,
          topRight: keepRight ? null : Radius.zero,
          bottomRight: keepRight ? null : Radius.zero,
        );
      }
      return resolved.copyWith(
        topLeft: keepBefore ? null : Radius.zero,
        topRight: keepBefore ? null : Radius.zero,
        bottomLeft: keepAfter ? null : Radius.zero,
        bottomRight: keepAfter ? null : Radius.zero,
      );
    }

    FinesseBorder? ring(FinesseBorder? border) {
      if (border == null || border is FinesseRoundedSuperellipseBorder) {
        return border;
      }
      // Not `copyWith`: a null radius has to stay null.
      return FinesseBorder(
        canMerge: border.canMerge,
        top: border.top,
        right: border.right,
        bottom: border.bottom,
        left: border.left,
        padding: border.padding,
        borderRadius: squared(border.borderRadius),
        offset: border.offset,
      );
    }

    FinesseBorder? outline(FinesseBorder? border) {
      final joined = ring(border);
      if (joined == null ||
          joined is FinesseRoundedSuperellipseBorder ||
          isFirst) {
        return joined;
      }
      final side = horizontal ? (ltr ? joined.left : joined.right) : joined.top;
      final width = side?.width ?? 0;
      if (side == null || width == 0) return joined;
      const none = EdgeInsets.zero;
      final given = side.copyWith(width: 0);
      final reserve = horizontal
          ? (ltr ? EdgeInsets.only(left: width) : EdgeInsets.only(right: width))
          : EdgeInsets.only(top: width);
      return FinesseBorder(
        canMerge: joined.canMerge,
        top: horizontal ? joined.top : given,
        right: horizontal && !ltr ? given : joined.right,
        bottom: joined.bottom,
        left: horizontal && ltr ? given : joined.left,
        padding: (joined.padding ?? none).add(reserve),
        borderRadius: joined.borderRadius,
        offset: joined.offset,
      );
    }

    return merged.copyWith(
      border: outline(merged.border),
      errorBorder: outline(merged.errorBorder),
      // Without a focused border of its own the control is drawn with its
      // resting one, which has been joined above.
      focusedBorder: ring(merged.focusedBorder),
      secondaryBorder: ring(merged.secondaryBorder),
      secondaryFocusedBorder: ring(merged.secondaryFocusedBorder),
      secondaryErrorBorder: ring(merged.secondaryErrorBorder),
    );
  }

  @override
  bool updateShouldNotify(ButtonGroupScope oldWidget) =>
      axis != oldWidget.axis ||
      isFirst != oldWidget.isFirst ||
      isLast != oldWidget.isLast;
}

/// Hears of each control under a group's child being deactivated, which is
/// when the control's place is free again.
class _ButtonGroupScopeElement extends InheritedElement {
  _ButtonGroupScopeElement(ButtonGroupScope super.widget);

  @override
  void removeDependent(Element dependent) {
    (widget as ButtonGroupScope)._slot._release(dependent);
    super.removeDependent(dependent);
  }
}

/// A hairline between two children of a [ButtonGroup] that have no outline
/// of their own: between the two halves of a secondary split button.
///
/// It runs across the group — vertical in a horizontal group — and is as
/// long as the group is tall.
class ButtonGroupSeparator extends StatelessWidget {
  /// Creates a separator.
  const ButtonGroupSeparator({this.color, this.thickness = 1, super.key});

  /// The colour of the line. Defaults to the scheme's `input`, the colour
  /// of an outlined control's edge.
  final Color? color;

  /// The thickness of the line.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final axis = ButtonGroupScope._peek(context)?.axis ?? Axis.horizontal;
    return ExcludeSemantics(
      child: ColoredBox(
        color: color ?? Theme.of(context).colorScheme.input,
        child: axis == Axis.horizontal
            ? SizedBox(width: thickness)
            : SizedBox(height: thickness),
      ),
    );
  }
}

/// A label that sits in a [ButtonGroup] like a button: "https://" before a
/// field's worth of buttons, a count between a minus and a plus.
///
/// It has the outline of an outline button on a muted fill, and joins its
/// neighbours as they do.
class ButtonGroupText extends StatelessWidget {
  /// Creates a label for a button group.
  const ButtonGroupText({required this.child, this.padding, super.key});

  /// The label: usually a `Text`, or a row of an icon and one.
  final Widget child;

  /// The padding around [child]. Defaults to the regular button's
  /// horizontal padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final outline = theme.outlineButtonTheme;
    final size = theme.buttonSizesTheme.regular!;
    final direction = Directionality.of(context);
    final group = ButtonGroupScope.maybeOf(context);

    var decoration = (outline.decoration ?? const FinesseDecoration()).copyWith(
      color: theme.colorScheme.muted,
    );
    if (group != null) {
      decoration = group.join(
        decoration,
        direction,
        fallback: theme.decoration,
      );
    }
    final horizontal = (padding ?? size.padding)
        .resolve(direction)
        .copyWith(
          top: 0,
          bottom: 0,
        );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: size.height),
      child: Decorator(
        decoration: decoration,
        child: Padding(
          padding: horizontal,
          // As large as the label where the group leaves it free, centred
          // where the group makes it as tall as its tallest child.
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: IconTheme.merge(
              data: IconThemeData(
                size: size.iconSize,
                color: theme.colorScheme.foreground,
              ),
              child: DefaultTextStyle.merge(
                style: (outline.textStyle ?? theme.textTheme.small).copyWith(
                  color: theme.colorScheme.foreground,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonGroupLayout extends MultiChildRenderObjectWidget {
  const _ButtonGroupLayout({
    required this.axis,
    required this.textDirection,
    required this.paintLast,
    required super.children,
  });

  final Axis axis;
  final TextDirection textDirection;
  final int? paintLast;

  @override
  RenderButtonGroup createRenderObject(BuildContext context) =>
      RenderButtonGroup(
        axis: axis,
        textDirection: textDirection,
        paintLast: paintLast,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderButtonGroup renderObject,
  ) {
    renderObject
      ..axis = axis
      ..textDirection = textDirection
      ..paintLast = paintLast;
  }
}

class _ButtonGroupParentData extends ContainerBoxParentData<RenderBox> {}

/// Lays the children of a `ButtonGroup` out edge to edge, each as large
/// across the group as the largest, and paints the focused one last.
///
/// Public for tests.
@visibleForTesting
class RenderButtonGroup extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ButtonGroupParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ButtonGroupParentData> {
  /// Creates the layout.
  RenderButtonGroup({
    required Axis axis,
    required TextDirection textDirection,
    required int? paintLast,
  }) : _axis = axis,
       _textDirection = textDirection,
       _paintLast = paintLast;

  /// The direction the children are laid out in.
  Axis get axis => _axis;
  Axis _axis;
  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    markNeedsLayout();
  }

  /// The direction a horizontal group reads in.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  /// The index of the child painted over the others, or null.
  int? get paintLast => _paintLast;
  int? _paintLast;
  set paintLast(int? value) {
    if (_paintLast == value) return;
    _paintLast = value;
    markNeedsPaint();
  }

  bool get _horizontal => axis == Axis.horizontal;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ButtonGroupParentData) {
      child.parentData = _ButtonGroupParentData();
    }
  }

  double _sum(double Function(RenderBox child) of) {
    var total = 0.0;
    var child = firstChild;
    while (child != null) {
      total += of(child);
      child = childAfter(child);
    }
    return total;
  }

  double _max(double Function(RenderBox child) of) {
    var largest = 0.0;
    var child = firstChild;
    while (child != null) {
      largest = math.max(largest, of(child));
      child = childAfter(child);
    }
    return largest;
  }

  @override
  double computeMinIntrinsicWidth(double height) => _horizontal
      ? _sum((child) => child.getMinIntrinsicWidth(height))
      : _max((child) => child.getMinIntrinsicWidth(double.infinity));

  @override
  double computeMaxIntrinsicWidth(double height) => _horizontal
      ? _sum((child) => child.getMaxIntrinsicWidth(height))
      : _max((child) => child.getMaxIntrinsicWidth(double.infinity));

  @override
  double computeMinIntrinsicHeight(double width) => _horizontal
      ? _max((child) => child.getMinIntrinsicHeight(double.infinity))
      : _sum((child) => child.getMinIntrinsicHeight(width));

  @override
  double computeMaxIntrinsicHeight(double width) => _horizontal
      ? _max((child) => child.getMaxIntrinsicHeight(double.infinity))
      : _sum((child) => child.getMaxIntrinsicHeight(width));

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  Size _layout(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) layoutChild, {
    required bool position,
  }) {
    // Each child at its own size first, to learn how large the group is
    // across; then the ones that are smaller again, at that size. No
    // intrinsics: a child may be something that has none.
    final loose = _horizontal
        ? BoxConstraints(maxHeight: constraints.maxHeight)
        : BoxConstraints(maxWidth: constraints.maxWidth);
    final sizes = <Size>[];
    var cross = _horizontal ? constraints.minHeight : constraints.minWidth;
    var child = firstChild;
    while (child != null) {
      final size = layoutChild(child, loose);
      sizes.add(size);
      cross = math.max(cross, _horizontal ? size.height : size.width);
      child = childAfter(child);
    }
    var main = 0.0;
    var index = 0;
    child = firstChild;
    while (child != null) {
      var size = sizes[index];
      if ((_horizontal ? size.height : size.width) != cross) {
        size = layoutChild(
          child,
          _horizontal
              ? BoxConstraints(minHeight: cross, maxHeight: cross)
              : BoxConstraints(minWidth: cross, maxWidth: cross),
        );
        sizes[index] = size;
      }
      main += _horizontal ? size.width : size.height;
      index++;
      child = childAfter(child);
    }
    final size = constraints.constrain(
      _horizontal ? Size(main, cross) : Size(cross, main),
    );
    if (position) {
      final rtl = _horizontal && textDirection == TextDirection.rtl;
      var offset = rtl ? size.width : 0.0;
      index = 0;
      child = firstChild;
      while (child != null) {
        final childSize = sizes[index];
        final parentData = child.parentData! as _ButtonGroupParentData;
        if (_horizontal) {
          if (rtl) offset -= childSize.width;
          parentData.offset = Offset(offset, 0);
          if (!rtl) offset += childSize.width;
        } else {
          parentData.offset = Offset(0, offset);
          offset += childSize.height;
        }
        index++;
        child = childAfter(child);
      }
    }
    return size;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layout(
    constraints,
    (child, constraints) => child.getDryLayout(constraints),
    position: false,
  );

  @override
  void performLayout() {
    size = _layout(
      constraints,
      (child, constraints) {
        child.layout(constraints, parentUsesSize: true);
        return child.size;
      },
      position: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? last;
    var index = 0;
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _ButtonGroupParentData;
      if (index == paintLast) {
        last = child;
      } else {
        context.paintChild(child, parentData.offset + offset);
      }
      index++;
      child = childAfter(child);
    }
    if (last != null) {
      final parentData = last.parentData! as _ButtonGroupParentData;
      context.paintChild(last, parentData.offset + offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
