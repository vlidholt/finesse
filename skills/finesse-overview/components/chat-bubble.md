# Chat Bubble

One message in a conversation. A `ChatBubble` aligns itself to its side, wraps at a fraction of the available width and squares off the corner nearest the sender into a tail. `TypingIndicator` is the three pulsing dots that go in one.

## Incoming and outgoing

`direction` picks the side and the fill. Set `showTail` to false for all but the last bubble of a run.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A short exchange. Only the last bubble of each run keeps its tail, and a
/// bubble never grows past a fraction of the width, so long messages wrap.
class ChatBubbleConversationExample extends StatelessWidget {
  const ChatBubbleConversationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatBubble(
            showTail: false,
            child: Text('Morning! Did the research summary come through?'),
          ),
          SizedBox(height: 4),
          ChatBubble(child: Text('I sent it late last night.')),
          SizedBox(height: 12),
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            showTail: false,
            child: Text('It did, thank you.'),
          ),
          SizedBox(height: 4),
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text(
              'The part about onboarding drop-off is exactly what we '
              'needed for Thursday. Can I quote it in the deck?',
            ),
          ),
        ],
      ),
    );
  }
}
```

## Typing indicator

The animation stops while the widget is off screen or animations are disabled.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// `TypingIndicator` in an incoming bubble, beside the sender's avatar.
class ChatBubbleTypingExample extends StatelessWidget {
  const ChatBubbleTypingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text('Can I quote it in the deck?'),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              Avatar(
                'assets/strand/avatar_omar_rahimi.jpg',
                size: Size.square(28),
                fallback: Text('O'),
              ),
              // The bubble sizes itself against the width it is given.
              Expanded(
                child: ChatBubble(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: TypingIndicator(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## An attachment

`color`, `foregroundColor`, `border` and `padding` restyle a single bubble.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

/// A bubble is a container: any widget works as its child. An attachment
/// swaps the fill for the card colour and adds a border.
class ChatBubbleAttachmentExample extends StatelessWidget {
  const ChatBubbleAttachmentExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          const ChatBubble(
            showTail: false,
            child: Text('Here is the map from the workshop.'),
          ),
          ChatBubble(
            color: theme.colorScheme.card,
            foregroundColor: theme.colorScheme.foreground,
            border: Border.all(color: theme.colorScheme.border),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                const IconTile(icon: PhosphorIcon(PhosphorIconsRegular.image)),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'onboarding-map.jpg',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.small,
                      ),
                      Text('840 KB', style: theme.textTheme.muted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

