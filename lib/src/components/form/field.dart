import 'package:finesse/src/components/form/form.dart';
import 'package:finesse/src/components/input_decorator.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/widgets.dart';

/// A function that transforms the value of a form field into a different
/// format.
///
/// Takes a value of type [T] and returns a transformed value of any type.
/// Used to convert field values before saving or processing
typedef ToValueTransformer<T> = dynamic Function(T value);

/// A function that transforms a value from a different format into the form
/// field's expected type.
///
/// Takes a value of any type and returns a transformed value of type [T].
/// Used to convert values before populating the form field.
typedef FromValueTransformer<T> = T Function(dynamic value);

/// A customizable form field widget with built-in decoration and state
/// management.
///
/// The [FinesseFormField] extends [FormField] to provide a styled input
/// field with a label, error display, and description, integrated with
/// `Theme` via [InputDecorator]. It supports validation, focus
/// management, and value transformation, designed for use within a
/// [FinesseForm].
@immutable
class FinesseFormField<T> extends FormField<T> {
  /// Creates a form field widget with a custom builder and optional properties.
  FinesseFormField({
    super.key,
    required Widget Function(FormFieldState<T>) builder,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    this.readOnly = false,
    this.id,
    this.focusNode,
    this.label,
    this.error,
    this.description,
    this.onChanged,
    this.toValueTransformer,
    this.fromValueTransformer,
    this.onReset,
    this.decorationBuilder,
    super.forceErrorText,
  }) : super(
         builder: (state) {
           state as FinesseFormFieldState<FinesseFormField<T>, T>;
           final hasError = state.hasError;

           final effectiveError = hasError
               ? error?.call(state.errorText!) ?? Text(state.errorText!)
               : null;

           return InputDecorator(
             label: label,
             error: effectiveError,
             description: description,
             decoration: state.decoration,
             child: builder(state),
           );
         },
         onReset: onReset,
       );

  /// {@template FinesseFormField.id}
  /// An optional identifier used to reference the field within a [FinesseForm].
  /// Enables form data retrieval or field manipulation post-submission.
  /// {@endtemplate}
  final String? id;

  /// {@template FinesseFormField.focusNode}
  /// The focus node for keyboard navigation and focus handling.
  /// If null, an internal focus node is created by the state.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template FinesseFormField.label}
  /// The label widget displayed above the field.
  /// Typically a [Text] widget, providing context for the field’s purpose.
  /// {@endtemplate}
  final Widget? label;

  /// {@template FinesseFormField.error}
  /// A function that returns a custom error widget based on the error text.
  /// Called when validation fails; defaults to a [Text] widget if null.
  /// {@endtemplate}
  final Widget Function(String error)? error;

  /// {@template FinesseFormField.description}
  /// The description widget displayed below the field.
  /// Typically a [Text] widget, offering additional field information.
  /// {@endtemplate}
  final Widget? description;

  /// {@template FinesseFormField.onChanged}
  /// Callback invoked when the field’s value changes.
  /// Provides the new value, complementing form state updates.
  /// {@endtemplate}
  final ValueChanged<T?>? onChanged;

  /// {@template FinesseFormField.toValueTransformer}
  /// A function to transform the field’s value before saving or processing.
  /// Useful for formatting or converting data; defaults to null
  /// (no transformation).
  /// {@endtemplate}
  final ToValueTransformer<T?>? toValueTransformer;

  /// {@template FinesseFormField.fromValueTransformer}
  /// A function to transform a value into the field’s expected type.
  /// Useful for converting data before populating the field; defaults to null
  /// (no transformation).
  /// {@endtemplate}
  final FromValueTransformer<T?>? fromValueTransformer;

  /// {@template FinesseFormField.onReset}
  /// Callback invoked when the field is reset to its initial value.
  /// Allows additional reset logic; defaults to null.
  /// {@endtemplate}
  @override
  // ignore: overridden_fields
  final VoidCallback? onReset;

  /// {@template FinesseFormField.decorationBuilder}
  /// A function that builds a custom [FinesseDecoration] for the field.
  /// Overrides the default decoration; merged with error state if provided.
  /// {@endtemplate}
  final FinesseDecoration? Function(BuildContext context)? decorationBuilder;

  /// {@template FinesseFormField.readOnly}
  /// Whether the field is read-only.
  /// Defaults to false; if true, prevents editing but allows focus.
  /// {@endtemplate}
  final bool readOnly;

  @override
  FinesseFormFieldState<FinesseFormField<T>, T> createState() =>
      FinesseFormFieldState<FinesseFormField<T>, T>();
}

