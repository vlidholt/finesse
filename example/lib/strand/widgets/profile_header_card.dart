import 'package:example/strand/assets.dart';
import 'package:example/strand/data/profile_data.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/profile_common.dart';
import 'package:example/strand/widgets/saved_items_sheet.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_links.dart';
import 'package:example/strand/widgets/strand_actions.dart';
import 'package:example/strand/widgets/verified_badge.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The desktop profile's first card: the cover photo, who the person is, the
/// status tiles and the tab bar that switches the sections below it.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.tab,
    required this.onTabSelected,
    super.key,
  });

  final ProfileTab tab;
  final ValueChanged<ProfileTab> onTabSelected;

  /// The cover's height, and the portrait that straddles its bottom edge.
  static const _coverHeight = 260.0;
  static const _avatarSize = 152.0;

  /// The identity block is inset further than a card's content: 28, a step
  /// the gap scale does not have.
  static const _inset = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;

    return Card(
      padding: EdgeInsets.zero,
      // A step rounder than the cards under it.
      radius: theme.radii.xl3,
      rowMainAxisSize: MainAxisSize.max,
      columnCrossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _coverHeight,
                child: Image(
                  image: AssetImage(StrandAssets.photoCoverMountainLake),
                  fit: BoxFit.cover,
                  semanticLabel: ProfileData.coverLabel,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _inset,
                  _coverHeight - _avatarSize / 2,
                  _inset,
                  layout.gap(GapSize.xl),
                ),
                child: const _Identity(),
              ),
              PositionedDirectional(
                top: layout.gap(GapSize.lg),
                end: layout.gap(GapSize.lg),
                child: ProfileCoverButton(
                  icon: PhosphorIconsRegular.camera,
                  label: 'Edit cover',
                  onPressed: () =>
                      openSettings(context, SettingsSection.account),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: layout.gap(GapSize.lg)),
            child: TabBar(
              selectedIndex: tab.index,
              onSelected: (index) => onTabSelected(ProfileTab.values[index]),
              tabs: [for (final tab in ProfileTab.values) Text(tab.label)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Everything between the cover and the tab bar.
class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final layout = theme.layoutTheme;
    const person = ProfileData.person;
    // A copy of the line's own theme style, so the heavier weight gets the
    // font's semibold face.
    final strong = theme.textTheme.p.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.foreground,
    );
    // Taller than the default button (36) and shorter than the large one
    // (44): the designs' own size for this row.
    const actionHeight = 40.0;
    // The diameter of the mutual connections' faces.
    const mutualSize = 24.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PersonAvatar(
              person,
              size: ProfileHeaderCard._avatarSize,
              ringColor: scheme.card,
              ringWidth: 5,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: layout.gap(GapSize.sm)),
              child: FinesseRow(
                gap: GapSize.sm,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Button.outline(
                    leading: const Icon(PhosphorIconsRegular.export),
                    onPressed: () => copyLink(
                      context,
                      ProfileData.publicUrl,
                      title: 'Profile link copied',
                    ),
                    child: const Text('Share profile'),
                  ),
                  IconButton.secondary(
                    icon: const Icon(PhosphorIconsRegular.pencilSimple),
                    iconSize: theme.buttonSizesTheme.regular?.iconSize,
                    // A square that takes the text button's radius to sit
                    // beside one, where the style's icon buttons are round.
                    decoration: theme.buttonDecoration(radius: theme.radius),
                    semanticLabel: 'Edit profile',
                    onPressed: () =>
                        openSettings(context, SettingsSection.account),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap.raw(profileSnugGap),
        Row(
          children: [
            Flexible(
              child: Semantics(
                header: true,
                child: Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.h1.copyWith(color: scheme.foreground),
                ),
              ),
            ),
            const Gap.sm(),
            if (person.verified) const VerifiedBadge(size: 22),
            if (person.pronouns case final pronouns?) ...[
              const Gap.md(),
              Text(pronouns, style: theme.textTheme.muted),
            ],
          ],
        ),
        const Gap.raw(profileInlineGap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            ProfileData.headline,
            // The headline is the one 17-point text in the designs.
            style: theme.textTheme.p.copyWith(
              fontSize: 17,
              height: 26 / 17,
              color: scheme.foregroundSubtle,
            ),
          ),
        ),
        const Gap.md(),
        Wrap(
          spacing: layout.gap(GapSize.lg),
          runSpacing: profileInlineGap,
          children: [
            for (final meta in ProfileData.meta) ProfileMetaItem(meta),
          ],
        ),
        const Gap.raw(profileSnugGap),
        Row(
          children: [
            ExcludeSemantics(
              child: AvatarGroup(
                size: mutualSize,
                children: [
                  for (final person in ProfileData.mutuals)
                    Image.asset(
                      person.avatar,
                      width: mutualSize,
                      height: mutualSize,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
            ),
            const Gap.raw(profileTightGap),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: ProfileData.followers, style: strong),
                    const TextSpan(text: ' followers · '),
                    TextSpan(text: ProfileData.connections, style: strong),
                    const TextSpan(
                      text: ' connections · ${ProfileData.mutualSummary}',
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.p.copyWith(
                  color: scheme.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        const Gap.raw(profileRoomyGap),
        Wrap(
          spacing: layout.gap(GapSize.sm),
          runSpacing: layout.gap(GapSize.sm),
          children: [
            Button(
              height: actionHeight,
              leading: const Icon(PhosphorIconsRegular.plusCircle),
              onPressed: () => openSettings(context, SettingsSection.privacy),
              child: const Text('Open to'),
            ),
            Button.outline(
              height: actionHeight,
              onPressed: () => openSettings(context, SettingsSection.account),
              child: const Text('Add section'),
            ),
            Button.outline(
              height: actionHeight,
              onPressed: () => showSavedItems(context),
              child: const Text('Resources'),
            ),
          ],
        ),
        const Gap.raw(profileRoomyGap),
        const _StatusTiles(),
      ],
    );
  }
}

/// "Open to work" and "Available for talks": side by side, or stacked when
/// the card is too narrow for two readable tiles.
class _StatusTiles extends StatelessWidget {
  const _StatusTiles();

  @override
  Widget build(BuildContext context) {
    final gap = Theme.of(context).layoutTheme.gap(GapSize.md);
    const tiles = [
      ProfileStatusTile(ProfileData.openToWork),
      ProfileStatusTile(ProfileData.availableForTalks),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: tiles,
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: [for (final tile in tiles) Expanded(child: tile)],
          ),
        );
      },
    );
  }
}
