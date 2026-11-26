import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A setting that stays on. `toggled` adds `WidgetState.selected` and is
/// announced as on or off; a `statesController` lets the hint below the
/// region follow its hover and focus without being part of it.
class PressableToggleExample extends StatefulWidget {
  const PressableToggleExample({super.key});

  @override
  State<PressableToggleExample> createState() => _PressableToggleExampleState();
}

class _PressableToggleExampleState extends State<PressableToggleExample> {
  final _states = WidgetStatesController();
  bool quiet = false;

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = theme.radii.lg;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Pressable(
            toggled: quiet,
            statesController: _states,
            onPressed: () => setState(() => quiet = !quiet),
            builder: (context, states) {
              final on = states.contains(WidgetState.selected);
              return FocusRing(
                visible: states.contains(WidgetState.focused),
                borderRadius: radius,
                child: AnimatedFill(
                  color: on
                      ? scheme.accent
                      : states.contains(WidgetState.hovered)
                      ? scheme.muted
                      : scheme.card,
                  borderColor: on ? scheme.accentBorder : scheme.border,
                  borderRadius: radius,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      spacing: 12,
                      children: [
                        PhosphorIcon(
                          on
                              ? PhosphorIconsFill.moon
                              : PhosphorIconsRegular.moon,
                          size: 20,
                          color: on ? scheme.tint : scheme.mutedForeground,
                        ),
                        Expanded(
                          child: Text(
                            'Do not disturb',
                            style: theme.textTheme.small,
                          ),
                        ),
                        Text(
                          on ? 'On' : 'Off',
                          style: theme.textTheme.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Outside the region, following it through the controller.
          ValueListenableBuilder(
            valueListenable: _states,
            builder: (context, states, _) {
              final engaged =
                  states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused);
              return AnimatedOpacity(
                opacity: engaged ? 1 : 0,
                duration: Motion.of(context).fast,
                child: Text(
                  quiet
                      ? 'Notifications will sound again.'
                      : 'Notifications will wait until you turn this off.',
                  style: theme.textTheme.caption,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
