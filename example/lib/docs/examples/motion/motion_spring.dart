import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A value that follows its target on a spring. Tap the track while the dot
/// is still moving: it turns around from where it is, at the speed it has,
/// instead of starting again.
class MotionSpringExample extends StatefulWidget {
  const MotionSpringExample({super.key});

  @override
  State<MotionSpringExample> createState() => _MotionSpringExampleState();
}

class _MotionSpringExampleState extends State<MotionSpringExample> {
  bool end = false;
  bool bouncy = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = Motion.of(context);
    const track = 240.0;
    const dot = 28.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        Pressable(
          onPressed: () => setState(() => end = !end),
          semanticLabel: 'Move the dot',
          builder: (context, states) => DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.muted,
              borderRadius: theme.radii.full,
            ),
            child: SizedBox(
              width: track,
              height: dot + 8,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  // The builder runs every frame, so it only moves the dot:
                  // the dot itself is the child, built once.
                  child: SpringBuilder(
                    value: end ? 1 : 0,
                    spring: bouncy ? motion.bouncy : motion.smooth,
                    builder: (context, t, child) => Transform.translate(
                      offset: Offset(
                        (track - dot - 8) *
                            t *
                            (Directionality.of(context) == TextDirection.rtl
                                ? -1
                                : 1),
                        0,
                      ),
                      child: child,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(dimension: dot),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Switch(
          value: bouncy,
          onChanged: (value) => setState(() => bouncy = value),
          label: const Text('Bouncy'),
        ),
      ],
    );
  }
}
