# Overlays: popovers, menus, dialogs, sheets and toasts

Everything that floats above the page. Pick by what the user is doing;
each one already presents itself the way the form factor expects, so a
desktop popover becomes a bottom sheet on a phone without a branch in
your code.

| The user... | Use | On a phone |
| --- | --- | --- |
| needs a little more on the thing they pointed at | `Tooltip` (hover or focus), `HoverCard` (rests on a link) | a long press |
| picks an action from a list under a button | `DropdownMenu` | the same menu |
| right-clicks or long-presses something | `ContextMenuRegion` | a long press |
| picks one of a few actions about what they touched | `showActionSheet` | a sheet from the bottom |
| works with a small panel tied to a control | `Popover` | consider a sheet |
| must answer before going on | `showDialog` + `Dialog` / `Dialog.alert` | a dialog fitted to the phone |
| works in a panel beside or over the page | `showSheet` + `Sheet` | resting at detents, dragged |
| is told something happened | `Toaster.of(context).show(Toast(...))` | spans the bottom, swiped away |
| searches or runs a command | `showCommandDialog`, `showSearch` | `showSearch` is a full page |

Every overlay grows from its anchor on the theme's springs and leaves
faster than it arrives. No overlay takes `effects:`, `duration:` or
animation parameters: motion comes from `Motion.of(context)` (see
[motion.md](motion.md)).

## Popover

A `Popover` anchors `builder`'s content to its `child`. It is open while
`open` is true, or while its `PopoverController` says so:

```dart
class Dimensions extends StatefulWidget {
  const Dimensions({super.key});

  @override
  State<Dimensions> createState() => _DimensionsState();
}

class _DimensionsState extends State<Dimensions> {
  final _popover = PopoverController();

  @override
  void dispose() {
    _popover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Popover(
      controller: _popover,
      showArrow: true,
      builder: (context) => const SizedBox(
        width: 260,
        child: TextField(placeholder: Text('Width')),
      ),
      child: Button.outline(
        onPressed: _popover.toggle,
        child: const Text('Dimensions'),
      ),
    );
  }
}
```

- **One controller for every overlay.** `PopoverController` drives
  `Popover`, `DropdownMenu`, `ContextMenu`, `ContextMenuRegion`, `Tooltip`
  and `Select`: `isOpen`, `open()`, `close()`, `toggle()`,
  `setOpen(bool)`, and `openAt(globalPosition)` for a menu at a point.
  There is no `TooltipController` or context-menu controller.
- **Focus.** `requestFocus: true` (the default) moves the focus into the
  popover and traps Tab there; Escape closes it and the focus goes back to
  the trigger. `requestFocus: false` leaves the caret where it is, for a
  list of suggestions under a field (this is what `Autocomplete` does).
  `DropdownMenu`, `ContextMenu`, `ContextMenuRegion`, `DatePicker` and
  `showPopover` take the same flag.
- A tap outside closes it (`closeOnTapOutside`). A popover opened inside
  another counts as inside it.
- A popover whose anchor is hidden (another tab of an `IndexedStack`, a
  covered route, an `Offstage`) closes with it.
- `showPopover(context:, anchorRect:, builder:)` opens one against any
  rectangle, from code, and returns a `Future` like a route.

### Anchors

`anchor:` says where the overlay goes. The default for each component is
already right; reach for it to place a custom overlay.

- `AnchorAuto(targetAnchor:, followerAnchor:, fallback:)` puts the
  follower's `followerAnchor` point on the child's `targetAnchor` point,
  tries `fallback` (itself an `AnchorAuto`) when that does not fit, and
  then shifts the overlay inward, keeping a small gap from the screen edge.
- `Anchor(childAlignment:, overlayAlignment:)` is a fixed placement.
- `GlobalAnchor(offset)` places the overlay at a point in global
  coordinates, as a context menu does at the pointer.

## Menus

```dart
DropdownMenu(
  builder: (context, controller, child) => Button.outline(
    onPressed: controller.toggle,
    trailing: const PhosphorIcon(PhosphorIconsRegular.caretDown),
    child: const Text('Sort'),
  ),
  items: [
    MenuLabel(child: const Text('Sort by')),
    MenuRadioGroup<String>(
      value: 'recent',
      onChanged: (value) {},
      children: const [
        MenuRadioItem(value: 'recent', child: Text('Most recent')),
        MenuRadioItem(value: 'relevant', child: Text('Most relevant')),
      ],
    ),
    const MenuDivider(),
    MenuItem(
      leading: const PhosphorIcon(PhosphorIconsRegular.trash),
      destructive: true,
      onPressed: () {},
      child: const Text('Clear history'),
    ),
  ],
)
```

- Rows are `MenuItem` (with `leading`, `trailing`, `shortcut:
  MenuShortcut(SingleActivator(...))`, `destructive`, and `items:` for a
  submenu), `MenuCheckboxItem` (`checked`, `onChanged`), `MenuRadioGroup` +
  `MenuRadioItem`, `MenuLabel` and `MenuDivider`. The same rows go in
  `ContextMenuRegion(items:)`, `Menubar` and `showMenu`.
- Menus flip to stay on screen, scroll when long, and take the arrow keys,
  Enter, type-ahead and Escape (one press closes one submenu).
- `ContextMenuRegion(items:, child:)` opens a menu at the pointer on a
  right click and at the finger on a long press. `showMenu(context:,
  position:, items:)` opens one from code.
- In the `fluid` style menus are glass; `ThemeData(menuTranslucent:
  false)` keeps them solid, and `menuColorScheme` / `menuAccent` restyle
  them (see [theming.md](theming.md)).

## Tooltips and hover cards

