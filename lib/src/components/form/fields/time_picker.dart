import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/time_picker.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';

/// A [TimePicker] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class TimePickerFormField extends FinesseFormField<TimeOfDay> {
  /// Creates a 24-hour time picker form field.
  TimePickerFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.validator,
    super.focusNode,

    /// {@macro TimePicker.onChanged}
    super.onChanged,

    /// {@macro TimePicker.initialValue}
    super.initialValue,

    /// {@macro TimePicker.controller}
    this.controller,

    /// {@macro TimePicker.axis}
    Axis? axis,

    /// {@macro TimePicker.spacing}
    double? spacing,

    /// {@macro TimePicker.runSpacing}
    double? runSpacing,

    /// {@macro TimePicker.jumpToNextFieldWhenFilled}
    bool? jumpToNextFieldWhenFilled,

    /// {@macro TimePicker.hourLabel}
    Widget? hourLabel,

    /// {@macro TimePicker.minuteLabel}
    Widget? minuteLabel,

    /// {@macro TimePicker.secondLabel}
    Widget? secondLabel,

    /// {@macro TimePicker.hourPlaceholder}
    Widget? hourPlaceholder,

    /// {@macro TimePicker.minutePlaceholder}
    Widget? minutePlaceholder,

    /// {@macro TimePicker.secondPlaceholder}
    Widget? secondPlaceholder,

    /// {@macro TimePicker.leading}
    Widget? leading,

    /// {@macro TimePicker.trailing}
    Widget? trailing,

    /// {@macro TimePicker.alignment}
    WrapAlignment? alignment,

    /// {@macro TimePicker.runAlignment}
    WrapAlignment? runAlignment,

    /// {@macro TimePicker.crossAxisAlignment}
    WrapCrossAlignment? crossAxisAlignment,

    /// {@macro TimePicker.maxHour}
    int maxHour = 23,

    /// {@macro TimePicker.maxMinute}
    int maxMinute = 59,

    /// {@macro TimePicker.maxSecond}
    int maxSecond = 59,

    /// {@macro TimePicker.minHour}
    int minHour = 0,

    /// {@macro TimePicker.minMinute}
    int minMinute = 0,

    /// {@macro TimePicker.minSecond}
    int minSecond = 0,

    /// {@macro TimePicker.gap}
    double? gap,

    /// {@macro TimePicker.style}
    TextStyle? style,

    /// {@macro TimePicker.placeholderStyle}
    TextStyle? placeholderStyle,

    /// {@macro TimePicker.labelStyle}
    TextStyle? labelStyle,

    /// {@macro TimePicker.fieldWidth}
    double? fieldWidth,

    /// {@macro TimePicker.fieldPadding}
    EdgeInsetsGeometry? fieldPadding,

    /// {@macro TimePicker.fieldDecoration}
    FinesseDecoration? fieldDecoration,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,
    this.showHours,
    this.showMinutes,
    this.showSeconds,
  }) : super(
         builder: (state) {
           state as TimePickerFormFieldState;
           return TimePicker(
             controller: state.controller,
             onChanged: state.didChange,
             enabled: state.enabled,
             initialValue: state.initialValue,
             axis: axis,
             spacing: spacing,
             runSpacing: runSpacing,
             jumpToNextFieldWhenFilled: jumpToNextFieldWhenFilled,
             hourLabel: hourLabel,
             minuteLabel: minuteLabel,
             secondLabel: secondLabel,
             hourPlaceholder: hourPlaceholder,
             minutePlaceholder: minutePlaceholder,
             secondPlaceholder: secondPlaceholder,
             leading: leading,
             trailing: trailing,
             alignment: alignment,
             runAlignment: runAlignment,
             crossAxisAlignment: crossAxisAlignment,
             maxHour: maxHour,
             maxMinute: maxMinute,
             maxSecond: maxSecond,
             minHour: minHour,
             minMinute: minMinute,
             minSecond: minSecond,
             gap: gap,
             style: style,
             placeholderStyle: placeholderStyle,
             labelStyle: labelStyle,
             fieldWidth: fieldWidth,
             fieldPadding: fieldPadding,
             fieldDecoration: fieldDecoration,
             keyboardToolbarBuilder: keyboardToolbarBuilder,
             showHours: showHours,
             showMinutes: showMinutes,
             showSeconds: showSeconds,
           );
         },
       );

  /// Creates a 12-hour time picker form field with an AM/PM selector.
  TimePickerFormField.period({
    super.id,
    super.key,
    super.onSaved,
    super.label,
    super.error,
    super.description,
    super.forceErrorText,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.validator,

    /// {@macro TimePicker.onChanged}
    super.onChanged,

    /// {@macro TimePicker.initialValue}
    super.initialValue,

    /// {@macro TimePicker.controller}
    this.controller,

    /// {@macro TimePicker.axis}
    Axis? axis,

    /// {@macro TimePicker.spacing}
    double? spacing,

    /// {@macro TimePicker.runSpacing}
    double? runSpacing,

    /// {@macro TimePicker.jumpToNextFieldWhenFilled}
    bool? jumpToNextFieldWhenFilled,

    /// {@macro TimePicker.hourLabel}
    Widget? hourLabel,

    /// {@macro TimePicker.minuteLabel}
    Widget? minuteLabel,

    /// {@macro TimePicker.secondLabel}
    Widget? secondLabel,

    /// {@macro TimePicker.hourPlaceholder}
    Widget? hourPlaceholder,

    /// {@macro TimePicker.minutePlaceholder}
    Widget? minutePlaceholder,

    /// {@macro TimePicker.secondPlaceholder}
    Widget? secondPlaceholder,

    /// {@macro TimePicker.leading}
    Widget? leading,

    /// {@macro TimePicker.trailing}
    Widget? trailing,

    /// {@macro TimePicker.alignment}
    WrapAlignment? alignment,

    /// {@macro TimePicker.runAlignment}
    WrapAlignment? runAlignment,

    /// {@macro TimePicker.crossAxisAlignment}
    WrapCrossAlignment? crossAxisAlignment,

    /// {@macro TimePicker.maxHour}
    int maxHour = 23,

    /// {@macro TimePicker.maxMinute}
    int maxMinute = 59,

    /// {@macro TimePicker.maxSecond}
    int maxSecond = 59,

    /// {@macro TimePicker.minHour}
    int minHour = 0,

    /// {@macro TimePicker.minMinute}
    int minMinute = 0,

    /// {@macro TimePicker.minSecond}
    int minSecond = 0,

    /// {@macro TimePicker.initialDayPeriod}
    DayPeriod? initialDayPeriod,

    /// {@macro TimePicker.periodLabel}
    Widget? periodLabel,

    /// {@macro TimePicker.periodPlaceholder}
    Widget? periodPlaceholder,

    /// {@macro TimePicker.periodHeight}
    double? periodHeight,

    /// {@macro TimePicker.periodMinWidth}
    double? periodMinWidth,

    /// {@macro TimePicker.gap}
    double? gap,

    /// {@macro TimePicker.style}
    TextStyle? style,

    /// {@macro TimePicker.placeholderStyle}
    TextStyle? placeholderStyle,

    /// {@macro TimePicker.labelStyle}
    TextStyle? labelStyle,

    /// {@macro TimePicker.fieldWidth}
    double? fieldWidth,

    /// {@macro TimePicker.fieldPadding}
    EdgeInsetsGeometry? fieldPadding,

    /// {@macro TimePicker.fieldDecoration}
    FinesseDecoration? fieldDecoration,

    /// {@macro TimePicker.periodDecoration}
    FinesseDecoration? periodDecoration,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,
    this.showHours,
    this.showMinutes,
    this.showSeconds,
  }) : super(
         builder: (state) {
           state as TimePickerFormFieldState;
           return TimePicker.period(
             controller: state.controller,
             onChanged: state.didChange,
             enabled: state.enabled,
             initialValue: state.initialValue,
             axis: axis,
             spacing: spacing,
             runSpacing: runSpacing,
             jumpToNextFieldWhenFilled: jumpToNextFieldWhenFilled,
             hourLabel: hourLabel,
             minuteLabel: minuteLabel,
             secondLabel: secondLabel,
             hourPlaceholder: hourPlaceholder,
             minutePlaceholder: minutePlaceholder,
             secondPlaceholder: secondPlaceholder,
             leading: leading,
             trailing: trailing,
             alignment: alignment,
             runAlignment: runAlignment,
             crossAxisAlignment: crossAxisAlignment,
             maxHour: maxHour,
             maxMinute: maxMinute,
             maxSecond: maxSecond,
             minHour: minHour,
             minMinute: minMinute,
             minSecond: minSecond,
             initialDayPeriod: initialDayPeriod,
             periodLabel: periodLabel,
             periodPlaceholder: periodPlaceholder,
             periodHeight: periodHeight,
             periodMinWidth: periodMinWidth,
             gap: gap,
             style: style,
             placeholderStyle: placeholderStyle,
             labelStyle: labelStyle,
             fieldWidth: fieldWidth,
             fieldPadding: fieldPadding,
             fieldDecoration: fieldDecoration,
             periodDecoration: periodDecoration,
             keyboardToolbarBuilder: keyboardToolbarBuilder,
             showHours: showHours,
             showMinutes: showMinutes,
             showSeconds: showSeconds,
           );
         },
       );

  /// Creates a time picker form field with an explicit [variant].
  TimePickerFormField.raw({
    required TimePickerVariant variant,
    super.id,
    super.key,
    super.onSaved,
    super.label,
    super.error,
    super.description,
    super.forceErrorText,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    super.validator,

    /// {@macro TimePicker.onChanged}
    super.onChanged,

    /// {@macro TimePicker.initialValue}
    super.initialValue,

    /// {@macro TimePicker.controller}
    this.controller,

    /// {@macro TimePicker.axis}
    Axis? axis,

    /// {@macro TimePicker.spacing}
    double? spacing,

    /// {@macro TimePicker.runSpacing}
    double? runSpacing,

    /// {@macro TimePicker.jumpToNextFieldWhenFilled}
    bool? jumpToNextFieldWhenFilled,

    /// {@macro TimePicker.hourLabel}
    Widget? hourLabel,

    /// {@macro TimePicker.minuteLabel}
    Widget? minuteLabel,

    /// {@macro TimePicker.secondLabel}
    Widget? secondLabel,

    /// {@macro TimePicker.hourPlaceholder}
    Widget? hourPlaceholder,

    /// {@macro TimePicker.minutePlaceholder}
    Widget? minutePlaceholder,

    /// {@macro TimePicker.secondPlaceholder}
    Widget? secondPlaceholder,

    /// {@macro TimePicker.leading}
    Widget? leading,

    /// {@macro TimePicker.trailing}
    Widget? trailing,

    /// {@macro TimePicker.alignment}
    WrapAlignment? alignment,

    /// {@macro TimePicker.runAlignment}
    WrapAlignment? runAlignment,

    /// {@macro TimePicker.crossAxisAlignment}
    WrapCrossAlignment? crossAxisAlignment,

    /// {@macro TimePicker.maxHour}
    int maxHour = 23,

    /// {@macro TimePicker.maxMinute}
    int maxMinute = 59,

    /// {@macro TimePicker.maxSecond}
    int maxSecond = 59,

    /// {@macro TimePicker.minHour}
    int minHour = 0,

    /// {@macro TimePicker.minMinute}
    int minMinute = 0,

    /// {@macro TimePicker.minSecond}
    int minSecond = 0,

    /// {@macro TimePicker.initialDayPeriod}
    DayPeriod? initialDayPeriod,

    /// {@macro TimePicker.periodLabel}
    Widget? periodLabel,

    /// {@macro TimePicker.periodPlaceholder}
    Widget? periodPlaceholder,

    /// {@macro TimePicker.periodHeight}
    double? periodHeight,

    /// {@macro TimePicker.periodMinWidth}
    double? periodMinWidth,

    /// {@macro TimePicker.gap}
    double? gap,

    /// {@macro TimePicker.style}
    TextStyle? style,

    /// {@macro TimePicker.placeholderStyle}
    TextStyle? placeholderStyle,

    /// {@macro TimePicker.labelStyle}
    TextStyle? labelStyle,

    /// {@macro TimePicker.fieldWidth}
    double? fieldWidth,

    /// {@macro TimePicker.fieldPadding}
    EdgeInsetsGeometry? fieldPadding,

    /// {@macro TimePicker.fieldDecoration}
    FinesseDecoration? fieldDecoration,

    /// {@macro TimePicker.periodDecoration}
    FinesseDecoration? periodDecoration,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,
    this.showHours,
    this.showMinutes,
    this.showSeconds,
  }) : super(
         builder: (state) {
           state as TimePickerFormFieldState;
           return TimePicker.raw(
             variant: variant,
             controller: state.controller,
             onChanged: state.didChange,
             enabled: state.enabled,
             initialValue: state.initialValue,
             axis: axis,
             spacing: spacing,
             runSpacing: runSpacing,
             jumpToNextFieldWhenFilled: jumpToNextFieldWhenFilled,
             hourLabel: hourLabel,
             minuteLabel: minuteLabel,
             secondLabel: secondLabel,
             hourPlaceholder: hourPlaceholder,
             minutePlaceholder: minutePlaceholder,
             secondPlaceholder: secondPlaceholder,
             leading: leading,
             trailing: trailing,
             alignment: alignment,
             runAlignment: runAlignment,
             crossAxisAlignment: crossAxisAlignment,
             maxHour: maxHour,
             maxMinute: maxMinute,
             maxSecond: maxSecond,
             minHour: minHour,
             minMinute: minMinute,
             minSecond: minSecond,
             initialDayPeriod: initialDayPeriod,
             periodLabel: periodLabel,
             periodPlaceholder: periodPlaceholder,
             periodHeight: periodHeight,
             periodMinWidth: periodMinWidth,
             gap: gap,
             style: style,
             placeholderStyle: placeholderStyle,
             labelStyle: labelStyle,
             fieldWidth: fieldWidth,
             fieldPadding: fieldPadding,
             fieldDecoration: fieldDecoration,
             periodDecoration: periodDecoration,
             keyboardToolbarBuilder: keyboardToolbarBuilder,
             showHours: showHours,
             showMinutes: showMinutes,
             showSeconds: showSeconds,
           );
         },
       );

  @override
  FinesseFormFieldState<TimePickerFormField, TimeOfDay> createState() =>
      TimePickerFormFieldState();

  /// {@macro TimePicker.controller}
  final TimePickerController? controller;

  /// {@macro TimePicker.showHours}
  final bool? showHours;

  /// {@macro TimePicker.showMinutes}
  final bool? showMinutes;

  /// {@macro TimePicker.showSeconds}
  final bool? showSeconds;
}

