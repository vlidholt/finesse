# Accessibility: semantics, keyboard, text scale and direction

The components announce themselves, take the keyboard, grow with large
text and mirror in right-to-left languages. App code keeps that working by
following a few rules.

## Semantics

- **Name every control that has no visible text.** An icon-only button
  takes `semanticLabel` (and usually `tooltip`):
  `IconButton.ghost(icon: ..., semanticLabel: 'Delete', onPressed: ...)`.
- **A control is one node.** `Button`, `IconButton`, `Toggle`, the FAB and
  the list tiles are each one semantics node with the role, the label, the
  enabled state and the tap action. A `Pressable` of your own does the same
  with `semanticContainer: true`.
- **A control named by a visible label is one node.** Where a label sits
  beside a control you build, wrap both in `MergeSemantics`, or
  `ExcludeSemantics` the label the control already repeats. A screen reader
  should stop on it once.
- `AppBar.title` is announced as a heading. Menus carry menu roles, tab
  bars a tab-bar role, segmented controls are a radio group, sliders and
  ratings are adjustable.
- A loading `Button` reports "Loading" and is not enabled. The board, the
  reorderable list, a remote `DataTable` and `StreamingText` announce
  what they do (moves, loading rows, a finished reply).
- Give a `Board` and a `ReorderableListView` an `itemSemanticLabel`, so
  moves are announced by name.

## Keyboard

- Enter and Space activate everything pressable, on every platform
  including the web.
- Tab moves between controls; a focus ring shows only for keyboard focus.
  A tab bar and a segmented control are one Tab stop, and the arrow keys
  move the selection inside them.
- Menus, selects and command palettes take the arrow keys, Enter,
  type-ahead and Escape; one Escape closes one layer, innermost first.
- A popover that takes the focus traps Tab and gives the focus back to
  its trigger when it closes.
- F6 moves the focus to the toasts; ⌘B / Ctrl+B toggles a `Sidebar`.
- Bind Escape for your own overlay with `DismissShortcut`, never a bare
  `CallbackShortcuts`, which would swallow Escape while the overlay is
  closed and keep the dialog around it open.

## Text scale

Every control is laid out for the platform's text scale. A style's
control height is a *floor*: exactly the style height at a scale of 1 or
less, and above that the control grows when its content needs the room.
Calendar cells, OTP slots and time-picker fields scale their side; the
app bar grows to fit its title.

For your own layout:

- Do not put text in a box of fixed height; constrain a minimum instead.
- Inside a control, nothing may expand to the height it is offered.
- Read sizes from text styles and the theme, which scale, not from
  literals.
- Check a screen at a text scale of 2: nothing should clip or overflow.

## Right to left

- No una widget takes a `textDirection` parameter (except text
  widgets and `UnaRow`/`UnaColumn`, like Flutter's own). Wrap a
  subtree in a `Directionality` to change it.
- Write `start` and `end`: `AlignmentDirectional`,
  `EdgeInsetsDirectional`, `CrossAxisAlignment.start`. `SheetSide.start`,
  `FloatingActionButtonLocation.end` and the drawers follow the reading
  direction.
- Icons do not mirror themselves (a checkmark must not flip). Components
  pick their own carets per direction; in your code pick `caretLeft` or
  `caretRight` from `Directionality.of(context)`.

## Reduced motion

Read motion with `Motion.of(context)`; it returns the reduced form when
the platform asks for less motion: no springs, scaling or travel, short
fades only. Every component already does. See [motion.md](motion.md).

## Localized strings

The package's own strings come from `UnaLocalizations.of(context)`,
in some 80 languages. Strings in a control you build that duplicate one of
una's (Cancel, Back, Done, Clear...) should come from there too.

See also: [building-blocks.md](building-blocks.md),
[overlays.md](overlays.md).
