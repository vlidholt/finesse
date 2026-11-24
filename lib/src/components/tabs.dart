import 'dart:math' as math;

import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:finesse/src/theme/themes/shadows.dart';
import 'package:finesse/src/utils/border.dart';
import 'package:finesse/src/utils/gesture_detector.dart';
import 'package:finesse/src/utils/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A controller for [Tabs] to manage tab selection.
///
/// Extends [ChangeNotifier] to provide reactive updates when the selected tab
/// changes.
class TabsController<T> extends ChangeNotifier {
  /// Creates a [TabsController] with an initial selected value.
  TabsController({required T value}) : _selected = value;

  T _selected;

  /// The selected tab's value. Setting it selects that tab, as [select] does.
  T get selected => _selected;
  set selected(T value) => select(value);

  /// Selects the given [value].
  ///
  /// Returns true if the value was changed, false otherwise.
  bool select(T value) {
    if (value == _selected) return false;
    _selected = value;
    notifyListeners();
    return true;
  }
}

/// A restorable version of [TabsController] for state persistence.
///
/// Useful for maintaining tab selection across widget rebuilds and state
/// restoration.
class RestorableTabsController<T>
    extends RestorableChangeNotifier<TabsController<T>> {
  /// Creates a [RestorableTabsController].
  factory RestorableTabsController({required T value}) =>
      RestorableTabsController.fromValue(value);

  /// Creates a [RestorableTabsController] from a given value.
  RestorableTabsController.fromValue(T value) : selected = value;

  /// The value used to create the default controller and saved for state
  /// restoration.
  ///
  /// It is the initial value. Selecting another tab does not change it.
  T selected;

  @override
  TabsController<T> createDefaultValue() {
    return TabsController<T>(value: selected);
  }

  @override
  TabsController<T> fromPrimitives(Object? data) {
    return TabsController<T>(value: data! as T);
  }

  @override
  Object? toPrimitives() {
    // The live selection; `selected` is only the initial value, so
    // restoration always brought back the first tab.
    return value.selected;
  }
}

/// {@template Tabs}
/// A widget that displays a horizontal series of tabs with associated content.
///
/// When no [Tab] has `content`, only the tab list is shown, with no gap
/// below it. That is the standalone tabs list, or segmented control, that
/// switches something elsewhere on the page through `onChanged`.
///
/// Supports scrollable and non-scrollable layouts, custom styling, and state
/// management.
/// {@endtemplate}
class Tabs<T> extends StatefulWidget implements PreferredSizeWidget {
  /// {@macro Tabs}
  const Tabs({
    super.key,
    this.value,
    required this.tabs,
    this.controller,
    this.tabBarAlignment,
    this.tabsGap,
    this.expandTabs,
    this.gap,
    this.scrollable,
    this.dragStartBehavior,
    this.physics,
    this.padding,
    this.decoration,
    this.tabBarConstraints,
    this.contentConstraints,
    this.restorationId,
    this.onChanged,
    this.maintainState,
  }) : assert(
         (value != null) ^ (controller != null),
         'Either value or controller must be provided',
       );

  /// {@template Tabs.value}
  /// The currently selected tab.
  /// {@endtemplate}
  final T? value;

  /// {@template Tabs.tabs}
  /// The tabs to display.
  /// {@endtemplate}
  final List<Tab<T>> tabs;

  /// {@template Tabs.controller}
  /// The controller of the tabs.
  /// {@endtemplate}
  final TabsController<T>? controller;

  /// {@template Tabs.expandTabs}
  /// Whether the tabs share the full width of the bar.
  ///
  /// Defaults to false, matching shadcn/ui's `w-fit` list: a tab is as wide as
  /// its label plus its padding, and the bar is as wide as its tabs.
  /// {@endtemplate}
  final bool? expandTabs;

  /// {@template Tabs.tabsGap}
  /// The horizontal gap between the tabs in the tabBar.
  /// {@endtemplate}
  final double? tabsGap;

  /// {@template Tabs.tabBarAlignment}
  /// The alignment of the tabBar.
  /// {@endtemplate}
  final Alignment? tabBarAlignment;

  /// {@template Tabs.gap}
  /// The gap between the tabBar and the content.
  /// {@endtemplate}
  final double? gap;

