import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The three outlines. With no callback a chip is a static tag, not a
/// control, and is not announced as a button.
class ChipVariantsExample extends StatelessWidget {
  const ChipVariantsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String name, List<Widget> chips) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(name, style: theme.textTheme.muted),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          row('Outline', const [
            Chip(label: Text('Copenhagen')),
            Chip(
              label: Text('Hybrid'),
              leading: PhosphorIcon(PhosphorIconsRegular.buildings),
            ),
          ]),
          // Soft: read-only tags, such as a person's skills.
          row('Soft', const [
            Chip(label: Text('Design systems'), variant: ChipVariant.soft),
            Chip(label: Text('Prototyping'), variant: ChipVariant.soft),
            Chip(label: Text('Research'), variant: ChipVariant.soft),
          ]),
          // Dashed: something absent or suggested.
          row('Dashed', [
            Chip(
              label: const Text('Add a skill'),
              leading: const PhosphorIcon(PhosphorIconsRegular.plus),
              variant: ChipVariant.dashed,
              onPressed: () {},
            ),
            const Chip(
              label: Text('Accessibility'),
              variant: ChipVariant.dashed,
            ),
          ]),
        ],
      ),
    );
  }
}
