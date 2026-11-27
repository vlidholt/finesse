import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/liquid_glass/controls.dart';
import 'package:una/src/liquid_glass/liquid_glass.dart';
import 'package:una/src/raw_components/focusable.dart';
import 'package:una/src/theme/components/slider.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/gesture_detector.dart';
import 'package:una/src/utils/haptics.dart';
import 'package:una/src/utils/shadow.dart';
import 'package:una/src/utils/spring.dart';

/// Possible ways for a user to interact with a [Slider].
enum SliderInteraction {
  /// Allows the user to interact with a [Slider] by tapping or sliding
  /// anywhere on the track.
  ///
  /// Essentially all possible interactions are allowed.
  ///
  /// This is different from [SliderInteraction.slideOnly] as when you try
  /// to slide anywhere other than the thumb, the thumb will move to the first
  /// point of contact.
  tapAndSlide,

  /// Allows the user to interact with a [Slider] by only tapping anywhere
  /// on the track.
  ///
  /// Sliding interaction is ignored.
  tapOnly,

  /// Allows the user to interact with a [Slider] only by sliding anywhere
  /// on the track.
  ///
  /// Tapping interaction is ignored.
  slideOnly,

  /// Allows the user to interact with a [Slider] only by sliding the thumb.
  ///
  /// Tapping and sliding interactions on the track are ignored.
  slideThumb,
}

/// When a slider shows its value in a bubble above the thumb.
enum SliderValueIndicator {
  /// Never. The value is still announced to assistive technology.
  never,

  /// While the thumb is dragged, hovered or has the keyboard focus.
  whileDragging,

  /// Always.
  always,
}

/// A customizable slider widget styled to match the Shadcn UI design system.
///
/// Allows users to select a value from a continuous range by dragging a thumb
/// along a track.
///
/// See [RangeSlider] for a slider with more than one thumb.
class Slider extends StatefulWidget {
  /// Creates a [Slider].
  ///
  /// Give [value] to hold the value yourself, changing it in [onChanged],
  /// or [initialValue] to let the slider keep it.
  const Slider({
    super.key,
    this.value,
    this.initialValue,
    this.onChanged,
    this.enabled = true,
    this.min,
    this.max,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.mouseCursor,
    this.disabledMouseCursor,
    this.thumbColor,
    this.disabledThumbColor,
    this.thumbBorderColor,
    this.disabledThumbBorderColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.disabledActiveTrackColor,
    this.disabledInactiveTrackColor,
    this.trackHeight,
    this.thumbRadius,
    this.onChangeStart,
    this.onChangeEnd,
    this.divisions,
    this.showDivisionMarks = true,
    this.valueIndicator = SliderValueIndicator.never,
    this.valueLabel,
    this.semanticLabel,
    this.semanticFormatterCallback,
    this.allowedInteraction,
  }) : assert(
         (value != null) ^ (initialValue != null),
         'Give value to control the slider or initialValue to seed it: one '
         'of the two, not both.',
       );

  /// The value of the slider, held by the parent: the slider shows it and
  /// reports a new one through [onChanged] without changing by itself.
  final double? value;

  /// The value the slider starts with when it keeps its own state.
  final double? initialValue;

  /// {@template Slider.onChanged}
  /// Callback that is called when the slider value changes.
  ///
  /// Provides the new value as an argument.
  /// {@endtemplate}
  final ValueChanged<double>? onChanged;

  /// {@template Slider.enabled}
  /// Whether the slider is enabled.
  ///
  /// When disabled, the slider cannot be interacted with and visually appears
  /// disabled. Defaults to true.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Slider.min}
  /// The minimum value the slider can take.
  ///
  /// Defaults to 0.0.
  /// {@endtemplate}
  final double? min;

  /// {@template Slider.max}
  /// The maximum value the slider can take.
  ///
  /// Defaults to 1.0.
  /// {@endtemplate}
  final double? max;

  /// {@template Slider.focusNode}
  /// The focus node to control the focus state of the slider.
  ///
  /// If null, a default [FocusNode] will be created internally.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Widget.onFocusChange}
  /// Called when the focus state of this widget changes.
  /// {@endtemplate}
  final ValueChanged<bool>? onFocusChange;