  /// {@template Tabs.scrollable}
  /// Whether the tabs should be scrollable, defaults to false.
  /// {@endtemplate}
  final bool? scrollable;

  /// {@template Tabs.dragStartBehavior}
  /// The drag start behavior of the tabs, defaults to [DragStartBehavior.start]
  /// {@endtemplate}
  final DragStartBehavior? dragStartBehavior;

  /// {@template Tabs.physics}
  /// The physics of the tabs, defaults to null.
  /// {@endtemplate}
  final ScrollPhysics? physics;

  /// {@template Tabs.padding}
  /// The padding of the tabs, defaults to `EdgeInsets.zero`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Tabs.decoration}
  /// The decoration of the tabs.
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Tabs.tabBarConstraints}
  /// The constraints of the tab bar, defaults to `null`.
  /// {@endtemplate}
  final BoxConstraints? tabBarConstraints;

  /// {@template Tabs.contentConstraints}
  /// The constraints of the content, defaults to `null`.
  /// {@endtemplate}
  final BoxConstraints? contentConstraints;

  /// {@template Tabs.restorationId}
  /// The restoration id, defaults to `null`.
  /// {@endtemplate}
  final String? restorationId;

  /// {@template Tabs.onChanged}
  /// The callback that is called when the value of the tabs changes.
  /// {@endtemplate}
  final ValueChanged<T>? onChanged;

  /// {@template Tabs.maintainState}
  /// Whether to maintain the state of the tabs when switching between them.
  /// Defaults to true.
  /// {@endtemplate}
  final bool? maintainState;

  @override
  State<Tabs<T>> createState() => TabsState<T>();

  @override
  Size get preferredSize {
    var maxHeight = 0.0;
    for (final tab in tabs) {
      final itemHeight = tab.preferredSize.height;
      maxHeight = math.max(itemHeight, maxHeight);
    }
    return Size.fromHeight(maxHeight);
  }
}

/// The state of a [Tabs].
class TabsState<T> extends State<Tabs<T>> with RestorationMixin {
  late List<GlobalKey> _tabKeys;

  /// The values of the tabs, in the order of [Tabs.tabs].
  @protected
  late List<T> orderedValues;

  RestorableTabsController<T>? _controller;

  /// The controller in use: [Tabs.controller], or an internal restorable
  /// one when that is null.
  TabsController<T> get controller => widget.controller ?? _controller!.value;

  /// Scrolls the tab list when [scrollable] is true.
  @protected
  late final scrollController = ScrollController();

  /// Whether the tabs share the full width of the bar.
  bool expandTabs(BuildContext context) =>
      widget.expandTabs ?? Theme.of(context).tabsTheme.expandTabs ?? false;

  /// Whether the tab list scrolls horizontally. Defaults to false.
  bool get scrollable => widget.scrollable ?? false;

  @override
  void initState() {
    super.initState();
    _tabKeys = widget.tabs.map((_) => GlobalKey()).toList();
    if (widget.controller == null) {
      _createLocalController(widget.value as T);
    }
    orderedValues = widget.tabs.map((e) => e.value).toList();
  }

  @override
  void didUpdateWidget(covariant Tabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.selected);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    if (widget.tabs.length > _tabKeys.length) {
      final delta = widget.tabs.length - _tabKeys.length;
      _tabKeys.addAll(List<GlobalKey>.generate(delta, (int n) => GlobalKey()));
    } else if (widget.tabs.length < _tabKeys.length) {
      _tabKeys.removeRange(widget.tabs.length, _tabKeys.length);
    }
    if (!listEquals(widget.tabs, oldWidget.tabs)) {
      orderedValues = widget.tabs.map((e) => e.value).toList();
    }

