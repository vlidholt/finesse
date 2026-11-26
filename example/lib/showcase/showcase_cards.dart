import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

// The showcase's cards: each one a moment from a real app, built only from
// the package's widgets on the current theme.

/// Every card, in reading order. [columns] is how many the grid has, for
/// the few cards that arrange themselves differently in a narrow one.
List<Widget> showcaseCards({required int columns}) => const [
  _TeamCard(),
  _ChatCard(),
  _BookingCard(),
  _PlayerCard(),
  _NotificationsCard(),
  _CheckoutCard(),
  _GoalCard(),
  _PricingCard(),
  _ReleaseCard(),
  _ShortcutsCard(),
];

/// The figures across the top: four stat tiles.
class ShowcaseStats extends StatelessWidget {
  const ShowcaseStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = theme.layoutTheme.gap(GapSize.lg);
    final tiles = <Widget>[
      const _Stat(
        icon: PhosphorIconsRegular.users,
        label: 'Users',
        value: '24,816',
        change: '+12.4%',
      ),
      const _Stat(
        icon: PhosphorIconsRegular.currencyDollar,
        label: 'Revenue',
        value: r'$48.2k',
        change: '+8.1%',
      ),
      const _Stat(
        icon: PhosphorIconsRegular.chartLineUp,
        label: 'Conversion',
        value: '3.62%',
        change: '+0.4%',
      ),
      const _Stat(
        icon: PhosphorIconsRegular.smiley,
        label: 'Satisfaction',
        value: '4.8',
        change: '-0.1',
        down: true,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 480
            ? 2
            : 1;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles)
              SizedBox(
                width: (constraints.maxWidth - gap * (perRow - 1)) / perRow,
                child: tile,
              ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    this.down = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String change;
  final bool down;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StatTile(
      icon: PhosphorIcon(icon),
      label: Text(label),
      value: Text(value),
      trailing: Badge.secondary(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              down
                  ? PhosphorIconsBold.arrowDownRight
                  : PhosphorIconsBold.arrowUpRight,
              size: 12,
              color: down ? scheme.destructive : scheme.success,
            ),
            const Gap.xs(),
            Text(change),
          ],
        ),
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
      trailing: IconButton.ghost(
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
            trailing: IconButton(
              size: ButtonSize.sm,
              icon: const PhosphorIcon(PhosphorIconsFill.paperPlaneTilt),
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
                  Image.asset(
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
                            PhosphorIconsFill.waveform,
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
                      icon: const PhosphorIcon(PhosphorIconsFill.shuffle),
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
                      icon: const PhosphorIcon(PhosphorIconsFill.repeat),
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
