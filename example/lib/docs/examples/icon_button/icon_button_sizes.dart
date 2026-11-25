import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class IconButtonSizesExample extends StatelessWidget {
  const IconButtonSizesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton.outline(
          size: ButtonSize.sm,
          tooltip: 'Add',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        IconButton.outline(
          tooltip: 'Add',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        IconButton.outline(
          size: ButtonSize.lg,
          tooltip: 'Add',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
        // Anything else is the style: a small, quiet close button.
        IconButton.ghost(
          style: ButtonTheme(
            width: 24,
            height: 24,
            iconSize: 14,
            foregroundColor: scheme.mutedForeground,
            hoverForegroundColor: scheme.foreground,
          ),
          tooltip: 'Close',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.x),
        ),
      ],
    );
  }
}
