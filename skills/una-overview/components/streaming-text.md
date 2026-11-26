# Streaming Text

Text that grows while it is on screen, such as the reply of a language model arriving token by token. `StreamingText` reveals what arrives a character at a time at an even pace, each piece fading in, instead of popping in a chunk at a time. Feed it a string that keeps getting longer, a `Stream<String>` of chunks, or a `StreamingTextController`. When the text is complete it becomes a plain `Text`.

## An uneven stream, evenly shown

The reveal speeds up the further behind it is, so a burst does not take long and a trickle does not stutter. It never splits a grapheme cluster, and lines already showing are not laid out again by what follows. A soft caret marks the end while more is expected. `StreamingTextController.stop` is what a "stop generating" button calls: the text that arrived stays, in the same finished state as a stream that ended by itself. With reduced motion each chunk appears at once with a short fade.

```dart
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

/// Text fed in uneven chunks at uneven intervals, and shown as an even
/// flow. Replay it; stop it part-way and what has arrived stays.
class StreamingTextReplayExample extends StatefulWidget {
  const StreamingTextReplayExample({super.key});

  @override
  State<StreamingTextReplayExample> createState() =>
      _StreamingTextReplayExampleState();
}

class _StreamingTextReplayExampleState
    extends State<StreamingTextReplayExample> {
  static const _chunks = [
    'Text that arrives ',
    'in pieces ',
    'does not have to look like it. ',
    'Each piece is revealed a character at a time, at a pace that speeds '
        'up when there is a lot to catch up on ',
    'and ',
    'eases off when there is not, ',
    'so a stream that stutters reads as one that flows. ',
    'Emoji arrive whole \u{1F44B}\u{1F3FD}, ',
    'and lines that are already showing never move.',
  ];
  static const _pauses = [90, 420, 60, 700, 40, 240, 520, 120, 0];

  final _text = StreamingTextController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _play() {
    _timer?.cancel();
    _text.reset();
    var index = 0;
    void next() {
      if (index == _chunks.length) return _text.complete();
      _text.append(_chunks[index]);
      _timer = Timer(Duration(milliseconds: _pauses[index++]), next);
    }

    _timer = Timer(const Duration(milliseconds: 500), next);
  }

  void _stop() {
    _timer?.cancel();
    _text.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Room for the whole text, so the buttons below do not move.
          SizedBox(
            height: 150,
            child: StreamingText.controller(
              _text,
              style: Theme.of(context).textTheme.p,
            ),
          ),
          ListenableBuilder(
            listenable: _text,
            builder: (context, _) => Row(
              spacing: 8,
              children: [
                Button(onPressed: _play, child: const Text('Replay')),
                Button.outline(
                  enabled: !_text.isDone,
                  onPressed: _stop,
                  child: const Text('Stop'),
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

## In a chat bubble

`placeholder` shows a `TypingIndicator` until the first text, then fades out over it. A `ChatBubble` follows the size of what is in it on a spring, so the bubble grows with the reply. For Markdown, render the blocks that are complete with your Markdown widget and give the last, unfinished one to a `StreamingText` (or to `StreamingText.rich`, with inline styles as spans).

```dart
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
```
