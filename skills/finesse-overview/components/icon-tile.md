# Icon Tile

An `IconTile` is an icon on a soft, rounded square: the marker beside a statistic, a file type, a setting. A `StatTile` puts one on a card next to a headline number and its label.

## IconTile

The accent fill and tint colour are what make a tile read as part of the brand rather than as a control.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The default tile takes the theme's accent fill and tint colour. Size,
/// colours and radius can each be overridden.
class IconTileBasicExample extends StatelessWidget {
  const IconTileBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const IconTile(icon: PhosphorIcon(PhosphorIconsRegular.bookmarkSimple)),
        const IconTile(
          size: 32,
          iconSize: 18,
          icon: PhosphorIcon(PhosphorIconsRegular.fileText),
        ),
        const IconTile(
          size: 56,
          iconSize: 28,
          icon: PhosphorIcon(PhosphorIconsRegular.chartLineUp),
        ),
        IconTile(
          backgroundColor: scheme.successMuted,
          foregroundColor: scheme.success,
          icon: const PhosphorIcon(PhosphorIconsRegular.checkCircle),
        ),
        IconTile(
          backgroundColor: scheme.muted,
          foregroundColor: scheme.mutedForeground,
          borderRadius: theme.radii.full,
          icon: const PhosphorIcon(PhosphorIconsRegular.gear),
        ),
      ],
    );
  }
}
```

## StatTile

Wrap each tile in an `Expanded` for a summary strip. `trailing` holds a trend or a chevron, and `onTap` makes the tile focusable.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A summary strip of `StatTile`s: side by side where there is room, stacked
/// where there is not. One has a trailing trend and one is tappable.
class IconTileStatsExample extends StatelessWidget {
  const IconTileStatsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tiles = [
      const StatTile(
        icon: PhosphorIcon(PhosphorIconsRegular.bookmarkSimple),
        value: Text('6'),
        label: Text('Saved jobs'),
      ),
      StatTile(
        icon: const PhosphorIcon(PhosphorIconsRegular.eye),
        value: const Text('248'),
        label: const Text('Profile views'),
        trailing: Badge.secondary(
          backgroundColor: scheme.successMuted,
          foregroundColor: scheme.success,
          child: const Text('+12%'),
        ),
      ),
      StatTile(
        icon: const PhosphorIcon(PhosphorIconsRegular.paperPlaneTilt),
        value: const Text('3'),
        label: const Text('Applications'),
        trailing: const PhosphorIcon(PhosphorIconsRegular.caretRight, size: 16),
        onTap: () {},
      ),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return FinesseColumn(
              gap: GapSize.md,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: tiles,
            );
          }
          return FinesseRow(
            gap: GapSize.md,
            children: [for (final tile in tiles) Expanded(child: tile)],
          );
        },
      ),
    );
  }
}
```
