# Icons

The Phosphor icon set ships inside the package: 1,512 icons in six weights,
exported from `package:una/una.dart`. There is no icon dependency to
add, nothing to declare in `pubspec.yaml`, and no `LucideIcons`.

## Using an icon

Each weight is a class of constants named after the icon:

| Class | Weight | Type |
| --- | --- | --- |
| `PhosphorIconsThin` | Thin | `IconData` |
| `PhosphorIconsLight` | Light | `IconData` |
| `PhosphorIconsRegular` | Regular, the one the components use | `IconData` |
| `PhosphorIconsBold` | Bold | `IconData` |
| `PhosphorIconsFill` | Filled, for selected states | `IconData` |
| `PhosphorIconsDuotone` | Outline over a translucent fill | `PhosphorDuotoneIconData` |

```dart
const PhosphorIcon(PhosphorIconsRegular.house)
```

Draw a regular icon with `PhosphorIcon`, not `Icon`: it is Flutter's `Icon` (a
subclass, same parameters) that keeps a small icon's line from thinning with its
size. See "Optical weight" below.

Names are the camelCase form of the names on
[phosphoricons.com](https://phosphoricons.com): `chat-circle-dots` is
`chatCircleDots`, `magnifying-glass` is `magnifyingGlass`. Common ones: `house`,
`magnifyingGlass`, `bell`, `chatCircleDots`, `usersThree`, `user`, `briefcase`,
`bookmarkSimple`, `heart`, `shareNetwork`, `paperPlaneTilt`, `gear`,
`calendarBlank`, `mapPin`, `image`, `paperclip`, `plus`, `check`, `x`,
`caretRight`, `caretDown`, `arrowLeft`, `dotsThree`, `trash`, `notePencil`,
`envelopeSimple`, `sun`, `moon`. If a name does not resolve, look it up rather
than guessing: Phosphor has no `search`, `settings`, `close`, `edit` or `mail`;
those are `magnifyingGlass`, `gear`, `x`, `pencilSimple` or `notePencil`, and
`envelopeSimple`.

The constants are `const IconData`, so Flutter's icon tree-shaking keeps only
the glyphs an app uses. Never construct an `IconData` at runtime (for instance
to switch an icon's family): a non-constant `IconData` fails a release build.

## Optical weight

The regular weight draws its line as a fixed share of the icon, a sixteenth of
its size: 1.5 px at 24 but 1 px at 16 and 0.75 px at 12, so small icons look
thin beside large ones. `PhosphorIcon` resolves its size as `Icon` does (its own
`size`, else the ambient `IconTheme`, scaled with text when `applyTextScaling`
is set) and, for a `PhosphorIconsRegular` icon smaller than 24, paints the
regular glyph with a fine outline of its own color around it. The outline
thickens every line by the same amount, continuously, from the one regular font.

| Size | Line as the font has it | Line as `PhosphorIcon` draws it (default) |
| --- | --- | --- |
| 12 | 0.75 px | 1.13 px |
| 14 | 0.88 px | 1.19 px |
| 16 | 1.00 px | 1.25 px |
| 18 | 1.13 px | 1.31 px |
| 20 | 1.25 px | 1.38 px |
| 24 and up | 1.50 px and up | unchanged |

Rules:

- Write `PhosphorIcon(PhosphorIconsRegular.x)` and leave the weight to the
  theme. Do not pick `PhosphorIconsBold` for a small icon by hand.
- Only `PhosphorIconsRegular` icons are thickened. `PhosphorIconsBold`, `Light`,
  `Thin` and `Fill` are an explicit choice and are drawn as given at every size;
  so is an `IconData` from another font, and any icon of 24 or more.
  `PhosphorIcon(selected ? PhosphorIconsFill.heart :
  PhosphorIconsRegular.heart)` is therefore fine.
- A plain `Icon(PhosphorIconsRegular.x)` still works and is always the font's
  own line; use it to pin one icon.
- The icon's box, baseline, semantics and hit area are an `Icon`'s. Half the
  outline (at most a fifth of a pixel by default) may be painted outside the box
  where a glyph touches its edge; do not wrap a bare icon in a clip exactly its
  size.

The two style tokens are `iconOpticalSize` (24: the size drawn as the font has
it) and `iconOpticalStrength` (0.5: how much of the difference a smaller icon
makes up; 1 holds the 1.5 px line all the way down, 0 switches it off). They
resolve into `ThemeData.phosphorIconTheme`:

```dart
// For the app, through the style.
final stronger = ThemeData(
  style: StyleTokens.fluid.copyWith(iconOpticalStrength: .8),
);

// Off for the app: every regular icon is the font's own.
final off = ThemeData(
  style: StyleTokens.fluid.copyWith(iconOpticalStrength: 0),
);

// Or the component theme directly.
final themed = ThemeData(
  phosphorIconTheme: const PhosphorIconTheme(strength: 0),
);

// The line an icon of a size is drawn with, in logical pixels.
final line = Theme.of(context).phosphorIconTheme.strokeAt(16); // 1.25
```

In tests a `PhosphorIcon` is an `Icon` whose `icon` is the constant it was
given, and there is no second `Icon` beneath it:
`find.byIcon(PhosphorIconsRegular.house)` and `find.widgetWithIcon` find it
once. `find.byType(Icon)` matches the exact type and does not; use
`find.byType(PhosphorIcon)` or `find.bySubtype<Icon>()`. A thickened icon has no
`RichText` beneath it. The package's own components draw their icons with
`PhosphorIcon` too.

## Regular and fill for selected states

The convention throughout una: the regular weight at rest, the fill weight
of the same icon when selected. It is what `NavigationDestination.selectedIcon`
is for.

```dart
import 'package:una/una.dart';
import 'package:flutter/widgets.dart';

/// Regular at rest, fill when selected: the same name in two classes, so a
/// toggle swaps the class and nothing else.
class IconsSelectedExample extends StatefulWidget {
  const IconsSelectedExample({super.key});

  @override
  State<IconsSelectedExample> createState() => _IconsSelectedExampleState();
}

class _IconsSelectedExampleState extends State<IconsSelectedExample> {
  bool liked = true;
  bool saved = false;
  bool following = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return UnaRow(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.sm,
      children: [
        IconButton.ghost(
          icon: PhosphorIcon(
            liked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
            color: liked ? scheme.destructive : null,
          ),
          semanticLabel: liked ? 'Unlike' : 'Like',
          onPressed: () => setState(() => liked = !liked),
        ),
        IconButton.ghost(
          icon: PhosphorIcon(
            saved
                ? PhosphorIconsFill.bookmarkSimple
                : PhosphorIconsRegular.bookmarkSimple,
            color: saved ? scheme.tint : null,
          ),
          semanticLabel: saved ? 'Remove from saved' : 'Save',
          onPressed: () => setState(() => saved = !saved),
        ),
        IconButton.ghost(
          icon: PhosphorIcon(
            following ? PhosphorIconsFill.bell : PhosphorIconsRegular.bell,
            color: following ? scheme.tint : null,
          ),
          semanticLabel: following ? 'Mute' : 'Notify me',
          onPressed: () => setState(() => following = !following),
        ),
      ],
    );
  }
}
```

## Duotone

A duotone icon is two glyphs, so `PhosphorIconsDuotone.x` is a
`PhosphorDuotoneIconData` and is drawn by `PhosphorDuotoneIcon`, not by `Icon`
or `PhosphorIcon`. Size and color default to the ambient `IconTheme`; the fill
layer is the same color at `secondaryOpacity` (0.2) unless `secondaryColor` is
given.

```dart
const bell = PhosphorDuotoneIcon(PhosphorIconsDuotone.bellRinging, size: 24);

final scheme = Theme.of(context).colorScheme;
final sun = PhosphorDuotoneIcon(
  PhosphorIconsDuotone.sun,
  color: scheme.foreground,
  secondaryColor: scheme.warning,
  secondaryOpacity: .6,
);
```

## Sizes come from the theme

A button hands its icon size down through an `IconTheme`. In the default style
that is 18 in a regular button, 16 in a small one and 20 in an icon button;
every style sets its own, and chips, navigation bars and icon tiles do the same.
Do not pass `size:` to an icon inside a component: leave it off and the icon is
right in every style and form factor, and a `PhosphorIcon` takes its line from
the same size. An explicit `size` still wins where one icon has to differ.

```dart
final newPost = Button(
  leading: const PhosphorIcon(PhosphorIconsRegular.plus), // no size
  onPressed: () {},
  child: const Text('New post'),
);

final bell = IconButton.ghost(
  icon: const PhosphorIcon(PhosphorIconsRegular.bell),
  semanticLabel: 'Notifications', // an icon-only control needs a label
  onPressed: () {},
);
```

Outside a component an icon takes the ambient `IconTheme`, 24 by default.
An icon set inline with a line of text (a pin before a place, a caret
after a label) is sized from that text, not from a constant, so it follows
the text role on every form factor and text scale:

```dart
final theme = Theme.of(context);
final style = theme.textTheme.muted;
final place = UnaRow(
  gap: GapSize.xs,
  mainAxisSize: MainAxisSize.min,
  children: [
    PhosphorIcon(
      PhosphorIconsRegular.mapPin,
      size: ((style.fontSize ?? 14) * 1.15).roundToDouble(),
      color: theme.colorScheme.mutedForeground,
    ),
    Text('Copenhagen', style: style),
  ],
);
```

A glyph that stands alone in a row of your own takes the size the theme's
buttons use, `theme.style.buttonIconSize` (or `iconButtonIconSize` for a
larger one).

## Direction

The constants do not mirror themselves in right-to-left layouts: flipping every
icon would also flip checkmarks and logos. Components that need a directional
chevron pick the right one themselves; in your own code choose between
`caretLeft` and `caretRight` from `Directionality.of(context)`.

## Other icon sets

Nothing ties a component to Phosphor. Every icon slot takes a widget, so an
`Icon` from any other font, an SVG or an image works in its place. A
`PhosphorIcon` given another font's `IconData` draws it unchanged.
