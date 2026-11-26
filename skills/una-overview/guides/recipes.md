# Recipes: screens that look finished

The widgets give an app the right sizes, colours and motion only if the
screen leaves those to the theme. These recipes are the idioms of the
package's Demo app (a professional network built from una alone, the app
the default look was measured from): copy their shape, not their numbers.

## What a finished screen does

- **Structure from the package.** One `UnaApp`; a `NavigationScaffold`
  (or `Scaffold` + `AppBar`) per screen; content in a `PageContainer`;
  panels are `Card`, `ListSection`, `Sheet`, `Dialog`, `Popover`. No
  `Container` with a colour and a shadow, no hand-made bar.
- **Every size from the theme.** Gaps are `GapSize`/`Gap.md()`; text is a
  `textTheme` role, copied for weight or colour; radii are `theme.radii`;
  icons inside components have no `size`. The only literals are what the
  design means as a picture (a cover photo's height, a rail's width).
- **Every colour from the scheme.** `foreground` for what matters,
  `mutedForeground` (or `textTheme.muted`/`caption`) for what supports
  it, `tint` for brand ink on a surface. No hex in a screen.
- **Rearrange, do not resize.** A phone screen is a different arrangement
  under `FormFactorBuilder`, not the desktop one with smaller numbers.
  Inside the desktop one, a `LayoutBuilder` decides how many columns fit.
- **Content under the chrome.** Bars are laid over the page; the page
  scrolls beneath them. Never pad the top of a page by the bar's height.
- **Nothing is a dead end.** Every button does something: opens a sheet, a
  dialog, a toast with Undo. A placeholder `onPressed: () {}` ships as a
  bug.

## The app root

```dart
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:una/una.dart';

// Built once, at the top level: themes compare by value, and a new one per
// build would rebuild and cross-fade the app on every build.
final _textTheme = TextTheme.fromGoogleFont(GoogleFonts.geist);
final _light = ThemeData(
  colorScheme: const OceanColorScheme.light(),
  textTheme: _textTheme,
);
final _dark = ThemeData(
  colorScheme: const OceanColorScheme.dark(),
  textTheme: _textTheme,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Liquid Glass shaders (iOS, macOS) before the first frame.
  await LiquidGlass.initialize();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return UnaApp(
      title: 'Acme',
      theme: _light,
      darkTheme: _dark,
      themeMode: ThemeMode.system,
      home: const Shell(),
    );
  }
}
```

The default style (`StyleTokens.fluid`) was drawn in Geist; with no font
the platform's is used, which is fine but looks less like the designs.
To avoid a reflow when the font arrives, await
`GoogleFonts.pendingFonts()` before `runApp` (with a timeout), after
asking for each weight the roles use (`GoogleFonts.geist(fontWeight:
FontWeight.w500)`, ... w400 to w700).

## A shell with destinations

```dart
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationScaffold(
      title: const Text('Acme'),
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      actions: [
        IconButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.bell),
          semanticLabel: 'Notifications',
          onPressed: () => Navigator.of(context).push(
            UnaPageRoute<void>(builder: (context) => const NotificationsPage()),
          ),
        ),
      ],
      action: NavigationAction(
        icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        label: 'New post',
        onPressed: () => showCompose(context),
      ),
      destinations: const [
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.house),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
          label: 'Home',
        ),
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.briefcase),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.briefcase),
          label: 'Jobs',
        ),
      ],
      body: DestinationStack(
        index: _index,
        builders: [
          (context) => const HomeScreen(),
          (context) => const JobsScreen(),
        ],
      ),
    );
  }
}
```

- The selected icon is the **fill** weight of the same glyph.
- Bar buttons name **no variant** ([app-structure.md](app-structure.md)).
- A destination's screen returns page content (a `PageContainer`, a
  `CustomScrollView`), never its own `Scaffold`: the shell's bars are
  already over it and its `MediaQuery` padding includes them.
- What needs the whole screen (a conversation, a job's detail on a phone,
  a compose form) is pushed as a route with its own `Scaffold` and
  `AppBar`, whose back or close button is implied.

