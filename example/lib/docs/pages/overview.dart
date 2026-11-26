import 'package:example/docs/docs.dart';
import 'package:example/screens/components_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Every component doc page by category — the landing page of the
/// Components section.
///
/// A row of chips at the top jumps to a category; each category is a
/// heading with its icon and what its components are for, over a grid of
/// cards, one per page.
class ComponentsOverview extends StatefulWidget {
  const ComponentsOverview({super.key, required this.categories});

  final List<DocCategory> categories;

  @override
  State<ComponentsOverview> createState() => _ComponentsOverviewState();
}

class _ComponentsOverviewState extends State<ComponentsOverview> {
  final _sectionKeys = <String, GlobalKey>{};

  GlobalKey _keyOf(DocCategory category) =>
      _sectionKeys.putIfAbsent(category.title, GlobalKey.new);

  void _open(String slug) {
    context.findAncestorStateOfType<ComponentsScreenState>()?.open(slug);
  }

  void _jumpTo(DocCategory category) {
    final section = _keyOf(category).currentContext;
    if (section == null) return;
    final motion = Motion.of(context);
    Scrollable.ensureVisible(
      section,
      alignment: 0,
      duration: motion.smooth.settleDuration,
      curve: motion.smooth.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // The cards are links: a press on one opens its page rather than
    // starting a selection of the page's text.
    return SelectionContainer.disabled(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Theme.of(context).layoutTheme.gap(GapSize.sm),
            runSpacing: Theme.of(context).layoutTheme.gap(GapSize.sm),
            children: [
              for (final category in widget.categories)
                Chip(
                  leading: PhosphorIcon(category.icon),
                  label: Text(category.title),
                  onPressed: () => _jumpTo(category),
                ),
            ],
          ),
          for (final category in widget.categories) ...[
            const Gap(10),
            _CategorySection(
              key: _keyOf(category),
              category: category,
              onOpen: _open,
            ),
          ],
        ],
      ),
    );
  }
}

/// One category of the overview: its heading, then a card per page.
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    super.key,
    required this.category,
    required this.onOpen,
  });

  final DocCategory category;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = theme.layoutTheme.gap(GapSize.md);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Row(
            children: [
              IconTile(icon: PhosphorIcon(category.icon)),
              const Gap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            category.title,
                            style: theme.textTheme.h4,
                          ),
                        ),
                        const Gap.sm(),
                        Badge.secondary(
                          child: Text('${category.items.length}'),
                        ),
                      ],
                    ),
                    const Gap.xs(),
                    Text(category.description, style: theme.textTheme.muted),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap.lg(),
        // On a phone the pages are rows of one list, a screen's worth of
        // them at a glance; with room for a grid, a card each.
        if (theme.formFactor == FormFactor.mobile)
          ListSection(
            margin: EdgeInsets.zero,
            children: [
              for (final doc in category.items)
                ListTile(
                  title: Text(doc.title),
                  subtitle: Text(_plain(doc.description)),
                  showChevron: true,
                  onTap: () => onOpen(doc.slug),
                ),
            ],
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 720 ? 3 : 2;
              final cardWidth = (width - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final doc in category.items)
                    SizedBox(
                      width: cardWidth,
                      child: _PageCard(doc: doc, onOpen: onOpen),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// A card that opens one doc page: its title and the start of its
/// description.
class _PageCard extends StatelessWidget {
  const _PageCard({required this.doc, required this.onOpen});

  final ComponentDoc doc;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      onTap: () => onOpen(doc.slug),
      title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      // Two lines whatever the description's length, so the cards of a
      // row are one height: the empty lines hold the space, the text lies
      // over them.
      description: Stack(
        children: [
          const ExcludeSemantics(child: Text(' \n ', maxLines: 2)),
          Text(
            _plain(doc.description),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// [description] without its `code` marks: the doc page renders them as
/// inline code; in a card or a row they are plain words.
String _plain(String description) => description.replaceAll('`', '');
