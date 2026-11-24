import 'package:example/strand/assets.dart';
import 'package:example/strand/data/profile_data.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/profile_common.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_links.dart';
import 'package:example/strand/widgets/strand_actions.dart';
import 'package:example/strand/widgets/user_menu.dart';
import 'package:example/strand/widgets/verified_badge.dart';
import 'package:example/strand/widgets/strand_metrics.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The top of the profile on a phone: the cover photo under the status bar
/// with the round glass buttons on it, then who the person is.
///
/// The shell shows no app bar over the profile on a phone, so the area under
/// the status bar belongs to the cover: it grows by the top safe-area inset
/// and the buttons start below it.
class ProfileMobileHeader extends StatelessWidget {
  const ProfileMobileHeader({
    required this.onBack,
    required this.onSearch,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSearch;

  /// The cover's height below the status bar, and the portrait that
  /// straddles its bottom edge: the profile's own picture sizes, on no
  /// scale.
  static const _coverHeight = 190.0;
  static const _avatarSize = 96.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final topInset = MediaQuery.paddingOf(context).top;
    final margin = (layout.pagePadding ?? const EdgeInsets.all(16))
        .resolve(Directionality.of(context))
        .left;
    final cover = _coverHeight + topInset;
    // The buttons sit 12 from the edges, inside the page's 16 margin.
    final buttonInset = layout.gap(GapSize.md);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: cover,
          child: const Image(
            image: AssetImage(StrandAssets.photoCoverMountainLake),
            fit: BoxFit.cover,
            semanticLabel: ProfileData.coverLabel,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            margin,
            cover - _avatarSize / 2,
            margin,
            0,
          ),
          child: const _Identity(),
        ),
        Positioned(
          top: topInset + buttonInset,
          left: buttonInset,
          right: buttonInset,
          child: Row(
            children: [
              ProfileCoverButton(
                icon: PhosphorIconsRegular.arrowLeft,
                semanticLabel: 'Back',
                onPressed: onBack,
              ),
              const Spacer(),
              ProfileCoverButton(
                icon: PhosphorIconsRegular.magnifyingGlass,
                semanticLabel: 'Search',
                onPressed: onSearch,
              ),
              const Gap.sm(),
              // On a phone this is the way from Strand to the component
              // library and the theme editor.
              UserMenu(
                showProfile: false,
                builder: (context, controller, _) => ProfileCoverButton(
                  icon: PhosphorIconsRegular.dotsThree,
                  semanticLabel: 'More options',
                  onPressed: controller.toggle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final layout = theme.layoutTheme;
    const person = ProfileData.person;
    // The diameter of the mutual connections' faces.
    final mutualSize = theme.avatarXs;
    // A copy of the line's own theme style, so the heavier weight gets the
    // font's semibold face.
    final strong = theme.textTheme.muted.copyWith(
      fontWeight: FontWeight.w600,
      color: scheme.foreground,
    );
    // The designs space the meta line's parts with the `xs` gap rather than
    // with word spaces.
    const gap = WidgetSpan(child: Gap.xs());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PersonAvatar(
              person,
              size: ProfileMobileHeader._avatarSize,
              // The portrait sits on the page here, not on a card.
              ringColor: scheme.background,
              ringWidth: 4,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: layout.gap(GapSize.xs)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: AvatarGroup(
                      size: mutualSize,
                      // The same 6 as the desktop's 24-point faces.
                      overlap: theme.gap(GapSize.xs),
                      children: [
                        for (final person in ProfileData.mutuals.take(3))
                          Image.asset(
                            person.avatar,
                            width: mutualSize,
                            height: mutualSize,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  ),
                  const Gap.sm(),
                  Text(
                    ProfileData.mutualCount,
                    style: theme.textTheme.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap.md(),
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
            const Gap.xs(),
            if (person.verified) VerifiedBadge(style: theme.textTheme.h3),
          ],
        ),
        const Gap.xs(),
        Text(
          person.headline,
          style: theme.textTheme.p.copyWith(color: scheme.foregroundSubtle),
        ),
        const Gap.sm(),
        Row(
          children: [
            PhosphorIcon(
              PhosphorIconsRegular.mapPin,
              size: theme.iconBeside(theme.textTheme.muted),
              color: scheme.mutedForeground,
            ),
            const Gap.xs(),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '${ProfileData.city} ·'),
                    gap,
                    TextSpan(text: ProfileData.followers, style: strong),
                    gap,
                    const TextSpan(text: '\u00A0followers ·'),
                    gap,
                    TextSpan(text: ProfileData.connections, style: strong),
                    gap,
                    const TextSpan(text: '\u00A0connections'),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.muted,
              ),
            ),
          ],
        ),
        const Gap.md(),
        FinesseRow(
          gap: GapSize.sm,
          children: [
            Expanded(
              child: Button(
                leading: const PhosphorIcon(PhosphorIconsRegular.plusCircle),
                onPressed: () => openSettings(context, SettingsSection.privacy),
                child: const _ButtonLabel('Open to'),
              ),
            ),
            Expanded(
              child: Button.outline(
                onPressed: () => openSettings(context, SettingsSection.account),
                child: const _ButtonLabel('Edit profile'),
              ),
            ),
            IconButton.secondary(
              icon: const PhosphorIcon(PhosphorIconsRegular.export),
              // Squared to the text buttons' radius, as on the desktop.
              decoration: theme.buttonDecoration(radius: theme.radius),
              semanticLabel: 'Share profile',
              onPressed: () => copyLink(
                context,
                ProfileData.publicUrl,
                title: 'Profile link copied',
              ),
            ),
          ],
        ),
        const Gap.md(),
        const ProfileStatusTile(ProfileData.openToWork, compact: true),
      ],
    );
  }
}

/// The label of a button that shares a row: it gives way, with an ellipsis,
/// rather than overflowing when the row is narrow or the text is large.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    // A button lays its label out in a row at its natural width; `Flexible`
    // lets that row shrink it.
    return Flexible(
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
