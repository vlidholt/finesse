import 'package:finesse/src/components/control_affinity.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/activation_keys.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:flutter/widgets.dart';

/// What a radio reads from the [FinesseRadioGroup] around it: the selected
/// value, whether the group is enabled, and how to select another value.
///
/// `Radio` uses it; so can a row or a card of your own that should act as
/// one of the group's options (see [FinesseRadioGroup.maybeOf]).
@immutable
class RadioGroupScope<T> {
  const RadioGroupScope._({
    required this.value,
    required this.enabled,
    required this.select,
  });

  /// The selected value, or null when nothing is selected.
  final T? value;

  /// Whether the group's radios react to input.
  final bool enabled;

  /// Selects [value], as a tap on its radio does.
  final ValueChanged<T> select;
}

/// A set of [Radio]s of which one is selected.
///
/// ```dart
/// FinesseRadioGroup<String>(
///   value: _plan,
///   onChanged: (plan) => setState(() => _plan = plan),
///   items: const [
///     Radio(value: 'free', label: Text('Free')),
///     Radio(value: 'pro', label: Text('Pro')),
///   ],
/// )
/// ```
///
/// Give [value] to hold the selection yourself, changing it in [onChanged],
/// or [initialValue] to let the group keep it.
///
/// [items] are laid out in a wrap along [axis]. To lay the radios out any
/// other way — in a `ListSection`, a grid, a row, with other widgets
/// between them — give the group a [child] instead and put the radios
/// wherever they belong in it:
///
/// ```dart
/// FinesseRadioGroup<Plan>(
///   value: _plan,
///   onChanged: (plan) => setState(() => _plan = plan),
///   child: ListSection(
///     children: const [
///       RadioListTile(value: Plan.free, title: Text('Free')),
///       RadioListTile(value: Plan.pro, title: Text('Pro')),
///     ],
///   ),
/// )
/// ```
class FinesseRadioGroup<T> extends StatefulWidget {
  /// Creates a radio group around [items], laid out in a wrap, or around a
  /// [child] that lays out its own radios.
  const FinesseRadioGroup({
    super.key,
    this.items,
    this.child,
    this.value,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.axis,
    this.alignment,
    this.runAlignment,
    this.crossAxisAlignment,
    this.spacing,
    this.runSpacing,
  }) : assert(
         value == null || initialValue == null,
         'Give value to control the group or initialValue to seed it, not '
         'both.',
       ),
       assert(
         (items == null) != (child == null),
         'Give a radio group either items, which it lays out in a wrap, or '
         'a child that lays out its own radios.',
       );

  /// {@template FinesseRadioGroup.value}
  /// The selected value, held by the parent. While it is non-null the group
  /// shows it and reports a tap through [onChanged] without changing by
  /// itself.
  /// {@endtemplate}
  final T? value;

  /// {@template FinesseRadioGroup.initialValue}
  /// The value selected at first, when the group keeps its own state.
  /// {@endtemplate}
  final T? initialValue;

  /// {@template FinesseRadioGroup.items}
  /// The radios, laid out in a wrap along [axis]; any widget can stand
  /// among them. Give this or a [child], not both.
  /// {@endtemplate}
  final Iterable<Widget>? items;

  /// {@template FinesseRadioGroup.child}
  /// The content of the group, for radios laid out freely: every `Radio`
  /// and `RadioListTile` below it, however deep, belongs to the group. The
  /// group adds no layout of its own, so [axis], [spacing] and the other
  /// wrap parameters do not apply. Give this or [items], not both.
  /// {@endtemplate}
  final Widget? child;

  /// {@template FinesseRadioGroup.onChanged}
  /// Called with the value of the radio the user selects. Null disables
  /// the group.
  /// {@endtemplate}
  final ValueChanged<T>? onChanged;

  /// {@template FinesseRadioGroup.enabled}
  /// Whether the radio [items] are enabled, defaults to true.
  /// {@endtemplate}
  final bool enabled;

  /// {@template FinesseRadioGroup.axis}
  /// The axis of the radio group, defaults to [Axis.vertical].
  /// {@endtemplate}
  final Axis? axis;

  /// {@template FinesseRadioGroup.spacing}
  /// The main axis spacing of the radio group items, defaults to 4
  /// {@endtemplate}
  final double? spacing;

  /// {@template FinesseRadioGroup.runSpacing}
  /// The cross axis spacing of the radio group items, defaults to 0
  /// {@endtemplate}
  final double? runSpacing;

  /// {@template FinesseRadioGroup.alignment}
  /// The main axis alignment of the radio group items, defaults to
  /// [WrapAlignment.start]
  /// {@endtemplate}
  final WrapAlignment? alignment;

  /// {@template FinesseRadioGroup.runAlignment}
  /// The cross axis alignment of the radio group items, defaults to
  /// [WrapAlignment.start]
  /// {@endtemplate}
  final WrapAlignment? runAlignment;

