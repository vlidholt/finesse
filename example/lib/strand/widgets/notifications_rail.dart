import 'package:example/strand/navigation.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/settings_controller.dart';
import 'package:example/strand/widgets/settings_links.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The left rail's "Manage notifications": the three switches people reach
/// for most, and a link to the rest.
///
/// They are the Settings page's own preferences, so a switch flipped here
/// is flipped there.
class NotificationsManageCard extends StatelessWidget {
  const NotificationsManageCard({required this.settings, super.key});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget toggle({
      required String label,
      required String detail,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) => Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.small.copyWith(
                  fontSize: 14,
                  height: 18 / 14,
                  color: scheme.foreground,
                ),
              ),
              Text(
                detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: homeFinePrint(theme),
              ),
            ],
          ),
        ),
        const Gap.md(),
        Semantics(
          label: label,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ],
    );

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => HomeSectionCard(
        title: 'Manage notifications',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FinesseColumn(
              gap: GapSize.lg,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                toggle(
                  label: 'Pause all',
                  detail: 'Mute everything for now',
                  value: settings.pauseAll,
                  onChanged: (value) =>
                      settings.update(() => settings.pauseAll = value),
                ),
                toggle(
                  label: 'Mentions',
                  detail: 'Push when someone tags you',
                  value: settings.push.contains(NotificationTopic.mentions),
                  onChanged: (_) => settings.toggle(
                    settings.push,
                    NotificationTopic.mentions,
                  ),
                ),
                toggle(
                  label: 'Job matches',
                  detail: 'Email for roles that fit your profile',
                  value: settings.emailed.contains(NotificationTopic.jobs),
                  onChanged: (_) => settings.toggle(
                    settings.emailed,
                    NotificationTopic.jobs,
                  ),
                ),
              ],
            ),
            const Gap.lg(),
            Button.secondary(
              width: double.infinity,
              gap: homeTightGap,
              textStyle: theme.textTheme.small,
              trailing: const Icon(PhosphorIconsRegular.caretRight, size: 14),
              onPressed: () =>
                  openSettings(context, SettingsSection.notifications),
              child: const Flexible(
                child: Text(
                  'All notification settings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The right rail's "Your week": three figures the notifications keep
/// referring to, with a link to the profile's analytics.
class NotificationsWeekCard extends StatelessWidget {
  const NotificationsWeekCard({super.key});

  static const _stats = [
    (PhosphorIconsRegular.eye, '128', 'Profile viewers', '+12%'),
    (PhosphorIconsRegular.chartLineUp, '2,431', 'Post impressions', '+38%'),
    (PhosphorIconsRegular.magnifyingGlass, '312', 'Search appearances', '+6%'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return HomeSectionCard(
      title: 'Your week',
      trailing: HomeTextLink(
        'Analytics',
        onPressed: () => context.goTo(StrandDestination.profile),
        style: theme.textTheme.small.copyWith(color: scheme.tint),
      ),
      child: FinesseColumn(
        gap: GapSize.md,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (icon, value, label, change) in _stats)
            Row(
              children: [
                IconTile(icon: Icon(icon), size: 36, iconSize: 18),
                const Gap.raw(homeSnugGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        maxLines: 1,
                        style: theme.textTheme.p.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.foreground,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: homeFinePrint(theme),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.trendUp,
                  size: 14,
                  color: scheme.tint,
                ),
                const Gap.xs(),
                Text(
                  change,
                  style: theme.textTheme.small.copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.tint,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
