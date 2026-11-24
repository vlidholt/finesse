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
        icon: Icon(PhosphorIconsRegular.bookmarkSimple),
        value: Text('6'),
        label: Text('Saved jobs'),
      ),
      StatTile(
        icon: const Icon(PhosphorIconsRegular.eye),
        value: const Text('248'),
        label: const Text('Profile views'),
        trailing: Badge.secondary(
          backgroundColor: scheme.successMuted,
          foregroundColor: scheme.success,
          child: const Text('+12%'),
        ),
      ),
      StatTile(
        icon: const Icon(PhosphorIconsRegular.paperPlaneTilt),
        value: const Text('3'),
        label: const Text('Applications'),
        trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
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
