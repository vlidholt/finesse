import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

// TODO(strand): built by the messages screen agent. This file is a stub; replace
// its body and keep the class name, which `strand_shell.dart` builds.

/// The Messages destination of the Strand shell.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PageContainer(
      scrollable: true,
      child: FinesseColumn(
        gap: GapSize.sm,
        // Stretch: a PageContainer centres a child narrower than the page.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Messages', style: theme.textTheme.h3),
          Text(
            'This screen has not been built yet.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
