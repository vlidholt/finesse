import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A control built from scratch. `Pressable` supplies the behaviour and the
/// set of states; the builder decides what each one looks like. Hover it,
/// press it, or reach it with Tab to see the set change.
class PressableStatesExample extends StatefulWidget {
  const PressableStatesExample({super.key});

  @override
  State<PressableStatesExample> createState() => _PressableStatesExampleState();
}

class _PressableStatesExampleState extends State<PressableStatesExample> {
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = theme.radii.xl;

    return Pressable(
      onPressed: () => setState(() => taps++),
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final pressed = states.contains(WidgetState.pressed);
        return FocusRing(
          visible: states.contains(WidgetState.focused),
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pressed
                  ? scheme.accent
                  : hovered
                  ? scheme.muted
                  : scheme.card,
              borderRadius: radius,
              border: Border.all(
                color: hovered || pressed ? scheme.borderStrong : scheme.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text('Tapped $taps times', style: theme.textTheme.large),
                Text(
                  states.isEmpty
                      ? 'idle'
                      : states.map((state) => state.name).join(', '),
                  style: theme.textTheme.muted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
