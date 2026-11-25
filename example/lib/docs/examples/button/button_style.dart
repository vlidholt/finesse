import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonStyleExample extends StatelessWidget {
  const ButtonStyleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // New corners: the outline and the focus ring follow them.
        Button.outline(
          style: ButtonTheme(
            decoration: theme.buttonDecoration(radius: theme.radii.full),
          ),
          onPressed: () {},
          child: const Text('Follow'),
        ),
        // Colours for each state; the rest is still the primary button.
        Button(
          style: ButtonTheme(
            backgroundColor: scheme.success,
            hoverBackgroundColor: scheme.success.withValues(alpha: .85),
          ),
          onPressed: () {},
          leading: const PhosphorIcon(PhosphorIconsRegular.check),
          child: const Text('Approve'),
        ),
        // A fixed width, with the label at the start.
        Button.secondary(
          style: const ButtonTheme(
            width: 200,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          onPressed: () {},
          leading: const PhosphorIcon(PhosphorIconsRegular.folder),
          child: const Text('Documents'),
        ),
      ],
    );
  }
}
