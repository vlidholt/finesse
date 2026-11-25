# App structure: scaffolds, bars, navigation and routes

How a finesse screen is put together, from the frame of one page to the
destinations of a whole app. Every piece here follows the form factor by
itself: write the screen once and it becomes a phone screen below the `md`
breakpoint (see [form-factors.md](form-factors.md)).

## One screen: `Scaffold`

A `Scaffold` lays its slots over the body and tells the body how far to
inset itself. The bars are drawn *over* the page, so the page scrolls
beneath a translucent bar, and the body's `MediaQuery` padding includes
the bars' heights: a `PageContainer`, a `ListView` or a `SafeArea` inside
it clears them without being told.

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Inbox'),
    actions: [
      IconButton.ghost(
        icon: const PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
        semanticLabel: 'Search',
        onPressed: () {},
      ),
    ],
  ),
  floatingActionButton: FloatingActionButton(
    icon: const PhosphorIcon(PhosphorIconsRegular.notePencil),
    label: const Text('Compose'),
    onPressed: () {},
  ),
  body: const PageContainer(
    scrollable: true,
    child: Text('Messages'),
  ),
)
```

| Slot | What goes there |
| --- | --- |
| `appBar` | An `AppBar`. For a bar that scrolls with the page, leave this empty and make a `SliverAppBar` the first sliver of the body. |
| `banner` | A notice under the app bar, usually an `Alert(onDismissed:)`. |
| `bottomNavigationBar` | A `BottomNavigationBar` or a `Toolbar`. |
| `footer` | A strip over the end of the page that rises with the keyboard: a message composer, a row of actions. Wrap one that is not a bar in a `SafeArea`. |
| `bottomSheet` | A panel above the footer that does not block the page: a mini player, an inline `Sheet` resting at its detents. |
| `floatingActionButton` | A `FloatingActionButton`; `floatingActionButtonLocation` is `start`, `center` or `end`. It is kept clear of the bars and the keyboard. |
| `drawer`, `endDrawer` | Panels that slide in from an edge, also by a drag from that edge. `Scaffold.of(context).openDrawer()` / `openEndDrawer()`. |

- The body is measured in the same layout pass as the bars, so its inset
  is right on the first frame whatever the bars' heights.
- With `resizeToAvoidBottomInset` (the default) the body ends where the
  keyboard begins and sees no `viewInsets.bottom` of its own; the footer,
  the bottom sheet and the action button ride up with the keyboard, and the
  bottom navigation bar stays where it is and is covered. Pass `false` to
  handle the keyboard yourself.
- `systemOverlayStyle` styles the status bar; by default its icons follow
  the page and the app bar.

## Bars

`AppBar` is a logo or back button, a title and actions. Its height
follows the form factor (and grows when large text needs a second line),
and its fill is the style's bar opacity over a blur.

- **Leading is implied.** With no `leading`, a bar on a page that can be
  popped shows a `BackButton`, on a full-screen dialog a `CloseButton`,
  and over a scaffold with a `drawer` a menu button. Pass
  `automaticallyImplyLeading: false` to show nothing. Never hand-build a
  back button.
- **Actions are implied too**: with no `actions` over a scaffold that has an
  `endDrawer`, the bar shows the button that opens it
  (`automaticallyImplyActions`).
- `title` is announced as a heading; `centerTitle: true` centres it.
  `middle` replaces the title with any widget (a search field).
- `bottom` holds a `TabBar` under the bar; share a `TabsController` with the
  `TabBarView` in the body.
- `surfaceBehavior: AppBarSurfaceBehavior.whenScrolled` keeps the bar clear
  until the page scrolls beneath it.

`SliverAppBar` lives in the scroll view instead: `SliverAppBar.large` has a
large title that collapses into the toolbar, `floating: true` comes back
when the reader scrolls up. Give the scaffold no `appBar` and make the
sliver bar the first sliver of the body's `CustomScrollView`.

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar.large(title: const Text('Settings')),
      SliverListSection(
        header: const Text('Account'),
        children: [
          ListTile(
            title: const Text('Profile'),
            showChevron: true,
            onTap: () {},
          ),
        ],
      ),
    ],
  ),
)
```

Along the bottom: `BottomNavigationBar` carries destinations (below), and
`Toolbar` carries actions on what is showing (`children`, usually
`IconButton.ghost`s, and a `trailing` one that stands apart). Both float as
a glass pill in a style whose bottom bar floats, and span the edge
otherwise.

