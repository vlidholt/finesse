import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// The popover and menu surfaces, around any widget: for floating UI that
/// finesse has no component for.
class SurfaceBasicExample extends StatelessWidget {
  const SurfaceBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        Surface(
          child: SizedBox(
            width: 200,
            child: Text(
              'A popover surface: the outline, radius, padding and shadow '
              'of Popover.',
              style: theme.textTheme.small,
            ),
          ),
        ),
        Surface(
          kind: SurfaceKind.menu,
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final label in ['Cut', 'Copy', 'Paste'])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(label, style: theme.textTheme.small),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
