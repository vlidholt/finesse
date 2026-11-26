import 'package:flutter/widgets.dart';
import 'package:una/src/components/tab_list.dart';
import 'package:una/src/components/tabs.dart';
import 'package:una/src/theme/theme.dart';

/// A row of tabs for switching between the views of a page. It reports
/// which tab was chosen; showing the matching view is up to the caller, a
/// `TabBarView` or — with the two put together — a `Tabs`.
///
/// ```dart
/// TabBar<Section>(
///   value: section,
///   onChanged: (value) => setState(() => section = value),
///   tabs: const [
///     Tab(value: Section.posts, child: Text('Posts')),
///     Tab(value: Section.about, child: Text('About')),
///     Tab(value: Section.experience, child: Text('Experience')),
///   ],
/// )
/// ```
///
/// It has two looks. [TabBarVariant.underline], the default, is text tabs
/// on the page with a line under the selected one: the sections of a page,
/// or the `bottom` of an `AppBar`. [TabBarVariant.segmented] is a filled
/// strip with a raised pill on the selected tab: a few views of the same
/// thing. In both the selection is one shape that slides to the tab that
/// was chosen, stretching a little on the way — the theme's `Motion` sets
/// the pace, and reduced motion moves it at once.
///
/// The bar is one stop for the Tab key, on the selected tab; the arrow
/// keys, Home and End move the selection within it. A screen reader is told
/// it is a list of tabs and which one is selected.
///
/// To pick a value rather than show a view — a unit, a density, light or
/// dark — use a `SegmentedControl`: it looks like the segmented bar and is
/// announced as a set of radio buttons.
///
/// See also:
///
///  * `TabBarView`, the pages that go with a bar placed apart from them.
///  * [TabsController], which links the two.
class TabBar<T> extends StatefulWidget {
  /// Creates a tab bar.
  const TabBar({
    required this.tabs,
    this.value,
    this.onChanged,
    this.controller,
    this.variant = TabBarVariant.underline,
    this.expandTabs,
    this.tabAlignment,
    this.scrollable = false,
    this.showBorder = true,
    super.key,
  }) : assert(
         value == null || controller == null,
         'Give either a value or a controller, not both.',
       );

  /// The tabs, in order. A tab's `content` is not shown here.
  final List<Tab<T>> tabs;

  /// The value of the selected tab, when there is no [controller]. With a
  /// value no tab has, none is selected and the indicator fades out.
  final T? value;

  /// Called with the value of the tab the user chose. Without it, and
  /// without a [controller], the tabs are inert.
  final ValueChanged<T>? onChanged;

  /// Holds the selection in place of [value], and makes the indicator
  /// follow a `TabBarView` on the same controller while it is dragged.
  final TabsController<T>? controller;

  /// How the bar is drawn.
  final TabBarVariant variant;

  /// Whether the tabs share the available width equally.
  ///
  /// Underline tabs do by default; without it each is as wide as its label
  /// plus its padding and the row scrolls when it does not fit. The
  /// segmented strip is as wide as its tabs by default, or as the theme's
  /// `TabsTheme.expandTabs` says.
  final bool? expandTabs;

  /// Where a segmented strip that does not [expandTabs] sits in a parent
  /// that makes the bar wider than it. Defaults to the theme's, and then to
  /// the start.
  final AlignmentGeometry? tabAlignment;

  /// Whether the row scrolls sideways when the tabs do not fit, instead of
  /// the tabs sharing the width.
  final bool scrollable;

  /// Whether a hairline runs under the whole of an underline bar.
  final bool showBorder;

  @override
  State<TabBar<T>> createState() => _TabBarState<T>();
}

class _TabBarState<T> extends State<TabBar<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_changed);
  }

  @override
  void didUpdateWidget(TabBar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?.removeListener(_changed);
      widget.controller?.addListener(_changed);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_changed);
    super.dispose();
  }

  void _changed() => setState(() {});

  void _select(int index) {
    final value = widget.tabs[index].value;
    widget.controller?.select(value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final value = controller != null ? controller.value : widget.value;
    final selected = widget.tabs.indexWhere((tab) => tab.value == value);
    final segmented = widget.variant == TabBarVariant.segmented;
    return TabList(
      items: tabListItems(widget.tabs),
      selectedIndex: selected < 0 ? null : selected,
      onSelected: controller == null && widget.onChanged == null
          ? null
          : _select,
      variant: widget.variant,
      expand:
          widget.expandTabs ??
          (!segmented || (Theme.of(context).tabsTheme.expandTabs ?? false)),
      scrollable: widget.scrollable,
      showBorder: widget.showBorder,
      alignment: widget.tabAlignment,
      track: controller?.swipePosition,
    );
  }
}
