import 'package:finesse/src/components/control_affinity.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/activation_keys.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:finesse/src/utils/haptics.dart';
import 'package:finesse/src/utils/motion_color.dart';
import 'package:finesse/src/utils/pop_in.dart';
import 'package:flutter/widgets.dart';

/// A box that is checked or not, with an optional label and description
/// beside it.
///
/// ```dart
/// Checkbox(
///   value: _accepted,
///   onChanged: (value) => setState(() => _accepted = value),
///   label: const Text('Accept the terms'),
/// )
/// ```
///
/// With [tristate] the [value] may also be null, which draws a dash: the
/// mixed state of a box that stands for several others, some of them
/// checked. A tap on a mixed box checks it.
class Checkbox extends StatefulWidget {
  /// Creates a checkbox widget with the specified state and options.
  const Checkbox({
    super.key,
    required this.value,
    this.tristate = false,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.decoration,
    this.size,
    this.icon,
    this.color,
    this.uncheckedColor,
    this.mixedIcon,
    this.label,
    this.description,
    this.padding,
    this.controlAffinity = ControlAffinity.leading,
    this.crossAxisAlignment,
    this.checkboxPadding,
  }) : assert(
         tristate || value != null,
         'Only a tristate checkbox may have a null value.',
       );

  /// {@template Checkbox.value}
  /// Whether the checkbox is checked (true) or unchecked (false). With
  /// [tristate] it may be null: mixed, drawn as a dash.
  /// {@endtemplate}
  final bool? value;

  /// {@template Checkbox.tristate}
  /// Whether [value] may be null, the mixed state.
  /// {@endtemplate}
  final bool tristate;

  /// {@template Checkbox.enabled}
  /// Whether the checkbox is interactive.
  /// Defaults to true; if false, the checkbox is disabled and visually dimmed.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Checkbox.onChanged}
  /// Called with the new state when the checkbox is tapped: true for an
  /// unchecked or a mixed box, false for a checked one. If null, the
  /// checkbox is non-interactive but still visible.
  /// {@endtemplate}
  final ValueChanged<bool>? onChanged;

  /// {@template Checkbox.focusNode}
  /// The focus node for keyboard navigation and focus handling.
  /// If null, an internal focus node is created.
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

  /// {@template Checkbox.decoration}
  /// The decoration applied to the checkbox box.
  /// Merged with the theme’s default decoration if provided.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Checkbox.size}
  /// The size (width and height) of the checkbox box.
  /// Defaults to 16 if not specified.
  /// {@endtemplate}
  final double? size;

  /// {@template Checkbox.icon}
  /// The icon displayed when the checkbox is checked.
  /// Defaults to a checkmark icon if not specified.
  /// {@endtemplate}
  final Widget? icon;

  /// {@template Checkbox.color}
  /// The color of the checkbox when checked.
  /// Defaults to the theme’s primary color if not specified.
  /// {@endtemplate}
  final Color? color;

  /// {@template Checkbox.uncheckedColor}
  /// The color of the checkbox when unchecked.
  /// Defaults to the theme’s input color if not specified.
  /// {@endtemplate}
  final Color? uncheckedColor;

  /// {@template Checkbox.label}
  /// An optional label displayed next to the checkbox.
  /// Typically a [Text] widget, on the side [controlAffinity] leaves free.
  /// {@endtemplate}
  final Widget? label;

  /// {@template Checkbox.mixedIcon}
  /// The icon displayed in the mixed state. Defaults to a dash.
  /// {@endtemplate}
  final Widget? mixedIcon;

  /// {@template Checkbox.description}
  /// An optional line under the label, in the muted colour.
  /// {@endtemplate}
  final Widget? description;

  /// {@template Checkbox.padding}
  /// The padding between the checkbox and its label and description.
  /// Defaults to `EdgeInsetsDirectional.only(start: 8)` if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Checkbox.checkboxPadding}
  /// The padding around the checkbox field only.
  ///
  /// Defaults to `EdgeInsets.only(top: 1)` if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? checkboxPadding;

  /// {@template Checkbox.controlAffinity}
  /// Whether the box comes before the label or after it.
  /// {@endtemplate}
  final ControlAffinity controlAffinity;

  /// {@template Checkbox.crossAxisAlignment}
  /// The cross-axis alignment of the checkbox and its label and description.
  /// Defaults to [CrossAxisAlignment.start] if both label and description are
  /// present, otherwise [CrossAxisAlignment.center].
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  State<Checkbox> createState() => _CheckboxState();
}

class _CheckboxState extends State<Checkbox> {
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

