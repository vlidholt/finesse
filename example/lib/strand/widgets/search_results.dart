import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/data/jobs_data.dart';
import 'package:example/strand/data/search_data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/jobs_job_card.dart';
import 'package:example/strand/widgets/network_controller.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/search_history.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// What happens when a search result is chosen. The host — the app bar's
/// dropdown or the search page — closes itself and goes there.
@immutable
class SearchCallbacks {
  const SearchCallbacks({
    required this.onPerson,
    required this.onJob,
    required this.onPost,
    required this.onCompany,
  });

  final ValueChanged<Person> onPerson;
  final ValueChanged<Job> onJob;
  final ValueChanged<SearchPost> onPost;
  final ValueChanged<Company> onCompany;
}

/// Text with every occurrence of the query's words picked out: semibold, in
/// the foreground colour, on the accent wash.
class HighlightedText extends StatelessWidget {
  const HighlightedText(
    this.text, {
    required this.query,
    required this.style,
    this.maxLines = 1,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // A copy of the caller's style, so the heavier weight resolves to the
    // font's own face.
    final match = style.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.foreground,
      backgroundColor: scheme.accent,
    );
    return Text.rich(
      TextSpan(children: _spans(match)),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<TextSpan> _spans(TextStyle match) {
    final terms = SearchData.termsOf(query);
    if (terms.isEmpty) return [TextSpan(text: text)];
    final lower = text.toLowerCase();

    // Mark every character a term covers, then emit runs.
    final marked = List.filled(text.length, false);
    for (final term in terms) {
      var from = lower.indexOf(term);
      while (from >= 0 && from + term.length <= text.length) {
        marked.fillRange(from, from + term.length, true);
        from = lower.indexOf(term, from + term.length);
      }
    }
    final spans = <TextSpan>[];
    var start = 0;
    for (var i = 1; i <= text.length; i++) {
      if (i == text.length || marked[i] != marked[start]) {
        spans.add(
          TextSpan(
            text: text.substring(start, i),
            style: marked[start] ? match : null,
          ),
        );
        start = i;
      }
    }
    return spans;
  }
}

/// A result row: something at the start, lines of text, something at the
/// end, on a tile that highlights under the pointer.
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.leading,
    required this.lines,
    required this.onPressed,
    this.trailing,
  });

  final Widget leading;
  final List<Widget> lines;
  final Widget? trailing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final layout = theme.layoutTheme;
    return Pressable(
      onPressed: onPressed,
      builder: (context, states) {
        final hovered =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: theme.radii.lg,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: layout.gap(GapSize.md),
              vertical: homeSnugGap,
            ),
            decoration: BoxDecoration(
              color: hovered ? scheme.muted : null,
              borderRadius: theme.radii.lg,
            ),
            child: Row(
              children: [
                leading,
                const Gap.md(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: lines,
                  ),
                ),
                if (trailing case final trailing?) ...[
                  const Gap.sm(),
                  trailing,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The results of a query, as rows.
///
/// With [category] set to one kind it lists every result of that kind.
/// With [SearchCategory.all] it lists the first few of each kind under a
/// heading, with a "See all" link that calls [onCategory].
///
/// [compact] is the app bar's dropdown: smaller marks, no buttons at the
/// end of a row, and the headings alone separate the kinds. Otherwise each
/// kind is a card of its own.
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    required this.query,
    required this.results,
    required this.callbacks,
    required this.network,
    this.category = SearchCategory.all,
    this.onCategory,
    this.compact = false,
    super.key,
  });

  final String query;
  final SearchResults results;
  final SearchCallbacks callbacks;
  final NetworkController network;
  final SearchCategory category;
  final ValueChanged<SearchCategory>? onCategory;
  final bool compact;

  /// How many results of a kind "All" shows before "See all".
  int get _preview => compact ? 2 : 3;

  double get _markSize => compact ? 36 : 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final kinds = category == SearchCategory.all
        ? [
            for (final kind in SearchCategory.kinds)
              if (results.countOf(kind) > 0) kind,
          ]
        : [category];

    final name = theme.textTheme.large.copyWith(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: scheme.foregroundSubtle,
    );
    final detail = theme.textTheme.muted;
    final fine = homeFinePrint(theme);
    final narrow = theme.formFactor == FormFactor.mobile;

    List<Widget> rowsOf(SearchCategory kind, int limit) => switch (kind) {
      SearchCategory.people => [
        for (final person in results.people.take(limit))
          _ResultTile(
            onPressed: () => callbacks.onPerson(person),
            leading: PersonAvatar(person, size: _markSize),
            lines: [
              HighlightedText(person.name, query: query, style: name),
              HighlightedText(person.headline, query: query, style: detail),
            ],
            trailing: compact
                ? null
                : network.isConnected(person)
                ? Text('1st', style: fine)
                : StrandPillButton.connect(
                    pending: network.isRequested(person),
                    onPressed: () => network.toggleRequest(person),
                  ),
          ),
      ],
      SearchCategory.jobs => [
        for (final job in results.jobs.take(limit))
          _ResultTile(
            onPressed: () => callbacks.onJob(job),
            leading: StrandMark(
              asset: job.company.logo,
              label: job.company.name,
              size: _markSize,
            ),
            lines: [
              HighlightedText(job.title, query: query, style: name),
              HighlightedText(
                '${job.company.name} · ${job.location}',
                query: query,
                style: detail,
              ),
              // A phone has no room for the tag beside a title.
              if (narrow && !compact) Text(job.salary, style: fine),
            ],
            trailing: compact || narrow ? null : JobTag(job.salary),
          ),
      ],
      SearchCategory.posts => [
        for (final post in results.posts.take(limit))
          _ResultTile(
            onPressed: () => callbacks.onPost(post),
            leading: PersonAvatar(post.author, size: _markSize),
            lines: [
              HighlightedText(
                SearchData.excerpt(post.text, query),
                query: query,
                style: name,
                maxLines: 2,
              ),
              Text(
                compact
                    ? '${post.author.name} · ${post.age}'
                    : '${post.author.name} · ${post.age} · '
                          '${formatCount(post.reactions)} reactions · '
                          '${post.comments} comments',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: fine,
              ),
            ],
          ),
      ],
      SearchCategory.companies => [
        for (final entry in results.companies.take(limit))
          _ResultTile(
            onPressed: () => callbacks.onCompany(entry.company),
            leading: StrandMark(
              asset: entry.company.logo,
              label: entry.company.name,
              size: _markSize,
            ),
            lines: [
              HighlightedText(entry.company.name, query: query, style: name),
              if (entry.tagline.isNotEmpty)
                HighlightedText(entry.tagline, query: query, style: detail),
              if (!compact)
                Text(
                  switch (entry.openRoles) {
                    0 => 'No open roles',
                    1 => '1 open role',
                    final roles => '$roles open roles',
                  },
                  style: fine,
                ),
            ],
            trailing: compact
                ? null
                : StrandPillButton.follow(
                    following: network.isFollowingPage(entry.company),
                    onPressed: () => network.togglePage(entry.company),
                  ),
          ),
      ],
      SearchCategory.all => const [],
    };

    Widget section(SearchCategory kind) {
      final count = results.countOf(kind);
      final all = category != SearchCategory.all;
      final limit = all ? count : _preview;
      final inset = theme.layoutTheme.gap(GapSize.md);
      final heading = Padding(
        padding: EdgeInsets.fromLTRB(inset, compact ? 6 : 4, inset, 6),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  compact ? kind.label : '${kind.label} · $count',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: compact
                      ? fine.copyWith(fontWeight: FontWeight.w600)
                      : theme.textTheme.large.copyWith(
                          color: scheme.foreground,
                        ),
                ),
              ),
            ),
            if (!all && count > limit && onCategory != null)
              HomeTextLink(
                'See all $count',
                onPressed: () => onCategory!(kind),
                style: theme.textTheme.small.copyWith(color: scheme.tint),
              ),
          ],
        ),
      );
      final rows = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [heading, ...rowsOf(kind, limit)],
      );
      if (compact) return rows;
      return Card(
        // The rows bring their own inset, as a conversation's do.
        padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
        child: rows,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: compact ? 4 : theme.layoutTheme.gap(GapSize.lg),
      children: [for (final kind in kinds) section(kind)],
    );
  }
}