```dart
Tooltip(
  builder: (context) => const Text('Archive'),
  child: IconButton.ghost(
    icon: const PhosphorIcon(PhosphorIconsRegular.archive),
    semanticLabel: 'Archive',
    onPressed: () {},
  ),
)
```

A tooltip shows on hover after `waitDuration`, on keyboard focus, and under
a held finger. An `IconButton` has a `tooltip:` parameter that does this
for you. `HoverCard(builder:, child:)` is a larger card of extra content
for a link or a name, opened after a pause on hover, on focus or on a long
press.

## Dialogs

```dart
Future<void> confirmDelete(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog.alert(
      title: const Text('Delete this post?'),
      description: const Text('This cannot be undone.'),
      actions: [
        Button.outline(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        Button.destructive(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed ?? false) save();
}
```

- `Dialog` has `title`, `description`, `child` and `actions`;
  `Dialog.alert` is the variant for a question. A dialog has no close
  button unless `showCloseButton: true` (`closeIcon` changes the glyph,
  `closeButton` replaces the whole button).
- On a phone the dialog follows the form factor, not the window: its
  actions stack at the dialog's full width (except a row you build
  yourself), its text is centred, and where it has the screen's whole width
  it is a band across it.
- The barrier is a light tint over a blur. A tap on it closes the dialog
  unless `barrierDismissible: false`.

## Sheets

`showSheet` presents a `Sheet` over a barrier; its builder must return one.
A sheet attaches to an edge (`side:`: `bottom` by default, or `top`,
`start`, `end`, `left`, `right`) and, from the bottom, rests at
`detents`:

```dart
showSheet<void>(
  context: context,
  builder: (context) => Sheet(
    title: const Text('Filters'),
    detents: const [SheetDetent.medium, SheetDetent.large],
    actions: [
      Button(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Show results'),
      ),
    ],
    child: const Text('Filter controls'),
  ),
);
```

- Detents: `SheetDetent.content` (as tall as its content, the default),
  `medium` (half), `large`, `full`, and `SheetDetent.fraction(.3)` /
  `SheetDetent.height(320)`. With more than one, the sheet shows a drag
  handle, follows a finger between them and reports `onDetentChanged`; a
  `SheetController` moves it with `animateTo(detent)`.
- A list inside the sheet hands its drag to the sheet: scrolled to its top,
  dragging down moves the sheet. Use `Sheet(builder: (context,
  scrollController) => ListView(controller: scrollController, ...))` for a
  long list.
- Dragged past its lowest detent, or tapped outside, a sheet closes
  (`dismissible: false` on `showSheet` keeps it).
- A `Sheet` placed in the tree, for example as `Scaffold.bottomSheet`,
  stays beside the content instead of covering it.

## Action sheets

```dart
Future<void> moreActions(BuildContext context) async {
  final choice = await showActionSheet<String>(
    context: context,
    title: const Text('This post'),
    actions: const [
      ActionSheetAction(label: Text('Share'), value: 'share'),
      ActionSheetAction(label: Text('Report'), value: 'report',
          destructive: true),
    ],
  );
  if (choice == 'report') save();
}
```

On a phone it is a sheet from the bottom with a Cancel row; on a desktop a
small menu at `anchorRect`, or a dialog.

## Toasts

`UnaApp` installs one `Toaster` above the navigator. Show a toast from
anywhere below it:

```dart
final id = Toaster.of(context).show(
  Toast(
    variant: ToastVariant.success,
    title: const Text('Post published'),
    action: Button.outline(
      size: ButtonSize.sm,
      onPressed: () {},
      child: const Text('Undo'),
    ),
  ),
);
```

`show` returns an id for `update(id, toast)` and `dismiss(id)`;
`dismissAll()` clears them. Variants are `neutral`, `success`, `warning`,
`destructive` and `loading` (a spinner; it stays until updated or
dismissed). Toasts stack, pause while hovered, leave by themselves after
`duration`, can be swiped away, and stay clear of the bottom bar. F6
moves the keyboard focus to them.

## Command palette and search

`showCommandDialog(context:, groups:)` is a filtered list of actions
(`CommandGroup(heading:, items: [CommandItem(label:, onSelected:)])`),
searched in memory with full keyboard navigation. `showSearch<T>(context:,
builder: (context, query, close) => ...)` is for results looked up per
query: a page on a phone, a palette on a desktop; the builder runs once
typing pauses and `close(result)` returns a value.

## Your own floating UI

- Draw it on a `Surface(kind: SurfaceKind.popover, child: ...)` (or
  `SurfaceKind.menu`): the same colours, hairline, shadow and glass as the
  built-in overlays. See [surfaces.md](surfaces.md).
- Place it with a `Popover`, or `showPopover` against a rectangle.
- `Portal(visible:, anchor:, portalBuilder:, child:)` is the primitive
  under all of them: it renders `portalBuilder`'s widget in the overlay,
  anchored to `child`, with no surface, focus handling or motion. Use it
  only for something none of the above can be.
- Close it on Escape with `DismissShortcut(isActive: () => isOpen,
  onDismiss: close, child: ...)`. It answers only while active, so the
  dialog around it still closes on the next press; never bind Escape with
  a bare `CallbackShortcuts`.

See also: [popover.md](../components/popover.md),
[dropdown-menu.md](../components/dropdown-menu.md),
[context-menu.md](../components/context-menu.md),
[menubar.md](../components/menubar.md),
[tooltip.md](../components/tooltip.md),
[hover-card.md](../components/hover-card.md),
[dialog.md](../components/dialog.md), [sheet.md](../components/sheet.md),
[action-sheet.md](../components/action-sheet.md),
[toast.md](../components/toast.md), [command.md](../components/command.md),
[search-view.md](../components/search-view.md).
