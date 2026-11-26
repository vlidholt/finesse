# Surfaces: Card, Surface, Glass

Three widgets draw a rounded panel. They differ in *where the panel sits*,
not in how translucent it is: the style decides the translucency of all
three (see [styles.md](styles.md)). Never hand-build a panel out of a
`Container` with a colour, a border and a shadow.

| Widget | What it is | Use it for |
| --- | --- | --- |
| `Card` | Content on the page, with a title, description, body and footer and the theme's padding. Translucent in the default style but never blurred, so a page of them costs nothing per frame. | A post, a settings group, a stat, a form: anything that scrolls with the page. |
| `Surface` | The skin of something that floats: the popover's or the menu's colours, hairline, shadow and glass, exactly as `Popover` and the menus paint them. | An overlay you place yourself: a search panel under a field, a custom menu, a hover preview. `Popover` already wraps its content in one. |
| `Glass` | The raw material: a tint over the blurred, saturated backdrop, with a hairline. No padding rules, no text style. | Floating chrome over moving content: a toolbar, a pill, a label on a photo. |

## Card

```dart
Card(
  title: const Text('Notifications'),
  description: const Text('Choose what you hear about.'),
  action: IconButton.ghost(
    icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
    semanticLabel: 'More',
    onPressed: () {},
  ),
  footer: Button(onPressed: () {}, child: const Text('Save')),
  child: const Text('Email, push and in-app settings.'),
)
```

- `title` takes the card title style and `description` the muted style;
  `child` is the body, `footer` the actions, `action` a button pinned to
  the end of the header row. `leading` / `trailing` sit beside the whole
  content column.
- `onTap` makes the whole card a button (focusable, with a focus ring and a
  press response); `selected: true` gives it the accent fill, for the open
  item of a list.
- Padding, radius, border and shadow come from `CardTheme`; leave them
  alone unless the design says otherwise.
- Cards do not blur what is behind them in any built-in style. A theme opts
  in with `StyleTokens.una.copyWith(cardBlur: true)` or
  `CardTheme(blur: ...)`, and pays a backdrop filter per card per frame.

## Surface

```dart
Surface(
  kind: SurfaceKind.popover, // or SurfaceKind.menu
  child: const Text('Anything that floats'),
)
```

Place it with `showPopover` or a `Popover` (see [overlays.md](overlays.md));
`arrow:` takes a `SurfaceArrow` for a pointer towards the anchor.

## Glass

```dart
Glass(
  level: GlassLevel.strong, // GlassLevel.regular shows more backdrop
  borderRadius: Theme.of(context).radii.full,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: const Text('Now playing'),
)
```

- `GlassLevel.strong` for a surface that carries text, `regular` for one
  that mostly shows what is behind it. `color` replaces the tint (a dark
  scrim keeps white labels readable over a photo in both brightnesses).
- **Each frosted `Glass` is a backdrop filter**, a compositing layer
  repainted whenever what is behind it moves. A handful on screen is fine;
  one per row of a list is not. Inside scrolling content, or over a flat
  fill, pass `frosted: false`: the tint and hairline stay, the blur goes.
- A label over a photograph is a plain scrim (`Glass(frosted: false,
  color: ...)` or a gradient), not frosted glass: a blur samples the page
  around the photo as well and turns grey.

## Building your own

- **Shadows.** An outward shadow on a translucent surface must not show
  through it. Use `ShadowDecoration.box(shadows:, color:, borderRadius:,
  border:)`, which takes `BoxDecoration`'s arguments and paints the shadow
  outside the shape only. Never put an outer shadow in a
  `BoxDecoration.boxShadow` here: it washes the fill grey.
- **Blur.** `Backdrop(blur:, saturation:, borderRadius:, child:)` is the
  blur alone, with a tint of your own on top. It does nothing (and costs
  nothing) when `blur` is 0 and `saturation` is 1.
- **Fading glass.** A backdrop filter under an `Opacity` loses its backdrop
  on some renderers (on the web always). Do not wrap glass in `Opacity`,
  `FadeTransition` or `AnimatedOpacity`; the built-in overlays fade inside
  their filter (`BackdropSurface`).
- Colours of an on-surface glyph or label: `scheme.tint` for a brand-
  coloured icon or text drawn straight on a card, never
  `accentForeground` (that is the ink *on an accent fill*).

See also: [card.md](../components/card.md),
[surface.md](../components/surface.md), [glass.md](../components/glass.md),
[building-blocks.md](building-blocks.md).
