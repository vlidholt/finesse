import 'package:example/strand/data.dart';
import 'package:example/strand/data/home_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/verified_badge.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The left rail's summary of the signed-in user: cover photo, portrait,
/// name and headline, two figures and three shortcuts.
class HomeProfileCard extends StatelessWidget {
  const HomeProfileCard({super.key});

  static const _coverHeight = 76.0;
  static const _avatarSize = 68.0;

  /// How far the portrait rises over the cover photo.
  static const _avatarOverlap = 34.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const me = People.me;
    void openProfile() => context.goTo(StrandDestination.profile);

    return Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Image.asset(
                HomeData.cover,
                height: _coverHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  homeRailInset,
                  _coverHeight - _avatarOverlap,
                  homeRailInset,
                  homeRailInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Pressable(
                      onPressed: openProfile,
                      semanticLabel: 'Your profile',
                      builder: (context, states) => FocusRing(
                        visible: states.contains(WidgetState.focused),
                        borderRadius: theme.radii.full,
                        child: PersonAvatar(
                          me,
                          size: _avatarSize,
                          ringColor: scheme.card,
                          ringWidth: 3,
                        ),
                      ),
                    ),
                    // 10 in the design, plus the sliver a portrait set on a
                    // text baseline leaves beneath it.
                    const Gap.raw(15),
                    Row(
                      children: [
                        Flexible(
                          child: HomeTextLink(
                            me.name,
                            onPressed: openProfile,
                            style: theme.textTheme.large.copyWith(
                              fontSize: 17,
                              height: 22 / 17,
                              color: scheme.foreground,
                            ),
                          ),
                        ),
                        if (me.verified) ...[
                          const Gap.raw(homeTightGap),
                          const VerifiedBadge(),
                        ],
                      ],
                    ),
                    const Gap.raw(homeHairGap),
                    Text(
                      me.headline,
                      // The muted line a point looser, in the stronger of
                      // the two secondary inks.
                      style: theme.textTheme.muted.copyWith(
                        height: 19 / 13,
                        color: scheme.foregroundSubtle,
                      ),
                    ),
                    if (me.location case final location?) ...[
                      const Gap.sm(),
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.mapPin,
                            size: 14,
                            color: scheme.mutedForeground,
                          ),
                          const Gap.xs(),
                          Flexible(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider.horizontal(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: homeRailInset,
              vertical: theme.layoutTheme.gap(GapSize.md),
            ),
            child: FinesseColumn(
              gap: GapSize.sm,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final stat in HomeData.profileStats)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stat.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.muted.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        stat.value,
                        style: theme.textTheme.small.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.tint,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider.horizontal(),
          Padding(
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final shortcut in HomeData.shortcuts)
                  Button.ghost(
                    // 38 tall and inset 10: a list row, a little roomier
                    // than the theme's 36-point button.
                    height: 38,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: homeSnugGap,
                    ),
                    gap: homeSnugGap,
                    iconSize: 20,
                    mainAxisAlignment: MainAxisAlignment.start,
                    foregroundColor: scheme.foregroundSubtle,
                    leading: Icon(shortcut.icon),
                    onPressed: () {},
                    child: Text(shortcut.label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
