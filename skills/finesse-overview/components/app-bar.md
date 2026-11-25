# App Bar

The bar across the top of a screen: a logo or back button, a title, and actions. Its height follows the form factor and its fill the bar opacity of the style. Put it in a `Scaffold` so the page scrolls beneath it. For a bar that scrolls with the page or carries a large title, see `SliverAppBar`.

## Leading, title and actions

Without a `middle`, the title takes the space between `leading` and `actions` and truncates when it runs out. It is the page's heading for a screen reader.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A back button, a title and two actions. Without a `middle`, the title
/// takes the space between the leading widget and the actions.
class AppBarBasicExample extends StatelessWidget {
  const AppBarBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 520,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: theme.radii.xl,
      ),
      // Painted over the content, so nothing covers the frame's corners.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            // Not at the top of the screen here, so no status bar inset.
            primary: false,
            leading: IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.arrowLeft),
              semanticLabel: 'Back',
              onPressed: () {},
            ),
            title: const Text('Messages'),
            actions: [
              IconButton.ghost(
                icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
                semanticLabel: 'Search',
                onPressed: () {},
              ),
              IconButton.ghost(
                icon: const PhosphorIcon(PhosphorIconsRegular.notePencil),
                semanticLabel: 'New message',
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(
            height: 120,
            child: Center(
              child: Text('Page content', style: theme.textTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}
```

## The leading button it shows by itself

A bar with no `leading` shows the button its place calls for: a `CloseButton` on a full-screen dialog, a `BackButton` on a page that can be popped, a menu button over a `Scaffold` with a drawer, and nothing on the first page. `automaticallyImplyLeading: false` turns it off.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// None of these bars is given a `leading`. The first page has nothing to
/// go back to; the pushed one gets a back button; the full-screen dialog
/// gets a close button.
class AppBarLeadingExample extends StatelessWidget {
  const AppBarLeadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhoneFrame(height: 420, child: _Page(depth: 0));
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.depth, this.dialog = false});

  final int depth;
  final bool dialog;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dialog
              ? 'New message'
              : depth == 0
              ? 'Inbox'
              : 'Thread $depth',
        ),
      ),
      body: Center(
        child: FinesseColumn(
          mainAxisSize: MainAxisSize.min,
          gap: GapSize.md,
          children: [
            Button.outline(
              onPressed: () => Navigator.of(context).push(
                FinessePageRoute<void>(builder: (_) => _Page(depth: depth + 1)),
              ),
              child: const Text('Push a page'),
            ),
            Button.outline(
              onPressed: () => Navigator.of(context).push(
                FinessePageRoute<void>(
                  fullscreenDialog: true,
                  builder: (_) => _Page(depth: depth, dialog: true),
                ),
              ),
              child: const Text('Open a full-screen dialog'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Centred title

`centerTitle` centres the title in the bar whatever sits on either side, and cuts it short rather than laying it under the buttons. `AppBarTheme.centerTitle` sets it for the whole app.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `centerTitle` puts the title in the centre of the bar — not of the space
/// the buttons leave — the way a pushed page is titled on iOS.
class AppBarCenterTitleExample extends StatelessWidget {
  const AppBarCenterTitleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 260,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: BackButton(onPressed: () {}),
          title: const Text('Notifications'),
          actions: [
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.gear),
              semanticLabel: 'Settings',
              onPressed: () {},
            ),
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.checks),
              semanticLabel: 'Mark all as read',
              onPressed: () {},
            ),
          ],
        ),
        body: Center(
          child: Text(
            'You are all caught up',
            style: Theme.of(context).textTheme.muted,
          ),
        ),
      ),
    );
  }
}
```

## A row under the toolbar

`bottom` is a second row inside the bar's surface and above its hairline — a `TabBar`, a search field, filter chips. It adds its own height, and the scaffold insets the page for all of it.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A tab bar in `bottom`: a second row inside the bar's surface, above its
/// hairline. The page is inset for the whole bar.
class AppBarBottomExample extends StatefulWidget {
  const AppBarBottomExample({super.key});

  @override
  State<AppBarBottomExample> createState() => _AppBarBottomExampleState();
}

class _AppBarBottomExampleState extends State<AppBarBottomExample> {
  static const _tabs = ['Albums', 'Artists', 'Songs'];

  String _tab = _tabs.first;

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      height: 420,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          actions: [
            IconButton.ghost(
              icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
              semanticLabel: 'Search',
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            // The bar draws the hairline under both rows.
            showBorder: false,
            tabs: [for (final tab in _tabs) Tab(value: tab, child: Text(tab))],
            value: _tab,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
        ),
        body: ListView(
          children: [
            for (var i = 1; i <= 12; i++) ListTile(title: Text('$_tab $i')),
          ],
        ),
      ),
    );
  }
}
```

## A surface only when scrolled

With `surfaceBehavior: AppBarSurfaceBehavior.whenScrolled` the fill, the hairline and the blur are absent while the page is at its top and fade in once content scrolls under the bar. It needs a `Scaffold` above it, which is what tells the bar the page has moved; nothing is rebuilt while it does.

```dart
import 'package:example/docs/phone_frame.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// With `AppBarSurfaceBehavior.whenScrolled` the bar is bare while the page
/// is at its top. Scroll: its fill, hairline and blur fade in as content
/// goes under it.
class AppBarScrolledExample extends StatelessWidget {
  const AppBarScrolledExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneFrame(
      height: 420,
      child: Scaffold(
        appBar: const AppBar(
          title: Text('Journal'),
          surfaceBehavior: AppBarSurfaceBehavior.whenScrolled,
        ),
        body: PageContainer(
          scrollable: true,
          child: FinesseColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            gap: GapSize.md,
            children: [
              for (final day in const ['Monday', 'Tuesday', 'Wednesday'])
                Card(
                  title: Text(day),
                  description: const Text('Three entries'),
                  child: Text(
                    'Walked the long way round the harbour before work. '
                    'The light was low and everything was quiet.',
                    style: theme.textTheme.small,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## With a middle

A `middle` is centred in the bar whatever sits on either side, which is where a `NavigationBar` goes on a wide screen. `NavigationScaffold` builds this bar for you.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The three-zone bar of a wide screen: a logo and a search field at the
/// start, the destinations centred, the actions at the end.
class AppBarMiddleExample extends StatefulWidget {
  const AppBarMiddleExample({super.key});

  @override
  State<AppBarMiddleExample> createState() => _AppBarMiddleExampleState();
}

class _AppBarMiddleExampleState extends State<AppBarMiddleExample> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A desktop arrangement: it needs the width, so on a narrow screen the
    // frame scrolls sideways rather than squeezing the three zones together.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 800,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: theme.radii.xl,
        ),
        // Painted over the content, so nothing covers the frame's corners.
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              primary: false,
              leading: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: theme.radii.md,
                ),
                child: PhosphorIcon(
                  PhosphorIconsBold.waves,
                  size: 18,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
              title: const TextField(
                placeholder: Text('Search'),
                leading: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
              ),
              middle: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: const [
                  NavigationDestination(
                    icon: PhosphorIcon(PhosphorIconsRegular.house),
                    selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: PhosphorIcon(PhosphorIconsRegular.usersThree),
                    selectedIcon: PhosphorIcon(PhosphorIconsFill.usersThree),
                    label: 'Network',
                  ),
                  NavigationDestination(
                    icon: PhosphorIcon(PhosphorIconsRegular.briefcase),
                    selectedIcon: PhosphorIcon(PhosphorIconsFill.briefcase),
                    label: 'Jobs',
                  ),
                ],
              ),
              actions: [
                IconButton.ghost(
                  icon: const PhosphorIcon(PhosphorIconsRegular.bell),
                  semanticLabel: 'Notifications',
                  onPressed: () {},
                ),
                const Avatar('', fallback: Text('NH')),
              ],
            ),
            SizedBox(
              height: 120,
              child: Center(
                child: Text('Page content', style: theme.textTheme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

