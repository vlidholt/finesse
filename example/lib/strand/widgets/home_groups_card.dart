import 'package:example/strand/data.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The left rail's "Your groups" card.
class HomeGroupsCard extends StatelessWidget {
  const HomeGroupsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return HomeSectionCard(
      title: 'Your groups',
      trailing: HomeTextLink(
        'See all',
        onPressed: () {},
        style: theme.textTheme.small.copyWith(color: scheme.tint),
      ),
      child: FinesseColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final group in Groups.all)
            Pressable(
              onPressed: () {},
              builder: (context, states) => FocusRing(
                visible: states.contains(WidgetState.focused),
                borderRadius: theme.radii.md,
                child: Row(
                  children: [
                    _GroupLogo(group),
                    const Gap.raw(homeSnugGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.small.copyWith(
                              fontSize: 14,
                              height: 18 / 14,
                              color: scheme.foreground,
                              decoration: states.contains(WidgetState.hovered)
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          ),
                          Text(
                            '${group.newPosts} new posts',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: homeFinePrint(theme),
                          ),
                        ],
                      ),
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

/// A group's mark: 36 square on the control radius, with a hairline drawn
/// inside its edge so a pale logo still has an outline on a pale card.
class _GroupLogo extends StatelessWidget {
  const _GroupLogo(this.group);

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: theme.radii.md),
      foregroundDecoration: BoxDecoration(
        borderRadius: theme.radii.md,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Image.asset(
        group.logo,
        fit: BoxFit.cover,
        semanticLabel: '${group.name} logo',
      ),
    );
  }
}
