import 'package:finesse/src/components/button_group.dart';
import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:finesse/src/utils/spring.dart';
import 'package:finesse/src/utils/text_scaled_height.dart';
import 'package:flutter/widgets.dart';

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
/// {@endtemplate}
class Toggle extends StatefulWidget {
  /// {@macro Toggle}
  const Toggle({
    super.key,
    this.variant = ToggleVariant.primary,
    required this.value,
    required this.child,
    this.onChanged,
    this.enabled = true,
    this.leading,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.selectedBackgroundColor,
    this.selectedHoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.selectedForegroundColor,
    this.padding,
    this.decoration,
    this.textStyle,
    this.gap,
    this.height,
    this.width,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.statesController,
    this.semanticLabel,
  });

  /// A bordered toggle, matching shadcn/ui's `variant="outline"`.
  const Toggle.outline({
    super.key,
    required this.value,
    required this.child,
    this.onChanged,
    this.enabled = true,
    this.leading,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.selectedBackgroundColor,
    this.selectedHoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.selectedForegroundColor,
    this.padding,
    this.decoration,
    this.textStyle,
    this.gap,
    this.height,
    this.width,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.statesController,
    this.semanticLabel,
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

  /// {@template Toggle.backgroundColor}
  /// The background color when off.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Toggle.hoverBackgroundColor}
  /// The background color when off and hovered.
  /// {@endtemplate}
  final Color? hoverBackgroundColor;

  /// {@template Toggle.selectedBackgroundColor}
  /// The background color when on.
  /// {@endtemplate}
  final Color? selectedBackgroundColor;

  /// {@template Toggle.selectedHoverBackgroundColor}
  /// The background color when on and hovered.
  /// {@endtemplate}
  final Color? selectedHoverBackgroundColor;

  /// {@template Toggle.foregroundColor}
  /// The content color when off.
  /// {@endtemplate}
  final Color? foregroundColor;

  /// {@template Toggle.hoverForegroundColor}
  /// The content color when off and hovered.
  /// {@endtemplate}
  final Color? hoverForegroundColor;

  /// {@template Toggle.selectedForegroundColor}
  /// The content color when on.
  /// {@endtemplate}
  final Color? selectedForegroundColor;

  /// {@template Toggle.padding}
  /// The padding inside the toggle.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Toggle.decoration}
  /// The decoration of the toggle.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Toggle.textStyle}
  /// The text style of the label.
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// The gap between [leading] and [child].
  final double? gap;

  /// The height of the toggle.
  final double? height;

  /// The width of the toggle. Null sizes to the content.
  final double? width;

  /// The focus node of the toggle. When null, the toggle creates its own.
  final FocusNode? focusNode;

  /// Whether to take focus when first built, if nothing else has focus.
  /// Defaults to false.
  final bool autofocus;

  /// Called with the new focus state each time it changes.
  final ValueChanged<bool>? onFocusChange;

  /// Holds the interaction states of the toggle, such as hovered and pressed.
  /// When null, the toggle creates its own.
  final WidgetStatesController? statesController;

  /// The accessible name, needed when [child] is icon-only.
  final String? semanticLabel;

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  WidgetStatesController? _internalStatesController;

  WidgetStatesController get statesController =>
      widget.statesController ?? _internalStatesController!;

  bool get enabled => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    if (widget.statesController == null) {
      _internalStatesController = WidgetStatesController();
    }
  }

  @override
  void dispose() {
    _internalStatesController?.dispose();
    super.dispose();
  }

  // Counted for the press response; see `PressScale.taps`.
  int _taps = 0;

  void _toggle() {
    if (!enabled) return;
    setState(() => _taps++);
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final toggleTheme = switch (widget.variant) {
      ToggleVariant.primary => theme.toggleTheme,
      ToggleVariant.outline => theme.outlineToggleTheme,
    };

    final selected = widget.value;

    final effectivePadding =
        widget.padding ??
        toggleTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 12);
    final effectiveHeight = widget.height ?? toggleTheme.height ?? 40.0;
    final effectiveGap = widget.gap ?? toggleTheme.gap ?? 8.0;
    var effectiveDecoration =
        (toggleTheme.decoration ?? const FinesseDecoration()).merge(
          widget.decoration,
        );
    // In a `ButtonGroup` — a toggle group with no gap is one — the corners
    // and the edge towards a neighbour are the group's to decide.
    final joined = ButtonGroupScope.maybeOf(context);
    if (joined != null) {
      effectiveDecoration = joined.join(
        effectiveDecoration,
        Directionality.of(context),
        fallback: theme.decoration,
      );
    }

    Color? backgroundFor({required bool hovered}) {
      if (selected) {
        return hovered
            ? widget.selectedHoverBackgroundColor ??
                  toggleTheme.selectedHoverBackgroundColor ??
                  theme.colorScheme.accent
            : widget.selectedBackgroundColor ??
                  toggleTheme.selectedBackgroundColor ??
                  theme.colorScheme.accent;
      }
      return hovered
          ? widget.hoverBackgroundColor ??
                toggleTheme.hoverBackgroundColor ??
                theme.colorScheme.muted
          : widget.backgroundColor ?? toggleTheme.backgroundColor;
    }

    Color foregroundFor({required bool hovered}) {
      if (selected) {
        return widget.selectedForegroundColor ??
            toggleTheme.selectedForegroundColor ??
            theme.colorScheme.accentForeground;
      }
      return hovered
          ? widget.hoverForegroundColor ??
                toggleTheme.hoverForegroundColor ??
                theme.colorScheme.mutedForeground
          : widget.foregroundColor ??
                toggleTheme.foregroundColor ??
                theme.colorScheme.foreground;
    }

    final effectiveIconSize = toggleTheme.iconSize ?? 16;
    final effectiveTextStyle = (toggleTheme.textStyle ?? theme.textTheme.small)
        .merge(widget.textStyle);

    final motion = Motion.of(context);
    final transitionDuration = toggleTheme.transitionDuration ?? motion.fast;
    final fillRadius = effectiveDecoration.border?.radius ?? theme.radius;
    // In a single-selection group the selected fill is one shape that
    // travels between the items, painted by the group; the item itself only
    // marks where it belongs.
    final group = context.maybeRead<_ToggleGroupState<dynamic>>();
    final travelling =
        group != null && group.widget.variant == ToggleGroupVariant.single;

    Widget toggle = Focusable(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onFocusChange: widget.onFocusChange,
      canRequestFocus: enabled,
      builder: (context, focused, child) {
        // The size constraints sit *outside* the decorator so the outline
        // variant's border — and the no-secondary-border variant's focus
        // reserve — is counted into the toggle's height, the way CSS `h-9`
        // is border-box. Constraining inside made an outline toggle 2px
        // taller than a default one.
        // The height is a floor once text is scaled up, so the label is
        // never cut off; at a scale of 1 the two are the same.
        return ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: widget.width).copyWith(
            minHeight: effectiveHeight,
            maxHeight: textScaledMaxHeight(context, effectiveHeight),
          ),
          child: Decorator(
            focused: focused,
            decoration: effectiveDecoration,
            child: child,
          ),
        );
      },
      child: FinesseGestureDetector(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        onHoverChange: (hovered) =>
            statesController.update(WidgetState.hovered, hovered),
        onTapDown: (_) => statesController.update(WidgetState.pressed, true),
        onTapUp: (_) => statesController.update(WidgetState.pressed, false),
        onTapCancel: () => statesController.update(WidgetState.pressed, false),
        child: ValueListenableBuilder(
          valueListenable: statesController,
          builder: (context, states, _) {
            final hovered = enabled && states.contains(WidgetState.hovered);
            final foreground = foregroundFor(hovered: hovered);
            final fill = backgroundFor(hovered: hovered);
            final content = Padding(
              padding: effectivePadding,
              // As tall as the label, centred in whatever the toggle's
              // height leaves: a plain `Center` takes all the height it is
              // offered, which under a text scale is more than it needs.
              child: Center(
                heightFactor: 1,
                child: AnimatedColorBuilder(
                  color: foreground,
                  duration: transitionDuration,
                  curve: motion.standard,
                  builder: (context, color, child) => IconTheme(
                    data: IconThemeData(
                      size: effectiveIconSize,
                      color: color,
                    ),
                    child: DefaultTextStyle(
                      style: effectiveTextStyle.copyWith(color: color),
                      child: child!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        SizedBox(width: effectiveGap),
                      ],
                      widget.child,
                    ],
                  ),
                ),
              ),
            );
            final Widget filled;
            if (travelling) {
              // The hover fill of an unselected item is still the item's
              // own; the selected fill is the group's travelling shape.
              filled = MovingIndicatorTarget(
                selected: selected,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: fillRadius,
                ),
                child: AnimatedColorBuilder(
                  color: selected ? null : fill,
                  duration: transitionDuration,
                  curve: motion.standard,
                  builder: (context, color, child) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: fillRadius,
                    ),
                    child: child,
                  ),
                  child: content,
                ),
              );
            } else {
              filled = AnimatedColorBuilder(
                color: fill,
                duration: transitionDuration,
                curve: motion.standard,
                builder: (context, color, child) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: fillRadius,
                  ),
                  child: child,
                ),
                child: content,
              );
            }
            return filled;
          },
        ),
      ),
    );

    // The press response takes the whole toggle, outline and all. Not in a
    // single-selection group: there the selection is the group's travelling
    // shape, and a label shrinking away from it would come apart.
    toggle = ValueListenableBuilder(
      valueListenable: statesController,
      builder: (context, states, child) => PressScale(
        pressed: enabled && !travelling && states.contains(WidgetState.pressed),
        taps: travelling ? 0 : _taps,
        scale: toggleTheme.pressScale,
        child: child!,
      ),
      child: toggle,
    );

    toggle = Semantics(
      label: widget.semanticLabel,
      button: true,
      toggled: selected,
      enabled: enabled,
      container: true,
      // With an explicit label, drop the child's own semantics rather than
      // merging — otherwise an icon-only toggle announces "Bold B".
      child: widget.semanticLabel == null
          ? toggle
          : ExcludeSemantics(child: toggle),
    );

    if (!enabled) {
      toggle = Disabled(disabled: true, child: toggle);
    }
    return toggle;
  }
}

