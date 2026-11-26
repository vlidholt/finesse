import 'package:example/common/app_state.dart';
import 'package:example/showcase/showcase_cards.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// What the app opens on: the components at their best, as the pieces of
/// real screens, under a header that restyles the whole page on the spot.
///
/// Everything here is the package's own widgets on the editor's theme, so
/// a change in the theme editor — or in the header's quick switches —
/// shows on every card at once.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: PageContainer(
        scrollable: true,
        maxWidth: 1280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Hero(),
            const Gap.xl(),
            const ShowcaseStats(),
            const Gap.lg(),
            const ShowcaseAnalytics(),
            const Gap.lg(),
            const _Grid(),
            const Gap.xl(),
          ],
        ),
      ),
    );
  }
}

/// The page's header: what una is, and the two ways on — the theme editor,
/// which restyles everything here, and the reference.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mobile = theme.formFactor == FormFactor.mobile;
    return Padding(
      padding: EdgeInsets.only(top: theme.layoutTheme.gap(GapSize.lg)),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          // A measure a headline and a paragraph read well at.
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Interfaces that feel at home, on every screen.',
                style: (mobile ? theme.textTheme.h2 : theme.textTheme.h1)
                    .copyWith(color: scheme.foreground),
              ),
              const Gap.sm(),
              Text(
                'Over a hundred components, four looks and any colour you '
                'like, with a phone layout for each — Liquid Glass on Apple '
                'platforms, frosted glass everywhere else. Open the theme '
                'editor and every card below follows.',
                style: theme.textTheme.lead.copyWith(
                  color: scheme.mutedForeground,
                ),
              ),
              const Gap.lg(),
              Wrap(
                spacing: theme.layoutTheme.gap(GapSize.sm),
                runSpacing: theme.layoutTheme.gap(GapSize.sm),
                children: [
                  Button(
                    leading: const PhosphorIcon(
                      PhosphorIconsRegular.paintBrush,
                    ),
                    onPressed: () =>
                        themeEditorOpenProvider.of(context).value = true,
                    child: const Text('Customize the theme'),
                  ),
                  Button.outline(
                    onPressed: () => appSectionProvider.of(context).value =
                        AppSection.components,
                    child: const Text('Browse components'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cards, in as many columns as the page has room for, each column
/// filled in turn so the order reads across.
class _Grid extends StatelessWidget {
  const _Grid();

  @override
  Widget build(BuildContext context) {
    final gap = Theme.of(context).layoutTheme.gap(GapSize.lg);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1040
            ? 3
            : width >= 680
            ? 2
            : 1;
        final cards = showcaseCards(columns: columns);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: gap,
          children: [
            for (var c = 0; c < columns; c++)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: gap,
                  children: [
                    for (var i = c; i < cards.length; i += columns) cards[i],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
