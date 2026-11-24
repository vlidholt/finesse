import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Underline tabs sharing the width. `TabBar` only reports the selection;
/// showing the matching section is up to the caller.
class TabBarExpandedExample extends StatefulWidget {
  const TabBarExpandedExample({super.key});

  @override
  State<TabBarExpandedExample> createState() => _TabBarExpandedExampleState();
}

class _TabBarExpandedExampleState extends State<TabBarExpandedExample> {
  static const _sections = {
    'Posts': 'Twelve posts this month.',
    'About': 'Product designer in Copenhagen.',
    'Experience': 'Halcyon, Birchline and Lumen Labs.',
  };

  int section = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            selectedIndex: section,
            onSelected: (i) => setState(() => section = i),
            tabs: [for (final name in _sections.keys) Text(name)],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _sections.values.elementAt(section),
              textAlign: TextAlign.center,
              style: theme.textTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}
