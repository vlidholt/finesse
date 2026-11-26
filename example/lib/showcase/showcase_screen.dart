import 'package:example/common/app_state.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/showcase/showcase_cards.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
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
            const _Grid(),
            const Gap.xl(),
          ],
        ),
      ),
    );
  }
}

/// The page's header: what una is, and two ways to change how it looks —
/// a style and a palette — that act on the whole app.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mobile = theme.formFactor == FormFactor.mobile;
    return SignalBuilder(
      builder: (context, _) {
        final configSignal = themeConfigProvider.of(context);
        final config = configSignal.value;
        final palette = ColorPalette.of(config);

        final intro = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge.secondary(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIconsFill.sparkle,
                    size: 12,
                    color: scheme.tint,
                  ),
                  const Gap.xs(),
                  const Text('A design system for Flutter'),
                ],
              ),
            ),
            const Gap.md(),
            Text(
              'Interfaces that feel at home, on every screen.',
              style: (mobile ? theme.textTheme.h2 : theme.textTheme.h1)
                  .copyWith(color: scheme.foreground),
            ),
            const Gap.sm(),
            Text(
              'Over a hundred components, four styles, twenty-one palettes '
              'and a phone layout for each — Liquid Glass on Apple '
              'platforms, frosted glass everywhere else. Change the look '
              'below and every card follows.',
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
                  trailing: const PhosphorIcon(PhosphorIconsRegular.arrowRight),
                  onPressed: () => appSectionProvider.of(context).value =
                      AppSection.components,
                  child: const Text('Browse components'),
                ),
              ],
            ),
          ],
        );

        final switches = Card(
          title: const Text('Try a look'),
          description: const Text('Applies to the whole app.'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: theme.layoutTheme.gap(GapSize.md),
            children: [
              SegmentedControl<StylePreset>(
                expand: true,
                value: config.style,
                onChanged: (style) =>
                    configSignal.value = config.copyWith(style: style),
                segments: [
                  for (final style in StylePreset.values)
                    Segment(value: style, label: Text(style.label)),
                ],
              ),
              Wrap(
                spacing: theme.layoutTheme.gap(GapSize.sm),
                runSpacing: theme.layoutTheme.gap(GapSize.sm),
                children: [
                  for (final p in _heroPalettes)
                    _Swatch(
                      palette: p,
                      selected: p == palette,
                      onPressed: () => configSignal.value = p.applyTo(config),
                    ),
                ],
              ),
            ],
          ),
        );

        return Padding(
          padding: EdgeInsets.only(top: theme.layoutTheme.gap(GapSize.lg)),
          child: FormFactorBuilder(
            mobile: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [intro, const Gap.lg(), switches],
            ),
            desktop: (context) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(flex: 3, child: intro),
                const Gap.xl(),
                Expanded(flex: 2, child: switches),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The palettes the header offers in one tap; the editor has them all.
const _heroPalettes = [
  ColorPalette.ocean,
  ColorPalette.graphite,
  ColorPalette.forest,
  ColorPalette.iris,
  ColorPalette.ember,
  ColorPalette.rose,
  ColorPalette.teal,
  ColorPalette.gold,
  ColorPalette.indigo,
  ColorPalette.slate,
];

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.palette,
    required this.selected,
    required this.onPressed,
  });

  final ColorPalette palette;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = palette.seed != null
        ? ColorScheme.fromSeed(palette.seed!).primary
        : palette.scheme!.light.primary;
    return Tooltip(
      builder: (context) => Text(palette.label),
      child: Pressable(
        onPressed: onPressed,
        semanticLabel: palette.label,
        builder: (context, states) => Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: selected
                  ? theme.colorScheme.foreground
                  : const Color(0x00000000),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
