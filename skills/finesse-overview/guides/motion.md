# Motion

Every animation in the package reads one vocabulary, `Motion`: three durations, three curves, three springs and a few amounts. It lives on the style, so a theme decides how lively the whole app is, and an app can tune or switch it off in one place.

| Preset | Used by | Character |
| --- | --- | --- |
| `Motion.lively` | the `finesse` style | springs with a little bounce, press scale, stretching indicators, shimmer |
| `Motion.calm` | `nova`, `maia`, `lyra` (and the `Motion()` default) | the same movements, quieter |
| `Motion.none` | opt-in | nothing moves; state changes are instant |

```dart
FinesseApp(
  // Overrides the style's motion on both form factors.
  theme: ThemeData(motion: Motion.calm),
  home: const HomePage(),
)
```

## Reading it

Read it with `Motion.of(context)`, never `Theme.of(context).motion`: `of` returns the reduced form when the platform asks for reduced motion (`MediaQuery.disableAnimationsOf`), in which springs are instant and scale, stretch and travel are gone.

```dart
final motion = Motion.of(context);
AnimatedOpacity(
  opacity: visible ? 1 : 0,
  duration: motion.fast, // fast 120 ms, normal 200 ms, slow 320 ms
  curve: motion.standard, // standard, emphasized, exit
  child: child,
)
```

Springs are `MotionSpring(duration:, bounce:)`: `snappy` for touch response and indicators, `smooth` for surfaces, `bouncy` for small delights. A spring keeps its velocity when interrupted, which a fixed curve cannot.

## What already moves

Nothing to do for these; they follow the theme's motion.

- Popovers, menus, the select list, tooltips and dialogs grow from their anchor and leave faster than they arrive.
- `Tabs`, `TabBar`, `NavigationBar`, `BottomNavigationBar`, toggle groups, menubar triggers and menu rows have one selection indicator that travels between items.
- Buttons, toggles, cards, list tiles and anything on `Pressable` scale slightly while pressed. `pressScale: 1` switches it off for one widget.
- `Switch`, `Checkbox`, `Radio`, `Accordion`, `ProgressBar`, `Slider`, toasts, sheets, badges and `Board` move on springs.

A component's own `effects:`, `duration` or theme override still wins over the tokens.

## Building blocks

All exported, for custom widgets that should move like the built-in ones.

| Widget | For |
| --- | --- |
| `SpringBuilder` | Animating a number to a new value on a spring; the spring counterpart of `TweenAnimationBuilder<double>` |
| `SpringController` | The same, driven by hand (`animateTo`, `shiftBy`, `jumpTo`) |
| `PressScale` | A paint-only scale while pressed. Pass `taps:` so a quick click, which is down and up within one frame, still pulses |
| `MovingIndicator` + `MovingIndicatorTarget` | One decoration that travels between the selected items of a list |
| `Entrance` | Showing and hiding something with a fade, a scale from an origin and a small travel |
| `PopIn`, `PopOnChange` | A small thing appearing, or acknowledging that its value changed |
| `ExpandReveal` | Height, fade and slide for content that opens |
| `ContentSwitch` | A directional fade and slide when the content changes |
| `AnimatedFill`, `AnimatedColorBuilder` | Fading between state colours |

```dart
// A custom segmented control whose selection glides.
MovingIndicator(
  child: Row(
    children: [
      for (final (i, label) in labels.indexed)
        MovingIndicatorTarget(
          selected: i == selectedIndex,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: theme.radii.md,
          ),
          child: Pressable(
            onPressed: () => onSelected(i),
            builder: (context, states) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(label),
            ),
          ),
        ),
    ],
  ),
)
```

## Things to know

- **Fade colours with `AnimatedFill`, not `AnimatedContainer`.** `Color.lerp` between colours of different opacity (a 4% wash and an opaque white) passes through a half-opaque grey that is darker than both ends, which reads as a flash.
- **A travelling selection cannot be the item's own fill.** Mark the item with `MovingIndicatorTarget` and let the list paint the one indicator. Keep no `RepaintBoundary` between the indicator and its targets.
- **Do not fade glass with `Opacity`.** A blurred surface under an opacity layer loses its backdrop on some renderers. The built-in overlays fade inside their filter; for your own, see `BackdropSurface`.
- **Nothing should animate forever while idle**, or `pumpAndSettle` never returns in tests.
- In tests, pump the fade (200 ms) or the spring (400 ms) before reading a colour or position right after a state change.
