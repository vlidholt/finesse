# Styles

A style is a complete preset for geometry, typography, shadows,
translucency and motion. Four ship with una, switchable with one line.

Styles are not colour variations. Each is a full set of measurements:
control heights and padding, the radius of every kind of surface, the text
roles (title, label, body, caption, overline, field), the shadows, how
translucent cards, bars and overlays are, and the motion vocabulary.
Buttons, fields, menu rows, cards, sliders and switches move together when
the style changes. Colour is a separate choice; see
[theming.md](theming.md).

## Choosing a style

```dart
final theme = ThemeData(style: StyleTokens.maia);
```

- `una`: the default, measured from the package's own designs. Soft
  glass: 36-point buttons and 40-point fields, controls rounded to 10 and
  cards to 18; translucent cards, and glass bars, popovers, menus, tooltips
  and toasts. Lively motion. It has hand-measured phone metrics
  (`StyleTokens.unaMobile`).
- `nova`: compact and neutral. 32-point controls, moderate radii, opaque
  surfaces.
- `maia`: pill-shaped and roomy, with fully rounded controls.
- `lyra`: square and compact. No radii, flat shadows, 12-point body text.

`nova`, `maia` and `lyra` are three of shadcn/ui's styles, measured from
its CSS, with calm motion. There is no `vega`, `mira`, `luma`, `sera` or
`rhea`.

## Picking at runtime

```dart
final presets = StyleTokens.all; // the four, the default first
final lyra = StyleTokens.fromName('lyra'); // throws ArgumentError if unknown
```

## Custom styles

A style is data. Derive your own from the preset closest to what you want:

```dart
final theme = ThemeData(
  style: StyleTokens.nova.copyWith(
    buttonRadius: RadiusToken.full,
    buttonHeight: 40,
  ),
);
```

`copyWith` reaches the phone metrics too: the style's `mobile` set takes
each new value whose field it had in common with the desktop set, so
`StyleTokens.una.copyWith(glassBlur: 12)` changes the blur on both
form factors. A field the phone sets on purpose (control heights, page
margins, body text) keeps its phone value; to change that as well, pass
`mobile:` explicitly (see [form-factors.md](form-factors.md)).

## Glass and translucency

Translucency belongs to the style, not to the colour scheme. The scheme
holds the solid `card` and `bar` colours; the style holds `cardOpacity`,
`barOpacity`, `glassOpacity`, `popoverOpacity` and `tooltipOpacity` (each
with a `...Dark` override), `glassBlur`, `glassSaturation` and `cardBlur`.
A value below 1 is that colour at that opacity over the style's blur. An
opaque style such as `nova` pays for no blur at all.

```dart
// The default look with opaque surfaces everywhere.
final opaque = StyleTokens.una.copyWith(
  cardOpacity: 1,
  cardOpacityDark: 1,
  barOpacity: 1,
  barOpacityDark: 1,
  popoverOpacity: 1,
  popoverOpacityDark: 1,
  tooltipOpacity: 1,
  tooltipOpacityDark: 1,
);
final theme = ThemeData(style: opaque);
```

`cardBlur` is false in every preset: cards are translucent over the flat
page and blur nothing, because a backdrop filter per card costs every
frame. For a frosted panel of your own see [surfaces.md](surfaces.md).

## Spacing

Metrics a style writes in spacing units follow the theme's `Spacing` step,
4 by default. Raising it loosens every unit-derived padding and gap in one
move:

```dart
final roomy = ThemeData(spacing: const Spacing(step: 5));
```

## Motion and icons

The style also carries `motion` (`Motion.lively` for `una`,
`Motion.calm` for the others; see [motion.md](motion.md)) and the icons'
optical weight (`iconOpticalSize`, `iconOpticalStrength`; see
[icons.md](icons.md)).
