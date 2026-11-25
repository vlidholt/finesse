import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'text_selection.g.theme.dart';

/// The theme of text selection on a touch screen: the drag handles at the
/// ends of a selection, the toolbar over it and the magnifier shown while a
/// handle or the caret is dragged.
///
/// It is read by `FinesseTextSelectionControls`, `TextSelectionToolbar` and
/// `TextMagnifier`, and so by every `TextField`, `Textarea` and
/// `SelectionArea`.
@themeGen
@immutable
class TextSelectionTheme with _$TextSelectionTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const TextSelectionTheme({
    bool canMerge = true,
    this.handleColor,
    this.handleSize,
    this.handleStemWidth,
    this.toolbarHeight,
    this.toolbarDecoration,
    this.toolbarItemPadding,
    this.toolbarTextStyle,
    this.toolbarDividerColor,
    this.toolbarPressedColor,
    this.toolbarGap,
    this.magnifierSize,
    this.magnifierScale,
    this.magnifierBorderRadius,
    this.magnifierBorderColor,
    this.magnifierShadows,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The colour of the drag handles. The variant uses the scheme's tint.
  final Color? handleColor;

  /// The diameter of a handle's dot.
  final double? handleSize;

  /// The width of the stem that joins a handle's dot to the selection.
  final double? handleStemWidth;

  /// The height of the selection toolbar, at a text scale of 1.
  final double? toolbarHeight;

  /// Merged over the menu surface the selection toolbar is drawn on.
  final FinesseDecoration? toolbarDecoration;

  /// The padding around the label of a toolbar button.
  final EdgeInsetsGeometry? toolbarItemPadding;

  /// The text style of a toolbar button.
  final TextStyle? toolbarTextStyle;

  /// The colour of the hairlines between toolbar buttons.
  final Color? toolbarDividerColor;

  /// The fill of a toolbar button while it is pressed or hovered.
  final Color? toolbarPressedColor;

  /// The distance between the selection and the toolbar.
  final double? toolbarGap;

  /// The size of the magnifier's lens.
  final Size? magnifierSize;

  /// How much the magnifier enlarges what is under it; 1 is not at all.
  final double? magnifierScale;

  /// The corner radius of the magnifier. The variant rounds it fully.
  final BorderRadius? magnifierBorderRadius;

  /// The colour of the hairline around the magnifier.
  final Color? magnifierBorderColor;

  /// The shadows the magnifier casts.
  final List<BoxShadow>? magnifierShadows;

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild. Compare the list by
  // value, then let the generated `==` compare everything else against a
  // copy that shares it.
  @override
  bool operator ==(Object other) =>
      other is TextSelectionTheme &&
      listEquals(magnifierShadows, other.magnifierShadows) &&
      super == other.copyWith(magnifierShadows: magnifierShadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    handleColor,
    toolbarHeight,
    Object.hashAll(magnifierShadows ?? const []),
  );

  /// Linearly interpolates between two themes.
  static TextSelectionTheme? lerp(
    TextSelectionTheme? a,
    TextSelectionTheme? b,
    double t,
  ) => _$TextSelectionTheme.lerp(a, b, t);
}
