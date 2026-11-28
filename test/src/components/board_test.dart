import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A board over plain strings, which keeps its lists the way an app would.
class _Host extends StatefulWidget {
  const _Host({
    required this.lists,
    this.limits = const {},
    this.size = const Size(960, 500),
    this.applyMoves = true,
    this.shrinkWrap = false,
    this.dragTrigger = BoardDragTrigger.item,
    this.canMove,
    this.controller,
    this.pressable = false,
    this.expandColumns = false,
  });

  final Map<String, List<String>> lists;
  final Map<String, int> limits;
  final Size size;

  /// Whether the parent carries a move out, as it is asked to.
  final bool applyMoves;
  final bool shrinkWrap;
  final BoardDragTrigger dragTrigger;
  final bool Function(BoardMove<String> move)? canMove;
  final BoardController<String>? controller;

  /// Whether each item is a button of its own.
  final bool pressable;
  final bool expandColumns;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late final lists = {
    for (final entry in widget.lists.entries) entry.key: [...entry.value],
  };
  final moves = <BoardMove<String>>[];
  final pressed = <String>[];
  final started = <String>[];
  final ended = <String>[];

  void remove(String item) => setState(() {
    for (final list in lists.values) {
      list.remove(item);
    }
  });

  void insert(String column, int index, String item) =>
      setState(() => lists[column]!.insert(index, item));

  void change(VoidCallback body) => setState(body);

  @override
  Widget build(BuildContext context) {
    final board = Board<String>(
      controller: widget.controller,
      shrinkWrap: widget.shrinkWrap,
      dragTrigger: widget.dragTrigger,
      canMove: widget.canMove,
      expandColumns: widget.expandColumns,
      onDragStart: started.add,
      onDragEnd: ended.add,
      columns: [
        for (final entry in lists.entries)
          BoardColumn(
            id: entry.key,
            label: 'Column ${entry.key}',
            items: entry.value,
            limit: widget.limits[entry.key],
          ),
      ],
      itemBuilder: (context, item, details) {
        final content = SizedBox(
          key: ValueKey('${details.dragging ? 'lifted' : 'item'}-$item'),
          height: 56,
          child: Row(
            children: [
              if (widget.dragTrigger == BoardDragTrigger.handle)
                BoardDragHandle(
                  child: SizedBox.square(
                    key: ValueKey('handle-$item'),
                    dimension: 24,
                  ),
                ),
              Text(item),
            ],
          ),
        );
        return widget.pressable
            ? Card(onTap: () => pressed.add(item), child: content)
            : Card(
                style: const CardTheme(padding: EdgeInsets.zero),
                child: content,
              );
      },
      onMove: (move) {
        moves.add(move);
        if (!widget.applyMoves) return;
        setState(() {
          move.apply(lists[move.fromColumn]!, lists[move.toColumn]!);
        });
      },
    );
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: widget.size.width,
        height: widget.shrinkWrap ? null : widget.size.height,
        child: widget.shrinkWrap
            ? SingleChildScrollView(
                key: const ValueKey('page'),
                child: board,
              )
            : board,
      ),
    );
  }
}

Finder _item(String id) => find.byKey(ValueKey('item-$id'));
Finder _lifted(String id) => find.byKey(ValueKey('lifted-$id'));

Rect _rect(WidgetTester tester, String id) => tester.getRect(_item(id));

_HostState _host(WidgetTester tester) => tester.state(find.byType(_Host));

/// The scroll position of [column]'s list of items.
ScrollPosition _columnScroll(WidgetTester tester, String column) {
  final header = find.text('Column $column');
  final columnFinder = find.ancestor(
    of: header,
    matching: find.byWidgetPredicate(
      (widget) => '${widget.runtimeType}'.startsWith('_BoardColumnView'),
    ),
  );
  final scrollable = find.descendant(
    of: columnFinder.first,
    matching: find.byType(Scrollable),
  );
  return tester.state<ScrollableState>(scrollable.first).position;
}

ScrollPosition _boardScroll(WidgetTester tester) {
  final scrollable = find.descendant(
    of: find.byType(Board<String>),
    matching: find.byType(Scrollable),
  );
  return tester.state<ScrollableState>(scrollable.first).position;
}

/// Whether the board is painting [id] in its column: it does not while a
/// lifted copy stands in for it.
bool _paintedInPlace(WidgetTester tester, String id) {
  RenderObject? node = tester.renderObject(_item(id));
  while (node != null && '${node.runtimeType}' != '_RenderBoardSlot') {
    node = node.parent;
  }
  final hidden = node!
      .toDiagnosticsNode()
      .getProperties()
      .whereType<FlagProperty>()
      .firstWhere((property) => property.name == 'hidden');
  return hidden.value != true;
}

/// A lifted copy's scale and lean, read off its transform: its bounding
/// rectangle widens and narrows with the lean as well.
double _scale(WidgetTester tester, Finder finder) {
  final m = tester.renderObject(finder).getTransformTo(null).storage;
  return math.sqrt(m[0] * m[0] + m[1] * m[1]);
}

double _tilt(WidgetTester tester, Finder finder) {
  final m = tester.renderObject(finder).getTransformTo(null).storage;
  return math.atan2(m[1], m[0]).abs();
}

/// What a copy did between its release and its landing, a frame at a time.
class _Landing {
  final scales = <double>[];
  final centres = <Offset>[];
  Offset slot = Offset.zero;
}

List<String> _letters(int count, [String prefix = 'i']) => [
  for (var i = 0; i < count; i++) '$prefix$i',
];

/// Picks [id] up with a mouse and returns the gesture, past its slop.
Future<TestGesture> _pickUp(WidgetTester tester, String id) async {
  final gesture = await tester.startGesture(
    tester.getCenter(_item(id)),
    kind: PointerDeviceKind.mouse,
  );
  addTearDown(gesture.removePointer);
  await gesture.moveBy(const Offset(0, 4));
  await tester.pump();
  return gesture;
}

