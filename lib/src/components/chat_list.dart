import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:una/src/components/chat_bubble.dart';
import 'package:una/src/components/icon_button.dart';
import 'package:una/src/components/indicator_badge.dart';
import 'package:una/src/icons/phosphor_icon.dart';
import 'package:una/src/icons/phosphor_icons_regular.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/motion.dart';
import 'package:una/src/theme/theme.dart';
import 'package:una/src/utils/entrance.dart';
import 'package:una/src/utils/spring.dart';

/// Which edge a conversation shorter than its viewport rests against.
enum ChatListAlignment {
  /// Under the top edge, like a page: a new message appears below the
  /// last, and nothing moves until the viewport is full.
  top,

  /// Against the bottom edge, beside the composer, like a phone's
  /// messaging app: every new message pushes the earlier ones up.
  bottom,
}

/// One message of a [ChatList], as its `itemBuilder` sees it.
@immutable
class ChatListItem<T> {
  /// Creates the description of one message.
  const ChatListItem({
    required this.message,
    required this.index,
    this.previous,
    this.next,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.isLeaving = false,
  });

  /// The message to build.
  final T message;

  /// Its position in `ChatList.messages`. For a message that [isLeaving],
  /// the position it had.
  final int index;

  /// The message before it — the older one — or null for the first.
  final T? previous;

  /// The message after it — the newer one — or null for the last.
  final T? next;

  /// Whether this message starts a run, by `ChatList.sameGroup`. Always
  /// true without one.
  final bool isFirstInGroup;

  /// Whether this message ends a run: the one that shows the bubble's tail
  /// and the sender's avatar. Always true without a `ChatList.sameGroup`.
  final bool isLastInGroup;

  /// Whether the message has been removed from `ChatList.messages` and is
  /// only still built while it animates out.
  final bool isLeaving;
}

/// Follows and steers a [ChatList] from outside it: whether the newest
/// message is in view, how many arrived while it was not, and a way back.
///
/// ```dart
/// final chat = ChatListController();
///
/// ValueListenableBuilder(
///   valueListenable: chat.unseenCount,
///   builder: (context, count, _) => count == 0
///       ? const SizedBox.shrink()
///       : Button(onPressed: chat.scrollToEnd, child: Text('$count new')),
/// )
/// ```
///
/// Dispose it when it is no longer needed.
class ChatListController {
  final _atEnd = ValueNotifier<bool>(true);
  final _unseenCount = ValueNotifier<int>(0);
  _ChatListState<Object?>? _state;

  /// Whether the list rests on its newest message — and so follows new
  /// content as it arrives or grows.
  ///
  /// False once the reader has scrolled further back than the theme's
  /// `followDistance`; from then on the list holds what they are reading
  /// still instead.
  ValueListenable<bool> get atEnd => _atEnd;

  /// How many messages have been added at the end since the reader
  /// scrolled away from it. Back to zero when they return.
  ValueListenable<int> get unseenCount => _unseenCount;

  /// Scrolls to the newest message. With [animate] false, or with reduced
  /// motion, it jumps.
  ///
  /// From far away the list first jumps to within a screen and a half of
  /// the end, so the scroll is short however long the conversation is.
  Future<void> scrollToEnd({bool animate = true}) =>
      _state?._scrollToEnd(animate: animate) ?? Future<void>.value();

  /// Releases the listenables.
  void dispose() {
    _atEnd.dispose();
    _unseenCount.dispose();
  }
}

/// Builds the "jump to latest" control of a [ChatList].
///
/// [unseenCount] is the number of messages that arrived while the reader
/// was scrolled away; [onPressed] scrolls to the newest.
typedef ChatListJumpBuilder = Widget Function(
  BuildContext context,
  int unseenCount,
  VoidCallback onPressed,
);

