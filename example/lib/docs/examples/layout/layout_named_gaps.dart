import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A card laid out entirely with named gaps: `lg` between its sections,
/// `sm` between related controls, `xs` between an icon and its label.
class LayoutNamedGapsExample extends StatelessWidget {
  const LayoutNamedGapsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Card(
        child: UnaColumn(
          gap: GapSize.lg,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Senior product designer', style: theme.textTheme.large),
                // One odd gap in a plain Column: reach for `Gap`.
                const Gap.xs(),
                UnaRow(
                  gap: GapSize.xs,
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.mapPin,
                      size: 16,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    Text('Copenhagen', style: theme.textTheme.muted),
                  ],
                ),
              ],
            ),
            const Divider(margin: EdgeInsets.zero),
            UnaRow(
              gap: GapSize.sm,
              children: [
                Expanded(
                  child: Button(onPressed: () {}, child: const Text('Apply')),
                ),
                Button.outline(onPressed: () {}, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
