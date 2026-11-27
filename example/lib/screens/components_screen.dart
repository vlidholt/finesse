import 'dart:math' as math;

import 'package:example/common/app_state.dart';
import 'package:example/common/page_switch.dart';
import 'package:example/docs/docs.dart';
import 'package:example/docs/registry.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The documentation browser: a [Sidebar] of every doc page next to the
/// selected page.
///
/// It holds two of the app's destinations: the guides
/// ([AppSection.introduction]) and the component reference
/// ([AppSection.components]). [section] says which the app's navigation
/// has selected and [onSectionChanged] reports a page opened in the other.
class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({
    super.key,
    this.initialSlug,
    this.section,
    this.onSectionChanged,
  });

  /// The page to open first. Defaults to the first page of [section]: the
  /// introduction, or the components' overview.
  final String? initialSlug;

  /// The destination the app's navigation has selected.
  ///
  /// When it changes to one the open page is not in, the browser opens that
  /// destination's first page — [introductionDoc] or [overviewDoc] — and
  /// scrolls the sidebar to its section. A page the destination already
  /// shows stays open, so coming back from the showcase finds the page you
  /// left. Null, or [AppSection.showcase] (the browser is hidden), changes
  /// nothing.
  final AppSection? section;

  /// Called with the destination of a page the reader opened, from the
  /// sidebar or the overview, when it is not [section]: the app's
  /// navigation follows what is shown.
  final ValueChanged<AppSection>? onSectionChanged;

  /// The destination [slug]'s page is in: a component page, or the
  /// components' overview, is [AppSection.components]; every other page a
  /// guide.
  static AppSection sectionOf(String slug) =>
      componentsGroup.pages.any((doc) => doc.slug == slug)
      ? AppSection.components
      : AppSection.introduction;

  /// The page a destination opens on.
  static String landingOf(AppSection? section) => switch (section) {
    AppSection.components => overviewDoc.slug,
    _ => docGroups.first.items.first.slug,
  };

  @override
  State<ComponentsScreen> createState() => ComponentsScreenState();
}

class ComponentsScreenState extends State<ComponentsScreen> {
  late String selectedSlug =
      widget.initialSlug ?? ComponentsScreen.landingOf(widget.section);
  String query = '';

  /// The titles of the component categories folded open in the sidebar:
  /// the one the first page is in, then every one the reader opens or a
  /// page is opened in. A search shows every category it finds pages in,
  /// open, whatever this holds.
  late final Set<String> openCategories = {
    if (_categoryOf(selectedSlug) case final category?) category.title,
  };

  final _sidebarScrollController = ScrollController();
  final _sidebarController = SidebarController();
  final _searchController = TextEditingController();

  /// Ticks whenever what the sidebar lists changes.
  ///
  /// On a phone the sidebar is a sheet, and the sheet's route keeps the
  /// [Sidebar] it was opened with: a rebuild of this screen does not reach
  /// it. So the sidebar's content listens to this instead of being rebuilt
  /// from above, and a search or a category folded open shows in the sheet
  /// as it does beside the page.
  final _sidebarRevision = ValueNotifier(0);

  /// One stable key per sidebar group and per category, so [open] can bring
  /// the selected page's section into view.
  final _groupKeys = {for (final group in docGroups) group.title: GlobalKey()};
  final _categoryKeys = {
    for (final group in docGroups)
      for (final category in group.categories) category.title: GlobalKey(),
  };

  /// Every page, in the order the sidebar lists them.
  static final List<ComponentDoc> _sidebarOrder = [
    for (final group in docGroups) ...group.pages,
  ];

  @override
  void didUpdateWidget(ComponentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final section = widget.section;
    if (section == oldWidget.section || section == null || !section.isDocs) {
      return;
    }
    if (ComponentsScreen.sectionOf(selectedSlug) == section) return;
    open(ComponentsScreen.landingOf(section));
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    _sidebarController.dispose();
    _searchController.dispose();
    _sidebarRevision.dispose();
    super.dispose();
  }

