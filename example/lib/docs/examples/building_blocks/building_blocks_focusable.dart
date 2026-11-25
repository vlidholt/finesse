import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// `Focusable` is a `Focus` that rebuilds when it gains or loses the focus.
/// Tab to a swatch, then use the arrow keys.
class BuildingBlocksFocusableExample extends StatefulWidget {
  const BuildingBlocksFocusableExample({super.key});

  @override
  State<BuildingBlocksFocusableExample> createState() =>
      _BuildingBlocksFocusableExampleState();
}

class _BuildingBlocksFocusableExampleState
    extends State<BuildingBlocksFocusableExample> {
  final _levels = [2, 4, 1];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget meter(int index) {
      return Focusable(
        // Up and Down change the level while this meter has the focus.
        onKeyEvent: (node, event) {
          if (event is KeyUpEvent) return KeyEventResult.ignored;
          final delta = switch (event.logicalKey) {
            LogicalKeyboardKey.arrowUp => 1,
            LogicalKeyboardKey.arrowDown => -1,
            _ => 0,
          };
          if (delta == 0) return KeyEventResult.ignored;
          setState(() {
            _levels[index] = (_levels[index] + delta).clamp(0, 5);
          });
          return KeyEventResult.handled;
        },
        builder: (context, focused, child) => FocusRing(
          visible: focused,
          borderRadius: theme.radii.lg,
          child: child!,
        ),
        // Built once: it does not depend on the focus.
        child: Semantics(
          label: 'Channel ${index + 1}',
          value: '${_levels[index]} of 5',
          child: Container(
            width: 56,
            padding: EdgeInsets.all(theme.layoutTheme.gap(GapSize.sm)),
            decoration: BoxDecoration(
              color: scheme.card,
              border: Border.all(color: scheme.border),
              borderRadius: theme.radii.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                for (var level = 5; level >= 1; level--)
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: level <= _levels[index]
                          ? scheme.primary
                          : scheme.muted,
                      borderRadius: theme.radii.sm,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.md),
      children: [for (var i = 0; i < _levels.length; i++) meter(i)],
    );
  }
}
