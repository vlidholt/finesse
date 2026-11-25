import 'dart:ui' as ui;

import 'package:finesse/src/components/form/field.dart';
import 'package:finesse/src/components/textarea.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/utils/clipboard/clipboard_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A [Textarea] that takes part in a `FinesseForm`, with a label, a
/// description and validation.
class TextareaFormField extends FinesseFormField<String> {
  /// Creates a textarea form field.
  TextareaFormField({
    super.key,
    super.id,
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
    super.toValueTransformer,
    super.fromValueTransformer,
    super.onReset,
    super.focusNode,
    void Function(String)? onChanged,

    /// {@macro Textarea.decoration}
    FinesseDecoration? decoration,

    /// {@macro Textarea.placeholder}
    Widget? placeholder,

    /// {@macro Textarea.placeholderStyle}
    TextStyle? placeholderStyle,

    /// {@macro Textarea.alignment}
    AlignmentGeometry? alignment,

    /// {@macro Textarea.placeholderAlignment}
    AlignmentGeometry? placeholderAlignment,

    /// {@macro Textarea.padding}
    EdgeInsetsGeometry? padding,

    /// {@macro Textarea.inputPadding}
    EdgeInsetsGeometry? inputPadding,

    /// {@macro Textarea.gap}
    double? gap,

    /// {@macro Textarea.constraints}
    BoxConstraints? constraints,

    /// {@macro Textarea.mainAxisAlignment}
    MainAxisAlignment? mainAxisAlignment,

    /// {@macro Textarea.crossAxisAlignment}
    CrossAxisAlignment? crossAxisAlignment,

    /// {@macro Textarea.readOnly}
    bool readOnly = false,

    /// {@macro Textarea.autofocus}
    bool autofocus = false,

    /// {@macro Textarea.showCursor}
    bool? showCursor,

    /// {@macro Textarea.onTapAlwaysCalled}
    bool onTapAlwaysCalled = false,

    /// {@macro Textarea.onTapOutside}
    TapRegionCallback? onTapOutside,

    /// {@macro Textarea.onTap}
    GestureTapCallback? onTap,

    /// {@macro Textarea.scrollController}
    ScrollController? scrollController,

    /// {@macro Textarea.scrollPhysics}
    ScrollPhysics? scrollPhysics,

    /// {@macro Textarea.mouseCursor}
    MouseCursor? mouseCursor,

    /// {@macro Textarea.magnifierConfiguration}
    TextMagnifierConfiguration? magnifierConfiguration,

    /// {@macro Textarea.cursorWidth}
    double? cursorWidth,

    /// {@macro Textarea.cursorHeight}
    double? cursorHeight,

    /// {@macro Textarea.cursorRadius}
    Radius? cursorRadius,

    /// {@macro Textarea.cursorOpacityAnimates}
    bool? cursorOpacityAnimates,

    /// {@macro Textarea.cursorColor}
    Color? cursorColor,

    /// {@macro Textarea.selectionColor}
    Color? selectionColor,

    /// {@macro Textarea.keyboardAppearance}
    Brightness? keyboardAppearance,

    /// {@macro Textarea.textDirection}
    TextDirection? textDirection,

    /// {@macro Textarea.textAlign}
    TextAlign textAlign = TextAlign.start,

    /// {@macro Textarea.onEditingComplete}
    VoidCallback? onEditingComplete,

    /// {@macro Textarea.onSubmitted}
    ValueChanged<String>? onSubmitted,

    /// {@macro Textarea.onAppPrivateCommand}
    AppPrivateCommandCallback? onAppPrivateCommand,

    /// {@macro Textarea.style}
    TextStyle? style,

    /// {@macro Textarea.strutStyle}
    StrutStyle? strutStyle,

    /// {@macro Textarea.scribbleEnabled}
    bool scribbleEnabled = true,

    /// {@macro Textarea.stylusHandwritingEnabled}
    bool stylusHandwritingEnabled = true,

    /// {@macro Textarea.enableIMEPersonalizedLearning}
    bool enableIMEPersonalizedLearning = true,

    /// {@macro Textarea.contextMenuBuilder}
    EditableTextContextMenuBuilder? contextMenuBuilder,

    /// {@macro Textarea.spellCheckConfiguration}
    SpellCheckConfiguration? spellCheckConfiguration,

    /// {@macro Textarea.contentInsertionConfiguration}
    ContentInsertionConfiguration? contentInsertionConfiguration,

    /// {@macro Textarea.selectionControls}
    TextSelectionControls? selectionControls,

    /// {@macro Textarea.enableInteractiveSelection}
    bool? enableInteractiveSelection,

    /// {@macro Textarea.selectionHeightStyle}
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,

    /// {@macro Textarea.selectionWidthStyle}
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,

    /// {@macro Textarea.clipBehavior}
    Clip clipBehavior = Clip.hardEdge,

    /// {@macro Textarea.dragStartBehavior}
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,

    /// {@macro Textarea.minHeight}
    double minHeight = 80,

    /// {@macro Textarea.maxHeight}
    double maxHeight = 500,

    /// {@macro Textarea.resizable}
    bool resizable = true,

    /// {@macro Textarea.onHeightChanged}
    ValueChanged<double>? onHeightChanged,

    /// {@macro Textarea.resizeHandleBuilder}
    WidgetBuilder? resizeHandleBuilder,

    /// {@macro Textarea.groupId}
    Object? groupId,

    /// {@macro KeyboardToolbar.toolbarBuilder}
    WidgetBuilder? keyboardToolbarBuilder,

    /// {@macro TextField.leading}
    Widget? leading,

    /// {@macro TextField.trailing}
    Widget? trailing,

    /// {@macro TextField.top}
    Widget? top,

    /// {@macro TextField.bottom}
    Widget? bottom,

    /// {@macro TextField.onLineCountChanged}
    ValueChanged<int>? onLineCountChanged,

    /// {@macro TextField.verticalGap}
    double? verticalGap,

    /// {@macro TextField.useBrowserContextMenu}
    bool? useBrowserContextMenu,

    /// {@macro TextField.onPasteFiles}
    ValueChanged<List<ClipboardItem>>? onPasteFiles,

    /// {@macro TextField.onPasteFilesError}
    ValueChanged<Object>? onPasteFilesError,

    /// {@macro TextField.showCounter}
    bool showCounter = false,
  }) : super(
         initialValue: controller != null ? controller.text : initialValue,
         validator: validator == null ? null : (v) => validator(v ?? ''),
         onChanged: onChanged == null ? null : (v) => onChanged(v ?? ''),
         decorationBuilder: (context) =>
             (Theme.of(context).textFieldTheme.decoration ??
                     const FinesseDecoration())
                 .merge(decoration),
         builder: (state) {
           state as TextareaFormFieldState;
           return Textarea(
             key: state.textareaKey,
             controller: state.controller,
             restorationId: restorationId,
             enabled: state.enabled,
             focusNode: state.focusNode,
             readOnly: readOnly,
             decoration: state.decoration,
             style: style,
             cursorColor: cursorColor,
             selectionColor: selectionColor,
             textAlign: textAlign,
             textDirection: textDirection,
             keyboardAppearance: keyboardAppearance,
             autofocus: autofocus,
             showCursor: showCursor,
             placeholder: placeholder,
             placeholderStyle: placeholderStyle,
             placeholderAlignment: placeholderAlignment,
             alignment: alignment,
             padding: padding,
             inputPadding: inputPadding,
             gap: gap,
             constraints: constraints,
             mainAxisAlignment: mainAxisAlignment,
             crossAxisAlignment: crossAxisAlignment,
             onEditingComplete: onEditingComplete,
             onSubmitted: onSubmitted,
             onAppPrivateCommand: onAppPrivateCommand,
             scrollController: scrollController,
             scrollPhysics: scrollPhysics,
             mouseCursor: mouseCursor,
             magnifierConfiguration: magnifierConfiguration,
             cursorWidth: cursorWidth,
             cursorHeight: cursorHeight,
             cursorRadius: cursorRadius,
             cursorOpacityAnimates: cursorOpacityAnimates,
             scribbleEnabled: scribbleEnabled,
             stylusHandwritingEnabled: stylusHandwritingEnabled,
             enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
             contextMenuBuilder: contextMenuBuilder,
             spellCheckConfiguration: spellCheckConfiguration,
             contentInsertionConfiguration: contentInsertionConfiguration,
             selectionControls: selectionControls,
             enableInteractiveSelection: enableInteractiveSelection,
             selectionHeightStyle: selectionHeightStyle,
             selectionWidthStyle: selectionWidthStyle,
             clipBehavior: clipBehavior,
             dragStartBehavior: dragStartBehavior,
             onTap: onTap,
             onTapAlwaysCalled: onTapAlwaysCalled,
             onTapOutside: onTapOutside,
             minHeight: minHeight,
             maxHeight: maxHeight,
             resizable: resizable,
             onHeightChanged: onHeightChanged,
             resizeHandleBuilder: resizeHandleBuilder,
             strutStyle: strutStyle,
             groupId: groupId,
             keyboardToolbarBuilder: keyboardToolbarBuilder,
             top: top,
             bottom: bottom,
             leading: leading,
             trailing: trailing,
             onLineCountChanged: onLineCountChanged,
             verticalGap: verticalGap,
             useBrowserContextMenu: useBrowserContextMenu,
             onPasteFiles: onPasteFiles,
             onPasteFilesError: onPasteFilesError,
             showCounter: showCounter,
           );
         },
       );

  /// Controls the text. When null, the field creates its own controller.
  final TextEditingController? controller;

  @override
  FinesseFormFieldState<TextareaFormField, String> createState() =>
      TextareaFormFieldState();
}

/// The state of a [TextareaFormField].
class TextareaFormFieldState
    extends FinesseFormFieldState<TextareaFormField, String> {
  /// The key of the inner [Textarea].
  final GlobalKey<State<StatefulWidget>> textareaKey = GlobalKey();
  TextEditingController? _controller;

  /// The controller in use: [TextareaFormField.controller] when given,
  /// otherwise an internal one.
  TextEditingController get controller => widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: value);
    }
    controller.addListener(onControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(onControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TextareaFormField oldWidget) {
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
  void didChange(String? value) {
    super.didChange(value);
    if (controller.text != value) {
      controller.text = value ?? '';
    }
  }

  @override
  void reset() {
    super.reset();
    controller.text = initialValue ?? '';
    widget.onChanged?.call(controller.text);
  }

  /// Copies the controller's text into the field's value.
  void onControllerChanged() {
    if (controller.text != value) {
      didChange(controller.text);
    }
  }
}
