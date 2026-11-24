# Tab Bar

A row of text tabs with a line under the selected one, for the sections of a page. `TabBar` only reports which tab is selected. Use `Tabs` instead for a segmented control: a filled strip with a raised selection that can also own and switch its content.

## Expanded

By default the tabs share the width equally. Show the matching section yourself from `selectedIndex`.

```dart
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
```

## Scrollable

With `expand: false` each tab hugs its label, and the row scrolls sideways when the tabs do not fit.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// With `expand: false` each tab is as wide as its label and the row scrolls
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

  int selected = 0;

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
          child: TabBar(
            expand: false,
            selectedIndex: selected,
            onSelected: (i) => setState(() => selected = i),
            tabs: [for (final name in _tabs) Text(name)],
          ),
        ),
      ),
    );
  }
}
```

