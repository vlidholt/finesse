# The board and the chat list

Two controlled widgets for content that moves: a kanban `Board`, and a
`ChatList` with `StreamingText` for a conversation whose replies arrive
token by token. Both report what happened and let the parent own the data;
both animate whatever the next build puts where.

## Board

Columns of cards dragged to reorder them and to move them between
columns. The parent owns the lists and applies each `BoardMove`:

```dart
class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final _lists = {
    'todo': ['Write the brief', 'Book the room'],
    'done': ['Send invites'],
  };

  @override
  Widget build(BuildContext context) {
    return Board<String>(
      columns: [
        for (final MapEntry(key: id, value: items) in _lists.entries)
          BoardColumn(id: id, label: id, items: items),
      ],
      itemId: (task) => task,
      onMove: (move) => setState(
        () => move.apply(_lists[move.fromColumn]!, _lists[move.toColumn]!),
      ),
      itemBuilder: (context, task, details) => Card(child: Text(task)),
    );
  }
}
```

- `BoardMove.toIndex` is counted after the item is taken out, so `apply`
  (remove, then insert) is all the parent does. A parent that refuses,
  sorts or applies the move later is still animated correctly.
- A mouse drags a card at once, a finger after a long press
  (`longPressDelay`); `dragTrigger: BoardDragTrigger.handle` restricts the
  drag to a `BoardDragHandle`. From the keyboard, Space picks a focused
  card up, the arrows move it, Space drops it, Escape cancels; every step
  is announced (`itemSemanticLabel`).
- Per-column rules: `limit`, `canAccept`, and `canMove` on the board. They
  are asked when the target changes, not on every pointer event.
- A `BoardController` moves cards from code and scrolls a column into
  view. On a phone the columns snap one at a time.
- The board needs a bounded width and height; `shrinkWrap: true` makes
  columns as tall as their cards inside a scrolling page.
- Within one list only, use `ReorderableListView` (see
  [lists.md](lists.md)); it is built on the board.

## Chat list

`ChatList<T>` is a lazily built, reversed list anchored to its newest
message. Give it the messages oldest first, a stable `idOf`, and an
`itemBuilder`:

```dart
typedef Message = ({String id, String text, bool mine});

Widget conversation(List<Message> messages) {
  return ChatList<Message>(
    messages: messages,
    idOf: (message) => message.id,
    directionOf: (message) => message.mine
        ? ChatBubbleDirection.outgoing
        : ChatBubbleDirection.incoming,
    sameGroup: (a, b) => a.mine == b.mine,
    itemBuilder: (context, item) => ChatBubble(
      direction: item.message.mine
          ? ChatBubbleDirection.outgoing
          : ChatBubbleDirection.incoming,
      showTail: item.isLastInGroup,
      child: Text(item.message.text),
    ),
  );
}
```

- What is added, removed or resized is animated: a new message opens its
  height while it fades and grows from its tail's corner.
- At the end, new and growing content pushes the rest up; once the reader
  has scrolled back, what they are reading holds still and a jump-to-latest
  button appears (`showJumpToLatest`).
- `sameGroup` sets a run of one sender tighter, with one tail
  (`item.isFirstInGroup`, `item.isLastInGroup`); `onStartReached` is the
  place to load older messages.
- `ChatListController.scrollToEnd()` jumps to the newest message.
- `ChatBubble` aligns itself to its side, wraps at a fraction of the width
  and follows its content's size on a spring. `TypingIndicator` is the
  three dots that go in one while a reply is pending.

## Streaming text

`StreamingText` reveals text that is still arriving at an even pace, each
piece fading in, instead of popping in a chunk at a time:

```dart
// A string that keeps getting longer: rebuild with more of it.
const growing = StreamingText('The reply so far', streaming: true);

// A stream of chunks.
final streamed = StreamingText.stream(Stream.fromIterable(['Hel', 'lo']));

// A controller: append(chunk) or addStream(stream), then complete().
final controller = StreamingTextController();
final driven = StreamingText.controller(controller);
```

- `placeholder` shows until the first text arrives (a `TypingIndicator`).
- Lines already showing never re-break as more text arrives; when the text
  is complete and revealed it becomes a plain, selectable `Text`.
- The caret breathes while more text is expected, so in a widget test
  `pumpAndSettle` waits until `streaming` is false.

See also: [board.md](../components/board.md),
[chat-list.md](../components/chat-list.md),
[chat-bubble.md](../components/chat-bubble.md),
[streaming-text.md](../components/streaming-text.md).
