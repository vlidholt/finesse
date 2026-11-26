import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `Haptics` is where every control asks for its tick. On a phone these
/// buttons can be felt; on a desktop and on the web they do nothing.
class BuildingBlocksHapticsExample extends StatefulWidget {
  const BuildingBlocksHapticsExample({super.key});

  @override
  State<BuildingBlocksHapticsExample> createState() =>
      _BuildingBlocksHapticsExampleState();
}

class _BuildingBlocksHapticsExampleState
    extends State<BuildingBlocksHapticsExample> {
  bool _enabled = true;

  // A theme for the subtree, made once per ambient theme: `copyWith`
  // derives every component theme again, so it does not belong in `build`.
  static final _quiet = Expando<ThemeData>();

  @override
  Widget build(BuildContext context) {
    final ambient = Theme.of(context);
    final theme = _enabled
        ? ambient
        : _quiet[ambient] ??= ambient.copyWith(haptics: false);

    return UnaColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.lg,
      children: [
        Switch(
          value: _enabled,
          onChanged: (value) => setState(() => _enabled = value),
          label: const Text('Haptics in this group'),
        ),
        // `ThemeData(haptics: false)` on the app switches them off
        // everywhere; on a `Theme`, for what is under it.
        Theme(
          data: theme,
          child: Builder(
            builder: (context) => Wrap(
              spacing: ambient.layoutTheme.gap(GapSize.sm),
              runSpacing: ambient.layoutTheme.gap(GapSize.sm),
              alignment: WrapAlignment.center,
              children: [
                Button.outline(
                  // A value changing under the finger.
                  onPressed: () => Haptics.selection(context),
                  child: const Text('Selection'),
                ),
                Button.outline(
                  // Something put down, a switch thrown.
                  onPressed: () => Haptics.impact(context),
                  child: const Text('Light'),
                ),
                Button.outline(
                  // Something picked up, a gesture that armed.
                  onPressed: () => Haptics.impact(context, HapticImpact.medium),
                  child: const Text('Medium'),
                ),
                Button.outline(
                  onPressed: () => Haptics.impact(context, HapticImpact.heavy),
                  child: const Text('Heavy'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