    // Update the controller if the value has changed.
    if (widget.value is T &&
        widget.controller == null &&
        controller.selected != widget.value) {
      controller.select(widget.value as T);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController(T value) {
    assert(_controller == null);
    _controller = RestorableTabsController<T>.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) _registerController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabsTheme = theme.tabsTheme;

    final effectiveDragStartBehavior =
        widget.dragStartBehavior ??
        tabsTheme.dragStartBehavior ??
        DragStartBehavior.start;

    final effectivePadding =
        widget.padding ?? tabsTheme.padding ?? EdgeInsets.zero;

    final effectiveDecoration = FinesseDecoration(
      color: theme.colorScheme.muted,
      border: FinesseBorder.all(radius: theme.radius, width: 0),
    ).merge(tabsTheme.decoration).merge(widget.decoration);

    final effectiveGap = widget.gap ?? tabsTheme.gap ?? 8;

    final effectiveTabBarConstraints =
        widget.tabBarConstraints ?? tabsTheme.tabBarConstraints;

    final effectiveContentConstraints =
        widget.contentConstraints ?? tabsTheme.contentConstraints;

    final effectiveMaintainState = widget.maintainState ?? true;
    final expandTabs = this.expandTabs(context);

    Widget tabBar = Row(
      mainAxisSize: expandTabs ? MainAxisSize.max : MainAxisSize.min,
      spacing: widget.tabsGap ?? tabsTheme.tabsGap ?? 0,
      children: widget.tabs,
    );

    if (effectiveTabBarConstraints != null) {
      tabBar = ConstrainedBox(
        constraints: effectiveTabBarConstraints,
        child: tabBar,
      );
    }

    if (scrollable) {
      tabBar = ScrollConfiguration(
        // The scrolling tabs should not show an overscroll indicator.
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: SingleChildScrollView(
          dragStartBehavior: effectiveDragStartBehavior,
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          padding: effectivePadding,
          physics: widget.physics,
          child: tabBar,
        ),
      );
    } else {
      tabBar = Padding(padding: effectivePadding, child: tabBar);
    }

    final effectiveTabBarAlignment =
        widget.tabBarAlignment ??
        tabsTheme.tabBarAlignment ??
        // A `w-fit` bar has to be told where to sit, or a stretching parent
        // pulls the decoration out to the full width behind the tabs.
        (expandTabs ? null : AlignmentDirectional.centerStart);
    if (effectiveTabBarAlignment != null) {
      tabBar = Align(alignment: effectiveTabBarAlignment, child: tabBar);
    }

    return Provider(
      data: this as TabsState<dynamic>,
      notifyUpdate: (_) => true,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final decoratedBar = Decorator(
            decoration: effectiveDecoration,
            child: tabBar,
          );
          // With no panels, Tabs is just its list: shadcn's TabsList on
          // its own, the segmented control of a toolbar or settings row.
          if (widget.tabs.every((tab) => tab.content == null)) {
            return decoratedBar;
          }
          return Column(
            children: [
              decoratedBar,
              SizedBox(height: effectiveGap),
              ...List<Widget>.generate(widget.tabs.length, (int index) {
                final tab = widget.tabs[index];
                final selected = tab.value == controller.selected;
                final effectiveTabMaintainState =
                    tab.maintainState ?? effectiveMaintainState;
                if (!selected && !effectiveTabMaintainState) {
                  return const SizedBox.shrink();
                }
                Widget content = Offstage(
                  offstage: !selected,
                  child: FocusTraversalGroup(
                    descendantsAreFocusable: selected,
                    policy: WidgetOrderTraversalPolicy(),
                    child: KeyedSubtree(
                      key: _tabKeys[index],
                      child: tab.content ?? const SizedBox.shrink(),
                    ),
                  ),
                );

                if (effectiveContentConstraints != null) {
                  content = ConstrainedBox(
                    constraints: effectiveContentConstraints,
                    child: content,
                  );
                }

                final effectiveExpandContent =
                    tab.expandContent ?? theme.tabsTheme.expandContent ?? false;
                if (effectiveExpandContent && selected) {
                  content = Expanded(child: content);
                }

                return content;
              }),
            ],
          );
        },
      ),
    );
  }
}

/// {@template Tab}
/// Represents a single tab item within a [Tabs] widget.
///
/// Includes properties for styling, content, and interaction handling.
/// {@endtemplate}
class Tab<T> extends StatefulWidget implements PreferredSizeWidget {
  /// {@macro Tab}
  const Tab({
    super.key,
    required this.value,
    required this.child,
    this.content,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.flex = 1,
    this.height,
    this.width,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.hoverBackgroundColor,
    this.selectedHoverBackgroundColor,
    this.padding,
    this.decoration,
    this.selectedDecoration,
    this.foregroundColor,
    this.selectedForegroundColor,
    this.textStyle,
    this.shadows,
    this.selectedShadows,
    this.focusNode,
    this.onPressed,
    this.onLongPress,
    this.size,
    this.cursor,
    this.hoverForegroundColor,
    this.autofocus = false,
    this.pressedBackgroundColor,
    this.pressedForegroundColor,
    this.gradient,
    this.textDecoration,
    this.hoverTextDecoration,
    this.statesController,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.hoverStrategies,
    this.onHoverChange,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onLongPressStart,
    this.onLongPressCancel,
    this.onLongPressUp,
    this.onLongPressDown,
    this.onLongPressEnd,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.onDoubleTapCancel,
    this.longPressDuration,
    this.expandContent,
    this.maintainState,
  });

