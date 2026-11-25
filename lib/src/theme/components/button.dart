import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/button_sizes.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'button.g.theme.dart';

/// How a `Button` looks: its colours in each state, its decoration, its
/// metrics and its press response.
///
/// It is used in two places. `ThemeData` holds one per variant
/// (`primaryButtonTheme`, `outlineButtonTheme`, …), which is how a theme
/// restyles every button of that variant. And `Button.style`,
/// `IconButton.style` and the widgets built from them take one to restyle a
/// single button: it is merged over the variant's theme, so only the fields
/// that are set change anything.
///
/// ```dart
/// Button(
///   style: ButtonTheme(
///     backgroundColor: scheme.success,
///     hoverBackgroundColor: scheme.success.withValues(alpha: .9),
///     padding: const EdgeInsets.symmetric(horizontal: 24),
///   ),
///   onPressed: _confirm,
///   child: const Text('Confirm'),
/// )
/// ```
@themeGen
@immutable
class ButtonTheme with _$ButtonTheme {
  /// Creates a [ButtonTheme].
  const ButtonTheme({
    bool canMerge = true,
    this.mouseCursor,
    this.size,
    this.sizesTheme,
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.foregroundColor,
    this.hoverForegroundColor,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.shadows,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.decoration,
    this.width,
    this.height,
    this.padding,
    this.iconSize,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.gap,
    this.expands,
    this.pressedOffset,
    this.pressAnimationDuration,
    this.pressScale,
    this.transitionDuration,
    this.textStyle,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The cursor over an enabled button. Defaults to
  /// [SystemMouseCursors.click].
  final MouseCursor? mouseCursor;

  /// The size a button takes its metrics from when it is not given one.
  /// Defaults to [ButtonSize.regular].
  final ButtonSize? size;

  /// The metrics of each size, in place of the theme-wide
  /// `ThemeData.buttonSizesTheme`.
  final ButtonSizesTheme? sizesTheme;

  /// {@template Button.backgroundColor}
  /// The fill at rest. Null paints none.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Button.hoverBackgroundColor}
  /// The fill while the button is hovered or held.
  /// {@endtemplate}
  final Color? hoverBackgroundColor;

  /// {@template Button.foregroundColor}
  /// The colour of the label and icons at rest.
  /// {@endtemplate}
  final Color? foregroundColor;

  /// {@template Button.hoverForegroundColor}
  /// The colour of the label and icons while the button is hovered or held.
  /// {@endtemplate}
  final Color? hoverForegroundColor;

  /// {@template Button.pressedBackgroundColor}
  /// The fill while the button is held. Null, the default, keeps
  /// [hoverBackgroundColor].
  /// {@endtemplate}
  final Color? pressedBackgroundColor;

  /// {@template Button.pressedForegroundColor}
  /// The colour of the label and icons while the button is held. Null, the
  /// default, keeps [hoverForegroundColor].
  /// {@endtemplate}
  final Color? pressedForegroundColor;

  /// {@template Button.shadows}
  /// The shadows around the button. They are clipped to outside its
  /// outline, so a translucent fill stays clean.
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Button.gradient}
  /// A gradient painted over the fill.
  /// {@endtemplate}
  final Gradient? gradient;

  /// {@template Button.textDecoration}
  /// The decoration of the label at rest: an underline, for a link.
  /// {@endtemplate}
  final TextDecoration? textDecoration;

  /// {@template Button.hoverTextDecoration}
  /// The decoration of the label while the button is hovered or held.
  /// {@endtemplate}
  final TextDecoration? hoverTextDecoration;

  /// {@template Button.decoration}
  /// The border, corners and focus treatment. A style override is merged
  /// into the variant's, so one that only changes the corners keeps the
  /// rest.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Button.width}
  /// A fixed width. Null, the default, takes the size's — a text button's
  /// is as wide as its content.
  /// {@endtemplate}
  final double? width;

  /// {@template Button.height}
  /// The height, in place of the size's. It is a floor once text is
  /// scaled up: the button grows to keep its label whole.
  /// {@endtemplate}
  final double? height;

  /// {@template Button.padding}
  /// The padding around the content, in place of the size's.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Button.iconSize}
  /// The size handed to icons that do not set one themselves, in place of
  /// the size's. An `Icon` with its own `size` is left alone.
  /// {@endtemplate}
  final double? iconSize;

  /// {@template Button.mainAxisAlignment}
  /// How the content is placed along the button when it is wider than its
  /// content. Defaults to [MainAxisAlignment.center].
  /// {@endtemplate}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@template Button.crossAxisAlignment}
  /// How the content is placed across the button. Defaults to
  /// [CrossAxisAlignment.center].
  /// {@endtemplate}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@template Button.gap}
  /// The space between the leading widget, the label and the trailing
  /// widget. Defaults to 8.
  /// {@endtemplate}
  final double? gap;

  /// Whether the label takes all the room the button has, pushing the
  /// leading and trailing widgets to its ends. Defaults to false.
  final bool? expands;

  /// {@template ButtonTheme.pressedOffset}
  /// How far the button shifts while pressed, in logical pixels.
  ///
  /// shadcn/ui nudges a button down by one pixel on `:active`
  /// (`active:translate-y-px`); this is the same effect. Defaults to
  /// `Offset(0, 1)`. Use [Offset.zero] to disable it.
  /// {@endtemplate}
  final Offset? pressedOffset;

  /// {@template ButtonTheme.pressAnimationDuration}
  /// How long the [pressedOffset] shift takes, defaults to 100ms.
  /// {@endtemplate}
  final Duration? pressAnimationDuration;

  /// {@template ButtonTheme.pressScale}
  /// The scale of the button while it is pressed: a paint-time transform that
  /// springs back on release and never changes the layout. Defaults to the
  /// theme's `Motion.pressScale`; 1 disables it, which is what a button
  /// used as a row — a menu item, a calendar day — passes.
  /// {@endtemplate}
  final double? pressScale;

  /// {@template ButtonTheme.transitionDuration}
  /// How long the background and foreground colours take to change between
  /// the idle, hovered and pressed states. Defaults to the theme's
  /// `Motion.fast`; `Duration.zero` changes them at once, which is what a
  /// row whose highlight follows the pointer — a menu item — passes.
  /// {@endtemplate}
  final Duration? transitionDuration;

  /// {@template Button.textStyle}
  /// The text style of the label. Its colour comes from [foregroundColor].
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// Linearly interpolates between [a] and [b] by [t].
  static ButtonTheme? lerp(
    ButtonTheme? a,
    ButtonTheme? b,
    double t,
  ) {
    return _$ButtonTheme.lerp(a, b, t);
  }

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is ButtonTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
