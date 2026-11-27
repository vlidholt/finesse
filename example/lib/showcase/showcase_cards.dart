import 'package:example/showcase/showcase_layout.dart';
import 'package:example/showcase/showcase_media_cards.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

// The showcase's cards: each one a moment from a real app, built only from
// the package's widgets on the current theme.

// The page is the header, a first run of cards, the revenue chart across
// the grid and the rest of the cards. The first run has to end level, or
// the chart under it leaves a hole above it in the shorter columns, so its
// cards are chosen per column count to come out even in the default look
// at every width of that count: one picture card to a column (a picture
// grows with its column) beside cards of fixed height that make up the
// difference. The rest are ordered to end close together too, and so that
// no two charts sit side by side.

/// The cards between the header and the revenue chart, in reading order,
/// for a grid of [columns].
List<Widget> showcaseOpeningCards({required int columns}) => columns >= 3
    ? const [
        // Event over payment, figures over the player, chat over the
        // gallery.
        ShowcaseEventCard(),
        ShowcaseStats(),
        _ChatCard(),
        _PlayerCard(),
        _CheckoutCard(),
        ShowcaseGalleryCard(),
      ]
    : const [
        // Event over the figures, the team over the article.
        ShowcaseEventCard(),
        _TeamCard(),
        ShowcaseArticleCard(),
        ShowcaseStats(),
      ];

/// The cards under the revenue chart, in reading order, for a grid of
/// [columns]. Below three columns the top pages leave the revenue's row
/// and come among these.
List<Widget> showcaseClosingCards({required int columns}) => columns >= 3
    ? const [
        ShowcaseArticleCard(),
        _TeamCard(),
        _NotificationsCard(),
        _ReleaseCard(),
        _GoalCard(),
        _PricingCard(),
        _BookingCard(),
        ShowcaseJobsCard(),
        _ActivityCard(),
        _ShortcutsCard(),
      ]
    : const [
        ShowcaseGalleryCard(),
        _PlayerCard(),
        _TopPagesCard(),
        _ReleaseCard(),
        _PricingCard(),
        ShowcaseJobsCard(),
        _ActivityCard(),
        _NotificationsCard(),
        _ChatCard(),
        _CheckoutCard(),
        _BookingCard(),
        _GoalCard(),
        _ShortcutsCard(),
      ];

