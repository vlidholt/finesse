import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A plan picker. `selected` adds `WidgetState.selected` and is announced to
/// assistive technology; a region with no `onPressed` reports
/// `WidgetState.disabled` and takes no focus.
class PressableChoiceExample extends StatefulWidget {
  const PressableChoiceExample({super.key});

  @override
  State<PressableChoiceExample> createState() => _PressableChoiceExampleState();
}

class _PressableChoiceExampleState extends State<PressableChoiceExample> {
  static const _plans = [
    ('Free', 'For trying it out', true),
    ('Team', 'Shared workspaces', true),
    ('Enterprise', 'Not available yet', false),
  ];

  int selected = 0;

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
          for (final (index, (name, caption, available)) in _plans.indexed)
            Pressable(
              selected: index == selected,
              onPressed: available
                  ? () => setState(() => selected = index)
                  : null,
              builder: (context, states) {
                final isSelected = states.contains(WidgetState.selected);
                final disabled = states.contains(WidgetState.disabled);
                return FocusRing(
                  visible: states.contains(WidgetState.focused),
                  borderRadius: radius,
                  child: Opacity(
                    opacity: disabled ? .5 : 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.accent
                            : states.contains(WidgetState.hovered)
                            ? scheme.muted
                            : scheme.card,
                        borderRadius: radius,
                        border: Border.all(
                          color: isSelected
                              ? scheme.accentBorder
                              : scheme.border,
                        ),
                      ),
                      child: Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: theme.textTheme.small),
                                Text(caption, style: theme.textTheme.muted),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected
                                ? PhosphorIconsFill.checkCircle
                                : PhosphorIconsRegular.circle,
                            size: 20,
                            color: isSelected
                                ? scheme.tint
                                : scheme.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
