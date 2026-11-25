# Expansion Tile

A list row that opens to show rows of its own: settings folded under a heading, the parts of an order. The heading is a `ListTile` ending in a caret; the rows unfold on the theme's spring. For panels of content rather than rows, use `Accordion` or `Collapsible`.

## In a section

Inside a `ListSection` the heading and its rows take the section's padding and fill to the card's corners. `value` sums up what is folded away.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Settings folded under their headings in one section. Each heading shows
/// a summary of what is under it, and the rows keep their state while they
/// are folded away.
class ExpansionTileSettingsExample extends StatefulWidget {
  const ExpansionTileSettingsExample({super.key});

  @override
  State<ExpansionTileSettingsExample> createState() =>
      _ExpansionTileSettingsExampleState();
}

class _ExpansionTileSettingsExampleState
    extends State<ExpansionTileSettingsExample> {
  final _alerts = {'Mentions': true, 'Replies': true, 'New followers': false};
  bool _digest = false;

  @override
  Widget build(BuildContext context) {
    final on = _alerts.values.where((value) => value).length;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ListSection(
        header: const Text('Account'),
        children: [
          const ListTile(
            leading: PhosphorIcon(PhosphorIconsRegular.user),
            title: Text('Profile'),
            showChevron: true,
          ),
          ExpansionTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.bell),
            title: const Text('Notifications'),
            value: Text('$on on'),
            initiallyOpen: true,
            children: [
              for (final MapEntry(key: name, value: enabled) in _alerts.entries)
                SwitchListTile(
                  title: Text(name),
                  value: enabled,
                  onChanged: (value) => setState(() => _alerts[name] = value),
                ),
            ],
          ),
          ExpansionTile(
            leading: const PhosphorIcon(PhosphorIconsRegular.envelope),
            title: const Text('Email'),
            value: Text(_digest ? 'Weekly' : 'Off'),
            children: [
              CheckboxListTile(
                title: const Text('Weekly digest'),
                subtitle: const Text('Every Monday morning'),
                value: _digest,
                onChanged: (value) => setState(() => _digest = value ?? false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Held by the parent

`open` and `onOpenChanged` hold the state outside the row; `initiallyOpen` lets it keep its own. `childrenPadding` indents the rows.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Outside a section the row is a plain tile: the parts of an order, held
/// open or closed by the parent through `open` and `onOpenChanged`.
class ExpansionTilePlainExample extends StatefulWidget {
  const ExpansionTilePlainExample({super.key});

  @override
  State<ExpansionTilePlainExample> createState() =>
      _ExpansionTilePlainExampleState();
}

class _ExpansionTilePlainExampleState extends State<ExpansionTilePlainExample> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: FinesseColumn(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        gap: GapSize.sm,
        children: [
          ExpansionTile(
            title: const Text('Order #2041'),
            subtitle: const Text('3 items · Delivered Tuesday'),
            value: const Text('€38.50'),
            open: _open,
            onOpenChanged: (open) => setState(() => _open = open),
            childrenPadding: EdgeInsetsDirectional.only(
              start: theme.layoutTheme.gap(GapSize.lg),
            ),
            children: const [
              ListTile(title: Text('Linen shirt'), value: Text('€24.00')),
              ListTile(title: Text('Canvas tote'), value: Text('€9.50')),
              ListTile(title: Text('Gift wrap'), value: Text('€5.00')),
            ],
          ),
          Button.outline(
            size: ButtonSize.sm,
            onPressed: () => setState(() => _open = !_open),
            child: Text(_open ? 'Fold it away' : 'Show the items'),
          ),
        ],
      ),
    );
  }
}
```
