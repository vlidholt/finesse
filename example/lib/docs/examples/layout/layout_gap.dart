import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// `Gap` inserts space along the flex axis in spacing steps.
class LayoutGapExample extends StatelessWidget {
  const LayoutGapExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Account', style: theme.textTheme.h4),
            const Gap(1),
            Text(
              'Manage your profile and security settings.',
              style: theme.textTheme.muted,
            ),
            const Gap(4),
            Button.outline(
              onPressed: () {},
              child: const Text('Open settings'),
            ),
          ],
        ),
      ),
    );
  }
}