  void onTap() {
    if (widget.onChanged == null) return;

    // A mixed box becomes a checked one.
    Haptics.selection(context);
    widget.onChanged!(!(widget.value ?? false));
    if (!focusNode.hasFocus) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasTheme(context));
    final theme = Theme.of(context);

    final effectiveColor =
        widget.color ?? theme.checkboxTheme.color ?? theme.colorScheme.primary;

    final effectiveUncheckedColor =
        widget.uncheckedColor ??
        theme.checkboxTheme.uncheckedColor ??
        theme.colorScheme.input;

    // A checked box swaps its whole decoration, not just the fill: the
    // reference recolours the outline with it (`data-checked:border-primary`),
    // so keeping the unchecked border would leave a pale halo around the fill.
    final value = widget.value;
    // Mixed is filled like checked: it is a box with a mark in it.
    final filled = value ?? true;
    final effectiveDecoration =
        ((filled
                    ? theme.checkboxTheme.checkedDecoration ??
                          theme.checkboxTheme.decoration
                    : theme.checkboxTheme.decoration) ??
                const FinesseDecoration())
            .merge(widget.decoration)
            .copyWith(
              color: filled ? effectiveColor : effectiveUncheckedColor,
            );

    final effectiveSize = widget.size ?? theme.checkboxTheme.size ?? 16;

    final effectiveIcon =
        widget.icon ??
        PhosphorIcon(
          PhosphorIconsRegular.check,
          color: theme.colorScheme.primaryForeground,
          // `[&>svg]:size-3.5`: the glyph sits 2px inside its 16px box.
          size: effectiveSize - 2,
        );

    final effectiveMixedIcon =
        widget.mixedIcon ??
        PhosphorIcon(
          PhosphorIconsBold.minus,
          color: theme.colorScheme.primaryForeground,
          size: effectiveSize - 4,
        );

    // The check pops in on the small-delight spring; the fill fades.
    final motion = Motion.of(context);
    final checkSpring = motion.bouncy;
    final effectivePadding =
        widget.padding ??
        theme.checkboxTheme.padding ??
        const EdgeInsetsDirectional.only(start: 8);

    final effectiveCheckboxPadding =
        widget.checkboxPadding ??
        theme.checkboxTheme.checkboxPadding ??
        const EdgeInsets.only(top: 1);

    final checkbox = Semantics(
      checked: value ?? false,
      mixed: widget.tristate ? value == null : null,
      child: Disabled(
        showForbiddenCursor: true,
        enabled: widget.enabled,
        child: CallbackShortcuts(
          bindings: {
            for (final trigger in activationKeys)
              trigger: () {
                if (!widget.enabled) return;
                onTap();
              },
          },
          child: Focusable(
            autofocus: widget.autofocus,
            onFocusChange: widget.onFocusChange,
            focusNode: focusNode,
            builder: (context, focused, child) {
              // The fill fades between the two states; the outline swaps
              // with the decoration.
              return AnimatedColorBuilder(
                color: effectiveDecoration.color,
                duration: motion.fast,
                curve: motion.standard,
                builder: (context, color, child) => Decorator(
                  focused: focused,
                  decoration: color == null
                      ? effectiveDecoration
                      : effectiveDecoration.copyWith(color: color),
                  child: child,
                ),
                child: child,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: effectiveSize,
                height: effectiveSize,
                child: Center(
                  // The mark pops in while it is wiped on from its leading
                  // edge, which reads as the stroke being drawn.
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PopIn(
                        visible: value ?? false,
                        wipe: true,
                        spring: checkSpring,
                        child: effectiveIcon,
                      ),
                      if (widget.tristate)
                        PopIn(
                          visible: value == null,
                          spring: checkSpring,
                          child: effectiveMixedIcon,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final defaultCrossAxisAlignment =
        widget.label != null && widget.description != null
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        theme.checkboxTheme.crossAxisAlignment ??
        defaultCrossAxisAlignment;

    return Disabled(
      showForbiddenCursor: true,
      enabled: widget.enabled,
      disabledOpacity: 1,
      child: GestureDetector(
        onTap: widget.onChanged == null ? null : onTap,
        child: ControlLabelRow(
          affinity: widget.controlAffinity,
          crossAxisAlignment: effectiveCrossAxisAlignment,
          labelPadding: effectivePadding,
          control: Padding(
            padding: effectiveCheckboxPadding,
            child: checkbox,
          ),
          label: widget.label == null && widget.description == null
              ? null
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.label != null)
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
                          style: theme.textTheme.muted.fallback(
                            color: theme.colorScheme.mutedForeground,
                          ),
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
