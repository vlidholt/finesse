# Sheet

A panel attached to an edge of the page. showSheet presents one over a barrier; a Sheet placed in the tree stays beside the content. It rests at detents, follows a finger, and takes its drag from the list inside it.

## Sides

On a phone a sheet from the bottom spans the screen, has a drag handle and is pulled down to close. On a desktop it is centred and no wider than a readable column; a sheet from a side is the usual choice there.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A sheet comes from any edge. `start` and `end` follow the text direction;
/// the other four are physical. A sheet from the top or bottom is as tall as
/// its content, one from a side as tall as the page.
class SheetSidesExample extends StatelessWidget {
  const SheetSidesExample({super.key});

  void _open(BuildContext context, SheetSide side) {
    showSheet<void>(
      context: context,
      side: side,
      builder: (context) => Sheet(
        title: const Text('Edit profile'),
        description: const Text(
          "Make changes to your profile here. Save when you're done.",
        ),
        actions: [
          Button.outline(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Button(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Save changes'),
          ),
        ],
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: TextField(placeholder: Text('Name')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final side in SheetSide.values)
          Button.outline(
            onPressed: () => _open(context, side),
            child: Text(side.name),
          ),
      ],
    );
  }
}
```

## Detents

SheetDetent.content (the default), medium, large, full, fraction(…) and height(…). The handle resizes it with a mouse, the arrow keys and a screen reader; a SheetController sends it to a detent or closes it.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Detents are the sizes a sheet rests at. Drag it, fling it, press the
/// arrow keys with the handle focused, or send it somewhere with a
/// `SheetController`.
class SheetDetentsExample extends StatelessWidget {
  const SheetDetentsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      onPressed: () => showSheet<void>(
        context: context,
        builder: (context) => const _TripSheet(),
      ),
      child: const Text('Plan a trip'),
    );
  }
}

class _TripSheet extends StatefulWidget {
  const _TripSheet();

  @override
  State<_TripSheet> createState() => _TripSheetState();
}

class _TripSheetState extends State<_TripSheet> {
  final _sheet = SheetController();
  var _detent = SheetDetent.medium;

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expanded = _detent == SheetDetent.large;
    return Sheet(
      controller: _sheet,
      detents: const [SheetDetent.medium, SheetDetent.large],
      onDetentChanged: (detent) => setState(() => _detent = detent),
      title: const Text('Lisbon, three days'),
      description: Text(expanded ? 'The whole plan' : 'Day one'),
      actions: [
        Button.outline(
          onPressed: () => _sheet.animateTo(
            expanded ? SheetDetent.medium : SheetDetent.large,
          ),
          child: Text(expanded ? 'Show less' : 'Show all three days'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (day, plan) in const [
            ('Friday', 'Alfama on foot, then fado after dinner.'),
            ('Saturday', 'The tram to Belém and back along the river.'),
            ('Sunday', 'Sintra by train, home on the late one.'),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day, style: theme.textTheme.small),
                  Text(plan, style: theme.textTheme.muted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
```

## A list that drives the sheet

With a builder the sheet hands its scroll controller to your list, and one drag does both: the sheet grows before the list scrolls, and comes down from the top of the list.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A sheet with a list of its own takes a `builder` and gives the list the
/// scroll controller it is handed. A pull up then raises the sheet to its
/// largest detent before the list scrolls, and a pull down from the top of
/// the list lowers it — and, from the smallest detent, closes it.
class SheetListExample extends StatelessWidget {
  const SheetListExample({super.key});

  static const _names = [
    'Maya Lindqvist',
    'Omar Rahimi',
    'Ines Carvalho',
    'Jonas Berg',
    'Aiko Tanaka',
    'Leila Haddad',
    'Tomás Rivera',
    'Freja Holm',
    'Noah Okafor',
    'Sofia Marin',
    'Elias Novak',
    'Priya Raman',
  ];

  @override
  Widget build(BuildContext context) {
    return Button.outline(
      onPressed: () => showSheet<void>(
        context: context,
        builder: (context) => Sheet(
          title: const Text('Liked by'),
          detents: const [SheetDetent.medium, SheetDetent.large],
          builder: (context, controller) => ListView.builder(
            controller: controller,
            itemCount: _names.length,
            itemBuilder: (context, index) {
              final name = _names[index];
              return ListTile(
                leading: Avatar(null, fallback: Text(name[0])),
                title: Text(name),
                onTap: () => Navigator.of(context).pop(),
              );
            },
          ),
        ),
      ),
      child: const Text('Show who liked this'),
    );
  }
}
```

## Inline

No route, no barrier. Use it for something that stays with the page: a player, the results under a map, the bottom sheet of a scaffold.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A `Sheet` placed in the tree is an inline sheet: no route and no barrier,
/// so what is behind it stays in use. Its detents are measured against its
/// parent, and it cannot be dragged away — only its parent can remove it.
class SheetInlineExample extends StatefulWidget {
  const SheetInlineExample({super.key});

  @override
  State<SheetInlineExample> createState() => _SheetInlineExampleState();
}

class _SheetInlineExampleState extends State<SheetInlineExample> {
  var _taps = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: theme.radii.lg,
      child: SizedBox(
        width: 340,
        height: 420,
        child: Stack(
          children: [
            // The page behind: still tappable.
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.muted,
                child: Align(
                  alignment: const Alignment(0, -.7),
                  child: Button.outline(
                    onPressed: () => setState(() => _taps++),
                    child: Text('Tapped $_taps times'),
                  ),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Sheet(
                detents: [SheetDetent.height(112), SheetDetent.fraction(.7)],
                // Draggable by a mouse too, anywhere on it.
                draggable: true,
                showDragHandle: true,
                title: Text('Now playing'),
                description: Text('Pull up for the queue'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(title: Text('Saudade'), subtitle: Text('3:42')),
                    ListTile(
                      title: Text('Bairro Alto'),
                      subtitle: Text('4:05'),
                    ),
                    ListTile(title: Text('Tejo'), subtitle: Text('2:58')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
