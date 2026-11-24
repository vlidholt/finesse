import 'dart:ui' as ui;

import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/text_field.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/clipboard/clipboard_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A [TextField] that takes part in a `FinesseForm`, with a label, a description
/// and validation.
class TextFormField extends FinesseFormField<String> {
  /// Creates a text input form field.
  TextFormField({
    super.id,
    super.key,
    super.onSaved,
    super.forceErrorText,
    String? Function(String)? validator,
    String? initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    this.controller,
    super.label,
    super.error,
    super.description,
    void Function(String)? onChanged,
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.focusNode,

    /// {@macro TextField.decoration}
    FinesseDecoration? decoration,

    /// {@macro TextField.placeholder}
    Widget? placeholder,

    /// {@macro TextField.magnifierConfiguration}
    TextMagnifierConfiguration magnifierConfiguration =
        TextMagnifierConfiguration.disabled,

    /// {@macro TextField.keyboardType}
    TextInputType? keyboardType,

    /// {@macro TextField.textInputAction}
    TextInputAction? textInputAction,

    /// {@macro TextField.textCapitalization}
    TextCapitalization textCapitalization = TextCapitalization.none,

    /// {@macro TextField.style}
    TextStyle? style,

    /// {@macro TextField.strutStyle}
    StrutStyle? strutStyle,

    /// {@macro TextField.textAlign}
    TextAlign textAlign = TextAlign.start,

    /// {@macro TextField.textDirection}
    TextDirection? textDirection,

    /// {@macro TextField.autofocus}
    bool autofocus = false,

    /// {@macro TextField.obscuringCharacter}
    String obscuringCharacter = '•',

    /// {@macro TextField.obscureText}
    bool obscureText = false,

    /// {@macro TextField.autocorrect}
    bool autocorrect = true,

    /// {@macro TextField.smartDashesType}
    SmartDashesType? smartDashesType,

    /// {@macro TextField.smartQuotesType}
    SmartQuotesType? smartQuotesType,

    /// {@macro TextField.enableSuggestions}
    bool enableSuggestions = true,

    /// {@macro TextField.maxLines}
    int? maxLines = 1,

    /// {@macro TextField.minLines}
    int? minLines,

    /// {@macro TextField.expands}
    bool expands = false,

    /// {@macro FinesseFormField.readOnly}
    super.readOnly,

    /// {@macro TextField.showCursor}
    bool? showCursor,

    /// {@macro TextField.maxLength}
    int? maxLength,

    /// {@macro TextField.maxLengthEnforcement}
    MaxLengthEnforcement? maxLengthEnforcement,

    /// {@macro TextField.onEditingComplete}
    VoidCallback? onEditingComplete,

    /// {@macro TextField.onSubmitted}
    ValueChanged<String>? onSubmitted,

    /// {@macro TextField.onAppPrivateCommand}
    AppPrivateCommandCallback? onAppPrivateCommand,

    /// {@macro TextField.inputFormatters}
    List<TextInputFormatter>? inputFormatters,

    /// {@macro TextField.cursorWidth}
    double? cursorWidth,

    /// {@macro TextField.cursorHeight}
    double? cursorHeight,

    /// {@macro TextField.cursorRadius}
    Radius? cursorRadius,

    /// {@macro TextField.cursorOpacityAnimates}
    bool? cursorOpacityAnimates,

    /// {@macro TextField.cursorColor}
    Color? cursorColor,

    /// {@macro TextField.selectionHeightStyle}
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,

    /// {@macro TextField.selectionWidthStyle}
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,

    /// {@macro TextField.keyboardAppearance}
    Brightness? keyboardAppearance,

    /// {@macro TextField.scrollPadding}
    EdgeInsets scrollPadding = const EdgeInsets.all(20),

    /// {@macro TextField.enableInteractiveSelection}
    bool? enableInteractiveSelection,

    /// {@macro TextField.selectionControls}
    TextSelectionControls? selectionControls,

    /// {@macro TextField.dragStartBehavior}
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,

    /// {@macro TextField.onPressed}
    GestureTapCallback? onPressed,

    /// {@macro TextField.onPressedAlwaysCalled}
    bool onPressedAlwaysCalled = false,

    /// {@macro TextField.onPressedOutside}
    TapRegionCallback? onPressedOutside,

    /// {@macro TextField.mouseCursor}
    MouseCursor? mouseCursor,

    /// {@macro TextField.scrollPhysics}
    ScrollPhysics? scrollPhysics,

    /// {@macro TextField.scrollController}
    ScrollController? scrollController,

    /// {@macro TextField.autofillHints}
    Iterable<String>? autofillHints,

    /// {@macro TextField.clipBehavior}
    Clip clipBehavior = Clip.hardEdge,

    /// {@macro TextField.scribbleEnabled}
    bool scribbleEnabled = true,

    /// {@macro TextField.enableIMEPersonalizedLearning}
    bool enableIMEPersonalizedLearning = true,

    /// {@macro TextField.contentInsertionConfiguration}
    ContentInsertionConfiguration? contentInsertionConfiguration,

    /// {@macro TextField.contextMenuBuilder}
    EditableTextContextMenuBuilder? contextMenuBuilder,

    /// {@macro TextField.undoController}
    UndoHistoryController? undoController,

    /// {@macro TextField.spellCheckConfiguration}
    SpellCheckConfiguration? spellCheckConfiguration,

    /// {@macro TextField.selectionColor}
    Color? selectionColor,

    /// {@macro TextField.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro TextField.leading}
    Widget? leading,

    /// {@macro TextField.trailing}
    Widget? trailing,

    /// {@macro TextField.mainAxisAlignment}
    MainAxisAlignment? mainAxisAlignment,

    /// {@macro TextField.crossAxisAlignment}
    CrossAxisAlignment? crossAxisAlignment,

    /// {@macro TextField.placeholderStyle}
    TextStyle? placeholderStyle,

    /// {@macro TextField.alignment}
    AlignmentGeometry? alignment,

    /// {@macro TextField.placeholderAlignment}
    AlignmentGeometry? placeholderAlignment,

    /// {@macro TextField.inputPadding}
    EdgeInsetsGeometry? inputPadding,

    /// {@macro TextField.gap}
    double? gap,

    /// {@macro TextField.constraints}
    BoxConstraints? constraints,

    /// {@macro TextField.groupId}
    Object? groupId,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,

    /// {@macro TextField.top}
    Widget? top,

    /// {@macro TextField.bottom}
    Widget? bottom,

    /// {@macro TextField.onLineCountChanged}
    ValueChanged<int>? onLineCountChanged,

    /// {@macro TextField.editableTextSize}
    Size? editableTextSize,

    /// {@macro TextField.useBrowserContextMenu}
    bool? useBrowserContextMenu,

    /// {@macro TextField.onPasteFiles}
    ValueChanged<List<ClipboardItem>>? onPasteFiles,

    /// {@macro TextField.onPasteFilesError}
    ValueChanged<Object>? onPasteFilesError,
  }) : super(
         initialValue: controller != null ? controller.text : initialValue,
         validator: validator == null ? null : (v) => validator(v ?? ''),
         onChanged: onChanged == null ? null : (v) => onChanged(v ?? ''),
         decorationBuilder: (context) =>
             (Theme.of(context).textFieldTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as TextFormFieldState;
           return TextField(
             key: state.inputKey,
             controller: state.controller,
             restorationId: restorationId,
             enabled: state.enabled,
             focusNode: state.focusNode,
             decoration: state.decoration,
             style: style,
             cursorColor: cursorColor,
             selectionColor: selectionColor,
             keyboardType: keyboardType,
             textInputAction: textInputAction,
             textCapitalization: textCapitalization,
             autofocus: autofocus,
             obscureText: obscureText,
             autocorrect: autocorrect,
             magnifierConfiguration: magnifierConfiguration,
             smartDashesType: smartDashesType,
             smartQuotesType: smartQuotesType,
             enableSuggestions: enableSuggestions,
             maxLines: maxLines,
             minLines: minLines,
             expands: expands,
             onEditingComplete: onEditingComplete,
             onSubmitted: onSubmitted,
             onAppPrivateCommand: onAppPrivateCommand,
             inputFormatters: inputFormatters,
             cursorWidth: cursorWidth,
             cursorHeight: cursorHeight,
             cursorRadius: cursorRadius,
             selectionHeightStyle: selectionHeightStyle,
             selectionWidthStyle: selectionWidthStyle,
             scrollPadding: scrollPadding,
             dragStartBehavior: dragStartBehavior,
             scrollController: scrollController,
             scrollPhysics: scrollPhysics,
             autofillHints: autofillHints,
             clipBehavior: clipBehavior,
             scribbleEnabled: scribbleEnabled,
             enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
             contentInsertionConfiguration: contentInsertionConfiguration,
             contextMenuBuilder: contextMenuBuilder,
             selectionControls: selectionControls,
             mouseCursor: mouseCursor,
             enableInteractiveSelection: enableInteractiveSelection,
             undoController: undoController,
             spellCheckConfiguration: spellCheckConfiguration,
             placeholder: placeholder,
             onPressed: onPressed,
             onPressedAlwaysCalled: onPressedAlwaysCalled,
             onPressedOutside: onPressedOutside,
             keyboardAppearance: keyboardAppearance,
             cursorOpacityAnimates: cursorOpacityAnimates,
             readOnly: readOnly,
             strutStyle: strutStyle,
             textAlign: textAlign,
             textDirection: textDirection,
             obscuringCharacter: obscuringCharacter,
             showCursor: showCursor,
             maxLength: maxLength,
             maxLengthEnforcement: maxLengthEnforcement,
             padding: padding,
             leading: leading,
             trailing: trailing,
             mainAxisAlignment: mainAxisAlignment,
             crossAxisAlignment: crossAxisAlignment,
             alignment: alignment,
             placeholderStyle: placeholderStyle,
             placeholderAlignment: placeholderAlignment,
             inputPadding: inputPadding,
             gap: gap,
             constraints: constraints,
             groupId: groupId,
             keyboardToolbarBuilder: keyboardToolbarBuilder,
             top: top,
             bottom: bottom,
             onLineCountChanged: onLineCountChanged,
             editableTextSize: editableTextSize,
             useBrowserContextMenu: useBrowserContextMenu,
             onPasteFiles: onPasteFiles,
             onPasteFilesError: onPasteFilesError,
           );
         },
       );

