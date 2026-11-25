# Motion

Every animation in the package reads one vocabulary, `Motion`: three
durations, three curves, three springs and a few amounts. It lives on the
style, so a theme decides how lively the whole app is, and an app tunes or
switches it off in one place. The package has no `flutter_animate`
dependency, and no component takes `effects:`, `duration:`, `curve:` or
`animateIn` parameters.

| Preset | Used by | Character |
| --- | --- | --- |
| `Motion.lively` | the `finesse` style | springs with a little bounce, a clear press, stretching indicators, shimmering skeletons |
| `Motion.calm` | `nova`, `maia`, `lyra` (and the `Motion()` default) | the same movements, quieter |
| `Motion.none` | opt-in | nothing moves; state changes are instant |

```dart
FinesseApp(
  // Overrides the style's motion on both form factors.
  theme: ThemeData(motion: Motion.calm),
  home: const HomePage(),
)
```

Tune one token with `Motion.lively.copyWith(pressScale: .95)`. To change
motion for a part of the app, re-theme that subtree; there is no
per-widget animation parameter.

## Reading it

Read it with `Motion.of(context)`, never `Theme.of(context).motion`.
`of` returns the reduced form when the platform asks for reduced motion
(`MediaQuery.disableAnimationsOf`): springs become instant and nothing
scales, stretches or travels, while short fades stay.

```dart
class Hint extends StatelessWidget {
  const Hint({super.key, required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: motion.fast, // fast 120 ms, normal 200 ms, slow 320 ms
      curve: motion.standard, // standard, emphasized (arriving), exit
      child: child,
    );
  }
}
```

| Token | For |
| --- | --- |
| `fast`, `normal`, `slow` | Fades and colour changes. |
| `standard`, `emphasized`, `exit` | A change in place, something arriving, something leaving. |
| `snappy` | Touch response and selection indicators. |
| `smooth` | Surfaces: sheets, panels, accordions. |
| `bouncy` | Small things: a switch thumb, a check mark, a badge. |
| `pressScale`, `surfacePressScale` | How far a pressed control and a pressed card shrink. |
| `indicatorStretch` | How far a travelling selection stretches. |
| `overlayScale`, `overlayTravel` | How an overlay grows in from its anchor. |

A `MotionSpring(duration:, bounce:)` is described by how long it takes
and how much it overshoots. A spring keeps its velocity when its target
changes, so an interrupted transition turns around where it is instead of
jumping or starting again.

A component theme can still say otherwise: `TabsTheme.indicatorSpring`,
`ButtonTheme.pressScale`, `ProgressBarTheme.spring`. Left null, they
follow the tokens.

## What already moves

Nothing to do for these:

- Popovers, menus, the select list, tooltips, dialogs and sheets grow from
  their anchor or edge and leave faster than they arrive. Pages slide in
  on `FinessePageRoute`.
- `Tabs`, `TabBar`, `SegmentedControl`, the navigation bars, toggle groups
  and menubar triggers have one selection indicator that travels between
  items. The highlighted row of a menu, a `Select` or a `Command` does not
  travel or fade: it is on the row under the pointer or the arrow keys at
  once.
- Everything on `Pressable` (buttons, toggles, chips, cards with `onTap`,
  list tiles) shrinks slightly while pressed. On one button,
  `style: ButtonTheme(pressScale: 1)` switches it off; on a `Pressable`,
  `pressScale: 1`.
- `Switch`, `Checkbox`, `Radio`, `Accordion`, `Collapsible`,
  `ProgressBar`, `Slider`, toasts, sheets, badges, the `Board`, the
  reorderable list and the chat list move on springs.

## Building blocks

All exported, for custom widgets that should move like the built-in ones.

| Widget | For |
| --- | --- |
| `SpringBuilder` | A number that follows `value` on a spring; the spring counterpart of `TweenAnimationBuilder<double>`. |
| `SpringController` | The same, driven by hand (`animateTo`, `shiftBy`, `jumpTo`), for several values or a render object. |
| `SpringSize` | `AnimatedSize` on a spring. |
| `PressScale` | A paint-only scale while pressed. Pass `taps:` so a quick click, down and up within one frame, still pulses. `Pressable` already has one. |
| `MovingIndicator` + `MovingIndicatorTarget` | One decoration that travels between the selected items of a list. |
| `Entrance` | Showing and hiding something that appears in response to the user: a fade, a scale from an origin and a small travel. |
| `PopIn`, `PopOnChange` | A small thing appearing, or acknowledging that its value changed. |
| `ExpandReveal` | Height, fade and slide for content that opens. |
| `ContentSwitch` | A directional fade and slide when `value` changes. |
| `AnimatedFill`, `AnimatedColorBuilder` | Fading between state colours. |

```dart
class Counter extends StatelessWidget {
  const Counter({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return PopOnChange(
      value: count,
      child: ContentSwitch(
        value: count,
        child: Text('$count', style: Theme.of(context).textTheme.h3),
      ),
    );
  }
}
```

## Rules

- **Fade colours with `AnimatedFill`, not `AnimatedContainer`.**
  `Color.lerp` between colours of different opacity (a 4% wash and an
  opaque white) passes through a half-opaque grey darker than both ends,
  which reads as a flash.
- **A travelling selection is not the item's own fill.** Mark each item
  with `MovingIndicatorTarget` and let the list paint one
  `MovingIndicator`. Keep no `RepaintBoundary` between the indicator and
  its targets.
- **Do not fade glass with `Opacity`.** A blurred surface under an
  opacity layer loses its backdrop on some renderers, the web among them.
- **Do not make a `CurvedAnimation` in `build`**: it leaks a listener on
  every rebuild. Use `controller.drive(CurveTween(curve: ...))`.
- **Wrap a static `Alert` or `Empty` in an `Entrance`** only where it
  arrives in response to the user; on their own they are simply there, so a
  page of them does not animate when it opens.
- **Nothing animates forever at rest.** Something that never stops (a
  spinner, typing dots) is painted, not rebuilt, in a layer of its own.
- In widget tests, `pumpAndSettle` never returns while a `Spinner` or a
  `Skeleton` is on screen; pump fixed frames. After a state change, pump
  the fade (200 ms) or the spring (400 ms) before reading a colour or a
  position.

See also: [building-blocks.md](building-blocks.md),
[accessibility.md](accessibility.md).
