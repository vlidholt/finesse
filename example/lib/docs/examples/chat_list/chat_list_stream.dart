import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