  /// {@template Slider.autofocus}
  /// Whether the slider should automatically focus when it is first built.
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Slider.mouseCursor}
  /// The cursor for the slider when it is enabled.
  ///
  /// Defaults to [SystemMouseCursors.click].
  /// {@endtemplate}
  final MouseCursor? mouseCursor;

  /// {@template Slider.disabledMouseCursor}
  /// The cursor for the slider when it is disabled.
  ///
  /// Defaults to [SystemMouseCursors.forbidden].
  /// {@endtemplate}
  final MouseCursor? disabledMouseCursor;

  /// {@template Slider.thumbColor}
  /// The color of the slider thumb when enabled.
  ///
  /// Defaults to the theme's background color.
  /// {@endtemplate}
  final Color? thumbColor;

  /// {@template Slider.disabledThumbColor}
  /// The color of the slider thumb when disabled.
  ///
  /// Defaults to the theme's background color.
  /// {@endtemplate}
  final Color? disabledThumbColor;

  /// {@template Slider.thumbBorderColor}
  /// The border color of the slider thumb when enabled.
  ///
  /// Defaults to the theme's primary color.
  /// {@endtemplate}
  final Color? thumbBorderColor;

  /// {@template Slider.disabledThumbBorderColor}
  /// The border color of the slider thumb when disabled.
  ///
  /// Defaults to a semi-transparent version of the theme's primary color.
  /// {@endtemplate}
  final Color? disabledThumbBorderColor;

  /// {@template Slider.activeTrackColor}
  /// The color of the active portion of the slider track.
  ///
  /// Defaults to the theme's primary color.
  /// {@endtemplate}
  final Color? activeTrackColor;

  /// {@template Slider.inactiveTrackColor}
  /// The color of the inactive portion of the slider track.
  ///
  /// Defaults to the theme's secondary color.
  /// {@endtemplate}
  final Color? inactiveTrackColor;

  /// {@template Slider.disabledActiveTrackColor}
  /// The color of the active track when the slider is disabled.
  ///
  /// Defaults to a semi-transparent version of the theme's primary color.
  /// {@endtemplate}
  final Color? disabledActiveTrackColor;

  /// {@template Slider.disabledInactiveTrackColor}
  /// The color of the inactive track when the slider is disabled.
  ///
  /// Defaults to a semi-transparent version of the theme's secondary color.
  /// {@endtemplate}
  final Color? disabledInactiveTrackColor;

  /// {@template Slider.trackHeight}
  /// The height of the slider track.
  ///
  /// Defaults to 8.0.
  /// {@endtemplate}
  final double? trackHeight;

  /// {@template Slider.thumbRadius}
  /// The radius of the slider thumb.
  ///
  /// Defaults to 10.0.
  /// {@endtemplate}
  final double? thumbRadius;

  /// {@template Slider.onChangeStart}
  /// Callback that is called when the user starts to change the slider value.
  ///
  /// Provides the starting value as an argument.
  /// {@endtemplate}
  final ValueChanged<double>? onChangeStart;

  /// {@template Slider.onChangeEnd}
  /// Callback that is called when the user finishes changing the slider value.
  ///
  /// Provides the ending value as an argument.
  /// {@endtemplate}
  final ValueChanged<double>? onChangeEnd;

  /// {@template Slider.divisions}
  /// The number of discrete divisions the slider has.
  ///
  /// When provided, the slider will snap to these divisions.
  /// {@endtemplate}
  final int? divisions;

  /// {@template Slider.showDivisionMarks}
  /// Whether to draw the tick marks on the track when [divisions] is set.
  ///
  /// Snapping still applies either way; set this to false for a clean track
  /// that snaps. Defaults to true.
  /// {@endtemplate}
  final bool showDivisionMarks;

  /// {@template Slider.valueIndicator}
  /// When the value shows in a bubble above the thumb: never, while the
  /// thumb is dragged, hovered or focused, or always.
  /// {@endtemplate}
  final SliderValueIndicator valueIndicator;

  /// {@template Slider.valueLabel}
  /// Turns a value into the text of the bubble, and into what assistive
  /// technology reads when there is no [semanticFormatterCallback].
  /// Defaults to the number, with decimals only when it has any.
  /// {@endtemplate}
  final String Function(double value)? valueLabel;

  /// {@template Slider.semanticLabel}
  /// The slider's accessible name, announced by assistive technologies
  /// together with its value.
  /// {@endtemplate}
  final String? semanticLabel;

  /// {@template Slider.semanticFormatterCallback}
  /// A semantic formatter to be called by assistive technologies.
  /// {@endtemplate}
  final String Function(double value)? semanticFormatterCallback;

  /// {@template Slider.allowedInteraction}
  /// Configures how the user can interact with the slider.
  ///
  /// Defaults to `SliderInteraction.tapAndSlide`.
  /// {@endtemplate}
  final SliderInteraction? allowedInteraction;

  @override
  State<Slider> createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  late double _value = widget.value ?? widget.initialValue!;

  @override
  Widget build(BuildContext context) {
    final value = widget.value ?? _value;
    final theme = Theme.of(context);
    final sliderTheme = theme.sliderTheme;
    // A value bubble, division marks and restricted interaction are
    // una's own; a slider that asks for one keeps una's look.
    if (widget.valueIndicator != SliderValueIndicator.always &&
        (widget.divisions == null || !widget.showDivisionMarks) &&
        widget.allowedInteraction == null &&
        LiquidGlass.isActive(context, sliderTheme.liquidGlass)) {
      final scheme = theme.colorScheme;
      final slider = LiquidGlassSlider(
        value: value,
        onChanged: widget.enabled
            ? (next) {
                if (widget.value == null) setState(() => _value = next);
                widget.onChanged?.call(next);
              }
            : null,
        onChangeStart: widget.onChangeStart,
        onChangeEnd: widget.onChangeEnd,
        min: widget.min ?? sliderTheme.min ?? 0,
        max: widget.max ?? sliderTheme.max ?? 1,
        divisions: widget.divisions,
        trackHeight: widget.trackHeight ?? sliderTheme.trackHeight ?? 8,
        thumbSize: 2 * (widget.thumbRadius ?? sliderTheme.thumbRadius ?? 10),
        activeColor:
            widget.activeTrackColor ??
            sliderTheme.activeTrackColor ??
            scheme.primary,
        inactiveColor:
            widget.inactiveTrackColor ??
            sliderTheme.inactiveTrackColor ??
            scheme.secondary,
        thumbColor:
            widget.thumbColor ?? sliderTheme.thumbColor ?? scheme.background,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
      );
      if (widget.semanticLabel == null) return slider;
      return Semantics(label: widget.semanticLabel, child: slider);
    }
    final slider = _SliderCore(
      // One thumb: the multi-thumb core collapses to exactly the
      // single-value slider when handed a one-element list.
      values: [value],
      onValuesChanged: (values) {
        // A controlled slider waits for its parent to hand the value back.
        if (widget.value == null) setState(() => _value = values.first);
        widget.onChanged?.call(values.first);
      },
      enabled: widget.enabled,
      min: widget.min,
      max: widget.max,
      focusNode: widget.focusNode,
      onFocusChange: widget.onFocusChange,
      autofocus: widget.autofocus,
      mouseCursor: widget.mouseCursor,
      disabledMouseCursor: widget.disabledMouseCursor,
      thumbColor: widget.thumbColor,
      disabledThumbColor: widget.disabledThumbColor,
      thumbBorderColor: widget.thumbBorderColor,
      disabledThumbBorderColor: widget.disabledThumbBorderColor,
      activeTrackColor: widget.activeTrackColor,
      inactiveTrackColor: widget.inactiveTrackColor,
      disabledActiveTrackColor: widget.disabledActiveTrackColor,
      disabledInactiveTrackColor: widget.disabledInactiveTrackColor,
      trackHeight: widget.trackHeight,
      thumbRadius: widget.thumbRadius,
      onChangeStart: (values) => widget.onChangeStart?.call(values.first),
      onChangeEnd: (values) => widget.onChangeEnd?.call(values.first),
      divisions: widget.divisions,
      showDivisionMarks: widget.showDivisionMarks,
      allowedInteraction: widget.allowedInteraction,
      valueIndicator: widget.valueIndicator,
      valueLabel: widget.valueLabel,
      semanticFormatter: widget.semanticFormatterCallback == null
          ? null
          : (value, _) => widget.semanticFormatterCallback!(value),
    );
    if (widget.semanticLabel == null) return slider;
    return Semantics(label: widget.semanticLabel, child: slider);
  }
}