/// Whether a [ToggleGroup] allows one or many selections.
enum ToggleGroupVariant {
  /// At most one item may be selected.
  single,

  /// Any number of items may be selected.
  multiple,
}

/// {@template ToggleGroup}
/// A set of [Toggle]s sharing a selection.
///
/// Mirrors shadcn/ui's `ToggleGroup`, in `single` or `multiple` mode.
///
/// ```dart
/// ToggleGroup<String>(
///   values: selected,
///   onChanged: (values) => setState(() => selected = values),
///   children: const [
///     ToggleGroupItem(
///       value: 'bold',
///       child: PhosphorIcon(PhosphorIconsRegular.textB),
///     ),
///     ToggleGroupItem(
///       value: 'italic',
///       child: PhosphorIcon(PhosphorIconsRegular.textItalic),
///     ),
///   ],
/// )
/// ```
///
/// The group is controlled: it shows [values] and reports what a tap would
/// make of them through [onChanged]; the parent decides. Give
/// [initialValues] instead, and no [values], for a group that keeps its own
/// selection.
/// {@endtemplate}
class ToggleGroup<T> extends StatefulWidget {
  /// {@macro ToggleGroup}
  const ToggleGroup({
    super.key,
    required this.children,
    this.values,
    this.initialValues,
    this.onChanged,
    this.allowDeselection = true,
    this.enabled = true,
    this.toggleVariant = ToggleVariant.primary,
    this.gap,
    this.axis = Axis.horizontal,
    this.mainAxisSize = MainAxisSize.min,
  }) : variant = ToggleGroupVariant.single,
       assert(
         values == null || initialValues == null,
         'Give values (controlled) or initialValues (uncontrolled), not both',
       ),
       assert(
         (values ?? initialValues ?? const {}).length <= 1,
         'A single-selection ToggleGroup has at most one value selected',
       );

