import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

const _frame = Duration(milliseconds: 16);

@immutable
class _Message {
  const _Message(this.id, this.text, {this.mine = false, this.height});

  final int id;
  final String text;
  final bool mine;

  /// A box of exactly this height instead of a bubble, where a test needs
  /// to know the layout to the pixel.
  final double? height;

  _Message copyWith({String? text, double? height}) => _Message(
    id,
    text ?? this.text,
    mine: mine,
    height: height ?? this.height,
  );
}

List<_Message> _thread(int count, {double? height}) => [
  for (var i = 0; i < count; i++)
    _Message(i, 'message $i', mine: i.isOdd, height: height),
];

/// A [ChatList] over a list the test replaces.
class _Host extends StatefulWidget {
  const _Host({
    required this.messages,
    this.controller,
    this.alignment = ChatListAlignment.bottom,
    this.padding = EdgeInsets.zero,
    this.sameGroup = false,
    this.separators = false,
    this.onStartReached,
    this.onBuild,
    super.key,
  });

  final List<_Message> messages;
  final ChatListController? controller;
  final ChatListAlignment alignment;
  final EdgeInsets padding;
  final bool sameGroup;
  final bool separators;
  final VoidCallback? onStartReached;
  final void Function(ChatListItem<_Message> item)? onBuild;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<_Message> messages = widget.messages;
  late EdgeInsets padding = widget.padding;
  Widget? footer;
  Widget? header;

  void update(VoidCallback change) => setState(change);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 320,
        height: 400,
        child: ChatList<_Message>(
          messages: messages,
          idOf: (message) => message.id,
          controller: widget.controller,
          alignment: widget.alignment,
          padding: padding,
          spacing: 10,
          groupSpacing: 2,
          header: header,
          footer: footer,
          onStartReached: widget.onStartReached,
          directionOf: (message) => message.mine
              ? ChatBubbleDirection.outgoing
              : ChatBubbleDirection.incoming,
          sameGroup: widget.sameGroup ? (a, b) => a.mine == b.mine : null,
          separatorBuilder: widget.separators
              ? (context, previous, message) => message.id % 4 == 0
                    ? SizedBox(
                        key: ValueKey('separator ${message.id}'),
                        height: 16,
                      )
                    : null
              : null,
          itemBuilder: (context, item) {
            widget.onBuild?.call(item);
            final message = item.message;
            if (message.height case final height?) {
              return SizedBox(
                key: ValueKey('box ${message.id}'),
                height: height,
                child: Text(message.text),
              );
            }
            return ChatBubble(
              direction: message.mine
                  ? ChatBubbleDirection.outgoing
                  : ChatBubbleDirection.incoming,
              showTail: item.isLastInGroup,
              child: Text(message.text),
            );
          },
        ),
      ),
    );
  }
}

_HostState _host(WidgetTester tester) =>
    tester.state<_HostState>(find.byType(_Host));

Finder _box(int id) => find.byKey(ValueKey('box $id'));

/// [_box], also while it has no height yet: a message's first frame, which
/// a sliver — and so a default finder — counts as off stage.
Finder _boxAnywhere(int id) =>
    find.byKey(ValueKey('box $id'), skipOffstage: false);

/// Matches a rectangle to within rounding.
Matcher _near(Rect rect) => within<Rect>(distance: 1e-6, from: rect);

Rect _rect(WidgetTester tester, int id) => tester.getRect(_box(id));

ScrollPosition _position(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable)).position;

/// The opacity the list paints message [id] with.
double _opacity(WidgetTester tester, int id) => tester
    .widget<Opacity>(
      find
          .ancestor(
            of: _boxAnywhere(id),
            matching: find.byType(Opacity, skipOffstage: false),
          )
          .first,
    )
    .opacity;

/// The transform the list paints message [id] through.
Transform _transform(WidgetTester tester, int id) => tester.widget<Transform>(
  find
      .ancestor(
        of: _boxAnywhere(id),
        matching: find.byType(Transform, skipOffstage: false),
      )
      .first,
);