/// A conversation: a lazily built, scrolling list of messages that is
/// anchored to its newest one, and that moves when it changes.
///
/// The list is controlled — the parent owns [messages], oldest first — and
/// generic over the message type; [idOf] gives each a stable identity and
/// [itemBuilder] turns one into a widget, usually a `ChatBubble`.
///
/// ```dart
/// ChatList<Message>(
///   messages: thread,
///   idOf: (message) => message.id,
///   directionOf: (message) => message.mine
///       ? ChatBubbleDirection.outgoing
///       : ChatBubbleDirection.incoming,
///   sameGroup: (a, b) => a.sender == b.sender,
///   itemBuilder: (context, item) => ChatBubble(
///     direction: item.message.mine
///         ? ChatBubbleDirection.outgoing
///         : ChatBubbleDirection.incoming,
///     showTail: item.isLastInGroup,
///     child: Text(item.message.text),
///   ),
/// )
/// ```
///
/// What it does when the list changes:
///
/// * **A message added** opens its height on a spring, so the ones above
///   it glide up rather than jump, while it fades in and grows out of the
///   corner its tail is in — [directionOf] says which — an incoming one
///   also travelling in from its side. Several added at once follow each
///   other a moment apart. Older messages added at the *start* (a page of
///   history) appear in place without moving what is in view.
/// * **A message removed** closes up the same way and is built, with
///   `ChatListItem.isLeaving` set, until it is gone.
/// * **A message that changes height** — streaming text reaching a new
///   line, an edit — moves its neighbours as its own box moves. A
///   `ChatBubble` follows its content on a spring; wrap anything else that
///   appears (a row of reactions) in a `SpringSize`.
///
/// And where it scrolls to:
///
/// * While the reader is at the end, or within the theme's
///   `followDistance` of it, the list **follows**: new and growing content
///   pushes the rest up and the end stays in view, frame by frame.
/// * Once they have scrolled back it **holds still** instead: whatever is
///   added, removed or resized below keeps what they are reading exactly
///   where it is. [ChatListController.unseenCount] counts what arrived, and
///   a small button offers the way back (see [showJumpToLatest]).
///
/// Give the room a floating composer and the keyboard take as bottom
/// [padding]; the list keeps its end above it.
///
/// With reduced motion a new message fades in without moving anything, and
/// with motion switched off it simply appears. The list must be given a
/// bounded height.
///
/// See also:
///
///  * `StreamingText`, for a message that arrives a piece at a time.
///  * `TypingIndicator`, which goes in a bubble while someone is typing.
class ChatList<T> extends StatefulWidget {
  /// Creates a list of [messages].
  const ChatList({
    required this.messages,
    required this.idOf,
    required this.itemBuilder,
    this.directionOf,
    this.sameGroup,
    this.separatorBuilder,
    this.header,
    this.footer,
    this.controller,
    this.scrollController,
    this.padding,
    this.spacing,
    this.groupSpacing,
    this.alignment = ChatListAlignment.bottom,
    this.physics,
    this.keyboardDismissBehavior,
    this.onStartReached,
    this.showJumpToLatest = true,
    this.jumpToLatestBuilder,
    this.jumpToLatestLabel = 'Jump to latest',
    super.key,
  });

  /// The conversation, oldest message first.
  final List<T> messages;

  /// The identity of a message: what tells the list that a message in the
  /// next build is the same one, moved or changed. It must be unique in
  /// [messages] and have a stable `==`.
  final Object Function(T message) idOf;

  /// Builds a message. Called lazily, for the messages near the viewport.
  final Widget Function(BuildContext context, ChatListItem<T> item) itemBuilder;

  /// Which side a message is on, which decides how it arrives: from the
  /// corner its tail is in. Null — the callback, or its result — is a
  /// message with no side, a notice in the middle, which fades in place.
  final ChatBubbleDirection? Function(T message)? directionOf;

  /// Whether two consecutive messages belong to one run: the same sender,
  /// close together. A run is set tighter (the theme's `groupSpacing`), and
  /// `ChatListItem.isLastInGroup` tells the builder which of its messages
  /// carries the tail and the avatar.
  final bool Function(T previous, T next)? sameGroup;

  /// Builds what goes above a message, between it and the one before: a
  /// date, "New messages". `previous` is null for the first message.
  /// Return null for nothing.
  final Widget? Function(BuildContext context, T? previous, T message)?
  separatorBuilder;

  /// What goes above the oldest message, scrolling with it: a spinner
  /// while more history loads, the start of the conversation.
  final Widget? header;

  /// What goes below the newest message, scrolling with it: "Omar is
  /// typing". It arrives and leaves like a message.
  final Widget? footer;

  /// Reports whether the end is in view and scrolls back to it.
  final ChatListController? controller;

  /// The scroll controller. The list is reversed, as a chat is: offset
  /// zero is the newest message.
  final ScrollController? scrollController;

  /// The padding around the messages, inside the scroll view. Defaults to
  /// the theme's.
  final EdgeInsetsGeometry? padding;

  /// The gap between two messages that are not in one run. Defaults to the
  /// theme's.
  final double? spacing;

  /// The gap between two messages of one run. Defaults to the theme's.
  final double? groupSpacing;

  /// Which edge a conversation shorter than the viewport rests against.
  final ChatListAlignment alignment;

  /// The scroll physics. Defaults to the ambient scroll behaviour's.
  final ScrollPhysics? physics;

  /// See `ScrollView.keyboardDismissBehavior`.
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;

