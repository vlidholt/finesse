import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// In a `ChatBubble`: three dots while nothing has arrived, then the text,
/// the bubble growing with it — wider, then a line at a time — with its
/// tail corner staying where it is.
class StreamingTextBubbleExample extends StatefulWidget {
  const StreamingTextBubbleExample({super.key});

  @override
  State<StreamingTextBubbleExample> createState() =>
      _StreamingTextBubbleExampleState();
}

class _StreamingTextBubbleExampleState
    extends State<StreamingTextBubbleExample> {
  static const _reply =
      'Yes. Slide 14 reads much better with the flow beside it, and the '
      'numbers on 16 make the point on their own. I would cut the '
      'second quote and end on the question.';

  // The simplest way to feed it: a string that keeps getting longer.
  var _text = '';
  var _streaming = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _play() {
    _timer?.cancel();
    setState(() {
      _text = '';
      _streaming = true;
    });
    // "Thinking", then a few characters every so often.
    var sent = 0;
    void next() {
      final size = 3 + (sent * 5) % 14;
      sent = (sent + size).clamp(0, _reply.length);
      setState(() {
        _text = _reply.substring(0, sent);
        _streaming = sent < _reply.length;
      });
      if (_streaming) {
        _timer = Timer(Duration(milliseconds: 30 + (sent * 29) % 130), next);
      }
    }

    _timer = Timer(const Duration(milliseconds: 1100), next);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          const ChatBubble(
            direction: ChatBubbleDirection.outgoing,
            child: Text('Does the deck hold together?'),
          ),
          // As tall as the whole reply, against its bottom edge: the
          // bubble grows upwards, as it does at the end of a conversation.
          SizedBox(
            height: 132,
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: ChatBubble(
                child: StreamingText(
                  _text,
                  streaming: _streaming,
                  placeholder: const TypingIndicator(),
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Button.outline(
              onPressed: _play,
              child: const Text('Replay'),
            ),
          ),
        ],
      ),
    );
  }
}