## Many destinations: `NavigationScaffold`

An app with several top-level sections gives `NavigationScaffold` one list
of `NavigationDestination`s. On a desktop they sit in the app bar (a
`NavigationBar`); on a phone in a `BottomNavigationBar`; with
`layout: NavigationLayout.rail` down the start edge in a `NavigationRail`.
The default, `NavigationLayout.auto`, follows the form factor.

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
      title: const Text('Strand'),
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: const [
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.house),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
          label: 'Home',
        ),
        NavigationDestination(
          icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
          selectedIcon: PhosphorIcon(PhosphorIconsFill.chatCircleDots),
          label: 'Messages',
          badgeCount: 3,
        ),
      ],
      body: DestinationStack(
        index: _index,
        builders: [
          (context) => const PageContainer(child: Text('Home')),
          (context) => const PageContainer(child: Text('Messages')),
        ],
      ),
    );
  }
}
```

- The selected destination's icon is the fill weight of the same glyph
  (`selectedIcon`); see [icons.md](icons.md).
- `DestinationStack` keeps each destination's page alive and off stage
  while another shows, so scroll positions and drafts survive a switch.
- `action:` is a `NavigationAction`, the one prominent button (Create
  post) that sits in the bars; `showInTopBar`, `showInBottomBar` and
  `showInRail` on a destination leave it out of one of them.
- A site-style row of links with drop-down panels is a `NavigationMenu`
  (`NavigationMenuItem`, `NavigationMenuLink`); it becomes a sheet on a
  phone.
- A collapsible side panel of navigation is a `Sidebar` inside a
  `SidebarScaffold` (an icon rail or off-canvas on a desktop, a sheet on a
  phone; `SidebarController` has `isOpen`, `open()`, `close()`,
  `toggle()`, and `isMobileOpen`/`openMobile()` for the phone sheet).

## Pages and routes

`FinesseApp` pushes `FinessePageRoute`s: a short slide and fade on the
theme's motion, from the end edge on a phone. Push one yourself the usual
way:

```dart
Navigator.of(context).push(
  FinessePageRoute<void>(builder: (context) => const DetailPage()),
);
```

- A pushed page has its own `Scaffold` and `AppBar`; the bar shows the
  back button by itself.
- `fullscreenDialog: true` slides the page up and gives its bar a close
  button: a compose screen, a search on a phone.
- Back gestures are on: a drag from the start edge on iOS, the predictive
  back preview on Android. `backGesture: false` turns them off for one
  route. `FinessePage` is the same route for a declarative page list
  (`Navigator.pages`, a router).
- A list and the detail of what is chosen in it is a `ListDetailLayout`:
  side by side on a desktop, the detail pushed over the list on a phone.

## Tabs and segments

| Widget | Use it to |
| --- | --- |
| `Tabs` | Show one of several sections of content, with the tab list above it. |
| `TabBar` + `TabBarView` | The same, apart: the list in an `AppBar.bottom`, the pages in the body, sharing a `TabsController`. |
| `SegmentedControl` | Pick one of a few *values* (a filter, a mode), not a view. |
| `ToggleGroup` | Turn several options on or off. |

All of them are controlled: `value` and `onChanged`. Tabs are data, not
widgets:

```dart
Tabs<String>(
  value: 'posts',
  onChanged: (value) {},
  tabs: const [
    Tab(value: 'posts', child: Text('Posts'), content: Text('Posts')),
    Tab(value: 'about', child: Text('About'), content: Text('About')),
  ],
)
```

`TabBarVariant.underline` is text tabs with a line under the selected one;
`TabBarVariant.segmented` is a filled strip with a raised pill. The
selection indicator travels between tabs on a spring.

## Insets for floating things

Toasts and other floating UI stay clear of the bars through
`OverlayInsets`: a `Scaffold` reports the screen edges its bars cover, and
`Toaster` (installed by `FinesseApp`) is an `OverlayInsetsScope` that lifts
its toasts above them. Something of your own that floats over the page can
read the same value with `OverlayInsets.watch(context)`.

See also: [scaffold.md](../components/scaffold.md),
[app-bar.md](../components/app-bar.md),
[sliver-app-bar.md](../components/sliver-app-bar.md),
[navigation-bar.md](../components/navigation-bar.md),
[navigation-rail.md](../components/navigation-rail.md),
[page-route.md](../components/page-route.md),
[list-detail-layout.md](../components/list-detail-layout.md),
[tab-bar.md](../components/tab-bar.md).
