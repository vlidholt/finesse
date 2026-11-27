import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/button_group.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/disabled.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/components/toggle.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/debug_check.dart';
import 'package:una/src/utils/motion_color.dart';
import 'package:una/src/utils/moving_indicator.dart';
import 'package:una/src/utils/provider.dart';
import 'package:una/src/utils/text_scaled_height.dart';

/// Variants available for the [Toggle] widget.
enum ToggleVariant {
  /// A borderless toggle with a muted fill when pressed.
  primary,

  /// A bordered toggle with a subtle shadow.
  outline,
}

/// {@template Toggle}
/// A two-state button that stays pressed when on.
///
/// Mirrors shadcn/ui's `Toggle`. Use it for a single on/off control that reads
/// as a button rather than a checkbox — bold/italic in a text toolbar, for
/// example. For a set of related toggles, use [ToggleGroup].
///
/// ```dart
/// Toggle(
///   value: bold,
///   onChanged: (v) => setState(() => bold = v),
///   child: const PhosphorIcon(PhosphorIconsRegular.textB),
/// )
/// ```
///
/// Prefer `Switch` when the control turns a *setting* on and off, and
/// `Checkbox` when it selects an item. This is for a formatting-style
/// action.
///
/// How it looks comes from the variant's `ToggleTheme` in the theme; a
/// [style] restyles one toggle, merged over it.
/// {@endtemplate}
class Toggle extends StatelessWidget {
  /// {@macro Toggle}
  const Toggle({
    super.key,
    this.variant = ToggleVariant.primary,
    required this.value,
    required this.child,
    this.leading,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  });

  /// A bordered toggle, matching shadcn/ui's `variant="outline"`.
  const Toggle.outline({
    super.key,
    required this.value,
    required this.child,
    this.leading,
    this.onChanged,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
    this.onHover,
    this.onFocusChange,
    this.mouseCursor,
    this.semanticLabel,
    this.style,
  }) : variant = ToggleVariant.outline;

  /// The visual style of the toggle. Set by the constructor:
  /// [ToggleVariant.primary] for [Toggle.new] and
  /// [ToggleVariant.outline] for [Toggle.outline].
  final ToggleVariant variant;

  /// Whether the toggle is on.
  final bool value;

  /// The content of the toggle, usually an [Icon] or a [Text].
  final Widget child;

  /// An optional widget shown before [child].
  final Widget? leading;

  /// Called with the new value when the toggle is pressed.
  ///
  /// A null callback disables the toggle, matching the rest of the package.
  final ValueChanged<bool>? onChanged;

  /// Whether the toggle responds to input, defaults to `true`.
  final bool enabled;

  /// The focus node of the toggle. When null, the toggle creates its own.
  final FocusNode? focusNode;

  /// Whether to take focus when first built, if nothing else has focus.
  /// Defaults to false.
  final bool autofocus;

  /// Holds the interaction states of the toggle — hovered, pressed, focused,
  /// selected while it is on, and disabled — for whoever else wants to
  /// follow them.
  final WidgetStatesController? statesController;

  /// Called when a mouse pointer enters or leaves the enabled toggle.
  final ValueChanged<bool>? onHover;

  /// Called with the new focus state each time it changes.
  final ValueChanged<bool>? onFocusChange;

  /// The cursor over the enabled toggle. Defaults to
  /// [SystemMouseCursors.click].
  final MouseCursor? mouseCursor;

  /// The accessible name, needed when [child] is icon-only.
  final String? semanticLabel;

  /// Overrides of the variant's look for this one toggle: colours, padding,
  /// decoration, size, text style.
  ///
  /// It is merged over the variant's `ToggleTheme` from the theme, so only
  /// the fields that are set change anything.
  final ToggleTheme? style;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final toggleTheme = switch (variant) {
      ToggleVariant.primary => theme.toggleTheme,
      ToggleVariant.outline => theme.outlineToggleTheme,
    }.merge(style);

    final enabled = this.enabled && onChanged != null;
    final selected = value;

