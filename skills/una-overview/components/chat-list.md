# Chat List

A conversation: a lazily built list of messages that is anchored to its newest one and moves when it changes. `ChatList` is generic over your message type and controlled by its parent. Give it the messages, oldest first, an `idOf` and an `itemBuilder`, and it animates what is added, removed or resized, keeps the end in view while you are at it, and holds what you are reading still once you have scrolled away.

## Messages arriving

A new message opens its height on a spring, so the ones above glide up, while it grows out of the corner its tail is in. `directionOf` says which side that is. `sameGroup` sets a run of one sender tighter, and `item.isLastInGroup` tells the builder which bubble keeps the tail. A reply that starts as a `TypingIndicator` and becomes text keeps its id, so it is one bubble changing size, not two messages.

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A conversation the two buttons add to. A message that arrives opens its
/// height on a spring while it grows out of its tail corner; the reply
/// starts as three dots and becomes text in the same bubble.
class ChatListBasicExample extends StatefulWidget {
  const ChatListBasicExample({super.key});

  @override
  State<ChatListBasicExample> createState() => _ChatListBasicExampleState();
}

typedef _Message = ({int id, String? text, bool mine});

class _ChatListBasicExampleState extends State<ChatListBasicExample> {
  static const _lines = [
    'Did the research summary come through?',
    'It did, thank you. Reading it now.',
    'The part about onboarding is what we needed for Thursday.',
    'Quote it in the deck if you like.',
  ];

  var _messages = <_Message>[
    (id: 0, text: 'Morning!', mine: false),
    (id: 1, text: 'Morning. Coffee first.', mine: true),
  ];
  var _next = 2;
  Timer? _reply;

  @override
  void dispose() {
    _reply?.cancel();
    super.dispose();
  }

  // The list is controlled: replace the list, and it animates the change.
  void _send() => setState(() {
    final text = _lines[_next % _lines.length];
    _messages = [..._messages, (id: _next++, text: text, mine: true)];
  });

  void _receive() {
    if (_reply != null) return;
    // No text yet: they are typing.
    final id = _next++;
    setState(
      () => _messages = [..._messages, (id: id, text: null, mine: false)],
    );
    _reply = Timer(const Duration(milliseconds: 1400), () {
      _reply = null;
      setState(() {
        _messages = [
          for (final message in _messages)
            if (message.id == id)
              (id: id, text: _lines[id % _lines.length], mine: false)
            else
              message,
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SizedBox(
            height: 320,
            child: ChatList<_Message>(
              messages: _messages,
              idOf: (message) => message.id,
              directionOf: (message) => message.mine
                  ? ChatBubbleDirection.outgoing
                  : ChatBubbleDirection.incoming,
              // A run of one sender is set tighter and shares one tail.
              sameGroup: (a, b) => a.mine == b.mine,
              itemBuilder: (context, item) {
                final (id: _, :text, :mine) = item.message;
                return ChatBubble(
                  direction: mine
                      ? ChatBubbleDirection.outgoing
                      : ChatBubbleDirection.incoming,
                  showTail: item.isLastInGroup,
                  child: mine
                      ? Text(text!)
                      : StreamingText(
                          text ?? '',
                          streaming: text == null,
                          placeholder: const TypingIndicator(),
                        ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              Button.outline(onPressed: _receive, child: const Text('Receive')),
              Button(onPressed: _send, child: const Text('Send')),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Following a streamed reply

While the reader is within the `followDistance` of the theme from the end, the list follows content that grows. Scroll back while the reply is still being written and it holds the view exactly where it is; a `ChatListController` reports `atEnd` and `unseenCount` and scrolls back with `scrollToEnd`, which is what the round button does. Pass `showJumpToLatest: false` or a `jumpToLatestBuilder` for your own. Older messages added at the start, from `onStartReached`, never move the view.

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// A reply streamed into the newest bubble. The list follows it down while
/// you are at the end; scroll up while it writes and the view holds still,
/// with a button back to the latest.
class ChatListStreamExample extends StatefulWidget {
  const ChatListStreamExample({super.key});

  @override
  State<ChatListStreamExample> createState() => _ChatListStreamExampleState();
}

class _ChatListStreamExampleState extends State<ChatListStreamExample> {
  static const _answer =
      'A list that is anchored to its end behaves like a conversation: what '
      'arrives pushes the rest up, and the newest line is always the one '
      'you are reading. That holds while a reply is still being written, a '
      'few words at a time. Scroll back and it lets go, because now you '
      'are reading something else, and it keeps that exactly where it is '
      'until you come back to the end.';

  // Each reply keeps its text in a controller, so a bubble that is
  // scrolled out of the lazy list and built again loses nothing.
  final _replies = <StreamingTextController>[];
  Timer? _timer;

  bool get _writing => _replies.isNotEmpty && !_replies.last.isDone;

  @override
  void dispose() {
    _timer?.cancel();
    for (final reply in _replies) {
      reply.dispose();
    }
    super.dispose();
  }

  void _ask() {
    final reply = StreamingTextController();
    setState(() => _replies.add(reply));
    // A stand-in for a model: a few words at a time, unevenly.
    final words = _answer.split(' ');
    var word = 0;
    void more() {
      if (word >= words.length) return setState(reply.complete);
      final count = 1 + (word * 7) % 5;
      reply.append('${words.skip(word).take(count).join(' ')} ');
      word += count;
      _timer = Timer(Duration(milliseconds: 40 + (word * 37) % 160), more);
    }

    _timer = Timer(const Duration(milliseconds: 600), more);
  }

  void _stop() {
    _timer?.cancel();
    // What has arrived stays, as a finished message.
    setState(_replies.last.stop);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SizedBox(
            height: 320,
            child: ChatList<int>(
              // Questions are even, the replies to them odd.
              messages: [for (var i = 0; i < _replies.length * 2; i++) i],
              idOf: (index) => index,
              directionOf: (index) => index.isEven
                  ? ChatBubbleDirection.outgoing
                  : ChatBubbleDirection.incoming,
              itemBuilder: (context, item) => item.message.isEven
                  ? const ChatBubble(
                      direction: ChatBubbleDirection.outgoing,
                      child: Text('How does the list follow a reply?'),
                    )
                  : ChatBubble(
                      child: StreamingText.controller(
                        _replies[item.message ~/ 2],
                        placeholder: const TypingIndicator(),
                      ),
                    ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _writing
                ? Button.outline(onPressed: _stop, child: const Text('Stop'))
                : Button(onPressed: _ask, child: const Text('Ask')),
          ),
        ],
      ),
    );
  }
}
```
