# Building blocks: controls of your own, and haptics

The pieces the components are made of, exported for a control finesse does
not have. Reach for a component first; a hand-made control misses
behaviour that is easy to forget (keyboard activation on the web, one
semantics node, the press response, the focus ring, haptics).

## Restyling a built-in control first

Before building, check whether a style object is enough. `Button`,
`IconButton` and `Toggle` take one `style:`, a `ButtonTheme` (a
`ToggleTheme` for `Toggle`) merged over the variant's theme. Every colour,
size, padding and decoration lives there, not in constructor parameters:

```dart
Button(
  style: ButtonTheme(
    backgroundColor: Theme.of(context).colorScheme.success,
    height: 48,
  ),
  onPressed: () {},
  child: const Text('Approve'),
)
```

- A button's API is `child`, `leading`, `trailing`, `onPressed`,
  `onLongPress`, `variant` (or the shortcuts `Button.outline`,
  `.secondary`, `.ghost`, `.destructive`, `.link`), `size`
  (`ButtonSize.sm`, `regular`, `lg`), `enabled`, `loading`, `expands`,
  `semanticLabel` and `style`.
- An icon-only button is an `IconButton(icon:, semanticLabel:)`, with an
  optional `tooltip:`. There is no `ButtonSize.icon`.
- A pressable pill is a `Chip`; a `Badge` is a static label and takes no
  callbacks.
- For a double tap, a secondary tap or a tap-down, wrap the button in a
  `FinesseGestureDetector`; the button keeps its own tap.

## Pressable

`Pressable` is the behaviour under everything that is pressed (`Button`,
`IconButton`, `Toggle`, `Chip`, `ListTile`, the navigation bars, the FAB).
It handles pointer and keyboard activation (Enter and Space, also on the
web), hover, the press scale, the cursor and the button semantics, and
hands its interaction states to a builder. It paints nothing.

```dart
class Swatch extends StatelessWidget {
  const Swatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Pressable(
      onPressed: onPressed,
      selected: selected,
      semanticLabel: 'Colour',
      semanticContainer: true,
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.full,
        child: AnimatedFill(
          color: color,
          borderColor: states.contains(WidgetState.selected)
              ? theme.colorScheme.foreground
              : null,
          borderWidth: 2,
          borderRadius: theme.radii.full,
          child: const SizedBox.square(dimension: 32),
        ),
      ),
    );
  }
}
```

- `states` is a `Set<WidgetState>` (`hovered`, `focused`, `pressed`,
  `selected`, `disabled`). A click is down and up within one frame, so a
  builder rarely sees `pressed`; the press response is `pressScale`, which
  `Pressable` already plays (pass `pressScale: 1` to switch it off). Do not
  add a `PressScale` inside a `Pressable`: it scales twice.
- `semanticContainer: true` makes the region one semantics node with the
  label, the role and the tap action, as the buttons do. Without it, a
  label beside the control merges into it.
- `enabled: false`, or no callbacks, disables it; `toggled:` reports a
  pressed/on state; `statesController:` shares the states with something
  outside.
- `FocusRing(visible:, borderRadius:, child:)` draws the theme's focus ring
  around anything; it is the same widget shown or hidden, so its child
  keeps its state.
- `AnimatedFill` fades its fill and border between state colours. Use it,
  not `AnimatedContainer`: `Color.lerp` between colours of different
  opacity passes through a darker grey and reads as a flash. It takes its
  timing from the theme's motion.

## Other blocks

| Widget | For |
| --- | --- |
| `FinesseGestureDetector` | Gestures `Pressable` has no callback for: double tap, secondary tap, tap-down, long-press phases. On touch it reports a press as a hover, as menus need. |
| `Disabled(disabled:, child:)` | Dims a subtree and takes it out of the focus order (`showForbiddenCursor` adds the cursor). |
| `Focusable` | A focus node with a builder that is told whether it is focused. |
| `RovingFocus` + `RovingFocusController` | One Tab stop for a group, with the arrow keys moving inside it and type-ahead. |
| `DismissShortcut` | Escape that closes your overlay and nothing else (see [overlays.md](overlays.md)). |
| `Backdrop`, `ShadowDecoration` | Blur and outer shadows for a surface of your own (see [surfaces.md](surfaces.md)). |
| `FormFactorBuilder` | Two layouts, one per form factor (see [form-factors.md](form-factors.md)). |
| `OverlayInsets` | How far the bars cover the screen, for something that floats (see [app-structure.md](app-structure.md)). |

## Haptics

Every tick a finesse control makes under a finger goes through `Haptics`,
and an app's own controls should too. Never call `HapticFeedback`
directly.

```dart
Slider(
  value: .5,
  onChanged: (value) {
    Haptics.selection(context);
  },
)
```

- `Haptics.selection(context)` is the tick of a value passing a step;
  `Haptics.impact(context, HapticImpact.medium)` is something picked up
  or armed (`light` for a drop or a toggle, `heavy` rarely).
- A call does nothing on the web and desktop platforms, under a theme with
  `ThemeData(haptics: false)` (for the app, or a subtree), and in tests
  unless `Haptics.debugEnabledInTests` is set.
- It does not look at the pointer kind. A control also driven by a mouse
  or the keyboard ticks only for a finger's changes, as the board and the
  wheel do.
- Already built in: the board, the reorderable list, sliders, the wheel
  picker, rating, number field steppers, tab lists and segmented controls,
  swipe actions, pull to refresh, switches, checkboxes, a sheet passing a
  detent and a context menu opened by a long press.

See also: [pressable.md](../components/pressable.md),
[button.md](../components/button.md),
[icon-button.md](../components/icon-button.md),
[accessibility.md](accessibility.md).