    final padding =
        toggleTheme.padding ?? const EdgeInsets.symmetric(horizontal: 12);
    final height = toggleTheme.height ?? 40.0;
    final width = toggleTheme.width;
    final gap = toggleTheme.gap ?? 8.0;
    var decoration = toggleTheme.decoration ?? const UnaDecoration();
    // In a `ButtonGroup` — a toggle group with no gap is one — the corners
    // and the edge towards a neighbour are the group's to decide.
    final joined = ButtonGroupScope.maybeOf(context);
    if (joined != null) {
      decoration = joined.join(
        decoration,
        Directionality.of(context),
        fallback: theme.decoration,
      );
    }

    Color? backgroundFor({required bool hovered}) {
      if (selected) {
        return hovered
            ? toggleTheme.selectedHoverBackgroundColor ??
                  theme.colorScheme.accent
            : toggleTheme.selectedBackgroundColor ?? theme.colorScheme.accent;
      }
      return hovered
          ? toggleTheme.hoverBackgroundColor ?? theme.colorScheme.muted
          : toggleTheme.backgroundColor;
    }

    Color foregroundFor({required bool hovered}) {
      if (selected) {
        return toggleTheme.selectedForegroundColor ??
            theme.colorScheme.accentForeground;
      }
      return hovered
          ? toggleTheme.hoverForegroundColor ??
                theme.colorScheme.mutedForeground
          : toggleTheme.foregroundColor ?? theme.colorScheme.foreground;
    }

    final iconSize = toggleTheme.iconSize ?? 16;
    final textStyle = toggleTheme.textStyle ?? theme.textTheme.small;

    final motion = Motion.of(context);
    final transitionDuration = toggleTheme.transitionDuration ?? motion.fast;
    final fillRadius = decoration.border?.borderRadius ?? theme.radius;
    // In a single-selection group the selected fill is one shape that
    // travels between the items, painted by the group; the item itself only
    // marks where it belongs.
    final group = context.maybeRead<_ToggleGroupState<dynamic>>();
    final travelling = group != null && !group.widget._multiple;

    return Pressable(
      onPressed: enabled ? () => onChanged!(!value) : null,
      enabled: enabled,
      toggled: selected,
      focusNode: focusNode,
      autofocus: autofocus,
      statesController: statesController,
      onHover: onHover,
      onFocusChange: onFocusChange,
      mouseCursor: mouseCursor ?? SystemMouseCursors.click,
      // With an explicit label the child's own semantics are dropped rather
      // than merged — otherwise an icon-only toggle announces "Bold B".
      semanticLabel: semanticLabel,
      semanticContainer: true,
      // The press response takes the whole toggle, outline and all. Not in
      // a single-selection group: there the selection is the group's
      // travelling shape, and a label shrinking away from it would come
      // apart.
      pressScale: travelling ? 1 : toggleTheme.pressScale,
      builder: (context, states) {
        // A finger has no hover: while it is down the toggle looks as it
        // does under a pointer.
        final hovered =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed);
        final foreground = foregroundFor(hovered: hovered);
        final fill = backgroundFor(hovered: hovered);
        final content = Padding(
          padding: padding,
          // As tall as the label, centred in whatever the toggle's height
          // leaves: a plain `Center` takes all the height it is offered,
          // which under a text scale is more than it needs — and all the
          // width, which in a `Wrap` or a `Column` is the whole line.
          child: Center(
            heightFactor: 1,
            widthFactor: width == null ? 1 : null,
            child: AnimatedColorBuilder(
              color: foreground,
              duration: transitionDuration,
              curve: motion.standard,
              builder: (context, color, child) => IconTheme(
                data: IconThemeData(size: iconSize, color: color),
                child: DefaultTextStyle(
                  style: textStyle.copyWith(color: color),
                  child: child!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, SizedBox(width: gap)],
                  child,
                ],
              ),
            ),
          ),
        );
        // The hover fill of an unselected item is always the item's own;
        // in a single-selection group the selected fill is the group's
        // travelling shape.
        Widget filled = AnimatedColorBuilder(
          color: travelling && selected ? null : fill,
          duration: transitionDuration,
          curve: motion.standard,
          builder: (context, color, child) => DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: fillRadius),
            child: child,
          ),
          child: content,
        );
        if (travelling) {
          filled = MovingIndicatorTarget(
            selected: selected,
            decoration: BoxDecoration(color: fill, borderRadius: fillRadius),
            child: filled,
          );
        }
        // Joined, the outline is a hairline shared with the neighbours, so
        // only the fill and the content are dimmed: a disabled toggle's
        // edge would otherwise be a paler stretch of the group's.
        final innerDim = joined != null && !enabled
            ? theme.disabledOpacity
            : 1.0;
        final ownFill = decoration.color;
        final outline = innerDim != 1 && ownFill != null
            ? decoration.copyWith(
                color: ownFill.withValues(alpha: ownFill.a * innerDim),
              )
            : decoration;
        filled = Opacity(opacity: innerDim, child: filled);
        // Dimmed and deaf while disabled; the same widgets either way, so
        // the toggle keeps its state when it is enabled again.
        return Disabled(
          enabled: enabled,
          disabledOpacity: joined == null ? null : 1,
          // The size constraints sit *outside* the decorator so the outline
          // variant's border — and the no-secondary-border variant's focus
          // reserve — is counted into the toggle's height, the way CSS
          // `h-9` is border-box. Constraining inside made an outline toggle
          // 2px taller than a default one.
          // The height is a floor once text is scaled up, so the label is
          // never cut off; at a scale of 1 the two are the same.
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: width).copyWith(
              minHeight: height,
              maxHeight: textScaledMaxHeight(context, height),
            ),
            child: Decorator(
              focused: states.contains(WidgetState.focused),
              decoration: outline,
              child: filled,
            ),
          ),
        );
      },
    );
  }
}

