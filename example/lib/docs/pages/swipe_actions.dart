import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/swipe_actions/swipe_actions_confirm.dart';
import 'package:example/docs/examples/swipe_actions/swipe_actions_inbox.dart';

final swipeActionsDoc = ComponentDoc(
  slug: 'swipe_actions',
  title: 'Swipe Actions',
  description:
      'A row with actions behind it, uncovered by swiping it sideways: '
      'archive or delete a message, mark a notification read.',
  examples: [
    ComponentExample(
      id: 'swipe_actions_inbox',
      title: 'An inbox',
      description:
          'Swipe a row with a finger or a trackpad. Let go past half of the '
          'actions and they stay open; swipe across most of the row and the '
          'outer one runs. An action that returns true removes the row: it '
          'slides out, the gap closes and `onRemoved` is called. A mouse '
          'does not drag rows: right-click one, or press the menu key while '
          'it has the focus, for the same actions as a menu. '
          '`SwipeActionsScope` keeps one row open at a time.',
      minPreviewHeight: 380,
      builder: (_) => const SwipeActionsInboxExample(),
    ),
    ComponentExample(
      id: 'swipe_actions_confirm',
      title: 'Asking first',
      description:
          '`onPressed` may return a future: the row stays open until it '
          'completes. With `fullSwipe: false` a long swipe only opens the '
          'row.',
      minPreviewHeight: 300,
      builder: (_) => const SwipeActionsConfirmExample(),
    ),
  ],
);