  /// {@template FinesseRadioGroup.crossAxisAlignment}
  /// The cross axis alignment of the radio group items, defaults to
  /// [WrapCrossAlignment.start]
  /// {@endtemplate}
  final WrapCrossAlignment? crossAxisAlignment;

  /// The group around [context], or null when there is none.
  ///
  /// [context] is rebuilt when the selection or the enabled state changes.
  /// `T` has to be the group's own type argument, or a supertype of it.
  static RadioGroupScope<T>? maybeOf<T>(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_RadioGroupMarker>();
    if (scope == null) return null;
    return RadioGroupScope<T>._(
      value: scope.value as T?,
      enabled: scope.enabled,
      select: scope.select,
    );
  }

  @override
  State<FinesseRadioGroup<T>> createState() => _RadioGroupState<T>();
}

class _RadioGroupState<T> extends State<FinesseRadioGroup<T>> {
  late T? _value = widget.value ?? widget.initialValue;

  @override
  void didUpdateWidget(covariant FinesseRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A value written from outside — null included, which clears the
    // selection — replaces what the group shows.
    if (widget.value != oldWidget.value) _value = widget.value;
  }

  /// Whether the radios take input: [FinesseRadioGroup.enabled], and an
  /// [FinesseRadioGroup.onChanged] to report to.
  bool get _enabled => widget.enabled && widget.onChanged != null;

  void _select(Object? value) {
    if (value is! T || !_enabled) return;
    // A controlled group waits for its parent to hand the value back.
    if (widget.value == null && value != _value) {
      setState(() => _value = value);
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (child != null) {
      return _RadioGroupMarker(
        value: widget.value ?? _value,
        enabled: _enabled,
        select: _select,
        child: child,
      );
    }

    final theme = Theme.of(context);
    final effectiveAxis = widget.axis ?? theme.radioTheme.axis ?? Axis.vertical;
    final effectiveSpacing = widget.spacing ?? theme.radioTheme.spacing ?? 4;
    final effectiveRunSpacing =
        widget.runSpacing ?? theme.radioTheme.runSpacing ?? 0;
    final effectiveAlignment =
        widget.alignment ?? theme.radioTheme.alignment ?? WrapAlignment.start;
    final effectiveRunAlignment =
        widget.runAlignment ??
        theme.radioTheme.runAlignment ??
        WrapAlignment.start;
    final effectiveWrapCrossAlignment =
        widget.crossAxisAlignment ??
        theme.radioTheme.crossAxisAlignment ??
        WrapCrossAlignment.start;

    return _RadioGroupMarker(
      value: widget.value ?? _value,
      enabled: _enabled,
      select: _select,
      child: Wrap(
        direction: effectiveAxis,
        spacing: effectiveSpacing,
        runSpacing: effectiveRunSpacing,
        alignment: effectiveAlignment,
        runAlignment: effectiveRunAlignment,
        crossAxisAlignment: effectiveWrapCrossAlignment,
        children: widget.items!.toList(),
      ),
    );
  }
}

/// Carries a group's selection to the radios under it.
class _RadioGroupMarker extends InheritedWidget {
  const _RadioGroupMarker({
    required this.value,
    required this.enabled,
    required this.select,
    required super.child,
  });

  final Object? value;
  final bool enabled;
  final ValueChanged<Object?> select;

  @override
  bool updateShouldNotify(_RadioGroupMarker oldWidget) =>
      oldWidget.value != value || oldWidget.enabled != enabled;
}

/// A customizable radio button widget that represents a single option in a
/// radio group.
///
/// The [Radio] widget can be used to create individual radio buttons
/// with various customization options such as size, color, and labels.
class Radio<T> extends StatefulWidget {
  /// Creates a [Radio] with the specified [value] and optional parameters.
  ///
  /// The [value] parameter is required and represents the value of the radio
  /// button. The [enabled] parameter determines if the radio button is
  /// interactive. Other parameters allow for customization of appearance and
  /// behavior.
  const Radio({
    super.key,
    required this.value,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.decoration,
    this.size,
    this.circleSize,
    this.color,
    this.label,
    this.description,
    this.padding,
    this.controlAffinity = ControlAffinity.leading,
    this.radioPadding,
  });

  /// {@template Radio.value}
  /// The value of the radio.
  /// {@endtemplate}
  final T value;

  /// {@template Radio.enabled}
  /// Whether the radio is enabled, defaults to true.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Radio.focusNode}
  /// The focus node of the radio.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Widget.autofocus}
  /// Whether this widget should be focused when first shown.
  /// Defaults to `false`.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Widget.onFocusChange}
  /// Called when the focus state of this widget changes.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@template Radio.decoration}
  /// The decoration of the radio.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Radio.size}
  /// The size of the radio, defaults to 16.
  /// {@endtemplate}
  final double? size;

