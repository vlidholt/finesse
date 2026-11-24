import 'package:example/strand/data.dart';
import 'package:example/strand/data/network_data.dart';
import 'package:example/strand/data/search_data.dart';
import 'package:example/strand/navigation.dart';
import 'package:example/strand/session.dart';
import 'package:example/strand/widgets/home_pieces.dart';
import 'package:example/strand/widgets/person_avatar.dart';
import 'package:example/strand/widgets/strand_pieces.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Opens a short preview of [person]: who they are, how the user knows
/// them, and the two things to do about it — connect and message.
///
/// It is what a name or a portrait leads to anywhere in Strand. Only the
/// signed-in user has a full profile page, so for them it goes straight
/// there.
Future<void> showPersonPreview(BuildContext context, Person person) async {
  if (person == People.me) {
    context.leaveTo(StrandDestination.profile);
    return;
  }
  final destination = await showDialog<StrandDestination>(
    context: context,
    builder: (context) => _PersonPreview(person),
  );
  if (destination != null && context.mounted) context.leaveTo(destination);
}

/// Opens a short preview of [company]: what it is, how many roles it has
/// open, and a "Follow" button.
Future<void> showCompanyPreview(BuildContext context, Company company) async {
  final destination = await showDialog<StrandDestination>(
    context: context,
    builder: (context) => _CompanyPreview(company),
  );
  if (destination != null && context.mounted) context.leaveTo(destination);
}

/// The width the previews are capped at: a card, not a page.
const _previewConstraints = BoxConstraints(maxWidth: 400);

class _PersonPreview extends StatelessWidget {
  const _PersonPreview(this.person);

  final Person person;

  /// How the user knows [person], from the Network screen's lists.
  ({List<Person> mutuals, int count})? get _mutuals {
    for (final entry in NetworkData.suggestions) {
      if (entry.person == person) {
        return (mutuals: entry.mutuals, count: entry.mutualCount);
      }
    }
    for (final entry in NetworkData.invitations) {
      if (entry.person == person) {
        return (mutuals: entry.mutuals, count: entry.mutualCount);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final network = context.strand.network;

    return ListenableBuilder(
      listenable: network,
      builder: (context, _) {
        final connected = network.isConnected(person);
        final mutuals = _mutuals;
        return Dialog(
          constraints: _previewConstraints,
          closeIconData: PhosphorIconsRegular.x,
          semanticLabel: person.name,
          actions: [
            Button.outline(
              leading: const Icon(PhosphorIconsRegular.paperPlaneTilt),
              onPressed: () =>
                  Navigator.of(context).pop(StrandDestination.messages),
              child: const Text('Message'),
            ),
            if (connected)
              Button.secondary(
                leading: const Icon(PhosphorIconsRegular.check),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Connected'),
              )
            else
              Button(
                leading: Icon(
                  network.isRequested(person)
                      ? PhosphorIconsRegular.clock
                      : PhosphorIconsRegular.userPlus,
                ),
                onPressed: () => network.toggleRequest(person),
                child: Text(
                  network.isRequested(person) ? 'Pending' : 'Connect',
                ),
              ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PersonAvatar(
                person,
                size: 72,
                showOnline: person.online,
                onlineRingColor: scheme.popover,
              ),
              const Gap.md(),
              PersonName(
                person,
                style: theme.textTheme.h3.copyWith(color: scheme.foreground),
              ),
              const Gap.raw(homeHairGap),
              Text(
                person.headline,
                textAlign: TextAlign.center,
                style: theme.textTheme.muted.copyWith(
                  color: scheme.foregroundSubtle,
                ),
              ),
              if (person.location case final location?) ...[
                const Gap.sm(),
                Row(
                  mainAxisSize: MainAxisSize.min,
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
              const Gap.md(),
              if (connected)
                Text(
                  '1st · In your network',
                  style: homeFinePrint(theme),
                )
              else if (mutuals != null)
                MutualsLine(
                  people: mutuals.mutuals,
                  label: '${mutuals.count} mutual connections',
                  size: 20,
                )
              else
                Text('2nd · Not connected yet', style: homeFinePrint(theme)),
            ],
          ),
        );
      },
    );
  }
}

class _CompanyPreview extends StatelessWidget {
  const _CompanyPreview(this.company);

  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final network = context.strand.network;
    final entry = SearchData.companies.firstWhere(
      (entry) => entry.company == company,
      orElse: () => SearchCompany(company, '', 0),
    );
    final roles = entry.openRoles;

    return ListenableBuilder(
      listenable: network,
      builder: (context, _) => Dialog(
        constraints: _previewConstraints,
        closeIconData: PhosphorIconsRegular.x,
        semanticLabel: company.name,
        actions: [
          Button.outline(
            leading: const Icon(PhosphorIconsRegular.briefcase),
            onPressed: () => Navigator.of(context).pop(StrandDestination.jobs),
            child: Text(roles == 0 ? 'Browse jobs' : 'See open roles'),
          ),
          Button.raw(
            variant: network.isFollowingPage(company)
                ? ButtonVariant.secondary
                : ButtonVariant.primary,
            leading: Icon(
              network.isFollowingPage(company)
                  ? PhosphorIconsRegular.check
                  : PhosphorIconsRegular.plus,
            ),
            onPressed: () => network.togglePage(company),
            child: Text(
              network.isFollowingPage(company) ? 'Following' : 'Follow',
            ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StrandMark(asset: company.logo, label: company.name, size: 64),
            const Gap.md(),
            Text(
              company.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.h3.copyWith(color: scheme.foreground),
            ),
            if (entry.tagline.isNotEmpty) ...[
              const Gap.raw(homeHairGap),
              Text(
                entry.tagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.muted.copyWith(
                  color: scheme.foregroundSubtle,
                ),
              ),
            ],
            const Gap.md(),
            Text(
              [
                switch (roles) {
                  0 => 'No open roles right now',
                  1 => '1 open role',
                  _ => '$roles open roles',
                },
                ?company.website,
              ].join(' · '),
              textAlign: TextAlign.center,
              style: homeFinePrint(theme),
            ),
          ],
        ),
      ),
    );
  }
}
