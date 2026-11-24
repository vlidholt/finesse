import 'dart:ui';

import 'package:finesse/src/raw_components/portal.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'select.g.theme.dart';

/// {@template SelectTheme}
/// Theme for the `Select` widget.
/// {@endtemplate}
@themeGen
@immutable
class SelectTheme with _$SelectTheme {
  /// {@macro SelectTheme}
  const SelectTheme({
    bool canMerge = true,
    this.decoration,
    this.placeholderStyle,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.minHeight,
    this.padding,
    this.optionsPadding,
    this.showScrollToTopChevron,
    this.showScrollToBottomChevron,
    this.anchor,
    this.searchPadding,
    this.clearSearchOnClose,
    this.effects,
    this.shadows,
    this.filter,
    this.popoverReverseDuration,
    this.popoverDecoration,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// {@macro Popover.reverseDuration}
  final Duration? popoverReverseDuration;

  /// {@macro Select.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Select.placeholderStyle}
  final TextStyle? placeholderStyle;

  /// {@macro Select.minWidth}
  final double? minWidth;

  /// {@macro Select.maxWidth}
  final double? maxWidth;

  /// {@macro Select.maxHeight}
  final double? maxHeight;

  /// {@macro Select.minHeight}
  final double? minHeight;

  /// {@macro Select.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Select.optionsPadding}
  final EdgeInsetsGeometry? optionsPadding;

  /// {@macro Select.showScrollToTopChevron}
  final bool? showScrollToTopChevron;

  /// {@macro Select.showScrollToBottomChevron}
  final bool? showScrollToBottomChevron;

  /// {@macro Select.anchor}
  final AnchorBase? anchor;

  /// {@macro Select.searchPadding}
  final EdgeInsetsGeometry? searchPadding;

  /// {@macro Select.clearSearchOnClose}
  final bool? clearSearchOnClose;

  /// {@macro Popover.filter}
  final ImageFilter? filter;

  /// The decoration of the options popover, as opposed to [decoration] which
  /// styles the trigger. Menus can carry their own palette (see
  /// `ThemeData.menuColorScheme`), so the options surface cannot simply
  /// fall back to the page's `PopoverTheme`.
  final FinesseDecoration? popoverDecoration;

  /// {@macro Popover.effects}
  final List<Effect<dynamic>>? effects;

  /// {@macro Popover.shadows}
  final List<BoxShadow>? shadows;

  /// Linearly interpolates between [a] and [b] by [t].
  static SelectTheme? lerp(
    SelectTheme? a,
    SelectTheme? b,
    double t,
  ) => _$SelectTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is SelectTheme &&
      listEquals(effects, other.effects) &&
      listEquals(shadows, other.shadows) &&
      super == other.copyWith(effects: effects, shadows: shadows);

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(effects ?? const []),
    Object.hashAll(shadows ?? const []),
  );
}
