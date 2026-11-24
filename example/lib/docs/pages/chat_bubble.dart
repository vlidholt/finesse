import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/chat_bubble/chat_bubble_attachment.dart';
import 'package:example/docs/examples/chat_bubble/chat_bubble_conversation.dart';
import 'package:example/docs/examples/chat_bubble/chat_bubble_typing.dart';

final chatBubbleDoc = ComponentDoc(
  slug: 'chat_bubble',
  title: 'Chat Bubble',
  description:
      'One message in a conversation. A `ChatBubble` aligns itself to its '
      'side, wraps at a fraction of the available width and squares off '
      'the corner nearest the sender into a tail. `TypingIndicator` is '
      'the three pulsing dots that go in one.',
  examples: [
    ComponentExample(
      id: 'chat_bubble_conversation',
      title: 'Incoming and outgoing',
      description:
          '`direction` picks the side and the fill. Set `showTail` to '
          'false for all but the last bubble of a run.',
      minPreviewHeight: 300,
      builder: (_) => const ChatBubbleConversationExample(),
    ),
    ComponentExample(
      id: 'chat_bubble_typing',
      title: 'Typing indicator',
      description:
          'The animation stops while the widget is off screen or '
          'animations are disabled.',
      builder: (_) => const ChatBubbleTypingExample(),
    ),
    ComponentExample(
      id: 'chat_bubble_attachment',
      title: 'An attachment',
      description:
          '`color`, `foregroundColor`, `border` and `padding` restyle a '
          'single bubble.',
      builder: (_) => const ChatBubbleAttachmentExample(),
    ),
  ],
);
