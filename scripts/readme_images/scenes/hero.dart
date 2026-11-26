import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

import '../frames.dart';
import '../harness.dart';
import 'common.dart';

/// The size of the hero image.
const heroSize = Size(1440, 860);

/// The hero: a desktop dashboard in light, a phone conversation in dark,
/// over a wash of the blue palette.
class HeroScene extends StatelessWidget {
  /// Creates the hero.
  const HeroScene({super.key});

  @override
  Widget build(BuildContext context) {
    final light = imageTheme();
    final dark = imageTheme(brightness: Brightness.dark);
    return Aurora(
      base: const Color(0xFFEFF5F4),
      glows: const [
        (Color(0xFF7FD3C8), Alignment.topLeft, .55),
        (Color(0xFFB9C8FF), Alignment(1.05, -.9), .5),
        (Color(0xFF9EE6D6), Alignment(.6, 1.1), .45),
        (Color(0xFFFFD9C2), Alignment(-.8, 1.2), .35),
      ],
      child: Stack(
        children: [
          Positioned(
            left: 64,
            top: 84,
            child: DesktopWindow(
              theme: light,
              title: 'Orbit',
              size: const Size(966, 640),
              child: const _Dashboard(),
            ),
          ),
          Positioned(
            right: 64,
            top: 58,
            child: Transform.scale(
              scale: .87,
              alignment: Alignment.topRight,
              child: PhoneFrame(theme: dark, child: const _Conversation()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    SidebarMenuButton item(String label, IconData icon, {bool on = false}) {
      return SidebarMenuButton(
        leading: PhosphorIcon(icon),
        selected: on,
        onPressed: () {},
        child: Text(label),
      );
    }

    final sidebar = Sidebar(
      width: 228,
      header: Row(
        children: [
          const LogoMark(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orbit',
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('Design team', style: theme.textTheme.caption),
              ],
            ),
          ),
        ],
      ),
      footer: SidebarMenuButton(
        leading: const PersonAvatar(0, size: 24),
        trailing: const PhosphorIcon(PhosphorIconsRegular.caretUpDown),
        onPressed: () {},
        child: Text(people[0].name),
      ),
      children: [
        SidebarGroup(
          label: const Text('Workspace'),
          children: [
            SidebarMenu(
              children: [
                item('Overview', PhosphorIconsRegular.squaresFour, on: true),
                item('Projects', PhosphorIconsRegular.kanban),
                item('Inbox', PhosphorIconsRegular.tray),
                item('Calendar', PhosphorIconsRegular.calendarBlank),
              ],
            ),
          ],
        ),
        SidebarGroup(
          label: const Text('Team'),
          children: [
            SidebarMenu(
              children: [
                item('Members', PhosphorIconsRegular.usersThree),
                item('Reports', PhosphorIconsRegular.chartLineUp),
                item('Settings', PhosphorIconsRegular.gear),
              ],
            ),
          ],
        ),
      ],
    );

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: theme.textTheme.h3),
              const SizedBox(height: 2),
              Text(
                'Tuesday, 25 November',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 240,
          child: SearchField(placeholder: Text('Search')),
        ),
        const Gap.sm(),
        IconButton.outline(
          icon: const PhosphorIcon(PhosphorIconsRegular.bell),
          onPressed: () {},
        ),
        const Gap.sm(),
        ContextMenu(
          open: true,
          requestFocus: false,
          constraints: const BoxConstraints(minWidth: 220),
          anchor: const AnchorAuto(
            offset: Offset(0, 6),
            targetAnchor: AlignmentDirectional.bottomEnd,
            followerAnchor: AlignmentDirectional.bottomStart,
          ),
          items: const [
            MenuLabel(child: Text('Create')),
            MenuItem(
              leading: PhosphorIcon(PhosphorIconsRegular.kanban),
              child: Text('Project'),
            ),
            MenuItem(
              leading: PhosphorIcon(PhosphorIconsRegular.checkSquare),
              child: Text('Task'),
            ),
            MenuItem(
              leading: PhosphorIcon(PhosphorIconsRegular.fileText),
              child: Text('Document'),
            ),
            MenuDivider(),
            MenuItem(
              leading: PhosphorIcon(PhosphorIconsRegular.userPlus),
              child: Text('Invite people'),
            ),
          ],
          child: Button(
            onPressed: () {},
            leading: const PhosphorIcon(PhosphorIconsBold.plus),
            child: const Text('New project'),
          ),
        ),
      ],
    );

    final stats = UnaRow(
      gap: GapSize.md,
      children: [
        const Expanded(
          child: StatTile(
            icon: PhosphorIcon(PhosphorIconsRegular.checkCircle),
            value: Text('128'),
            label: Text('Tasks done'),
          ),
        ),
        Expanded(
          child: StatTile(
            icon: const PhosphorIcon(PhosphorIconsRegular.lightning),
            value: const Text('94%'),
            label: const Text('On time'),
            trailing: Badge.secondary(
              backgroundColor: scheme.successMuted,
              foregroundColor: scheme.success,
              child: const Text('+6%'),
            ),
          ),
        ),
        const Expanded(
          child: StatTile(
            icon: PhosphorIcon(PhosphorIconsRegular.usersThree),
            value: Text('12'),
            label: Text('Active members'),
          ),
        ),
      ],
    );

    final activity = Card(
      title: const Text('Activity'),
      description: const Text('Tasks completed this week'),
      action: Tabs<String>(
        value: 'week',
        onChanged: (_) {},
        tabs: const [
          Tab(value: 'week', child: Text('Week')),
          Tab(value: 'month', child: Text('Month')),
        ],
      ),
      child: const SizedBox(
        height: 200,
        child: MiniBarChart(
          values: [.42, .64, .5, .78, .58, .92, .7],
          labels: ['Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue'],
          highlight: 5,
        ),
      ),
    );

    final team = Card(
      title: const Text('Team'),
      description: const Text('Who is working on what'),
      style: const CardTheme(padding: EdgeInsets.fromLTRB(20, 20, 20, 12)),
      child: Column(
        children: [
          for (final (i, status) in const [
            (1, 'Review'),
            (2, 'Planning'),
            (3, 'In progress'),
            (4, 'Research'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  PersonAvatar(i, size: 34),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          people[i].name,
                          style: theme.textTheme.small.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(people[i].role, style: theme.textTheme.caption),
                      ],
                    ),
                  ),
                  if (status == 'In progress')
                    Badge(child: Text(status))
                  else
                    Badge.secondary(child: Text(status)),
                ],
              ),
            ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 228, child: sidebar),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const Gap.xl(),
                stats,
                const Gap.md(),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: activity),
                      const Gap.md(),
                      Expanded(flex: 2, child: team),
                    ],
                  ),
                ),
                const Gap.md(),
                UnaRow(
                  gap: GapSize.md,
                  children: [
                    for (final (name, progress, due, members) in const [
                      ('Mobile onboarding', .82, 'Due Friday', [0, 1, 2]),
                      ('Design system v3', .56, 'Due in 2 weeks', [3, 4]),
                      ('Insights dashboard', .31, 'Due in December', [5, 0, 3]),
                    ])
                      Expanded(
                        child: _ProjectCard(name, progress, due, members),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.name, this.progress, this.due, this.members);

  final String name;
  final double progress;
  final String due;
  final List<int> members;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      style: const CardTheme(padding: EdgeInsets.all(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AvatarGroup(
                size: 24,
                children: [for (final i in members) PersonAvatar(i, size: 24)],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(value: progress),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(due, style: theme.textTheme.caption),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.caption.copyWith(
                  color: theme.colorScheme.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {}),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PersonAvatar(2, size: 32),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  people[2].name,
                  style: theme.textTheme.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('Active now', style: theme.textTheme.caption),
              ],
            ),
          ],
        ),
        actions: [
          IconButton.ghost(
            icon: const PhosphorIcon(PhosphorIconsRegular.videoCamera),
            onPressed: () {},
          ),
        ],
      ),
      footer: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          8 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          children: [
            IconButton.secondary(
              icon: const PhosphorIcon(PhosphorIconsRegular.plus),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            const Expanded(child: TextField(placeholder: Text('Message'))),
            const SizedBox(width: 8),
            IconButton(
              icon: const PhosphorIcon(PhosphorIconsFill.paperPlaneRight),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          final insets = MediaQuery.paddingOf(context);
          return ListView(
            reverse: true,
            padding: EdgeInsets.fromLTRB(
              16,
              insets.top + 16,
              16,
              insets.bottom + 16,
            ),
            children: [
              Center(
                child: Text('Yesterday', style: theme.textTheme.caption),
              ),
              const SizedBox(height: 12),
              const ChatBubble(
                direction: ChatBubbleDirection.outgoing,
                child: Text('The new screens are in the shared folder.'),
              ),
              const SizedBox(height: 14),
              const ChatBubble(
                child: Text('Looking now. Love the glass bars!'),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('Today 9:12', style: theme.textTheme.caption),
              ),
              const SizedBox(height: 12),
              const ChatBubble(
                showTail: false,
                child: Text(
                  'Morning! Is the new onboarding flow ready to try?',
                ),
              ),
              const SizedBox(height: 4),
              const ChatBubble(
                child: Text('I want to show it in the review at 11.'),
              ),
              const SizedBox(height: 14),
              const ChatBubble(
                direction: ChatBubbleDirection.outgoing,
                showTail: false,
                child: Text('Yes, it shipped to the beta last night.'),
              ),
              const SizedBox(height: 4),
              const ChatBubble(
                direction: ChatBubbleDirection.outgoing,
                child: Text(
                  'Dark mode and the phone layout came for free with the '
                  'theme.',
                ),
              ),
              const SizedBox(height: 14),
              const ChatBubble(
                child: Text('Perfect. Sending it to the team now.'),
              ),
              const SizedBox(height: 18),
              const Toast(
                variant: ToastVariant.success,
                title: Text('Build 2.4 is live'),
                description: Text('Rolled out to 1,204 beta testers.'),
              ),
            ].reversed.toList(),
          );
        },
      ),
    );
  }
}