/// Four figures, one above the other: a column of the grid.
class ShowcaseStats extends StatelessWidget {
  const ShowcaseStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnaColumn(
      gap: GapSize.lg,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Stat(
          icon: PhosphorIconsRegular.users,
          label: 'Users',
          value: '24,816',
          change: '+12.4%',
          trend: [18, 19, 21, 20, 23, 22, 25, 27, 26, 29],
        ),
        _Stat(
          icon: PhosphorIconsRegular.currencyDollar,
          label: 'Revenue',
          value: r'$48.2k',
          change: '+8.1%',
          trend: [31, 33, 32, 36, 35, 39, 41, 40, 44, 48],
        ),
        _Stat(
          icon: PhosphorIconsRegular.chartLineUp,
          label: 'Conversion',
          value: '3.62%',
          change: '+0.4%',
          trend: [3.1, 3.2, 3.15, 3.3, 3.25, 3.4, 3.38, 3.5, 3.55, 3.62],
        ),
        _Stat(
          icon: PhosphorIconsRegular.smiley,
          label: 'Rating',
          value: '4.8',
          change: '-0.1',
          trend: [4.9, 4.9, 4.85, 4.9, 4.88, 4.86, 4.84, 4.83, 4.81, 4.8],
          down: true,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.trend,
    this.down = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String change;
  final List<double> trend;
  final bool down;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = down ? scheme.destructive : scheme.success;
    return StatTile(
      icon: PhosphorIcon(icon),
      label: Text(label),
      value: Text(value),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 64,
            height: 24,
            child: Sparkline(
              values: trend,
              color: down ? scheme.destructive : null,
              semanticLabel: '$label over ten weeks',
            ),
          ),
          const Gap.xs(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                down
                    ? PhosphorIconsBold.arrowDownRight
                    : PhosphorIconsBold.arrowUpRight,
                size: 11,
                color: color,
              ),
              Text(
                change,
                style: theme.textTheme.caption.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A row of a person: their face, name and a line under it.
class _Person extends StatelessWidget {
  const _Person({
    required this.name,
    required this.line,
    required this.avatar,
    this.trailing,
  });

  final String name;
  final String line;
  final String avatar;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UnaRow(
      gap: GapSize.md,
      children: [
        Avatar(
          'assets/images/$avatar.jpg',
          size: const Size.square(36),
          fallback: Text(name.substring(0, 1)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.foreground,
                ),
              ),
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _TeamCard extends StatefulWidget {
  const _TeamCard();

  @override
  State<_TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<_TeamCard> {
  final _roles = {
    'Mei Tanaka': 'Owner',
    'Julian Reyes': 'Editor',
    'Freya Holm': 'Editor',
    'Omar Rahimi': 'Viewer',
  };

  static const _people = [
    ('Mei Tanaka', 'mei@halcyon.design', 'avatar_mei_tanaka'),
    ('Julian Reyes', 'julian@halcyon.design', 'avatar_julian_reyes'),
    ('Freya Holm', 'freya@halcyon.design', 'avatar_freya_holm'),
    ('Omar Rahimi', 'omar@birchline.co', 'avatar_omar_rahimi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      title: const Text('Team'),
      description: const Text('Invite people and choose what they can do.'),
      action: Button.outline(
        size: ButtonSize.sm,
        leading: const PhosphorIcon(PhosphorIconsRegular.userPlus),
        onPressed: () => Toaster.of(context).show(
          const Toast(
            variant: ToastVariant.success,
            title: Text('Invitation sent'),
            description: Text('They will get an email in a moment.'),
          ),
        ),
        child: const Text('Invite'),
      ),
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, email, avatar) in _people)
            _Person(
              name: name,
              line: email,
              avatar: avatar,
              trailing: SizedBox(
                width: 104,
                child: Select<String>(
                  size: ControlSize.sm,
                  value: _roles[name],
                  onChanged: name == 'Mei Tanaka'
                      ? null
                      : (role) {
                          if (role != null) setState(() => _roles[name] = role);
                        },
                  options: const [
                    SelectOption(value: 'Owner', label: 'Owner'),
                    SelectOption(value: 'Editor', label: 'Editor'),
                    SelectOption(value: 'Viewer', label: 'Viewer'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget bubble(String text, {bool mine = false}) => Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ChatBubble(
        direction: mine
            ? ChatBubbleDirection.outgoing
            : ChatBubbleDirection.incoming,
        maxWidth: 260,
        child: Text(text),
      ),
    );
    return Card(
      title: const _Person(
        name: 'Freya Holm',
        line: 'Active now',
        avatar: 'avatar_freya_holm',
      ),
      // In the header, not beside the body: a trailing widget takes a
      // column of its own and the bubbles stopped short of the edge.
      action: IconButton.ghost(
        icon: const PhosphorIcon(PhosphorIconsRegular.phone),
        semanticLabel: 'Call',
        onPressed: () {},
      ),
      child: UnaColumn(
        gap: GapSize.sm,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bubble('Did the new palette land in the build?'),
          bubble(
            'It did, and the dark mode came along by itself.',
            mine: true,
          ),
          bubble('Looks great on the iPhone. Shipping it 🚀'),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ChatBubble(
              direction: ChatBubbleDirection.incoming,
              child: TypingIndicator(color: theme.colorScheme.mutedForeground),
            ),
          ),
          const Gap.xs(),
          TextField(
            placeholder: const Text('Message'),
            trailing: IconButton.ghost(
              size: ButtonSize.sm,
              icon: const PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
              semanticLabel: 'Send',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatefulWidget {
  const _BookingCard();

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  DateTime? _day = DateTime(DateTime.now().year, DateTime.now().month, 18);
  String? _time = '10:30';

  @override
  Widget build(BuildContext context) {
    return Card(
      title: const Text('Book a session'),
      description: const Text('Thirty minutes with a design lead.'),
      footer: SizedBox(
        width: double.infinity,
        child: Button(
          onPressed: _day == null || _time == null
              ? null
              : () => Toaster.of(context).show(
                  Toast(
                    variant: ToastVariant.success,
                    title: const Text('Booked'),
                    description: Text(
                      '${_day!.day}/${_day!.month} at $_time',
                    ),
                  ),
                ),
          child: Text(_time == null ? 'Pick a time' : 'Book $_time'),
        ),
      ),
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Calendar(
              value: _day,
              onChanged: (day) => setState(() => _day = day),
              showOutsideDays: false,
            ),
          ),
          ChipGroup<String>(
            value: _time,
            onChanged: (time) => setState(() => _time = time),
            items: const [
              ChipGroupItem(value: '9:00', label: Text('9:00')),
              ChipGroupItem(value: '10:30', label: Text('10:30')),
              ChipGroupItem(value: '13:00', label: Text('13:00')),
              ChipGroupItem(value: '15:30', label: Text('15:30')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatefulWidget {
  const _PlayerCard();

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> {
  double _position = .38;
  bool _playing = true;
  bool _liked = true;

  String _time(double fraction) {
    final seconds = (fraction * 214).round();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = theme.cardTheme.borderRadius ?? theme.radius;
    return Card(
      style: const CardTheme(padding: EdgeInsets.zero),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: radius.resolve(TextDirection.ltr).topLeft,
              topRight: radius.resolve(TextDirection.ltr).topRight,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RevealImage.asset(
                    'assets/images/photo_alpine_lake.jpg',
                    fit: BoxFit.cover,
                  ),
                  PositionedDirectional(
                    start: 12,
                    top: 12,
                    child: Glass(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.waveform,
                            size: 14,
                            color: scheme.foreground,
                          ),
                          const Gap.xs(),
                          Text('Now playing', style: theme.textTheme.small),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.lg)),
            child: UnaColumn(
              gap: GapSize.sm,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alpine Morning', style: theme.textTheme.large),
                          Text(
                            'Lumen Labs · Field Recordings',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    Toggle(
                      value: _liked,
                      onChanged: (v) => setState(() => _liked = v),
                      semanticLabel: 'Like',
                      child: PhosphorIcon(
                        _liked
                            ? PhosphorIconsFill.heart
                            : PhosphorIconsRegular.heart,
                        color: _liked ? scheme.destructive : null,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _position,
                  onChanged: (v) => setState(() => _position = v),
                  semanticLabel: 'Position',
                ),
                Row(
                  children: [
                    Text(_time(_position), style: theme.textTheme.caption),
                    const Spacer(),
                    Text(_time(1), style: theme.textTheme.caption),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: theme.layoutTheme.gap(GapSize.md),
                  children: [
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsRegular.shuffle),
                      semanticLabel: 'Shuffle',
                      onPressed: () {},
                    ),
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsFill.skipBack),
                      semanticLabel: 'Previous',
                      onPressed: () {},
                    ),
                    IconButton(
                      size: ButtonSize.lg,
                      icon: PhosphorIcon(
                        _playing
                            ? PhosphorIconsFill.pause
                            : PhosphorIconsFill.play,
                      ),
                      semanticLabel: _playing ? 'Pause' : 'Play',
                      onPressed: () => setState(() => _playing = !_playing),
                    ),
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsFill.skipForward),
                      semanticLabel: 'Next',
                      onPressed: () {},
                    ),
                    IconButton.ghost(
                      icon: const PhosphorIcon(PhosphorIconsRegular.repeat),
                      semanticLabel: 'Repeat',
                      onPressed: () {},
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

class _NotificationsCard extends StatefulWidget {
  const _NotificationsCard();

  @override
  State<_NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<_NotificationsCard> {
  final _on = {'Mentions': true, 'Comments': true, 'Weekly digest': false};

  static const _icons = {
    'Mentions': PhosphorIconsRegular.at,
    'Comments': PhosphorIconsRegular.chatCircle,
    'Weekly digest': PhosphorIconsRegular.envelopeSimple,
  };

  static const _lines = {
    'Mentions': 'When someone @mentions you',
    'Comments': 'Replies to your posts',
    'Weekly digest': 'A summary every Monday',
  };

  @override
  Widget build(BuildContext context) {
    return ListSection(
      header: const Text('Notifications'),
      children: [
        for (final key in _on.keys)
          ListTile(
            leading: IconTile(icon: PhosphorIcon(_icons[key]!)),
            title: Text(key),
            subtitle: Text(_lines[key]!),
            trailing: Switch(
              value: _on[key]!,
              onChanged: (v) => setState(() => _on[key] = v),
            ),
            onTap: () => setState(() => _on[key] = !_on[key]!),
          ),
      ],
    );
  }
}

class _CheckoutCard extends StatefulWidget {
  const _CheckoutCard();

  @override
  State<_CheckoutCard> createState() => _CheckoutCardState();
}

class _CheckoutCardState extends State<_CheckoutCard> {
  bool _save = true;
  String? _country = 'se';

  @override
  Widget build(BuildContext context) {
    return Card(
      title: const Text('Payment'),
      description: const Text('Pro plan, billed yearly.'),
      footer: SizedBox(
        width: double.infinity,
        child: Button(
          leading: const PhosphorIcon(PhosphorIconsRegular.lockSimple),
          onPressed: () {},
          child: const Text(r'Pay $96.00'),
        ),
      ),
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TextField(placeholder: Text('Name on card')),
          const TextField(
            placeholder: Text('1234 1234 1234 1234'),
            leading: PhosphorIcon(PhosphorIconsRegular.creditCard),
          ),
          const UnaRow(
            gap: GapSize.md,
            children: [
              Expanded(child: TextField(placeholder: Text('MM / YY'))),
              Expanded(child: TextField(placeholder: Text('CVC'))),
            ],
          ),
          Select<String>(
            value: _country,
            onChanged: (v) => setState(() => _country = v),
            options: const [
              SelectOption(value: 'se', label: 'Sweden'),
              SelectOption(value: 'no', label: 'Norway'),
              SelectOption(value: 'dk', label: 'Denmark'),
              SelectOption(value: 'fi', label: 'Finland'),
            ],
          ),
          Checkbox(
            value: _save,
            onChanged: (v) => setState(() => _save = v),
            label: const Text('Save this card for later'),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget task(String name, double value) => UnaColumn(
      gap: GapSize.xs,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(name, style: theme.textTheme.small)),
            Text('${(value * 100).round()}%', style: theme.textTheme.caption),
          ],
        ),
        ProgressBar(value: value),
      ],
    );
    return Card(
      title: const Text('Weekly goal'),
      description: const Text('Three days left in the sprint.'),
      child: UnaRow(
        gap: GapSize.lg,
        // The ring's foot on the last bar's: the two read as one block.
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ProgressRing(
            value: .72,
            size: 96,
            strokeWidth: 9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('72%', style: theme.textTheme.h4),
                Text('done', style: theme.textTheme.caption),
              ],
            ),
          ),
          Expanded(
            child: UnaColumn(
              gap: GapSize.md,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                task('Design review', .9),
                task('Onboarding flow', .64),
                task('Release notes', .35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatefulWidget {
  const _PricingCard();

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget feature(String text) => UnaRow(
      gap: GapSize.sm,
      children: [
        PhosphorIcon(
          PhosphorIconsBold.check,
          size: 14,
          color: scheme.success,
        ),
        Expanded(child: Text(text, style: theme.textTheme.small)),
      ],
    );
    return Card(
      title: Row(
        children: [
          const Expanded(child: Text('Pro')),
          Badge(child: Text(_yearly ? 'Save 20%' : 'Popular')),
        ],
      ),
      description: const Text('Everything a growing team needs.'),
      footer: SizedBox(
        width: double.infinity,
        child: Button(onPressed: () {}, child: const Text('Start free trial')),
      ),
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedControl<bool>(
            expand: true,
            value: _yearly,
            onChanged: (v) => setState(() => _yearly = v),
            segments: const [
              Segment(value: false, label: Text('Monthly')),
              Segment(value: true, label: Text('Yearly')),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ContentSwitch(
                value: _yearly,
                axis: Axis.vertical,
                child: Text(
                  _yearly ? r'$8' : r'$10',
                  style: theme.textTheme.h1,
                ),
              ),
              const Gap.xs(),
              Text('per user / month', style: theme.textTheme.muted),
            ],
          ),
          feature('Unlimited projects and history'),
          feature('Custom themes and palettes'),
          feature('Priority support'),
        ],
      ),
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Widget marker(IconData icon, Color color) => Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: PhosphorIcon(icon, size: 14, color: color),
    );
    Widget entry(String title, String when) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.small.copyWith(color: scheme.foreground),
        ),
        Text(when, style: theme.textTheme.caption),
      ],
    );
    return Card(
      title: const Text('Release 2.4'),
      description: const Text('Rolling out to everyone this week.'),
      trailing: const Badge.outline(child: Text('In progress')),
      child: Timeline(
        entries: [
          TimelineEntry(
            marker: marker(PhosphorIconsBold.check, scheme.success),
            child: entry('Design approved', 'Monday · Mei Tanaka'),
          ),
          TimelineEntry(
            marker: marker(PhosphorIconsBold.check, scheme.success),
            child: entry('Beta on TestFlight', 'Tuesday · 1,204 testers'),
          ),
          TimelineEntry(
            marker: marker(PhosphorIconsBold.rocketLaunch, scheme.tint),
            child: entry('Rollout at 25%', 'Today · Julian Reyes'),
          ),
          TimelineEntry(
            marker: marker(PhosphorIconsBold.flag, scheme.mutedForeground),
            child: entry('Everyone', 'Friday'),
          ),
        ],
      ),
    );
  }
}

class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget row(IconData icon, String label, List<String> keys) => UnaRow(
      gap: GapSize.md,
      children: [
        PhosphorIcon(icon, color: theme.colorScheme.mutedForeground),
        Expanded(child: Text(label, style: theme.textTheme.small)),
        UnaRow(
          gap: GapSize.xs,
          mainAxisSize: MainAxisSize.min,
          children: [for (final key in keys) Kbd(key)],
        ),
      ],
    );
    return Card(
      title: const Text('Quick actions'),
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SearchField(placeholder: Text('Search files, people, actions')),
          row(PhosphorIconsRegular.filePlus, 'New document', ['⌘', 'N']),
          row(PhosphorIconsRegular.magnifyingGlass, 'Search', ['⌘', 'K']),
          row(PhosphorIconsRegular.shareNetwork, 'Share', ['⌘', '⇧', 'S']),
          const Alert(
            icon: PhosphorIcon(PhosphorIconsRegular.lightbulb),
            title: Text('Tip'),
            description: Text('Press ? anywhere to see every shortcut.'),
          ),
        ],
      ),
    );
  }
}

/// The revenue over the year, two columns wide, and the pages read most in
/// the third on a desktop, the two as tall as each other. Below three
/// columns the revenue is as wide as the page and the top pages go on
/// among the cards.
class ShowcaseAnalytics extends StatelessWidget {
  const ShowcaseAnalytics({required this.columns, super.key});

  final ShowcaseColumns columns;

  @override
  Widget build(BuildContext context) {
    if (columns.count < 3) return const _RevenueCard();
    return ShowcaseSpanRow(
      columns: columns,
      spans: const [2, 1],
      children: const [_RevenueCard(fill: true), _TopPagesCard(fill: true)],
    );
  }
}

class _RevenueCard extends StatefulWidget {
  const _RevenueCard({this.fill = false});

  /// Whether the chart takes whatever height the card is given beyond its
  /// own: true in a row whose cards are as tall as each other.
  final bool fill;

  @override
  State<_RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<_RevenueCard> {
  bool _year = true;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _thisYear = <double>[
    18.2,
    21.4,
    20.1,
    24.8,
    27.3,
    26.1,
    30.4,
    33.9,
    32.2,
    38.6,
    41.8,
    48.2,
  ];
  static const _lastYear = <double>[
    14.1,
    15.8,
    17.2,
    16.9,
    19.4,
    21.0,
    20.3,
    23.7,
    24.9,
    26.2,
    28.8,
    31.5,
  ];

  static const _dollar = r'$';

  static String _money(num v, {int digits = 0}) =>
      '$_dollar${v.toStringAsFixed(digits)}k';

  @override
  Widget build(BuildContext context) {
    final from = _year ? 0 : 6;
    final series = [
      ChartSeries(label: 'This year', values: _thisYear.sublist(from)),
      ChartSeries(label: 'Last year', values: _lastYear.sublist(from)),
    ];
    final chart = SizedBox(
      height: 260,
      child: LineChart(
        labels: _months.sublist(from),
        series: series,
        area: true,
        valueFormatter: (v) => _money(v, digits: 1),
        tickFormatter: (v) => _money(v),
        semanticLabel: 'Revenue by month, this year and last',
      ),
    );
    return Card(
      style: widget.fill
          ? const CardTheme(columnMainAxisSize: MainAxisSize.max)
          : null,
      title: const Text('Revenue'),
      description: Text(
        '${_money(48.2, digits: 1)} this month, 53% up on last year',
      ),
      action: SegmentedControl<bool>(
        size: ControlSize.sm,
        value: _year,
        onChanged: (v) => setState(() => _year = v),
        segments: const [
          Segment(value: false, label: Text('6M')),
          Segment(value: true, label: Text('12M')),
        ],
      ),
      child: UnaColumn(
        gap: GapSize.md,
        mainAxisSize: widget.fill ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.fill) Expanded(child: chart) else chart,
          ChartLegend(entries: series),
        ],
      ),
    );
  }
}

/// The pages visitors open most, as shares of a ring with the total in
/// the middle, in the theme's chart palette.
class _TopPagesCard extends StatelessWidget {
  const _TopPagesCard({this.fill = false});

  /// Whether the ring takes whatever height the card is given beyond its
  /// own: true beside the revenue, which sets the row's height.
  final bool fill;

  static const _pages = [
    ChartSegment(label: '/pricing', value: 9840),
    ChartSegment(label: '/docs', value: 7320),
    ChartSegment(label: '/blog', value: 4180),
    ChartSegment(label: '/changelog', value: 2650),
    ChartSegment(label: '/about', value: 1730),
  ];

  static String _views(num v) => '${(v / 1000).toStringAsFixed(1)}k';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _pages.fold<double>(0, (sum, page) => sum + page.value);
    final chart = SizedBox(
      height: 200,
      child: DonutChart(
        segments: _pages,
        valueFormatter: (v) => '${_views(v)} views',
        semanticLabel: 'Views of the top pages this month',
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_views(total), style: theme.textTheme.h3),
            Text('views', style: theme.textTheme.caption),
          ],
        ),
      ),
    );
    return Card(
      style: fill
          ? const CardTheme(columnMainAxisSize: MainAxisSize.max)
          : null,
      title: const Text('Top pages'),
      description: const Text('Views this month.'),
      child: UnaColumn(
        gap: GapSize.lg,
        mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fill) Expanded(child: chart) else chart,
          const ChartLegend(
            entries: _pages,
            alignment: WrapAlignment.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _series = [
    ChartSeries(label: 'Desktop', values: [42, 58, 61, 55, 67, 30, 24]),
    ChartSeries(label: 'Mobile', values: [36, 41, 47, 52, 58, 49, 44]),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      title: const Text('Sessions'),
      description: const Text('This week, by device.'),
      child: UnaColumn(
        gap: GapSize.md,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              labels: _days,
              series: _series,
              semanticLabel: 'Sessions this week by device',
            ),
          ),
          const ChartLegend(entries: _series),
        ],
      ),
    );
  }
}
