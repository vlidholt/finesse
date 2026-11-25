import 'dart:ui' as ui;

import 'package:finesse/src/components/chip.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// One chip of a [ChipGroup].
@immutable
class ChipGroupItem<T> {
  /// Creates a chip that stands for [value].
  const ChipGroupItem({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
    this.semanticLabel,
  });

  /// What the group reports when this chip is chosen.
  final T value;

  /// The chip's label, usually a [Text].
  final Widget label;

  /// A widget before the label, usually an icon.
  final Widget? leading;

  /// Whether the chip can be chosen.
  final bool enabled;

  /// A description for assistive technology, in place of the label.
  final String? semanticLabel;
}

/// A set of chips of which one or some are chosen: filters above a list,
/// the choices of a field.
///
/// ```dart
/// ChipGroup<String>.multiple(
///   values: _filters,
///   onValuesChanged: (values) => setState(() => _filters = values),
///   items: const [
///     ChipGroupItem(value: 'remote', label: Text('Remote')),
///     ChipGroupItem(value: 'full', label: Text('Full-time')),
///   ],
/// )
/// ```
///
/// It is controlled. The unnamed constructor holds one chosen chip:
/// [value], reported through [onChanged]. [ChipGroup.multiple] holds a set:
/// [values], reported through [onValuesChanged]. Either way the callback
/// gets what a tap would make of the selection and the parent decides;
/// with no callback the group is disabled. With [allowDeselection] false
/// the last chosen chip cannot be unchosen.
///
/// By default the chips wrap onto as many rows as they need. With [wrap]
/// false they stay on one row that scrolls sideways, fading at an edge
/// they continue beyond — the filter bar of a phone screen.
///
/// [leading] and [trailing] hold an action beside the choices — an "All
/// filters" chip that opens the rest — at the start and the end of the
/// first row. They are not chosen and do not scroll: in a group that
/// scrolls they stay where they are while the chips pass under the fade.
/// A group with either needs a bounded width.
///
/// The group is one Tab stop; the arrow keys, Home and End move the focus
/// between its chips. [leading] and [trailing] are Tab stops of their own.
class ChipGroup<T> extends StatefulWidget {
  /// Creates a group of chips of which at most one is chosen.
  const ChipGroup({
    required this.items,
    this.value,
    required this.onChanged,
    this.allowDeselection = true,
    this.wrap = true,
    this.showCheckmark,
    this.variant = ChipVariant.outline,
    this.alignment = WrapAlignment.start,
    this.padding,
    this.semanticLabel,
    this.leading,
    this.trailing,
    super.key,
  }) : _multiple = false,
       values = const {},
       onValuesChanged = null;

  /// Creates a group of chips of which any number are chosen.
  const ChipGroup.multiple({
    required this.items,
    required this.values,
    required this.onValuesChanged,
    this.allowDeselection = true,
    this.wrap = true,
    this.showCheckmark,
    this.variant = ChipVariant.outline,
    this.alignment = WrapAlignment.start,
    this.padding,
    this.semanticLabel,
    this.leading,
    this.trailing,
    super.key,
  }) : _multiple = true,
       value = null,
       onChanged = null;

  /// Whether the group was made by [ChipGroup.multiple].
  final bool _multiple;

  /// The chips, in order.
  final List<ChipGroupItem<T>> items;

  /// The value of the chosen chip, or null for none.
  final T? value;

  /// Called with the value of the chip a tap chooses, or with null when
  /// the chosen chip is tapped again and [allowDeselection] is true. Null
  /// disables the group.
  final ValueChanged<T?>? onChanged;

  /// The values of the chosen chips of a [ChipGroup.multiple].
  final Set<T> values;

  /// Called with the new set when a chip of a [ChipGroup.multiple] is
  /// tapped. Null disables the group.
  final ValueChanged<Set<T>>? onValuesChanged;

  /// Whether the selection may become empty: whether the last chosen chip
  /// can be unchosen.
  final bool allowDeselection;

  /// Whether the chips wrap onto further rows. False keeps them on one row
  /// that scrolls.
  final bool wrap;

  /// Whether a chosen chip shows a check. Defaults to the theme's.
  final bool? showCheckmark;

  /// How the chips are outlined.
  final ChipVariant variant;

  /// How the chips of a row are placed when the group is wider than they
  /// are. Only for a group that wraps.
  final WrapAlignment alignment;

  /// Room around the chips, inside the scroll view when the group
  /// scrolls: give a scrolling filter bar the page's margin here, so its
  /// chips line up with the page and still scroll to the screen's edge.
  final EdgeInsetsGeometry? padding;

