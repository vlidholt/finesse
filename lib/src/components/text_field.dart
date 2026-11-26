// ignore_for_file: lines_longer_than_80_chars

import 'dart:math';
import 'dart:ui' as ui;

import 'package:boxy/flex.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/context_menu.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/disabled.dart';
import 'package:una/src/components/text_magnifier.dart';
import 'package:una/src/components/text_selection.dart';
import 'package:una/src/i18n/localizations_delegate.dart';
import 'package:una/src/i18n/strings.g.dart';
import 'package:una/src/icons/phosphor_icon.dart';
import 'package:una/src/icons/phosphor_icons_regular.dart';
import 'package:una/src/raw_components/keyboard_toolbar.dart';
import 'package:una/src/raw_components/portal.dart';
import 'package:una/src/raw_components/pressable.dart';
import 'package:una/src/theme/components/decorator.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/clipboard/clipboard_service.dart';
import 'package:una/src/utils/extensions/text_style.dart';
import 'package:una/src/utils/pop_in.dart';
import 'package:una/src/utils/separated_iterable.dart';

String? _localizedLabel(
  ContextMenuButtonType type,
  UnaLocalizationsData l,
) {
  return switch (type) {
    ContextMenuButtonType.cut => l.input.cut,
    ContextMenuButtonType.copy => l.input.copy,
    ContextMenuButtonType.paste => l.input.paste,
    ContextMenuButtonType.selectAll => l.input.selectAll,
    _ => null,
  };
}

/// The `scrollPadding` of an input that is given none: 20 on every side,
/// and at the top and the bottom what lies over the scroll view the input
/// is in.
EdgeInsets _defaultScrollPadding(BuildContext context) {
  var covered = MediaQuery.paddingOf(context);
  // A `ListView` moves the padding into its own content and takes it off
  // for its children, so in a list the input is told of none. What lies
  // over the viewport is what the scroll view itself is told.
  final scrollable = Scrollable.maybeOf(context, axis: Axis.vertical);
  if (scrollable != null) {
    final own = context.getElementForInheritedWidgetOfExactType<MediaQuery>();
    final outer = scrollable.context
        .getElementForInheritedWidgetOfExactType<MediaQuery>();
    if (outer != null && !identical(outer, own)) {
      // The aspects of a `MediaQuery` are its own to name: this follows
      // every change of the outer one. Under a `Scaffold` that is the
      // page's insets and little else.
      final media = context.dependOnInheritedElement(outer) as MediaQuery;
      covered = media.data.padding;
    }
  }
  return EdgeInsets.fromLTRB(20, 20 + covered.top, 20, 20 + covered.bottom);
}

