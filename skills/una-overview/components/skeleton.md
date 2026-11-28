# Skeleton

A placeholder to show while content is loading, in the shape of the content it stands in for.

## Default

A block of any size: `width` and `height`, or the size its parent gives it; `Skeleton.circle` for a round one. In the una style a soft band of light sweeps across it; the shadcn styles pulse. Every skeleton moves to one clock, and the band is laid across the whole screen, so neighbours shimmer as one surface. Under reduced motion it holds still.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class SkeletonCardExample extends StatelessWidget {
  const SkeletonCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Skeleton.circle(size: 48),
        SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 220, height: 16),
            SizedBox(height: 8),
            Skeleton(width: 160, height: 16),
          ],
        ),
      ],
    );
  }
}
```

## Text

`SkeletonText` is `lines` bars in a text `style`: each as tall as the text's capitals and spaced at its line height, so the block is as tall as the text that replaces it. The lines vary a little and the last is shorter (`lastLineWidthFactor`).

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A heading and a paragraph, each as tall as the text it stands in for.
class SkeletonTextExample extends StatelessWidget {
  const SkeletonTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          SkeletonText(lines: 1, style: text.h3, lastLineWidthFactor: .5),
          SkeletonText(lines: 4, style: text.p),
        ],
      ),
    );
  }
}
```

## List tiles

`SkeletonListTile` has a list tile's padding, gap and text styles: an avatar by default as `leading` (null for none), a title, `subtitleLines` of subtitle and an optional `trailing` placeholder.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A list loading: rows the shape of list tiles, avatar and all.
class SkeletonListExample extends StatelessWidget {
  const SkeletonListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonListTile(),
          SkeletonListTile(trailing: Skeleton.button(width: 64)),
          SkeletonListTile(subtitleLines: 2),
          SkeletonListTile(leading: Skeleton(width: 40, height: 40)),
        ],
      ),
    );
  }
}
```

## Cards

`SkeletonCard` is a real card with a media block across its top (`mediaAspectRatio`, null for none), a title, `lines` of description and `actions` button placeholders.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Cards loading: one with a picture and actions, one with text only.
class SkeletonCardsExample extends StatelessWidget {
  const SkeletonCardsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        SkeletonCard(width: 280, actions: 2),
        SkeletonCard(width: 280, mediaAspectRatio: null, lines: 4),
      ],
    );
  }
}
```

## Chat

`SkeletonChatBubble` is a bubble of the chat bubble theme's corners and padding, `lines` tall, on the side its `direction` puts it, with the tail corner squared off.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A conversation loading: bubbles on both sides, tails and all.
class SkeletonChatExample extends StatelessWidget {
  const SkeletonChatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SkeletonChatBubble(),
          SkeletonChatBubble(lines: 1, widthFactor: .45),
          SkeletonChatBubble(
            direction: ChatBubbleDirection.outgoing,
            lines: 3,
          ),
          SkeletonChatBubble(
            direction: ChatBubbleDirection.outgoing,
            lines: 1,
            widthFactor: .3,
          ),
        ],
      ),
    );
  }
}
```

## Table rows

`SkeletonTableRow` has the table theme's row height and cell padding; `flex` shares the width between the columns and `row` varies the bars from one row to the next.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A table loading: the table's row height and padding, bars of different
/// lengths so it does not read as loaded and empty.
class SkeletonTableExample extends StatelessWidget {
  const SkeletonTableExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 5; row++)
            SkeletonTableRow(columns: 4, flex: const [3, 2, 2, 1], row: row),
        ],
      ),
    );
  }
}
```

## Avatars, chips and buttons

`Skeleton.avatar`, `Skeleton.chip` and `Skeleton.button` take their size and corners from the component they stand in for.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Avatars, chips and buttons, each the size its component would be.
class SkeletonControlsExample extends StatelessWidget {
  const SkeletonControlsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Skeleton.avatar(),
            Skeleton.avatar(),
            Skeleton.avatar(),
            Skeleton.avatar(size: 48),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Skeleton.chip(),
            Skeleton.chip(width: 96),
            Skeleton.chip(width: 56),
            Skeleton.chip(width: 80),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            Skeleton.button(size: ButtonSize.sm),
            Skeleton.button(),
            Skeleton.button(size: ButtonSize.lg, width: 120),
          ],
        ),
      ],
    );
  }
}
```

## Swapping in the content

Put the content in the skeleton's place once it has loaded. A placeholder in the real component's metrics keeps the page from jumping when it does.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A placeholder stands in for exactly the row that replaces it, so the
/// page does not jump when the content arrives.
class SkeletonSwapExample extends StatefulWidget {
  const SkeletonSwapExample({super.key});

  @override
  State<SkeletonSwapExample> createState() => _SkeletonSwapExampleState();
}

class _SkeletonSwapExampleState extends State<SkeletonSwapExample> {
  var _loaded = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          SwitchListTile(
            value: _loaded,
            onChanged: (value) => setState(() => _loaded = value),
            title: const Text('Loaded'),
          ),
          if (_loaded)
            const ListTile(
              leading: Avatar(
                'assets/images/avatar_mei_tanaka.jpg',
                fallback: Text('MT'),
              ),
              title: Text('Mei Tanaka'),
              subtitle: Text('Shared three photos with you'),
            )
          else
            const SkeletonListTile(),
        ],
      ),
    );
  }
}
```
