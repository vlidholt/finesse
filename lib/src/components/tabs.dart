import 'package:finesse/src/components/tab_bar_view.dart';
import 'package:finesse/src/components/tab_list.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/widgets.dart';

/// Holds the selected tab for a `TabBar`, a [Tabs] or a `TabBarView`, in
/// place of their `value` and `onChanged`.
///
/// There are two reasons to use one. A `TabBar` and a `TabBarView` that are
/// placed apart — the bar in an `AppBar`, the pages in the body — share
/// one, so they agree on the selection and the bar's indicator follows the
/// finger while a page is dragged. And a [RestorableTabsController] keeps
/// the selection across state restoration.
///
/// ```dart
/// final tabs = TabsController<String>(value: 'posts');
/// // ...
/// tabs.value = 'about';
/// ```
class TabsController<T> extends ChangeNotifier {
  /// Creates a controller with [value] selected.
  TabsController({required T value}) : _value = value;

  T _value;

  /// The selected tab's value. Setting it selects that tab, as [select]
  /// does.
  T get value => _value;
  set value(T value) => select(value);

  /// Selects [value]. Returns whether that changed the selection.
  bool select(T value) {
    if (value == _value) return false;
    _value = value;
    notifyListeners();
    return true;
  }

  /// Where a swipe has dragged the pages: a fractional index into the
  /// pages, or null while nothing is being dragged.
  ///
  /// Written by the pages of a `TabBarView` or a [Tabs] on this controller,
  /// and listened to by the tab bar, which holds its indicator there.
  final ValueNotifier<double?> swipePosition = ValueNotifier<double?>(null);

  @override
  void dispose() {
    swipePosition.dispose();
    super.dispose();
  }
}

/// A [TabsController] that is saved and brought back by state restoration.
///
/// Register it in a `RestorationMixin`'s `restoreState` and pass its
/// `value` — the controller — to the tabs.
class RestorableTabsController<T>
    extends RestorableChangeNotifier<TabsController<T>> {
  /// Creates a restorable controller that starts on [value].
  RestorableTabsController({required T value}) : initialValue = value;

  /// The tab selected before anything was restored.
  final T initialValue;

  @override
  TabsController<T> createDefaultValue() {
    return TabsController<T>(value: initialValue);
  }

  @override
  TabsController<T> fromPrimitives(Object? data) {
    return TabsController<T>(value: data! as T);
  }

  @override
  Object? toPrimitives() => value.value;
}

/// One tab of a `TabBar` or a [Tabs]: its [value], its label and — in a
/// [Tabs] — the [content] shown while it is selected.
///
/// ```dart
/// Tab(
///   value: 'account',
///   leading: PhosphorIcon(PhosphorIconsRegular.user),
///   child: Text('Account'),
///   content: AccountForm(),
/// )
/// ```
@immutable
class Tab<T> {
  /// Creates a tab.
  const Tab({
    required this.value,
    required this.child,
    this.leading,
    this.trailing,
    this.content,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
  });

  /// What this tab stands for: the tab bar's `value` when it is selected.
  final T value;

  /// The label, usually a [Text].
  ///
  /// A text label is one line. It is the part of the tab that gives way: in
  /// a tab narrower than its content — an expanded tab in a narrow strip —
  /// it is cut short with an ellipsis, next to [leading] and [trailing] at
  /// their full size. Give the [Text] its own `maxLines` or `overflow` to
  /// change that.
  final Widget child;

  /// Shown before the label, usually an icon.
  final Widget? leading;

  /// Shown after the label: a count, a badge.
  final Widget? trailing;

  /// What a [Tabs] shows under its bar while this tab is selected. A
  /// `TabBar` ignores it.
  final Widget? content;

  /// Whether the tab can be selected.
  final bool enabled;

  /// Shown when the pointer rests on the tab.
  final String? tooltip;

  /// Read by a screen reader in place of the label.
  final String? semanticLabel;

  /// This tab as an entry of the shared tab list.
  TabListItem _toItem() => TabListItem(
    leading: leading,
    trailing: trailing,
    enabled: enabled,
    tooltip: tooltip,
    semanticLabel: semanticLabel,
    child: child,
  );
}

/// The entries of the shared tab list for [tabs]. Internal.
List<TabListItem> tabListItems<T>(List<Tab<T>> tabs) => [
  for (final tab in tabs) tab._toItem(),
];

/// A tab bar with the selected tab's content under it.
///
/// ```dart
/// Tabs<String>(
///   value: tab,
///   onChanged: (value) => setState(() => tab = value),
///   tabs: const [
///     Tab(value: 'account', content: AccountForm(), child: Text('Account')),
///     Tab(value: 'billing', content: BillingForm(), child: Text('Billing')),
///   ],
/// )
/// ```
///
/// It is a `TabBar` and a `TabBarView` put together, and the two are
/// linked: on a touch screen the content can be swiped to the next tab's,
/// and the bar's selection follows the finger. When no [Tab] has `content`
/// only the bar is shown, with no gap below it.
///
/// The bar is the [TabBarVariant.segmented] strip by default — as wide as
/// its tabs unless [expandTabs] is set — and the underline row with
/// [variant] set to [TabBarVariant.underline]. To pick a value rather than
/// show a view, use a `SegmentedControl`.
///
/// Controlled with [value] and [onChanged], or by a [controller].
class Tabs<T> extends StatefulWidget {
  /// Creates a tab bar with the selected tab's content under it.
  const Tabs({
    required this.tabs,
    this.value,
    this.onChanged,
    this.controller,
    this.variant = TabBarVariant.segmented,
    this.expandTabs,
    this.scrollable = false,
    this.tabBarAlignment,
    this.gap,
    this.maintainState = true,
    this.swipeable = true,
    this.expandContent,
    this.restorationId,
    super.key,
  }) : assert(
         (value != null) ^ (controller != null),
         'Either value or controller must be provided',
       );

