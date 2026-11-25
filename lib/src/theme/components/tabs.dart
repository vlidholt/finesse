import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/motion.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:theme_extensions_builder_annotation/theme_extensions_builder_annotation.dart';

part 'tabs.g.theme.dart';

/// {@template TabsTheme}
/// Theme for the `Tabs` widget.
/// {@endtemplate}
@themeGen
@immutable
class TabsTheme with _$TabsTheme {
  /// {@macro TabsTheme}
  const TabsTheme({
    bool canMerge = true,
    this.gap,
    this.tabsGap,
    this.expandTabs,
    this.tabBarAlignment,
    this.dragStartBehavior,
    this.physics,
    this.padding,
    this.decoration,
    this.tabBarConstraints,
    this.contentConstraints,
    this.expandContent,
    this.tabWidth,
    this.tabBackgroundColor,
    this.tabSelectedBackgroundColor,
    this.tabHoverBackgroundColor,
    this.tabSelectedHoverBackgroundColor,
    this.tabPadding,
    this.tabDecoration,
    this.tabSelectedDecoration,
    this.tabForegroundColor,
    this.tabSelectedForegroundColor,
    this.tabTextStyle,
    this.tabShadows,
    this.tabSelectedShadows,
    this.tabSize,
    this.tabHeight,
    this.tabMouseCursor,
    this.tabHoverForegroundColor,
    this.tabPressedBackgroundColor,
    this.tabPressedForegroundColor,
    this.tabGradient,
    this.tabTextDecoration,
    this.tabHoverTextDecoration,
    this.tabMainAxisAlignment,
    this.tabCrossAxisAlignment,
    this.tabHoverStrategies,
    this.longPressDuration,
    this.indicatorSpring,
    this.indicatorStretch,
    this.contentTransitionDuration,
    this.contentTransitionOffset,
    this.underlineHeight,
    this.underlinePadding,
    this.underlineTextStyle,
    this.underlineColor,
  }) : _canMerge = canMerge;

  @ignore
  final bool _canMerge;

  @override
  bool get canMerge => _canMerge;

  /// The gap between the tab bar and the content under it in a `Tabs`.
  final double? gap;

  /// The gap between two tabs of a segmented strip.
  final double? tabsGap;

  /// Whether the tabs of a segmented strip share its full width. Defaults
  /// to false: a tab is as wide as its label plus its padding, and the strip
  /// as wide as its tabs.
  final bool? expandTabs;

  /// Where a segmented strip sits in a place wider than it. Defaults to the
  /// start.
  final Alignment? tabBarAlignment;

  /// When a drag of a scrolling strip is taken to start. Defaults to
  /// [DragStartBehavior.start].
  final DragStartBehavior? dragStartBehavior;

  /// The scroll physics of a strip that scrolls.
  final ScrollPhysics? physics;

  /// The padding of a segmented strip, between its edge and its tabs.
  final EdgeInsetsGeometry? padding;

  /// The decoration of a segmented strip: its fill and corners.
  final FinesseDecoration? decoration;

  /// Constraints on the row of tabs in a segmented strip.
  final BoxConstraints? tabBarConstraints;

  /// Constraints on the content under the bar of a `Tabs`.
  final BoxConstraints? contentConstraints;

  /// Whether the content of a `Tabs` fills the height left under its bar.
  /// Defaults to false: the content is as tall as it needs to be.
  final bool? expandContent;

  /// The width of each tab of a segmented strip. By default a tab is as
  /// wide as its content, or shares the strip's width when the tabs expand.
  final double? tabWidth;

  /// The fill of a tab that is not selected. Defaults to none.
  final Color? tabBackgroundColor;

  /// The fill of the pill on the selected tab.
  final Color? tabSelectedBackgroundColor;

  /// The fill of a hovered tab that is not selected.
  final Color? tabHoverBackgroundColor;

  /// The fill of the selected tab while it is hovered.
  final Color? tabSelectedHoverBackgroundColor;

  /// The padding inside a tab of a segmented strip.
  final EdgeInsetsGeometry? tabPadding;

  /// The decoration of a tab of a segmented strip: its corners and focus
  /// ring.
  final FinesseDecoration? tabDecoration;

  /// The decoration of the selected tab. Defaults to [tabDecoration].
  final FinesseDecoration? tabSelectedDecoration;

