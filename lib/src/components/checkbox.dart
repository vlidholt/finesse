import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/extensions/text_style.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A customizable checkbox widget with optional label and sublabel.
///
/// The [Checkbox] widget allows users to toggle a boolean state, visually
/// represented by a checkmark within a styled box. It supports enabling/disabling,
/// focus handling, animations, and integrates with [Theme] for consistent
/// styling.
class Checkbox extends StatefulWidget {
  /// Creates a checkbox widget with the specified state and options.
  const Checkbox({
    super.key,
    required this.value,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.decoration,
    this.size,
    this.duration,
    this.icon,
    this.color,
    this.uncheckedColor,
    this.label,
    this.sublabel,
    this.padding,
    this.direction,
    this.crossAxisAlignment,
    this.checkboxPadding,
  });

  /// {@template Checkbox.value}
  /// Whether the checkbox is checked (true) or unchecked (false).
  /// Required to set the initial state of the checkbox.
  /// {@endtemplate}
  final bool value;

  /// {@template Checkbox.enabled}
  /// Whether the checkbox is interactive.
  /// Defaults to true; if false, the checkbox is disabled and visually dimmed.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Checkbox.onChanged}
  /// Callback invoked when the checkbox is toggled.
  /// If null, the checkbox is non-interactive but still visible.
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

  /// {@template Checkbox.duration}
  /// The duration of the checkmark animation when toggling.
  /// Defaults to 100 milliseconds if not specified.
  /// {@endtemplate}
  final Duration? duration;

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
  /// Typically a [Text] widget, positioned based on [direction].
  /// {@endtemplate}
  final Widget? label;

  /// {@template Checkbox.sublabel}
  /// An optional sublabel displayed below the label.
  /// Typically a [Text] widget, enhancing the checkbox description.
  /// {@endtemplate}
  final Widget? sublabel;

  /// {@template Checkbox.padding}
  /// The padding between the checkbox and its label/sublabel.
  /// Defaults to `EdgeInsetsDirectional.only(start: 8)` if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Checkbox.checkboxPadding}
  /// The padding around the checkbox field only.
  ///
  /// Defaults to `EdgeInsets.only(top: 1)` if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? checkboxPadding;

  /// {@template Checkbox.direction}
  /// The text direction for arranging the checkbox and label/sublabel.
  /// Defaults to null (inherits from context) if not specified.
  /// {@endtemplate}
  final TextDirection? direction;

  /// {@template Checkbox.crossAxisAlignment}
  /// The cross-axis alignment of the checkbox and label/sublabel.
  /// Defaults to [CrossAxisAlignment.start] if both label and sublabel are
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

    widget.onChanged!(!widget.value);
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
    final effectiveDecoration =
        ((widget.value
                    ? theme.checkboxTheme.checkedDecoration ??
                          theme.checkboxTheme.decoration
                    : theme.checkboxTheme.decoration) ??
                const FinesseDecoration())
            .merge(widget.decoration)
            .copyWith(
              color: widget.value ? effectiveColor : effectiveUncheckedColor,
            );

    final effectiveSize = widget.size ?? theme.checkboxTheme.size ?? 16;

    final effectiveIcon =
        widget.icon ??
        Icon(
          LucideIcons.check,
          color: theme.colorScheme.primaryForeground,
          // `[&>svg]:size-3.5`: the glyph sits 2px inside its 16px box.
          size: effectiveSize - 2,
        );

    final effectiveDuration =
        widget.duration ?? theme.checkboxTheme.duration ?? 100.milliseconds;
    final effectivePadding =
        widget.padding ??
        theme.checkboxTheme.padding ??
        const EdgeInsetsDirectional.only(start: 8);

    final effectiveCheckboxPadding =
        widget.checkboxPadding ??
        theme.checkboxTheme.checkboxPadding ??
        const EdgeInsets.only(top: 1);

    final keyboardTriggers = <ShortcutActivator>[
      const SingleActivator(LogicalKeyboardKey.enter),
      const SingleActivator(LogicalKeyboardKey.space),
    ];

    final checkbox = Semantics(
      checked: widget.value,
      child: Disabled(
        showForbiddenCursor: true,
        disabled: !widget.enabled,
        child: CallbackShortcuts(
          bindings: {
            for (final trigger in keyboardTriggers)
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
              return Decorator(
                focused: focused,
                decoration: effectiveDecoration,
                child: child,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                width: effectiveSize,
                height: effectiveSize,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: effectiveDuration,
                    child: widget.value ? effectiveIcon : const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final defaultCrossAxisAlignment =
        widget.label != null && widget.sublabel != null
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        theme.checkboxTheme.crossAxisAlignment ??
        defaultCrossAxisAlignment;

    return Disabled(
      showForbiddenCursor: true,
      disabled: !widget.enabled,
      disabledOpacity: 1,
      child: GestureDetector(
        onTap: widget.onChanged == null ? null : onTap,
        child: Row(
          textDirection: widget.direction,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: effectiveCrossAxisAlignment,
          children: [
            Padding(
              padding: effectiveCheckboxPadding,
              child: checkbox,
            ),
            if (widget.label != null || widget.sublabel != null)
              Flexible(
                child: Padding(
                  padding: effectivePadding,
                  child: Column(
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
                      if (widget.sublabel != null)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: DefaultTextStyle(
                            style: theme.textTheme.muted.fallback(
                              color: theme.colorScheme.mutedForeground,
                            ),
                            child: widget.sublabel!,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
