# Styles

A style is a complete preset for geometry, typography, shadows and translucency. Four ship with finesse, switchable with one line.

Styles are not color variations. Each one is a full set of measurements: control heights and padding, the radius of every kind of surface, the type roles (title, label, body, caption, field), the shadows, and how translucent cards and bars are. Buttons, fields, menu rows, cards, sliders and switches all move together when the style changes. Color is a separate choice; see [theming.md](theming.md).

## Choosing a style

```dart
ThemeData(
  style: StyleTokens.maia,
)
```

- `finesse`: the default. Soft glass: 36px buttons and 40px fields, controls rounded to 10 and cards to 18, with cards, bars and outline buttons translucent over a blurred backdrop. It has hand-measured phone metrics (`StyleTokens.finesseMobile`).
- `nova`: compact and neutral. 32px controls, moderate radii, opaque surfaces.
- `maia`: pill-shaped and roomy, with fully rounded controls.
- `lyra`: square and compact. No radii, flat shadows, 12px body text.

`nova`, `maia` and `lyra` are three of shadcn/ui's styles, measured from its CSS. `finesse` is the package's own. The other shadcn styles (`vega`, `mira`, `luma`, `sera`, `rhea`) are not part of this package.

## Picking at runtime

The presets are values on `StyleTokens`, so a style switcher is a list and a lookup:

```dart
StyleTokens.all;              // the four presets, the default first
StyleTokens.fromName('lyra'); // one, by name; throws ArgumentError if unknown
```

## Custom styles

A style is data, a set of measured tokens. Derive your own from the preset closest to what you want:

```dart
ThemeData(
  style: StyleTokens.nova.copyWith(
    buttonRadius: RadiusToken.full,
    buttonHeight: 40,
  ),
)
```

`copyWith` changes the set of metrics it is called on. `nova`, `maia` and `lyra` derive their phone metrics from the result, so one call covers both form factors. `finesse` has a separate `finesseMobile`: to change it on a phone too, copy that as well and pass it as `mobile`.

## Desktop and phone

Every style carries a second set of metrics for a phone: larger touch targets, larger body text, tighter page margins. `finesse` defines its own; the others derive theirs. `FinesseApp` picks between the two from the window width. See [form-factors.md](form-factors.md).

## Glass

Translucency belongs to the style, not to the color scheme. The scheme holds the solid `card` and `bar` colors; the style holds `cardOpacity`, `barOpacity`, `glassOpacity` (each with a `...Dark` override), `cardBlur`, `glassBlur` and `glassSaturation`. An opaque style such as `nova` pays for no blur at all. To turn the default style opaque, change both of its sets of metrics:

```dart
StyleTokens opaque(StyleTokens style) => style.copyWith(
  cardOpacity: 1,
  cardOpacityDark: 1,
  cardBlur: false,
  barOpacity: 1,
  barOpacityDark: 1,
);

ThemeData(
  style: opaque(StyleTokens.finesse).copyWith(
    mobile: opaque(StyleTokens.finesseMobile),
  ),
)
```

For a frosted surface of your own, use the `Glass` widget ([glass.md](../components/glass.md)). Each one is a compositing layer: a handful on screen is fine, a long scrolling list of them is not.

## Spacing

Metrics a style writes in spacing units follow the theme's `Spacing` step, 4px by default. Raising it loosens every unit-derived padding and gap in one move:

```dart
ThemeData(
  spacing: const Spacing(step: 5),
)
```