  /// The colour of the label and icons of a tab that is not selected.
  final Color? tabForegroundColor;

  /// The colour of the selected tab's label and icons.
  final Color? tabSelectedForegroundColor;

  /// The style of a segmented tab's label.
  final TextStyle? tabTextStyle;

  /// The shadows of a tab that is not selected.
  final List<BoxShadow>? tabShadows;

  /// The shadows of the pill on the selected tab.
  final List<BoxShadow>? tabSelectedShadows;

  /// The button size a segmented tab is built at.
  final ButtonSize? tabSize;

  /// The height of each tab. A `Tab`'s own `height` wins; with neither, a tab
  /// is 32 logical pixels tall.
  final double? tabHeight;

  /// The mouse cursor over a tab.
  final MouseCursor? tabMouseCursor;

  /// The colour of a hovered tab's label and icons.
  final Color? tabHoverForegroundColor;

  /// The fill of a tab while it is pressed.
  final Color? tabPressedBackgroundColor;

  /// The colour of a tab's label and icons while it is pressed.
  final Color? tabPressedForegroundColor;

  /// A gradient that fills a tab in place of its fill colour.
  final Gradient? tabGradient;

  /// The decoration of a tab's label, such as an underline.
  final TextDecoration? tabTextDecoration;

  /// The decoration of a hovered tab's label.
  final TextDecoration? tabHoverTextDecoration;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? tabMainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? tabCrossAxisAlignment;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? tabHoverStrategies;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@template TabsTheme.indicatorSpring}
  /// The spring the selection indicator travels between tabs with. Defaults
  /// to the theme's `Motion.snappy`; `MotionSpring.instant` moves it at once.
  /// {@endtemplate}
  final MotionSpring? indicatorSpring;

  /// {@template TabsTheme.indicatorStretch}
  /// How far the selection indicator stretches while it travels; see
  /// `MovingIndicator.stretch`. Defaults to the theme's
  /// `Motion.indicatorStretch`.
  /// {@endtemplate}
  final double? indicatorStretch;

  /// {@template TabsTheme.contentTransitionDuration}
  /// How long a tab's content takes to fade in when the tab is selected.
  /// Defaults to the theme's `Motion.normal`; `Duration.zero` swaps the
  /// content at once.
  /// {@endtemplate}
  final Duration? contentTransitionDuration;

  /// {@template TabsTheme.contentTransitionOffset}
  /// How far, in logical pixels, a tab's content slides in from the side its
  /// tab is on. Defaults to twice the theme's `Motion.overlayTravel`; 0 leaves
  /// a plain fade.
  /// {@endtemplate}
  final double? contentTransitionOffset;

  /// The height of an underline tab (`TabBarVariant.underline`), not
  /// counting the hairline under the row. Defaults to the style's
  /// `underlineTabHeight`.
  final double? underlineHeight;

  /// The padding around an underline tab's label. Defaults to 4 on each
  /// side for tabs that share the width and 16 for tabs that hug their
  /// label.
  final EdgeInsetsGeometry? underlinePadding;

  /// The style of an underline tab's label; weight and colour are set per
  /// tab on top of it. Defaults to the text theme's `large`.
  final TextStyle? underlineTextStyle;

  /// The colour of the line under the selected underline tab. Defaults to
  /// the foreground colour.
  final Color? underlineColor;

  /// Linearly interpolates between [a] and [b] by [t].
  static TabsTheme? lerp(
    TabsTheme? a,
    TabsTheme? b,
    double t,
  ) => _$TabsTheme.lerp(a, b, t);

  // The generated `==` compares lists by identity, so a theme built with a
  // non-const list would never equal its own rebuild, and AnimatedTheme
  // would re-lerp on every frame. Compare the lists by value, then let the
  // generated `==` compare everything else against a copy that shares them.
  @override
  bool operator ==(Object other) =>
      other is TabsTheme &&
      listEquals(tabShadows, other.tabShadows) &&
      listEquals(tabSelectedShadows, other.tabSelectedShadows) &&
      super ==
          other.copyWith(
            tabShadows: tabShadows,
            tabSelectedShadows: tabSelectedShadows,
          );

  // Equal themes must hash alike, and the lists may differ in identity.
  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(tabShadows ?? const []),
    Object.hashAll(tabSelectedShadows ?? const []),
  );
}
