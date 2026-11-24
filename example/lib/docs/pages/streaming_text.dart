import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/streaming_text/streaming_text_bubble.dart';
import 'package:example/docs/examples/streaming_text/streaming_text_replay.dart';

final streamingTextDoc = ComponentDoc(
  slug: 'streaming_text',
  title: 'Streaming Text',
  description:
      'Text that grows while it is on screen, such as the reply of a '
      'language model arriving token by token. `StreamingText` reveals '
      'what arrives a character at a time at an even pace, each piece '
      'fading in, instead of popping in a chunk at a time. Feed it a '
      'string that keeps getting longer, a `Stream<String>` of chunks, or '
      'a `StreamingTextController`. When the text is complete it becomes '
      'a plain `Text`.',
  examples: [
    ComponentExample(
      id: 'streaming_text_replay',
      title: 'An uneven stream, evenly shown',
      description:
          'The reveal speeds up the further behind it is, so a burst does '
          'not take long and a trickle does not stutter. It never splits '
          'a grapheme cluster, and lines already showing are not laid out '
          'again by what follows. A soft caret marks the end while more '
          'is expected. `StreamingTextController.stop` is what a "stop '
          'generating" button calls: the text that arrived stays, in the '
          'same finished state as a stream that ended by itself. With '
          'reduced motion each chunk appears at once with a short fade.',
      minPreviewHeight: 300,
      builder: (_) => const StreamingTextReplayExample(),
    ),
    ComponentExample(
      id: 'streaming_text_bubble',
      title: 'In a chat bubble',
      description:
          '`placeholder` shows a `TypingIndicator` until the first text, '
          'then fades out over it. A `ChatBubble` follows the size of '
          'what is in it on a spring, so the bubble grows with the reply. '
          'For Markdown, render the blocks that are complete with your '
          'Markdown widget and give the last, unfinished one to a '
          '`StreamingText` (or to `StreamingText.rich`, with inline '
          'styles as spans).',
      minPreviewHeight: 300,
      builder: (_) => const StreamingTextBubbleExample(),
    ),
  ],
);
