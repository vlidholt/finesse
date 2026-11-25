import 'dart:ui' show ImageFilter;

import 'package:finesse/src/liquid_glass/liquid_glass_theme.dart';
import 'package:finesse/src/utils/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'dialog.g.theme.dart';

/// {@template DialogTheme}
/// Theme for the `Dialog` widget.
/// {@endtemplate}
@themeGen
@immutable
class DialogTheme with _$DialogTheme {
  /// {@macro DialogTheme}
  const DialogTheme({
    bool canMerge = true,
    this.liquidGlass,
    this.showCloseButton,
    this.closeIcon,
    this.closeIconPosition,
    this.borderRadius,
    this.backgroundColor,
    this.padding,
    this.gap,
    this.constraints,
    this.border,
    this.shadows,
    this.filter,
    this.actionsAxis,
    this.actionsMainAxisSize,
    this.actionsMainAxisAlignment,
    this.actionsVerticalDirection,
    this.titleStyle,
    this.descriptionStyle,
    this.titleTextAlign,
    this.descriptionTextAlign,
    this.alignment,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.scrollable,
    this.scrollPadding,
    this.actionsGap,
    this.useSafeArea,
    this.titlePinned,
    this.descriptionPinned,
    this.actionsPinned,
    this.barrierColor,
    this.barrierBlurSigma,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// Whether dialogs draw with Liquid Glass, over
  /// `ThemeData.liquidGlass.mode`; null follows the theme.
  final LiquidGlassMode? liquidGlass;

  /// {@macro Dialog.showCloseButton}
  final bool? showCloseButton;

  /// {@macro Dialog.closeIcon}
  ///
  /// A theme is compared on every rebuild, so a widget given here has to be
  /// a constant.
  final Widget? closeIcon;

  /// The position of the close icon within the dialog.
  /// Defaults to top-end (8, 8) if not specified.
  final Position? closeIconPosition;

  /// The border radius of the dialog’s corners.
  /// Defaults to the theme’s radius if not specified.
  final BorderRadius? borderRadius;

  /// The background color of the dialog.
  /// Defaults to the theme’s background color if not specified.
  final Color? backgroundColor;

  /// The padding inside the dialog, surrounding all content.
  /// Defaults to EdgeInsets.all(24) if not specified.
  final EdgeInsetsGeometry? padding;

  /// The gap between content elements (title, description, child, actions).
  /// Defaults to 8 if not specified.
  final double? gap;

  /// Constraints applied to the dialog’s layout.
  /// Defaults to a max width of 512 if not specified.
  final BoxConstraints? constraints;

  /// The axis along which actions are arranged (horizontal or vertical).
  /// Follows the theme's form factor if not specified.
  final Axis? actionsAxis;

  /// The main axis size of the actions layout.
  /// Defaults to [MainAxisSize.max] if not specified.
  final MainAxisSize? actionsMainAxisSize;

  /// The main axis alignment of the actions.
  /// Defaults to [MainAxisAlignment.end] if not specified.
  final MainAxisAlignment? actionsMainAxisAlignment;

  /// The vertical direction of the actions layout when vertical.
  /// Follows the theme's form factor if not specified.
  final VerticalDirection? actionsVerticalDirection;

  /// The border surrounding the dialog.
  /// Defaults to a border with the theme’s border color if not specified.
  final BoxBorder? border;

  /// The list of box shadows applied to the dialog for elevation.
  /// Defaults to large shadows if not specified.
  final List<BoxShadow>? shadows;

  /// A filter applied to what is behind the dialog, for a translucent
  /// [backgroundColor]: the blur of a glass surface. Null, the default,
  /// applies none.
  final ImageFilter? filter;

  /// The text style for the title.
  /// Defaults to the theme’s large text style if not specified.
  final TextStyle? titleStyle;

  /// The text style for the description.
  /// Defaults to the theme’s muted text style if not specified.
  final TextStyle? descriptionStyle;

  /// The text alignment for the title.
  /// Follows the theme's form factor if not specified.
  final TextAlign? titleTextAlign;

  /// The text alignment for the description.
  /// Follows the theme's form factor if not specified.
  final TextAlign? descriptionTextAlign;

  /// The alignment of the dialog within its parent container.
  /// Defaults to [Alignment.center] if not specified.
  final Alignment? alignment;

  /// The main axis alignment of the dialog’s column content.
  /// Defaults to [MainAxisAlignment.start] if not specified.
  final MainAxisAlignment? mainAxisAlignment;

  /// The cross axis alignment of the dialog’s column content.
  /// Defaults to [CrossAxisAlignment.start] if not specified.
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Dialog.scrollable}
  final bool? scrollable;

  /// The padding applied when the dialog content is scrollable.
  ///
  /// If not specified, no additional padding is applied to the scrollable
  /// content.
  final EdgeInsetsGeometry? scrollPadding;

  /// The gap between action buttons.

  /// Defaults to 8 if not specified.
  final double? actionsGap;

  /// {@macro Dialog.useSafeArea}
  final bool? useSafeArea;

  /// {@macro Dialog.titlePinned}
  final bool? titlePinned;

  /// {@macro Dialog.descriptionPinned}
  final bool? descriptionPinned;

  /// {@macro Dialog.actionsPinned}
  final bool? actionsPinned;

  /// The colour of the barrier behind the dialog. Defaults to shadcn's
  /// `bg-black/10`, which reads because the barrier is also blurred.
  final Color? barrierColor;

  /// {@macro Dialog.barrierBlurSigma}
  final double? barrierBlurSigma;

  /// Linearly interpolates between [a] and [b] by [t].
  static DialogTheme? lerp(
    DialogTheme? a,
    DialogTheme? b,
    double t,
  ) => _$DialogTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is DialogTheme &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(shadows ?? const []),
  );
}
