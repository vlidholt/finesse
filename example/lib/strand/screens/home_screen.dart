import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

// TODO(strand): built by the home feed screen agent. This file is a stub; replace
// its body and keep the class name, which `strand_shell.dart` builds.

/// The Home destination of the Strand shell.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          Text('Home', style: theme.textTheme.h3),
          Text(
            'This screen has not been built yet.',
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
