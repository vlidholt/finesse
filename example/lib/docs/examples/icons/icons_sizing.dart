import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Inside a button the icon size is a theme token, so call sites pass none.
/// An explicit `size` still wins, and outside a component the IconTheme
/// decides.
class IconsSizingExample extends StatelessWidget {
  const IconsSizingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Button(
          size: ButtonSize.sm,
          leading: const Icon(PhosphorIconsRegular.plus),
          onPressed: () {},
          child: const Text('Small'),
        ),
        Button(
          leading: const Icon(PhosphorIconsRegular.plus),
          onPressed: () {},
          child: const Text('Regular'),
        ),
        Button(
          size: ButtonSize.lg,
          leading: const Icon(PhosphorIconsRegular.plus),
          onPressed: () {},
          child: const Text('Large'),
        ),
        IconButton.outline(
          icon: const Icon(PhosphorIconsRegular.gear),
          semanticLabel: 'Settings',
          onPressed: () {},
        ),
        // Opting out of the token for one icon.
        Button.outline(
          leading: const Icon(PhosphorIconsRegular.sparkle, size: 22),
          onPressed: () {},
          child: const Text('Explicit size'),
        ),
      ],
    );
  }
}