Future<void> _pumpFrames(WidgetTester tester, int frames) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(_frame);
  }
}

void main() {
  group('ChatListTheme', () {
    test('is fed by the variant and compares by value', () {
      final theme = ThemeData().chatListTheme;
      expect(theme.spacing, 12);
      expect(theme.groupSpacing, 4);
      expect(theme.followDistance, 48);
      expect(theme.padding, const EdgeInsets.all(12));
      // The motion knobs are left to be resolved from `Motion.of`.
      expect(theme.enterSpring, isNull);
      expect(theme.stagger, isNull);
      expect(ThemeData().chatListTheme, theme);
      expect(
        ThemeData(
          chatListTheme: const ChatListTheme(followDistance: 120),
        ).chatListTheme.followDistance,
        120,
      );
    });
  });

  group('layout', () {
    testWidgets('builds in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => _Host(key: ValueKey(layout), messages: _thread(30)),
      );
    });

    testWidgets('opens on the newest message, against the bottom', (
      tester,
    ) async {
      await pumpUna(tester, _Host(messages: _thread(40, height: 50)));
      expect(_position(tester).pixels, 0);
      expect(_rect(tester, 39).bottom, 400);
      expect(_rect(tester, 38).bottom, 400 - 50 - 10);
      expect(_box(0), findsNothing);
    });

    testWidgets('builds lazily: a long conversation costs a screenful', (
      tester,
    ) async {
      final built = <int>{};
      await pumpUna(
        tester,
        _Host(
          messages: _thread(600, height: 50),
          onBuild: (item) => built.add(item.message.id),
        ),
      );
      expect(built.length, lessThan(30));
      expect(built, contains(599));
    });

    testWidgets('a short conversation rests against the bottom by default', (
      tester,
    ) async {
      await pumpUna(tester, _Host(messages: _thread(2, height: 50)));
      expect(_rect(tester, 1).bottom, 400);
      expect(_rect(tester, 0).top, 400 - 50 - 10 - 50);
    });

    testWidgets('or against the top, growing downwards', (tester) async {
      await pumpUna(
        tester,
        _Host(
          messages: _thread(2, height: 50),
          alignment: ChatListAlignment.top,
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
        ),
      );
      expect(_rect(tester, 0).top, 20);
      expect(_rect(tester, 1).top, 20 + 50 + 10);
      // A tap lands where the message is drawn.
      await tester.tapAt(_rect(tester, 0).center);
      expect(tester.takeException(), isNull);
      expect(
        tester
            .hitTestOnBinding(_rect(tester, 0).center)
            .path
            .any(
              (entry) => entry.target == tester.renderObject(_box(0)),
            ),
        isTrue,
      );

      // A new message appears under the last; nothing above it moves.
      final before = _rect(tester, 0);
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(2, 'new', height: 50),
        ],
      );
      await tester.pump();
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        expect(_rect(tester, 0), _near(before));
        expect(_rect(tester, 1).top, closeTo(80, 1e-6));
      }
      expect(_rect(tester, 2).top, closeTo(80 + 50 + 10, 1e-6));

      // Once it no longer fits it is an ordinary list, anchored to its end.
      _host(tester).update(
        () => _host(tester).messages = _thread(12, height: 50),
      );
      await tester.pumpAndSettle();
      expect(_rect(tester, 11).bottom, 400 - 30);
      expect(_position(tester).pixels, 0);
    });

    testWidgets('sets runs tighter and tells the builder where they end', (
      tester,
    ) async {
      final items = <int, ChatListItem<_Message>>{};
      // Two of theirs, two of mine, one of theirs.
      const messages = [
        _Message(0, 'a', height: 30),
        _Message(1, 'b', height: 30),
        _Message(2, 'c', mine: true, height: 30),
        _Message(3, 'd', mine: true, height: 30),
        _Message(4, 'e', height: 30),
      ];
      await pumpUna(
        tester,
        _Host(
          messages: messages,
          sameGroup: true,
          onBuild: (item) => items[item.message.id] = item,
        ),
      );
      expect(
        [for (var i = 0; i < 5; i++) items[i]!.isFirstInGroup],
        [
          true,
          false,
          true,
          false,
          true,
        ],
      );
      expect(
        [for (var i = 0; i < 5; i++) items[i]!.isLastInGroup],
        [
          false,
          true,
          false,
          true,
          true,
        ],
      );
      expect(items[0]!.previous, isNull);
      expect(items[2]!.previous, messages[1]);
      expect(items[2]!.next, messages[3]);
      expect(items[4]!.next, isNull);
      expect(items[3]!.index, 3);
      // 2 inside a run, 10 between runs.
      expect(_rect(tester, 1).top - _rect(tester, 0).bottom, 2);
      expect(_rect(tester, 2).top - _rect(tester, 1).bottom, 10);
      expect(_rect(tester, 4).top - _rect(tester, 3).bottom, 10);
    });

    testWidgets('puts separators above the messages they belong to', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(messages: _thread(6, height: 30), separators: true),
      );
      final separator = tester.getRect(
        find.byKey(const ValueKey('separator 4')),
      );
      expect(separator.top - _rect(tester, 3).bottom, 10);
      expect(_rect(tester, 4).top - separator.bottom, 10);
      // The first message's has nothing above it.
      expect(find.byKey(const ValueKey('separator 0')), findsOneWidget);
    });

    testWidgets('shows a header above the oldest and a footer below the '
        'newest', (tester) async {
      await pumpUna(tester, _Host(messages: _thread(3, height: 40)));
      _host(tester).update(() {
        _host(tester)
          ..header = const SizedBox(key: ValueKey('header'), height: 24)
          ..footer = const SizedBox(key: ValueKey('footer'), height: 20);
      });
      await tester.pumpAndSettle();
      final footer = tester.getRect(find.byKey(const ValueKey('footer')));
      final header = tester.getRect(find.byKey(const ValueKey('header')));
      expect(footer.bottom, 400);
      expect(footer.top - _rect(tester, 2).bottom, 10);
      expect(_rect(tester, 0).top - header.bottom, 10);

      // The footer leaves like a message: the end comes down smoothly.
      _host(tester).update(() => _host(tester).footer = null);
      await tester.pump();
      var last = _rect(tester, 2).bottom;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        final bottom = _rect(tester, 2).bottom;
        expect(bottom, greaterThanOrEqualTo(last));
        last = bottom;
      }
      expect(last, 400);
      expect(find.byKey(const ValueKey('footer')), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('the room kept for a composer or the keyboard lifts the end', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(
          messages: _thread(20, height: 50),
          padding: const EdgeInsets.only(bottom: 80),
        ),
      );
      expect(_rect(tester, 19).bottom, 320);
      // The keyboard comes up.
      _host(tester).update(
        () => _host(tester).padding = const EdgeInsets.only(bottom: 280),
      );
      await tester.pump();
      expect(_rect(tester, 19).bottom, 120);
      expect(_position(tester).pixels, 0);
    });

    testWidgets('survives a large text scale and a right-to-left locale', (
      tester,
    ) async {
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
          child: _Host(messages: _thread(12)),
        ),
        textDirection: TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
      // Mine are at the end: the left, here.
      final mine = tester.getRect(
        find.descendant(
          of: find.widgetWithText(ChatBubble, 'message 11'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(mine.left, 0);
    });
  });

  group('a message arriving', () {
    testWidgets('opens its height on a spring: the ones above glide up', (
      tester,
    ) async {
      await pumpUna(tester, _Host(messages: _thread(12, height: 50)));
      final before = _rect(tester, 11);
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(12, 'new', mine: true, height: 60),
        ],
      );
      await tester.pump();
      // Nothing has moved in the frame it was added.
      expect(_rect(tester, 11), before);
      expect(_opacity(tester, 12), 0);

      var lastBottom = before.bottom;
      var lastOpacity = 0.0;
      var largestStep = 0.0;
      var frames = 0;
      while (tester.binding.hasScheduledFrame) {
        await tester.pump(_frame);
        final bottom = _rect(tester, 11).bottom;
        // Up, never back, and never past where it ends.
        expect(bottom, lessThanOrEqualTo(lastBottom + 1e-6));
        expect(bottom, greaterThanOrEqualTo(400 - 60 - 10 - 1e-6));
        if (lastBottom - bottom > largestStep) {
          largestStep = lastBottom - bottom;
        }
        lastBottom = bottom;
        final opacity = _opacity(tester, 12);
        expect(opacity, greaterThanOrEqualTo(lastOpacity));
        lastOpacity = opacity;
        // The list never leaves its end while it follows.
        expect(_position(tester).pixels, 0);
        expect(++frames, lessThan(120));
      }
      expect(frames, greaterThan(8));
      // No frame carries more than a fraction of the way.
      expect(largestStep, lessThan(20));
      // Exactly in place.
      expect(lastOpacity, 1);
      expect(_rect(tester, 12).bottom, 400);
      expect(_rect(tester, 12).height, 60);
      expect(_rect(tester, 11).bottom, 400 - 60 - 10);
    });

    testWidgets('grows out of the corner its tail is in', (tester) async {
      await pumpUna(tester, _Host(messages: _thread(12, height: 50)));

      Future<Matrix4> midway(_Message message) async {
        _host(tester).update(
          () => _host(tester).messages = [..._host(tester).messages, message],
        );
        await tester.pump();
        await _pumpFrames(tester, 4);
        final transform = _transform(tester, message.id);
        await tester.pumpAndSettle();
        expect(_transform(tester, message.id).transform, Matrix4.identity());
        _lastAlignment = transform.alignment!;
        return transform.transform;
      }

      final sent = await midway(
        const _Message(12, 's', mine: true, height: 40),
      );
      expect(_lastAlignment, Alignment.bottomRight);
      expect(sent.entry(0, 0), inExclusiveRange(.85, 1));
      expect(sent.entry(1, 1), sent.entry(0, 0));
      // A sent message rises; it does not slide sideways.
      expect(sent.getTranslation().x, 0);

      final received = await midway(const _Message(13, 'r', height: 40));
      expect(_lastAlignment, Alignment.bottomLeft);
      expect(received.entry(0, 0), inExclusiveRange(.85, 1));
      // A received one comes in from its side.
      expect(received.getTranslation().x, lessThan(0));
    });

    testWidgets('several at once follow each other, a moment apart', (
      tester,
    ) async {
      await pumpUna(tester, _Host(messages: _thread(10, height: 40)));
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          for (var i = 10; i < 15; i++) _Message(i, 'm$i', height: 40),
        ],
      );
      await tester.pump();
      final started = <int, int>{};
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(_frame);
        for (var id = 10; id < 15; id++) {
          if (!started.containsKey(id) && _opacity(tester, id) > 0) {
            started[id] = frame;
          }
        }
      }
      // In order, oldest first…
      expect(started[10], lessThan(started[11]!));
      expect(started[11], lessThan(started[12]!));
      // …and the queue is capped: the last two start together.
      expect(started[13], started[14]);
      expect(started[14]! - started[10]!, lessThan(12));
      await tester.pumpAndSettle();
      expect(_rect(tester, 14).bottom, 400);
    });

    testWidgets('a page of many is simply there', (tester) async {
      await pumpUna(tester, _Host(messages: _thread(4, height: 40)));
      _host(tester).update(
        () => _host(tester).messages = _thread(30, height: 40),
      );
      await tester.pump();
      expect(_rect(tester, 29).bottom, 400);
      expect(_opacity(tester, 29), 1);
      await tester.pump(_frame);
      expect(_rect(tester, 29).bottom, 400);
      await tester.pumpAndSettle();
    });

    testWidgets('the first messages of an empty conversation', (tester) async {
      await pumpUna(tester, const _Host(messages: []));
      // One: it was sent.
      _host(tester).update(
        () => _host(tester).messages = const [_Message(0, 'hi', height: 40)],
      );
      await tester.pump();
      expect(_opacity(tester, 0), 0);
      await tester.pumpAndSettle();
      expect(_rect(tester, 0).bottom, 400);
    });

    testWidgets('settles: nothing is left running', (tester) async {
      await pumpUna(tester, _Host(messages: _thread(8)));
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(8, 'a bubble this time', mine: true),
        ],
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.text('a bubble this time'), findsOneWidget);
    });
  });

  group('following the end', () {
    testWidgets('within reach of the end a new message brings it back', (
      tester,
    ) async {
      final controller = ChatListController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        _Host(messages: _thread(20, height: 50), controller: controller),
      );
      _position(tester).jumpTo(30);
      await tester.pump();
      expect(controller.atEnd.value, isTrue);

      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(20, 'new', height: 50),
        ],
      );
      await tester.pump();
      var last = _position(tester).pixels;
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        expect(_position(tester).pixels, lessThanOrEqualTo(last));
        last = _position(tester).pixels;
      }
      expect(last, 0);
      expect(_rect(tester, 20).bottom, 400);
      expect(controller.unseenCount.value, 0);
      await tester.pumpAndSettle();
    });

    testWidgets('scrolled back, a new message leaves the view exactly where '
        'it is', (tester) async {
      final controller = ChatListController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        _Host(messages: _thread(30, height: 50), controller: controller),
      );
      await tester.drag(find.byType(ChatList<_Message>), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(controller.atEnd.value, isFalse);
      final reading = find.textContaining('message 2').evaluate().first;
      final id = int.parse(
        (reading.widget as Text).data!.split(' ').last,
      );
      final before = _rect(tester, id);
      final offset = _position(tester).pixels;

      for (var added = 30; added < 33; added++) {
        _host(tester).update(
          () => _host(tester).messages = [
            ..._host(tester).messages,
            _Message(added, 'new $added', height: 70),
          ],
        );
        await tester.pump();
        for (var i = 0; i < 30; i++) {
          await tester.pump(_frame);
          // Not a pixel, in any frame of the arrival.
          expect(_rect(tester, id), _near(before));
        }
      }
      expect(controller.unseenCount.value, 3);
      expect(controller.atEnd.value, isFalse);
      // The offset moved instead, by what was added below.
      expect(_position(tester).pixels, greaterThan(offset + 100));
      await tester.pumpAndSettle();
      // And the way back ends on the newest of them.
      unawaited(controller.scrollToEnd(animate: false));
      await tester.pump();
      await tester.pump();
      expect(_position(tester).pixels, 0);
      expect(_rect(tester, 32).bottom, 400);
      expect(_rect(tester, 31).bottom, 400 - 70 - 10);
    });

    testWidgets('the jump button counts what arrived and leads back', (
      tester,
    ) async {
      final controller = ChatListController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        _Host(messages: _thread(30, height: 50), controller: controller),
      );
      final button = find.byType(IconButton);
      // There, but not showing.
      expect(tester.widget<Entrance>(find.byType(Entrance)).visible, isFalse);

      await tester.drag(find.byType(ChatList<_Message>), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(tester.widget<Entrance>(find.byType(Entrance)).visible, isTrue);

      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(30, 'new', height: 50),
          const _Message(31, 'newer', height: 50),
        ],
      );
      await tester.pumpAndSettle();
      expect(controller.unseenCount.value, 2);
      expect(
        find.descendant(
          of: find.byType(IndicatorBadge),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );

      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(_position(tester).pixels, 0);
      expect(_rect(tester, 31).bottom, 400);
      expect(controller.unseenCount.value, 0);
      expect(controller.atEnd.value, isTrue);
      expect(tester.widget<Entrance>(find.byType(Entrance)).visible, isFalse);
    });

    testWidgets('showJumpToLatest: false builds no button, and a builder '
        'replaces it', (tester) async {
      await pumpUna(
        tester,
        SizedBox(
          height: 300,
          child: ChatList<int>(
            messages: const [1, 2, 3],
            idOf: (i) => i,
            showJumpToLatest: false,
            itemBuilder: (context, item) => Text('${item.message}'),
          ),
        ),
      );
      expect(find.byType(IconButton), findsNothing);

      await pumpUna(
        tester,
        SizedBox(
          height: 300,
          child: ChatList<int>(
            messages: const [1, 2, 3],
            idOf: (i) => i,
            jumpToLatestBuilder: (context, unseen, onPressed) =>
                Text('$unseen new'),
            itemBuilder: (context, item) => Text('${item.message}'),
          ),
        ),
      );
      expect(find.text('0 new'), findsOneWidget);
    });

    testWidgets('scrollToEnd is short however far away it starts', (
      tester,
    ) async {
      final controller = ChatListController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        _Host(messages: _thread(400, height: 50), controller: controller),
      );
      _position(tester).jumpTo(9000);
      await tester.pump();
      expect(controller.atEnd.value, isFalse);

      unawaited(controller.scrollToEnd());
      await tester.pump();
      // Within a screen and a half at once, the rest animated.
      expect(_position(tester).pixels, lessThanOrEqualTo(600));
      await tester.pumpAndSettle();
      expect(_position(tester).pixels, 0);
      expect(controller.atEnd.value, isTrue);

      _position(tester).jumpTo(900);
      await tester.pump();
      unawaited(controller.scrollToEnd(animate: false));
      await tester.pump();
      expect(_position(tester).pixels, 0);
    });

    testWidgets('history added at the start does not move the view', (
      tester,
    ) async {
      var reached = 0;
      await pumpUna(
        tester,
        _Host(
          messages: _thread(20, height: 50),
          onStartReached: () => reached++,
        ),
      );
      // At the end.
      final atEnd = _rect(tester, 19);
      _host(tester).update(
        () => _host(tester).messages = [
          for (var i = -10; i < 0; i++) _Message(i, 'old $i', height: 50),
          ..._host(tester).messages,
        ],
      );
      await tester.pump();
      expect(_rect(tester, 19), atEnd);
      expect(tester.binding.hasScheduledFrame, isFalse);

      // And near the start, where the older page is asked for.
      expect(reached, 0);
      // The extent of a lazy list is a guess until its far end is built:
      // the first jump only gets most of the way.
      for (var i = 0; i < 3; i++) {
        _position(tester).jumpTo(_position(tester).maxScrollExtent);
        await tester.pump();
      }
      expect(reached, 1);
      // Whatever is in view up here.
      final id = int.parse(
        (find.textContaining('old ').evaluate().first.widget as Text).data!
            .split(' ')
            .last,
      );
      final reading = _rect(tester, id);
      _host(tester).update(
        () => _host(tester).messages = [
          for (var i = -20; i < -10; i++) _Message(i, 'older $i', height: 50),
          ..._host(tester).messages,
        ],
      );
      await tester.pump();
      expect(_rect(tester, id), _near(reading));
      await tester.pump(_frame);
      expect(_rect(tester, id), _near(reading));
      // Asked once for each length, not on every scroll.
      _position(tester).jumpTo(_position(tester).pixels - 1);
      await tester.pump();
      expect(reached, 1);
      for (var i = 0; i < 3; i++) {
        _position(tester).jumpTo(_position(tester).maxScrollExtent);
        await tester.pump();
      }
      expect(reached, 2);
    });

    testWidgets('a finger on the list keeps it still, even near the end', (
      tester,
    ) async {
      await pumpUna(tester, _Host(messages: _thread(30, height: 50)));
      final gesture = await tester.startGesture(const Offset(160, 200));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      final held = _rect(tester, 28);
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(30, 'new', height: 50),
        ],
      );
      await tester.pump();
      for (var i = 0; i < 30; i++) {
        await tester.pump(_frame);
        expect(_rect(tester, 28), _near(held));
      }
      // Let go, still within reach of the end: it comes to rest on it.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_position(tester).pixels, 0);
      expect(_rect(tester, 30).bottom, 400);
    });
  });

  group('a message leaving or changing', () {
    testWidgets('a removed message closes up smoothly and is then gone', (
      tester,
    ) async {
      final leaving = <int>{};
      await pumpUna(
        tester,
        _Host(
          messages: _thread(12, height: 50),
          onBuild: (item) {
            if (item.isLeaving) leaving.add(item.message.id);
          },
        ),
      );
      final before = _rect(tester, 9).bottom;
      _host(tester).update(
        () => _host(tester).messages = [
          for (final message in _host(tester).messages)
            if (message.id != 10) message,
        ],
      );
      await tester.pump();
      expect(_rect(tester, 9).bottom, before);
      expect(_box(10), findsOneWidget);

      var last = before;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        final bottom = _rect(tester, 9).bottom;
        expect(bottom, greaterThanOrEqualTo(last - 1e-6));
        last = bottom;
        // The newest stays put.
        expect(_rect(tester, 11).bottom, 400);
      }
      expect(leaving, {10});
      expect(_box(10), findsNothing);
      expect(_rect(tester, 9).bottom, _rect(tester, 11).top - 10);
      await tester.pumpAndSettle();
    });

    testWidgets('a message that comes back while leaving turns around', (
      tester,
    ) async {
      final all = _thread(6, height: 50);
      await pumpUna(tester, _Host(messages: all));
      _host(tester).update(
        () => _host(tester).messages = all.sublist(0, 5),
      );
      await tester.pump();
      await _pumpFrames(tester, 3);
      expect(_opacity(tester, 5), lessThan(1));
      _host(tester).update(() => _host(tester).messages = all);
      await tester.pumpAndSettle();
      expect(_opacity(tester, 5), 1);
      expect(_rect(tester, 5).bottom, 400);
    });

    testWidgets('a bubble that grows takes its neighbours with it', (
      tester,
    ) async {
      await pumpUna(tester, _Host(messages: _thread(8)));
      final neighbour = find.widgetWithText(ChatBubble, 'message 6');
      final before = tester.getRect(neighbour);
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages.sublist(0, 7),
          _host(tester).messages[7].copyWith(
            text:
                'edited into something long enough to take three or four '
                'lines of this narrow list, so the bubble has to grow',
          ),
        ],
      );
      await tester.pump();
      expect(tester.getRect(neighbour), before);

      var last = before.top;
      var frames = 0;
      while (tester.binding.hasScheduledFrame) {
        await tester.pump(_frame);
        final top = tester.getRect(neighbour).top;
        expect(top, lessThanOrEqualTo(last + 1e-6));
        last = top;
        expect(_position(tester).pixels, 0);
        expect(++frames, lessThan(120));
      }
      expect(frames, greaterThan(6));
      expect(last, lessThan(before.top - 40));
    });

    testWidgets('scrolled back, a message growing below does not move the '
        'view', (tester) async {
      await pumpUna(
        tester,
        _Host(
          messages: [
            ..._thread(29, height: 50),
            const _Message(29, 'reply', height: 200),
          ],
        ),
      );
      await tester.drag(find.byType(ChatList<_Message>), const Offset(0, 120));
      await tester.pumpAndSettle();
      final held = _rect(tester, 27);
      final top = _rect(tester, 29).top;
      // The newest is partly in view and gets taller, as a streamed reply
      // does, a line at a time.
      for (var height = 222.0; height <= 310; height += 22) {
        _host(tester).update(
          () => _host(tester).messages = [
            ..._host(tester).messages.sublist(0, 29),
            _host(tester).messages[29].copyWith(height: height),
          ],
        );
        await tester.pump();
        expect(_rect(tester, 27), _near(held));
        // It grew downwards, out of view.
        expect(_rect(tester, 29).top, closeTo(top, 1e-6));
      }
      expect(_rect(tester, 29).height, 310);
    });
  });

  group('reduced motion', () {
    testWidgets('a new message fades in without moving anything', (
      tester,
    ) async {
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _Host(messages: _thread(12, height: 50)),
        ),
      );
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(12, 'new', height: 60),
        ],
      );
      await tester.pump();
      // In place in the frame it was added.
      expect(_rect(tester, 12).bottom, 400);
      expect(_rect(tester, 11).bottom, 400 - 60 - 10);
      final opacities = <double>[];
      for (var i = 0; i < 20; i++) {
        await tester.pump(_frame);
        expect(_rect(tester, 11).bottom, 400 - 60 - 10);
        opacities.add(_opacity(tester, 12));
      }
      expect(opacities.first, lessThan(1));
      expect(opacities.last, 1);
      await tester.pumpAndSettle();
    });

    testWidgets('Motion.none: it is simply there', (tester) async {
      await pumpUna(
        tester,
        _Host(messages: _thread(12, height: 50)),
        theme: ThemeData(motion: Motion.none),
      );
      _host(tester).update(
        () => _host(tester).messages = [
          ..._host(tester).messages,
          const _Message(12, 'new', height: 60),
        ],
      );
      await tester.pump();
      expect(_rect(tester, 12).bottom, 400);
      expect(_opacity(tester, 12), 1);

      _host(tester).update(
        () => _host(tester).messages = _thread(12, height: 50),
      );
      await tester.pump();
      await tester.pump();
      expect(_box(12), findsNothing);
      expect(_rect(tester, 11).bottom, 400);
    });
  });

  group('a streamed reply', () {
    testWidgets('grows with its tail pinned to the end of the list', (
      tester,
    ) async {
      final reply = StreamingTextController();
      addTearDown(reply.dispose);
      await pumpUna(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            height: 400,
            child: ChatList<int>(
              messages: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
              idOf: (i) => i,
              padding: EdgeInsets.zero,
              itemBuilder: (context, item) => item.message < 9
                  ? ChatBubble(child: Text('message ${item.message}'))
                  : ChatBubble(
                      key: const ValueKey('reply'),
                      child: StreamingText.controller(
                        reply,
                        placeholder: const TypingIndicator(),
                      ),
                    ),
            ),
          ),
        ),
      );
      final bubble = find
          .descendant(
            of: find.byKey(const ValueKey('reply')),
            matching: find.byType(DecoratedBox),
          )
          .first;
      final above = find.widgetWithText(ChatBubble, 'message 8');
      expect(find.byType(TypingIndicator), findsOneWidget);
      final typing = tester.getRect(bubble);
      expect(typing.bottom, 400);

      var last = typing;
      var lastAbove = tester.getRect(above).top;
      var largestStep = 0.0;
      // Uneven chunks at uneven intervals.
      const chunks = [
        'Here is ',
        'a reply that ',
        'arrives in pieces of rather different sizes, ',
        'some of them long enough to wrap over more than one line at once, ',
        'and',
        ' some short.',
      ];
      const gaps = [3, 9, 2, 14, 5, 20];
      for (final (index, chunk) in chunks.indexed) {
        reply.append(chunk);
        for (var i = 0; i < gaps[index] + 20; i++) {
          await tester.pump(_frame);
          final rect = tester.getRect(bubble);
          // The tail corner — bottom start — never moves…
          expect(rect.bottom, closeTo(400, 1e-6));
          expect(rect.left, typing.left);
          // …and the bubble only grows, a little a frame.
          expect(rect.height, greaterThanOrEqualTo(last.height - 1e-6));
          if (rect.height - last.height > largestStep) {
            largestStep = rect.height - last.height;
          }
          last = rect;
          final top = tester.getRect(above).top;
          expect(top, lessThanOrEqualTo(lastAbove + 1e-6));
          lastAbove = top;
        }
      }
      expect(last.height, greaterThan(typing.height * 3));
      // A new line is not taken in one frame.
      expect(largestStep, lessThan(12));

      reply.complete();
      await tester.pumpAndSettle();
      expect(tester.getRect(bubble).bottom, 400);
      expect(find.byType(TypingIndicator), findsNothing);
    });
  });
}

late AlignmentGeometry _lastAlignment;
