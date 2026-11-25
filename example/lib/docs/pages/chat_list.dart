import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/chat_list/chat_list_basic.dart';
import 'package:example/docs/examples/chat_list/chat_list_stream.dart';

final chatListDoc = ComponentDoc(
  slug: 'chat_list',
  title: 'Chat List',
  description:
      'A conversation: a lazily built list of messages that is anchored to '
      'its newest one and moves when it changes. `ChatList` is generic '
      'over your message type and controlled by its parent. Give it the '
      'messages, oldest first, an `idOf` and an `itemBuilder`, and it '
      'animates what is added, removed or resized, keeps the end in view '
      'while you are at it, and holds what you are reading still once you '
      'have scrolled away.',
  examples: [
    ComponentExample(
      id: 'chat_list_basic',
      title: 'Messages arriving',
      description:
          'A new message opens its height on a spring, so the ones above '
          'glide up, while it grows out of the corner its tail is in. '
          '`directionOf` says which side that is. `sameGroup` sets a run '
          'of one sender tighter, and `item.isLastInGroup` tells the '
          'builder which bubble keeps the tail. A reply that starts as a '
          '`TypingIndicator` and becomes text keeps its id, so it is one '
          'bubble changing size, not two messages.',
      minPreviewHeight: 440,
      builder: (_) => const ChatListBasicExample(),
    ),
    ComponentExample(
      id: 'chat_list_stream',
      title: 'Following a streamed reply',
      description:
          'While the reader is within the `followDistance` of the theme '
          'from the end, the list follows content that grows. Scroll back while the '
          'reply is still being written and it holds the view exactly '
          'where it is; a `ChatListController` reports `atEnd` and '
          '`unseenCount` and scrolls back with `scrollToEnd`, which is '
          'what the round button does. Pass `showJumpToLatest: false` or '
          'a `jumpToLatestBuilder` for your own. Older messages added at '
          'the start, from `onStartReached`, never move the view.',
      minPreviewHeight: 440,
      builder: (_) => const ChatListStreamExample(),
    ),
  ],
);
