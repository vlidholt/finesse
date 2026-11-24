# Tooltip

A popup that displays information related to an element on hover or focus.

## Basic

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipBasicExample extends StatelessWidget {
  const TooltipBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Text('Add to library'),
      child: Button.outline(
        onPressed: () {},
        child: const Text('Show Tooltip'),
      ),
    );
  }
}
```

## Sides

An anchor places the tooltip on any side of its trigger; the arrow direction follows it.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipSidesExample extends StatelessWidget {
  const TooltipSidesExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SideTooltip(label: 'Left', direction: AxisDirection.left),
        _SideTooltip(label: 'Top', direction: AxisDirection.up),
        _SideTooltip(label: 'Bottom', direction: AxisDirection.down),
        _SideTooltip(label: 'Right', direction: AxisDirection.right),
      ],
    );
  }
}

class _SideTooltip extends StatelessWidget {
  const _SideTooltip({required this.label, required this.direction});

  final String label;

  /// The side of the trigger the tooltip appears on.
  final AxisDirection direction;

  @override
  Widget build(BuildContext context) {
    final anchor = switch (direction) {
      AxisDirection.up => const Anchor(
        childAlignment: Alignment.topCenter,
        overlayAlignment: Alignment.bottomCenter,
        offset: Offset(0, -4),
      ),
      AxisDirection.down => const Anchor(
        childAlignment: Alignment.bottomCenter,
        overlayAlignment: Alignment.topCenter,
        offset: Offset(0, 4),
      ),
      AxisDirection.left => const Anchor(
        childAlignment: Alignment.centerLeft,
        overlayAlignment: Alignment.centerRight,
        offset: Offset(-4, 0),
      ),
      AxisDirection.right => const Anchor(
        childAlignment: Alignment.centerRight,
        overlayAlignment: Alignment.centerLeft,
        offset: Offset(4, 0),
      ),
    };

    return Tooltip(
      anchor: anchor,
      // The arrow points back at the trigger, opposite the placement side.
      arrowDirection: switch (direction) {
        AxisDirection.up => AxisDirection.down,
        AxisDirection.down => AxisDirection.up,
        AxisDirection.left => AxisDirection.right,
        AxisDirection.right => AxisDirection.left,
      },
      builder: (context) => const Text('Add to library'),
      child: Button.outline(onPressed: () {}, child: Text(label)),
    );
  }
}
```

## With icon

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipIconExample extends StatelessWidget {
  const TooltipIconExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Text('Additional information'),
      child: IconButton.ghost(
        icon: const Icon(PhosphorIconsRegular.info),
        onPressed: () {},
      ),
    );
  }
}
```

## Long content

Long content wraps at the tooltip’s max width.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipLongContentExample extends StatelessWidget {
  const TooltipLongContentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      // Long content wraps at the tooltip's max width.
      builder: (context) => const Text(
        'To learn more about how this works, check out the docs. If you '
        'have any questions, please reach out to us.',
      ),
      child: Button.outline(
        onPressed: () {},
        child: const Text('Show Tooltip'),
      ),
    );
  }
}
```

## Disabled

A disabled control absorbs pointer events, so a gesture wrapper reports the hover on its behalf.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipDisabledExample extends StatelessWidget {
  const TooltipDisabledExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A disabled button absorbs pointer events, so a wrapper reports the
    // hover on its behalf — the reference wraps its trigger in a span for
    // the same reason.
    return Tooltip(
      builder: (context) => const Text('This feature is currently unavailable'),
      child: FinesseGestureDetector(
        child: Button.outline(
          enabled: false,
          onPressed: () {},
          child: const Text('Disabled'),
        ),
      ),
    );
  }
}
```

## With keyboard shortcut

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipKeyboardExample extends StatelessWidget {
  const TooltipKeyboardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Save Changes'),
          SizedBox(width: 6),
          Kbd('S'),
        ],
      ),
      child: IconButton.outline(
        icon: const Icon(PhosphorIconsRegular.floppyDisk),
        onPressed: () {},
      ),
    );
  }
}
```

## On link

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipLinkExample extends StatelessWidget {
  const TooltipLinkExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) => const Text('Click to read the documentation'),
      child: Button.link(
        onPressed: () {},
        child: const Text('Learn more'),
      ),
    );
  }
}
```

## Formatted content

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class TooltipFormattedExample extends StatelessWidget {
  const TooltipFormattedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      builder: (context) {
        final style = DefaultTextStyle.of(context).style;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active',
              style: style.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Opacity(
              opacity: .8,
              child: Text('Last updated 2 hours ago', style: style),
            ),
          ],
        );
      },
      child: Button.outline(onPressed: () {}, child: const Text('Status')),
    );
  }
}
```