/// A slider with more than one thumb, styled to match the Shadcn UI design
/// system — shadcn/ui's `Slider` given an array of values.
///
/// Two thumbs select a range; any number is supported. The active track spans
/// the selected range rather than starting at the minimum, and each thumb is
/// focusable and adjustable with the arrow keys on its own.
///
/// The values stay in ascending order: a thumb stops when it meets its
/// neighbour rather than crossing it, so `values.first` and `values.last` are
/// always the ends of the range.
///
/// ```dart
/// RangeSlider(
///   values: _range,
///   max: 100,
///   onChanged: (values) => setState(() => _range = values),
/// )
/// ```
class RangeSlider extends StatefulWidget {
  /// Creates a [RangeSlider].
  ///
  /// Give [values] to hold the values yourself, changing them in
  /// [onChanged], or [initialValues] to let the slider keep them: one per
  /// thumb, in ascending order.
  const RangeSlider({
    super.key,
    this.values,
    this.initialValues,
    this.onChanged,
    this.enabled = true,
    this.min,
    this.max,
    this.autofocus = false,
    this.focusNode,
    this.mouseCursor,
    this.disabledMouseCursor,
    this.thumbColor,
    this.disabledThumbColor,
    this.thumbBorderColor,
    this.disabledThumbBorderColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.disabledActiveTrackColor,
    this.disabledInactiveTrackColor,
    this.trackHeight,
    this.thumbRadius,
    this.onChangeStart,
    this.onChangeEnd,
    this.divisions,
    this.showDivisionMarks = true,
    this.valueIndicator = SliderValueIndicator.never,
    this.valueLabel,
    this.semanticLabel,
    this.semanticFormatterCallback,
    this.allowedInteraction,
  }) : assert(
         (values != null) ^ (initialValues != null),
         'Give values to control the slider or initialValues to seed it: '
         'one of the two, not both.',
       );

  /// The values of the slider, one per thumb in ascending order, held by
  /// the parent: the slider shows them and reports new ones through
  /// [onChanged] without changing by itself.
  final List<double>? values;

  /// The values the slider starts with when it keeps its own state, one
  /// per thumb in ascending order.
  final List<double>? initialValues;

  /// {@template RangeSlider.onChanged}
  /// Callback that is called when any of the slider values change.
  ///
  /// Provides the full list of values as an argument.
  /// {@endtemplate}
  final ValueChanged<List<double>>? onChanged;

  /// {@macro Slider.enabled}
  final bool enabled;

  /// {@macro Slider.min}
  final double? min;

  /// {@macro Slider.max}
  final double? max;

  /// {@template RangeSlider.autofocus}
  /// Whether the lowest thumb should automatically focus when the slider is
  /// first built.
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool autofocus;

  /// The focus node of the lowest thumb. The other thumbs have nodes of
  /// their own.
  final FocusNode? focusNode;

  /// {@macro Slider.mouseCursor}
  final MouseCursor? mouseCursor;

  /// {@macro Slider.disabledMouseCursor}
  final MouseCursor? disabledMouseCursor;

  /// {@macro Slider.thumbColor}
  final Color? thumbColor;

  /// {@macro Slider.disabledThumbColor}
  final Color? disabledThumbColor;

  /// {@macro Slider.thumbBorderColor}
  final Color? thumbBorderColor;

  /// {@macro Slider.disabledThumbBorderColor}
  final Color? disabledThumbBorderColor;

  /// {@macro Slider.activeTrackColor}
  final Color? activeTrackColor;

  /// {@macro Slider.inactiveTrackColor}
  final Color? inactiveTrackColor;

  /// {@macro Slider.disabledActiveTrackColor}
  final Color? disabledActiveTrackColor;

  /// {@macro Slider.disabledInactiveTrackColor}
  final Color? disabledInactiveTrackColor;

  /// {@macro Slider.trackHeight}
  final double? trackHeight;

  /// {@macro Slider.thumbRadius}
  final double? thumbRadius;

  /// {@template RangeSlider.onChangeStart}
  /// Callback that is called when the user starts to change a value.
  ///
  /// Provides the values as they were when the gesture started.
  /// {@endtemplate}
  final ValueChanged<List<double>>? onChangeStart;

  /// {@template RangeSlider.onChangeEnd}
  /// Callback that is called when the user finishes changing a value.
  ///
  /// Provides the final values as an argument.
  /// {@endtemplate}
  final ValueChanged<List<double>>? onChangeEnd;

  /// {@macro Slider.divisions}
  final int? divisions;

  /// {@macro Slider.showDivisionMarks}
  final bool showDivisionMarks;

  /// {@template RangeSlider.semanticFormatterCallback}
  /// A semantic formatter to be called by assistive technologies, with the
  /// value of one thumb and its index.
  /// {@endtemplate}
  final String Function(double value, int index)? semanticFormatterCallback;

  /// {@macro Slider.allowedInteraction}
  final SliderInteraction? allowedInteraction;

  /// {@macro Slider.valueIndicator}
  final SliderValueIndicator valueIndicator;

  /// {@macro Slider.valueLabel}
  final String Function(double value)? valueLabel;

  /// {@macro Slider.semanticLabel}
  final String? semanticLabel;

  @override
  State<RangeSlider> createState() => _RangeSliderState();
}

class _RangeSliderState extends State<RangeSlider> {
  late List<double> _values = List.of(
    widget.values ?? widget.initialValues!,
  );

