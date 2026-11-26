# Lists: rows, sections, reordering, swipe actions and tables

## Rows

A `ListTile` is a row: `leading`, `title`, `subtitle`, a `value` at the
end (a setting's current choice, a file size), `trailing`, and
`showChevron` for a row that opens something. `onTap` makes it pressable;
`selected` and `destructive` colour it.

```dart
ListTile(
  leading: const IconTile(icon: PhosphorIcon(PhosphorIconsRegular.bell)),
  title: const Text('Notifications'),
  subtitle: const Text('Push, email and in-app'),
  value: const Text('On'),
  showChevron: true,
  onTap: () {},
)
```

A row with a control is a `SwitchListTile`, `CheckboxListTile` or
`RadioListTile<T>`: the whole row toggles the control, the row is one
semantics node, and `controlAffinity` puts the control at the start or the
end. A radio tile takes only its `value`: like a `Radio`, it belongs to
the `UnaRadioGroup` around it (give the group the `ListSection` as
its `child`), which holds `value` and `onChanged`.

A row that opens to show rows of its own is an `ExpansionTile(title:,
children:)` (`open`/`initiallyOpen`/`onOpenChanged`).

## Sections

`ListSection` groups rows under a header, the grouped list of a settings
page. `ListSectionVariant.card` (the default) sets them on a card with
hairlines between rows; `plain` drops the card.

```dart
ListSection(
  header: const Text('Account'),
  footer: const Text('Your email is never shown to other members.'),
  children: [
    ListTile(title: const Text('Email'), value: const Text('ada@example.com')),
    SwitchListTile(
      title: const Text('Two-factor sign-in'),
      value: true,
      onChanged: (value) {},
    ),
  ],
)
```

- Rows inside a section take the section's padding, minimum height and
  square press highlight by themselves; do not pad them.
- The hairlines are drawn by the rows, aligned with the title
  (`dividerIndent` moves them, `dividers: false` removes them).

## Long lists are lazy

A list of more than a screenful is built lazily: a `ListView.builder`, or
in a `CustomScrollView` a `SliverListSection.builder`, which is a
`ListSection` whose rows are built as they scroll into view.

```dart
CustomScrollView(
  slivers: [
    SliverAppBar.large(title: const Text('Contacts')),
    SliverListSection.builder(
      header: const Text('All'),
      itemCount: 500,
      itemBuilder: (context, index) => ListTile(
        title: Text('Contact $index'),
        onTap: () {},
      ),
    ),
  ],
)
```

`PageContainer(scrollable: true)` wraps a whole page in one scroll view
and is right for a page of a few cards, not for a feed.

## Reordering

`ReorderableListView` lets rows be dragged into a new order, with the
board's lift, springs and haptics. It is controlled, and **`to` is the
row's final index**, so the update is one line:

```dart
class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  final _tracks = ['Intro', 'Northern lights', 'Undertow', 'Coda'];

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (from, to) =>
          setState(() => _tracks.insert(to, _tracks.removeAt(from))),
      itemSemanticLabel: (index) => _tracks[index],
      children: [
        for (final track in _tracks)
          ListTile(
            key: ValueKey(track), // the key belongs to the item
            title: Text(track),
            trailing: const ReorderableDragHandle(),
          ),
      ],
    );
  }
}
```

- A finger picks a row up with a long press anywhere on it
  (`longPressToDrag`), or at once by its `ReorderableDragHandle`; a mouse
  drags by the handle. From the keyboard, Space picks the focused row up,
  the arrows move it and Space drops it; every step is announced.
- `ReorderableListView.builder(itemCount:, itemId:, itemBuilder:)` and
  `SliverReorderableListView` are the lazy forms; `itemId` gives each row a
  stable identity.
- Moving cards between columns as well is a `Board`; see
  [board-and-chat.md](board-and-chat.md).

## Swipe actions

`SwipeActions` puts actions behind a row, uncovered by swiping it
sideways. With a mouse, a right click shows the same actions as a menu.

```dart
SwipeActions(
  trailing: [
    SwipeAction(
      icon: const PhosphorIcon(PhosphorIconsRegular.trash),
      label: 'Delete',
      destructive: true,
      onPressed: () async => true, // true: the row leaves
    ),
  ],
  onRemoved: () {},
  child: const ListTile(title: Text('Invoice.pdf')),
)
```

An action's `onPressed` returns whether the row leaves; a `Future` keeps
the row open until it completes, which is where to ask "are you sure?".
`fullSwipe` runs the outermost action when the row is swiped all the way.
Remove the item from your data in `onRemoved`.

## Pull to refresh

`RefreshIndicator(onRefresh: () async {...}, child: list)` around a
scroll view: pull past the top and it spins until the future completes.

## Tables

| Widget | What it is |
| --- | --- |
| `UnaTable` | The grid: header, body and footer rows of cells you build, laid out lazily in both directions. It knows nothing about your data. |
| `DataTable` | Data features on top of the grid: give it `columns` and a `DataTableController`, and it sorts, filters, selects and pages. |

`DataTableController(rows:, pageSize:)` holds rows in memory.
`DataTableController.remote(pageSize:, onPageRequested:)` asks a server
for one page at a time: the callback gets a `DataTablePageRequest` (page,
page size, sort column and direction, query) and returns a
`DataTablePage(rows:, rowCount:)`. Sorting, paging and the query are sent
to the source; skeleton rows stand in while a page loads, and a failure
shows a retry button (`errorBuilder` replaces it).

See also: [list-tile.md](../components/list-tile.md),
[list-section.md](../components/list-section.md),
[expansion-tile.md](../components/expansion-tile.md),
[reorderable-list-view.md](../components/reorderable-list-view.md),
[swipe-actions.md](../components/swipe-actions.md),
[refresh-indicator.md](../components/refresh-indicator.md),
[table.md](../components/table.md),
[data-table.md](../components/data-table.md).