/// {@template ToggleGroup}
/// A set of [Toggle]s sharing a selection.
///
/// Mirrors shadcn/ui's `ToggleGroup`. The unnamed constructor holds one
/// value, [ToggleGroup.multiple] a set of them.
///
/// ```dart
/// ToggleGroup<String>(
///   value: alignment,
///   onChanged: (value) => setState(() => alignment = value),
///   items: const [
///     ToggleGroupItem(
///       value: 'left',
///       child: PhosphorIcon(PhosphorIconsRegular.textAlignLeft),
///     ),
///     ToggleGroupItem(
///       value: 'center',
///       child: PhosphorIcon(PhosphorIconsRegular.textAlignCenter),
///     ),
///   ],
/// )
/// ```
///
/// The group is controlled: it shows [value] (or [values]) and reports what
/// a tap would make of it through [onChanged] (or [onValuesChanged]); the
/// parent decides. Give [initialValue] (or [initialValues]) instead, and no
/// value, for a group that keeps its own selection. With no callback the
/// group is disabled.
/// {@endtemplate}
class ToggleGroup<T> extends StatefulWidget {
  /// A group where at most one item is selected.
  const ToggleGroup({
    super.key,
    required this.items,
    this.value,
    this.initialValue,
    this.onChanged,
    this.allowDeselection = true,
    this.enabled = true,
    this.variant = ToggleVariant.primary,
    this.gap,
    this.axis = Axis.horizontal,
    this.mainAxisSize = MainAxisSize.min,
    this.semanticLabel,
  }) : _multiple = false,
       values = null,
       initialValues = null,
       onValuesChanged = null,
       assert(
         value == null || initialValue == null,
         'Give value (controlled) or initialValue (uncontrolled), not both',
       );

  /// A group where any number of items may be selected.
  const ToggleGroup.multiple({
    super.key,
    required this.items,
    this.values,
    this.initialValues,
    this.onValuesChanged,
    this.allowDeselection = true,
    this.enabled = true,
    this.variant = ToggleVariant.primary,
    this.gap,
    this.axis = Axis.horizontal,
    this.mainAxisSize = MainAxisSize.min,
    this.semanticLabel,
  }) : _multiple = true,
       value = null,
       initialValue = null,
       onChanged = null,
       assert(
         values == null || initialValues == null,
         'Give values (controlled) or initialValues (uncontrolled), not both',
       );

  /// Whether the group was made by [ToggleGroup.multiple].
  final bool _multiple;

  /// The visual style shared by every toggle in the group.
  final ToggleVariant variant;

  /// The items in the group.
  final List<ToggleGroupItem<T>> items;

  /// The selected value of a single-selection group, for a controlled
  /// group: a tap changes nothing until the parent passes the new value
  /// back. Null leaves the selection to the group, from [initialValue].
  final T? value;

  /// The value selected at first, for a single-selection group that keeps
  /// its own selection. Give this or [value], not both.
  final T? initialValue;