/// What the search shows before anything is typed: the recent searches,
/// each removable, and the trending ones as chips.
class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({
    required this.history,
    required this.onPick,
    this.compact = false,
    super.key,
  });

  final SearchHistory history;

  /// Called with the search that was tapped.
  final ValueChanged<String> onPick;

  /// Whether this is the app bar's dropdown rather than the page.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inset = theme.layoutTheme.gap(GapSize.md);
    final label = compact
        ? homeFinePrint(theme).copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.large.copyWith(color: scheme.foreground);

    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final recents = history.recents;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (recents.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(inset, compact ? 6 : 4, inset, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text('Recent', style: label),
                      ),
                    ),
                    HomeTextLink(
                      'Clear',
                      onPressed: history.clear,
                      style: theme.textTheme.small.copyWith(
                        color: scheme.tint,
                      ),
                    ),
                  ],
                ),
              ),
              for (final recent in recents)
                _ResultTile(
                  onPressed: () => onPick(recent),
                  leading: Icon(
                    PhosphorIconsRegular.clockCounterClockwise,
                    size: 20,
                    color: scheme.mutedForeground,
                  ),
                  lines: [
                    Text(
                      recent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.p.copyWith(
                        color: scheme.foreground,
                      ),
                    ),
                  ],
                  trailing: IconButton.ghost(
                    width: 28,
                    height: 28,
                    iconSize: 16,
                    icon: const Icon(PhosphorIconsRegular.x),
                    foregroundColor: scheme.mutedForeground,
                    semanticLabel: 'Remove $recent',
                    onPressed: () => history.remove(recent),
                  ),
                ),
              Gap.raw(compact ? 6 : inset),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(inset, compact ? 6 : 4, inset, 10),
              child: Semantics(
                header: true,
                child: Text('Trending searches', style: label),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(inset, 0, inset, compact ? 8 : 4),
              child: Wrap(
                spacing: homeTightGap,
                runSpacing: homeTightGap,
                children: [
                  for (final trend in SearchData.trending)
                    Chip(
                      leading: const Icon(PhosphorIconsRegular.trendUp),
                      label: Text(trend),
                      onPressed: () => onPick(trend),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The honest answer to a query nothing matches.
class SearchNoResults extends StatelessWidget {
  const SearchNoResults({
    required this.query,
    required this.onPick,
    this.compact = false,
    super.key,
  });

  final String query;
  final ValueChanged<String> onPick;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Empty(
      padding: compact ? const EdgeInsets.all(20) : null,
      icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
      title: Text('No results for “${query.trim()}”'),
      description: const Text(
        'Search looks through people, job listings, posts and companies. '
        'Check the spelling, or try one of these.',
      ),
      actions: [
        for (final trend in SearchData.trending.take(compact ? 2 : 3))
          Button.outline(
            size: ButtonSize.sm,
            onPressed: () => onPick(trend),
            child: Text(trend),
          ),
      ],
    );
  }
}
