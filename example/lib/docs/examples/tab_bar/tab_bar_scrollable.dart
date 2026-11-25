import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// With `expandTabs: false` each tab is as wide as its label and the row scrolls
/// when there are more tabs than room.
class TabBarScrollableExample extends StatefulWidget {
  const TabBarScrollableExample({super.key});

  @override
  State<TabBarScrollableExample> createState() =>
      _TabBarScrollableExampleState();
}

class _TabBarScrollableExampleState extends State<TabBarScrollableExample> {
  static const _tabs = [
    'All',
    'Mentions',
    'Reactions',
    'Comments',
    'Invitations',
    'Job alerts',
    'Events',
  ];

  String selected = _tabs.first;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      // The bar does not clip its own scroller, so tabs that have scrolled
      // out would paint beside it. The pixel of padding keeps the selection
      // line, which overhangs the hairline, inside the clip.
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: TabBar<String>(
            expandTabs: false,
            value: selected,
            onChanged: (value) => setState(() => selected = value),
            tabs: [
              for (final name in _tabs) Tab(value: name, child: Text(name)),
            ],
          ),
        ),
      ),
    );
  }
}