  /// Called with what the selection of a single-selection group becomes
  /// when an item is tapped: its value, or null when the selected item is
  /// tapped again and [allowDeselection] is true. Null disables the group.
  final ValueChanged<T?>? onChanged;

  /// The selected values of a [ToggleGroup.multiple], for a controlled
  /// group: a tap changes nothing until the parent passes the new set back.
  final Set<T>? values;

  /// The values selected at first, for a [ToggleGroup.multiple] that keeps
  /// its own selection. Give this or [values], not both.
  final Set<T>? initialValues;

  /// Called with what the selection of a [ToggleGroup.multiple] becomes
  /// when an item is tapped. Null disables the group.
  final ValueChanged<Set<T>>? onValuesChanged;

  /// Whether the selection may become empty: whether tapping the only
  /// selected item clears it.
  final bool allowDeselection;

  /// Whether the whole group responds to input. A group with no callback
  /// does not either.
  final bool enabled;

  /// The gap between items, 4 by default.
  ///
  /// With a gap of 0 the items are joined into one bar, as in a
  /// `ButtonGroup`: the corners between them are squared and, in the
  /// outline variant, neighbours share one hairline. A joined group is as
  /// small as its items, whatever [mainAxisSize] says.
  final double? gap;

  /// The direction the items are laid out in.
  final Axis axis;

  /// How much space the group takes on its main axis. Defaults to
  /// [MainAxisSize.min].
  final MainAxisSize mainAxisSize;

  /// What the group sets, for assistive technology: "Text alignment".
  final String? semanticLabel;

  @override
  State<ToggleGroup<T>> createState() => _ToggleGroupState<T>();
}

class _ToggleGroupState<T> extends State<ToggleGroup<T>> {
  /// The selection of a group that keeps its own.
  late Set<T> _own = widget._multiple
      ? {...?widget.initialValues}
      : {?widget.initialValue};

  bool get _controlled =>
      widget._multiple ? widget.values != null : widget.value != null;

  Set<T> get _values => widget._multiple
      ? (widget.values ?? _own)
      : (widget.value == null ? _own : {widget.value as T});

  /// One focus node per item: the group is one Tab stop and the arrows
  /// move among its items, as in a toolbar.
  final _nodes = <FocusNode>[];