  /// A group where any number of items may be selected.
  const ToggleGroup.multiple({
    super.key,
    required this.children,
    this.values,
    this.initialValues,
    this.onChanged,
    this.enabled = true,
    this.toggleVariant = ToggleVariant.primary,
    this.gap,
    this.axis = Axis.horizontal,
    this.mainAxisSize = MainAxisSize.min,
  }) : variant = ToggleGroupVariant.multiple,
       allowDeselection = true,
       assert(
         values == null || initialValues == null,
         'Give values (controlled) or initialValues (uncontrolled), not both',
       );

  /// Whether one or many items can be selected. Set by the constructor:
  /// [ToggleGroupVariant.single] for [ToggleGroup.new] and
  /// [ToggleGroupVariant.multiple] for [ToggleGroup.multiple].
  final ToggleGroupVariant variant;

  /// The visual style shared by every toggle in the group.
  final ToggleVariant toggleVariant;

  /// The items in the group.
  final List<ToggleGroupItem<T>> children;

  /// The selected values, for a controlled group: a tap changes nothing
  /// until the parent passes the new set back.
  final Set<T>? values;

  /// The values selected at first, for a group that keeps its own
  /// selection. Give this or [values], not both.
  final Set<T>? initialValues;

  /// Called with what the selection becomes when an item is tapped.
  final ValueChanged<Set<T>>? onChanged;