  /// What the group chooses, for assistive technology.
  final String? semanticLabel;

  /// An action before the chips, usually a [Chip] with `onPressed`. It
  /// stays at the start of the first row.
  final Widget? leading;

  /// An action after the chips, usually a [Chip] with `onPressed`. It
  /// stays at the end of the first row.
  final Widget? trailing;

  @override
  State<ChipGroup<T>> createState() => _ChipGroupState<T>();
}

class _ChipGroupState<T> extends State<ChipGroup<T>> {
  final _nodes = <FocusNode>[];
  final _scroll = ScrollController();

  /// The chip that is the group's Tab stop: the one last focused.
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _syncNodes();
    final first = widget.items.indexWhere(
      (item) => _chosen.contains(item.value),
    );
    if (first >= 0) _current = first;
  }

  @override
  void didUpdateWidget(ChipGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  void _syncNodes() {
    final count = widget.items.length;
    while (_nodes.length > count) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < count) {
      final index = _nodes.length;
      late final FocusNode node;
      node = FocusNode(debugLabel: 'ChipGroup chip $index')
        ..addListener(() {
          if (node.hasFocus && _current != _nodes.indexOf(node)) {
            setState(() => _current = _nodes.indexOf(node));
          }
        });
      _nodes.add(node);
    }
    if (_current >= count) _current = count == 0 ? 0 : count - 1;
  }

  /// What is chosen, as a set whichever constructor made the group.
  Set<T> get _chosen => widget._multiple ? widget.values : {?widget.value};

  bool get _interactive => widget._multiple
      ? widget.onValuesChanged != null
      : widget.onChanged != null;

  bool _enabled(int index) => _interactive && widget.items[index].enabled;

  void _toggle(ChipGroupItem<T> item) {
    final values = _chosen;
    final chosen = values.contains(item.value);
    final Set<T> next;
    if (chosen) {
      if (!widget.allowDeselection && values.length == 1) return;
      next = {...values}..remove(item.value);
    } else {
      next = widget._multiple ? {...values, item.value} : {item.value};
    }
    if (widget._multiple) {
      widget.onValuesChanged?.call(next);
    } else {
      widget.onChanged?.call(next.firstOrNull);
    }
  }

  /// Moves the focus [step] chips on, skipping the ones that cannot take
  /// it, or to the first or last with [toEnd].
  void _move(int from, int step, {bool toEnd = false}) {
    final count = widget.items.length;
    var index = toEnd ? (step > 0 ? -1 : count) : from;
    for (var i = 0; i < count; i++) {
      index += step;
      if (index < 0 || index >= count) return;
      if (_enabled(index)) break;
    }
    if (index < 0 || index >= count || !_enabled(index)) return;
    _nodes[index].requestFocus();
    final target = _nodes[index].context;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        alignment: .5,
        duration: const Duration(milliseconds: 160),
      );
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final from = _nodes.indexWhere((n) => n.hasFocus);
    if (from < 0) return KeyEventResult.ignored;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      _move(from, rtl ? -1 : 1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _move(from, rtl ? 1 : -1);
    } else if (key == LogicalKeyboardKey.home) {
      _move(from, 1, toEnd: true);
    } else if (key == LogicalKeyboardKey.end) {
      _move(from, -1, toEnd: true);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chip = theme.chipTheme;
    final spacing = chip.groupSpacing ?? 8;

    final chips = [
      for (final (index, item) in widget.items.indexed)
        Builder(
          builder: (context) {
            // One Tab stop for the group: the arrows reach the others.
            _nodes[index].skipTraversal = index != _current;
            return Chip(
              label: item.label,
              leading: item.leading,
              semanticLabel: item.semanticLabel,
              selected: _chosen.contains(item.value),
              showCheckmark: widget.showCheckmark,
              variant: widget.variant,
              focusNode: _nodes[index],
              enabled: _enabled(index),
              onSelected: (_) => _toggle(item),
            );
          },
        ),
    ];

    final Widget body;
    if (widget.wrap) {
      body = Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Wrap(
          spacing: spacing,
          runSpacing: chip.groupRunSpacing ?? spacing,
          alignment: widget.alignment,
          children: chips,
        ),
      );
    } else {
      body = _EdgeFade(
        controller: _scroll,
        extent: chip.groupFade ?? 24,
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          // The chips' focus rings and shadows reach past the row.
          clipBehavior: Clip.none,
          child: Row(spacing: spacing, children: chips),
        ),
      );
    }

    Widget group = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: body,
    );
    final leading = widget.leading;
    final trailing = widget.trailing;
    if (leading != null || trailing != null) {
      // Beside the first row, whatever the chips wrap to, and outside the
      // scroll view of a group that scrolls.
      group = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing,
        children: [
          ?leading,
          Expanded(child: group),
          ?trailing,
        ],
      );
    }

    return Semantics(
      container: true,
      // The group is named; each chip, and the actions beside them, is a
      // node of its own. Without this a lone chip beside a scroll view
      // merged into the group's node and lost its name.
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: group,
    );
  }
}