  /// The item that is the group's Tab stop: the one last focused.
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _syncNodes();
    final first = widget.items.indexWhere(
      (item) => _values.contains(item.value),
    );
    if (first >= 0) _current = first;
  }

  @override
  void didUpdateWidget(ToggleGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A value taken away by the parent is an empty selection, as in a
    // `Select`: the group does not fall back on what it held before.
    if (!widget._multiple && widget.value != oldWidget.value) {
      _own = {?widget.value};
    }
    _syncNodes();
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncNodes() {
    final count = widget.items.length;
    while (_nodes.length > count) {
      _nodes.removeLast().dispose();
    }
    while (_nodes.length < count) {
      late final FocusNode node;
      node = FocusNode(debugLabel: 'ToggleGroup item ${_nodes.length}')
        ..addListener(() {
          final index = _nodes.indexOf(node);
          if (node.hasFocus && index >= 0 && _current != index) {
            setState(() => _current = index);
          }
        });
      _nodes.add(node);
    }
    if (_current >= count) _current = count == 0 ? 0 : count - 1;
  }

  bool _itemEnabled(int index) => _enabled && widget.items[index].enabled;

  /// The Tab stop: the item last focused while it can take the focus,
  /// else the first selected item that can, else the first that can.
  int _stop() {
    final count = widget.items.length;
    if (_current < count && _itemEnabled(_current)) return _current;
    final values = _values;
    int? firstEnabled;
    for (var i = 0; i < count; i++) {
      if (!_itemEnabled(i)) continue;
      if (values.contains(widget.items[i].value)) return i;
      firstEnabled ??= i;
    }
    return firstEnabled ?? _current;
  }

  /// Moves the focus [step] items on, past the disabled ones, or to the
  /// first or last with [toEnd].
  void _move(int from, int step, {bool toEnd = false}) {
    final count = widget.items.length;
    var index = toEnd ? (step > 0 ? -1 : count) : from;
    for (var i = 0; i < count; i++) {
      index += step;
      if (index < 0 || index >= count) return;
      if (_itemEnabled(index)) {
        _nodes[index].requestFocus();
        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final from = _nodes.indexWhere((n) => n.hasFocus);
    if (from < 0) return KeyEventResult.ignored;
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final horizontal = widget.axis == Axis.horizontal;
    final key = event.logicalKey;
    if (horizontal && key == LogicalKeyboardKey.arrowRight) {
      _move(from, rtl ? -1 : 1);
    } else if (horizontal && key == LogicalKeyboardKey.arrowLeft) {
      _move(from, rtl ? 1 : -1);
    } else if (!horizontal && key == LogicalKeyboardKey.arrowDown) {
      _move(from, 1);
    } else if (!horizontal && key == LogicalKeyboardKey.arrowUp) {
      _move(from, -1);
    } else if (key == LogicalKeyboardKey.home) {
      _move(from, 1, toEnd: true);
    } else if (key == LogicalKeyboardKey.end) {
      _move(from, -1, toEnd: true);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  bool get _enabled =>
      widget.enabled &&
      (widget._multiple
          ? widget.onValuesChanged != null
          : widget.onChanged != null);

  /// Selects [item], or takes it out of the selection.
  ///
  /// In a single-selection group, selecting an item replaces the selection.
  /// Either way, the only selected item is cleared only when deselection is
  /// allowed.
  void _toggle(T item) {
    final current = _values;
    final selected = current.contains(item);
    if (selected && current.length == 1 && !widget.allowDeselection) return;
    final Set<T> next;
    if (widget._multiple) {
      next = selected ? ({...current}..remove(item)) : {...current, item};
    } else {
      next = selected ? {} : {item};
    }
    if (!_controlled) setState(() => _own = next);
    if (widget._multiple) {
      widget.onValuesChanged?.call(next);
    } else {
      widget.onChanged?.call(next.isEmpty ? null : next.single);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final effectiveGap = widget.gap ?? 4.0;

    // Without a gap the items are one bar: joined corners, shared edges.
    final joined = effectiveGap == 0;
    final stop = _stop();
    final items = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      if (i > 0 && !joined) {
        items.add(
          widget.axis == Axis.horizontal
              ? SizedBox(width: effectiveGap)
              : SizedBox(height: effectiveGap),
        );
      }
      final item = widget.items[i];
      _nodes[i].skipTraversal = i != stop;
      items.add(
        Toggle(
          focusNode: _nodes[i],
          variant: widget.variant,
          value: _values.contains(item.value),
          enabled: _enabled && item.enabled,
          onChanged: (_) => _toggle(item.value),
          leading: item.leading,
          semanticLabel: item.semanticLabel,
          child: item.child,
        ),
      );
    }

    final toggleTheme = switch (widget.variant) {
      ToggleVariant.primary => Theme.of(context).toggleTheme,
      ToggleVariant.outline => Theme.of(context).outlineToggleTheme,
    };
    final list = joined
        ? ButtonGroup(axis: widget.axis, children: items)
        : widget.axis == Axis.horizontal
        ? Row(mainAxisSize: widget.mainAxisSize, children: items)
        : Column(mainAxisSize: widget.mainAxisSize, children: items);

    return Provider(
      data: this as _ToggleGroupState<dynamic>,
      child: Semantics(
        container: true,
        // The group is named; each toggle is a node of its own.
        explicitChildNodes: true,
        label: widget.semanticLabel,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          onKeyEvent: _onKey,
          // The same tree for both variants; with several selections there
          // is no single target and the indicator paints nothing.
          child: MovingIndicator(
            spring: toggleTheme.indicatorSpring,
            stretch: toggleTheme.indicatorStretch,
            child: list,
          ),
        ),
      ),
    );
  }
}

/// A single item within a [ToggleGroup].
///
/// This is a description, not a widget that builds itself — the group renders
/// a [Toggle] from it so that selection stays in one place.
@immutable
class ToggleGroupItem<T> {
  /// Creates an item for [value] that shows [child].
  const ToggleGroupItem({
    required this.value,
    required this.child,
    this.leading,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The value this item contributes to the group's selection.
  final T value;

  /// The content of the item.
  final Widget child;

  /// An optional widget shown before [child].
  final Widget? leading;

  /// Whether this individual item responds to input.
  final bool enabled;

  /// The accessible name, needed when [child] is icon-only.
  final String? semanticLabel;
}