  /// The tabs, in order.
  final List<Tab<T>> tabs;

  /// The value of the selected tab, when there is no [controller].
  final T? value;

  /// Called with the value of the tab the user selected, by a tap, a key
  /// or a swipe.
  final ValueChanged<T>? onChanged;

  /// Holds the selection in place of [value]; see [TabsController].
  final TabsController<T>? controller;

  /// How the bar is drawn. Defaults to the segmented strip.
  final TabBarVariant variant;

  /// Whether the tabs share the full width of the bar.
  ///
  /// The segmented strip defaults to false: a tab is as wide as its label
  /// plus its padding, and the strip is as wide as its tabs. Underline tabs
  /// default to true.
  final bool? expandTabs;

  /// Whether the bar scrolls sideways when its tabs do not fit.
  final bool scrollable;

  /// Where the segmented strip sits in the width [Tabs] has, when the
  /// strip is narrower than it. Defaults to the start.
  ///
  /// It has no effect when the tabs expand (see [expandTabs]) or when a
  /// [Tabs] without content is free to be as small as its strip.
  final AlignmentGeometry? tabBarAlignment;

  /// The gap between the bar and the content. Defaults to the theme's.
  final double? gap;

  /// Whether the content of a tab that is not selected stays built, keeping
  /// its state. Defaults to true.
  final bool maintainState;

  /// Whether dragging the content changes the tab. A mouse never does.
  /// Defaults to true.
  final bool swipeable;

  /// Whether the content fills the height left under the bar, for a
  /// [Tabs] that is given one. By default the content is as tall as it
  /// needs to be.
  final bool? expandContent;

  /// Restores the selection under this id, when there is no [controller].
  final String? restorationId;

  @override
  State<Tabs<T>> createState() => _TabsState<T>();
}

class _TabsState<T> extends State<Tabs<T>> with RestorationMixin {
  RestorableTabsController<T>? _local;
  TabsController<T>? _listened;

  TabsController<T> get _controller => widget.controller ?? _local!.value;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _createLocal(widget.value as T);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // After RestorationMixin has had the chance to create or restore the
    // local controller.
    _listen();
  }

  @override
  void didUpdateWidget(covariant Tabs<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocal(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_local!);
      _local!.dispose();
      _local = null;
    }
    _listen();
    if (widget.controller == null && widget.value is T) {
      _controller.select(widget.value as T);
    }
  }

  @override
  void dispose() {
    _listened?.removeListener(_changed);
    _local?.dispose();
    super.dispose();
  }

  void _createLocal(T value) {
    assert(_local == null);
    _local = RestorableTabsController<T>(value: value);
    if (!restorePending) registerForRestoration(_local!, 'controller');
  }

  void _listen() {
    final current = _controller;
    if (identical(current, _listened)) return;
    _listened?.removeListener(_changed);
    _listened = current..addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_local != null) registerForRestoration(_local!, 'controller');
    _listened = null;
    _listen();
  }

  void _select(int index) {
    final value = widget.tabs[index].value;
    if (_controller.select(value)) widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabsTheme = theme.tabsTheme;
    final tabs = widget.tabs;
    final selected = tabs.indexWhere((tab) => tab.value == _controller.value);
    final segmented = widget.variant == TabBarVariant.segmented;
    final expandTabs =
        widget.expandTabs ?? (!segmented || (tabsTheme.expandTabs ?? false));
    // With no content, Tabs is just its list: the strip of a toolbar or a
    // settings row.
    final listOnly = tabs.every((tab) => tab.content == null);

    final bar = TabList(
      items: tabListItems(tabs),
      selectedIndex: selected < 0 ? null : selected,
      onSelected: _select,
      variant: widget.variant,
      expand: expandTabs,
      scrollable: widget.scrollable,
      track: _controller.swipePosition,
      alignment: widget.tabBarAlignment,
      // Above its content the strip is placed across the content's width;
      // on its own the list is as small as its strip wherever its parent
      // lets it be.
      shrinkWrap: listOnly,
    );
    if (listOnly) return bar;

    final expandContent =
        widget.expandContent ?? tabsTheme.expandContent ?? false;
    final contentConstraints =
        tabsTheme.contentConstraints ?? const BoxConstraints();
    final Widget pages = TabPages(
      count: tabs.length,
      index: selected < 0 ? 0 : selected,
      onIndexChanged: _select,
      builder: (context, index) =>
          // The content is as wide as it asks to be, in the middle of the
          // page, as it would be in a column.
          Align(
            alignment: Alignment.topCenter,
            heightFactor: expandContent ? null : 1,
            child: ConstrainedBox(
              constraints: contentConstraints,
              child: tabs[index].content ?? const SizedBox.shrink(),
            ),
          ),
      maintainState: widget.maintainState,
      swipeable: widget.swipeable,
      fill: expandContent,
      track: _controller.swipePosition,
      canShow: (index) => tabs[index].enabled,
    );

    return Column(
      children: [
        bar,
        SizedBox(height: widget.gap ?? tabsTheme.gap ?? 8),
        if (expandContent) Expanded(child: pages) else pages,
      ],
    );
  }
}