/// A customizable text input field with optional leading and trailing widgets.
///
/// The [TextField] widget provides a styled text field with support for
/// placeholders, leading/trailing decorations, and extensive text editing features. It integrates
/// with [Theme] for consistent styling and supports advanced interactions
/// like selection, context menus, and autofill.
class TextField extends StatefulWidget {
  /// Creates a text input widget with customizable properties.
  const TextField({
    super.key,
    this.initialValue,
    this.placeholder,
    this.controller,
    this.focusNode,
    this.decoration,
    this.undoController,
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled = true,
    this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding,
    this.dragStartBehavior = DragStartBehavior.start,
    bool? enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.mouseCursor,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.selectionColor,
    this.padding,
    this.leading,
    this.trailing,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.placeholderStyle,
    this.alignment,
    this.placeholderAlignment,
    this.inputPadding,
    this.gap,
    this.constraints,
    this.stylusHandwritingEnabled =
        EditableText.defaultStylusHandwritingEnabled,
    this.groupId,
    this.scrollbarPadding,
    this.keyboardToolbarBuilder,
    this.top,
    this.bottom,
    this.onLineCountChanged,
    this.editableTextSize,
    this.verticalGap,
    this.useBrowserContextMenu,
    this.onPasteFiles,
    this.onPasteFilesError,
    this.clearable = false,
    this.onCleared,
    this.revealable = false,
    this.showCounter = false,
  }) : smartDashesType =
           smartDashesType ??
           (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
       smartQuotesType =
           smartQuotesType ??
           (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
       keyboardType =
           keyboardType ??
           (maxLines == 1 ? TextInputType.text : TextInputType.multiline),
       enableInteractiveSelection =
           enableInteractiveSelection ?? (!readOnly || !obscureText),
       assert(
         initialValue == null || controller == null,
         'Either initialValue or controller must be specified',
       );

  /// Creates a field for a password: its text is obscured, a trailing
  /// button shows and hides it, and autocorrect and suggestions are off.
  ///
  /// The keyboard is the platform's password keyboard and the field is
  /// offered to the password manager ([AutofillHints.password]; pass
  /// [AutofillHints.newPassword] in a sign-up form).
  ///
  /// ```dart
  /// TextField.password(
  ///   placeholder: const Text('Password'),
  ///   onSubmitted: signIn,
  /// )
  /// ```
  const TextField.password({
    Key? key,
    String? initialValue,
    Widget? placeholder,
    TextEditingController? controller,
    FocusNode? focusNode,
    UnaDecoration? decoration,
    TextInputAction? textInputAction,
    TextStyle? style,
    bool readOnly = false,
    bool autofocus = false,
    String obscuringCharacter = '•',
    int? maxLength,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    Iterable<String>? autofillHints = const [AutofillHints.password],
    Widget? leading,
    Widget? trailing,
    bool clearable = false,
    bool showCounter = false,
    Object? groupId,
    WidgetBuilder? keyboardToolbarBuilder,
  }) : this(
         key: key,
         initialValue: initialValue,
         placeholder: placeholder,
         controller: controller,
         focusNode: focusNode,
         decoration: decoration,
         textInputAction: textInputAction,
         style: style,
         readOnly: readOnly,
         autofocus: autofocus,
         obscuringCharacter: obscuringCharacter,
         maxLength: maxLength,
         onChanged: onChanged,
         onEditingComplete: onEditingComplete,
         onSubmitted: onSubmitted,
         inputFormatters: inputFormatters,
         enabled: enabled,
         autofillHints: autofillHints,
         leading: leading,
         trailing: trailing,
         clearable: clearable,
         showCounter: showCounter,
         groupId: groupId,
         keyboardToolbarBuilder: keyboardToolbarBuilder,
         obscureText: true,
         revealable: true,
         autocorrect: false,
         enableSuggestions: false,
         keyboardType: TextInputType.visiblePassword,
       );

  /// {@template TextField.initialValue}
  /// The initial text value of the input.
  /// Used if [controller] is null; cannot be used with [controller].
  /// {@endtemplate}
  final String? initialValue;

  /// {@template TextField.placeholder}
  /// The widget displayed when the input is empty.
  /// Typically a [Text] widget, styled with [placeholderStyle].
  /// {@endtemplate}
  final Widget? placeholder;

  /// {@template TextField.controller}
  /// The controller for managing the text input’s value and selection.
  /// If null, an internal controller is created with [initialValue].
  /// {@endtemplate}
  final TextEditingController? controller;

  /// {@template TextField.focusNode}
  /// The focus node for controlling focus behavior.
  /// If null, an internal focus node is created.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template TextField.decoration}
  /// The decoration applied to the input field.
  /// Merged with the theme’s default decoration if provided.
  /// {@endtemplate}
  final UnaDecoration? decoration;

  /// {@template TextField.undoController}
  /// The controller for managing undo/redo history.
  /// If null, undo functionality is not provided.
  /// {@endtemplate}
  final UndoHistoryController? undoController;

  /// {@template TextField.keyboardType}
  /// The type of keyboard to display for the input.
  /// Defaults to [TextInputType.text] for single-line,
  /// [TextInputType.multiline] otherwise.
  /// {@endtemplate}
  final TextInputType keyboardType;

  /// {@template TextField.textInputAction}
  /// The action to perform when the user submits the input.
  /// Defaults to null, relying on platform behavior.
  /// {@endtemplate}
  final TextInputAction? textInputAction;

  /// {@template TextField.textCapitalization}
  /// The capitalization behavior for the input text.
  /// Defaults to [TextCapitalization.none].
  /// {@endtemplate}
  final TextCapitalization textCapitalization;

  /// {@template TextField.style}
  /// The text style for the input content.
  /// Defaults to the theme’s muted style with foreground color if not
  /// specified.
  /// {@endtemplate}
  final TextStyle? style;

  /// {@template TextField.strutStyle}
  /// The strut style for controlling line spacing.
  /// Defaults to null, relying on the text style.
  /// {@endtemplate}
  final StrutStyle? strutStyle;

  /// {@template TextField.textAlign}
  /// The horizontal alignment of the text within the input.
  /// Defaults to [TextAlign.start].
  /// {@endtemplate}
  final TextAlign textAlign;

  /// {@template TextField.textDirection}
  /// The directionality of the text (e.g., LTR or RTL).
  /// Defaults to null, inheriting from the context.
  /// {@endtemplate}
  final TextDirection? textDirection;

  /// {@template TextField.readOnly}
  /// Whether the input is read-only.
  /// Defaults to false; if true, editing is disabled but selection may still be
  /// enabled.
  /// {@endtemplate}
  final bool readOnly;

  /// {@template TextField.showCursor}
  /// Whether to display the cursor in the input.
  /// Defaults to null, relying on Flutter’s default behavior.
  /// {@endtemplate}
  final bool? showCursor;

  /// {@template TextField.autofocus}
  /// Whether the input automatically receives focus when built.
  /// Defaults to false.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template TextField.obscuringCharacter}
  /// The character used to obscure text when [obscureText] is true.
  /// Defaults to '•'.
  /// {@endtemplate}
  final String obscuringCharacter;

  /// {@template TextField.obscureText}
  /// Whether the input text is obscured (e.g., for passwords).
  /// Defaults to false; affects [smartDashesType] and [smartQuotesType].
  /// {@endtemplate}
  final bool obscureText;

  /// {@template TextField.autocorrect}
  /// Whether autocorrect is enabled for the input.
  /// Defaults to true.
  /// {@endtemplate}
  final bool autocorrect;

  /// {@template TextField.smartDashesType}
  /// The smart dashes behavior for the input.
  /// Defaults to enabled if not obscured, disabled if obscured.
  /// {@endtemplate}
  final SmartDashesType smartDashesType;

  /// {@template TextField.smartQuotesType}
  /// The smart quotes behavior for the input.
  /// Defaults to enabled if not obscured, disabled if obscured.
  /// {@endtemplate}
  final SmartQuotesType smartQuotesType;

  /// {@template TextField.enableSuggestions}
  /// Whether text suggestions are enabled for the input.
  /// Defaults to true.
  /// {@endtemplate}
  final bool enableSuggestions;

  /// {@template TextField.maxLines}
  /// The maximum number of lines the input can span.
  /// Defaults to 1; affects [keyboardType].
  /// {@endtemplate}
  final int? maxLines;

  /// {@template TextField.minLines}
  /// The minimum number of lines the input should display.
  /// Defaults to null; must be less than or equal to [maxLines].
  /// {@endtemplate}
  final int? minLines;

  /// {@template TextField.expands}
  /// Whether the input expands to fill available vertical space.
  /// Defaults to false; requires [maxLines] and [minLines] to be null.
  /// {@endtemplate}
  final bool expands;

  /// {@template TextField.maxLength}
  /// The maximum length of the input text.
  /// Defaults to null (no limit); enforced by [maxLengthEnforcement].
  /// {@endtemplate}
  final int? maxLength;

  /// {@template TextField.maxLengthEnforcement}
  /// How the [maxLength] is enforced.
  /// Defaults to platform-specific behavior if not specified.
  /// {@endtemplate}
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// {@template TextField.onChanged}
  /// Callback invoked when the input text changes.
  /// Provides the new text value.
  /// {@endtemplate}
  final ValueChanged<String>? onChanged;

  /// {@template TextField.onEditingComplete}
  /// Callback invoked when editing is completed (e.g., via keyboard action).
  /// Does not provide the text value.
  /// {@endtemplate}
  final VoidCallback? onEditingComplete;

  /// {@template TextField.onSubmitted}
  /// Callback invoked when the user submits the input (e.g., pressing Enter).
  /// Provides the submitted text value.
  /// {@endtemplate}
  final ValueChanged<String>? onSubmitted;

  /// {@template TextField.onAppPrivateCommand}
  /// Callback for handling private app commands.
  /// Provides action and data for platform-specific features.
  /// {@endtemplate}
  final AppPrivateCommandCallback? onAppPrivateCommand;

  /// {@template TextField.inputFormatters}
  /// The list of formatters to apply to the input text.
  /// Controls text transformation (e.g., masking, filtering).
  /// {@endtemplate}
  final List<TextInputFormatter>? inputFormatters;

  /// {@template TextField.enabled}
  /// Whether the input is interactive.
  /// Defaults to true; if false, the input is disabled and visually dimmed.
  /// {@endtemplate}
  final bool enabled;

  /// {@template TextField.cursorWidth}
  /// The width of the cursor.
  /// Defaults to 2.0 pixels.
  /// {@endtemplate}
  final double? cursorWidth;

  /// {@template TextField.cursorHeight}
  /// The height of the cursor.
  /// Defaults to null, matching the text height.
  /// {@endtemplate}
  final double? cursorHeight;

  /// {@template TextField.cursorRadius}
  /// The radius of the cursor’s corners.
  /// Defaults to null (sharp edges).
  /// {@endtemplate}
  final Radius? cursorRadius;

  /// {@template TextField.cursorOpacityAnimates}
  /// Whether the cursor opacity animates when blinking.
  /// Defaults to false, relying on EditableText default value.
  /// {@endtemplate}
  final bool? cursorOpacityAnimates;

  /// {@template TextField.cursorColor}
  /// The color of the cursor.
  /// Defaults to the theme’s primary color if not specified.
  /// {@endtemplate}
  final Color? cursorColor;

  /// {@template TextField.selectionHeightStyle}
  /// The height style of the selection highlight.
  /// Defaults to [ui.BoxHeightStyle.tight].
  /// {@endtemplate}
  final ui.BoxHeightStyle selectionHeightStyle;

  /// {@template TextField.selectionWidthStyle}
  /// The width style of the selection highlight.
  /// Defaults to [ui.BoxWidthStyle.tight].
  /// {@endtemplate}
  final ui.BoxWidthStyle selectionWidthStyle;

  /// {@template TextField.keyboardAppearance}
  /// The appearance (brightness) of the keyboard.
  /// Defaults to the theme’s brightness if not specified.
  /// {@endtemplate}
  final Brightness? keyboardAppearance;

  /// {@template TextField.scrollPadding}
  /// The space kept around the input when a scroll view brings it into
  /// view, as it does when the input takes the focus.
  ///
  /// Defaults to 20 on every side, and at the top and the bottom what
  /// lies over the scroll view there as well — its `MediaQuery` padding,
  /// which under a `Scaffold` is the app bar, the bottom bar and the
  /// footer — so a focused input comes to rest clear of the bars, not
  /// under them.
  /// {@endtemplate}
  final EdgeInsets? scrollPadding;

  /// {@template TextField.dragStartBehavior}
  /// The behavior for starting a drag gesture.
  /// Defaults to [DragStartBehavior.start].
  /// {@endtemplate}
  final DragStartBehavior dragStartBehavior;

  /// {@template TextField.enableInteractiveSelection}
  /// Whether interactive text selection is enabled.
  /// Defaults to true unless [readOnly] or [obscureText] is true.
  /// {@endtemplate}
  final bool enableInteractiveSelection;

  /// {@template TextField.selectionControls}
  /// Builds the drag handles at the ends of a selection.
  ///
  /// Defaults to `UnaTextSelectionControls.adaptive`: this system's
  /// handles on iOS and Android, and none on a desktop, where a selection
  /// is made with the pointer.
  /// {@endtemplate}
  final TextSelectionControls? selectionControls;

  /// {@template TextField.onTap}
  /// Callback invoked when the input field is tapped.
  /// Useful for custom tap handling, e.g., in read-only mode.
  /// {@endtemplate}
  final GestureTapCallback? onTap;

  /// {@template TextField.onTapAlwaysCalled}
  /// Whether [onTap] is called even when selection is active.
  /// Defaults to false; if true, always triggers on tap.
  /// {@endtemplate}
  final bool onTapAlwaysCalled;

  /// {@template TextField.onTapOutside}
  /// Callback invoked when tapping outside the input field.
  /// Useful for handling focus dismissal or other actions.
  /// {@endtemplate}
  final TapRegionCallback? onTapOutside;

  /// {@template TextField.mouseCursor}
  /// The cursor displayed when hovering over the input.
  /// Defaults to [WidgetStateMouseCursor.textable].
  /// {@endtemplate}
  final MouseCursor? mouseCursor;

  /// {@template TextField.scrollController}
  /// The controller for managing scrolling within the input.
  /// Defaults to null (no custom scrolling).
  /// {@endtemplate}
  final ScrollController? scrollController;

  /// {@template TextField.scrollPhysics}
  /// The physics applied to scrolling within the input.
  /// Defaults to null, relying on platform defaults.
  /// {@endtemplate}
  final ScrollPhysics? scrollPhysics;

  /// {@template TextField.autofillHints}
  /// Hints for autofill services to suggest values.
  /// Defaults to an empty list.
  /// {@endtemplate}
  final Iterable<String>? autofillHints;

  /// {@template TextField.contentInsertionConfiguration}
  /// Configuration for content insertion (e.g., paste handling).
  /// Defaults to null, using default behavior.
  /// {@endtemplate}
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// {@template TextField.clipBehavior}
  /// The clip behavior for the input’s content.
  /// Defaults to [Clip.hardEdge].
  /// {@endtemplate}
  final Clip clipBehavior;

  /// {@template TextField.restorationId}
  /// The ID for restoring the input’s state across sessions.
  /// Defaults to null (no restoration).
  /// {@endtemplate}
  final String? restorationId;

  /// {@template TextField.scribbleEnabled}
  /// Whether scribble (handwriting) input is enabled.
  /// Defaults to true.
  /// {@endtemplate}
  final bool scribbleEnabled;

  /// {@template TextField.stylusHandwritingEnabled}
  /// Whether a stylus can write text into the field on platforms that
  /// support it. Defaults to [EditableText.defaultStylusHandwritingEnabled].
  /// {@endtemplate}
  final bool stylusHandwritingEnabled;

  /// {@template TextField.enableIMEPersonalizedLearning}
  /// Whether the IME can use personalized learning data.
  /// Defaults to true.
  /// {@endtemplate}
  final bool enableIMEPersonalizedLearning;

  /// {@template TextField.contextMenuBuilder}
  /// Builds the menu of a selection: cut, copy, paste and so on.
  ///
  /// Defaults to `TextFieldState.defaultContextMenuBuilder`, which follows
  /// the platform: a horizontal `TextSelectionToolbar` over the selection
  /// on iOS and Android, a `ContextMenu` at the pointer on a desktop. On
  /// the web the browser's own menu is used instead (see
  /// `TextField.useBrowserContextMenu`).
  /// {@endtemplate}
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// {@template TextField.spellCheckConfiguration}
  /// Configuration for spell checking in the input.
  /// Defaults to null (no spell checking).
  /// {@endtemplate}
  final SpellCheckConfiguration? spellCheckConfiguration;

  /// {@template TextField.magnifierConfiguration}
  /// The magnifier shown above the finger while the caret or a selection
  /// handle is dragged.
  ///
  /// Defaults to `TextMagnifier.adaptiveConfiguration`: this system's loupe
  /// on iOS and Android, none on a desktop. Pass
  /// [TextMagnifierConfiguration.disabled] for no magnifier at all.
  /// {@endtemplate}
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// {@template TextField.selectionColor}
  /// The color of the text selection highlight.
  /// Defaults to the theme’s selection color when focused.
  /// {@endtemplate}
  final Color? selectionColor;

  /// {@template TextField.padding}
  /// The padding around the entire input, including decorations.
  /// Defaults to theme’s input padding if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template TextField.leading}
  /// The widget displayed before the input field.
  /// Typically an icon or small graphic.
  /// {@endtemplate}
  final Widget? leading;

  /// {@template TextField.trailing}
  /// The widget displayed after the input field.
  /// Typically an icon or small graphic.
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template TextField.top}
  /// The widget displayed above the input field.
  /// {@endtemplate}
  final Widget? top;

  /// {@template TextField.bottom}
  /// The widget displayed below the input field.
  /// {@endtemplate}
  final Widget? bottom;

  /// {@template TextField.mainAxisAlignment}
  /// The main axis alignment of the input’s row (horizontal).
  /// Defaults to [MainAxisAlignment.start] if not specified.
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template TextField.crossAxisAlignment}
  /// The cross axis alignment of the input’s row (vertical).
  /// Defaults to [CrossAxisAlignment.center] if not specified.
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template TextField.placeholderStyle}
  /// The text style for the placeholder when the input is empty.
  /// Defaults to the theme’s muted style if not specified.
  /// {@endtemplate}
  final TextStyle? placeholderStyle;

  /// {@template TextField.placeholderAlignment}
  /// The alignment of the placeholder within the input field.
  /// Defaults to [Alignment.topLeft] if not specified.
  /// {@endtemplate}
  final AlignmentGeometry? placeholderAlignment;

  /// {@template TextField.alignment}
  /// The alignment of the input field.
  /// Defaults to [Alignment.topLeft] if not specified.
  /// {@endtemplate}
  final AlignmentGeometry? alignment;

  /// {@template TextField.inputPadding}
  /// The padding around the editable text within the input field.
  /// Defaults to [EdgeInsets.zero] if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? inputPadding;

  /// {@template TextField.gap}
  /// The gap between the input field and its leading/trailing widgets.
  /// Defaults to 8 if not specified.
  /// {@endtemplate}
  final double? gap;

  /// {@template TextField.verticalGap}
  /// The gap between the input field and its top/bottom widgets.
  ///
  /// Defaults to 0 if not specified.
  /// {@endtemplate}
  final double? verticalGap;

  /// {@template TextField.constraints}
  /// The constraints of the input field.
  ///
  /// By default only minHeight is set, based on the [style] and
  /// [placeholderStyle].
  /// {@endtemplate}
  final BoxConstraints? constraints;

  /// {@template TextField.onLineCountChanged}
  /// The callback that is called when the line count changes.
  /// The current line count is passed as an argument.
  ///
  /// **NOTE**: If the input doesn't get an higher height, this callback won't be called.
  /// For example, if the [maxLines] limit has been reached.
  /// {@endtemplate}
  final ValueChanged<int>? onLineCountChanged;

  /// {@template TextField.groupId}
  /// The tap-region group of the field. A tap inside any region of the same
  /// group does not count as a tap outside the field. Defaults to a group of
  /// the field's own.
  /// {@endtemplate}
  final Object? groupId;

  /// {@template TextField.scrollbarPadding}
  /// The padding around the scrollbar.
  ///
  /// Defaults to null if not specified.
  /// {@endtemplate}
  final EdgeInsetsGeometry? scrollbarPadding;

  /// {@template TextField.editableTextSize}
  /// The size of the EditableText widget.
  ///
  /// Defaults to null if not specified.
  /// {@endtemplate}
  final Size? editableTextSize;

  /// {@macro KeyboardToolbar.toolbarBuilder}
  final WidgetBuilder? keyboardToolbarBuilder;

  /// {@template TextField.useBrowserContextMenu}
  /// Whether to use the browser's native context menu on web.
  ///
  /// When `true` on web, the native browser context menu is shown instead of
  /// the custom [ContextMenu]. This enables native paste (including file
  /// paste), spellcheck, and browser accessibility features.
  ///
  /// Has no effect on non-web platforms.
  ///
  /// Defaults to `true` on web, `false` otherwise.
  /// {@endtemplate}
  final bool? useBrowserContextMenu;

  /// {@template TextField.onPasteFiles}
  /// Called when files are pasted from the clipboard on web.
  ///
  /// Invoked on Ctrl+V / Cmd+V when the input is focused and the clipboard
  /// contains file data. Normal text paste still proceeds regardless.
  ///
  /// Only works on web. On other platforms, this callback is never invoked.
  /// {@endtemplate}
  final ValueChanged<List<ClipboardItem>>? onPasteFiles;

  /// {@template TextField.onPasteFilesError}
  /// Called when an error occurs while extracting files from the clipboard.
  ///
  /// Only works on web. On other platforms, this callback is never invoked.
  /// {@endtemplate}
  final ValueChanged<Object>? onPasteFilesError;

  /// {@template TextField.clearable}
  /// Whether a clear button shows at the end of the field while it has
  /// text. Defaults to false.
  ///
  /// The button empties the field, keeps the focus in it and reports the
  /// change through [onChanged]. It is not shown while the field is
  /// disabled or read-only.
  /// {@endtemplate}
  final bool clearable;

  /// {@template TextField.onCleared}
  /// Called after the clear button of a [clearable] field emptied it.
  /// [onChanged] is called first, with an empty string.
  /// {@endtemplate}
  final VoidCallback? onCleared;

  /// {@template TextField.revealable}
  /// Whether an obscured field has a button at its end that shows the text
  /// and hides it again. Defaults to false; [TextField.password] sets it.
  ///
  /// Has no effect unless [obscureText] is true.
  /// {@endtemplate}
  final bool revealable;

  /// {@template TextField.showCounter}
  /// Whether the number of characters typed is shown under the text, out of
  /// [maxLength] when there is one: `12/80`. Defaults to false.
  ///
  /// The count is of user-perceived characters, as [maxLength] is. When the
  /// limit is reached, assistive technology is told.
  /// {@endtemplate}
  final bool showCounter;

  /// A constant representing no maximum length for the input.
  static const int noMaxLength = -1;

  /// Whether text selection is enabled, based on [enableInteractiveSelection].
  bool get selectionEnabled => enableInteractiveSelection;

  @override
  State<TextField> createState() => TextFieldState();
}

