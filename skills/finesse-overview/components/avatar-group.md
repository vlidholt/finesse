# Avatar Group

A row of overlapping avatars, each ringed in the colour of the surface behind it: the people who reacted, the mutual connections.

## Default

The first child is painted on top. The ring defaults to the card colour.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Mutual connections: the first avatar is painted on top and each one is
/// ringed in the colour of the surface behind it.
class AvatarGroupBasicExample extends StatelessWidget {
  const AvatarGroupBasicExample({super.key});

  static const _photos = [
    'assets/strand/avatar_mei_tanaka.jpg',
    'assets/strand/avatar_omar_rahimi.jpg',
    'assets/strand/avatar_claire_dubois.jpg',
    'assets/strand/avatar_julian_reyes.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          AvatarGroup(
            size: 28,
            children: [for (final photo in _photos) Avatar(photo)],
          ),
          Flexible(
            child: Text(
              'Mei, Omar and 12 other mutual connections',
              style: theme.textTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Sizes, overlap and other children

Every child is forced to `size` and clipped to a circle. Pass `ringColor` when the group does not sit on a card.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Every child is forced to `size` and clipped to a circle, so anything
/// works: initials, reaction icons, a "+5" for the rest. `overlap` sets how
/// far each one slides under the one before it.
class AvatarGroupMixedExample extends StatelessWidget {
  const AvatarGroupMixedExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget reaction(IconData icon, Color color) {
      return Container(
        width: 40,
        height: 40,
        color: color,
        alignment: Alignment.center,
        child: PhosphorIcon(icon, size: 24, color: const Color(0xFFFFFFFF)),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        AvatarGroup(
          size: 22,
          // On the page rather than on a card.
          ringColor: scheme.background,
          children: [
            reaction(PhosphorIconsFill.thumbsUp, scheme.tint),
            reaction(PhosphorIconsFill.heart, scheme.destructive),
            reaction(PhosphorIconsFill.lightbulb, scheme.warning),
          ],
        ),
        AvatarGroup(
          size: 40,
          overlap: 8,
          ringColor: scheme.background,
          children: [
            const Avatar('', fallback: Text('NH')),
            const Avatar('', fallback: Text('OR')),
            const Avatar('', fallback: Text('MT')),
            Container(
              width: 40,
              height: 40,
              color: scheme.muted,
              alignment: Alignment.center,
              child: Text('+5', style: theme.textTheme.small),
            ),
          ],
        ),
      ],
    );
  }
}
```

