import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The right rail's "Trending in design" card: five ranked topics.
class HomeTrendingCard extends StatelessWidget {
  const HomeTrendingCard({super.key});

  /// The rank's column and the glyphs that end the heading and each row.
  static const _markSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return HomeSectionCard(
      title: 'Trending in design',
      trailing: Icon(
        PhosphorIconsRegular.sparkle,
        size: _markSize,
        color: scheme.tint,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        // As in the comment thread: 14 between rows of two lines.
        spacing: homeLooseGap,
        children: [
          for (final (index, trend) in HomeData.trends.indexed)
            Pressable(
              onPressed: () {},
              builder: (context, states) => FocusRing(
                visible: states.contains(WidgetState.focused),
                borderRadius: theme.radii.sm,
                child: FinesseRow(
                  gap: GapSize.md,
                  children: [
                    SizedBox(
                      width: _markSize,
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.small.copyWith(
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: scheme.mutedForeground,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trend.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.p.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.foreground,
                              decoration: states.contains(WidgetState.hovered)
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          ),
                          Text(
                            trend.posts,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: homeFinePrint(theme),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      PhosphorIconsRegular.trendUp,
                      size: _markSize,
                      color: scheme.tint,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The links under the right rail: About, Accessibility, Privacy…
class HomeFooterLinks extends StatelessWidget {
  const HomeFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = homeFinePrint(theme);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.layoutTheme.gap(GapSize.sm),
        vertical: theme.layoutTheme.gap(GapSize.xs),
      ),
      child: Wrap(
        spacing: homeLooseGap,
        runSpacing: homeTightGap,
        children: [
          for (final link in HomeData.footerLinks)
            HomeTextLink(link, onPressed: () {}, style: style),
          Text(HomeData.copyright, style: style),
        ],
      ),
    );
  }
}