  /// Whether tapping the selected item of a single-variant group clears it.
  final bool allowDeselection;

  /// Whether the whole group responds to input.
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

  @override
  State<ToggleGroup<T>> createState() => _ToggleGroupState<T>();
}

class _ToggleGroupState<T> extends State<ToggleGroup<T>> {
  /// The selection of a group that keeps its own.
  late Set<T> _own = {...?widget.initialValues};

  Set<T> get _values => widget.values ?? _own;

  /// Selects [item], or takes it out of the selection.
  ///
  /// In a single-selection group, selecting an item replaces the selection,
  /// and tapping the selected item clears it only when deselection is
  /// allowed.
  void _toggle(T item) {
    final current = _values;
    final selected = current.contains(item);
    final Set<T> next;
    switch (widget.variant) {
      case ToggleGroupVariant.single:
        if (selected && !widget.allowDeselection) return;
        next = selected ? {} : {item};
      case ToggleGroupVariant.multiple:
        next = selected ? ({...current}..remove(item)) : {...current, item};
    }
    if (widget.values == null) setState(() => _own = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final effectiveGap = widget.gap ?? 4.0;

    // Without a gap the items are one bar: joined corners, shared edges.
    final joined = effectiveGap == 0;
    final items = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      if (i > 0 && !joined) {
        items.add(
          widget.axis == Axis.horizontal
              ? SizedBox(width: effectiveGap)
              : SizedBox(height: effectiveGap),
        );
      }
      final item = widget.children[i];
      items.add(
        Toggle(
          variant: widget.toggleVariant,
          value: _values.contains(item.value),
          enabled: widget.enabled && item.enabled,
          onChanged: (_) => _toggle(item.value),
          leading: item.leading,
          semanticLabel: item.semanticLabel,
          child: item.child,
        ),
      );
    }

    final toggleTheme = switch (widget.toggleVariant) {
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
        // The same tree for both variants; with several selections there is
        // no single target and the indicator paints nothing.
        child: MovingIndicator(
          spring: toggleTheme.indicatorSpring,
          stretch: toggleTheme.indicatorStretch,
          child: list,
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
