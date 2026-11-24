import 'package:finesse/src/components/disabled.dart';
import 'package:finesse/src/raw_components/focusable.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/debug_check.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Holds the selected value of a [FinesseRadioGroup] and whether the group is
/// enabled.
class RadioController<T> extends ValueNotifier<T?> {
  /// Creates a controller with the selected [value], null by default.
  /// The group is enabled by default.
  RadioController({T? value, bool enabled = true})
    : _enabled = enabled,
      super(value);

  late bool _enabled;

  /// Whether the radios of the group react to input. Setting it notifies
  /// listeners.
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }
}

/// A customizable radio group widget that allows selection of one item from
/// a list of options.
///
/// The [FinesseRadioGroup] widget is designed to manage a group of radio buttons
/// and handle their state. It supports various configurations such as
/// alignment, spacing, and initial value selection.
class FinesseRadioGroup<T> extends StatefulWidget {
  /// Creates a [FinesseRadioGroup] with the given [items] and optional
  /// parameters.
  ///
  /// The [items] parameter is required and should contain the list of radio
  /// options. The [initialValue] can be used to set the initially selected
  /// item. The [onChanged] callback is triggered when the selected value
  /// changes.
  const FinesseRadioGroup({
    super.key,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.axis,
    this.alignment,
    this.runAlignment,
    this.crossAxisAlignment,
    this.spacing,
    this.runSpacing,
    this.controller,
  });

  /// {@template FinesseRadioGroup.initialValue}
  /// The initial value of the radio group.
  /// {@endtemplate}
  final T? initialValue;

  /// {@template FinesseRadioGroup.items}
  /// The items of the radio group, any Widget can be used.
  /// {@endtemplate}
  final Iterable<Widget> items;

  /// {@template FinesseRadioGroup.onChanged}
  /// Called when the user toggles a radio on.
  /// {@endtemplate}
  final ValueChanged<T?>? onChanged;

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

  /// {@template FinesseRadioGroup.controller}
  /// An optional controller to programmatically control the selected value.
  /// {@endtemplate}
  final RadioController<T>? controller;

  @override
  State<FinesseRadioGroup<T>> createState() => RadioGroupState<T>();
}

/// The state of a [FinesseRadioGroup].
class RadioGroupState<T> extends State<FinesseRadioGroup<T>> {
  RadioController<T>? _controller;

  /// The controller in use: [FinesseRadioGroup.controller], or an internal one
  /// when that is null.
  RadioController<T> get effectiveController =>
      widget.controller ??
      (_controller ??= RadioController<T>(
        value: widget.initialValue,
        enabled: widget.enabled,
      ));

  @override
  void initState() {
    super.initState();
    effectiveController.addListener(onValueChanged);
  }

  @override
  void dispose() {
    effectiveController.removeListener(onValueChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FinesseRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      // The old controller, not effectiveController: that already resolves
      // to the new one, which left the listener on the old controller.
      (oldWidget.controller ?? _controller)?.removeListener(onValueChanged);
      if (oldWidget.controller == null && widget.controller != null) {
        _controller?.dispose();
        _controller = null;
      }
      effectiveController.addListener(onValueChanged);
    }

    if (oldWidget.initialValue != widget.initialValue) {
      effectiveController.value = widget.initialValue;
    }

    if (oldWidget.enabled != widget.enabled) {
      effectiveController.enabled = widget.enabled;
    }
  }

  /// Calls [FinesseRadioGroup.onChanged] with the value of the controller.
  ///
  /// It runs on every change of the controller, including changes made in
  /// code.
  void onValueChanged() {
    widget.onChanged?.call(effectiveController.value);
  }

  @override
  Widget build(BuildContext context) {
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

    return Provider(
      data: effectiveController as RadioController<dynamic>,
      child: Wrap(
        direction: effectiveAxis,
        spacing: effectiveSpacing,
        runSpacing: effectiveRunSpacing,
        alignment: effectiveAlignment,
        runAlignment: effectiveRunAlignment,
        crossAxisAlignment: effectiveWrapCrossAlignment,
        children: widget.items.toList(),
      ),
    );
  }
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
    this.duration,
    this.color,
    this.label,
    this.sublabel,
    this.padding,
    this.direction,
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

  /// {@template Radio.duration}
  /// The duration of the radio animation, defaults to 100ms.
  /// {@endtemplate}
  final Duration? duration;

  /// {@template Radio.color}
  /// The color of the radio.
  /// {@endtemplate}
  final Color? color;

  /// {@template Radio.label}
  /// An optional label for the radio, displayed on the right side if
  /// the [direction] is `TextDirection.ltr`.
  /// {@endtemplate}
  final Widget? label;

  /// {@template Radio.sublabel}
  /// An optional sublabel for the radio, displayed below the label.
  /// {@endtemplate}
  final Widget? sublabel;

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

  /// {@template Radio.direction}
  /// The direction of the radio.
  /// {@endtemplate}
  final TextDirection? direction;

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
    final inheritedController =
        context.watch<RadioController<dynamic>>() as RadioController<T>;

    void onTap() {
      inheritedController.value = widget.value;
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
    final effectiveDuration =
        widget.duration ?? theme.radioTheme.duration ?? 100.milliseconds;
    final effectivePadding =
        widget.padding ??
        theme.radioTheme.padding ??
        const EdgeInsetsDirectional.only(start: 8);

    final effectiveRadioPadding =
        widget.radioPadding ??
        theme.radioTheme.radioPadding ??
        const EdgeInsets.only(top: 1);

    final keyboardTriggers = <ShortcutActivator>[
      const SingleActivator(LogicalKeyboardKey.enter),
      const SingleActivator(LogicalKeyboardKey.space),
    ];

    return ValueListenableBuilder(
      valueListenable: inheritedController,
      builder: (context, value, child) {
        final selected = value == widget.value;
        final enabled = widget.enabled && inheritedController.enabled;

        final radio = Semantics(
          checked: selected,
          child: Disabled(
            showForbiddenCursor: true,
            disabled: !enabled,
            child: CallbackShortcuts(
              bindings: {
                for (final trigger in keyboardTriggers)
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
                  return Decorator(
                    focused: focused,
                    decoration: selected
                        ? effectiveCheckedDecoration
                        : effectiveDecoration,
                    child: child,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SizedBox.square(
                    dimension: effectiveSize,
                    child: AnimatedSwitcher(
                      duration: effectiveDuration,
                      child: selected
                          ? Align(
                              child: SizedBox.square(
                                dimension: effectiveCircleSize,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: effectiveColor,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        return Disabled(
          showForbiddenCursor: true,
          disabled: !enabled,
          disabledOpacity: 1,
          child: GestureDetector(
            onTap: enabled ? onTap : null,
            child: Row(
              textDirection: widget.direction,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: effectiveRadioPadding,
                  child: radio,
                ),
                if (widget.label != null)
                  Flexible(
                    child: Padding(
                      padding: effectivePadding,
                      child: Column(
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
                          if (widget.sublabel != null)
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: DefaultTextStyle(
                                style: theme.textTheme.muted,
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
      },
    );
  }
}