  /// {@template Tab.value}
  /// The value associated with this tab, used for selection and identification.
  /// {@endtemplate}
  final T value;

  /// {@template Tab.child}
  /// The widget to display as the tab's label, typically a [Text] widget.
  /// {@endtemplate}
  final Widget child;

  /// {@template Tab.content}
  /// The widget to display as the content associated with this tab.
  ///
  /// Displayed when the tab is selected.
  /// {@endtemplate}
  final Widget? content;

  /// {@template Tab.leading}
  /// A widget to display at the start of the tab, often an [Icon].
  /// {@endtemplate}
  final Widget? leading;

  /// {@template Tab.trailing}
  /// A widget to display at the end of the tab.
  /// {@endtemplate}
  final Widget? trailing;

  /// {@template Tab.enabled}
  /// Whether the tab is enabled and can be selected.
  ///
  /// Defaults to true.
  /// {@endtemplate}
  final bool enabled;

  /// {@template Tab.flex}
  /// Flex factor for the tab when it's part of a [Row] in a non-scrollable
  /// [Tabs].
  ///
  /// Ignored when [Tabs] is scrollable. Defaults to 1.
  /// {@endtemplate}
  final int flex;

  /// {@template Tab.height}
  /// Height of the tab.
  ///
  /// Defaults to 32.
  /// {@endtemplate}
  final double? height;

  /// {@template Tab.width}
  /// Width of the tab.
  ///
  /// In non-scrollable [Tabs], defaults to `double.infinity`. In scrollable
  /// [Tabs], defaults to null, allowing the tab to size to its content.
  /// {@endtemplate}
  final double? width;

  /// {@template Tab.backgroundColor}
  /// Background color of the tab when unselected.
  ///
  /// Defaults to `Colors.transparent`.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// {@template Tab.selectedBackgroundColor}
  /// Background color of the tab when selected.
  ///
  /// Defaults to theme's background color.
  /// {@endtemplate}
  final Color? selectedBackgroundColor;

  /// {@template Tab.hoverBackgroundColor}
  /// Background color when hovered.
  ///
  /// Defaults to [backgroundColor].
  /// {@endtemplate}
  final Color? hoverBackgroundColor;

  /// {@template Tab.selectedHoverBackgroundColor}
  /// Background color when selected and hovered.
  ///
  /// Defaults to [selectedBackgroundColor].
  /// {@endtemplate}
  final Color? selectedHoverBackgroundColor;

  /// {@template Tab.padding}
  /// Padding within the tab.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template Tab.decoration}
  /// Decoration for the tab when unselected.
  ///
  /// Uses [FinesseDecoration].
  /// {@endtemplate}
  final FinesseDecoration? decoration;

  /// {@template Tab.selectedDecoration}
  /// Decoration for the tab when selected.
  ///
  /// Defaults to [decoration]. Uses [FinesseDecoration].
  /// {@endtemplate}
  final FinesseDecoration? selectedDecoration;

  /// {@template Tab.foregroundColor}
  /// Foreground color (text/icon color) when unselected.
  ///
  /// Defaults to theme's foreground color.
  /// {@endtemplate}
  final Color? foregroundColor;

  /// {@template Tab.selectedForegroundColor}
  /// Foreground color when selected.
  ///
  /// Defaults to [foregroundColor].
  /// {@endtemplate}
  final Color? selectedForegroundColor;

  /// {@template Tab.textStyle}
  /// Text style for the tab label.
  ///
  /// Defaults to theme's small text style.
  /// {@endtemplate}
  final TextStyle? textStyle;

  /// {@template Tab.shadows}
  /// Shadows for the tab when unselected.
  ///
  /// Defaults to small shadows ([Shadows.sm]).
  /// {@endtemplate}
  final List<BoxShadow>? shadows;

