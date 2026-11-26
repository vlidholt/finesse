import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// One selection shape for a whole row. Each item marks where the shape
/// belongs with a `MovingIndicatorTarget`; the `MovingIndicator` around the
/// row paints it once and slides it to whichever target is selected,
/// stretching a little on the way.
class MotionIndicatorExample extends StatefulWidget {
  const MotionIndicatorExample({super.key});

  @override
  State<MotionIndicatorExample> createState() => _MotionIndicatorExampleState();
}

class _MotionIndicatorExampleState extends State<MotionIndicatorExample> {
  static const labels = ['Day', 'Week', 'Month', 'Year'];
  int selected = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pill = BoxDecoration(
      color: scheme.primary,
      borderRadius: theme.radii.full,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.muted,
        borderRadius: theme.radii.full,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: MovingIndicator(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, label) in labels.indexed)
                MovingIndicatorTarget(
                  selected: index == selected,
                  decoration: pill,
                  child: Pressable(
                    selected: index == selected,
                    onPressed: () => setState(() => selected = index),
                    builder: (context, states) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      // The label's colour fades while the pill travels.
                      child: AnimatedColorBuilder(
                        color: index == selected
                            ? scheme.primaryForeground
                            : scheme.mutedForeground,
                        duration: Motion.of(context).normal,
                        builder: (context, color, child) => Text(
                          label,
                          style: theme.textTheme.small.copyWith(color: color),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