/// The state of a [TextField].
///
/// Reach it with a `GlobalKey<TextFieldState>` to read the controllers and
/// focus node in use.
class TextFieldState extends State<TextField>
    with RestorationMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  FocusNode? _focusNode;

  /// The focus node in use: [TextField.focusNode] when given, otherwise an
  /// internal one.
  FocusNode get effectiveFocusNode =>
      widget.focusNode ??
      (_focusNode ??= FocusNode(canRequestFocus: !widget.readOnly));

  /// Whether the field has focus. Updated by [onFocusChange].
  @protected
  final hasFocus = ValueNotifier(false);

  /// Whether the field is empty, i.e. whether the placeholder should show.
  ///
  /// Derived from [effectiveController] so that only the placeholder rebuilds
  /// when the text changes. Listening to the controller directly around the
  /// whole field rebuilt EditableText, the decorator, the scrollbar and the
  /// leading/trailing row on every keystroke — and on every cursor move, since
  /// TextEditingController also notifies on selection changes.
  final _isEmpty = ValueNotifier(true);
  TextEditingController? _isEmptySource;

  RestorableTextEditingController? _controller;

  /// The text controller in use: [TextField.controller] when given, otherwise
  /// an internal one that supports state restoration.
  TextEditingController get effectiveController =>
      widget.controller ?? _controller!.value;
  bool _showSelectionHandles = false;
  final _groupId = UniqueKey();

  /// Whether a [TextField.revealable] field hides its text at the moment.
  bool _obscured = true;

  /// Empties the field as the user would: through the formatters, into the
  /// undo history, and reported by [TextField.onChanged].
  void clear() {
    final editable = _editableText;
    if (editable != null) {
      editable.userUpdateTextEditingValue(
        TextEditingValue.empty,
        SelectionChangedCause.toolbar,
      );
    } else {
      effectiveController.clear();
      widget.onChanged?.call('');
    }
    if (effectiveFocusNode.canRequestFocus) effectiveFocusNode.requestFocus();
    widget.onCleared?.call();
  }

  ScrollController? _scrollController;

  /// The scroll controller in use: [TextField.scrollController] when given,
  /// otherwise an internal one.
  ScrollController get effectiveScrollController =>
      widget.scrollController ?? _scrollController!;

  /// Whether the text is longer than the field, so that it can scroll.
  bool get isScrollable {
    if (!effectiveScrollController.hasClients) {
      return false;
    }
    return effectiveScrollController.position.maxScrollExtent > 0;
  }

  @override
  void initState() {
    super.initState();
    effectiveFocusNode.addListener(onFocusChange);

    if (widget.controller == null) {
      _createLocalController(TextEditingValue(text: widget.initialValue ?? ''));
    }
    if (widget.scrollController == null) _scrollController = ScrollController();
    if (widget.onPasteFiles != null && kIsWeb) {
      UnaClipboard.addPasteFilesListener(_onPasteFiles);
    }
    if (widget.onPasteFilesError != null && kIsWeb) {
      UnaClipboard.addPasteFilesErrorListener(_onPasteFilesError);
    }
    // NOTE: _syncIsEmptySource is deliberately not called here. For the local
    // controller, `effectiveController` reads RestorableTextEditingController
    // .value, which asserts the property is registered — and registration
    // happens in restoreState, after initState. It is called from restoreState
    // instead.
  }

  /// Points [_isEmpty] at the current [effectiveController], which can change
  /// when the caller swaps `controller` or when the local one is created.
  void _syncIsEmptySource() {
    final controller = effectiveController;
    if (identical(controller, _isEmptySource)) return;
    _isEmptySource?.removeListener(_updateIsEmpty);
    _isEmptySource = controller..addListener(_updateIsEmpty);
    _updateIsEmpty();
  }

  void _updateIsEmpty() {
    _isEmpty.value = effectiveController.text.isEmpty;
  }

  @override
  void didUpdateWidget(TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(onFocusChange);
      effectiveFocusNode.addListener(onFocusChange);
    }
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    if (kIsWeb && widget.onPasteFiles != oldWidget.onPasteFiles) {
      if (oldWidget.onPasteFiles != null) {
        UnaClipboard.removePasteFilesListener(_onPasteFiles);
      }
      if (widget.onPasteFiles != null) {
        UnaClipboard.addPasteFilesListener(_onPasteFiles);
      }
    }

    if (kIsWeb && widget.onPasteFilesError != oldWidget.onPasteFilesError) {
      if (oldWidget.onPasteFilesError != null) {
        UnaClipboard.removePasteFilesErrorListener(_onPasteFilesError);
      }
      if (widget.onPasteFilesError != null) {
        UnaClipboard.addPasteFilesErrorListener(_onPasteFilesError);
      }
    }

    if (widget.readOnly != oldWidget.readOnly) {
      effectiveFocusNode.canRequestFocus = !widget.readOnly;
      if (effectiveFocusNode.hasFocus &&
          effectiveController.selection.isCollapsed) {
        _showSelectionHandles = !widget.readOnly;
      }
    }

    _syncIsEmptySource();
  }

  @override
  void dispose() {
    _isEmptySource?.removeListener(_updateIsEmpty);
    _isEmpty.dispose();
    effectiveFocusNode.removeListener(onFocusChange);
    if (kIsWeb && widget.onPasteFiles != null) {
      UnaClipboard.removePasteFilesListener(_onPasteFiles);
    }
    if (kIsWeb && widget.onPasteFilesError != null) {
      UnaClipboard.removePasteFilesErrorListener(_onPasteFilesError);
    }
    if (widget.focusNode == null) effectiveFocusNode.dispose();
    _controller?.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  /// Copies the focus node's state into [hasFocus].
  void onFocusChange() {
    hasFocus.value = effectiveFocusNode.hasFocus;
  }

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  late final _selectionGestureDetectorBuilder =
      _InputSelectionGestureDetectorBuilder(state: this);

  @override
  bool get forcePressEnabled {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS => true,
      _ => false,
    };
  }

  @override
  bool get selectionEnabled => widget.enableInteractiveSelection;

  @override
  String? get restorationId => widget.restorationId;

  EditableTextState? get _editableText => editableTextKey.currentState;

  /// Whether [TextField.maxLines] is anything other than 1.
  bool get isMultiline => widget.maxLines != 1;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) _registerController();
    // Runs before the first build and after any restoration, and by this point
    // the restorable controller is registered so effectiveController is safe.
    _syncIsEmptySource();
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final willShowSelectionHandles = _shouldShowSelectionHandles(cause);
    if (willShowSelectionHandles != _showSelectionHandles) {
      setState(() {
        _showSelectionHandles = willShowSelectionHandles;
      });
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        if (cause == SelectionChangedCause.longPress) {
          _editableText?.bringIntoView(selection.extent);
        }
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        break;
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (cause == SelectionChangedCause.drag) {
          _editableText?.hideToolbar();
        }
    }
  }

  void _onPasteFiles(List<ClipboardItem> files) {
    if (!effectiveFocusNode.hasFocus) return;
    widget.onPasteFiles?.call(files);
  }

  void _onPasteFilesError(Object error) {
    if (!effectiveFocusNode.hasFocus) return;
    widget.onPasteFilesError?.call(error);
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    // When the text field is activated by something that doesn't trigger the
    // selection overlay, we shouldn't show the handles either.
    if (!_selectionGestureDetectorBuilder.shouldShowSelectionToolbar) {
      return false;
    }

    if (cause == SelectionChangedCause.keyboard) {
      return false;
    }

    if (widget.readOnly && effectiveController.selection.isCollapsed) {
      return false;
    }

    if (!widget.enabled) {
      return false;
    }

    if (cause == SelectionChangedCause.longPress ||
        // ignore: deprecated_member_use
        cause == SelectionChangedCause.scribble) {
      return true;
    }

    if (effectiveController.text.isNotEmpty) {
      return true;
    }

    return false;
  }

  int? _previousLineCount;

  /// Measures [text] at the field's width and calls
  /// [TextField.onLineCountChanged] when the line count differs from the last
  /// call.
  void fireOnLineCountChange(
    String text, {
    required BoxConstraints constraints,
    required TextStyle effectiveTextStyle,
    required TextScaler textScaler,
    required double effectiveCursorWidth,
  }) {
    // Do nothing if the callback is null
    if (widget.onLineCountChanged == null) {
      return;
    }
    final span = TextSpan(
      text: text,
      style: effectiveTextStyle,
    );
    final tp = TextPainter(
      text: span,
      textDirection: Directionality.of(
        context,
      ),
      textScaler: textScaler,
      maxLines: widget.maxLines,
      textAlign: widget.textAlign,
      textWidthBasis: widget.expands
          ? TextWidthBasis.parent
          : TextWidthBasis.longestLine,
    );
    // The default caret gap is 1 pixel, so we need to account for that
    const caretGap = 1;
    // default of TextField constructor
    tp.layout(
      maxWidth: constraints.maxWidth - caretGap - effectiveCursorWidth,
    );
    final numLines = tp.computeLineMetrics().length;
    // Only fire callback if line count changed
    if (numLines != _previousLineCount) {
      _previousLineCount = numLines;
      widget.onLineCountChanged!(
        numLines,
      );
    }
  }

  /// The default text selection menu, which follows the platform.
  ///
  /// On iOS and Android it is a [TextSelectionToolbar]: a horizontal pill
  /// over the selection with whatever the platform offers for it. When
  /// `TextFieldTheme.useSystemContextMenu` is true and the platform can draw
  /// the menu itself (iOS 16 and later), the system's own menu is shown
  /// instead — pasting from it does not raise iOS's paste-permission
  /// dialog.
  ///
  /// On a desktop it is a [ContextMenu] at the pointer with localized cut,
  /// copy, paste and select-all items. Items that would do nothing, such as
  /// copy with no selection, are left out.
  static Widget defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (UnaTextSelectionControls.usesTouchSelection) {
      final useSystemMenu =
          Theme.of(context).textFieldTheme.useSystemContextMenu ?? false;
      if (useSystemMenu &&
          SystemContextMenu.isSupportedByField(editableTextState)) {
        return SystemContextMenu.editableText(
          editableTextState: editableTextState,
        );
      }
      return TextSelectionToolbar.editableText(
        editableTextState: editableTextState,
      );
    }
    final l = UnaLocalizations.of(context);
    final textValue = editableTextState.textEditingValue;
    final selection = textValue.selection;
    final hasSelection = selection.isValid && !selection.isCollapsed;
    final buttonItems = editableTextState.contextMenuButtonItems.where(
      (item) {
        if (item.type == ContextMenuButtonType.cut ||
            item.type == ContextMenuButtonType.copy) {
          return hasSelection;
        }
        if (item.type == ContextMenuButtonType.selectAll) {
          return !(hasSelection &&
              selection.start == 0 &&
              selection.end == textValue.text.length);
        }
        return (_localizedLabel(item.type, l) ?? item.label ?? '').isNotEmpty;
      },
    ).toList();
    if (buttonItems.isEmpty) return const SizedBox.shrink();
    return FocusScope(
      // Prevent the context menu from stealing focus from the
      // EditableText, which would cause Flutter to dismiss the overlay
      // before the menu renders.
      canRequestFocus: false,
      child: ContextMenu(
        open: true,
        anchor: GlobalAnchor(
          editableTextState.contextMenuAnchors.primaryAnchor,
        ),
        items: [
          for (final item in buttonItems)
            MenuItem(
              onTapDown: item.onPressed != null
                  ? (_) {
                      item.onPressed!();
                      // After Select All, re-show the toolbar so the
                      // user can tap Copy/Cut on the updated selection.
                      if (item.type == ContextMenuButtonType.selectAll) {
                        editableTextState.showToolbar();
                      }
                    }
                  : null,
              child: Text(
                _localizedLabel(item.type, l) ?? item.label ?? '',
              ),
            ),
        ],
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextStyle = theme.textTheme.muted
        .copyWith(
          color: theme.colorScheme.foreground,
        )
        .merge(theme.textFieldTheme.style)
        .merge(widget.style);

    final effectiveDecoration =
        (theme.textFieldTheme.decoration ?? const UnaDecoration()).merge(
          widget.decoration,
        );

    final effectiveCursorColor =
        widget.cursorColor ??
        theme.textFieldTheme.cursorColor ??
        theme.colorScheme.primary;

    final effectiveCursorWidth =
        widget.cursorWidth ?? theme.textFieldTheme.cursorWidth ?? 2.0;

    final effectiveCursorHeight =
        widget.cursorHeight ?? theme.textFieldTheme.cursorHeight;

    final effectiveCursorRadius =
        widget.cursorRadius ?? theme.textFieldTheme.cursorRadius;

    final effectiveCursorOpacityAnimates =
        widget.cursorOpacityAnimates ??
        theme.textFieldTheme.cursorOpacityAnimates ??
        false;

    final effectivePadding =
        widget.padding ??
        theme.textFieldTheme.padding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final effectiveInputPadding =
        widget.inputPadding ??
        theme.textFieldTheme.inputPadding ??
        EdgeInsets.zero;

    final effectivePlaceholderStyle = theme.textTheme.muted
        .merge(theme.textFieldTheme.placeholderStyle)
        .merge(widget.placeholderStyle)
        .fallback(color: theme.colorScheme.mutedForeground);

    final defaultAlignment = Directionality.of(context) == TextDirection.rtl
        ? Alignment.topRight
        : Alignment.topLeft;

    final effectivePlaceholderAlignment =
        widget.placeholderAlignment ??
        theme.textFieldTheme.placeholderAlignment ??
        defaultAlignment;

    final effectiveAlignemnt =
        widget.alignment ?? theme.textFieldTheme.alignment ?? defaultAlignment;

    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ??
        theme.textFieldTheme.mainAxisAlignment ??
        MainAxisAlignment.start;

    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ??
        theme.textFieldTheme.crossAxisAlignment ??
        CrossAxisAlignment.center;
    final effectiveMouseCursor =
        widget.mouseCursor ?? WidgetStateMouseCursor.textable;

    final effectiveGap = widget.gap ?? theme.textFieldTheme.gap ?? 8.0;

    final effectiveMaxLengthEnforcement =
        widget.maxLengthEnforcement ??
        LengthLimitingTextInputFormatter.getDefaultMaxLengthEnforcement(
          defaultTargetPlatform,
        );

    final effectiveInputFormatters = <TextInputFormatter>[
      ...?widget.inputFormatters,
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(
          widget.maxLength,
          maxLengthEnforcement: effectiveMaxLengthEnforcement,
        ),
    ];

    final textScaler = MediaQuery.textScalerOf(context);

    final maxFontSize = max(
      (effectivePlaceholderStyle.fontSize ?? 0) *
          (effectivePlaceholderStyle.height ?? 0),
      (effectiveTextStyle.fontSize ?? 0) * (effectiveTextStyle.height ?? 0),
    );
    final maxFontSizeScaled = textScaler.scale(maxFontSize);

    final effectiveConstraints =
        widget.constraints ??
        theme.textFieldTheme.constraints ??
        BoxConstraints(minHeight: maxFontSizeScaled);

    final effectiveGroupId = widget.groupId ?? _groupId;

    final effectiveScrollbarPadding =
        widget.scrollbarPadding ?? theme.textFieldTheme.scrollbarPadding;

    final effectiveVerticalGap =
        widget.verticalGap ?? theme.textFieldTheme.verticalGap ?? 0.0;

    final effectiveUseBrowserContextMenu =
        widget.useBrowserContextMenu ??
        theme.textFieldTheme.useBrowserContextMenu ??
        kIsWeb;

    final l = UnaLocalizations.of(context);
    final showClear = widget.clearable && widget.enabled && !widget.readOnly;
    final showReveal = widget.revealable && widget.obscureText;
    // As tall as a line of the field's text, so a button never makes the
    // field taller than its style says.
    final adornmentExtent = maxFontSizeScaled > 0 ? maxFontSizeScaled : 20.0;

    return ConstrainedBox(
      constraints: effectiveConstraints,
      child: Disabled(
        enabled: widget.enabled,
        child: _selectionGestureDetectorBuilder.buildGestureDetector(
          behavior: HitTestBehavior.translucent,
          child: KeyboardToolbar(
            focusNode: effectiveFocusNode,
            toolbarBuilder: widget.keyboardToolbarBuilder,
            child: ValueListenableBuilder(
              valueListenable: hasFocus,
              builder: (context, focused, _) {
                return Builder(
                  builder: (context) {
                    final Widget editableText;
                    final rawEditableText = SizedBox(
                      width: widget.editableTextSize?.width,
                      height: widget.editableTextSize?.height,
                      child: EditableText(
                        showSelectionHandles: _showSelectionHandles,
                        key: editableTextKey,
                        controller: effectiveController,
                        obscuringCharacter: widget.obscuringCharacter,
                        readOnly: widget.readOnly,
                        focusNode: effectiveFocusNode,
                        // ! Selection handler section here
                        onSelectionChanged: _handleSelectionChanged,
                        selectionColor: focused
                            ? widget.selectionColor ??
                                  theme.colorScheme.selection
                            : null,
                        selectionHeightStyle: widget.selectionHeightStyle,
                        selectionWidthStyle: widget.selectionWidthStyle,
                        contextMenuBuilder: effectiveUseBrowserContextMenu
                            ? null
                            : (widget.contextMenuBuilder ??
                                  defaultContextMenuBuilder),
                        selectionControls:
                            widget.selectionControls ??
                            UnaTextSelectionControls.adaptive,
                        // ! End of selection handler
                        // ! section
                        mouseCursor: effectiveMouseCursor,
                        enableInteractiveSelection:
                            widget.enableInteractiveSelection,
                        style: effectiveTextStyle,
                        strutStyle: widget.strutStyle,
                        cursorColor: effectiveCursorColor,
                        cursorWidth: effectiveCursorWidth,
                        cursorHeight: effectiveCursorHeight,
                        cursorRadius: effectiveCursorRadius,
                        cursorOpacityAnimates: effectiveCursorOpacityAnimates,
                        backgroundCursorColor: const Color(
                          0xFF9E9E9E,
                        ),
                        keyboardType: widget.keyboardType,
                        keyboardAppearance:
                            widget.keyboardAppearance ?? theme.brightness,
                        textInputAction: widget.textInputAction,
                        textCapitalization: widget.textCapitalization,
                        autofocus: widget.autofocus,
                        obscureText:
                            widget.obscureText &&
                            !(widget.revealable && !_obscured),
                        autocorrect: widget.autocorrect,
                        magnifierConfiguration:
                            widget.magnifierConfiguration ??
                            TextMagnifier.adaptiveConfiguration,
                        smartDashesType: widget.smartDashesType,
                        smartQuotesType: widget.smartQuotesType,
                        enableSuggestions: widget.enableSuggestions,
                        maxLines: widget.maxLines,
                        minLines: widget.minLines,
                        expands: widget.expands,
                        onChanged: (v) {
                          _editableText?.hideToolbar();
                          widget.onChanged?.call(v);
                        },
                        onEditingComplete: widget.onEditingComplete,
                        onSubmitted: widget.onSubmitted,
                        onAppPrivateCommand: widget.onAppPrivateCommand,
                        inputFormatters: effectiveInputFormatters,
                        scrollPadding:
                            widget.scrollPadding ??
                            _defaultScrollPadding(context),
                        dragStartBehavior: widget.dragStartBehavior,
                        scrollPhysics: widget.scrollPhysics,
                        // Disable the internal scrollbars
                        // because there is already a
                        // Scrollbar above.
                        scrollBehavior:
                            ScrollConfiguration.of(
                              context,
                            ).copyWith(
                              scrollbars: false,
                              overscroll: false,
                            ),
                        autofillHints: widget.autofillHints,
                        clipBehavior: widget.clipBehavior,
                        restorationId: 'editable',
                        // ignore: deprecated_member_use
                        scribbleEnabled: widget.scribbleEnabled,
                        stylusHandwritingEnabled:
                            widget.stylusHandwritingEnabled,
                        enableIMEPersonalizedLearning:
                            widget.enableIMEPersonalizedLearning,
                        contentInsertionConfiguration:
                            widget.contentInsertionConfiguration,
                        undoController: widget.undoController,
                        spellCheckConfiguration: widget.spellCheckConfiguration,
                        textAlign: widget.textAlign,
                        onTapOutside: widget.onTapOutside,
                        rendererIgnoresPointer: true,
                        showCursor: widget.showCursor,
                        groupId: effectiveGroupId,
                      ),
                    );

                    if (widget.onLineCountChanged != null) {
                      editableText = LayoutBuilder(
                        builder: (context, constraints) {
                          /// Fire onLineCountChanged after the frame is rendered
                          /// This ensures that the line count is accurate, even for
                          /// resizes that happen outside of text changes.
                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) {
                            if (mounted) {
                              fireOnLineCountChange(
                                effectiveController.text,
                                textScaler: textScaler,
                                constraints: constraints,
                                effectiveTextStyle: effectiveTextStyle,
                                effectiveCursorWidth: effectiveCursorWidth,
                              );
                            }
                          });
                          return rawEditableText;
                        },
                      );
                    } else {
                      editableText = rawEditableText;
                    }
                    return Decorator(
                      decoration: effectiveDecoration,
                      focused: focused,
                      child: BoxyColumn(
                        mainAxisSize: MainAxisSize.min,
                        // A single-line field is laid out at a fixed height,
                        // so its content sits in the middle of it. A
                        // multi-line one grows downwards from the top.
                        mainAxisAlignment: isMultiline
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          if (widget.top != null) widget.top!,
                          RawScrollbar(
                            thumbVisibility: isMultiline && isScrollable,
                            controller: effectiveScrollController,
                            padding: effectiveScrollbarPadding?.resolve(
                              Directionality.of(context),
                            ),
                            child: SingleChildScrollView(
                              controller: effectiveScrollController,
                              padding: effectivePadding,
                              physics: widget.scrollPhysics,
                              child: Row(
                                mainAxisAlignment: effectiveMainAxisAlignment,
                                crossAxisAlignment: effectiveCrossAxisAlignment,
                                children: [
                                  if (widget.leading != null) ...[
                                    widget.leading!,
                                    SizedBox(width: effectiveGap),
                                  ],
                                  Flexible(
                                    child: AbsorbPointer(
                                      // AbsorbPointer is needed when the input is
                                      // readOnly so the onTap callback is fired on
                                      // each part of the input
                                      absorbing: widget.readOnly,
                                      child: Padding(
                                        padding: effectiveInputPadding,
                                        child: Stack(
                                          children: [
                                            // placeholder. Scoped to its own
                                            // listener so typing rebuilds only
                                            // this subtree.
                                            if (widget.placeholder != null)
                                              Positioned.fill(
                                                child: ValueListenableBuilder(
                                                  valueListenable: _isEmpty,
                                                  builder: (context, isEmpty, _) {
                                                    if (!isEmpty) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    return Align(
                                                      alignment:
                                                          effectivePlaceholderAlignment,
                                                      child: DefaultTextStyle(
                                                        style:
                                                            effectivePlaceholderStyle,
                                                        child:
                                                            widget.placeholder!,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            RepaintBoundary(
                                              child: UnmanagedRestorationScope(
                                                bucket: bucket,
                                                child: Align(
                                                  alignment: effectiveAlignemnt,
                                                  child: editableText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (showClear)
                                    // Its gap comes and goes with it.
                                    ValueListenableBuilder(
                                      valueListenable: _isEmpty,
                                      builder: (context, isEmpty, child) =>
                                          PopIn(
                                            visible: !isEmpty,
                                            child: child!,
                                          ),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          start: effectiveGap,
                                        ),
                                        child: ExcludeFocus(
                                          child: _AdornmentButton(
                                            icon: PhosphorIconsRegular.x,
                                            semanticLabel: l.input.clear,
                                            extent: adornmentExtent,
                                            onPressed: clear,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (showReveal)
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        start: effectiveGap,
                                      ),
                                      child: _AdornmentButton(
                                        // The icon shows the state: a
                                        // crossed-out eye while the text is
                                        // hidden, an open one while it shows.
                                        icon: _obscured
                                            ? PhosphorIconsRegular.eyeSlash
                                            : PhosphorIconsRegular.eye,
                                        semanticLabel: l.input.showPassword,
                                        toggled: !_obscured,
                                        extent: adornmentExtent,
                                        onPressed: () => setState(
                                          () => _obscured = !_obscured,
                                        ),
                                      ),
                                    ),
                                  if (widget.trailing != null) ...[
                                    SizedBox(width: effectiveGap),
                                    widget.trailing!,
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (widget.showCounter)
                            _CounterRow(
                              controller: effectiveController,
                              maxLength: widget.maxLength,
                              padding: effectivePadding,
                              bottom: widget.bottom,
                            )
                          else if (widget.bottom != null)
                            widget.bottom!,
                        ].separatedBy(SizedBox(height: effectiveVerticalGap)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _InputSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _InputSelectionGestureDetectorBuilder({
    required TextFieldState state,
  }) : _state = state,
       super(delegate: state);

  final TextFieldState _state;

  @override
  void onForcePressStart(ForcePressDetails details) {
    super.onForcePressStart(details);
    if (delegate.selectionEnabled && shouldShowSelectionToolbar) {
      editableText.showToolbar();
    }
  }

  @override
  void onForcePressEnd(ForcePressDetails details) {
    // Not required.
  }

  @override
  void onUserTap() {
    _state.widget.onTap?.call();
  }

  @override
  bool get onUserTapAlwaysCalled => _state.widget.onTapAlwaysCalled;

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    super.onSingleLongTapStart(details);
    if (delegate.selectionEnabled) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          break;
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          Feedback.forLongPress(_state.context);
      }
    }
  }
}

/// A small ghost button at the end of a field: the clear button, the
/// password toggle.
///
/// It is a square the height of a line of the field's text, so it fits
/// inside the field's own height; the icon is drawn a little smaller.
class _AdornmentButton extends StatelessWidget {
  const _AdornmentButton({
    required this.icon,
    required this.semanticLabel,
    required this.extent,
    required this.onPressed,
    this.toggled,
  });

  final IconData icon;
  final String semanticLabel;
  final double extent;
  final VoidCallback onPressed;

  /// For a button that switches something on and off: whether it is on.
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    const radius = BorderRadius.all(Radius.circular(9999));
    return Semantics(
      toggled: toggled,
      child: Pressable(
        onPressed: onPressed,
        semanticLabel: semanticLabel,
        builder: (context, states) {
          final lit =
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed);
          return FocusRing(
            visible: states.contains(WidgetState.focused),
            borderRadius: radius,
            child: AnimatedFill(
              color: lit ? colors.muted : colors.muted.withValues(alpha: 0),
              borderWidth: 0,
              borderRadius: radius,
              child: SizedBox.square(
                dimension: extent,
                child: Center(
                  child: PhosphorIcon(
                    icon,
                    size: extent * .8,
                    color: lit ? colors.foreground : colors.mutedForeground,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The row under the text of a field with [TextField.showCounter]: the
/// field's own `bottom` widget, then the character count at the end.
class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.controller,
    required this.maxLength,
    required this.padding,
    required this.bottom,
  });

  final TextEditingController controller;
  final int? maxLength;
  final EdgeInsetsGeometry padding;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = UnaLocalizations.of(context);
    final resolved = padding.resolve(Directionality.of(context));
    final max = maxLength != null && maxLength! > 0 ? maxLength : null;
    final style = theme.textTheme.caption.copyWith(
      // Digits of one width: the count does not jiggle as it changes.
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: bottom ?? const SizedBox.shrink()),
        Padding(
          // The field's own inset: the count lines up with its text.
          padding: EdgeInsets.only(
            left: resolved.left,
            right: resolved.right,
            bottom: resolved.bottom,
          ),
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, _) {
              final count = value.text.characters.length;
              final atLimit = max != null && count >= max;
              final spoken = max == null
                  ? '$count'
                  : l.input.characterCount(count: count, max: max);
              return Semantics(
                // Announced when the limit is reached, not on every key.
                liveRegion: atLimit,
                label: atLimit ? '${l.input.characterLimit}. $spoken' : spoken,
                child: ExcludeSemantics(
                  child: Text(
                    max == null ? '$count' : '$count/$max',
                    style: atLimit
                        ? style.copyWith(color: theme.colorScheme.foreground)
                        : style,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
