import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Stacked primary and secondary actions with `FinesseColumn` spacing.
/// the footer pattern used in dialogs and forms.
class LayoutFormActionsExample extends StatelessWidget {
  const LayoutFormActionsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        title: const Text('Schedule payout'),
        description: const Text('Confirm the transfer details below.'),
        child: FinesseColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 3,
          children: [
            const TextField(
              placeholder: Text('Amount'),
            ),
            Button(onPressed: () {}, child: const Text('Schedule')),
            Button.outline(
              onPressed: () {},
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