/// The state class for [FinesseFormField], managing field state and form
/// integration.
///
/// Extends [FormFieldState] to handle value changes, focus, and form
/// registration.
/// Provides methods for focusing, ensuring visibility, and updating the parent
/// form.
class FinesseFormFieldState<F extends FinesseFormField<T>, T>
    extends FormFieldState<T> {
  final String _internalId = UniqueKey().toString();
  FocusNode? _focusNode;
  FinesseFormState? _parentForm;

  /// The effective focus node, either provided or internally managed.
  ///
  /// It is attached only when the field's builder hands it to a widget; see
  /// [focus] for what happens when none does.
  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  /// The decoration applied to the field, reflecting error state.
  FinesseDecoration get decoration =>
      (widget.decorationBuilder?.call(context) ?? const FinesseDecoration())
          .copyWith(hasError: hasError);

  String? _forceErrorText;

  /// The error shown whatever the validator returns: [FormField.forceErrorText]
  /// when set, otherwise the text passed to [setError].
  String? get forceErrorText => widget.forceErrorText ?? _forceErrorText;

  @override
  String? get errorText =>
      _skipsValidation ? null : forceErrorText ?? super.errorText;

  @override
  bool get hasError =>
      !_skipsValidation && (forceErrorText != null || super.hasError);

  /// Sets an internal error message that overrides validation errors.
  void setError(String? error) {
    setState(() {
      _forceErrorText = error;
    });
  }

  @override
  F get widget => super.widget as F;

  /// The initial value of the field, sourced from widget or parent form.
  T? get initialValue {
    if (widget.initialValue != null) return widget.initialValue;

    // Use getFieldValue to support nested initial values with dot notation
    if (widget.id == null || _parentForm == null) return null;

    final value = _parentForm!.getFieldValue(widget.id!);
    if (widget.fromValueTransformer != null) {
      return widget.fromValueTransformer!(value);
    }
    return value as T?;
  }

  /// Whether the field is enabled, factoring in parent form state.
  bool get enabled => widget.enabled && (_parentForm?.enabled ?? true);

  /// Whether validation is skipped: the field is disabled and its form was
  /// built with [FinesseForm.skipDisabled].
  bool get _skipsValidation =>
      !enabled && (_parentForm?.widget.skipDisabled ?? false);

  @override
  bool validate() => _skipsValidation || super.validate();

  @override
  bool get isValid => _skipsValidation || super.isValid;

  /// The effective identifier for the field, using the provided ID or an
  /// auto-generated one.
  String get effectiveId => widget.id ?? _internalId;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _focusNode = FocusNode(canRequestFocus: !widget.readOnly);
    }
    // Register this field when there is a parent FinesseForm
    _parentForm = FinesseForm.maybeOf(context);
    _parentForm?.registerField(effectiveId, this);
  }

  @override
  void didUpdateWidget(covariant FinesseFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id) {
      if (oldWidget.id != null) {
        _parentForm?.unregisterField(oldWidget.id!, this);
      } else {
        _parentForm?.unregisterField(_internalId, this);
      }
      if (widget.id != null) {
        _parentForm?.registerField(widget.id!, this);
      } else {
        _parentForm?.registerField(_internalId, this);
      }
    }

    if (oldWidget.focusNode != null && widget.focusNode == null) {
      _focusNode ??= FocusNode(canRequestFocus: !widget.readOnly);
    }

    if (widget.readOnly != oldWidget.readOnly) {
      _focusNode?.canRequestFocus = !widget.readOnly;
    }
  }

  @override
  void didChange(T? value) {
    _parentForm?.setFieldValue<T>(effectiveId, value, notifyField: false);
    super.didChange(value);
    widget.onChanged?.call(value);
  }

  @override
  void reset() {
    super.reset();
    didChange(initialValue);
    widget.onReset?.call();
  }

  @override
  void dispose() {
    _parentForm?.unregisterField(effectiveId, this);
    _focusNode?.dispose();
    super.dispose();
  }

  /// Moves the keyboard focus into the field.
  ///
  /// A field that hands [focusNode] to a widget is focused through it. One
  /// made of several controls that attaches the node to none of them (an OTP
  /// field, a radio group, a time picker, or a custom [FinesseFormField]
  /// whose builder ignores it) gets the focus on its first focusable
  /// control instead; with no such control the focus stays where it is.
  void focus() {
    final node = focusNode;
    // Only a node some widget owns may be asked: requesting the focus for an
    // unattached one reparents it under the route's scope, where it becomes
    // a primary focus that no key event or traversal can reach, and that
    // outlives its own disposal.
    if (node.context != null) {
      node.requestFocus();
    } else {
      _firstFocusableControl()?.requestFocus();
    }
  }

  /// The first control under this field that can take the focus, in the
  /// order the field builds its controls.
  ///
  /// The order is the element tree's, not the focus tree's: a [FocusNode]'s
  /// children are in the order they were attached, which a rebuild can
  /// shuffle.
  FocusNode? _firstFocusableControl() {
    final candidates = <BuildContext, FocusNode>{
      for (final node in FocusScope.of(context).traversalDescendants)
        ?node.context: node,
    };
    if (candidates.isEmpty) return null;
    FocusNode? first;
    void visit(Element element) {
      if (first != null) return;
      first = candidates[element];
      if (first == null) element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return first;
  }

  /// Ensures the field is visible by scrolling if necessary.
  void ensureVisible() {
    Scrollable.ensureVisible(context);
  }

  @override
  void setValue(T? value, {bool populateForm = true}) {
    super.setValue(value);
    if (populateForm) {
      _informFormForFieldChange();
    }
  }

  void _informFormForFieldChange() {
    _parentForm?.setFieldValue<T>(
      effectiveId,
      value,
      notifyField: false,
    );
  }

  /// Registers the field’s value transformer with the provided map.
  void registerToValueTransformer(Map<String, Function> map) {
    final fun = widget.toValueTransformer;
    if (fun != null) map[effectiveId] = fun;
  }

  /// Registers the field’s from value transformer with the provided map.
  void registerFromValueTransformer(Map<String, Function> map) {
    final fun = widget.fromValueTransformer;
    if (fun != null) map[effectiveId] = fun;
  }
}