  /// Controls the text. When null, the field creates its own controller.
  final TextEditingController? controller;

  @override
  FinesseFormFieldState<TextFormField, String> createState() =>
      TextFormFieldState();
}

/// The state of a [TextFormField].
class TextFormFieldState extends FinesseFormFieldState<TextFormField, String> {
  TextEditingController? _controller;

  /// The controller in use: [TextFormField.controller] when given,
  /// otherwise an internal one.
  TextEditingController get controller => widget.controller ?? _controller!;

  /// The key of the inner [TextField], for reaching its [TextFieldState].
  final GlobalKey<TextFieldState> inputKey = GlobalKey<TextFieldState>();

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: value);
    }
    controller.addListener(onControllerChanged);
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (controller.text != value) {
      controller.text = value ?? '';
    }
  }

  @override
  void didUpdateWidget(covariant TextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) return;
    // Move the listener with the controller. It used to stay on the old one,
    // and dispose() then removed it from the wrong controller.
    (oldWidget.controller ?? _controller)?.removeListener(onControllerChanged);
    if (widget.controller != null) {
      _controller?.dispose();
      _controller = null;
    } else {
      _controller = TextEditingController(text: value);
    }
    controller.addListener(onControllerChanged);
  }

  @override
  void reset() {
    super.reset();
    controller.text = initialValue ?? '';
    widget.onChanged?.call(controller.text);
  }

  @override
  void dispose() {
    controller.removeListener(onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  /// Copies the controller's text into the field's value.
  void onControllerChanged() {
    if (controller.text != value) {
      didChange(controller.text);
    }
  }
}
