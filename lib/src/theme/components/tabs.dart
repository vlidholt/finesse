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
    this.tabCursor,
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

  /// {@macro Tabs.gap}
  final double? gap;

  /// {@macro Tabs.tabsGap}
  final double? tabsGap;

  /// {@macro Tabs.expandTabs}
  final bool? expandTabs;

  /// {@macro Tabs.tabBarAlignment}
  final Alignment? tabBarAlignment;

  /// {@macro Tabs.dragStartBehavior}
  final DragStartBehavior? dragStartBehavior;

  /// {@macro Tabs.physics}
  final ScrollPhysics? physics;

  /// {@macro Tabs.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro Tabs.decoration}
  final FinesseDecoration? decoration;

  /// {@macro Tabs.tabBarConstraints}
  final BoxConstraints? tabBarConstraints;

  /// {@macro Tabs.contentConstraints}
  final BoxConstraints? contentConstraints;

  /// {@macro Tab.expand}
  final bool? expandContent;

  /// {@macro Tab.width}
  final double? tabWidth;

  /// {@macro Tab.backgroundColor}
  final Color? tabBackgroundColor;

  /// {@macro Tab.selectedBackgroundColor}
  final Color? tabSelectedBackgroundColor;

  /// {@macro Tab.hoverBackgroundColor}
  final Color? tabHoverBackgroundColor;

  /// {@macro Tab.selectedHoverBackgroundColor}
  final Color? tabSelectedHoverBackgroundColor;

  /// {@macro Tab.padding}
  final EdgeInsetsGeometry? tabPadding;

  /// {@macro Tab.decoration}
  final FinesseDecoration? tabDecoration;

  /// {@macro Tab.selectedDecoration}
  final FinesseDecoration? tabSelectedDecoration;

  /// {@macro Tab.foregroundColor}
  final Color? tabForegroundColor;

  /// {@macro Tab.selectedForegroundColor}
  final Color? tabSelectedForegroundColor;

  /// {@macro Tab.textStyle}
  final TextStyle? tabTextStyle;

  /// {@macro Tab.shadows}
  final List<BoxShadow>? tabShadows;

  /// {@macro Tab.selectedShadows}
  final List<BoxShadow>? tabSelectedShadows;

  /// {@macro Tab.size}
  final ButtonSize? tabSize;

  /// The height of each tab. A `Tab`'s own `height` wins; with neither, a tab
  /// is 32 logical pixels tall.
  final double? tabHeight;

  /// {@macro Tab.cursor}
  final MouseCursor? tabCursor;

  /// {@macro Tab.hoverForegroundColor}
  final Color? tabHoverForegroundColor;

  /// {@macro Tab.pressedBackgroundColor}
  final Color? tabPressedBackgroundColor;

  /// {@macro Tab.pressedForegroundColor}
  final Color? tabPressedForegroundColor;

  /// {@macro Tab.gradient}
  final Gradient? tabGradient;

  /// {@macro Tab.textDecoration}
  final TextDecoration? tabTextDecoration;

  /// {@macro Tab.hoverTextDecoration}
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
