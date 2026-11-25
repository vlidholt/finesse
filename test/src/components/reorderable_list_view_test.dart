import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

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
    int? count,
  }) {
    if (count != null) items = [for (var i = 0; i < count; i++) 'Item $i'];
    return StatefulBuilder(
      builder: (context, setState) {
        void onReorder(int from, int to) {
          moves.add((from, to));
          setState(() => items.insert(to, items.removeAt(from)));
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

  /// The caller's row for [item]; the list's own wrapper has the same key.
  Finder rowOf(String item) => find.byWidgetPredicate(
    (widget) => widget is ListTile && widget.key == ValueKey(item),
  );

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
      await pumpFinesse(tester, list());
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
      await pumpFinesse(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2);
      expect(moves, [(0, 2)]);
      expect(items, ['B', 'C', 'A', 'D', 'E']);
      expect(log, ['start 0', 'end 2']);
    });

    testWidgets('dragging a handle up', (tester) async {
      await pumpFinesse(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('D')), -rowHeight * 2);
      expect(moves, [(3, 1)]);
      expect(items, ['A', 'D', 'B', 'C', 'E']);
    });

    testWidgets('a row dropped where it was reports nothing', (tester) async {
      await pumpFinesse(tester, list());
      await drag(tester, tester.getCenter(handleOf('B')), 6);
      expect(moves, isEmpty);
    });

    testWidgets('the builder constructor reorders too', (tester) async {
      await pumpFinesse(tester, list(builder: true));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight);
      expect(moves, [(0, 1)]);
    });

    testWidgets('a finger held on a row picks it up; a mouse held there '
        'does not', (tester) async {
      await pumpFinesse(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(find.text('A')),
        rowHeight,
        hold: kLongPressTimeout + const Duration(milliseconds: 100),
      );
      expect(moves, [(0, 1)]);

      moves.clear();
      await drag(
        tester,
        tester.getCenter(find.text('C')),
        rowHeight,
        kind: PointerDeviceKind.mouse,
        hold: kLongPressTimeout + const Duration(milliseconds: 100),
      );
      expect(moves, isEmpty);
    });

    testWidgets('with longPressToDrag off only the handle drags', (
      tester,
    ) async {
      await pumpFinesse(tester, list(longPressToDrag: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(
        tester,
        tester.getCenter(find.text('A')),
        rowHeight,
        hold: kLongPressTimeout + const Duration(milliseconds: 100),
      );
      expect(moves, isEmpty);
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight);
      expect(moves, [(0, 1)]);
    });

    testWidgets('a quick vertical drag on a row scrolls the list', (
      tester,
    ) async {
      await pumpFinesse(tester, list(count: 30));
      await tester.drag(find.text('Item 3'), const Offset(0, -150));
      await tester.pumpAndSettle();
      expect(moves, isEmpty);
      expect(find.text('Item 0'), findsNothing);
    });

    testWidgets('disabled, nothing can be picked up', (tester) async {
      await pumpFinesse(tester, list(enabled: false));
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2);
      expect(moves, isEmpty);
    });

    testWidgets('a moved row keeps its state', (tester) async {
      await pumpFinesse(tester, list());
      await tester.tap(find.byKey(const ValueKey('counter A')));
      await tester.tap(find.byKey(const ValueKey('counter A')));
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight * 2);
      expect(items.indexOf('A'), 2);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('the row in the air is lifted: larger, on the card colour, '
        "under the board's shadow", (tester) async {
      await pumpFinesse(tester, list());
      final gesture = await tester.startGesture(
        tester.getCenter(handleOf('B')),
      );
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 10));
      // The lift starts on the frame after the drag does.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final theme = themeOf(tester, find.byType(ReorderableListView));
      final lifted = find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox && widget.decoration is ShadowDecoration,
      );
      expect(lifted, findsOneWidget);
      final decoration =
          tester.widget<DecoratedBox>(lifted).decoration as ShadowDecoration;
      expect(decoration.shadows, isNotEmpty);
      final scale = tester
          .widget<Transform>(
            find.ancestor(of: lifted, matching: find.byType(Transform)).first,
          )
          .transform
          .getMaxScaleOnAxis();
      expect(scale, greaterThan(1));
      expect(scale, lessThanOrEqualTo(theme.boardTheme.dragScale! + 1e-6));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(lifted, findsNothing);
    });

    testWidgets('a touch drag gives a haptic at pick-up and at the drop; a '
        'mouse drag gives none', (tester) async {
      final calls = hapticCalls(tester);
      await pumpFinesse(tester, list());
      final rowHeight = tester.getSize(rowOf('A')).height;
      await drag(tester, tester.getCenter(handleOf('A')), rowHeight);
      expect(calls.map((call) => call.arguments), [
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.lightImpact',
      ]);
      calls.clear();
      await drag(
        tester,
        tester.getCenter(handleOf('C')),
        rowHeight,
        kind: PointerDeviceKind.mouse,
      );
      expect(calls, isEmpty);
      expect(moves, hasLength(2));
    });

    testWidgets('held near the bottom edge, the list scrolls under the '
        'row', (tester) async {
      await pumpFinesse(tester, list(count: 30));
      final gesture = await tester.startGesture(
        tester.getCenter(handleOf('Item 1')),
      );
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
      final bottom = tester.getRect(find.byType(ReorderableListView)).bottom;
      await gesture.moveTo(
        Offset(tester.getCenter(handleOf('Item 1')).dx, bottom - 4),
      );
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves.single.$1, 1);
      expect(moves.single.$2, greaterThan(8));
    });
  });

  group('ReorderableListView keyboard', () {
    testWidgets('Space picks up, arrows move, Space drops; every step is '
        'announced', (tester) async {
      final said = announcements(tester);
      await pumpFinesse(tester, list());
      // The first handle is the first focus stop of the list.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(said.last, contains('Picked up'));
      expect(log, ['start 0']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
      expect(said.last, 'A, Position 2 of 5');

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items, ['B', 'C', 'A', 'D', 'E']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(said.last, 'Dropped at position 2 of 5');
      expect(log.last, 'end 1');
      // Dropped: the arrows no longer move it.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
    });

    testWidgets('Escape puts the row back where it was', (tester) async {
      final said = announcements(tester);
      await pumpFinesse(tester, list());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items.indexOf('A'), 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(items, ['A', 'B', 'C', 'D', 'E']);
      expect(said.last, 'Move cancelled');
    });

    testWidgets('Home and End move a held row to the ends, and the ends '
        'stop it', (tester) async {
      await pumpFinesse(tester, list());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(items.last, 'A');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items.last, 'A');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(items.first, 'A');
    });

    testWidgets('the held row is lifted in place, and the focus stays on '
        'its handle as it moves', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, list());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final handle = tester.state(handleOf('A'));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox && widget.decoration is ShadowDecoration,
        ),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(tester.state(handleOf('A')), same(handle));
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<ListTile>()
            ?.key,
        const ValueKey('A'),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('tabbing away drops the row where it is', (tester) async {
      await pumpFinesse(tester, list());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(log.last, 'end 1');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(items, ['B', 'A', 'C', 'D', 'E']);
    });
  });

  group('ReorderableListView semantics', () {
    testWidgets('each row offers moves as custom actions, and only the '
        'ones it can make', (tester) async {
      final handle = tester.ensureSemantics();
      final said = announcements(tester);
      await pumpFinesse(tester, list(handles: false));

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

    testWidgets('the handle is a named button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, list());
      expect(find.bySemanticsLabel('Drag to reorder'), findsNWidgets(5));
      handle.dispose();
    });
  });

  group('ReorderableDragHandle', () {
    testWidgets('with a mouse it shows under the pointer; without one it '
        'is always there', (tester) async {
      await pumpFinesse(tester, list());
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
      await mouse.moveTo(tester.getCenter(find.text('B')));
      await tester.pumpAndSettle();
      expect(opacity('B'), 1);
      expect(opacity('A'), 0);
    });

    testWidgets('outside a list it is a picture', (tester) async {
      await pumpFinesse(
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
      await pumpFinesse(
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
