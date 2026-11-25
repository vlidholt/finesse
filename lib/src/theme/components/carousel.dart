import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'carousel.g.theme.dart';

/// The theme of `Carousel` and `PageIndicator`: every value the widgets do
/// not set themselves.
@themeGen
@immutable
class CarouselTheme with _$CarouselTheme {
  /// Creates a theme; a null field falls back to the app theme's.
  const CarouselTheme({
    bool canMerge = true,
    this.spacing,
    this.arrowSize,
    this.arrowIconSize,
    this.arrowInset,
    this.arrowColor,
    this.arrowHoverColor,
    this.arrowForegroundColor,
    this.arrowBorderColor,
    this.indicatorInset,
    this.dotSize,
    this.activeDotExtent,
    this.dotSpacing,
    this.dotColor,
    this.activeDotColor,
    this.overlayColor,
    this.overlayDotColor,
    this.overlayActiveDotColor,
    this.overlayPadding,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The gap between two pages of a carousel that shows more than one.
  final double? spacing;

  /// The diameter of a carousel's previous and next buttons.
  final double? arrowSize;

  /// The size of the caret in an arrow button.
  final double? arrowIconSize;

  /// The gap between an arrow button and the carousel's edge.
  final double? arrowInset;

  /// The fill of an arrow button.
  final Color? arrowColor;

  /// The fill of an arrow button under the pointer.
  final Color? arrowHoverColor;

  /// The colour of an arrow button's caret.
  final Color? arrowForegroundColor;

  /// The colour of an arrow button's hairline outline.
  final Color? arrowBorderColor;

  /// The gap between a carousel's own indicator and its bottom edge.
  final double? indicatorInset;

  /// The diameter of a page indicator's dot.
  final double? dotSize;

  /// The length of the pill that marks the current page.
  final double? activeDotExtent;

  /// The gap between two dots.
  final double? dotSpacing;

  /// The colour of the dots of the other pages.
  final Color? dotColor;

  /// The colour of the current page's pill.
  final Color? activeDotColor;

  /// The fill of the capsule an indicator sits on over a photograph.
  final Color? overlayColor;

  /// The colour of the other pages' dots over a photograph.
  final Color? overlayDotColor;

  /// The colour of the current page's pill over a photograph.
  final Color? overlayActiveDotColor;

  /// The padding of the capsule around the dots over a photograph.
  final EdgeInsetsGeometry? overlayPadding;

  /// Linearly interpolates between two themes.
  static CarouselTheme? lerp(CarouselTheme? a, CarouselTheme? b, double t) =>
      _$CarouselTheme.lerp(a, b, t);
}