  /// Called when the reader comes near the oldest message, once for each
  /// length of [messages]: the moment to load an earlier page and add it to
  /// the start.
  final VoidCallback? onStartReached;

  /// Whether a button that scrolls back to the newest message appears while
  /// the reader is away from it.
  final bool showJumpToLatest;

  /// Builds that button, in place of the default round one with a count.
  final ChatListJumpBuilder? jumpToLatestBuilder;

  /// What assistive technology calls the default button.
  final String jumpToLatestLabel;

  @override
  State<ChatList<T>> createState() => _ChatListState<T>();
}

class _Entry<T> {
  _Entry(this.id, this.message);

  final Object id;
  T message;
  bool leaving = false;

  /// What the builder was last given, for when the message is leaving.
  ChatListItem<T>? item;
}

/// The slots that are not messages.
enum _Slot { header, footer }

/// What the list's state shares with its render sliver and its items.
class _ChatScope {
  /// Whether the sliver keeps what is in view still when something below
  /// it changes size, rather than letting it push the view up.
  bool holdsStill = false;

  /// Whether the list rests on its newest message.
  bool following = true;

  /// How far the view has been pushed from the end while it was held still
  /// with a finger on it, although the list is following. Once the finger
  /// lifts, that distance is not the reader having scrolled away.
  double pushed = 0;

  /// The ids that are being added in this frame, and their place in line.
  final entering = <Object, int>{};

  /// The ids whose items are built.
  final mounted = <Object>{};

  late void Function(Object id) onGone;
  late void Function(Object id) onDisposed;
}

class _ChatListState<T> extends State<ChatList<T>> {
  final _scope = _ChatScope();
  final _entries = <_Entry<T>>[];
  final _present = <Object, int>{};
  final _position = <Object, int>{};
  final _showJump = ValueNotifier<bool>(false);

  ScrollController? _ownScroll;
  ChatListController? _ownController;

  bool _following = true;
  bool _userScrolling = false;
  bool _settling = false;
  int? _startReachedAt;

  // The footer is kept while it leaves.
  Widget? _footer;
  bool _footerLeaving = false;

  /// More messages than this at once are a page loading, not an arrival.
  static const _maxAnimated = 6;

  ScrollController get _scroll =>
      widget.scrollController ?? (_ownScroll ??= ScrollController());

  ChatListController get _controller =>
      widget.controller ?? (_ownController ??= ChatListController());

  @override
  void initState() {
    super.initState();
    _scope
      ..onGone = _remove
      ..onDisposed = _itemDisposed;
    for (final message in widget.messages) {
      _entries.add(_Entry(widget.idOf(message), message));
    }
    _index();
    _footer = widget.footer;
    _controller._state = this;
  }