/// The state of a [TimePickerFormField].
class TimePickerFormFieldState
    extends FinesseFormFieldState<TimePickerFormField, TimeOfDay> {
  TimePickerController? _controller;

  /// The controller in use: [TimePickerFormField.controller] when given,
  /// otherwise an internal one created from the initial value.
  TimePickerController get controller => widget.controller ?? _controller!;

  /// Whether the seconds field shows. Defaults to true.
  bool get showSeconds => widget.showSeconds ?? true;

  /// Whether the hours field shows. Defaults to true.
  bool get showHours => widget.showHours ?? true;

  /// Whether the minutes field shows. Defaults to true.
  bool get showMinutes => widget.showMinutes ?? true;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TimePickerController.fromTimeOfDay(widget.initialValue);
    }
    controller.setHour(showHours ? controller.hour : 0);
    controller.setMinute(showMinutes ? controller.minute : 0);
    controller.setSecond(showSeconds ? controller.second : 0);
  }

  @override
  void reset() {
    super.reset();
    controller.value = initialValue;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(
    covariant TimePickerFormField oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showHours != widget.showHours) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setHour(showHours ? null : 0);
      });
    }
    if (oldWidget.showMinutes != widget.showMinutes) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setMinute(showMinutes ? null : 0);
      });
    }
    if (oldWidget.showSeconds != widget.showSeconds) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setSecond(showSeconds ? null : 0);
      });
    }
  }
}
