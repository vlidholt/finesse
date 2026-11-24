# Indicator Badge

A small count or dot pinned to the corner of another widget: unread messages on an icon, presence on an avatar. For a label that stands in the flow of text, use `Badge`.

## Counts on icons

With a `count` the badge is a pill, and above `maxCount` it reads `99+`. With no count it is a dot. A ring in the colour of the surface behind keeps it legible over its child.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Counts on icons. Above `maxCount` the badge reads `99+`; with no count at
/// all it is a dot.
class IndicatorBadgeCountExample extends StatelessWidget {
  const IndicatorBadgeCountExample({super.key});

  @override
  Widget build(BuildContext context) {
    // The ring is what separates the badge from the icon under it. It
    // defaults to the card colour; these icons sit on the page instead.
    final ring = Theme.of(context).colorScheme.background;

    return IconTheme.merge(
      data: const IconThemeData(size: 28),
      child: Wrap(
        spacing: 36,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: [
          IndicatorBadge(
            count: 3,
            ringColor: ring,
            semanticLabel: '3 unread messages',
            child: const Icon(PhosphorIconsRegular.chatCircleDots),
          ),
          IndicatorBadge(
            count: 128,
            ringColor: ring,
            child: const Icon(PhosphorIconsRegular.bell),
          ),
          IndicatorBadge(
            count: 12,
            maxCount: 9,
            ringColor: ring,
            child: const Icon(PhosphorIconsRegular.envelopeSimple),
          ),
          IndicatorBadge(
            ringColor: ring,
            child: const Icon(PhosphorIconsRegular.usersThree),
          ),
          // A count of zero hides the badge unless `showZero` is set.
          IndicatorBadge(
            count: 0,
            ringColor: ring,
            child: const Icon(PhosphorIconsRegular.briefcase),
          ),
        ],
      ),
    );
  }
}
```

## A dot on an avatar

`alignment` picks the corner. `overhang` is how far the badge hangs outside it, as a fraction of its own size: the default suits a count on an icon, and 0 keeps a presence dot on the edge of a round avatar.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Presence dots on avatars. `alignment` picks the corner; an `overhang` of
/// zero keeps the dot inside the avatar's bounds, on the edge of the circle.
class IndicatorBadgePresenceExample extends StatelessWidget {
  const IndicatorBadgePresenceExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget person(String photo, String initial, {required Color color}) {
      return IndicatorBadge(
        alignment: AlignmentDirectional.bottomEnd,
        overhang: 0,
        size: 12,
        color: color,
        ringColor: scheme.background,
        child: Avatar(
          photo,
          size: const Size.square(48),
          fallback: Text(initial),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        person(
          'assets/strand/avatar_mei_tanaka.jpg',
          'M',
          color: scheme.success,
        ),
        person(
          'assets/strand/avatar_julian_reyes.jpg',
          'J',
          color: scheme.warning,
        ),
        person(
          'assets/strand/avatar_freya_holm.jpg',
          'F',
          color: scheme.mutedForeground,
        ),
      ],
    );
  }
}
```

## Standalone

Leave `child` out to lay the badge out on its own. `label` shows any widget in place of the number.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Without a child the badge is laid out on its own: an unread count at the
/// end of a row, or a short label in place of a number.
class IndicatorBadgeStandaloneExample extends StatelessWidget {
  const IndicatorBadgeStandaloneExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Card(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(PhosphorIconsRegular.tray),
              title: const Text('Inbox'),
              trailing: const IndicatorBadge(count: 24),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.userPlus),
              title: const Text('Invitations'),
              trailing: IndicatorBadge(
                count: 2,
                color: scheme.tint,
                foregroundColor: scheme.tintForeground,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(PhosphorIconsRegular.calendarBlank),
              title: const Text('Events'),
              trailing: IndicatorBadge(
                label: const Text('New'),
                color: scheme.success,
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