  @override
  void didUpdateWidget(ChatList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _ownController)?._state = null;
      _controller._state = this;
      _notify(() => _controller._atEnd.value = _following);
    }
    if (widget.scrollController != oldWidget.scrollController &&
        widget.scrollController != null) {
      _ownScroll?.dispose();
      _ownScroll = null;
    }
    _reconcile();
    _reconcileFooter();
  }

  @override
  void dispose() {
    if (_controller._state == this) _controller._state = null;
    _ownController?.dispose();
    _ownScroll?.dispose();
    _showJump.dispose();
    super.dispose();
  }

  /// Maps each entry to its place, and each message that is not leaving
  /// to its place among the messages.
  void _index() {
    _present.clear();
    _position.clear();
    var index = 0;
    for (final (position, entry) in _entries.indexed) {
      _position[entry.id] = position;
      if (!entry.leaving) _present[entry.id] = index++;
    }
  }

  /// Merges the new messages into the entries: what is new arrives, what
  /// is gone leaves where it was.
  void _reconcile() {
    final messages = widget.messages;
    final idOf = widget.idOf;

    // Nothing added or removed, which is every frame of a streamed reply.
    if (_sameIds(messages)) {
      var i = 0;
      for (final entry in _entries) {
        if (!entry.leaving) entry.message = messages[i++];
      }
      return;
    }

    final incoming = <Object, int>{
      for (final (index, message) in messages.indexed) idOf(message): index,
    };
    assert(
      incoming.length == messages.length,
      'ChatList: two messages have the same id.',
    );
    final known = <Object, _Entry<T>>{
      for (final entry in _entries) entry.id: entry,
    };
    final hadMessages = _present.isNotEmpty;
    final merged = <_Entry<T>>[];
    final added = <Object>[];
    var next = 0;
    var seenOld = false;
    var appended = 0;

    void take(int index) {
      final message = messages[index];
      final id = idOf(message);
      final old = known[id];
      if (old != null) {
        old
          ..message = message
          ..leaving = false;
        merged.add(old);
      } else {
        merged.add(_Entry(id, message));
        // Before every message there was is a page of history: it is
        // simply there.
        if (seenOld || !hadMessages) added.add(id);
      }
    }

    for (final entry in _entries) {
      final index = incoming[entry.id];
      if (index == null) {
        // Removed. It leaves from where it was if anyone can see it go.
        if (_scope.mounted.contains(entry.id)) {
          entry.leaving = true;
          merged.add(entry);
        }
        continue;
      }
      if (index < next) continue;
      while (next < index) {
        take(next++);
      }
      if (!entry.leaving) seenOld = true;
      take(next++);
    }
    appended = messages.length - next;
    while (next < messages.length) {
      take(next++);
    }

    _entries
      ..clear()
      ..addAll(merged);
    _index();

    // A conversation that was empty and now has many loaded; one that has
    // one, or a few more than before, received them.
    final arrived =
        added.length <= _maxAnimated && (hadMessages || added.length == 1);
    if (arrived) {
      final theme = Theme.of(context).chatListTheme;
      final steps = theme.maxStaggerSteps ?? 3;
      for (final (order, id) in added.indexed) {
        _scope.entering[id] = math.min(order, steps);
      }
      _afterFrame(_scope.entering.clear);
    }
    if (appended > 0 || arrived) _contentArrived(appended);
  }

  bool _sameIds(List<T> messages) {
    if (messages.length != _present.length) return false;
    var i = 0;
    for (final entry in _entries) {
      if (entry.leaving) continue;
      if (widget.idOf(messages[i++]) != entry.id) return false;
    }
    return true;
  }

  void _reconcileFooter() {
    final footer = widget.footer;
    if (footer != null) {
      if (_footer == null) _scope.entering[_Slot.footer] = 0;
      _footer = footer;
      _footerLeaving = false;
      _afterFrame(() => _scope.entering.remove(_Slot.footer));
    } else if (_footer != null && !_footerLeaving) {
      if (_scope.mounted.contains(_Slot.footer)) {
        _footerLeaving = true;
      } else {
        _footer = null;
      }
    }
  }

  void _remove(Object id) {
    if (!mounted) return;
    if (id == _Slot.footer) {
      if (_footerLeaving) {
        setState(() {
          _footer = null;
          _footerLeaving = false;
        });
      }
      return;
    }
    final index = _position[id];
    if (index == null || !_entries[index].leaving) return;
    setState(() {
      _entries.removeAt(index);
      _index();
    });
  }

  /// An item that is scrolled out of the lazy list while it is leaving has
  /// nothing left to animate.
  void _itemDisposed(Object id) {
    final leaving = id == _Slot.footer
        ? _footerLeaving
        : _position[id] != null && _entries[_position[id]!].leaving;
    if (leaving) _afterFrame(() => _remove(id));
  }

  /// Runs [change] now, or after the frame when this one is being built
  /// or laid out: a listener may want to rebuild.
  void _notify(VoidCallback change) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _afterFrame(change);
    } else {
      change();
    }
  }

  void _afterFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback();
    });
  }

  /// New messages at the end: seen if the list is following, counted if
  /// not.
  void _contentArrived(int appended) {
    if (_following) {
      _afterFrame(_settleToEnd);
    } else if (appended > 0) {
      _afterFrame(() {
        _controller._unseenCount.value += appended;
        _updateJump();
      });
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification) {
      _userScrolling = notification.dragDetails != null;
    } else if (notification is ScrollEndNotification) {
      _userScrolling = false;
      _track(notification.metrics);
      if (_following && notification.metrics.pixels > 0) {
        // Let go within reach of the end: rest on it.
        scheduleMicrotask(() {
          if (mounted) _settleToEnd();
        });
      }
      return false;
    }
    _track(notification.metrics);
    return false;
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    if (notification.depth != 0) return false;
    final pixels = notification.metrics.pixels;
    final viewport = notification.metrics.viewportDimension;
    _notify(() => _updateJump(pixels, viewport));
    return false;
  }

  void _track(ScrollMetrics metrics) {
    final theme = Theme.of(context).chatListTheme;
    final following =
        metrics.pixels - _scope.pushed <= (theme.followDistance ?? 48);
    _scope
      ..following = following
      ..holdsStill = !following || _userScrolling;
    if (!following || metrics.pixels <= 0) _scope.pushed = 0;
    if (following != _following) {
      _following = following;
      _notify(() {
        _controller._atEnd.value = _following;
        if (_following) _controller._unseenCount.value = 0;
        _updateJump();
      });
    } else {
      final pixels = metrics.pixels;
      final viewport = metrics.viewportDimension;
      _notify(() => _updateJump(pixels, viewport));
    }

    final onStartReached = widget.onStartReached;
    if (onStartReached != null &&
        metrics.extentAfter < metrics.viewportDimension / 2 &&
        _startReachedAt != widget.messages.length) {
      _startReachedAt = widget.messages.length;
      onStartReached();
    }
  }

  void _updateJump([double? pixels, double? viewport]) {
    final position = _scroll.hasClients ? _scroll.position : null;
    final offset = pixels ?? position?.pixels ?? 0;
    final extent = viewport ?? position?.viewportDimension ?? 0;
    // Further than a glance back, or with something new to see.
    _showJump.value =
        !_following &&
        (_controller._unseenCount.value > 0 || offset > extent * .3);
  }

  /// Brings a list that is following, but not quite at its end, to rest
  /// on it.
  void _settleToEnd() {
    if (!_scroll.hasClients || _settling || _userScrolling) return;
    final position = _scroll.position;
    if (position.pixels <= 0) return;
    final spring = Motion.of(context).smooth;
    if (spring.isInstant) {
      position.jumpTo(0);
      return;
    }
    _settling = true;
    position
        .animateTo(0, duration: spring.settleDuration, curve: spring.curve)
        .whenComplete(() {
          _settling = false;
          _scope.pushed = 0;
        });
  }

  Future<void> _scrollToEnd({required bool animate}) async {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final spring = Motion.of(context).smooth;
    if (!animate || spring.isInstant) {
      position.jumpTo(0);
      return;
    }
    final near = position.viewportDimension * 1.5;
    if (position.pixels > near) position.jumpTo(near);
    _settling = true;
    await position
        .animateTo(0, duration: spring.settleDuration, curve: spring.curve)
        .whenComplete(() => _settling = false);
  }

  ChatListItem<T> _describe(int entryIndex) {
    final entry = _entries[entryIndex];
    if (entry.leaving && entry.item != null) {
      final last = entry.item!;
      return ChatListItem<T>(
        message: last.message,
        index: last.index,
        previous: last.previous,
        next: last.next,
        isFirstInGroup: last.isFirstInGroup,
        isLastInGroup: last.isLastInGroup,
        isLeaving: true,
      );
    }
    _Entry<T>? previous;
    for (var i = entryIndex - 1; i >= 0; i--) {
      if (!_entries[i].leaving) {
        previous = _entries[i];
        break;
      }
    }
    _Entry<T>? next;
    for (var i = entryIndex + 1; i < _entries.length; i++) {
      if (!_entries[i].leaving) {
        next = _entries[i];
        break;
      }
    }
    final sameGroup = widget.sameGroup;
    return entry.item = ChatListItem<T>(
      message: entry.message,
      index: _present[entry.id] ?? 0,
      previous: previous?.message,
      next: next?.message,
      isFirstInGroup:
          previous == null ||
          sameGroup == null ||
          !sameGroup(previous.message, entry.message),
      isLastInGroup:
          next == null ||
          sameGroup == null ||
          !sameGroup(entry.message, next.message),
      isLeaving: entry.leaving,
    );
  }

  Widget _buildEntry(BuildContext context, int entryIndex) {
    final theme = Theme.of(context).chatListTheme;
    final entry = _entries[entryIndex];
    final item = _describe(entryIndex);
    final first = item.previous == null;
    final separator = widget.separatorBuilder?.call(
      context,
      item.previous,
      item.message,
    );
    final spacing = widget.spacing ?? theme.spacing ?? 12;
    final gap = item.isFirstInGroup
        ? spacing
        : widget.groupSpacing ?? theme.groupSpacing ?? 4;
    final message = widget.itemBuilder(context, item);
    final direction = widget.directionOf?.call(item.message);

    var content = message;
    if (separator != null || !first || widget.header != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!first || widget.header != null)
            SizedBox(height: separator == null ? gap : spacing),
          if (separator != null) ...[separator, SizedBox(height: spacing)],
          message,
        ],
      );
    }
    return _ChatListTransition(
      key: ValueKey<Object>(entry.id),
      id: entry.id,
      scope: _scope,
      leaving: entry.leaving,
      // Nothing is below the newest message for it to be drawn over.
      newest: entryIndex == _entries.length - 1 && _footer == null,
      direction: direction,
      child: content,
    );
  }

  int get _childCount =>
      _entries.length +
      (_footer == null ? 0 : 1) +
      (widget.header == null ? 0 : 1);

  /// The sliver is reversed: its first child is the newest thing.
  Widget? _buildChild(BuildContext context, int index) {
    var i = index;
    final footer = _footer;
    if (footer != null) {
      if (i == 0) {
        final theme = Theme.of(context).chatListTheme;
        return _ChatListTransition(
          key: const ValueKey<Object>(_Slot.footer),
          id: _Slot.footer,
          scope: _scope,
          leaving: _footerLeaving,
          newest: true,
          direction: ChatBubbleDirection.incoming,
          child: Padding(
            padding: EdgeInsets.only(
              top: _entries.isEmpty && widget.header == null
                  ? 0
                  : widget.spacing ?? theme.spacing ?? 12,
            ),
            child: footer,
          ),
        );
      }
      i--;
    }
    if (i < _entries.length) {
      return _buildEntry(context, _entries.length - 1 - i);
    }
    if (i == _entries.length && widget.header != null) {
      return KeyedSubtree(
        key: const ValueKey<Object>(_Slot.header),
        child: widget.header!,
      );
    }
    return null;
  }

  int? _findChild(Key key) {
    if (key is! ValueKey<Object>) return null;
    final id = key.value;
    final offset = _footer == null ? 0 : 1;
    if (id == _Slot.footer) return _footer == null ? null : 0;
    if (id == _Slot.header) {
      return widget.header == null ? null : offset + _entries.length;
    }
    final index = _position[id];
    return index == null ? null : offset + _entries.length - 1 - index;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).chatListTheme;
    final direction = Directionality.of(context);
    final padding =
        (widget.padding ?? theme.padding ?? const EdgeInsets.all(12)).resolve(
          direction,
        );

    Widget list = CustomScrollView(
      controller: _scroll,
      reverse: true,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: _ChatSliverList(
            scope: _scope,
            alignToTop: widget.alignment == ChatListAlignment.top,
            surroundingExtent: padding.vertical,
            delegate: SliverChildBuilderDelegate(
              _buildChild,
              childCount: _childCount,
              findChildIndexCallback: _findChild,
            ),
          ),
        ),
      ],
    );
    list = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      // Holding the view still moves the offset without a scroll; the
      // button has to hear of that too.
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: _onMetrics,
        child: list,
      ),
    );
    if (!widget.showJumpToLatest) return list;

    final controller = _controller;
    void jump() => controller.scrollToEnd();
    return Stack(
      fit: StackFit.passthrough,
      children: [
        list,
        Positioned(
          left: padding.left,
          right: padding.right,
          bottom: padding.bottom + (theme.jumpToLatestMargin ?? 8),
          child: Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: _showJump,
              builder: (context, show, child) => Entrance(
                visible: show,
                appear: false,
                origin: Alignment.bottomCenter,
                child: child!,
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: controller.unseenCount,
                builder: (context, unseen, _) =>
                    widget.jumpToLatestBuilder?.call(context, unseen, jump) ??
                    IndicatorBadge(
                      count: unseen,
                      visible: unseen > 0,
                      child: IconButton.outline(
                        icon: const PhosphorIcon(
                          PhosphorIconsRegular.arrowDown,
                        ),
                        semanticLabel: widget.jumpToLatestLabel,
                        // Opaque and lifted: the messages scroll under it.
                        style: ButtonTheme(
                          backgroundColor: Theme.of(context).colorScheme.card,
                          hoverBackgroundColor: Theme.of(
                            context,
                          ).colorScheme.card,
                          shadows: Theme.of(context).cardTheme.shadows,
                        ),
                        onPressed: jump,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A message's arrival and departure: its height opening or closing on a
/// spring while it fades and grows from the corner its tail is in.
class _ChatListTransition extends StatefulWidget {
  const _ChatListTransition({
    required this.id,
    required this.scope,
    required this.leaving,
    required this.newest,
    required this.direction,
    required this.child,
    super.key,
  });

  final Object id;
  final _ChatScope scope;
  final bool leaving;

  /// Whether nothing is below it. Anything else is clipped to its opening
  /// height so that it is never drawn over the message under it.
  final bool newest;
  final ChatBubbleDirection? direction;
  final Widget child;

  @override
  State<_ChatListTransition> createState() => _ChatListTransitionState();
}

class _ChatListTransitionState extends State<_ChatListTransition>
    with SingleTickerProviderStateMixin {
  late final int? _order = widget.scope.entering.remove(widget.id);

  // 0 is not there; 1 is in place.
  late final _presence = SpringController(
    vsync: this,
    value: _order == null ? 1 : 0,
  );
  Timer? _delay;
  bool _started = false;

  // With reduced motion the height does not move and the presence is only
  // a fade.
  bool _fadeOnly = false;

  @override
  void initState() {
    super.initState();
    widget.scope.mounted.add(widget.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final order = _order;
    if (order == null) return;
    final motion = Motion.of(context);
    final theme = Theme.of(context).chatListTheme;
    final stagger = theme.stagger ?? motion.fast ~/ 3;
    final wait = stagger * order;
    if (wait <= Duration.zero) {
      _run();
    } else {
      _delay = Timer(wait, _run);
    }
  }

  @override
  void didUpdateWidget(_ChatListTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.leaving != oldWidget.leaving) {
      _delay?.cancel();
      _run();
    }
  }

  void _run() {
    if (!mounted) return;
    final motion = Motion.of(context);
    final theme = Theme.of(context).chatListTheme;
    _fadeOnly = motion.reduced;
    final enter = motion.reduced
        ? MotionSpring(duration: motion.fast)
        : theme.enterSpring ?? motion.snappy.copyWith(bounce: 0);
    if (!widget.leaving) {
      _presence.animateTo(1, spring: enter);
      return;
    }
    final exit = motion.reduced
        ? enter
        : theme.exitSpring ?? enter.scaled(2 / 3);
    final id = widget.id;
    final scope = widget.scope;
    _presence.animateTo(0, spring: exit).whenComplete(() {
      if (mounted && widget.leaving) scope.onGone(id);
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _presence.dispose();
    widget.scope.mounted.remove(widget.id);
    widget.scope.onDisposed(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = Motion.of(context);
    final theme = Theme.of(context).chatListTheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final direction = widget.direction;
    final still = motion.reduced || _fadeOnly;
    final fromScale = still
        ? 1.0
        : theme.enterScale ?? 1 - (1 - motion.overlayScale) * 2;
    // Only a received message comes in from the side; a sent one rises.
    final travel = still || direction != ChatBubbleDirection.incoming
        ? 0.0
        : (theme.enterTravel ?? motion.overlayTravel * 2) * (rtl ? 1 : -1);
    final origin = switch (direction) {
      ChatBubbleDirection.outgoing => AlignmentDirectional.bottomEnd,
      ChatBubbleDirection.incoming => AlignmentDirectional.bottomStart,
      null => AlignmentDirectional.bottomCenter,
    }.resolve(Directionality.of(context));

    // The same widgets whether it is moving or not, so the message keeps
    // its state; at rest each of them paints its child as it is.
    return AnimatedBuilder(
      animation: _presence.animation,
      builder: (context, child) {
        final p = _presence.value;
        final t = p.clamp(0.0, 1.0);
        final moving = t < 1;
        return IgnorePointer(
          ignoring: widget.leaving,
          child: ClipRect(
            clipBehavior: moving && !still && !widget.newest
                ? Clip.hardEdge
                : Clip.none,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: still ? 1 : t,
              child: SizedBox(
                width: double.infinity,
                child: Opacity(
                  // Readable well before it has settled.
                  opacity: still ? t : (t / .6).clamp(0.0, 1.0),
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translateByDouble(travel * (1 - t), 0, 0, 1)
                      ..scaleByDouble(
                        fromScale + (1 - fromScale) * p,
                        fromScale + (1 - fromScale) * p,
                        1,
                        1,
                      ),
                    alignment: origin,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _ChatSliverList extends SliverMultiBoxAdaptorWidget {
  const _ChatSliverList({
    required super.delegate,
    required this.scope,
    required this.alignToTop,
    required this.surroundingExtent,
  });

  final _ChatScope scope;
  final bool alignToTop;

  /// The padding before and after the sliver, which is not the sliver's
  /// to fill.
  final double surroundingExtent;

  @override
  SliverMultiBoxAdaptorElement createElement() =>
      SliverMultiBoxAdaptorElement(this, replaceMovedChildren: true);

  @override
  _RenderChatSliverList createRenderObject(BuildContext context) =>
      _RenderChatSliverList(
        childManager: context as SliverMultiBoxAdaptorElement,
        scope: scope,
        alignToTop: alignToTop,
        surroundingExtent: surroundingExtent,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderChatSliverList renderObject,
  ) {
    renderObject
      ..scope = scope
      ..alignToTop = alignToTop
      ..surroundingExtent = surroundingExtent;
  }
}

/// A sliver list for a reversed viewport that does two things a plain one
/// does not.
///
/// **It can hold the view still.** In a reversed list everything is
/// measured from the newest message, so a message arriving or growing
/// below what the reader is looking at would push it up the screen. While
/// the scope says to hold still, the list remembers where the topmost
/// child in view is and, when a layout moves it, asks the viewport to
/// correct the scroll offset by the same amount — within the same layout,
/// so no frame shows the jump. It is what browsers call scroll anchoring.
///
/// **It can rest a short conversation against the top.** A reversed list
/// that does not fill its viewport sits at the bottom. With [alignToTop]
/// the sliver claims the rest of the viewport and paints its children that
/// much higher.
class _RenderChatSliverList extends RenderSliverList {
  _RenderChatSliverList({
    required super.childManager,
    required this.scope,
    required bool alignToTop,
    required double surroundingExtent,
  }) : _alignToTop = alignToTop,
       _surroundingExtent = surroundingExtent;

  _ChatScope scope;

  bool get alignToTop => _alignToTop;
  bool _alignToTop;
  set alignToTop(bool value) {
    if (value == _alignToTop) return;
    _alignToTop = value;
    markNeedsLayout();
  }

  double get surroundingExtent => _surroundingExtent;
  double _surroundingExtent;
  set surroundingExtent(double value) {
    if (value == _surroundingExtent) return;
    _surroundingExtent = value;
    markNeedsLayout();
  }

  RenderBox? _anchor;
  double _anchorEdge = 0;

  /// How far above their place the children are painted, to rest a short
  /// list against the top.
  double _lift = 0;

  bool _isLaidOutChild(RenderBox child) {
    if (child.parent != this) return false;
    final data = child.parentData! as SliverMultiBoxAdaptorParentData;
    return !data.keptAlive && data.layoutOffset != null;
  }

  @override
  void performLayout() {
    final constraints = this.constraints;
    super.performLayout();
    if (!scope.holdsStill &&
        constraints.scrollOffset < precisionErrorTolerance) {
      // A lazy list only guesses how tall the children it has not built
      // are, and when it reaches its first child and finds the guess was
      // wrong it moves the scroll offset rather than what is on screen.
      // At the end of a chat that is backwards: the newest message belongs
      // at the edge. So the correction is not passed on; the list is laid
      // out again, one more child at a time, until it starts at its start.
      var passes = 0;
      while (geometry!.scrollOffsetCorrection != null && passes++ < 100) {
        super.performLayout();
      }
    }
    final laidOut = geometry!;
    // The list itself asked for a correction and will be laid out again,
    // with its children somewhere else: the edge remembered is no use.
    if (laidOut.scrollOffsetCorrection != null) {
      _anchor = null;
      return;
    }

    final anchor = _anchor;
    if (scope.holdsStill && anchor != null && _isLaidOutChild(anchor)) {
      final edge = _edgeOf(anchor);
      // Never past the newest message.
      final delta = math.max(edge - _anchorEdge, -constraints.scrollOffset);
      _anchorEdge = edge;
      if (delta.abs() > precisionErrorTolerance) {
        if (scope.following) scope.pushed += delta;
        geometry = SliverGeometry(scrollOffsetCorrection: delta);
        return;
      }
    }
    _pickAnchor();

    _lift = 0;
    if (!_alignToTop || firstChild == null) return;
    final count = childManager.childCount;
    final whole =
        indexOf(firstChild!) == 0 &&
        indexOf(lastChild!) == count - 1 &&
        constraints.scrollOffset == 0;
    final room = constraints.viewportMainAxisExtent - _surroundingExtent;
    if (!whole || laidOut.scrollExtent >= room) return;
    _lift = room - laidOut.scrollExtent;
    geometry = SliverGeometry(
      scrollExtent: room,
      paintExtent: math.min(room, constraints.remainingPaintExtent),
      maxPaintExtent: room,
      cacheExtent: math.min(room, constraints.remainingCacheExtent),
      hasVisualOverflow: laidOut.hasVisualOverflow,
    );
  }

  /// The edge of [child] that is taken to stay where it is when the child
  /// itself changes height.
  ///
  /// A message gains and loses things at its top — the gap to the one
  /// before it, a date — so it is its bottom that is held. The newest is
  /// the exception: a reply that is still arriving grows at its end, and
  /// it is its top the reader is looking at.
  double _edgeOf(RenderBox child) {
    final offset = childScrollOffset(child)!;
    return _anchorIsNewest ? offset + paintExtentOf(child) : offset;
  }

  bool _anchorIsNewest = false;

  /// The topmost child in view: the last one that starts before the far
  /// edge of the viewport.
  void _pickAnchor() {
    _anchor = null;
    final end = constraints.scrollOffset + constraints.remainingPaintExtent;
    var child = lastChild;
    while (child != null) {
      final offset = childScrollOffset(child);
      if (offset != null && offset < end) {
        _anchor = child;
        _anchorIsNewest = indexOf(child) == 0;
        _anchorEdge = _edgeOf(child);
        return;
      }
      child = childBefore(child);
    }
  }

  @override
  double childMainAxisPosition(RenderBox child) =>
      super.childMainAxisPosition(child) + _lift;
}
