import 'package:example/common/app_state.dart';
import 'package:example/strand/data/search_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/screens/search_screen.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/search_results.dart';
import 'package:example/strand/widgets/strand_previews.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// What choosing a search result does, from [context]: a person or a
/// company opens its preview, a job goes to Jobs, a post to the feed — or
/// to the profile, for one of the user's own.
///
/// [before] runs first, for the host to close itself and record the query.
SearchCallbacks searchCallbacksFor(
  BuildContext context, {
  required VoidCallback before,
}) {
  return SearchCallbacks(
    onPerson: (person) {
      before();
      showPersonPreview(context, person);
    },
    onCompany: (company) {
      before();
      showCompanyPreview(context, company);
    },
    onJob: (job) {
      before();
      context.leaveTo(StrandDestination.jobs);
    },
    onPost: (post) {
      before();
      context.leaveTo(
        post.own ? StrandDestination.profile : StrandDestination.home,
      );
    },
  );
}

/// The desktop app bar's search: a [SearchField], with a panel under it
/// while the focus is in the field or in the panel.
///
/// Before anything is typed the panel lists the recent and the trending
/// searches. As the user types it shows the best few people, jobs, posts
/// and companies, live. Return — or "See all results" — opens the full
/// [SearchScreen] on the same query.
///
/// ## The panel follows the focus
///
/// The panel is not a route and has no barrier, so nothing but the focus
/// says whether it is in use. It opens when the field gains the focus (and
/// when the field is tapped or typed in with the focus already there), and
/// closes when the focus leaves both the field and the panel — by Tab, by a
/// click elsewhere, by a result opening a dialog — as well as on Escape and
/// on a tap outside. Field and panel are one focus traversal group, so Tab
/// and the down arrow go from the field into the results and Escape closes
/// the panel from either; they are one tap-region group too, so a click on
/// the panel's own surface neither closes it nor takes the focus from the
/// field.
///
/// ## The shortcut
///
/// ⌘K on an Apple platform, Ctrl+K elsewhere ([SearchField.isSearchShortcut])
/// puts the cursor in the field from anywhere in Strand. It is a
/// `HardwareKeyboard` handler, which hears a key wherever the focus is —
/// including inside a dialog — so it checks that nothing covers the bar
/// (`isOnTopRoute`) before it acts.
///
/// The panel is a `Portal` rather than a `Popover`: a popover takes the
/// focus when it opens, and this one has to leave it in the field.
class StrandSearchBar extends StatefulWidget {
  const StrandSearchBar({super.key});

  /// The panel's width: wider than the field, as a results list wants.
  static const panelWidth = 420.0;

  /// The width the designs give the field in the desktop app bar.
  static const fieldWidth = 280.0;

  /// What Strand's search fields ask for.
  static const placeholder = 'Search people, posts, jobs';

  @override
  State<StrandSearchBar> createState() => _StrandSearchBarState();
}