## A page header

The title of a destination, a muted line under it on a desktop, and the
page's actions at the end. A `Wrap`, so a long title at a large text size
pushes the actions under it instead of overflowing.

```dart
class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    this.subtitle,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = theme.layoutTheme;
    final heading = Semantics(
      header: true,
      child: Text(title, style: theme.textTheme.h1),
    );
    if (theme.formFactor == FormFactor.mobile) return heading;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: layout.gap(GapSize.xl),
      runSpacing: layout.gap(GapSize.md),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading,
            if (subtitle case final subtitle?) ...[
              const Gap.xs(),
              Text(
                subtitle,
                style: theme.textTheme.p.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        if (actions.isNotEmpty)
          UnaRow(gap: GapSize.sm, mainAxisSize: MainAxisSize.min, children: actions),
      ],
    );
  }
}
```

A heading over a group of cards on the page is `textTheme.h4` in a
`Semantics(header: true)`, with a `Button.link` ("See all") at the end of
the line.

## A content card

Header row (avatar, name, metadata, an overflow menu), body, then the
actions under a hairline. `GapSize.md` between the blocks, `xs` between a
name and its line.

```dart
class PostCard extends StatelessWidget {
  const PostCard({required this.post, super.key});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(post.avatarUrl, fallback: Text(post.initials)),
              const Gap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.large.copyWith(
                        color: scheme.foreground,
                      ),
                    ),
                    Text(
                      '${post.headline} · ${post.age}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.caption,
                    ),
                  ],
                ),
              ),
              DropdownMenu(
                builder: (context, controller, child) => IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
                  semanticLabel: 'More',
                  onPressed: controller.toggle,
                ),
                items: [
                  MenuItem(onPressed: () {}, child: const Text('Save')),
                  MenuItem(
                    destructive: true,
                    onPressed: () {},
                    child: const Text('Report'),
                  ),
                ],
              ),
            ],
          ),
          const Gap.md(),
          Text(post.body, style: theme.textTheme.p.copyWith(color: scheme.foreground)),
          const Gap.md(),
          const Divider(margin: EdgeInsets.zero),
          const Gap.xs(),
          UnaRow(
            gap: GapSize.xs,
            children: [
              Button.ghost(
                size: ButtonSize.sm,
                leading: PhosphorIcon(
                  post.liked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
                  color: post.liked ? scheme.tint : null,
                ),
                onPressed: () {},
                child: Text('${post.likes}'),
              ),
              Button.ghost(
                size: ButtonSize.sm,
                leading: const PhosphorIcon(PhosphorIconsRegular.chatCircle),
                onPressed: () {},
                child: const Text('Comment'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- Names and titles are `large` (or `h4`) in `foreground`; the line under
  them is `caption` or `muted`; body text is `p`. That contrast is most of
  what makes a card read as designed.
- An icon at rest is regular and inherits the button's colour; when it is
  *on* it is the fill weight in `tint` (a heart may be `destructive`).
- Inside a card, buttons are named (`IconButton.ghost`, `Button.ghost`):
  a card is not a bar.

## A summary strip

```dart
final summary = UnaRow(
  gap: GapSize.lg,
  children: [
    Expanded(
      child: StatTile(
        icon: const PhosphorIcon(PhosphorIconsRegular.bookmarkSimple),
        value: const Text('6'),
        label: const Text('Saved jobs'),
        onTap: () {},
      ),
    ),
    Expanded(
      child: StatTile(
        icon: const PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
        value: const Text('3'),
        label: const Text('Applications'),
        onTap: () {},
      ),
    ),
  ],
);
```

On a phone, two tiles to a row (a `Wrap` or two `UnaRow`s), not four
squeezed ones.

## A settings screen

A phone's top-level list: a large title that collapses, grouped rows,
controls in the rows. No cards around the sections: a `ListSection` is one.

```dart
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _push = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Settings')),
          SliverListSection(
            header: const Text('Notifications'),
            children: [
              SwitchListTile(
                title: const Text('Push notifications'),
                subtitle: const Text('Messages, invitations and mentions'),
                value: _push,
                onChanged: (value) => setState(() => _push = value),
              ),
              ListTile(
                leading: const IconTile(
                  icon: PhosphorIcon(PhosphorIconsRegular.envelopeSimple),
                ),
                title: const Text('Email'),
                value: const Text('Weekly'),
                showChevron: true,
                onTap: () {},
              ),
            ],
          ),
          SliverListSection(
            header: const Text('Account'),
            children: [
              ListTile(
                title: const Text('Sign out'),
                destructive: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

On a desktop the same sections sit in a `PageContainer(maxWidth: ...)`
column as `ListSection`s, beside a list of pages (a `ListDetailLayout`
does both arrangements).

## One screen, two arrangements

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FormFactorBuilder(
      desktop: (context) => PageContainer(
        scrollable: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gap = Theme.of(context).layoutTheme.gap(GapSize.xl);
            const feed = UnaColumn(
              gap: GapSize.lg,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [Card(title: Text('Feed'))],
            );
            if (constraints.maxWidth < 860) return feed;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: gap,
              children: const [
                SizedBox(
                  key: ValueKey('rail'),
                  width: 260,
                  child: Card(title: Text('Profile')),
                ),
                Expanded(key: ValueKey('feed'), child: feed),
              ],
            );
          },
        ),
      ),
      mobile: (context) => const PageContainer(
        scrollable: true,
        child: UnaColumn(
          gap: GapSize.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [Card(title: Text('Feed'))],
        ),
      ),
    );
  }
}
```

What the user typed or chose must not live in a `State` under one of the
two arrangements: a window resize swaps them. Keep it above the
`FormFactorBuilder` (in the screen's `State`, or a model).

## Empty, loading and error states

```dart
Widget results(BuildContext context, List<Job>? jobs, Object? error) {
  if (error != null) {
    return Card(
      child: Empty(
        icon: const PhosphorIcon(PhosphorIconsRegular.warningCircle),
        title: const Text('Could not load jobs'),
        description: const Text('Check your connection and try again.'),
        actions: [Button.outline(onPressed: retry, child: const Text('Try again'))],
      ),
    );
  }
  if (jobs == null) {
    return const UnaColumn(
      gap: GapSize.lg,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Skeleton(height: 96), Skeleton(height: 96)],
    );
  }
  if (jobs.isEmpty) {
    return const Card(
      child: Empty(
        icon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
        title: Text('No jobs match'),
        description: Text('Try fewer filters.'),
      ),
    );
  }
  return JobList(jobs: jobs);
}
```

A button that starts work shows it with `Button(loading: true, ...)`; a
result that arrives later is a toast (`Toaster.of(context).show(...)`),
updated from a `ToastVariant.loading` one to its outcome.

## A pushed detail page

```dart
class JobDetailPage extends StatelessWidget {
  const JobDetailPage({required this.job, super.key});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(job.title),
        actions: [
          IconButton(
            icon: const PhosphorIcon(PhosphorIconsRegular.shareNetwork),
            semanticLabel: 'Share',
            onPressed: () {},
          ),
        ],
      ),
      // Rises with the keyboard and keeps clear of the home indicator.
      footer: SafeArea(
        top: false,
        child: UnaPadding.all(
          4,
          child: Button(
            expands: true,
            onPressed: () {},
            child: const Text('Apply'),
          ),
        ),
      ),
      body: PageContainer(
        scrollable: true,
        child: UnaColumn(
          gap: GapSize.lg,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(job.title, style: theme.textTheme.h2),
            Text(job.description, style: theme.textTheme.p),
          ],
        ),
      ),
    );
  }
}
```

The back button is implied; never build one. On a phone the page slides
in from the end edge and goes back with a swipe from the start edge.

`Post`, `Job`, `JobList`, `retry`, `showCompose`, `NotificationsPage` and
the screens above stand for the app's own code.

See also: [layout.md](layout.md), [app-structure.md](app-structure.md),
[surfaces.md](surfaces.md), [mistakes.md](mistakes.md).