  ComponentDoc get selectedDoc => _sidebarOrder.firstWhere(
    (doc) => doc.slug == selectedSlug,
    orElse: () => _sidebarOrder.first,
  );

  /// Where [doc] is in the sidebar, counting from the top.
  static int _indexOf(ComponentDoc doc) => _sidebarOrder.indexOf(doc);

  /// The group the selected page belongs to.
  DocGroup get selectedGroup => docGroups.firstWhere(
    (group) => group.pages.any((doc) => doc.slug == selectedSlug),
    orElse: () => docGroups.first,
  );

  /// The component category the selected page belongs to, if it is a
  /// component page.
  DocCategory? get selectedCategory => _categoryOf(selectedSlug);

  static DocCategory? _categoryOf(String slug) {
    for (final group in docGroups) {
      for (final category in group.categories) {
        if (category.items.any((doc) => doc.slug == slug)) return category;
      }
    }
    return null;
  }

  /// Opens the page with [slug] and scrolls the sidebar until its section is
  /// in view — the top navigation and the overview's cards drive this.
  void open(String slug) {
    _select(slug);
    // After this frame, so a pending rebuild (e.g. a cleared filter, a
    // category folding open) has laid the sidebar out before it scrolls.
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelection());
  }

  /// Changes what the page or the sidebar shows, in both.
  void _update(VoidCallback change) {
    setState(change);
    _sidebarRevision.value++;
  }

  void _select(String slug) {
    _update(() {
      selectedSlug = slug;
      if (_categoryOf(slug) case final category?) {
        openCategories.add(category.title);
      }
    });
    final section = ComponentsScreen.sectionOf(slug);
    if (section != widget.section) widget.onSectionChanged?.call(section);
  }

  /// Opens the page a sidebar row names and, on a phone, puts the sheet
  /// away so the page shows.
  void _selectFromSidebar(String slug) {
    _select(slug);
    if (_sidebarController.isMobileOpen) _sidebarController.closeMobile();
  }

  /// Folds [category] open in the sidebar, or shut if it is open.
  void toggleCategory(DocCategory category) {
    _update(() {
      if (!openCategories.remove(category.title)) {
        openCategories.add(category.title);
      }
    });
  }

  void _revealSelection() {
    if (!mounted) return;
    final key = switch (selectedCategory) {
      final category? => _categoryKeys[category.title],
      null => _groupKeys[selectedGroup.title],
    };
    final context = key?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      // The section's heading lands at the top of the sidebar, not merely
      // within reach.
      alignment: 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// The sidebar's groups for [query]: the pages whose title contains it,
  /// and every page of a category whose title does.
  List<DocGroup> get filteredGroups {
    if (query.isEmpty) return docGroups;
    final q = query.toLowerCase();
    bool matches(String title) => title.toLowerCase().contains(q);
    return [
      for (final group in docGroups)
        if (DocGroup(
              title: group.title,
              items: [
                for (final doc in group.items)
                  if (matches(doc.title)) doc,
              ],
              categories: [
                for (final category in group.categories)
                  if (matches(category.title))
                    category
                  else if (category.items.any((d) => matches(d.title)))
                    category.withItems([
                      for (final doc in category.items)
                        if (matches(doc.title)) doc,
                    ]),
              ],
            )
            case final filtered when filtered.pages.isNotEmpty)
          filtered,
    ];
  }

  /// The sidebar's groups, as [filteredGroups] lists them.
  Widget _buildSidebarGroups(BuildContext context) {
    final gap = Theme.of(context).sidebarTheme.contentGap ?? 8;
    final groups = filteredGroups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, group) in groups.indexed) ...[
          if (index > 0) SizedBox(height: gap),
          SidebarGroup(
            key: _groupKeys[group.title],
            label: Text(group.title),
            children: [
              SidebarMenu(
                children: [
                  for (final item in group.items)
                    SidebarMenuButton(
                      selected: item.slug == selectedSlug,
                      onPressed: () => _selectFromSidebar(item.slug),
                      child: Text(item.title),
                    ),
                  for (final category in group.categories)
                    _SidebarCategory(
                      key: _categoryKeys[category.title],
                      category: category,
                      open:
                          query.isNotEmpty ||
                          openCategories.contains(category.title),
                      selectedSlug: selectedSlug,
                      onToggle: () => toggleCategory(category),
                      onSelect: _selectFromSidebar,
                    ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doc = selectedDoc;

    return SidebarScaffold(
      controller: _sidebarController,
      sidebar: Sidebar(
        scrollController: _sidebarScrollController,
        // On a phone the sheet takes most of the screen: the categories and
        // their pages need the width, and the page behind is not read
        // while the sheet is open.
        mobileWidth: math.min(MediaQuery.sizeOf(context).width * .88, 400),
        header: TextField(
          controller: _searchController,
          placeholder: const Text('Search docs'),
          leading: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
          onChanged: (value) => _update(() => query = value),
        ),
        children: [
          ValueListenableBuilder(
            valueListenable: _sidebarRevision,
            builder: (context, _, _) => _buildSidebarGroups(context),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.border),
              ),
            ),
            child: Row(
              children: [
                const SidebarTrigger(),
                const SizedBox(width: 8),
                const SizedBox(
                  height: 16,
                  child: Divider.vertical(margin: EdgeInsets.zero),
                ),
                const SizedBox(width: 12),
                // Scrolls rather than overflows: on a phone a long section
                // and page name do not fit beside the trigger.
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Breadcrumb(
                      children: [
                        Text(
                          selectedGroup.title,
                          style: theme.textTheme.muted,
                        ),
                        if (selectedCategory case final category?)
                          Text(category.title, style: theme.textTheme.muted),
                        Text(doc.title),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // A page lower in the sidebar comes up from below, one higher
          // comes down from above.
          Expanded(
            child: PageSwitch(
              value: _indexOf(doc),
              axis: Axis.vertical,
              child: ComponentDocPage(doc: doc),
            ),
          ),
        ],
      ),
    );
  }
}

/// A component category in the sidebar: a row with the category's icon that
/// folds its pages open and shut beneath it.
///
/// Folded shut, the row is highlighted when the open page is one of its
/// own, so the sidebar still says where the reader is.
class _SidebarCategory extends StatelessWidget {
  const _SidebarCategory({
    super.key,
    required this.category,
    required this.open,
    required this.selectedSlug,
    required this.onToggle,
    required this.onSelect,
  });

  final DocCategory category;
  final bool open;
  final String selectedSlug;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final holdsSelection = category.items.any(
      (doc) => doc.slug == selectedSlug,
    );
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final motion = Motion.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The row is a semantics node of its own; merged, the fold's
        // state is part of it.
        MergeSemantics(
          child: Semantics(
            expanded: open,
            child: SidebarMenuButton(
              leading: PhosphorIcon(category.icon),
              selected: holdsSelection && !open,
              onPressed: onToggle,
              // A caret pointing at the end of the line, turned down when
              // the fold is open.
              trailing: SpringBuilder(
                value: open ? 0 : (rtl ? .25 : -.25),
                spring: motion.snappy,
                builder: (context, turns, child) =>
                    Transform.rotate(angle: turns * 2 * math.pi, child: child),
                child: const PhosphorIcon(PhosphorIconsRegular.caretDown),
              ),
              child: Text(category.title),
            ),
          ),
        ),
        SpringBuilder(
          value: open ? 1 : 0,
          spring: motion.smooth,
          builder: (context, factor, child) {
            // Shut, the pages are not built at all.
            if (!open && factor <= .001) return const SizedBox.shrink();
            return ExpandReveal(factor: factor, child: child!);
          },
          child: SidebarMenuSub(
            children: [
              for (final item in category.items)
                SidebarMenuSubButton(
                  selected: item.slug == selectedSlug,
                  onPressed: () => onSelect(item.slug),
                  child: Text(item.title),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
