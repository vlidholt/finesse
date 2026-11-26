import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A sparkline beside a number shows where it is heading. It sizes itself
/// in a row and takes any colour.
class ChartsSparklineExample extends StatelessWidget {
  const ChartsSparklineExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tiles = [
      const StatTile(
        value: Text('2,350'),
        label: Text('Visitors'),
        trailing: Sparkline(
          values: [12, 18, 15, 22, 19, 28, 31],
          semanticLabel: 'Visitors this week',
        ),
      ),
      StatTile(
        value: const Text('38%'),
        label: const Text('Bounce rate'),
        trailing: Sparkline(
          values: const [46, 44, 45, 41, 42, 39, 38],
          color: theme.colorScheme.success,
          semanticLabel: 'Bounce rate this week',
        ),
      ),
    ];
    final mobile = theme.formFactor == FormFactor.mobile;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: mobile
          ? UnaColumn(gap: GapSize.md, children: tiles)
          : UnaRow(
              gap: GapSize.md,
              children: [for (final tile in tiles) Expanded(child: tile)],
            ),
    );
  }
}
