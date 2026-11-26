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