/// Fades its child out at the horizontal edges a scroll view continues
/// beyond, and costs nothing while it does not.
class _EdgeFade extends SingleChildRenderObjectWidget {
  const _EdgeFade({
    required this.controller,
    required this.extent,
    required super.child,
  });

  final ScrollController controller;
  final double extent;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEdgeFade(
    controller: controller,
    extent: extent,
    textDirection: Directionality.of(context),
  );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderEdgeFade renderObject,
  ) {
    renderObject
      ..controller = controller
      ..extent = extent
      ..textDirection = Directionality.of(context);
  }
}

class _RenderEdgeFade extends RenderProxyBox {
  _RenderEdgeFade({
    required ScrollController controller,
    required double extent,
    required TextDirection textDirection,
  }) : _controller = controller,
       _extent = extent,
       _textDirection = textDirection;

  ScrollController get controller => _controller;
  ScrollController _controller;
  set controller(ScrollController value) {
    if (identical(value, _controller)) return;
    if (attached) _controller.removeListener(_onScroll);
    _controller = value;
    if (attached) _controller.addListener(_onScroll);
    _onScroll();
  }

  double get extent => _extent;
  double _extent;
  set extent(double value) {
    if (value == _extent) return;
    _extent = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  /// How much of each edge fades, from 0 to 1: left, then right.
  double _left = 0;
  double _right = 0;

  bool get _fading => _left > 0 || _right > 0;

  @override
  bool get alwaysNeedsCompositing => _fading;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _controller.addListener(_onScroll);
  }

  @override
  void detach() {
    _controller.removeListener(_onScroll);
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    // The scroll view below has its extents now.
    _measure();
  }

  void _onScroll() {
    final was = _fading;
    final left = _left;
    final right = _right;
    _measure();
    if (left == _left && right == _right) return;
    if (was != _fading) markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  void _measure() {
    if (!_controller.hasClients) {
      _left = _right = 0;
      return;
    }
    final position = _controller.position;
    if (!position.hasContentDimensions || _extent <= 0) {
      _left = _right = 0;
      return;
    }
    // The fade grows in over its own length, so it does not pop.
    final before = ((position.pixels - position.minScrollExtent) / _extent)
        .clamp(0.0, 1.0);
    final after = ((position.maxScrollExtent - position.pixels) / _extent)
        .clamp(0.0, 1.0);
    // A horizontal scroll view starts at the right where text does.
    final rtl = _textDirection == TextDirection.rtl;
    _left = rtl ? after : before;
    _right = rtl ? before : after;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    // The scroll view does not clip, so that focus rings and shadows can
    // reach past the row; sideways it has to be cut off all the same.
    final clip = Rect.fromLTRB(
      0,
      -_extent,
      size.width,
      size.height + _extent,
    );
    if (!_fading || size.width <= 0) {
      layer = null;
      context.clipRectAndPaint(
        clip.shift(offset),
        Clip.hardEdge,
        clip.shift(offset),
        () => super.paint(context, offset),
      );
      return;
    }
    final stop = (_extent / size.width).clamp(0.0, .5);
    final shader = ui.Gradient.linear(
      Offset.zero,
      Offset(size.width, 0),
      [
        Color.fromRGBO(0, 0, 0, 1 - _left),
        const Color(0xFF000000),
        const Color(0xFF000000),
        Color.fromRGBO(0, 0, 0, 1 - _right),
      ],
      [0, stop, 1 - stop, 1],
    );
    final maskLayer = (layer as ShaderMaskLayer?) ?? ShaderMaskLayer()
      ..shader = shader
      ..maskRect = clip.shift(offset)
      ..blendMode = BlendMode.dstIn;
    context.pushLayer(
      maskLayer,
      (context, offset) => context.pushClipRect(
        needsCompositing,
        offset,
        clip,
        super.paint,
      ),
      offset,
    );
    layer = maskLayer;
  }
}
