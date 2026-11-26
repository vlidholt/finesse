import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

void main() {
  late List<String> items;
  late List<(int, int)> moves;
  late List<String> log;

  setUp(() {
    items = ['A', 'B', 'C', 'D', 'E'];
    moves = [];
    log = [];
  });

  Widget list({
    bool longPressToDrag = true,
    bool enabled = true,
    bool handles = true,
    bool builder = false,
    bool apply = true,
    int? count,
  }) {
    if (count != null) items = [for (var i = 0; i < count; i++) 'Item $i'];
    return StatefulBuilder(
      builder: (context, setState) {
        void onReorder(int from, int to) {
          moves.add((from, to));
          if (apply) setState(() => items.insert(to, items.removeAt(from)));
        }

        Widget row(String item) => ListTile(
          key: ValueKey(item),
          title: Text(item),
          // Something with state of its own, to see it survive a move.
          leading: _Counter(key: ValueKey('counter $item')),
          trailing: handles ? const ReorderableDragHandle() : null,
        );

        return Center(
          child: SizedBox(
            width: 360,
            height: 400,
            child: builder
                ? ReorderableListView.builder(
                    itemCount: items.length,
                    itemId: (index) => items[index],
                    itemBuilder: (context, index) => row(items[index]),
                    onReorder: onReorder,
                    longPressToDrag: longPressToDrag,
                    enabled: enabled,
                    onReorderStart: (index) => log.add('start $index'),
                    onReorderEnd: (index) => log.add('end $index'),
                    itemSemanticLabel: (index) => items[index],
                  )
                : ReorderableListView(
                    onReorder: onReorder,
                    longPressToDrag: longPressToDrag,
                    enabled: enabled,
                    onReorderStart: (index) => log.add('start $index'),
                    onReorderEnd: (index) => log.add('end $index'),
                    itemSemanticLabel: (index) => items[index],
                    children: [for (final item in items) row(item)],
                  ),
          ),
        );
      },
    );
  }

  // The copies hang under the list's portal, which is a box of no size:
  // a finder that skips what is off stage does not look there.
  final inTheAir = find.byWidgetPredicate(
    (widget) => '${widget.runtimeType}'.startsWith('_ProxyView'),
    skipOffstage: false,
  );

  bool isRowOf(Widget widget, String item) =>
      widget is ListTile && widget.key == ValueKey(item);

  /// The row of [item] in the list. Its copy in the air, which is built
  /// from the same widget, is [liftedRowOf].
  Finder rowOf(String item) => find.descendant(
    of: find.byType(SliverList),
    matching: find.byWidgetPredicate((widget) => isRowOf(widget, item)),
  );

  /// Every copy in the air.
  Finder lifted() => find.descendant(
    of: inTheAir,
    matching: find.byType(ListTile, skipOffstage: false),
    skipOffstage: false,
  );

  Finder liftedRowOf(String item) => find.descendant(
    of: inTheAir,
    matching: find.byWidgetPredicate(
      (widget) => isRowOf(widget, item),
      skipOffstage: false,
    ),
    skipOffstage: false,
  );

  Finder textOf(String item) =>
      find.descendant(of: rowOf(item), matching: find.text(item));

  Finder handleOf(String item) => find.descendant(
    of: rowOf(item),
    matching: find.byType(ReorderableDragHandle),
  );

  List<String> announcements(WidgetTester tester) {
    final messages = <String>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        final map = (message as Map<Object?, Object?>?) ?? const {};
        if (map['type'] == 'announce') {
          final data = map['data']! as Map<Object?, Object?>;
          messages.add(data['message']! as String);
        }
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(
            SystemChannels.accessibility,
            null,
          ),
    );
    return messages;
  }

  List<MethodCall> hapticCalls(WidgetTester tester) {
    final calls = <MethodCall>[];
    Haptics.debugEnabledInTests = true;
    addTearDown(() => Haptics.debugEnabledInTests = false);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return calls;
  }

  /// Drags from [from] by [dy] in steps, then lets go.
  Future<void> drag(
    WidgetTester tester,
    Offset from,
    double dy, {
    PointerDeviceKind kind = PointerDeviceKind.touch,
    Duration hold = Duration.zero,
  }) async {
    final gesture = await tester.startGesture(from, kind: kind);
    if (hold > Duration.zero) await tester.pump(hold);
    // Exactly [dy] in all, in steps of ten.
    var left = dy.abs();
    while (left > 0) {
      final step = left < 10 ? left : 10.0;
      await gesture.moveBy(Offset(0, dy.sign * step));
      await tester.pump(const Duration(milliseconds: 16));
      left -= step;
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Picks the row of [item] up by its handle and carries it [dy] further.
  /// The first movement is the slop a handle waits for, and is not part of
  /// the distance.
  Future<TestGesture> carry(
    WidgetTester tester,
    String item,
    Offset by,
  ) async {
    final gesture = await tester.startGesture(tester.getCenter(handleOf(item)));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(by - const Offset(0, 20));
    await tester.pump();
    return gesture;
  }

  /// Focuses the handle of the first row, as the first Tab does.
  Future<void> focusFirstHandle(WidgetTester tester) async {
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'ReorderableDragHandle',
    );
  }

  group('ReorderableListView', () {
    testWidgets('builds in every layout at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: list(),
        ),
      );
    });

    testWidgets('at rest it schedules nothing', (tester) async {
      await pumpUna(tester, list());
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    test('every child needs a key', () {
      expect(
        () => ReorderableListView(
          onReorder: (_, _) {},
          children: const [Text('a')],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('dragging a handle down reports the final index: no '
        'minus one to correct', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2 + 20);
      expect(moves, [(0, 2)]);
      expect(items, ['B', 'C', 'A', 'D', 'E']);
      expect(log, ['start 0', 'end 2']);
    });

    testWidgets('dragging a handle up', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('D')), -rowHeight * 2 - 20);
      expect(moves, [(3, 1)]);
      expect(items, ['A', 'D', 'B', 'C', 'E']);
    });

    testWidgets('a row dropped where it was reports no move, and its end', (
      tester,
    ) async {
      await pumpUna(tester, list());
      await drag(tester, tester.getCenter(handleOf('B')), 20);
      expect(moves, isEmpty);
      expect(log, ['start 1', 'end 1']);
    });

    testWidgets('the builder constructor reorders too, by item id', (
      tester,
    ) async {
      await pumpUna(tester, list(builder: true));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight + 20);
      expect(moves, [(0, 1)]);
      expect(items, ['B', 'A', 'C', 'D', 'E']);
    });

    testWidgets('a finger held on a row picks it up; a mouse held on a '
        'row with a handle does not', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(textOf('A')),
        rowHeight,
        hold: kLongPressTimeout + const Duration(milliseconds: 100),
      );
      expect(moves, [(0, 1)]);

      moves.clear();
      await drag(
        tester,
        tester.getCenter(textOf('C')),
        rowHeight,
        kind: PointerDeviceKind.mouse,
        hold: kLongPressTimeout + const Duration(milliseconds: 100),
      );
      expect(moves, isEmpty);
    });

    testWidgets('with longPressToDrag off only the handle drags', (
      tester,
    ) async {
      await pumpUna(tester, list(longPressToDrag: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(textOf('A')),
        rowHeight,
        hold: kLongPressTimeout + const Duration(milliseconds: 100),
      );
      expect(moves, isEmpty);
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight + 20);
      expect(moves, [(0, 1)]);
    });

    testWidgets('a mouse drags by the handle', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(handleOf('B')),
        rowHeight * 2 + 20,
        kind: PointerDeviceKind.mouse,
      );
      expect(moves, [(1, 3)]);
    });

    testWidgets('a mouse drags a row with no handle from anywhere on it, '
        'as on a board', (tester) async {
      await pumpUna(tester, list(handles: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(textOf('B')),
        rowHeight * 2 + 20,
        kind: PointerDeviceKind.mouse,
      );
      expect(moves, [(1, 3)]);
    });

    testWidgets('with no handle a click is still a click', (tester) async {
      var taps = 0;
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 360,
            height: 300,
            child: ReorderableListView(
              onReorder: (from, to) => moves.add((from, to)),
              children: [
                for (final item in ['A', 'B'])
                  ListTile(
                    key: ValueKey(item),
                    title: Text(item),
                    onTap: () => taps++,
                  ),
              ],
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('A')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 1));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(moves, isEmpty);
    });

    testWidgets('with longPressToDrag off a mouse does not drag a row with '
        'no handle either', (tester) async {
      await pumpUna(tester, list(handles: false, longPressToDrag: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(textOf('B')),
        rowHeight * 2 + 20,
        kind: PointerDeviceKind.mouse,
      );
      expect(moves, isEmpty);
    });

    testWidgets('a quick vertical drag on a row scrolls the list', (
      tester,
    ) async {
      await pumpUna(tester, list(count: 30));
      await tester.drag(find.text('Item 3'), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(moves, isEmpty);
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('disabled, nothing can be picked up', (tester) async {
      await pumpUna(tester, list(enabled: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2);
      expect(moves, isEmpty);
      expect(log, isEmpty);
    });

    testWidgets('a moved row keeps its state', (tester) async {
      await pumpUna(tester, list());
      await tester.tap(find.byKey(const ValueKey('counter A')));
      await tester.tap(find.byKey(const ValueKey('counter A')));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2 + 20);
      expect(items.indexOf('A'), 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('a touch drag gives a haptic at pick-up, at each slot '
        'crossed and at the drop; a mouse drag gives none', (tester) async {
      final calls = hapticCalls(tester);
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2 + 20);
      expect(calls.map((call) => call.arguments), [
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.lightImpact',
      ]);
      calls.clear();
      await drag(
        tester,
        tester.getCenter(handleOf('C')),
        rowHeight + 20,
        kind: PointerDeviceKind.mouse,
      );
      expect(calls, isEmpty);
      expect(moves, hasLength(2));
    });

    testWidgets('held near the bottom edge, the list scrolls under the '
        'row', (tester) async {
      await pumpUna(tester, list(count: 30));
      final start = tester.getCenter(handleOf('Item 1'));
      final gesture = await carry(tester, 'Item 1', const Offset(0, 30));
      final bottom = tester.getRect(find.byType(ReorderableListView)).bottom;
      await gesture.moveTo(Offset(start.dx, bottom - 4));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves.single.$1, 1);
      expect(moves.single.$2, greaterThan(8));
    });

    testWidgets('a shrink-wrapped list in a scrolling page scrolls the page', (
      tester,
    ) async {
      final page = ScrollController();
      addTearDown(page.dispose);
      items = [for (var i = 0; i < 12; i++) 'Item $i'];
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 360,
              height: 300,
              child: SingleChildScrollView(
                controller: page,
                child: Column(
                  children: [
                    const SizedBox(height: 120, child: Text('Above')),
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (from, to) {
                        moves.add((from, to));
                        setState(() => items.insert(to, items.removeAt(from)));
                      },
                      children: [
                        for (final item in items)
                          ListTile(
                            key: ValueKey(item),
                            title: Text(item),
                            trailing: const ReorderableDragHandle(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 120, child: Text('Below')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final start = tester.getCenter(handleOf('Item 0'));
      final gesture = await carry(tester, 'Item 0', const Offset(0, 30));
      final bottom = tester.getRect(find.byType(SingleChildScrollView)).bottom;
      await gesture.moveTo(Offset(start.dx, bottom - 4));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(page.offset, greaterThan(100));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves.single.$1, 0);
      expect(moves.single.$2, greaterThan(3));
      expect(lifted(), findsNothing);
    });
  });

  group('ReorderableListView motion', () {
    testWidgets('the row in the air is a lifted copy: larger, over the '
        'card colour', (tester) async {
      await pumpUna(tester, list());
      final width = tester.getSize(rowOf('B')).width;
      final gesture = await carry(tester, 'B', const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 400));
      expect(liftedRowOf('B'), findsOneWidget);
      final theme = themeOf(tester, find.byType(ReorderableListView));
      // `getRect` goes through the copy's transform.
      final scale = tester.getRect(liftedRowOf('B')).width / width;
      expect(scale, closeTo(theme.boardTheme.dragScale!, .005));
      // The copy stands on the card colour, which the row does not have.
      expect(
        find.ancestor(
          of: liftedRowOf('B'),
          matching: find.byWidgetPredicate(
            (widget) => '${widget.runtimeType}' == '_LiftFill',
            skipOffstage: false,
          ),
        ),
        findsOneWidget,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(lifted(), findsNothing);
    });

    testWidgets('the others make way on a spring, in paint: no row is laid '
        'out while a slot opens, and none turns back', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      final rest = tester.getTopLeft(rowOf('C')).dy;
      final box = tester.renderObject<RenderBox>(rowOf('C'));
      final gesture = await carry(tester, 'A', Offset(0, rowHeight * 2.2));
      var laidOut = 0;
      final tops = <double>[];
      for (var i = 0; i < 40; i++) {
        if (box.debugNeedsLayout) laidOut++;
        await tester.pump(const Duration(milliseconds: 16));
        tops.add(tester.getTopLeft(rowOf('C')).dy);
      }
      expect(laidOut, 0);
      // C slides up by one row and never turns back.
      expect(tops.last, closeTo(rest - rowHeight, .5));
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], lessThanOrEqualTo(tops[i - 1] + .01));
      }
      // It moved over several frames, not in one.
      expect(
        tops.where((top) => top < rest - 1 && top > rest - rowHeight + 1),
        isNotEmpty,
      );
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('let go, the copy flies to its slot, lands with a press '
        'in, and is gone', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      final top = tester.getTopLeft(rowOf('A')).dy;
      final width = tester.getSize(rowOf('A')).width;
      final gesture = await carry(tester, 'A', Offset(30, rowHeight * 2.4));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pump();
      var smallest = double.infinity;
      var frames = 0;
      while (lifted().evaluate().isNotEmpty && frames < 200) {
        await tester.pump(const Duration(milliseconds: 16));
        frames++;
        if (lifted().evaluate().isNotEmpty) {
          final rect = tester.getRect(liftedRowOf('A'));
          if (rect.width < smallest) smallest = rect.width;
        }
      }
      // It took a while (a flight), ended, and on the way pressed in below
      // its own size: the landing.
      expect(frames, inInclusiveRange(8, 199));
      expect(smallest, lessThan(width));
      expect(items, ['B', 'C', 'A', 'D', 'E']);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(rowOf('A')).dy,
        closeTo(top + rowHeight * 2, .5),
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a row caught in flight is picked up again', (tester) async {
      await pumpUna(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      var gesture = await carry(tester, 'A', Offset(0, rowHeight * 3));
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      // Still in the air.
      expect(lifted(), findsOneWidget);
      gesture = await carry(tester, 'A', const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 16));
      expect(lifted(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(lifted(), findsNothing);
    });

    testWidgets('a change the parent makes by itself is animated: the rows '
        'glide to where they belong', (tester) async {
      late StateSetter rebuild;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return list();
          },
        ),
      );
      final rowHeight = tester.getSize(rowOf('A')).height;
      final top = tester.getTopLeft(rowOf('A')).dy;
      rebuild(() => items = ['E', 'D', 'C', 'B', 'A']);
      await tester.pump();
      // The frame of the change draws every row where it was.
      expect(tester.getTopLeft(rowOf('A')).dy, closeTo(top, .5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final mid = tester.getTopLeft(rowOf('A')).dy;
      expect(mid, greaterThan(top + 1));
      expect(mid, lessThan(top + rowHeight * 4 - 1));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(rowOf('A')).dy,
        closeTo(top + rowHeight * 4, .5),
      );

      // A removal: the rows below close the gap on the same spring.
      final before = tester.getTopLeft(rowOf('A')).dy;
      rebuild(() => items = ['E', 'D', 'B', 'A']);
      await tester.pump();
      expect(tester.getTopLeft(rowOf('A')).dy, closeTo(before, .5));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(rowOf('A')).dy,
        closeTo(before - rowHeight, .5),
      );
    });

    testWidgets('a parent that does not apply the move gets its row back', (
      tester,
    ) async {
      await pumpUna(tester, list(apply: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      final top = tester.getTopLeft(rowOf('A')).dy;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2 + 20);
      expect(moves, [(0, 2)]);
      expect(items, ['A', 'B', 'C', 'D', 'E']);
      expect(tester.getTopLeft(rowOf('A')).dy, closeTo(top, .5));
      expect(tester.getTopLeft(rowOf('B')).dy, closeTo(top + rowHeight, .5));
      expect(lifted(), findsNothing);
    });

    testWidgets('with reduced motion nothing flies: the row is where the '
        'next build puts it', (tester) async {
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: list(),
        ),
      );
      final rowHeight = tester.getSize(rowOf('A')).height;
      final top = tester.getTopLeft(rowOf('A')).dy;
      final gesture = await carry(tester, 'A', Offset(0, rowHeight * 2));
      await tester.pump(const Duration(milliseconds: 16));
      // The others are already out of the way, and the copy is not scaled.
      expect(tester.getTopLeft(rowOf('B')).dy, closeTo(top, .5));
      expect(
        tester.getSize(liftedRowOf('A')).width,
        tester.getRect(liftedRowOf('A')).width,
      );
      await gesture.up();
      await tester.pump();
      await tester.pump();
      expect(lifted(), findsNothing);
      expect(
        tester.getTopLeft(rowOf('A')).dy,
        closeTo(top + rowHeight * 2, .5),
      );
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('Motion.none moves nothing either', (tester) async {
      await pumpUna(tester, list(), theme: ThemeData(motion: Motion.none));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2 + 20);
      expect(items, ['B', 'C', 'A', 'D', 'E']);
      expect(lifted(), findsNothing);
    });

    testWidgets('hidden mid-drag, the row is put back and no copy is left', (
      tester,
    ) async {
      var visible = true;
      late StateSetter rebuild;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return IndexedStack(
              index: visible ? 0 : 1,
              children: [list(), const Text('elsewhere')],
            );
          },
        ),
      );
      final gesture = await carry(tester, 'A', const Offset(0, 100));
      expect(lifted(), findsOneWidget);
      rebuild(() => visible = false);
      await tester.pump();
      await tester.pump();
      expect(lifted(), findsNothing);
      expect(log, ['start 0', 'end 0']);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves, isEmpty);
    });
  });

  group('SliverReorderableListView', () {
    Widget page({EdgeInsets padding = EdgeInsets.zero}) => StatefulBuilder(
      builder: (context, setState) => Center(
        child: SizedBox(
          width: 360,
          height: 400,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 90, child: Text('Header')),
              ),
              SliverPadding(
                padding: padding,
                sliver: SliverReorderableListView(
                  itemCount: items.length,
                  itemId: (index) => items[index],
                  itemBuilder: (context, index) => ListTile(
                    key: ValueKey(items[index]),
                    title: Text(items[index]),
                    trailing: const ReorderableDragHandle(),
                  ),
                  onReorder: (from, to) {
                    moves.add((from, to));
                    setState(() => items.insert(to, items.removeAt(from)));
                  },
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 600, child: Text('Footer')),
              ),
            ],
          ),
        ),
      ),
    );

    testWidgets('reorders among other slivers, and scrolls its scroll view '
        'from the edge', (tester) async {
      items = [for (var i = 0; i < 20; i++) 'Item $i'];
      await pumpUna(tester, page());
      final rowHeight = tester.getSize(rowOf('Item 0')).height;
      await drag(
        tester,
        tester.getCenter(handleOf('Item 0')),
        rowHeight * 2 + 20,
      );
      expect(moves, [(0, 2)]);

      moves.clear();
      final start = tester.getCenter(handleOf('Item 1'));
      final gesture = await carry(tester, 'Item 1', const Offset(0, 30));
      final bottom = tester.getRect(find.byType(CustomScrollView)).bottom;
      await gesture.moveTo(Offset(start.dx, bottom - 4));
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves.single.$2, greaterThan(6));
      expect(lifted(), findsNothing);
    });

    testWidgets('inset from its viewport, a row held by the keyboard stays '
        'in its column', (tester) async {
      await pumpUna(
        tester,
        page(padding: const EdgeInsets.fromLTRB(40, 0, 24, 0)),
      );
      final row = tester.getRect(rowOf('A'));
      await focusFirstHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      final copy = tester.getRect(liftedRowOf('A'));
      expect(copy.center.dx, closeTo(row.center.dx, .5));
      expect(copy.center.dy, closeTo(row.center.dy + row.height * 2, 1));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(items, ['B', 'C', 'A', 'D', 'E']);
    });

    testWidgets('scrolled far past its start, a copy is still painted', (
      tester,
    ) async {
      items = [for (var i = 0; i < 60; i++) 'Item $i'];
      await pumpUna(tester, page());
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(1800);
      await tester.pump();
      final handle = find.byType(ReorderableDragHandle).hitTestable().first;
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await gesture.moveBy(const Offset(0, 20));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(lifted(), findsOneWidget);
      expect(tester.getSize(lifted()).height, greaterThan(20));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves, hasLength(1));
    });
  });

  group('ReorderableListView keyboard', () {
    testWidgets('Space picks up, arrows move, Space drops; every step is '
        'announced and the move is reported once', (tester) async {
      final said = announcements(tester);
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(said.last, contains('Picked up'));
      expect(log, ['start 0']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(said.last, 'A, Position 2 of 5');
      // The list is the parent's: nothing has moved in it yet.
      expect(moves, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(said.last, 'A, Position 2 of 5');

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(moves, [(0, 1)]);
      expect(items, ['B', 'A', 'C', 'D', 'E']);
      expect(said.last, 'Dropped at position 2 of 5');
      expect(log.last, 'end 1');
      // Dropped: the arrows no longer move it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
      expect(lifted(), findsNothing);
    });

    testWidgets('Escape puts the row back where it was', (tester) async {
      final said = announcements(tester);
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(items, ['A', 'B', 'C', 'D', 'E']);
      expect(moves, isEmpty);
      expect(said.last, 'Move cancelled');
      expect(log, ['start 0', 'end 0']);
    });

    testWidgets('Home and End carry a held row to the ends, and the ends '
        'stop it', (tester) async {
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(items, ['B', 'C', 'D', 'E', 'A']);
      // The focus went with the row.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(items, ['A', 'B', 'C', 'D', 'E']);
    });

    testWidgets('the held row is a lifted copy on its slot, and the focus '
        'stays on its handle as it moves', (tester) async {
      useTraditionalHighlights();
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      final handle = tester.state(handleOf('A'));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(liftedRowOf('A'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
      expect(tester.state(handleOf('A')), same(handle));
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<ListTile>()
            ?.key,
        const ValueKey('A'),
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('tabbing away drops the row where it is', (tester) async {
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(log.last, 'end 1');
      expect(items, ['B', 'A', 'C', 'D', 'E']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
    });

    testWidgets('a row with a handle is not a Tab stop itself; a row '
        'without one is, and Space picks it up', (tester) async {
      useTraditionalHighlights();
      final said = announcements(tester);
      await pumpUna(tester, list());
      final labels = <String?>[];
      for (var i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        labels.add(FocusManager.instance.primaryFocus?.debugLabel);
      }
      expect(labels, everyElement('ReorderableDragHandle'));

      await pumpUna(tester, const SizedBox());
      await pumpUna(tester, list(handles: false));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'Board item');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(said.last, contains('Picked up'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
    });

    testWidgets("the focus ring is the handle's: the row around a focused "
        'handle shows none', (tester) async {
      useTraditionalHighlights();
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      await tester.pump(const Duration(milliseconds: 300));
      final around = tester
          .widgetList<FocusRing>(
            find.ancestor(of: handleOf('A'), matching: find.byType(FocusRing)),
          )
          .where((ring) => ring.visible);
      expect(around, isEmpty);
      final own = tester.widget<FocusRing>(
        find.descendant(of: handleOf('A'), matching: find.byType(FocusRing)),
      );
      expect(own.visible, isTrue);
    });

    testWidgets('sideways arrows do nothing to a held row', (tester) async {
      await pumpUna(tester, list());
      await focusFirstHandle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(moves, isEmpty);
      expect(tester.takeException(), isNull);
    });
  });

  group('ReorderableListView semantics', () {
    testWidgets('each row offers moves as custom actions, and only the '
        'ones it can make', (tester) async {
      final handle = tester.ensureSemantics();
      final said = announcements(tester);
      await pumpUna(tester, list(handles: false));

      List<String> actionsOf(String item) {
        final data = tester.getSemantics(find.text(item)).getSemanticsData();
        return [
          for (final id in data.customSemanticsActionIds ?? const <int>[])
            CustomSemanticsAction.getAction(id)!.label!,
        ];
      }

      expect(actionsOf('A'), unorderedEquals(['Move down', 'Move to bottom']));
      expect(actionsOf('E'), unorderedEquals(['Move up', 'Move to top']));
      expect(actionsOf('C'), hasLength(4));

      final node = tester.getSemantics(find.text('C'));
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.customAction,
        CustomSemanticsAction.getIdentifier(
          const CustomSemanticsAction(label: 'Move to top'),
        ),
      );
      await tester.pumpAndSettle();
      expect(items, ['C', 'A', 'B', 'D', 'E']);
      expect(said.last, 'C, Position 1 of 5');
      handle.dispose();
    });

    testWidgets('the handle is a named button, and the copy in the air is '
        'not in the tree', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, list());
      expect(find.bySemanticsLabel('Drag to reorder'), findsNWidgets(5));
      final gesture = await carry(tester, 'B', const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 100));
      expect(lifted(), findsOneWidget);
      expect(find.bySemanticsLabel('Drag to reorder'), findsNWidgets(5));
      await gesture.up();
      await tester.pumpAndSettle();
      handle.dispose();
    });
  });

  group('ReorderableDragHandle', () {
    testWidgets('with a mouse it shows under the pointer; without one it '
        'is always there', (tester) async {
      await pumpUna(tester, list());
      double opacity(String item) => tester
          .widget<AnimatedOpacity>(
            find.descendant(
              of: handleOf(item),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
      expect(opacity('A'), 1);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(5, 5));
      addTearDown(mouse.removePointer);
      await tester.pump();
      expect(opacity('A'), 0);
      await mouse.moveTo(tester.getCenter(textOf('B')));
      await tester.pumpAndSettle();
      expect(opacity('B'), 1);
      expect(opacity('A'), 0);
    });

    testWidgets('outside a list it is a picture', (tester) async {
      await pumpUna(
        tester,
        const Center(child: ReorderableDragHandle()),
      );
      expect(tester.takeException(), isNull);
      expect(find.byIcon(PhosphorIconsBold.dotsSixVertical), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.debugLabel,
        isNot('ReorderableDragHandle'),
      );
    });

    testWidgets('a custom child replaces the dots', (tester) async {
      await pumpUna(
        tester,
        const Center(child: ReorderableDragHandle(child: Text('grip'))),
      );
      expect(find.text('grip'), findsOneWidget);
    });
  });
}

/// A widget with state: a tap counts.
class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => count++),
    child: SizedBox(width: 24, height: 24, child: Text('$count')),
  );
}
