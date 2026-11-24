// Throwaway visual smoke test: renders the new widgets to PNG files.
// ignore_for_file: avoid_print, public_member_api_docs
import 'dart:io';
import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const out = String.fromEnvironment('OUT', defaultValue: '/tmp');

Future<void> loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Widget gallery() {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final mobile = theme.formFactor == FormFactor.mobile;
      const destinations = [
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.house),
          selectedIcon: Icon(PhosphorIconsFill.house),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.usersThree),
          label: 'Network',
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.briefcase),
          label: 'Jobs',
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.chatCircleDots),
          label: 'Messages',
          badgeCount: 3,
        ),
        NavigationDestination(
          icon: Icon(PhosphorIconsRegular.bell),
          label: 'Notifications',
          badgeCount: 12,
        ),
      ];
      return NavigationScaffold(
        destinations: destinations,
        selectedIndex: 2,
        onDestinationSelected: (_) {},
        leading: const Text('strand'),
        title: const SizedBox(
          width: 280,
          child: TextField(
            placeholder: Text('Search people, posts, jobs'),
            leading: Icon(PhosphorIconsRegular.magnifyingGlass),
          ),
        ),
        actions: [
          IconButton.secondary(
            icon: const Icon(PhosphorIconsRegular.moon),
            onPressed: () {},
          ),
        ],
        action: NavigationAction(
          icon: const Icon(PhosphorIconsRegular.plus),
          label: 'Create',
          onPressed: () {},
        ),
        body: PageContainer(
          scrollable: true,
          child: FinesseColumn(
            gap: GapSize.lg,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jobs', style: theme.textTheme.h1),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Button(onPressed: () {}, child: const Text('Post a job')),
                  Button.outline(
                    onPressed: () {},
                    leading: const Icon(PhosphorIconsRegular.bell),
                    child: const Text('Job alerts'),
                  ),
                  Button.secondary(
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                  Button.ghost(onPressed: () {}, child: const Text('Ghost')),
                  Button.destructive(
                    onPressed: () {},
                    child: const Text('Delete'),
                  ),
                  Button(
                    size: ButtonSize.lg,
                    onPressed: () {},
                    child: const Text('Easy Apply'),
                  ),
                  Button.outline(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Follow'),
                  ),
                  IconButton.ghost(
                    icon: const Icon(PhosphorIconsRegular.bookmarkSimple),
                    onPressed: () {},
                  ),
                  IconButton.secondary(
                    icon: const Icon(PhosphorIconsRegular.dotsThree),
                    onPressed: () {},
                  ),
                  IconButton.outline(
                    icon: const Icon(PhosphorIconsRegular.export),
                    onPressed: () {},
                  ),
                ],
              ),
              Card(
                child: FinesseColumn(
                  gap: GapSize.md,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextField(
                      placeholder: Text('Title, skill or company'),
                      leading: Icon(PhosphorIconsRegular.magnifyingGlass),
                    ),
                    const Divider.horizontal(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          label: const Text('Remote'),
                          leading: const Icon(PhosphorIconsRegular.globe),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        Chip(label: const Text('Hybrid'), onSelected: (_) {}),
                        Chip(
                          label: const Text('Posted this week'),
                          leading: const Icon(PhosphorIconsRegular.clock),
                          onSelected: (_) {},
                        ),
                        const Chip(
                          label: Text('Design systems'),
                          variant: ChipVariant.soft,
                        ),
                        const Chip(
                          label: Text('Healthcare'),
                          leading: Icon(PhosphorIconsRegular.x),
                          variant: ChipVariant.dashed,
                        ),
                        const Badge.secondary(child: Text('€78k – €95k')),
                        const Badge(child: Text('New')),
                        const Badge.outline(child: Text('Outline')),
                      ],
                    ),
                  ],
                ),
              ),
              FinesseRow(
                gap: GapSize.md,
                children: [
                  Expanded(
                    child: StatTile(
                      icon: const Icon(PhosphorIconsRegular.bookmarkSimple),
                      value: const Text('6'),
                      label: const Text('Saved jobs'),
                      onTap: () {},
                    ),
                  ),
                  if (!mobile)
                    const Expanded(
                      child: StatTile(
                        icon: Icon(PhosphorIconsRegular.paperPlaneTilt),
                        value: Text('4'),
                        label: Text('Applications sent'),
                      ),
                    ),
                  const Expanded(
                    child: StatTile(
                      icon: Icon(PhosphorIconsRegular.eye),
                      value: Text('18'),
                      label: Text('Recruiter profile views'),
                    ),
                  ),
                ],
              ),
              Tabs<String>(
                value: 'for-you',
                tabs: const [
                  Tab(value: 'for-you', child: Text('For you')),
                  Tab(value: 'following', child: Text('Following')),
                  Tab(value: 'trending', child: Text('Trending')),
                ],
              ),
              Card(
                padding: EdgeInsets.zero,
                child: FinesseColumn(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TabBar(
                      selectedIndex: 1,
                      onSelected: (_) {},
                      tabs: const [
                        Text('Posts'),
                        Text('About'),
                        Text('Experience'),
                        Text('Media'),
                      ],
                    ),
                    ListTile(
                      leading: const IconTile(
                        icon: Icon(PhosphorIconsRegular.filePdf),
                      ),
                      title: const Text('calm-by-default-draft.pdf'),
                      subtitle: const Text('4.2 MB · Today'),
                      trailing: Button.outline(
                        size: ButtonSize.sm,
                        onPressed: () {},
                        child: const Text('Open'),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      selected: true,
                      leading: IndicatorBadge(
                        alignment: AlignmentDirectional.bottomEnd,
                        size: 12,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff6cc0d6),
                          ),
                        ),
                      ),
                      title: const Text('Omar Rahimi'),
                      subtitle: const Text(
                        'You: Sending the deck now. Slides 12 to 18 are the ones',
                      ),
                      trailing: const IndicatorBadge(count: 4, ringWidth: 0),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FinesseRow(
                        gap: GapSize.sm,
                        children: [
                          AvatarGroup(
                            size: 20,
                            children: [
                              for (final c in const [
                                Color(0xff176b83),
                                Color(0xffc8432f),
                                Color(0xff2b6a4c),
                              ])
                                ColoredBox(
                                  color: c,
                                  child: const SizedBox.square(dimension: 20),
                                ),
                            ],
                          ),
                          Text(
                            '2 connections work here',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                child: FinesseColumn(
                  gap: GapSize.sm,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    ChatBubble(
                      child: Text(
                        'Hey Noor! Loved your talk proposal for Config '
                        'Nordics. Do you have slides yet?',
                      ),
                    ),
                    ChatBubble(
                      direction: ChatBubbleDirection.outgoing,
                      child: Text(
                        'Thank you! I have a rough draft. Would love a '
                        'second pair of eyes before I polish it.',
                      ),
                    ),
                    ChatBubble(child: TypingIndicator()),
                  ],
                ),
              ),
              Card(
                child: Timeline(
                  entries: [
                    for (final t in const ['Senior product designer', 'UX'])
                      TimelineEntry(
                        marker: const IconTile(
                          icon: Icon(PhosphorIconsRegular.buildings),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t, style: theme.textTheme.large),
                            Text('Halcyon', style: theme.textTheme.muted),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff176b83), Color(0xffc8432f)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Glass(
                  padding: EdgeInsets.all(12),
                  child: Text('Glass over a gradient'),
                ),
              ),
              const ProgressBar(value: .8),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    },
  );
}

void main() {
  setUpAll(() async {
    const cache = 'fonts/phosphor';
    await loadFont('packages/finesse/PhosphorRegular', [
      '$cache/Phosphor.ttf',
    ]);
    await loadFont('packages/finesse/PhosphorFill', [
      '$cache/Phosphor-Fill.ttf',
    ]);
    await loadFont('Body', ['/System/Library/Fonts/Supplemental/Arial.ttf']);
  });

  for (final (name, size, brightness) in [
    ('desktop_light', const Size(1200, 1500), Brightness.light),
    ('desktop_dark', const Size(1200, 1500), Brightness.dark),
    ('mobile_light', const Size(390, 1700), Brightness.light),
  ]) {
    testWidgets('gallery $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugDisableShadows = false;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: FinesseApp(
            theme: ThemeData(
              brightness: brightness,
              textTheme: TextTheme(family: 'Body'),
            ),
            home: gallery(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$out/gallery_$name.png').writeAsBytesSync(
          data!.buffer.asUint8List(),
        );
      });
      debugDisableShadows = true;
    });
  }
}
