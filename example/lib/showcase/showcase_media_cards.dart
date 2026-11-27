import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

// The showcase's cards with pictures: an event, an article, a gallery and
// a list of jobs with company logos.

/// A picture at the top of a card, clipped to the card's upper corners.
class _CardPicture extends StatelessWidget {
  const _CardPicture({
    required this.asset,
    required this.label,
    this.overlay,
  });

  final String asset;
  final String label;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = (theme.cardTheme.borderRadius ?? theme.radius).resolve(
      Directionality.of(context),
    );
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: radius.topLeft,
        topRight: radius.topRight,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RevealImage.asset(
              'assets/images/$asset.jpg',
              fit: BoxFit.cover,
              semanticLabel: label,
            ),
            ?overlay,
          ],
        ),
      ),
    );
  }
}

/// The inset of a card's content, for the part under a picture.
EdgeInsets _cardInset(BuildContext context) =>
    EdgeInsets.all(Theme.of(context).layoutTheme.gap(GapSize.lg));

class ShowcaseEventCard extends StatefulWidget {
  const ShowcaseEventCard({super.key});

  @override
  State<ShowcaseEventCard> createState() => _ShowcaseEventCardState();
}

class _ShowcaseEventCardState extends State<ShowcaseEventCard> {
  bool _going = false;
  bool _saved = false;

  static const _faces = [
    'avatar_mei_tanaka',
    'avatar_julian_reyes',
    'avatar_freya_holm',
    'avatar_omar_rahimi',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      style: const CardTheme(padding: EdgeInsets.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardPicture(
            asset: 'photo_summit_stage',
            label: 'An audience facing a lit stage and its screens',
            overlay: PositionedDirectional(
              start: 12,
              top: 12,
              child: Glass(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MAR',
                      style: theme.textTheme.caption.copyWith(
                        color: scheme.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('14', style: theme.textTheme.h3),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: _cardInset(context),
            child: UnaColumn(
              gap: GapSize.md,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UnaColumn(
                  gap: GapSize.xs,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Design Systems Summit', style: theme.textTheme.large),
                    UnaRow(
                      gap: GapSize.xs,
                      children: [
                        PhosphorIcon(
                          PhosphorIconsRegular.mapPin,
                          size: 14,
                          color: scheme.mutedForeground,
                        ),
                        Text(
                          'Copenhagen · 9:00–17:00',
                          style: theme.textTheme.muted,
                        ),
                      ],
                    ),
                  ],
                ),
                UnaRow(
                  gap: GapSize.sm,
                  children: [
                    AvatarGroup(
                      size: 28,
                      children: [
                        for (final face in _faces)
                          Image.asset(
                            'assets/images/$face.jpg',
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        _going ? 'You and 128 others' : '128 going',
                        style: theme.textTheme.caption,
                      ),
                    ),
                  ],
                ),
                UnaRow(
                  gap: GapSize.sm,
                  children: [
                    Expanded(
                      child: _going
                          ? Button.secondary(
                              leading: const PhosphorIcon(
                                PhosphorIconsBold.check,
                              ),
                              onPressed: () => setState(() => _going = false),
                              child: const Text('Going'),
                            )
                          : Button(
                              onPressed: () => setState(() => _going = true),
                              child: const Text('Register'),
                            ),
                    ),
                    Toggle(
                      variant: ToggleVariant.outline,
                      value: _saved,
                      onChanged: (v) => setState(() => _saved = v),
                      semanticLabel: 'Save',
                      child: PhosphorIcon(
                        _saved
                            ? PhosphorIconsFill.bookmarkSimple
                            : PhosphorIconsRegular.bookmarkSimple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShowcaseArticleCard extends StatelessWidget {
  const ShowcaseArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      style: const CardTheme(padding: EdgeInsets.zero),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardPicture(
            asset: 'photo_workshop_team',
            label: 'A team at a whiteboard in a workshop',
          ),
          Padding(
            padding: _cardInset(context),
            child: UnaColumn(
              gap: GapSize.sm,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Badge.secondary(child: Text('Case study')),
                Text(
                  'How Halcyon rebuilt onboarding in two days',
                  style: theme.textTheme.large,
                ),
                Text(
                  'Six setup screens became two, and the rest became '
                  'optional. What a workshop, a whiteboard and one theme '
                  'did for activation.',
                  style: theme.textTheme.muted,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap.xs(),
                UnaRow(
                  gap: GapSize.sm,
                  children: [
                    const Avatar(
                      'assets/images/avatar_claire_dubois.jpg',
                      size: Size.square(28),
                      fallback: Text('C'),
                    ),
                    Expanded(
                      child: Text(
                        'Claire Dubois · 6 min read',
                        style: theme.textTheme.caption,
                      ),
                    ),
                    PhosphorIcon(
                      PhosphorIconsRegular.arrowUpRight,
                      size: 16,
                      color: scheme.mutedForeground,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShowcaseGalleryCard extends StatelessWidget {
  const ShowcaseGalleryCard({super.key});

  static const _photos = [
    ('story_mountain_meadow', 'Wildflowers on a mountain meadow'),
    ('photo_alpine_lake', 'A still alpine lake under snowy peaks'),
    ('photo_summit_stage', 'An audience before a conference stage'),
    ('photo_workshop_team', 'A team at a whiteboard'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      title: const Text('Trip to the Alps'),
      description: const Text('Four photos · shared with you'),
      action: IconButton.ghost(
        icon: const PhosphorIcon(PhosphorIconsRegular.shareNetwork),
        semanticLabel: 'Share',
        onPressed: () {},
      ),
      child: Carousel(
        aspectRatio: 4 / 3,
        loop: true,
        showIndicator: true,
        borderRadius: theme.radii.lg,
        semanticLabel: 'Photos from the trip',
        children: [
          for (final (asset, alt) in _photos)
            RevealImage.asset(
              'assets/images/$asset.jpg',
              fit: BoxFit.cover,
              semanticLabel: alt,
            ),
        ],
      ),
    );
  }
}

class ShowcaseJobsCard extends StatefulWidget {
  const ShowcaseJobsCard({super.key});

  @override
  State<ShowcaseJobsCard> createState() => _ShowcaseJobsCardState();
}

class _ShowcaseJobsCardState extends State<ShowcaseJobsCard> {
  final _saved = <String>{'Halcyon'};

  static const _jobs = [
    ('Halcyon', 'logo_halcyon', 'Senior product designer', 'Remote'),
    ('Birchline', 'logo_birchline', 'Design systems lead', 'Stockholm'),
    ('Lumen Labs', 'logo_lumen_labs', 'Flutter engineer', 'Hybrid'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = theme.radii.md;
    return ListSection(
      header: const Text('Jobs for you'),
      children: [
        for (final (company, logo, role, place) in _jobs)
          ListTile(
            leading: ClipRRect(
              borderRadius: radius,
              child: Image.asset(
                'assets/images/$logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(role),
            subtitle: Text('$company · $place'),
            trailing: IconButton.ghost(
              size: ButtonSize.sm,
              icon: PhosphorIcon(
                _saved.contains(company)
                    ? PhosphorIconsFill.bookmarkSimple
                    : PhosphorIconsRegular.bookmarkSimple,
                color: _saved.contains(company) ? theme.colorScheme.tint : null,
              ),
              semanticLabel: 'Save $role',
              onPressed: () => setState(
                () => _saved.contains(company)
                    ? _saved.remove(company)
                    : _saved.add(company),
              ),
            ),
            onTap: () {},
          ),
      ],
    );
  }
}
