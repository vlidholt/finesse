# Tab Bar

The list of tabs, in two looks: text tabs with a line under the selected one, and a filled strip with a raised pill. `TabBar` reports which tab was chosen through `value` and `onChanged`; a `TabBarView` shows the matching page, and `Tabs` is the two put together. To pick a value rather than show a view, use a `SegmentedControl`.

## Underline

The default look, for the sections of a page. The tabs share the width equally, and each `Tab` has the `value` the bar reports when it is chosen. The bar is one stop for the Tab key: the arrow keys, Home and End move the selection.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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

  String section = 'Posts';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar<String>(
            value: section,
            onChanged: (value) => setState(() => section = value),
            tabs: [
              for (final name in _sections.keys)
                Tab(value: name, child: Text(name)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _sections[section]!,
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

With `expandTabs: false` each tab hugs its label, and the row scrolls sideways when the tabs do not fit.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
```

## Segmented

`variant: TabBarVariant.segmented` is the strip with a pill. It is as wide as its tabs unless `expand` is set. A tab can have a `leading` and a `trailing` widget, a `tooltip`, and be disabled.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// The same bar with `TabBarVariant.segmented`: a filled strip and a raised
/// pill. A tab takes a `leading` and a `trailing` widget, and can be
/// disabled.
class TabBarSegmentedExample extends StatefulWidget {
  const TabBarSegmentedExample({super.key});

  @override
  State<TabBarSegmentedExample> createState() => _TabBarSegmentedExampleState();
}

class _TabBarSegmentedExampleState extends State<TabBarSegmentedExample> {
  String folder = 'inbox';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.layoutTheme.gap(GapSize.lg),
      children: [
        TabBar<String>(
          variant: TabBarVariant.segmented,
          value: folder,
          onChanged: (value) => setState(() => folder = value),
          tabs: const [
            Tab(
              value: 'inbox',
              leading: PhosphorIcon(PhosphorIconsRegular.tray),
              trailing: IndicatorBadge(count: 4),
              child: Text('Inbox'),
            ),
            Tab(
              value: 'drafts',
              leading: PhosphorIcon(PhosphorIconsRegular.notePencil),
              child: Text('Drafts'),
            ),
            Tab(
              value: 'archive',
              leading: PhosphorIcon(PhosphorIconsRegular.archive),
              enabled: false,
              tooltip: 'Nothing archived yet',
              child: Text('Archive'),
            ),
          ],
        ),
        Text('Showing $folder', style: theme.textTheme.muted),
      ],
    );
  }
}
```

## With a TabBarView

When the bar and its pages are placed apart, give both the same `TabsController`. `TabBarView` takes a page builder per value. Swipe a page and it follows the finger, with the line under the tabs travelling between them; let go and it springs to the nearer page. Given a height, as here, the view fills it; in a column it is as tall as the page it shows.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A bar in one place and its pages in another, on one `TabsController`:
/// swipe the page and the line under the tabs goes with the finger.
class TabBarViewExample extends StatefulWidget {
  const TabBarViewExample({super.key});

  @override
  State<TabBarViewExample> createState() => _TabBarViewExampleState();
}

class _TabBarViewExampleState extends State<TabBarViewExample> {
  static const _sections = {
    'Posts': ['Shipping the new editor', 'What we learned in beta'],
    'Replies': ['Agreed, and the docs say so', 'Try the nightly build'],
    'Media': ['Launch day', 'The team offsite', 'Whiteboard, week 12'],
  };

  final tabs = TabsController<String>(value: 'Posts');

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A phone-sized frame: swiping is a touch gesture, so try it with a
    // finger or a trackpad.
    return Theme(
      data: theme.withFormFactor(FormFactor.mobile),
      child: Container(
        width: 340,
        height: 420,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: theme.radii.xl2),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.xl2,
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppBar(title: Text('Ada Okafor')),
              TabBar<String>(
                controller: tabs,
                tabs: [
                  for (final name in _sections.keys)
                    Tab(value: name, child: Text(name)),
                ],
              ),
              Expanded(
                child: TabBarView<String>(
                  controller: tabs,
                  pages: {
                    for (final MapEntry(key: name, value: rows)
                        in _sections.entries)
                      name: (context) => ListView(
                        padding: EdgeInsets.all(
                          theme.layoutTheme.gap(GapSize.md),
                        ),
                        children: [
                          for (final row in rows)
                            ListTile(
                              title: Text(row),
                              subtitle: Text(name),
                            ),
                        ],
                      ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