  /// {@template Tab.selectedShadows}
  /// Shadows for the tab when selected.
  ///
  /// Defaults to small shadows ([Shadows.sm]).
  /// {@endtemplate}
  final List<BoxShadow>? selectedShadows;

  /// {@template Tab.focusNode}
  /// Focus node to control the focus state of the tab.
  ///
  /// If null, an internal [FocusNode] is created.
  /// {@endtemplate}
  final FocusNode? focusNode;

  /// {@template Tab.onPressed}
  /// Callback for tap events on the tab.
  /// {@endtemplate}
  final VoidCallback? onPressed;

  /// {@template Tab.onLongPress}
  /// Callback for long-press events on the tab.
  /// {@endtemplate}
  final VoidCallback? onLongPress;

  /// {@template Tab.size}
  /// Size configuration for the tab, uses [ButtonSize].
  /// {@endtemplate}
  final ButtonSize? size;

  /// {@template Tab.cursor}
  /// Mouse cursor when hovering over the tab.
  /// {@endtemplate}
  final MouseCursor? cursor;

  /// {@template Tab.hoverForegroundColor}
  /// Foreground color when hovered.
  /// {@endtemplate}
  final Color? hoverForegroundColor;

  /// {@template Tab.autofocus}
  /// Whether the tab should automatically focus on build.
  ///
  /// Defaults to false.
  /// {@endtemplate}
  final bool autofocus;

  /// {@template Tab.pressedBackgroundColor}
  /// Background color when pressed.
  /// {@endtemplate}
  final Color? pressedBackgroundColor;

  /// {@template Tab.pressedForegroundColor}
  /// Foreground color when pressed.
  /// {@endtemplate}
  final Color? pressedForegroundColor;

  /// {@template Tab.gradient}
  /// Background gradient for the tab.
  /// {@endtemplate}
  final Gradient? gradient;

  /// {@template Tab.textDecoration}
  /// Text decoration for the tab label.
  /// {@endtemplate}
  final TextDecoration? textDecoration;

  /// {@template Tab.hoverTextDecoration}
  /// Text decoration when hovered.
  /// {@endtemplate}
  final TextDecoration? hoverTextDecoration;

  /// {@template Tab.statesController}
  /// Custom states controller for managing tab states.
  /// {@endtemplate}
  final WidgetStatesController? statesController;

  /// {@macro Button.mainAxisAlignment}
  final MainAxisAlignment? mainAxisAlignment;

  /// {@macro Button.crossAxisAlignment}
  final CrossAxisAlignment? crossAxisAlignment;

  /// {@macro Button.hoverStrategies}
  final HoverStrategies? hoverStrategies;

  /// {@macro Button.onHoverChange}
  final ValueChanged<bool>? onHoverChange;

  /// {@macro Button.onTapDown}
  final ValueChanged<TapDownDetails>? onTapDown;

  /// {@macro Button.onTapUp}
  final ValueChanged<TapUpDetails>? onTapUp;

  /// {@macro Button.onTapCancel}
  final VoidCallback? onTapCancel;

  /// {@macro Button.onLongPressStart}
  final ValueChanged<LongPressStartDetails>? onLongPressStart;

  /// {@macro Button.onLongPressCancel}
  final VoidCallback? onLongPressCancel;

  /// {@macro Button.onLongPressUp}
  final VoidCallback? onLongPressUp;

  /// {@macro Button.onLongPressDown}
  final ValueChanged<LongPressDownDetails>? onLongPressDown;

  /// {@macro Button.onLongPressEnd}
  final ValueChanged<LongPressEndDetails>? onLongPressEnd;

  /// {@macro Button.onDoubleTap}
  final VoidCallback? onDoubleTap;

  /// {@macro Button.onDoubleTapDown}
  final ValueChanged<TapDownDetails>? onDoubleTapDown;

  /// {@macro Button.onDoubleTapCancel}
  final VoidCallback? onDoubleTapCancel;

  /// {@macro Button.longPressDuration}
  final Duration? longPressDuration;

  /// {@template Tab.expand}
  /// Whether the tab content should be expanded, defaults to `false`.
  /// {@endtemplate}
  final bool? expandContent;

  /// {@template Tab.maintainState}
  /// Whether to maintain the state of this tab when switching away from it.
  ///
  /// When set, overrides the global [Tabs.maintainState] for this specific
  /// tab. When null, falls back to [Tabs.maintainState] (which defaults to
  /// true).
  /// {@endtemplate}
  final bool? maintainState;