  @override
  Widget build(BuildContext context) {
    final slider = _SliderCore(
      values: widget.values ?? _values,
      onValuesChanged: (next) {
        // A controlled slider waits for its parent to hand the values back.
        if (widget.values == null) setState(() => _values = next);
        widget.onChanged?.call(next);
      },
      enabled: widget.enabled,
      min: widget.min,
      max: widget.max,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      mouseCursor: widget.mouseCursor,
      disabledMouseCursor: widget.disabledMouseCursor,
      thumbColor: widget.thumbColor,
      disabledThumbColor: widget.disabledThumbColor,
      thumbBorderColor: widget.thumbBorderColor,
      disabledThumbBorderColor: widget.disabledThumbBorderColor,
      activeTrackColor: widget.activeTrackColor,
      inactiveTrackColor: widget.inactiveTrackColor,
      disabledActiveTrackColor: widget.disabledActiveTrackColor,
      disabledInactiveTrackColor: widget.disabledInactiveTrackColor,
      trackHeight: widget.trackHeight,
      thumbRadius: widget.thumbRadius,
      onChangeStart: widget.onChangeStart,
      onChangeEnd: widget.onChangeEnd,
      divisions: widget.divisions,
      showDivisionMarks: widget.showDivisionMarks,
      allowedInteraction: widget.allowedInteraction,
      valueIndicator: widget.valueIndicator,
      valueLabel: widget.valueLabel,
      semanticFormatter: widget.semanticFormatterCallback,
    );
    if (widget.semanticLabel == null) return slider;
    return Semantics(label: widget.semanticLabel, child: slider);
  }
}

/// The slider implementation both [Slider] and [RangeSlider] render.
///
/// Holds no value of its own — the values come down from the wrapper's
/// controller and go back up through [onValuesChanged] — so there is exactly
/// one source of truth however many thumbs there are. A single-thumb core is
/// pixel-for-pixel the old single-value slider: the active track simply starts
/// at the minimum instead of at the lowest thumb.
class _SliderCore extends StatefulWidget {
  const _SliderCore({
    required this.values,
    required this.onValuesChanged,
    required this.enabled,
    required this.autofocus,
    required this.min,
    required this.max,
    required this.mouseCursor,
    required this.disabledMouseCursor,
    required this.thumbColor,
    required this.disabledThumbColor,
    required this.thumbBorderColor,
    required this.disabledThumbBorderColor,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.disabledActiveTrackColor,
    required this.disabledInactiveTrackColor,
    required this.trackHeight,
    required this.thumbRadius,
    required this.onChangeStart,
    required this.onChangeEnd,
    required this.divisions,
    required this.showDivisionMarks,
    required this.allowedInteraction,
    required this.semanticFormatter,
    required this.valueIndicator,
    required this.valueLabel,
    this.focusNode,
    this.onFocusChange,
  });

  final List<double> values;
  final ValueChanged<List<double>> onValuesChanged;
  final bool enabled;
  final bool autofocus;
  final double? min;
  final double? max;

  /// The focus node of the first thumb, when the caller supplies one.
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  final MouseCursor? mouseCursor;
  final MouseCursor? disabledMouseCursor;
  final Color? thumbColor;
  final Color? disabledThumbColor;
  final Color? thumbBorderColor;
  final Color? disabledThumbBorderColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? disabledActiveTrackColor;
  final Color? disabledInactiveTrackColor;
  final double? trackHeight;
  final double? thumbRadius;
  final ValueChanged<List<double>>? onChangeStart;
  final ValueChanged<List<double>>? onChangeEnd;
  final int? divisions;
  final bool showDivisionMarks;
  final SliderInteraction? allowedInteraction;
  final String Function(double value, int index)? semanticFormatter;
  final SliderValueIndicator valueIndicator;
  final String Function(double value)? valueLabel;

  @override
  State<_SliderCore> createState() => _SliderCoreState();
}

class _SliderCoreState extends State<_SliderCore> {
  /// The focus nodes this state owns, by thumb index.
  ///
  /// Thumb 0 uses the caller's node when there is one, so
  /// [Slider.focusNode] still addresses the thumb it always did.
  final _ownedFocusNodes = <int, FocusNode>{};

  FocusNode _focusNodeFor(int index) {
    if (index == 0 && widget.focusNode != null) return widget.focusNode!;
    return _ownedFocusNodes.putIfAbsent(
      index,
      () => FocusNode(debugLabel: 'Slider thumb $index'),
    );
  }

  /// The thumb the pointer is over.
  ///
  /// shadcn shows the thumb's ring on `hover:` as well as `focus-visible:`,
  /// so the control tells you it is grabbable before you touch it.
  int? hoveredThumb;

  void _setHovered(int? index) {
    if (hoveredThumb == index) return;
    setState(() => hoveredThumb = index);
  }

  /// The thumb being dragged.
  ///
  /// Tracked separately from [hoveredThumb]: a drag routinely takes the
  /// pointer outside the slider, and the ring has to stay up for the whole
  /// gesture.
  int? draggingThumb;

  void _setDragging(int? index) {
    if (draggingThumb == index) return;
    setState(() => draggingThumb = index);
  }

  @override
  void didUpdateWidget(covariant _SliderCore oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Drop the nodes of thumbs that no longer exist.
    if (widget.values.length < oldWidget.values.length) {
      for (final index in _ownedFocusNodes.keys.toList()) {
        if (index >= widget.values.length) {
          _ownedFocusNodes.remove(index)!.dispose();
        }
      }
    }
  }

  @override
  void dispose() {
    for (final node in _ownedFocusNodes.values) {
      node.dispose();
    }
    _ownedFocusNodes.clear();
    super.dispose();
  }

  // The bounds are read through the theme here as well as in build, so a
  // theme-level min/max reaches the interaction maths and not just the paint.
  SliderTheme get _sliderTheme => Theme.of(context, listen: false).sliderTheme;

  /// Whether the drag in progress is a finger's or a stylus's.
  bool _touchDrag = false;

  void _dragStarted(DragStartDetails details) {
    _touchDrag =
        details.kind == PointerDeviceKind.touch ||
        details.kind == PointerDeviceKind.stylus;
  }

  /// The value as the bubble writes it.
  String _labelOf(double value) {
    final label = widget.valueLabel;
    if (label != null) return label(value);
    // Two decimals at most, and none that are zero: a value worked out
    // from a position is rarely a whole number to the last bit.
    final text = value.toStringAsFixed(2);
    return text.contains('.') ? text.replaceFirst(RegExp(r'\.?0+$'), '') : text;
  }

