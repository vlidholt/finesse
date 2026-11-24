import 'package:example/common/app_state.dart';
import 'package:example/strand/data/search_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/screens/search_screen.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/search_field.dart';
import 'package:example/strand/widgets/search_results.dart';
import 'package:example/strand/widgets/strand_previews.dart';
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

/// The desktop app bar's search: the [SearchField], with a panel under it
/// while it has the focus.
///
/// Before anything is typed the panel lists the recent and the trending
/// searches. As the user types it shows the best few people, jobs, posts
/// and companies, live. Return — or "See all results" — opens the full
/// [SearchScreen] on the same query; ⌘K (Ctrl+K) puts the cursor in the
/// field from anywhere.
///
/// The panel is a `Portal` rather than a `Popover`: a popover takes the
/// focus when it opens, and this one has to leave it in the field.
class StrandSearchBar extends StatefulWidget {
  const StrandSearchBar({super.key});

  /// The panel's width: wider than the field, as a results list wants.
  static const panelWidth = 420.0;

  @override
  State<StrandSearchBar> createState() => _StrandSearchBarState();
}

class _StrandSearchBarState extends State<StrandSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
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
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_open) setState(() => _open = true);
  }

  void _onQueryChanged() {
    setState(() {
      // Typing after Escape brings the panel back; clearing the field on
      // the way to the results page does not.
      if (_focusNode.hasFocus && _controller.text.isNotEmpty) _open = true;
    });
  }

  /// ⌘K or Ctrl+K, wherever the focus is — as long as this bar is the page
  /// on top, not one a full-screen route has covered.
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyK) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isMetaPressed && !keyboard.isControlPressed) return false;
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    // Strand stays alive behind the component library; the shortcut is
    // not its to take while it is not showing.
    if (appSectionProvider.of(context).untrackedValue != AppSection.strand) {
      return false;
    }
    if (_collapsed) {
      _openEmptyPage();
    } else {
      _focusNode.requestFocus();
    }
    return true;
  }

  void _close() {
    if (_open) setState(() => _open = false);
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
    _focusNode.unfocus();
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
        if (!_collapsed) return _buildField(context);
        // No room for a field: the phone's magnifier, which opens the
        // search page, as long as there is room for that.
        if (constraints.maxWidth < _iconFrom) return const SizedBox.shrink();
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: IconButton.ghost(
            icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
            semanticLabel: 'Search',
            onPressed: _openEmptyPage,
          ),
        );
      },
    );
  }

  /// The width under which the field gives way to the magnifier — the
  /// field's own `collapseBelow` — and the one under which that goes too.
  static const _collapseBelow = 120.0;
  static const _iconFrom = 40.0;

  Widget _buildField(BuildContext context) {
    return TapRegion(
      groupId: _group,
      onTapOutside: (_) => _close(),
      child: CallbackShortcuts(
        // Bound only while the panel is open: an unconditional binding
        // would swallow the Escape meant for whatever encloses the bar.
        bindings: _open
            ? {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  _focusNode.unfocus();
                  _close();
                },
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
          child: SearchField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: _openPage,
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
    final popover = theme.popoverTheme;
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
          const Divider.horizontal(margin: EdgeInsets.symmetric(vertical: 4)),
          Button.ghost(
            width: double.infinity,
            gap: homeTightGap,
            textStyle: theme.textTheme.small,
            foregroundColor: theme.colorScheme.tint,
            trailing: const Icon(PhosphorIconsRegular.arrowRight, size: 14),
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
        child: SurfacePainter(
          decoration: (popover.decoration ?? const FinesseDecoration())
              .copyWith(shadows: popover.shadows),
          filter: popover.filter,
          padding: const EdgeInsets.all(6),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(child: content),
          ),
        ),
      ),
    );
  }
}