  @override
  State<Tab<T>> createState() => _TabState<T>();

  @override
  Size get preferredSize {
    return Size.fromHeight(height ?? 32);
  }
}

class _TabState<T> extends State<Tab<T>> {
  FocusNode? _focusNode;

  FocusNode get focusNode => widget.focusNode ?? _focusNode!;

  late bool focused = focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _focusNode = FocusNode();
    focusNode.addListener(focusNodeListener);
  }

  @override
  void didUpdateWidget(covariant Tab<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode == null && oldWidget.focusNode != null) {
      focusNode.removeListener(focusNodeListener);
      _focusNode = FocusNode();
      focusNode.addListener(focusNodeListener);
    } else if (widget.focusNode != null && oldWidget.focusNode == null) {
      focusNode.removeListener(focusNodeListener);
      _focusNode?.dispose();
      _focusNode = null;
      focusNode.addListener(focusNodeListener);
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  void focusNodeListener() {
    setState(() => focused = focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inherited = context.watch<TabsState<dynamic>>() as TabsState<T>;

    void onMayChanged() {
      final hasChanged = inherited.controller.select(widget.value);
      if (hasChanged) {
        inherited.widget.onChanged?.call(widget.value);
      }
    }

    final tabsTheme = theme.tabsTheme;

    final expandTabs = inherited.expandTabs(context);
    final defaultWidth = inherited.scrollable || !expandTabs
        ? null
        : double.infinity;
    final effectiveWidth = widget.width ?? tabsTheme.tabWidth ?? defaultWidth;
    final effectiveBackgroundColor =
        widget.backgroundColor ??
        tabsTheme.tabBackgroundColor ??
        const Color(0x00000000);

    final effectiveSelectedBackgroundColor =
        widget.selectedBackgroundColor ??
        tabsTheme.tabSelectedBackgroundColor ??
        theme.colorScheme.background;

    final effectiveHoverBackgroundColor =
        widget.hoverBackgroundColor ??
        tabsTheme.tabHoverBackgroundColor ??
        effectiveBackgroundColor;

    final effectiveSelectedHoverBackgroundColor =
        widget.selectedHoverBackgroundColor ??
        tabsTheme.tabSelectedHoverBackgroundColor ??
        effectiveSelectedBackgroundColor;

    final effectivePadding =
        widget.padding ??
        tabsTheme.tabPadding ??
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    final effectiveForegroundColor =
        widget.foregroundColor ??
        tabsTheme.tabForegroundColor ??
        theme.colorScheme.foreground;

    final effectiveSelectedForegroundColor =
        widget.selectedForegroundColor ??
        tabsTheme.tabSelectedForegroundColor ??
        effectiveForegroundColor;

    final effectiveShadows = widget.shadows ?? tabsTheme.tabShadows;
    final effectiveSelectedShadows =
        widget.selectedShadows ?? tabsTheme.tabSelectedShadows ?? Shadows.sm;

    final effectiveMainAxisAlignment =
        widget.mainAxisAlignment ?? tabsTheme.tabMainAxisAlignment;
    final effectiveCrossAxisAlignment =
        widget.crossAxisAlignment ?? tabsTheme.tabCrossAxisAlignment;
    final effectiveHoverStrategies =
        widget.hoverStrategies ?? tabsTheme.tabHoverStrategies;

    final effectiveTextDecoration =
        widget.textDecoration ?? tabsTheme.tabTextDecoration;
    final effectiveHoverTextDecoration =
        widget.hoverTextDecoration ?? tabsTheme.tabHoverTextDecoration;
    final effectiveGradient = widget.gradient ?? tabsTheme.tabGradient;
    final effectiveSize = widget.size ?? tabsTheme.tabSize;
    final effectiveHoverForegroundColor =
        widget.hoverForegroundColor ?? tabsTheme.tabHoverForegroundColor;
    final effectiveCursor = widget.cursor ?? tabsTheme.tabCursor;
    final effectivePressedBackgroundColor =
        widget.pressedBackgroundColor ?? tabsTheme.tabPressedBackgroundColor;
    final effectivePressedForegroundColor =
        widget.pressedForegroundColor ?? tabsTheme.tabPressedForegroundColor;

    final effectiveTextStyle =
        widget.textStyle ?? tabsTheme.tabTextStyle ?? theme.textTheme.small;

    Widget tab = ListenableBuilder(
      listenable: inherited.controller,
      builder: (context, _) {
        final selected = inherited.controller.selected == widget.value;

        final defaultDecoration = switch (theme.disableSecondaryBorder) {
          true => FinesseDecoration(
            border: FinesseBorder.all(
              radius: BorderRadius.circular(2),
              width: 0,
              padding: const EdgeInsets.all(2),
            ),
            focusedBorder: FinesseBorder.all(
              width: 2,
              radius: BorderRadius.circular(2),
              color: theme.colorScheme.ring,
            ),
          ),
          false => FinesseDecoration(
            border: FinesseBorder.all(
              radius: BorderRadius.circular(2),
              width: 0,
            ),
            // No inner gutter around a tab: the strip's own `p-[3px]` is the
            // only inset in the reference. The old 4px secondary padding
            // shrank every tab inside its box, which read as too much space
            // between the tabs and the strip's border. The focus ring is the
            // standard outward ring; like shadcn's, it may overlap the strip.
            secondaryFocusedBorder: FinesseBorder.all(
              width: 2,
              radius: theme.radius,
              offset: 2,
              color: theme.colorScheme.ring,
            ),
          ),
        };

        final effectiveDecoration = defaultDecoration
            .merge(
              selected
                  ? tabsTheme.tabSelectedDecoration ?? tabsTheme.tabDecoration
                  : tabsTheme.tabDecoration,
            )
            .merge(widget.decoration)
            .merge(selected ? widget.selectedDecoration : null);

        return Button.secondary(
          canRequestFocus: selected,
          leading: widget.leading,
          trailing: widget.trailing,
          focusNode: focusNode,
          height: widget.height ?? tabsTheme.tabHeight ?? 32,
          width: effectiveWidth,
          backgroundColor: selected
              ? effectiveSelectedBackgroundColor
              : effectiveBackgroundColor,
          hoverBackgroundColor: selected
              ? effectiveSelectedHoverBackgroundColor
              : effectiveHoverBackgroundColor,
          padding: effectivePadding,
          decoration: effectiveDecoration,
          foregroundColor: selected
              ? effectiveSelectedForegroundColor
              : effectiveForegroundColor,
          shadows: selected ? effectiveSelectedShadows : effectiveShadows,
          onPressed: () {
            onMayChanged();
            widget.onPressed?.call();
          },
          enabled: widget.enabled,
          onLongPress: widget.onLongPress,
          size: effectiveSize,
          cursor: effectiveCursor,
          hoverForegroundColor: effectiveHoverForegroundColor,
          autofocus: widget.autofocus,
          pressedBackgroundColor: effectivePressedBackgroundColor,
          pressedForegroundColor: effectivePressedForegroundColor,
          gradient: effectiveGradient,
          textDecoration: effectiveTextDecoration,
          hoverTextDecoration: effectiveHoverTextDecoration,
          statesController: widget.statesController,
          mainAxisAlignment: effectiveMainAxisAlignment,
          crossAxisAlignment: effectiveCrossAxisAlignment,
          hoverStrategies: effectiveHoverStrategies,
          onHoverChange: widget.onHoverChange,
          onTapDown: widget.onTapDown,
          onTapUp: widget.onTapUp,
          onTapCancel: widget.onTapCancel,
          onLongPressStart: widget.onLongPressStart,
          onLongPressCancel: widget.onLongPressCancel,
          onLongPressUp: widget.onLongPressUp,
          onLongPressDown: widget.onLongPressDown,
          onLongPressEnd: widget.onLongPressEnd,
          onDoubleTap: widget.onDoubleTap,
          onDoubleTapDown: widget.onDoubleTapDown,
          onDoubleTapCancel: widget.onDoubleTapCancel,
          longPressDuration: widget.longPressDuration,
          onFocusChange: (focused) {
            if (focused) onMayChanged();
          },
          child: DefaultTextStyle.merge(
            style: effectiveTextStyle,
            child: widget.child,
          ),
        );
      },
    );

    if (!inherited.scrollable && expandTabs) {
      tab = Expanded(flex: widget.flex, child: tab);
    }

    return tab;
  }
}
