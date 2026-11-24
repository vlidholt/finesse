# Icons

The Phosphor icon set ships inside the package: 1,512 icons in six weights, exported from `package:finesse/finesse.dart`. There is no icon dependency to add, nothing to declare in `pubspec.yaml`, and no `LucideIcons`.

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
const Icon(PhosphorIconsRegular.house)
```

Names are the camelCase form of the names on [phosphoricons.com](https://phosphoricons.com): `chat-circle-dots` is `chatCircleDots`, `magnifying-glass` is `magnifyingGlass`. Common ones: `house`, `magnifyingGlass`, `bell`, `chatCircleDots`, `usersThree`, `user`, `briefcase`, `bookmarkSimple`, `heart`, `shareNetwork`, `paperPlaneTilt`, `gear`, `calendarBlank`, `mapPin`, `image`, `paperclip`, `plus`, `check`, `x`, `caretRight`, `caretDown`, `arrowLeft`, `dotsThree`, `trash`, `notePencil`, `envelopeSimple`, `sun`, `moon`. If a name does not resolve, look it up rather than guessing: Phosphor has no `search`, `settings`, `close`, `edit` or `mail`; those are `magnifyingGlass`, `gear`, `x`, `pencilSimple` or `notePencil`, and `envelopeSimple`.

The constants are `const IconData`, so Flutter's icon tree-shaking keeps only the glyphs an app uses.

## Regular and fill for selected states

The convention throughout finesse: the regular weight at rest, the fill weight of the same icon when selected. It is what `NavigationDestination.selectedIcon` is for.

```dart
import 'package:finesse/finesse.dart';
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        IconButton.ghost(
          icon: Icon(
            liked ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
            color: liked ? scheme.destructive : null,
          ),
          semanticLabel: liked ? 'Unlike' : 'Like',
          onPressed: () => setState(() => liked = !liked),
        ),
        IconButton.ghost(
          icon: Icon(
            saved
                ? PhosphorIconsFill.bookmarkSimple
                : PhosphorIconsRegular.bookmarkSimple,
            color: saved ? scheme.tint : null,
          ),
          semanticLabel: saved ? 'Remove from saved' : 'Save',
          onPressed: () => setState(() => saved = !saved),
        ),
        IconButton.ghost(
          icon: Icon(
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

A duotone icon is two glyphs, so `PhosphorIconsDuotone.x` is a `PhosphorDuotoneIconData` and is drawn by `PhosphorDuotoneIcon`, not by `Icon`. Size and color default to the ambient `IconTheme`; the fill layer is the same color at `secondaryOpacity` (0.2) unless `secondaryColor` is given.

```dart
const PhosphorDuotoneIcon(PhosphorIconsDuotone.bellRinging, size: 24)

PhosphorDuotoneIcon(
  PhosphorIconsDuotone.sun,
  color: scheme.foreground,
  secondaryColor: scheme.warning,
  secondaryOpacity: .6,
)
```

## Sizes come from the theme

A button hands its icon size down through an `IconTheme`. In the default style that is 18 in a regular button, 16 in a small one and 20 in an icon button; every style sets its own, and chips, navigation bars and icon tiles do the same. Do not pass `size:` to an icon inside a component: leave it off and the icon is right in every style and form factor. An explicit `size` still wins where one icon has to differ.

```dart
Button(
  leading: const Icon(PhosphorIconsRegular.plus), // no size
  onPressed: () {},
  child: const Text('New post'),
)

IconButton.ghost(
  icon: const Icon(PhosphorIconsRegular.bell),
  semanticLabel: 'Notifications', // an icon-only control needs a label
  onPressed: () {},
)
```

Outside a component an icon takes the ambient `IconTheme`, 24 by default.

## Direction

The constants do not mirror themselves in right-to-left layouts: flipping every icon would also flip checkmarks and logos. Components that need a directional chevron pick the right one themselves; in your own code choose between `caretLeft` and `caretRight` from `Directionality.of(context)`.

## Other icon sets

Nothing ties a component to Phosphor. Every icon slot takes a widget, so an `Icon` from any other font, an SVG or an image works in its place.
