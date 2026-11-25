# Hover Card

A card of supplementary content that opens when the pointer rests on its trigger, when the keyboard focuses it, or on a long press.

## Default

Hover the name, Tab to it, or press and hold it on a touch screen. The card never takes the focus, and closes a moment after the pointer has left both the name and the card.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// Rest the pointer on the name, move the focus to it, or press and hold it
/// on a touch screen: the card says who it is. Nothing in it is needed to
/// use the page, which is what makes it a hover card and not a popover.
class HoverCardBasicExample extends StatelessWidget {
  const HoverCardBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Reviewed by ', style: textTheme.p),
        HoverCard(
          builder: (context) => SizedBox(
            width: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const Avatar(null, fallback: Text('ML')),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text('Maya Lindqvist', style: textTheme.small),
                      Text(
                        'Type designer. Draws letters, mostly lowercase.',
                        style: textTheme.muted,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        spacing: 6,
                        children: [
                          PhosphorIcon(
                            PhosphorIconsRegular.calendarBlank,
                            size: 14,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          Text('Joined March 2024', style: textTheme.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Something the keyboard can reach: focus opens the card too.
          child: Pressable(
            onPressed: () {},
            builder: (context, states) => FocusRing(
              visible: states.contains(WidgetState.focused),
              borderRadius: theme.radii.sm,
              child: Text(
                '@maya',
                style: textTheme.p.copyWith(
                  color: theme.colorScheme.tint,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

## With an arrow

An arrow says which of several triggers the card belongs to. The card can hold controls: the pointer can travel into it, and Tab reaches them after the trigger.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// An arrow ties the card to one of several triggers in a row. The pointer
/// can travel into the card, and Tab reaches its button after the avatar:
/// the card stays for as long as either is in it.
class HoverCardArrowExample extends StatelessWidget {
  const HoverCardArrowExample({super.key});

  static const _people = [
    (initials: 'ML', name: 'Maya Lindqvist', role: 'Type designer'),
    (initials: 'OR', name: 'Omar Rahimi', role: 'Staff engineer'),
    (initials: 'EP', name: 'Elena Petrova', role: 'Product lead'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        for (final person in _people)
          HoverCard(
            showArrow: true,
            // Quick to open: these are small targets in a row, and the
            // next card should not keep the reader waiting.
            openDelay: const Duration(milliseconds: 250),
            builder: (context) => SizedBox(
              width: 220,
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(person.name, style: textTheme.small),
                        Text(person.role, style: textTheme.muted),
                      ],
                    ),
                  ),
                  Button.outline(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Follow'),
                  ),
                ],
              ),
            ),
            child: Pressable(
              onPressed: () {},
              semanticLabel: person.name,
              builder: (context, states) => FocusRing(
                visible: states.contains(WidgetState.focused),
                borderRadius: BorderRadius.circular(999),
                child: Avatar(null, fallback: Text(person.initials)),
              ),
            ),
          ),
      ],
    );
  }
}
```

## Placement and delays

An anchor puts the card above its trigger, with a fallback below; openDelay and closeDelay tune how eager it is.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A term in running text explains itself. The card opens above the line,
/// so it does not cover what the reader is about to read, and falls back
/// below where there is no room. openDelay and closeDelay set how long the
/// pointer has to rest and how long the card waits for it to come back.
class HoverCardTermExample extends StatelessWidget {
  const HoverCardTermExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Text.rich(
        TextSpan(
          style: textTheme.p,
          children: [
            const TextSpan(text: 'Each release is checked against the '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: HoverCard(
                showArrow: true,
                openDelay: const Duration(milliseconds: 400),
                closeDelay: const Duration(milliseconds: 150),
                anchor: const AnchorAuto(
                  offset: Offset(0, -4),
                  followerAnchor: Alignment.topCenter,
                  targetAnchor: Alignment.topCenter,
                  fallback: AnchorAuto(offset: Offset(0, 4)),
                ),
                builder: (context) => SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      Text('Error budget', style: textTheme.small),
                      Text(
                        'How much unreliability a service may spend in a '
                        'month before new features wait for fixes.',
                        style: textTheme.muted,
                      ),
                    ],
                  ),
                ),
                child: Text(
                  'error budget',
                  style: textTheme.p.copyWith(
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dotted,
                    decorationColor: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' before it ships.'),
          ],
        ),
      ),
    );
  }
}
```
