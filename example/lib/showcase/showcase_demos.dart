import 'package:example/showcase/showcase_layout.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';
import 'package:url_launcher/url_launcher.dart';

/// An app built with the package, published on its own page.
class _Demo {
  const _Demo(this.name, this.slug, this.description);

  final String name;
  final String slug;

  /// What the app is, in a few words.
  final String description;

  String get icon => 'assets/images/demo_$slug.png';
  Uri get url => Uri.parse('https://vlidholt.github.io/una_$slug/');
}

const _demos = [
  _Demo('Una Social', 'social', 'A feed, stories, groups and a messenger'),
  _Demo('Una Cowork', 'cowork', 'Team boards with cards you drag'),
  _Demo('Una Banking', 'banking', 'Accounts, cards, payments and savings'),
  _Demo('Una Dating', 'dating', 'Profiles to swipe, matches and chat'),
];

/// The apps made with the package, beside the header: one tile each, its
/// icon, name and what it is, opening the app in a new tab.
///
/// [perRow] tiles to a row, which sit on the page's grid: two to a column
/// or four across two.
class ShowcaseDemos extends StatelessWidget {
  const ShowcaseDemos({required this.perRow, super.key});

  final int perRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = theme.layoutTheme.gap(GapSize.lg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Apps built with una',
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ),
        const Gap.sm(),
        // Rows of equal shares, not a wrap: the shares meet the page's
        // columns to the pixel, and a row's tiles are as tall as each other.
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: [
            for (var i = 0; i < _demos.length; i += perRow)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: gap,
                  children: [
                    for (final demo in _demos.skip(i).take(perRow))
                      Expanded(child: _DemoTile(demo: demo)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inset = theme.layoutTheme.gap(GapSize.md);
    return Card(
      style: CardTheme(padding: EdgeInsets.all(inset)),
      semanticLabel: '${demo.name}: ${demo.description}. Opens in a new tab',
      onTap: () => launchUrl(demo.url, webOnlyWindowName: '_blank'),
      // The label says it all; the tile's text would only repeat it.
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: theme.radii.lg,
                  child: Image.asset(demo.icon, width: 40, height: 40),
                ),
                const Spacer(),
                PhosphorIcon(
                  PhosphorIconsRegular.arrowUpRight,
                  size: 16,
                  color: scheme.mutedForeground,
                ),
              ],
            ),
            const Gap.md(),
            Text(
              demo.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.small.copyWith(
                color: scheme.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              demo.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
}

/// The page's header and the demos beside it: the text two columns wide
/// and the demos in the third on a desktop, the demos four across under
/// the text at two columns, and two by two under it on a phone.
class ShowcaseHeader extends StatelessWidget {
  const ShowcaseHeader({
    required this.columns,
    required this.text,
    super.key,
  });

  final ShowcaseColumns columns;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    if (columns.count >= 3) {
      return ShowcaseSpanRow(
        columns: columns,
        spans: const [2, 1],
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [text, const ShowcaseDemos(perRow: 2)],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        text,
        const Gap.xl(),
        ShowcaseDemos(perRow: columns.count >= 2 ? 4 : 2),
      ],
    );
  }
}
