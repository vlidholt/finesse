import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A control of your own that answers a press the way a button does. A
/// `Pressable` does that by itself: its content shrinks a little in paint
/// only, so nothing around it moves, and a click that was over within a
/// frame still gives a pulse. `pressScale` sets how far (1 for not at all);
/// `PressScale` is the same response for a control built on something else.
class MotionPressExample extends StatefulWidget {
  const MotionPressExample({super.key});

  @override
  State<MotionPressExample> createState() => _MotionPressExampleState();
}

class _MotionPressExampleState extends State<MotionPressExample> {
  int likes = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Pressable(
      onPressed: () => setState(() => likes++),
      semanticLabel: 'Like',
      semanticValue: '$likes',
      builder: (context, states) => FocusRing(
        visible: states.contains(WidgetState.focused),
        borderRadius: theme.radii.full,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.card,
            borderRadius: theme.radii.full,
            border: Border.all(color: scheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                PhosphorIcon(
                  PhosphorIconsFill.heart,
                  size: 18,
                  color: scheme.destructive,
                ),
                // The number pops once each time it changes.
                PopOnChange(
                  value: likes,
                  child: Text('$likes', style: theme.textTheme.small),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