  /// {@template Radio.circleSize}
  /// The circle size of the radio, defaults to 10.
  /// {@endtemplate}
  final double? circleSize;

  /// {@template Radio.color}
  /// The color of the radio.
  /// {@endtemplate}
  final Color? color;

  /// {@template Radio.label}
  /// An optional label for the radio, on the side [controlAffinity] leaves
  /// free.
  /// {@endtemplate}
  final Widget? label;

  /// {@template Radio.description}
  /// An optional line under the label, in the muted colour.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Radio.padding}
  /// The padding between the radio and the label, defaults to
  /// `EdgeInsetsDirectional.only(start: 8)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Radio.radioPadding}
  /// The padding around the radio field only.
  ///
  /// Defaults to `EdgeInsets.only(top: 1)` if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? radioPadding;

  /// {@template Radio.controlAffinity}
  /// Whether the radio comes before the label or after it.
  /// {@endtemplate}
  final ControlAffinity controlAffinity;

  @override
  State<Radio<T>> createState() => _RadioState<T>();
}

class _RadioState<T> extends State<Radio<T>> {
  FocusNode? _focusNode;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);
    final group = context
        .dependOnInheritedWidgetOfExactType<_RadioGroupMarker>();
    assert(
      group != null,
      'A Radio has to be inside a FinesseRadioGroup, which holds the '
      'selection.',
    );

    void onTap() {
      group?.select(widget.value);
      if (!focusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    }

    final effectiveDecoration =
        (theme.radioTheme.decoration ?? const FinesseDecoration()).merge(
          widget.decoration,
        );

    // While selected the whole decoration swaps: the reference fills the
    // circle with the primary and recolours the outline with it
    // (`data-checked:bg-primary data-checked:border-primary`), with the dot
    // cut out of it in the primary foreground.
    final effectiveCheckedDecoration =
        (theme.radioTheme.checkedDecoration ??
                theme.radioTheme.decoration ??
                const FinesseDecoration())
            .merge(widget.decoration);

    final effectiveSize = widget.size ?? theme.radioTheme.size ?? 16;
    final effectiveCircleSize =
        widget.circleSize ?? theme.radioTheme.circleSize ?? 8;
    final effectiveColor =
        widget.color ??
        theme.radioTheme.color ??
        theme.colorScheme.primaryForeground;
    // The dot pops in on the small-delight spring; the fill fades.
    final motion = Motion.of(context);
    final dotSpring = motion.bouncy;
    final effectivePadding =
        widget.padding ??
        theme.radioTheme.padding ??
        const EdgeInsetsDirectional.only(start: 8);

    final effectiveRadioPadding =
        widget.radioPadding ??
        theme.radioTheme.radioPadding ??
        const EdgeInsets.only(top: 1);

    final selected = group != null && group.value == widget.value;
    final enabled = widget.enabled && (group?.enabled ?? false);

    final radio = Semantics(
      checked: selected,
      child: Disabled(
        showForbiddenCursor: true,
        enabled: enabled,
        child: CallbackShortcuts(
          bindings: {
            for (final trigger in activationKeys)
              trigger: () {
                if (!enabled) return;
                onTap();
              },
          },
          child: Focusable(
            autofocus: widget.autofocus,
            onFocusChange: widget.onFocusChange,
            focusNode: focusNode,
            builder: (context, focused, child) {
              final decoration = selected
                  ? effectiveCheckedDecoration
                  : effectiveDecoration;
              // The fill fades between the two states; the outline
              // swaps with the decoration.
              return AnimatedColorBuilder(
                color: decoration.color,
                duration: motion.fast,
                curve: motion.standard,
                builder: (context, color, child) => Decorator(
                  focused: focused,
                  decoration: color == null
                      ? decoration
                      : decoration.copyWith(color: color),
                  child: child,
                ),
                child: child,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox.square(
                dimension: effectiveSize,
                child: Center(
                  // The dot grows out of the centre and settles.
                  child: PopIn(
                    visible: selected,
                    scale: .2,
                    spring: dotSpring,
                    child: SizedBox.square(
                      dimension: effectiveCircleSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: effectiveColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Disabled(
      showForbiddenCursor: true,
      enabled: enabled,
      disabledOpacity: 1,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: ControlLabelRow(
          affinity: widget.controlAffinity,
          crossAxisAlignment: CrossAxisAlignment.center,
          labelPadding: effectivePadding,
          control: Padding(
            padding: effectiveRadioPadding,
            child: radio,
          ),
          label: widget.label == null
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: DefaultTextStyle(
                        style: theme.textTheme.muted.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.foreground,
                        ),
                        child: widget.label!,
                      ),
                    ),
                    if (widget.description != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: DefaultTextStyle(
                          style: theme.textTheme.muted,
                          child: widget.description!,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
