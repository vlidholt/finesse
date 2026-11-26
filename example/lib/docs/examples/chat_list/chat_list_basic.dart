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