/// Moves in steps, a frame apart, as a hand would.
Future<void> _dragBy(
  WidgetTester tester,
  TestGesture gesture,
  Offset delta, {
  int steps = 8,
}) async {
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(delta / steps.toDouble());
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  // Haptics are silent under `flutter test` unless a test asks.
  setUp(() => Haptics.debugEnabledInTests = true);
  tearDown(() => Haptics.debugEnabledInTests = false);

  group('BoardTheme', () {
    test('follows the form factor', () {
      final desktop = ThemeData().boardTheme;
      final mobile = ThemeData(formFactor: FormFactor.mobile).boardTheme;
      expect(desktop.columnWidth, 288);
      expect(desktop.columnViewportFraction, isNull);
      expect(desktop.snap, isFalse);
      expect(mobile.columnViewportFraction, .86);
      expect(mobile.snap, isTrue);
      expect(mobile.columnGap, lessThan(desktop.columnGap!));
    });

    test('wraps its items concentrically, and stays square in lyra', () {
      final theme = ThemeData().boardTheme;
      expect(
        theme.columnBorderRadius!.topLeft.x,
        theme.itemBorderRadius!.topLeft.x + theme.columnPadding!.horizontal / 2,
      );
      final lyra = ThemeData(style: StyleTokens.sharp).boardTheme;
      expect(lyra.columnBorderRadius, BorderRadius.zero);
      expect(lyra.itemBorderRadius, BorderRadius.zero);
    });

    test('items are opaque in every style and brightness', () {
      for (final style in [
        StyleTokens.fluid,
        StyleTokens.crisp,
        StyleTokens.pebble,
        StyleTokens.sharp,
      ]) {
        for (final scheme in const [
          OceanColorScheme.light(),
          OceanColorScheme.dark(),
        ]) {
          final theme = ThemeData(style: style, colorScheme: scheme);
          expect(theme.boardTheme.itemColor!.a, 1, reason: style.name);
        }
      }
    });

    test('two builds are equal, and an override merges', () {
      expect(ThemeData().boardTheme, ThemeData().boardTheme);
      final theme = ThemeData(boardTheme: const BoardTheme(columnWidth: 240));
      expect(theme.boardTheme.columnWidth, 240);
      expect(theme.boardTheme.itemGap, ThemeData().boardTheme.itemGap);
      expect(
        theme.copyWith(radius: BorderRadius.circular(4)).boardTheme.columnWidth,
        240,
      );
    });
  });

  group('Board layout', () {
    testWidgets('lays columns out side by side with their items', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
            'c': [],
          },
        ),
      );
      expect(find.text('Column a'), findsOneWidget);
      expect(_rect(tester, 'a1').top, lessThan(_rect(tester, 'a2').top));
      expect(_rect(tester, 'b1').left, greaterThan(_rect(tester, 'a1').right));
      // The counts.
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('builds only the items in view', (tester) async {
      await pumpUna(
        tester,
        _Host(lists: {'a': _letters(400), 'b': _letters(400, 'j')}),
      );
      expect(_item('i0'), findsOneWidget);
      expect(_item('i399'), findsNothing);
      expect(
        tester.widgetList(
          find.byWidgetPredicate(
            (w) => w.key is ValueKey<String> && w is SizedBox,
          ),
        ),
        // Two columns of at most a screen and its cache each.
        hasLength(lessThan(40)),
      );
    });

    testWidgets('survives every layout', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => _Host(
          size: kSurfaceSizes[layout.formFactor]!,
          lists: const {
            'a': ['a1', 'a2'],
            'b': ['b1'],
            'c': [],
          },
        ),
      );
    });

    testWidgets('a phone shows most of one column and a peek of the next', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          size: Size(390, 600),
          lists: {
            'a': ['a1'],
            'b': ['b1'],
            'c': ['c1'],
          },
        ),
        formFactor: FormFactor.mobile,
      );
      final first = _rect(tester, 'a1');
      final second = _rect(tester, 'b1');
      // The theme the items are built in is still the phone's.
      expect(
        Theme.of(tester.element(_item('a1'))).formFactor,
        FormFactor.mobile,
      );
      expect(first.width, greaterThan(300));
      expect(second.left, lessThan(390));
      expect(second.right, greaterThan(390));
    });

    testWidgets('a phone snaps to a column when it is swiped', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          size: Size(390, 600),
          lists: {
            'a': ['a1'],
            'b': ['b1'],
            'c': ['c1'],
          },
        ),
        formFactor: FormFactor.mobile,
      );
      final before = _rect(tester, 'a1').left;
      await tester.fling(find.text('Column a'), const Offset(-200, 0), 800);
      await tester.pumpAndSettle();
      // The second column is now where the first one was.
      expect(_rect(tester, 'b1').left, moreOrLessEquals(before, epsilon: 1));
    });

    testWidgets('says what it needs when its height is unbounded', (
      tester,
    ) async {
      await pumpUna(
        tester,
        SingleChildScrollView(
          child: Board<String>(
            columns: const [
              BoardColumn(id: 'a', label: 'A', items: ['x']),
            ],
            itemBuilder: (context, item, details) => Text(item),
            onMove: (_) {},
          ),
        ),
      );
      final error = tester.takeException();
      expect(error, isFlutterError);
      expect(error.toString(), contains('shrinkWrap: true'));
    });

    testWidgets('shrink-wraps inside a scrolling page', (tester) async {
      await pumpUna(
        tester,
        _Host(
          shrinkWrap: true,
          lists: {
            'a': _letters(30),
            'b': const ['b1'],
          },
        ),
      );
      expect(tester.takeException(), isNull);
      // Every item is built: the page scrolls, not the column.
      expect(_item('i29'), findsOneWidget);
      final page = tester.getSize(find.byKey(const ValueKey('page')));
      expect(
        tester.getSize(find.byType(Board<String>)).height,
        greaterThan(
          page.height,
        ),
      );
    });

    testWidgets('shares its width between columns that fit', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          expandColumns: true,
          size: Size(900, 400),
          lists: {
            'a': ['a1'],
            'b': ['b1'],
            'c': ['c1'],
          },
        ),
      );
      final theme = ThemeData().boardTheme;
      final gap = theme.columnGap!;
      final width = (900 - gap * 2) / 3;
      final inset = theme.columnPadding!.horizontal;
      double cardWidth() => tester
          .getSize(find.ancestor(of: _item('a1'), matching: find.byType(Card)))
          .width;
      expect(cardWidth(), moreOrLessEquals(width - inset));
      // The last column ends at the board's edge: nothing to scroll.
      expect(_boardScroll(tester).maxScrollExtent, 0);

      // Four would each be narrower than a column may be: they scroll.
      await pumpUna(tester, const SizedBox());
      await pumpUna(
        tester,
        const _Host(
          expandColumns: true,
          size: Size(900, 400),
          lists: {
            'a': ['a1'],
            'b': ['b1'],
            'c': ['c1'],
            'd': ['d1'],
          },
        ),
      );
      expect(cardWidth(), moreOrLessEquals(theme.columnWidth! - inset));
      expect(_boardScroll(tester).maxScrollExtent, greaterThan(0));
    });

    testWidgets('shows a header, a footer and an empty state', (tester) async {
      await pumpUna(
        tester,
        SizedBox(
          width: 700,
          height: 400,
          child: Board<String>(
            columns: const [
              BoardColumn(
                id: 'a',
                label: 'Plain',
                items: ['x'],
                leading: Text('lead'),
                trailing: Text('trail'),
                footer: Text('foot'),
              ),
              BoardColumn(
                id: 'b',
                label: 'Hidden label',
                title: Text('Custom title'),
                items: [],
                empty: Text('Nothing here'),
                showCount: false,
              ),
              BoardColumn(id: 'c', label: 'Bare', items: []),
            ],
            itemBuilder: (context, item, details) => Text(item),
            onMove: (_) {},
          ),
        ),
      );
      expect(find.text('Plain'), findsOneWidget);
      expect(find.text('Custom title'), findsOneWidget);
      expect(find.text('Hidden label'), findsNothing);
      expect(find.text('Nothing here'), findsOneWidget);
      for (final text in ['lead', 'trail', 'foot']) {
        expect(find.text(text), findsOneWidget);
      }
      // Counts for the first and the third column only.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      // The leading widget is before the title, the trailing one at the end
      // of the header, and the footer under the item.
      final title = tester.getRect(find.text('Plain'));
      expect(tester.getRect(find.text('lead')).right, lessThan(title.left));
      expect(tester.getRect(find.text('trail')).left, greaterThan(title.right));
      expect(
        tester.getRect(find.text('foot')).top,
        greaterThan(tester.getRect(find.text('x')).bottom),
      );
    });

    testWidgets('a Card inside a board takes the board metrics', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1'],
            'b': [],
          },
        ),
      );
      final theme = Theme.of(tester.element(_item('a1')));
      final board = ThemeData().boardTheme;
      expect(theme.cardTheme.borderRadius, board.itemBorderRadius);
      expect(theme.cardTheme.padding, board.itemPadding);
      expect(theme.cardTheme.backgroundColor, board.itemColor);
      expect(theme.cardTheme.blur, 0);
      // Everything else is the app's theme.
      expect(theme.colorScheme, ThemeData().colorScheme);
    });

    testWidgets('says so when two items share an id', (tester) async {
      await pumpUna(
        tester,
        SizedBox(
          width: 700,
          height: 400,
          child: Board<String>(
            columns: const [
              BoardColumn(id: 'a', label: 'A', items: ['x']),
              BoardColumn(id: 'b', label: 'B', items: ['x']),
            ],
            itemBuilder: (context, item, details) => Text(item),
            onMove: (_) {},
          ),
        ),
      );
      expect(
        tester.takeException(),
        isA<AssertionError>().having(
          (error) => '${error.message}',
          'message',
          contains('Board.itemId'),
        ),
      );
    });

    testWidgets('says what it needs when its width is unbounded', (
      tester,
    ) async {
      final errors = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) => errors.add('${details.exception}');
      await pumpUna(
        tester,
        Row(
          children: [
            SizedBox(
              height: 300,
              child: Board<String>(
                columns: const [
                  BoardColumn(id: 'a', label: 'A', items: ['x']),
                ],
                itemBuilder: (context, item, details) => Text(item),
                onMove: (_) {},
              ),
            ),
          ],
        ),
      );
      FlutterError.onError = previous;
      expect(errors.first, contains('unbounded width'));
    });

    testWidgets('follows the text scale', (tester) async {
      await pumpUna(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: _Host(
            lists: {
              'a': ['a1', 'a2'],
              'b': [],
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Column a'), findsOneWidget);
    });
  });

  group('Board dragging', () {
    testWidgets('reorders within a column', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      expect(_lifted('a1'), findsOneWidget);
      await _dragBy(tester, gesture, const Offset(0, 70));
      await gesture.up();
      await tester.pumpAndSettle();

      final host = _host(tester);
      expect(host.lists['a'], ['a2', 'a1', 'a3']);
      expect(
        host.moves.single,
        const BoardMove<String>(
          item: 'a1',
          fromColumn: 'a',
          fromIndex: 0,
          toColumn: 'a',
          toIndex: 1,
        ),
      );
      expect(host.started, ['a1']);
      expect(host.ended, ['a1']);
      expect(_lifted('a1'), findsNothing);
      expect(_rect(tester, 'a2').top, lessThan(_rect(tester, 'a1').top));
    });

    testWidgets('moves across columns', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1', 'b2'],
          },
        ),
      );
      final from = tester.getCenter(_item('a1'));
      final to = tester.getCenter(_item('b2'));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, to - from + const Offset(0, -10));
      await gesture.up();
      await tester.pumpAndSettle();

      final host = _host(tester);
      expect(host.lists['a'], ['a2']);
      expect(host.lists['b'], ['b1', 'a1', 'b2']);
      expect(host.moves.single.toColumn, 'b');
      expect(host.moves.single.toIndex, 1);
    });

    testWidgets('drops into an empty column', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a2');
      await _dragBy(tester, gesture, const Offset(300, 60));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).lists, {
        'a': ['a1'],
        'b': ['a2'],
      });
    });

    testWidgets('a full column refuses the drop and the item springs back', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
          limits: {'b': 1},
        ),
      );
      // The count of a full column.
      expect(find.text('1/1'), findsOneWidget);
      final home = _rect(tester, 'a1');
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 16));
      // On its way back, not there yet.
      expect(_lifted('a1'), findsOneWidget);
      expect(tester.getRect(_lifted('a1')).left, greaterThan(home.left + 20));
      await tester.pumpAndSettle();

      final host = _host(tester);
      expect(host.moves, isEmpty);
      expect(host.lists['a'], ['a1', 'a2']);
      expect(_lifted('a1'), findsNothing);
      expect(_rect(tester, 'a1'), home);
    });

    testWidgets('canMove refuses a move', (tester) async {
      await pumpUna(
        tester,
        _Host(
          lists: const {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
          canMove: (move) => move.toColumn != 'b',
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).moves, isEmpty);
    });

    testWidgets('Escape cancels the drag', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      final home = _rect(tester, 'a1');
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 90));
      expect(_rect(tester, 'a2').top, lessThan(home.bottom));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsNothing);
      expect(_rect(tester, 'a1'), home);

      // The pointer is still down; letting go now does nothing more.
      await gesture.up();
      await tester.pumpAndSettle();
      final host = _host(tester);
      expect(host.moves, isEmpty);
      expect(host.ended, ['a1']);
    });

    testWidgets('a pointer cancel puts the item back', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(_host(tester).moves, isEmpty);
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('dropped outside the board, the item goes back', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          size: Size(700, 300),
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(200, 600));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).moves, isEmpty);
    });

    testWidgets('a mouse drags at once, a finger after a long press', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(lists: {'a': _letters(30), 'b': const []}),
      );

      // A finger that moves straight away scrolls the column.
      final scroll = _columnScroll(tester, 'a');
      await tester.drag(find.text('i2'), const Offset(0, -120));
      await tester.pumpAndSettle();
      expect(scroll.pixels, greaterThan(50));
      expect(_host(tester).started, isEmpty);
      scroll.jumpTo(0);
      await tester.pump();

      // A finger that rests picks the item up.
      final finger = await tester.startGesture(tester.getCenter(_item('i1')));
      await tester.pump(const Duration(milliseconds: 100));
      expect(_lifted('i1'), findsNothing);
      await tester.pump(kLongPressTimeout);
      expect(_lifted('i1'), findsOneWidget);
      expect(_host(tester).started, ['i1']);
      await finger.up();
      await tester.pumpAndSettle();

      // A mouse picks it up as soon as it has moved a little.
      final mouse = await tester.startGesture(
        tester.getCenter(_item('i1')),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(_lifted('i1'), findsNothing);
      await mouse.moveBy(const Offset(5, 0));
      await tester.pump();
      expect(_lifted('i1'), findsOneWidget);
      await mouse.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a click on an item is still a click', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          pressable: true,
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(_item('a1')),
        kind: PointerDeviceKind.mouse,
      );
      // An unsteady hand.
      await gesture.moveBy(const Offset(1, 1));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).pressed, ['a1']);
      expect(_host(tester).started, isEmpty);
    });

    testWidgets('haptics on a touch pick-up and drop', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final finger = await tester.startGesture(tester.getCenter(_item('a1')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
      expect(calls, ['HapticFeedbackType.mediumImpact']);
      await finger.up();
      await tester.pumpAndSettle();
      expect(calls.last, 'HapticFeedbackType.lightImpact');
    });

    testWidgets('with handles, only the handle drags', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          dragTrigger: BoardDragTrigger.handle,
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final body = await tester.startGesture(
        tester.getCenter(find.text('a1')),
        kind: PointerDeviceKind.mouse,
      );
      await body.moveBy(const Offset(0, 30));
      await tester.pump();
      expect(_lifted('a1'), findsNothing);
      await body.up();

      // A finger on the handle does not wait for a long press.
      final handle = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('handle-a1'))),
      );
      await handle.moveBy(const Offset(0, 30));
      await tester.pump();
      expect(_lifted('a1'), findsOneWidget);
      await handle.up();
      await tester.pumpAndSettle();
    });

    testWidgets('wins a mouse drag from a text selection around it', (
      tester,
    ) async {
      await pumpUna(
        tester,
        SelectableRegion(
          selectionControls: emptyTextSelectionControls,
          child: const _Host(
            lists: {
              'a': ['a1', 'a2'],
              'b': [],
            },
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('a1')),
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(gesture.removePointer);
      // A pixel at a time, as a real mouse reports.
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(const Offset(1, 0));
      }
      await tester.pump();
      expect(_lifted('a1'), findsOneWidget);
      await _dragBy(tester, gesture, const Offset(290, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], ['a1']);
    });

    testWidgets('going away mid-drag leaves nothing behind', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(100, 20));
      expect(_lifted('a1'), findsOneWidget);
      await pumpUna(tester, const SizedBox());
      expect(tester.takeException(), isNull);
      expect(_lifted('a1'), findsNothing);
      // The pointer is still down, with nobody listening.
      await gesture.moveBy(const Offset(10, 10));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Escape is no longer swallowed.
      expect(
        await tester.sendKeyEvent(LogicalKeyboardKey.escape),
        isFalse,
      );
    });

    testWidgets('a disabled board does not drag', (tester) async {
      await pumpUna(
        tester,
        SizedBox(
          width: 700,
          height: 400,
          child: Board<String>(
            enabled: false,
            columns: const [
              BoardColumn(id: 'a', label: 'A', items: ['x', 'y']),
            ],
            itemBuilder: (context, item, details) =>
                SizedBox(height: 40, child: Text(item)),
            onMove: (_) => fail('moved'),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('x')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('a second pointer does not start a second drag', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      final first = await _pickUp(tester, 'a1');
      final second = await tester.startGesture(
        tester.getCenter(_item('b1')),
        kind: PointerDeviceKind.mouse,
        pointer: 9,
      );
      await second.moveBy(const Offset(0, 20));
      await tester.pump();
      expect(_lifted('b1'), findsNothing);
      await second.up();
      await first.up();
      await tester.pumpAndSettle();
      expect(_host(tester).started, ['a1']);
    });
  });

  group('Board motion', () {
    testWidgets('the neighbours slide to make way, without a jump', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3', 'a4'],
            'b': ['b1'],
          },
        ),
      );
      final start = _rect(tester, 'a2').top;
      final gesture = await _pickUp(tester, 'a1');
      // Straight past a2, in one move: its slot has to close by sliding.
      await gesture.moveBy(const Offset(0, 80));

      final tops = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        tops.add(_rect(tester, 'a2').top);
      }
      // It ends one slot up...
      expect(tops.last, lessThan(start - 50));
      // ...having got there a little at a time,
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], lessThanOrEqualTo(tops[i - 1] + 1e-6), reason: '$i');
      }
      // with no frame that covers more than a part of the way.
      final travel = start - tops.last;
      var previous = start;
      for (final top in tops) {
        expect(previous - top, lessThan(travel * .35));
        previous = top;
      }
      // a3 and a4 never moved: the slot opened above them.
      expect(_rect(tester, 'a3').top, greaterThan(tops.last));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('the slot follows the item into another column mid-drag', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1', 'b2'],
          },
        ),
      );
      final a2 = _rect(tester, 'a2').top;
      final b1 = _rect(tester, 'b1').top;
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));

      final aTops = <double>[];
      final bTops = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        aTops.add(_rect(tester, 'a2').top);
        bTops.add(_rect(tester, 'b1').top);
      }
      // The column it left closes up; the one it is over opens.
      expect(aTops.last, lessThan(a2 - 50));
      expect(bTops.last, greaterThan(b1 + 50));
      for (var i = 1; i < aTops.length; i++) {
        expect(aTops[i], lessThanOrEqualTo(aTops[i - 1] + 1e-6));
        expect(bTops[i], greaterThanOrEqualTo(bTops[i - 1] - 1e-6));
      }
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('nothing jumps in the frame the move is carried out', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1', 'b2'],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      // Let go while the neighbours are still on their way.
      await tester.pump(const Duration(milliseconds: 48));
      final before = {
        for (final id in ['a2', 'a3', 'b1', 'b2']) id: _rect(tester, id).top,
      };
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 16));
      for (final MapEntry(key: id, value: top) in before.entries) {
        expect(
          (_rect(tester, id).top - top).abs(),
          lessThan(12),
          reason: '$id jumped when the lists changed',
        );
      }
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], ['a1', 'b1', 'b2']);
    });

    testWidgets('the neighbours keep going the same way through a drop', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1', 'b2'],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      // Over the top of the other column, in one move, and let go while
      // everything is still sliding.
      await gesture.moveBy(const Offset(300, 0));
      final a2 = <double>[];
      final b1 = <double>[];
      Future<void> frame() async {
        await tester.pump(const Duration(milliseconds: 16));
        a2.add(_rect(tester, 'a2').top);
        b1.add(_rect(tester, 'b1').top);
      }

      for (var i = 0; i < 4; i++) {
        await frame();
      }
      await gesture.up();
      for (var i = 0; i < 40; i++) {
        await frame();
      }
      // Up in the column it left, down in the one it joined, and never a
      // frame the other way: not in the frame the lists changed either.
      for (var i = 1; i < a2.length; i++) {
        expect(a2[i], lessThanOrEqualTo(a2[i - 1] + 1e-6), reason: 'a2 $i');
        expect(b1[i], greaterThanOrEqualTo(b1[i - 1] - 1e-6), reason: 'b1 $i');
      }
      expect(a2.first - a2.last, greaterThan(30));
      expect(b1.last - b1.first, greaterThan(30));
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], ['a1', 'b1', 'b2']);
    });

    testWidgets('the lifted item grows, and lands with a small overshoot', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      final size = tester.getSize(_item('a1'));
      final gesture = await _pickUp(tester, 'a1');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      final lifted = tester.getRect(_lifted('a1'));
      expect(lifted.width, greaterThan(size.width * 1.02));

      await _dragBy(tester, gesture, const Offset(0, 70));
      await gesture.up();
      final widths = <double>[];
      while (_lifted('a1').evaluate().isNotEmpty && widths.length < 200) {
        await tester.pump(const Duration(milliseconds: 16));
        if (_lifted('a1').evaluate().isNotEmpty) {
          widths.add(tester.getRect(_lifted('a1')).width);
        }
      }
      // It is pressed a little under its size before settling on it: the
      // pop, as deep as the theme says and no deeper.
      final theme = ThemeData().boardTheme;
      final smallest = widths.reduce((a, b) => a < b ? a : b);
      expect(
        smallest / size.width,
        moreOrLessEquals(theme.landScale!, epsilon: .004),
      );
      // Down to it and back in one movement: no second bounce to speak of.
      final dip = widths.indexOf(smallest);
      for (var i = 1; i <= dip; i++) {
        expect(widths[i], lessThanOrEqualTo(widths[i - 1] + 1e-6));
      }
      final largestAfter = widths.skip(dip).reduce((a, b) => a > b ? a : b);
      expect(largestAfter, lessThan(size.width * 1.003));
      expect(widths.last, moreOrLessEquals(size.width, epsilon: .5));
      // And it ends exactly where the item is.
      expect(tester.getSize(_item('a1')), size);
      await tester.pumpAndSettle();
    });

    testWidgets('the lifted item leans into a sideways drag', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      final angles = <double>[];
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump(const Duration(milliseconds: 16));
        angles.add(_tilt(tester, _lifted('a1')));
      }
      // A rotation, and one to see: past the degree and a half it used to
      // stop at, and within what the theme allows.
      final tilt = ThemeData().boardTheme.dragTilt!;
      final most = angles.reduce(math.max);
      expect(most, greaterThan(.03));
      expect(most, lessThanOrEqualTo(tilt + 1e-6));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    // The pop of a landing was the same in both cases, but an item dropped
    // further along its own column flew to a slot that was itself sliding
    // from where the item had been picked up: the copy turned back towards
    // its old place and was then carried to its new one, a landing twice
    // the size of one in another column.
    testWidgets('a drop within a column lands exactly as a drop into another '
        'column does', (tester) async {
      Future<_Landing> drop(Offset delta) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpUna(
          tester,
          const _Host(
            lists: {
              'a': ['a1', 'a2', 'a3'],
              'b': ['b1'],
            },
          ),
        );
        final gesture = await _pickUp(tester, 'a1');
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        await _dragBy(tester, gesture, delta);
        await gesture.up();
        final landing = _Landing();
        for (var i = 0; i < 200 && _lifted('a1').evaluate().isNotEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          if (_lifted('a1').evaluate().isEmpty) break;
          landing.scales.add(_scale(tester, _lifted('a1')));
          landing.centres.add(tester.getRect(_lifted('a1')).center);
        }
        await tester.pumpAndSettle();
        landing.slot = _rect(tester, 'a1').center;
        return landing;
      }

      final within = await drop(const Offset(0, 50));
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      final across = await drop(const Offset(300, -20));
      expect(_host(tester).lists['b'], ['a1', 'b1']);

      for (final (name, landing) in [('within', within), ('across', across)]) {
        // Straight to its slot: never further from it than a frame before.
        final distances = [
          for (final centre in landing.centres)
            (centre - landing.slot).distance,
        ];
        for (var i = 1; i < distances.length; i++) {
          expect(
            distances[i],
            lessThanOrEqualTo(distances[i - 1] + .01),
            reason: '$name, frame $i: $distances',
          );
        }
        expect(distances.last, lessThan(.5), reason: name);
      }

      // And the same pop, frame for frame, from the frame it starts in.
      List<double> pop(_Landing landing) {
        final dragScale = ThemeData().boardTheme.dragScale!;
        final start = landing.scales.indexWhere((s) => s < dragScale - 1e-4);
        expect(start, greaterThanOrEqualTo(0));
        return landing.scales.sublist(start);
      }

      final a = pop(within);
      final b = pop(across);
      expect(a.length, greaterThan(20));
      for (var i = 0; i < 20; i++) {
        expect(a[i], moreOrLessEquals(b[i], epsilon: 1e-4), reason: 'frame $i');
      }
      expect(
        a.reduce(math.min),
        moreOrLessEquals(ThemeData().boardTheme.landScale!, epsilon: .002),
      );
    });

    testWidgets('an item caught mid-flight is picked up where it is', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 32));
      expect(_lifted('a1'), findsOneWidget);
      final flying = tester.getRect(_lifted('a1'));

      // Grab it again, on its slot in the new column.
      final again = await tester.startGesture(
        tester.getCenter(find.text('Column b')) + const Offset(0, 60),
        kind: PointerDeviceKind.mouse,
      );
      await again.moveBy(const Offset(0, 5));
      await tester.pump();
      expect(_host(tester).started, ['a1', 'a1']);
      expect(
        (tester.getRect(_lifted('a1')).center - flying.center).distance,
        lessThan(40),
      );
      // It comes to the pointer rather than staying where it was caught.
      await tester.pumpAndSettle();
      expect(
        tester
            .getRect(_lifted('a1'))
            .inflate(8)
            .contains(
              tester.getCenter(find.text('Column b')) + const Offset(0, 65),
            ),
        isTrue,
      );
      await again.up();
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('reduced motion moves nothing by animation', (tester) async {
      await pumpUna(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _Host(
            lists: {
              'a': ['a1', 'a2', 'a3'],
              'b': ['b1'],
            },
          ),
        ),
      );
      final size = tester.getSize(_item('a1'));
      final a2 = _rect(tester, 'a2').top;
      final gesture = await _pickUp(tester, 'a1');
      await gesture.moveBy(const Offset(0, 80));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      // The neighbour is already in its new place, and the copy is not
      // scaled or tilted.
      expect(_rect(tester, 'a2').top, lessThan(a2 - 50));
      expect(tester.getSize(_lifted('a1')), size);
      expect(tester.getRect(_lifted('a1')).width, size.width);

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a1'), findsNothing);
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      await tester.pumpAndSettle();
    });

    testWidgets('everything settles after a drop', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
            'c': [],
          },
        ),
      );
      for (final (id, delta) in [
        ('a1', const Offset(0, 100)),
        ('a2', const Offset(300, 20)),
        ('b1', const Offset(300, 0)),
        ('a3', const Offset(0, -300)),
      ]) {
        final gesture = await _pickUp(tester, id);
        await _dragBy(tester, gesture, delta);
        await gesture.up();
        // Returns only if every animation ends.
        await tester.pumpAndSettle();
        expect(tester.binding.transientCallbackCount, 0);
      }
      // And a drag that is held still does not keep ticking either.
      final gesture = await _pickUp(tester, 'a1');
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('Board scrolling while dragging', () {
    testWidgets('scrolls the column when the pointer nears its edge', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(lists: {'a': _letters(40), 'b': const []}),
      );
      final scroll = _columnScroll(tester, 'a');
      final gesture = await _pickUp(tester, 'i1');
      // To just inside the bottom of the board.
      await gesture.moveTo(Offset(tester.getCenter(_item('i1')).dx, 490));
      await tester.pump();
      final offsets = <double>[];
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        offsets.add(scroll.pixels);
      }
      expect(offsets.last, greaterThan(100));
      for (var i = 1; i < offsets.length; i++) {
        expect(offsets[i], greaterThan(offsets[i - 1]));
      }

      // Further from the edge it is slower.
      await gesture.moveBy(const Offset(0, -30));
      await tester.pump();
      final slowFrom = scroll.pixels;
      await tester.pump(const Duration(milliseconds: 160));
      final slow = scroll.pixels - slowFrom;
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      final fastFrom = scroll.pixels;
      await tester.pump(const Duration(milliseconds: 160));
      expect(scroll.pixels - fastFrom, greaterThan(slow * 2));

      // Away from the edge it stops, and the drop lands down the list.
      await gesture.moveBy(const Offset(0, -200));
      await tester.pump();
      final resting = scroll.pixels;
      await tester.pump(const Duration(milliseconds: 100));
      expect(scroll.pixels, resting);
      await gesture.up();
      await tester.pumpAndSettle();
      final host = _host(tester);
      expect(host.moves.single.toIndex, greaterThan(3));
      expect(host.lists['a']!.indexOf('i1'), host.moves.single.toIndex);
    });

    testWidgets('scrolls the board when the pointer nears its side', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          size: Size(700, 400),
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
            'c': ['c1'],
            'd': ['d1'],
            'e': [],
          },
        ),
      );
      final scroll = _boardScroll(tester);
      expect(scroll.maxScrollExtent, greaterThan(300));
      final gesture = await _pickUp(tester, 'a1');
      await gesture.moveTo(const Offset(690, 100));
      await tester.pump();
      final offsets = <double>[];
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        offsets.add(scroll.pixels);
      }
      expect(offsets.last, scroll.maxScrollExtent);
      for (var i = 1; i < offsets.length; i++) {
        expect(offsets[i], greaterThanOrEqualTo(offsets[i - 1]));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      // It landed in the last column, which was out of view at first.
      expect(_host(tester).lists['e'], ['a1']);
    });

    testWidgets('on a phone, resting at the edge turns to the next column', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          size: Size(390, 600),
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
            'c': [],
          },
        ),
        formFactor: FormFactor.mobile,
      );
      final scroll = _boardScroll(tester);
      final finger = await tester.startGesture(tester.getCenter(_item('a1')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
      expect(_lifted('a1'), findsOneWidget);
      await finger.moveTo(const Offset(380, 150));
      await tester.pump();
      // Not at once: only after a pause.
      await tester.pump(const Duration(milliseconds: 100));
      expect(scroll.pixels, 0);
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final step = tester.getRect(_item('b1')).width;
      expect(scroll.pixels, greaterThan(step * .9));
      // Pull back from the edge and drop on the column now in view.
      await finger.moveTo(const Offset(200, 150));
      await tester.pump();
      await finger.up();
      await tester.pumpAndSettle();
      expect(_host(tester).moves.single.toColumn, isNot('a'));
    });

    testWidgets('a shrink-wrapped board scrolls the page around it', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(
          shrinkWrap: true,
          lists: {'a': _letters(40), 'b': const []},
        ),
      );
      final page = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byKey(const ValueKey('page')),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;
      final gesture = await _pickUp(tester, 'i1');
      await gesture.moveTo(Offset(tester.getCenter(_item('i1')).dx, 790));
      await tester.pump();
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(page.pixels, greaterThan(100));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).moves.single.toIndex, greaterThan(3));
    });

    testWidgets('the wheel scrolls the column under a held item', (
      tester,
    ) async {
      await pumpUna(
        tester,
        _Host(lists: {'a': _letters(40), 'b': const []}),
      );
      final scroll = _columnScroll(tester, 'a');
      final gesture = await _pickUp(tester, 'i1');
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: tester.getCenter(_lifted('i1')),
          scrollDelta: const Offset(0, 120),
        ),
      );
      await tester.pump();
      expect(scroll.pixels, 120);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('Board with changing lists', () {
    testWidgets('an item added mid-drag makes the others slide', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a3');
      await _dragBy(tester, gesture, const Offset(0, -10));
      await tester.pumpAndSettle();
      final a2 = _rect(tester, 'a2').top;

      _host(tester).insert('a', 0, 'new');
      await tester.pump();
      // Not there in one frame...
      expect(_rect(tester, 'a2').top, lessThan(a2 + 30));
      await tester.pumpAndSettle();
      // ...but there in the end.
      expect(_rect(tester, 'a2').top, greaterThan(a2 + 50));
      expect(_lifted('a3'), findsOneWidget);

      await _dragBy(tester, gesture, const Offset(0, -150));
      await gesture.up();
      await tester.pumpAndSettle();
      final host = _host(tester);
      expect(host.lists['a']!.first, 'a3');
      expect(host.lists['a'], hasLength(4));
    });

    testWidgets('the dragged item being removed ends the drag', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      final home = _rect(tester, 'a2');
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(200, 40));
      _host(tester).remove('a1');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_lifted('a1'), findsNothing);
      final host = _host(tester);
      expect(host.ended, ['a1']);
      // The rest closed up, and the pointer letting go later is harmless.
      expect(_rect(tester, 'a2').top, lessThan(home.top));
      await gesture.moveBy(const Offset(10, 10));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(host.moves, isEmpty);
    });

    testWidgets('a parent that turns the move down gets the item back', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          applyMoves: false,
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
        ),
      );
      final home = _rect(tester, 'a1');
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).moves, hasLength(1));
      expect(_rect(tester, 'a1'), home);
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('an item the parent moves by itself flies across', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
        ),
      );
      final from = _rect(tester, 'a1');
      final host = _host(tester)..change(() {});
      host.change(() {
        host.lists['a']!.remove('a1');
        host.lists['b']!.add('a1');
      });
      await tester.pump();
      // In the frame the lists change the item is not drawn in its new
      // place, where the copy has yet to arrive.
      expect(_paintedInPlace(tester, 'a1'), isFalse);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      // A copy is in the air between the two places.
      expect(_lifted('a1'), findsOneWidget);
      final flying = tester.getRect(_lifted('a1'));
      expect(flying.left, greaterThan(from.left));
      expect(flying.left, lessThan(_rect(tester, 'a1').left));
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsNothing);
      expect(_paintedInPlace(tester, 'a1'), isTrue);
    });

    testWidgets('a reorder from outside slides instead of jumping', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': [],
          },
        ),
      );
      final top = _rect(tester, 'a1').top;
      final host = _host(tester);
      host.change(() => host.lists['a'] = ['a3', 'a1', 'a2']);
      await tester.pump();
      expect(_rect(tester, 'a1').top, moreOrLessEquals(top, epsilon: 8));
      await tester.pumpAndSettle();
      expect(_rect(tester, 'a1').top, greaterThan(top + 50));
    });
  });

  group('Board keyboard', () {
    Future<void> focus(WidgetTester tester, String id) async {
      useTraditionalHighlights();
      final node = Focus.of(tester.element(_item(id)));
      node.requestFocus();
      await tester.pump();
    }

    testWidgets('Space picks up, arrows move, Space drops', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );
      await focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(_lifted('a1'), findsOneWidget);
      expect(_host(tester).started, ['a1']);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      // Still only a preview.
      expect(_host(tester).moves, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_host(tester).lists['a'], ['a2', 'a3', 'a1']);
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('arrows move between columns, and Enter drops', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1', 'b2'],
            'c': [],
          },
        ),
      );
      await focus(tester, 'a2');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      final host = _host(tester);
      expect(host.lists['c'], ['a2']);
      // The item keeps the focus in its new column.
      expect(Focus.of(tester.element(_item('a2'))).hasFocus, isTrue);
    });

    testWidgets('Escape puts the item back', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
        ),
      );
      final home = _rect(tester, 'a1');
      await focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      final host = _host(tester);
      expect(host.moves, isEmpty);
      expect(host.ended, ['a1']);
      expect(_rect(tester, 'a1'), home);
    });

    testWidgets('a full column is skipped', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1'],
            'b': ['b1'],
            'c': [],
          },
          limits: {'b': 1},
        ),
      );
      await focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_host(tester).lists['c'], ['a1']);
    });

    testWidgets('the arrows are mirrored right-to-left', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1'],
            'b': ['b1'],
          },
        ),
        textDirection: TextDirection.rtl,
      );
      // The first column is on the right.
      expect(_rect(tester, 'a1').left, greaterThan(_rect(tester, 'b1').left));
      await focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // Right is backwards here: there is nothing before the first column.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], contains('a1'));
    });

    testWidgets('a move down the list scrolls it into view', (tester) async {
      await pumpUna(
        tester,
        _Host(lists: {'a': _letters(40), 'b': const []}),
      );
      final scroll = _columnScroll(tester, 'a');
      await focus(tester, 'i0');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
      }
      expect(scroll.pixels, greaterThan(100));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_host(tester).lists['a']!.indexOf('i0'), 12);
    });
  });

  group('Board semantics', () {
    testWidgets('every item offers its moves as actions', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
            'c': [],
          },
        ),
      );
      Set<String> actionsOf(String id) {
        final node = tester.getSemantics(
          find
              .ancestor(
                of: _item(id),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is Semantics &&
                      w.properties.customSemanticsActions != null,
                ),
              )
              .first,
        );
        final data = node.getSemanticsData();
        return {
          for (final id in data.customSemanticsActionIds ?? <int>[])
            CustomSemanticsAction.getAction(id)!.label!,
        };
      }

      expect(actionsOf('a1'), {
        'Move down',
        'Move to Column b',
        'Move to Column c',
      });
      expect(actionsOf('a2'), containsAll(['Move up', 'Move down']));
      expect(actionsOf('a3'), isNot(contains('Move down')));
      handle.dispose();
    });

    testWidgets('the actions move the item and say so', (tester) async {
      final handle = tester.ensureSemantics();
      final announcements = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, (
            message,
          ) async {
            final data = (message as Map<dynamic, dynamic>)['data'];
            if (message['type'] == 'announce' && data is Map) {
              announcements.add(data['message'] as String);
            }
          });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockDecodedMessageHandler<dynamic>(
              SystemChannels.accessibility,
              null,
            ),
      );
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2', 'a3'],
            'b': ['b1'],
          },
        ),
      );

      Future<void> perform(String id, String label) async {
        final semantics = tester.widget<Semantics>(
          find
              .ancestor(
                of: _item(id),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is Semantics &&
                      w.properties.customSemanticsActions != null,
                ),
              )
              .first,
        );
        final action = semantics.properties.customSemanticsActions!.entries
            .firstWhere((entry) => entry.key.label == label);
        action.value();
        await tester.pumpAndSettle();
      }

      await perform('a1', 'Move down');
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      await perform('a1', 'Move to Column b');
      expect(_host(tester).lists, {
        'a': ['a2', 'a3'],
        'b': ['b1', 'a1'],
      });
      expect(announcements.last, 'Dropped in Column b, position 2 of 2');
      handle.dispose();
    });
  });

  group('BoardController', () {
    testWidgets('moves an item, by the same rules as a drag', (tester) async {
      final controller = BoardController<String>();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        _Host(
          controller: controller,
          lists: const {
            'a': ['a1', 'a2'],
            'b': ['b1'],
            'c': ['c1'],
          },
          limits: const {'c': 1},
        ),
      );
      expect(controller.move('a1', toColumn: 'b', toIndex: 0), isTrue);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      expect(_lifted('a1'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], ['a1', 'b1']);

      expect(controller.move('a2', toColumn: 'c'), isFalse);
      expect(controller.move('nobody', toColumn: 'a'), isFalse);
      expect(controller.move('a1', toColumn: 'b', toIndex: 0), isFalse);
    });

    testWidgets('reports and cancels a drag', (tester) async {
      final controller = BoardController<String>();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);
      await pumpUna(
        tester,
        _Host(
          controller: controller,
          lists: const {
            'a': ['a1', 'a2'],
            'b': [],
          },
        ),
      );
      expect(controller.isDragging, isFalse);
      final gesture = await _pickUp(tester, 'a1');
      expect(controller.isDragging, isTrue);
      await _dragBy(tester, gesture, const Offset(300, 0));
      controller.cancelDrag();
      expect(controller.isDragging, isFalse);
      expect(notified, 2);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).moves, isEmpty);
    });

    testWidgets('scrolls a column into view', (tester) async {
      final controller = BoardController<String>();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        _Host(
          controller: controller,
          size: const Size(700, 400),
          lists: const {
            'a': ['a1'],
            'b': ['b1'],
            'c': ['c1'],
            'd': ['d1'],
          },
        ),
      );
      expect(_rect(tester, 'd1').right, greaterThan(700));
      unawaited(controller.showColumn('d'));
      await tester.pumpAndSettle();
      expect(_rect(tester, 'd1').right, lessThanOrEqualTo(700));
    });
  });

  group('Board right-to-left', () {
    testWidgets('dragging towards the start moves to the earlier column', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const _Host(
          lists: {
            'a': ['a1'],
            'b': ['b1'],
          },
        ),
        textDirection: TextDirection.rtl,
      );
      final from = tester.getCenter(_item('b1'));
      final to = tester.getCenter(_item('a1'));
      expect(to.dx, greaterThan(from.dx));
      final gesture = await _pickUp(tester, 'b1');
      await _dragBy(tester, gesture, to - from);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).lists['a'], contains('b1'));
    });

    testWidgets('the board scrolls towards the pointer', (tester) async {
      await pumpUna(
        tester,
        const _Host(
          size: Size(700, 400),
          lists: {
            'a': ['a1'],
            'b': ['b1'],
            'c': ['c1'],
            'd': ['d1'],
            'e': [],
          },
        ),
        textDirection: TextDirection.rtl,
      );
      final scroll = _boardScroll(tester);
      final gesture = await _pickUp(tester, 'a1');
      // The later columns are off to the left.
      await gesture.moveTo(const Offset(8, 100));
      await tester.pump();
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(scroll.pixels, scroll.maxScrollExtent);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).lists['e'], ['a1']);
    });
  });
}
