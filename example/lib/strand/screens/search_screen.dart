import 'package:example/strand/data/search_data.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/search_bar.dart';
import 'package:example/strand/widgets/search_field.dart';
import 'package:example/strand/widgets/search_results.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Strand's search page: a full-screen route with the field in its app bar.
///
/// A phone opens it from the app bar's magnifier; a desktop from the app
/// bar's own field, on Return or "See all results". It searches the app's
/// own mock data — the people, job listings, posts and companies the other
/// screens show — as the user types.
///
/// * Before anything is typed: the recent searches and the trending ones.
/// * With a query: the kinds of result as a filter — a rail of rows beside
///   the results in a wide window, a strip of chips over them otherwise —
///   and the results as cards, with every match picked out.
/// * With a query nothing matches: an empty state that says what search
///   covers and offers searches that do find something.
///
/// It is also the shell's example of a full-screen route: a `Scaffold`
/// with its own `AppBar`, pushed with `context.pushFullScreen`.
class SearchScreen extends StatefulWidget {
  const SearchScreen({this.initialQuery = '', super.key});

  /// What the field holds as the page opens.
  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  SearchCategory _category = SearchCategory.all;

  /// The page's content is capped narrower than the app's pages: a list
  /// reads badly across 1280.
  static const _maxWidth = 1040.0;
  static const _railWidth = 260.0;

  /// The content width from which the filter is a rail beside the results.
  static const _railFrom = 760.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  void _pick(String query) {
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    context.strand.search.add(query);
  }

  void _remember() => context.strand.search.add(_controller.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobile = theme.formFactor == FormFactor.mobile;
    final session = context.strand;
    final query = _controller.text;
    final results = SearchData.search(query);
    // A kind with nothing in it cannot stay selected.
    final category = results.countOf(_category) == 0
        ? SearchCategory.all
        : _category;

    final Widget body;
    if (query.trim().isEmpty) {
      body = Card(
        padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
        child: SearchSuggestions(history: session.search, onPick: _pick),
      );
    } else if (results.isEmpty) {
      body = Card(
        child: SearchNoResults(query: query, onPick: _pick),
      );
    } else {
      final list = ListenableBuilder(
        listenable: session.network,
        builder: (context, _) => SearchResultsView(
          query: query,
          results: results,
          category: category,
          network: session.network,
          onCategory: (value) => setState(() => _category = value),
          callbacks: searchCallbacksFor(context, before: _remember),
        ),
      );
      body = LayoutBuilder(
        builder: (context, constraints) {
          final filter = _CategoryFilter(
            results: results,
            selected: category,
            asRail: constraints.maxWidth >= _railFrom,
            onSelected: (value) => setState(() => _category = value),
          );
          if (constraints.maxWidth >= _railFrom) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: theme.layoutTheme.gap(GapSize.xl),
              children: [
                SizedBox(width: _railWidth, child: filter),
                Expanded(child: list),
              ],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: homeLooseGap,
            children: [filter, list],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton.ghost(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          semanticLabel: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Aligned, because the bar hands its title a tight width and the
        // field's own cap would otherwise not apply.
        title: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SearchField(
            controller: _controller,
            autofocus: widget.initialQuery.isEmpty,
            showShortcut: false,
            // The whole bar on a phone; a comfortable field on a desktop.
            maxWidth: mobile ? double.infinity : 560,
            onSubmitted: (_) => _remember(),
          ),
        ),
      ),
      body: PageContainer(
        scrollable: true,
        maxWidth: _maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!results.isEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.layoutTheme.gap(GapSize.xs),
                ),
                child: Text.rich(
                  TextSpan(
                    text: results.total == 1
                        ? '1 result'
                        : '${results.total} results',
                    children: [
                      TextSpan(
                        text: ' for ${query.trim().toLowerCase()}',
                        // A copy of the theme's style, so the lighter
                        // weight gets the font's regular face.
                        style: theme.textTheme.h4.copyWith(
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  style: theme.textTheme.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap.md(),
            ],
            body,
          ],
        ),
      ),
    );
  }
}

/// The kinds of result with their counts: rows in a card beside the
/// results, or chips over them that scroll sideways.
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.results,
    required this.selected,
    required this.asRail,
    required this.onSelected,
  });

  final SearchResults results;
  final SearchCategory selected;
  final bool asRail;
  final ValueChanged<SearchCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (!asRail) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: homeTightGap,
          children: [
            for (final category in SearchCategory.values)
              if (results.countOf(category) > 0)
                Chip(
                  label: Text(
                    '${category.label} · ${results.countOf(category)}',
                  ),
                  selected: category == selected,
                  onSelected: (_) => onSelected(category),
                ),
          ],
        ),
      );
    }

    final inset = theme.layoutTheme.gap(GapSize.sm);
    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              homeRailInset,
              homeRailInset,
              homeRailInset,
              homeSnugGap,
            ),
            child: Semantics(
              header: true,
              child: Text(
                'Show results for',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.cardTheme.titleStyle ??
                    theme.textTheme.large.copyWith(color: scheme.foreground),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(inset, 0, inset, inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final category in SearchCategory.values)
                  Semantics(
                    selected: category == selected,
                    child: Button.raw(
                      variant: category == selected
                          ? ButtonVariant.secondary
                          : ButtonVariant.ghost,
                      enabled: results.countOf(category) > 0,
                      // The home profile card's shortcut row.
                      height: 38,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: homeSnugGap,
                      ),
                      gap: homeSnugGap,
                      iconSize: 20,
                      mainAxisAlignment: MainAxisAlignment.start,
                      foregroundColor: category == selected
                          ? scheme.tint
                          : scheme.foregroundSubtle,
                      leading: Icon(category.icon),
                      trailing: Text(
                        '${results.countOf(category)}',
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: category == selected
                              ? scheme.tint
                              : scheme.mutedForeground,
                        ),
                      ),
                      onPressed: () => onSelected(category),
                      child: Expanded(
                        child: Text(
                          category.label,
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