  double get _min => widget.min ?? _sliderTheme.min ?? 0;

  double get _max => widget.max ?? _sliderTheme.max ?? 1;

  /// [value] clamped into the slider's bounds and snapped to its divisions.
  double _clampAndSnap(double value) {
    final min = _min;
    final max = _max;
    var result = value.clamp(min, max);

    final divisions = widget.divisions;
    if (divisions != null && divisions > 0) {
      final step = (max - min) / divisions;
      result = ((result - min) / step).round() * step + min;
    }
    return result;
  }

  /// Where thumb [index] stops on its way to [rawValue]: in the bounds, on
  /// a division, and short of crossing a neighbour.
  double _constrain(int index, double rawValue) {
    final values = widget.values;
    var value = _clampAndSnap(rawValue);
    if (index > 0) value = math.max(value, values[index - 1]);
    if (index < values.length - 1) value = math.min(value, values[index + 1]);
    return value;
  }

  /// How far a key or assistive technology moves a thumb: one division, or
  /// a hundredth of the range on a smooth slider.
  double get _step {
    final range = _max - _min;
    final divisions = widget.divisions;
    return divisions != null && divisions > 0 ? range / divisions : range * .01;
  }

  /// Moves thumb [index] to [rawValue], keeping the values in ascending
  /// order: a thumb stops where its neighbour is rather than crossing it.
  void _updateThumb(int index, double rawValue) {
    final values = widget.values;
    if (index < 0 || index >= values.length) return;

    final value = _constrain(index, rawValue);
    if (values[index] == value) return;
    // A finger feels each stop of a stepped slider as it passes, and
    // either end of any slider as the thumb arrives there.
    if (_touchDrag) {
      if (value == _min || value == _max) {
        Haptics.impact(context);
      } else if ((widget.divisions ?? 0) > 0) {
        Haptics.selection(context);
      }
    }
    widget.onValuesChanged(List<double>.of(values)..[index] = value);
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  /// The value the given horizontal offset into the track represents: from
  /// the left, or from the right where text runs that way.
  double _valueFromDx(double dx, double trackWidth, double thumbRadius) {
    // The thumb's centre travels a thumb radius in from each end, so the
    // value under a pointer is read along that span: the thumb follows
    // the finger exactly, and either end is reached with the thumb still
    // whole inside the track.
    final travel = trackWidth - thumbRadius * 2;
    if (travel <= 0) return _min;
    final fromStart = _rtl ? trackWidth - dx : dx;
    return _min + ((fromStart - thumbRadius) / travel) * (_max - _min);
  }

  /// How far from its thumb's centre the pointer took hold of it, so a
  /// thumb grabbed by its edge does not jump to centre on the pointer.
  double _grabOffset = 0;

  /// The thumb a pointer at [value] should grab.
  int _nearestThumb(double value) {
    final values = widget.values;
    var best = 0;
    var bestDistance = (values[0] - value).abs();
    for (var i = 1; i < values.length; i++) {
      final distance = (values[i] - value).abs();
      // On a tie the later thumb wins only when the pointer is past it, so
      // thumbs resting on the same value can be pulled apart either way.
      if (distance < bestDistance ||
          (distance == bestDistance && value > values[i])) {
        bestDistance = distance;
        best = i;
      }
    }
    return best;
  }

  /// The slider's own box, which every pointer position is measured against.
  RenderBox? _sliderBox(BuildContext layoutContext) =>
      layoutContext.findRenderObject() as RenderBox?;

  double? _localDx(BuildContext layoutContext, Offset globalPosition) {
    final box = _sliderBox(layoutContext);
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(globalPosition).dx;
  }

  bool _handleKeyEvent(int index, KeyEvent event) {
    if (!widget.enabled ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return false;
    }

    var increment = _step;
    if (HardwareKeyboard.instance.isShiftPressed) {
      increment *= 10;
    }

    if (index < 0 || index >= widget.values.length) return false;
    var newValue = widget.values[index];
    // Right to left, the left arrow points at the far end.
    final towardsEnd = _rtl
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowRight;
    final towardsStart = _rtl
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowLeft;

    final key = event.logicalKey;
    if (key == towardsStart || key == LogicalKeyboardKey.arrowDown) {
      newValue -= increment;
    } else if (key == towardsEnd || key == LogicalKeyboardKey.arrowUp) {
      newValue += increment;
    } else {
      return false;
    }

    _updateThumb(index, newValue);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveMouseCursor =
        widget.mouseCursor ??
        theme.sliderTheme.mouseCursor ??
        SystemMouseCursors.click;
    final effectiveDisabledMouseCursor =
        widget.disabledMouseCursor ??
        theme.sliderTheme.disabledMouseCursor ??
        SystemMouseCursors.forbidden;

    final effectiveMin = widget.min ?? theme.sliderTheme.min ?? 0;
    final effectiveMax = widget.max ?? theme.sliderTheme.max ?? 1;

    final effectiveThumbColor =
        widget.thumbColor ??
        theme.sliderTheme.thumbColor ??
        theme.colorScheme.background;

    final effectiveThumbBorderColor =
        widget.thumbBorderColor ??
        theme.sliderTheme.thumbBorderColor ??
        theme.colorScheme.primary;

    final effectiveDisabledThumbColor =
        widget.disabledThumbColor ??
        theme.sliderTheme.disabledThumbColor ??
        theme.colorScheme.background;

    final effectiveDisabledThumbBorderColor =
        widget.disabledThumbBorderColor ??
        theme.sliderTheme.disabledThumbBorderColor ??
        theme.colorScheme.primary.withValues(alpha: .5);

    // Resolved here rather than inline: the ternaries sat six levels deep in
    // the widget tree and no longer fit on a line.
    final resolvedThumbColor = widget.enabled
        ? effectiveThumbColor
        : effectiveDisabledThumbColor;
    final resolvedThumbBorderColor = widget.enabled
        ? effectiveThumbBorderColor
        : effectiveDisabledThumbBorderColor;

    final effectiveActiveTrackColor =
        widget.activeTrackColor ??
        theme.sliderTheme.activeTrackColor ??
        theme.colorScheme.primary;

    final effectiveInactiveTrackColor =
        widget.inactiveTrackColor ??
        theme.sliderTheme.inactiveTrackColor ??
        theme.colorScheme.secondary;

    final effectiveDisabledActiveTrackColor =
        widget.disabledActiveTrackColor ??
        theme.sliderTheme.disabledActiveTrackColor ??
        theme.colorScheme.primary.withValues(alpha: .5);

    final effectiveDisabledInactiveTrackColor =
        widget.disabledInactiveTrackColor ??
        theme.sliderTheme.disabledInactiveTrackColor ??
        theme.colorScheme.secondary.withValues(alpha: .5);

    final effectiveTrackHeight =
        widget.trackHeight ?? theme.sliderTheme.trackHeight ?? 8;

    final effectiveThumbRadius =
        widget.thumbRadius ?? theme.sliderTheme.thumbRadius ?? 10.0;

    final effectiveAllowedInteraction =
        widget.allowedInteraction ?? SliderInteraction.tapAndSlide;

    final canTap =
        widget.enabled &&
        (effectiveAllowedInteraction == SliderInteraction.tapAndSlide ||
            effectiveAllowedInteraction == SliderInteraction.tapOnly);
    final canSlideTrack =
        widget.enabled &&
        (effectiveAllowedInteraction == SliderInteraction.tapAndSlide ||
            effectiveAllowedInteraction == SliderInteraction.slideOnly);
    final canSlideThumb =
        widget.enabled &&
        effectiveAllowedInteraction != SliderInteraction.tapOnly;

    // The thumb's ring is the same one fields draw: colour, opacity and width
    // all come from the theme's focus ring rather than being invented here.
    final ringSide = theme.decoration.secondaryFocusedBorder?.top;
    final ringColor =
        ringSide?.color ?? theme.colorScheme.ring.withValues(alpha: .5);
    final ringWidth = ringSide?.width ?? 3.0;

    const thumbBorderWidth = 2.0;

    // Division marks configuration
    const divisionMarkWidth = 2.0;
    const divisionMarkHeight = 6.0;
    const divisionMarkOffset = 1.0;
    const divisionMarkBorderRadius = 1.0;

    final values = widget.values;
    final range = effectiveMax - effectiveMin;
    double fractionOf(double value) =>
        range == 0 ? 0.0 : ((value - effectiveMin) / range).clamp(0.0, 1.0);
    // The minimum is at the start: on the right where text runs that way.
    final rtl = _rtl;
    double fromLeft(double fraction) => rtl ? 1 - fraction : fraction;

    // A single thumb fills the track from the minimum; two or more fill the
    // span between the outermost thumbs, shadcn's `SliderIndicator`.
    final lowFraction = values.length < 2
        ? 0.0
        : fractionOf(values.reduce(math.min));
    final highFraction = values.isEmpty
        ? 0.0
        : fractionOf(
            values.length < 2 ? values.first : values.reduce(math.max),
          );

    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        assert(
          constraints.hasBoundedWidth,
          'Slider requires a bounded width',
        );
        // Calculate the effective width available for the track
        final effectiveTrackWidth = constraints.maxWidth;
        // The thumb is usually taller than the track, so the slider
        // has to reserve room for it. Sizing to the track alone let
        // the thumb spill over whatever sat above and below, which
        // read as a slider with no vertical padding at all.
        //
        // The focus ring is deliberately excluded: it is allowed to
        // overflow (the Stack does not clip) so that focusing a
        // slider never reflows the layout around it.
        final effectiveHeight = math.max(
          effectiveTrackHeight,
          effectiveThumbRadius * 2,
        );

        final motion = Motion.of(layoutContext);
        final liquid = LiquidGlass.isActive(
          layoutContext,
          theme.sliderTheme.liquidGlass,
        );
        final thumbPressScale =
            theme.sliderTheme.thumbPressScale ??
            1 + (1 - motion.pressScale) * 4;

        Widget buildThumb(int index) {
          final value = values[index];
          String semanticValue(double value) =>
              widget.semanticFormatter?.call(value, index) ??
              (widget.valueLabel == null ? value.toString() : _labelOf(value));
          final increased = _constrain(index, value + _step);
          final decreased = _constrain(index, value - _step);
          // Radix keeps the thumb inside the slider's bounds
          // (`getThumbInBoundsOffset`): its centre travels from a radius
          // in at the minimum to a radius in at the maximum. A thumb that
          // hung half outside at either end could not be grabbed by its
          // outer half, which no box around the slider hit-tests.
          final travel = math.max<double>(
            0,
            effectiveTrackWidth - effectiveThumbRadius * 2,
          );
          final centre =
              effectiveThumbRadius + fromLeft(fractionOf(value)) * travel;
          return Positioned(
            key: ValueKey<int>(index),
            left: centre - effectiveThumbRadius,
            top: (effectiveHeight - effectiveThumbRadius * 2) / 2,
            child: Focusable(
              visibleOnly: true,
              focusNode: _focusNodeFor(index),
              canRequestFocus: widget.enabled,
              // Only the first thumb reports focus to the caller: it is the
              // one [Slider.focusNode] addresses.
              onFocusChange: index == 0 ? widget.onFocusChange : null,
              autofocus: widget.autofocus && index == 0,
              onKeyEvent: (node, event) {
                return _handleKeyEvent(index, event)
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
              },
              builder: (context, focused, child) {
                final ringVisible =
                    widget.enabled &&
                    (focused ||
                        hoveredThumb == index ||
                        draggingThumb == index);
                final bubbleVisible = switch (widget.valueIndicator) {
                  SliderValueIndicator.never => false,
                  SliderValueIndicator.always => true,
                  SliderValueIndicator.whileDragging => ringVisible,
                };
                return _SliderValueBubble(
                  enabled: widget.valueIndicator != SliderValueIndicator.never,
                  visible: bubbleVisible,
                  label: _labelOf(value),
                  child: Semantics(
                    slider: true,
                    value: semanticValue(value),
                    increasedValue: semanticValue(increased),
                    decreasedValue: semanticValue(decreased),
                    onIncrease: widget.enabled && increased != value
                        ? () => _updateThumb(index, increased)
                        : null,
                    onDecrease: widget.enabled && decreased != value
                        ? () => _updateThumb(index, decreased)
                        : null,
                    child: SizedBox(
                      width: effectiveThumbRadius * 2,
                      height: effectiveThumbRadius * 2,
                      child: UnaGestureDetector(
                        mouseCursor: widget.enabled
                            ? effectiveMouseCursor
                            : effectiveDisabledMouseCursor,
                        onPanUpdate: canSlideThumb
                            ? (details) {
                                final dx = _localDx(
                                  layoutContext,
                                  details.globalPosition,
                                );
                                if (dx == null) return;
                                _updateThumb(
                                  index,
                                  _valueFromDx(
                                    dx - _grabOffset,
                                    effectiveTrackWidth,
                                    effectiveThumbRadius,
                                  ),
                                );
                              }
                            : null,
                        onPanDown: widget.enabled
                            ? (details) {
                                _grabOffset =
                                    details.localPosition.dx -
                                    effectiveThumbRadius;
                                _setDragging(index);
                              }
                            : null,
                        onPanCancel: widget.enabled
                            ? () => _setDragging(null)
                            : null,
                        onPanStart: widget.enabled
                            ? (details) {
                                _dragStarted(details);
                                _setDragging(index);
                                widget.onChangeStart?.call(widget.values);
                              }
                            : null,
                        onPanEnd: widget.enabled
                            ? (details) {
                                _setDragging(null);
                                widget.onChangeEnd?.call(widget.values);
                              }
                            : null,
                        child: MouseRegion(
                          onEnter: (_) => _setHovered(index),
                          onExit: (_) => _setHovered(null),
                          // On Liquid Glass the thumb is the package's
                          // capsule, which turns to a lens while held.
                          child: liquid
                              ? LiquidGlassSliderThumb(
                                  thumbRadius: effectiveThumbRadius,
                                  color: resolvedThumbColor,
                                  pressed:
                                      draggingThumb == index && widget.enabled,
                                  focusColor: focused && widget.enabled
                                      ? ringColor
                                      : null,
                                )
                              // The ring grows out of the thumb and the thumb
                              // swells while it is held; both are paint only,
                              // so the slider's box never changes.
                              : SpringBuilder(
                                  value:
                                      draggingThumb == index && widget.enabled
                                      ? 1
                                      : 0,
                                  spring: motion.bouncy,
                                  builder: (context, press, child) =>
                                      Transform.scale(
                                        scale:
                                            1 + (thumbPressScale - 1) * press,
                                        child: child,
                                      ),
                                  child: SpringBuilder(
                                    value: ringVisible ? 1 : 0,
                                    spring: motion.snappy,
                                    builder: (context, ring, _) => Container(
                                      decoration: ShadowDecoration.box(
                                        shape: BoxShape.circle,
                                        color: resolvedThumbColor,
                                        border: Border.all(
                                          color: resolvedThumbBorderColor,
                                          width: thumbBorderWidth,
                                        ),
                                        // A spread-only shadow is a ring: it
                                        // grows outward without moving
                                        // anything, as `hover:ring-4` does.
                                        shadows: ring > 0
                                            ? [
                                                BoxShadow(
                                                  color: ringColor,
                                                  spreadRadius:
                                                      ringWidth * ring,
                                                ),
                                              ]
                                            : const <BoxShadow>[],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Painted — and therefore traversed — in value order, so tabbing
        // through the thumbs runs from the start to the end however the
        // values are ordered in the list.
        final thumbOrder = List<int>.generate(values.length, (i) => i)
          ..sort((a, b) {
            final byValue = values[a].compareTo(values[b]);
            if (byValue != 0) return byValue;
            // Tied thumbs stack with the highest index on top, so a tie at
            // the minimum still surfaces the one thumb able to move (the
            // others are pinned below by a same-valued lower neighbour).
            // At the maximum that same rule pins every higher-index thumb
            // in the tied run in place instead, so it is inverted there:
            // the lowest index — the only one still free to move — goes on
            // top. Without this a range dragged fully to one side can
            // never be pulled back with the pointer.
            if (values[a] == effectiveMax) return b.compareTo(a);
            return a.compareTo(b);
          });

        return SizedBox(
          height: effectiveHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerLeft,
            children: [
              // Track with gesture handling based on interaction mode. It
              // takes the slider's whole height, so a finger need not land
              // on the thin track itself.
              Positioned.fill(
                child: UnaGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  mouseCursor: widget.enabled
                      ? effectiveMouseCursor
                      : effectiveDisabledMouseCursor,
                  onTapDown: canTap && values.isNotEmpty
                      ? (details) {
                          final dx = _localDx(
                            layoutContext,
                            details.globalPosition,
                          );
                          if (dx == null) return;
                          final value = _valueFromDx(
                            dx,
                            effectiveTrackWidth,
                            effectiveThumbRadius,
                          );
                          _updateThumb(_nearestThumb(value), value);
                        }
                      : null,
                  onPanUpdate: canSlideTrack
                      ? (details) {
                          final index = draggingThumb;
                          if (index == null) return;
                          final dx = _localDx(
                            layoutContext,
                            details.globalPosition,
                          );
                          if (dx == null) return;
                          _updateThumb(
                            index,
                            _valueFromDx(
                              dx,
                              effectiveTrackWidth,
                              effectiveThumbRadius,
                            ),
                          );
                        }
                      : null,
                  // The thumb the gesture grabs is decided once, when it
                  // starts: a drag that runs past another thumb keeps moving
                  // the one it picked up rather than swapping mid-gesture.
                  onPanDown: widget.enabled && values.isNotEmpty
                      ? (details) {
                          final dx = _localDx(
                            layoutContext,
                            details.globalPosition,
                          );
                          if (dx == null) return;
                          _setDragging(
                            _nearestThumb(
                              _valueFromDx(
                                dx,
                                effectiveTrackWidth,
                                effectiveThumbRadius,
                              ),
                            ),
                          );
                        }
                      : null,
                  onPanCancel: widget.enabled ? () => _setDragging(null) : null,
                  onPanStart: widget.enabled
                      ? (details) {
                          _dragStarted(details);
                          widget.onChangeStart?.call(widget.values);
                        }
                      : null,
                  onPanEnd: widget.enabled
                      ? (details) {
                          _setDragging(null);
                          widget.onChangeEnd?.call(widget.values);
                        }
                      : null,
                  // `.cn-slider-track` is `overflow-hidden`, so the active
                  // range takes the track's own rounded ends and nothing else:
                  // square where it stops mid-track, rounded where it reaches
                  // an end.
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: theme.radius,
                      child: Stack(
                        children: [
                          // whole track
                          SizedBox(
                            width: effectiveTrackWidth,
                            height: effectiveTrackHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: theme.radius,
                                color: widget.enabled
                                    ? effectiveInactiveTrackColor
                                    : effectiveDisabledInactiveTrackColor,
                              ),
                            ),
                          ),
                          // active track
                          Positioned(
                            left:
                                (rtl ? 1 - highFraction : lowFraction) *
                                effectiveTrackWidth,
                            top: 0,
                            width:
                                (highFraction - lowFraction).clamp(0.0, 1.0) *
                                effectiveTrackWidth,
                            height: effectiveTrackHeight,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: widget.enabled
                                    ? effectiveActiveTrackColor
                                    : effectiveDisabledActiveTrackColor,
                              ),
                            ),
                          ),
                          // division marks
                          if (widget.divisions != null &&
                              widget.divisions! > 0 &&
                              widget.showDivisionMarks)
                            ...List.generate(widget.divisions! + 1, (index) {
                              final position = index / widget.divisions!;
                              return Positioned(
                                left:
                                    position * effectiveTrackWidth -
                                    divisionMarkOffset,
                                top:
                                    (effectiveTrackHeight -
                                        divisionMarkHeight) /
                                    2,
                                child: Container(
                                  width: divisionMarkWidth,
                                  height: divisionMarkHeight,
                                  decoration: BoxDecoration(
                                    color: widget.enabled
                                        ? theme.colorScheme.border
                                        : theme.colorScheme.border.withValues(
                                            alpha: 0.5,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      divisionMarkBorderRadius,
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // thumbs
              for (final index in thumbOrder) buildThumb(index),
            ],
          ),
        );
      },
    );
  }
}

/// The value of a thumb in a bubble above it: the tooltip's surface, with
/// its arrow pointing at the thumb.
///
/// The bubble is painted in the overlay, so nothing around the slider — a
/// card, the edge of a scroll view — cuts it off, and it follows the thumb
/// through a layer link, so a drag moves it without a layout. It is in the
/// overlay only while it shows.
class _SliderValueBubble extends StatefulWidget {
  const _SliderValueBubble({
    required this.enabled,
    required this.visible,
    required this.label,
    required this.child,
  });

  /// Whether there is a bubble at all.
  final bool enabled;
  final bool visible;
  final String label;
  final Widget child;

  @override
  State<_SliderValueBubble> createState() => _SliderValueBubbleState();
}

class _SliderValueBubbleState extends State<_SliderValueBubble> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    if (widget.enabled && widget.visible) _portal.show();
  }

  @override
  void didUpdateWidget(_SliderValueBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && widget.visible && !_portal.isShowing) {
      // The overlay may not be changed while it is being built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.enabled && widget.visible) _portal.show();
      });
    }
  }

  void _left() {
    // Out of the overlay once it has shrunk away.
    if (mounted && !widget.visible && _portal.isShowing) _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final theme = Theme.of(context);
    final tooltip = theme.tooltipTheme;
    final motion = Motion.of(context);
    final color = tooltip.decoration?.color ?? theme.colorScheme.foreground;
    final radius =
        tooltip.decoration?.border?.borderRadius?.resolve(
          Directionality.of(context),
        ) ??
        theme.radius;
    final arrow = tooltip.arrowSize ?? 10;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            // The arrow's tip stops a hair above the thumb's ring.
            offset: const Offset(0, -6),
            child: IgnorePointer(
              child: ExcludeSemantics(
                // It pops out of the thumb and shrinks back into it.
                child: SpringBuilder(
                  value: widget.visible ? 1 : 0,
                  spring: widget.visible ? motion.bouncy : motion.snappy,
                  onEnd: _left,
                  builder: (context, t, child) => Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: motion.reduced ? 1 : .6 + .4 * t,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  ),
                  child: CustomPaint(
                    painter: _BubblePainter(
                      color: color,
                      radius: radius,
                      arrowSize: arrow,
                      arrowRadius: tooltip.arrowRadius ?? 0,
                    ),
                    child: Padding(
                      // Room for the half of the arrow below the bubble.
                      padding: EdgeInsets.only(bottom: arrow / 2),
                      child: Padding(
                        padding:
                            tooltip.padding ??
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          style: theme.textTheme.muted
                              .copyWith(color: theme.colorScheme.background)
                              .merge(tooltip.textStyle)
                              .copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
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
        child: widget.child,
      ),
    );
  }
}

/// A rounded bubble with a square arrow, turned on its corner, under its
/// middle.
class _BubblePainter extends CustomPainter {
  const _BubblePainter({
    required this.color,
    required this.radius,
    required this.arrowSize,
    required this.arrowRadius,
  });

  final Color color;
  final BorderRadius radius;
  final double arrowSize;
  final double arrowRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final body = Offset.zero & Size(size.width, size.height - arrowSize / 2);
    // Two contours wound the same way and filled non-zero: where the arrow
    // overlaps the bubble a translucent colour is painted once, not twice.
    final path = Path()..addRRect(radius.toRRect(body));
    final diamond = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: arrowSize,
            height: arrowSize,
          ),
          Radius.circular(arrowRadius),
        ),
      );
    path.addPath(
      diamond,
      Offset.zero,
      matrix4: (Matrix4.translationValues(
        size.width / 2,
        body.bottom,
        0,
      )..rotateZ(math.pi / 4)).storage,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.arrowSize != arrowSize ||
      oldDelegate.arrowRadius != arrowRadius;
}
