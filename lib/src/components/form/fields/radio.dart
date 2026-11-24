import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/radio.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// A [FinesseRadioGroup] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class RadioGroupFormField<T> extends FinesseFormField<T> {
  /// Creates a radio group form field.
  RadioGroupFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.label,
    super.error,
    super.description,
    super.onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    T? initialValue,
    super.validator,
    required Iterable<Widget> items,

    /// {@macro FinesseRadioGroup.axis}
    Axis? axis,

    /// {@macro FinesseRadioGroup.spacing}
    double? spacing,

    /// {@macro FinesseRadioGroup.runSpacing}
    double? runSpacing,

    /// {@macro FinesseRadioGroup.alignment}
    WrapAlignment? alignment,

    /// {@macro FinesseRadioGroup.runAlignment}
    WrapAlignment? runAlignment,

    /// {@macro FinesseRadioGroup.crossAxisAlignment}
    WrapCrossAlignment? crossAxisAlignment,

    /// {@macro FinesseRadioGroup.controller}
    this.controller,
  }) : super(
         decorationBuilder: (context) =>
             Theme.of(context).radioTheme.decoration ??
             const FinesseDecoration(),
         initialValue: controller?.value ?? initialValue,
         builder: (state) {
           state as RadioGroupFormFieldState<T>;
           return FinesseRadioGroup(
             items: items,
             onChanged: state.didChange,
             enabled: state.enabled,
             initialValue: initialValue,
             axis: axis,
             spacing: spacing,
             runSpacing: runSpacing,
             alignment: alignment,
             runAlignment: runAlignment,
             crossAxisAlignment: crossAxisAlignment,
             controller: state.controller,
           );
         },
       );

  /// {@macro FinesseRadioGroup.controller}
  final RadioController<T>? controller;

  @override
  FinesseFormFieldState<RadioGroupFormField<T>, T> createState() =>
      RadioGroupFormFieldState<T>();
}

/// The state of a [RadioGroupFormField].
class RadioGroupFormFieldState<T>
    extends FinesseFormFieldState<RadioGroupFormField<T>, T> {
  RadioController<T>? _controller;

  /// The controller in use: [RadioGroupFormField.controller] when given,
  /// otherwise an internal one.
  RadioController<T> get controller => widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = RadioController<T>(
        value: initialValue,
        enabled: enabled,
      );
    }
    controller.addListener(onControllerChanged);
  }

  @override
  void didChange(T? value) {
    super.didChange(value);
    if (controller.value != value) {
      controller.value = value;
    }
  }

  @override
  void didUpdateWidget(covariant RadioGroupFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) return;
    // Move the listener with the controller. It used to stay on the old one,
    // and dispose() then removed it from the wrong controller.
    (oldWidget.controller ?? _controller)?.removeListener(onControllerChanged);
    if (widget.controller != null) {
      _controller?.dispose();
      _controller = null;
    } else {
      _controller = RadioController<T>(value: value, enabled: enabled);
    }
    controller.addListener(onControllerChanged);
  }

  @override
  void reset() {
    super.reset();
    controller.value = initialValue;
  }

  @override
  void dispose() {
    controller.removeListener(onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  /// Copies the controller's value into the field's value and calls
  /// [FinesseFormField.onChanged].
  void onControllerChanged() {
    if (controller.value != value) {
      didChange(controller.value);
      widget.onChanged?.call(controller.value);
    }
  }
}
