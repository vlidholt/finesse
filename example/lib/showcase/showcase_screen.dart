import 'package:example/common/app_state.dart';
import 'package:example/showcase/showcase_cards.dart';
import 'package:example/showcase/showcase_demos.dart';
import 'package:example/showcase/showcase_layout.dart';
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
    final gap = theme.layoutTheme.gap(GapSize.lg);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: PageContainer(
        scrollable: true,
        maxWidth: 1280,
        // One grid for the whole page, so every row lines up with the
        // columns of the others.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = ShowcaseColumns.of(constraints.maxWidth, gap);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: gap),
                  child: ShowcaseHeader(columns: columns, text: const _Hero()),
                ),
                const Gap.xl(),
                ShowcaseMasonry(
                  columns: columns,
                  children: showcaseOpeningCards(columns: columns.count),
                ),
                SizedBox(height: gap),
                ShowcaseAnalytics(columns: columns),
                SizedBox(height: gap),
                ShowcaseMasonry(
                  columns: columns,
                  children: showcaseClosingCards(columns: columns.count),
                ),
                const Gap.xl(),
              ],
            );
          },
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
    return Align(
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
              'Over a hundred beautifully crafted components that adapt '
              'seamlessly across desktop, mobile, and web. Liquid Glass on '
              'Apple platforms. Includes skills for agentic engineering.',
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
                  leading: const PhosphorIcon(PhosphorIconsRegular.paintBrush),
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
    );
  }
}
