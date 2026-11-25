# Pressable

The behaviour underneath everything that is pressed — `Button`, `IconButton`, `Toggle`, `Chip`, `ListTile`, the navigation bars — for building a control of your own. A `Pressable` handles pointer and keyboard activation, the press response, the cursor and button semantics, and hands its interaction states to a builder. It paints nothing itself. `FocusRing` draws the focus ring of the theme around whatever the builder returns, and `AnimatedFill` fades its fill between states.

## Interaction states

The builder receives a set of `WidgetState`s: `hovered`, `pressed`, `focused`, `selected` and `disabled`. Activate the focused region with Enter or Space.

```dart
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
          // `AnimatedFill` cross-fades its colours. An `AnimatedContainer`
          // would lerp them channel by channel, and between an opaque fill
          // and a translucent wash that dips through a dark grey.
          child: SizedBox(
            width: 260,
            child: AnimatedFill(
              color: pressed
                  ? scheme.accent
                  : hovered
                  ? scheme.muted
                  : scheme.card,
              borderColor: hovered || pressed
                  ? scheme.borderStrong
                  : scheme.border,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.all(16),
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
            ),
          ),
        );
      },
    );
  }
}
```

## Selected and disabled

Pass `selected` for one of a set. With no `onPressed` the region is disabled: no focus, the basic cursor, and `WidgetState.disabled` in the set; `enabled` says otherwise in either direction — true keeps a region with nothing to do in the focus order, as a button that is busy.

```dart
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
                    child: AnimatedFill(
                      color: isSelected
                          ? scheme.accent
                          : states.contains(WidgetState.hovered)
                          ? scheme.muted
                          : scheme.card,
                      borderColor: isSelected
                          ? scheme.accentBorder
                          : scheme.border,
                      borderRadius: radius,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
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
                            PhosphorIcon(
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
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
```

## Toggled, and states shared

Pass `toggled` for a region that stays on: it adds `WidgetState.selected` and is announced as on or off. A `statesController` shares the states with whatever else follows them — here the hint below, which shows while the region is hovered or focused. `onHover` and `onFocusChange` report the two as callbacks, and `semanticContainer` makes the region a semantics node of its own, as a button is.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
```