class _StrandSearchBarState extends State<StrandSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  /// Above the field and the panel: has the focus while either does.
  final _scopeNode = FocusNode(
    debugLabel: 'StrandSearchBar',
    canRequestFocus: false,
    skipTraversal: true,
  );
  final _group = Object();
  bool _open = false;

  static const _anchor = AnchorAuto(
    offset: Offset(0, 8),
    targetAnchor: AlignmentDirectional.bottomStart,
    followerAnchor: AlignmentDirectional.bottomEnd,
  );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onQueryChanged);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _controller.dispose();
    _focusNode.dispose();
    _scopeNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) _show();
  }

  void _onQueryChanged() {
    setState(() {
      // Typing after Escape brings the panel back; clearing the field on
      // the way to the results page does not.
      if (_focusNode.hasFocus && _controller.text.isNotEmpty) _open = true;
    });
  }

  /// The search shortcut, wherever the focus is — as long as the bar is
  /// what the user is looking at.
  bool _onKey(KeyEvent event) {
    if (!SearchField.isSearchShortcut(event)) return false;
    // Not under a dialog, a sheet or a full-screen page: the focus belongs
    // to whatever covers the bar, and the panel would open behind it.
    if (!mounted || !context.isOnTopRoute) return false;
    // Strand stays alive behind the component library; the shortcut is
    // not its to take while it is not showing.
    if (appSectionProvider.of(context).untrackedValue != AppSection.strand) {
      return false;
    }
    if (_collapsed) {
      _openEmptyPage();
    } else {
      _focusNode.requestFocus();
      // The field may have the focus already, with the panel closed by a
      // tap outside.
      _show();
    }
    return true;
  }

  void _show() {
    if (!_open) setState(() => _open = true);
  }

  void _close() {
    if (_open) setState(() => _open = false);
  }

  /// Escape: the panel goes and the field gives up the focus.
  void _dismiss() {
    FocusManager.instance.primaryFocus?.unfocus();
    _close();
  }

  /// Moves the focus one stop along the field and the panel's controls, in
  /// reading order, and stops at either end: the arrow keys never leave
  /// the panel, which Tab does.
  void _step(int by) {
    final current = FocusManager.instance.primaryFocus;
    if (current == null) return;
    final stops = ReadingOrderTraversalPolicy()
        .sortDescendants(_scopeNode.traversalDescendants, current)
        .toList();
    final next = stops.indexOf(current) + by;
    if (stops.contains(current) && next >= 0 && next < stops.length) {
      FocusTraversalPolicy.defaultTraversalRequestFocusCallback(
        stops[next],
        alignmentPolicy: by > 0
            ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
            : ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
  }

  /// Whether the bar had no room for the field at the last layout, and
  /// showed the magnifier instead.
  bool _collapsed = false;

  void _openEmptyPage() {
    context.pushFullScreen<void>((context) => const SearchScreen());
  }

  /// Closes the panel, drops the focus and remembers the query.
  void _leave() {
    context.strand.search.add(_controller.text);
    FocusManager.instance.primaryFocus?.unfocus();
    _close();
  }

  void _openPage([String? query]) {
    final text = (query ?? _controller.text).trim();
    if (text.isEmpty) return;
    _leave();
    context.strand.search.add(text);
    _controller.clear();
    context.pushFullScreen<void>(
      (context) => SearchScreen(initialQuery: text),
    );
  }

  void _pick(String query) {
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _collapsed = constraints.maxWidth < _collapseBelow;
        if (!_collapsed) return _buildField(context, constraints.maxWidth);
        // No room for a field: the phone's magnifier, which opens the
        // search page, as long as there is room for that.
        if (constraints.maxWidth < _iconFrom) return const SizedBox.shrink();
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
            semanticLabel: 'Search',
            onPressed: _openEmptyPage,
          ),
        );
      },
    );
  }

  /// The width under which the field gives way to the magnifier, so a
  /// narrow app bar keeps its logo and navigation rather than a sliver of
  /// a text field, and the one under which the magnifier goes too.
  static const _collapseBelow = 120.0;
  static const _iconFrom = 40.0;

  /// The width from which the field has room for the shortcut's key cap.
  static const _shortcutFrom = 200.0;

  Widget _buildField(BuildContext context, double width) {
    final theme = Theme.of(context);
    final field = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: StrandSearchBar.fieldWidth),
      child: SearchField(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: StrandSearchBar.placeholder,
        // The panel is in the field's tap-region group, so a click
        // on it leaves the focus in the field.
        groupId: _group,
        // Open on a focus *gain* is not enough: after a tap outside
        // on a touch screen the field still has the focus.
        onTap: _show,
        onSubmitted: _openPage,
        // Escape is the panel's: it closes it, query and all.
        clearOnEscape: false,
        // The hint gives way first, and to the clear button once there
        // is something to clear.
        trailing: width >= _shortcutFrom && _controller.text.isEmpty
            // The design's key cap is outlined, not filled: a hairline
            // in the strong border colour.
            ? Kbd(
                SearchField.shortcutLabel,
                backgroundColor: const Color(0x00000000),
                border: FinesseBorder.all(
                  color: theme.colorScheme.borderStrong,
                  width: 1,
                  borderRadius: theme.radii.sm,
                ),
              )
            : null,
      ),
    );
    return TapRegion(
      groupId: _group,
      onTapOutside: (_) => _close(),
      // The field and the panel together: the overlay is a descendant of
      // the `Portal` as far as the focus tree goes, so the panel's controls
      // are the stops after the field, and [_scopeNode] has the focus while
      // any of them does.
      child: FocusTraversalGroup(
        child: Focus(
          focusNode: _scopeNode,
          onFocusChange: (focused) {
            if (!focused) _close();
          },
          // Escape closes the panel from the field or from a result, and
          // is left alone — for whatever encloses the bar — while the panel
          // is closed.
          child: DismissShortcut(
            isActive: () => _open,
            onDismiss: _dismiss,
            child: CallbackShortcuts(
              // Bound only while the panel is open: closed, the arrows are
              // the field's own.
              bindings: _open
                  ? {
                      const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                          _step(1),
                      const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                          _step(-1),
                    }
                  : const {},
              child: Portal(
                visible: _open,
                anchor: _anchor,
                portalBuilder: (context) => TapRegion(
                  groupId: _group,
                  child: _Panel(
                    query: _controller.text,
                    onPick: _pick,
                    onSeeAll: _openPage,
                    callbacks: searchCallbacksFor(this.context, before: _leave),
                  ),
                ),
                child: field,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The surface under the field: suggestions, live results or "no results".
class _Panel extends StatelessWidget {
  const _Panel({
    required this.query,
    required this.onPick,
    required this.onSeeAll,
    required this.callbacks,
  });

  final String query;
  final ValueChanged<String> onPick;
  final VoidCallback onSeeAll;
  final SearchCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.strand;
    final results = SearchData.search(query);
    final typed = query.trim().isNotEmpty;
    // Leave room for the app bar above and a margin below.
    final maxHeight = (MediaQuery.sizeOf(context).height - 120).clamp(
      200.0,
      560.0,
    );

    final Widget content;
    if (!typed) {
      content = SearchSuggestions(
        history: session.search,
        onPick: onPick,
        compact: true,
      );
    } else if (results.isEmpty) {
      content = SearchNoResults(query: query, onPick: onPick, compact: true);
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: session.network,
            builder: (context, _) => SearchResultsView(
              query: query,
              results: results,
              callbacks: callbacks,
              network: session.network,
              compact: true,
            ),
          ),
          const Divider(margin: EdgeInsets.symmetric(vertical: 4)),
          Button.ghost(
            width: double.infinity,
            gap: theme.gap(GapSize.xs),
            textStyle: theme.textTheme.small,
            foregroundColor: theme.colorScheme.tint,
            trailing: const PhosphorIcon(PhosphorIconsRegular.arrowRight),
            onPressed: onSeeAll,
            child: Flexible(
              child: Text(
                results.total == 1
                    ? 'See the result'
                    : 'See all ${results.total} results',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      label: 'Search suggestions',
      child: SizedBox(
        width: StrandSearchBar.panelWidth,
        child: Surface(
          padding: EdgeInsets.all(theme.gap(GapSize.xs)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(child: content),
          ),
        ),
      ),
    );
  }
}
