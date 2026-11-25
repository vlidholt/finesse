// Regressions found by review of the Board: state that must survive a
// change around it, moves that must be refused, and lifted copies that must
// not outlive the moment they belong to.
import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// How many `State`s were created per name, so a re-inflated subtree shows.
final Map<String, int> _inits = {};

/// How many times the item builder ran per name.
final Map<String, int> _builds = {};

class _Probe extends StatefulWidget {
  const _Probe(this.name, {required this.child});

  final String name;
  final Widget child;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _inits[widget.name] = (_inits[widget.name] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Host extends StatefulWidget {
  const _Host({
    required this.lists,
    this.limits = const {},
    this.applyMoves = true,
    this.controller,
    this.onMoveExtra,
    this.onItemPressed,
    this.dragTrigger = BoardDragTrigger.item,
    this.canMove,
    super.key,
  });

  final Map<String, List<String>> lists;
  final Map<String, int> limits;
  final bool applyMoves;
  final BoardController<String>? controller;
  final void Function(BuildContext context, BoardMove<String> move)?
  onMoveExtra;
  final void Function(BuildContext context, String item)? onItemPressed;
  final BoardDragTrigger dragTrigger;
  final bool Function(BoardMove<String> move)? canMove;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late final lists = {
    for (final entry in widget.lists.entries) entry.key: [...entry.value],
  };
  final moves = <BoardMove<String>>[];
  final ended = <String>[];
  bool enabled = true;

  void change(VoidCallback body) => setState(body);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 960,
        height: 500,
        child: Board<String>(
          controller: widget.controller,
          enabled: enabled,
          expandColumns: false,
          dragTrigger: widget.dragTrigger,
          canMove: widget.canMove,
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
            final name = '${details.dragging ? 'lifted' : 'item'}-$item';
            _builds[name] = (_builds[name] ?? 0) + 1;
            return Card(
              style: const CardTheme(padding: EdgeInsets.zero),
              onTap: widget.onItemPressed == null
                  ? null
                  : () => widget.onItemPressed!(context, item),
              child: _Probe(
                name,
                child: SizedBox(
                  key: ValueKey(name),
                  height: 56,
                  child: Row(
                    children: [
                      if (widget.dragTrigger == BoardDragTrigger.handle)
                        BoardDragHandle(
                          child: _Probe(
                            'handle-$name',
                            child: const SizedBox.square(dimension: 24),
                          ),
                        ),
                      Text(item),
                    ],
                  ),
                ),
              ),
            );
          },
          onMove: (move) {
            moves.add(move);
            widget.onMoveExtra?.call(context, move);
            if (!widget.applyMoves) return;
            setState(() {
              move.apply(lists[move.fromColumn]!, lists[move.toColumn]!);
            });
          },
        ),
      ),
    );
  }
}

Finder _item(String id) => find.byKey(ValueKey('item-$id'));
Finder _lifted(String id) =>
    find.byKey(ValueKey('lifted-$id'), skipOffstage: false);
_HostState _host(WidgetTester tester) =>
    tester.state(find.byType(_Host, skipOffstage: false));

ScrollPosition _columnScroll(WidgetTester tester, String column) {
  final columnFinder = find.ancestor(
    of: find.text('Column $column'),
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

/// Where the overlay child that [finder] is in comes in the overlay's
/// paint order.
int _overlayOrder(WidgetTester tester, Finder finder) {
  var node = tester.renderObject(finder);
  RenderObject? child;
  while ('${node.runtimeType}' != '_RenderTheater') {
    child = node;
    node = node.parent!;
  }
  final children = <RenderObject>[];
  node.visitChildren(children.add);
  return children.indexOf(child!);
}

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

List<String> _letters(int count, String prefix) => [
  for (var i = 0; i < count; i++) '$prefix$i',
];

const _abc = {
  'a': ['a1', 'a2', 'a3'],
  'b': ['b1'],
};

Future<void> _focus(WidgetTester tester, String id) async {
  Focus.of(tester.element(_item(id))).requestFocus();
  await tester.pump();
}

/// Drops a1 below a2 with a mouse and returns with the copy still in the
/// air.
Future<void> _dropA1BelowA2(WidgetTester tester) async {
  final gesture = await _pickUp(tester, 'a1');
  await _dragBy(tester, gesture, const Offset(0, 72));
  await gesture.up();
  await gesture.removePointer();
  await tester.pump(const Duration(milliseconds: 16));
  expect(_lifted('a1'), findsOneWidget, reason: 'still flying');
}

void main() {
  setUp(() {
    _inits.clear();
    _builds.clear();
  });

  group('a lifted copy never outlives the board ticking', () {
    Future<GlobalKey<NavigatorState>> pumpApp(
      WidgetTester tester,
      Widget home,
    ) async {
      final nav = GlobalKey<NavigatorState>();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(FinesseApp(navigatorKey: nav, home: home));
      await tester.pumpAndSettle();
      return nav;
    }

    FinessePageRoute<void> page() => FinessePageRoute<void>(
      builder: (context) => const ColoredBox(
        color: Color(0xffffffff),
        child: Center(child: Text('details')),
      ),
    );

    testWidgets('a page opened from a card while another is still landing '
        'has no copy left on top of it', (tester) async {
      await pumpApp(
        tester,
        _Host(
          lists: _abc,
          onItemPressed: (context, item) => Navigator.of(context).push(page()),
        ),
      );
      await _dropA1BelowA2(tester);

      // The card: the centre of the item's own box is the empty middle of
      // its row, which nothing in the item answers.
      await tester.tap(
        find.ancestor(of: _item('b1'), matching: find.byType(Card)),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('a route pushed from onMove has no copy left on top of it', (
      tester,
    ) async {
      await pumpApp(
        tester,
        _Host(
          lists: _abc,
          onMoveExtra: (context, move) => Navigator.of(context).push(page()),
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 72));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('details'), findsOneWidget);
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('a flight covered by a page neither freezes under it nor '
        'resumes on the way back', (tester) async {
      final nav = await pumpApp(tester, const _Host(lists: _abc));
      await _dropA1BelowA2(tester);
      nav.currentState!.push(page());
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
      expect(_lifted('a1'), findsNothing);

      nav.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a1'), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // The board is whole again: the dropped card is painted in its slot
      // and can be picked up.
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      final again = await _pickUp(tester, 'a1');
      expect(_lifted('a1'), findsOneWidget);
      await again.up();
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('a dialog opened from onMove is painted over the card that '
        'was dropped, which lands under it', (tester) async {
      await pumpApp(
        tester,
        _Host(
          lists: _abc,
          onMoveExtra: (context, move) => showDialog<void>(
            context: context,
            builder: (context) => const Dialog(title: Text('Moved')),
          ),
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 72));
      await gesture.up();
      // The dialog is in the overlay from the second frame; the card is
      // still in the air then, and under it.
      await tester.pump();
      var seen = 0;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (_lifted('a1').evaluate().isEmpty) break;
        if (find.text('Moved').evaluate().isEmpty) continue;
        seen++;
        expect(
          _overlayOrder(tester, _lifted('a1')),
          lessThan(_overlayOrder(tester, find.text('Moved'))),
          reason: 'frame $i: the copy is painted over the dialog',
        );
      }
      expect(seen, greaterThan(3), reason: 'the two were never up together');
      await tester.pumpAndSettle();
      expect(find.text('Moved'), findsOneWidget);
      expect(_lifted('a1'), findsNothing);
      expect(tester.takeException(), isNull);
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
    });

    testWidgets('a page pushed while a card is in the air is painted over '
        'it from its first frame', (tester) async {
      final nav = await pumpApp(tester, const _Host(lists: _abc));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 72));
      nav.currentState!.push(page());
      await tester.pump();
      var seen = 0;
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (_lifted('a1').evaluate().isEmpty) break;
        final details = find.text('details', skipOffstage: false);
        if (details.evaluate().isEmpty) continue;
        seen++;
        expect(
          _overlayOrder(tester, _lifted('a1')),
          lessThan(_overlayOrder(tester, details)),
          reason: 'frame $i: the copy is painted over the page',
        );
      }
      expect(seen, greaterThan(3));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('a held card is put back when a page covers the board', (
      tester,
    ) async {
      final nav = await pumpApp(tester, const _Host(lists: _abc));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 72));
      expect(_lifted('a1'), findsOneWidget);
      nav.currentState!.push(page());
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsNothing);
      final host = _host(tester);
      expect(host.moves, isEmpty);
      expect(host.ended, ['a1']);
      await gesture.moveBy(const Offset(0, 10));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(host.moves, isEmpty);
    });

    testWidgets('going off stage in an IndexedStack takes the copy down', (
      tester,
    ) async {
      var index = 0;
      late StateSetter setIndex;
      await pumpApp(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setIndex = setState;
            return IndexedStack(
              index: index,
              children: const [
                _Host(lists: _abc),
                Center(child: Text('other tab')),
              ],
            );
          },
        ),
      );
      await _dropA1BelowA2(tester);
      setIndex(() => index = 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a1'), findsNothing);
      await tester.pumpAndSettle();

      // A held one is put back too.
      setIndex(() => index = 0);
      await tester.pumpAndSettle();
      final gesture = await _pickUp(tester, 'a2');
      await _dragBy(tester, gesture, const Offset(0, 72));
      expect(_lifted('a2'), findsOneWidget);
      setIndex(() => index = 1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a2'), findsNothing);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // And nothing is displaced when the board comes back.
      setIndex(() => index = 0);
      await tester.pumpAndSettle();
      final host = _host(tester);
      final tops = [
        for (final id in host.lists['a']!) tester.getRect(_item(id)).top,
      ];
      expect(tops, [...tops]..sort());
      expect(tops[1] - tops[0], tops[2] - tops[1]);
    });

    testWidgets('TickerMode switched off mid-flight takes the copy down', (
      tester,
    ) async {
      var ticking = true;
      late StateSetter setTicking;
      await pumpApp(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setTicking = setState;
            return TickerMode(
              enabled: ticking,
              child: const _Host(lists: _abc),
            );
          },
        ),
      );
      final slots = [
        for (final id in ['a1', 'a2', 'a3']) tester.getRect(_item(id)).top,
      ];
      await _dropA1BelowA2(tester);
      setTicking(() => ticking = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a1'), findsNothing);
      // Every item is where it is laid out: no shift is left half way.
      expect(tester.getRect(_item('a2')).top, slots[0]);
      expect(tester.getRect(_item('a1')).top, slots[1]);
      expect(tester.getRect(_item('a3')).top, slots[2]);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('the app going to the background takes the copy down', (
      tester,
    ) async {
      await pumpApp(tester, const _Host(lists: _abc));
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      await _dropA1BelowA2(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(_lifted('a1'), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      final gesture = await _pickUp(tester, 'a2');
      await _dragBy(tester, gesture, const Offset(0, 72));
      expect(_lifted('a2'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(_lifted('a2'), findsNothing);
      expect(_host(tester).ended, ['a1', 'a2']);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a board moved to another place in the tree mid-flight '
        'leaves no copy behind', (tester) async {
      final key = GlobalKey();
      var deep = false;
      late StateSetter setDeep;
      await pumpApp(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setDeep = setState;
            final host = _Host(key: key, lists: _abc);
            return deep ? Padding(padding: EdgeInsets.zero, child: host) : host;
          },
        ),
      );
      await _dropA1BelowA2(tester);
      setDeep(() => deep = true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_lifted('a1'), findsNothing);
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
    });
  });

  group('state survives what changes around it', () {
    testWidgets('removing a column keeps the scroll offset and the item '
        'state of the columns after it', (tester) async {
      await pumpFinesse(
        tester,
        _Host(
          lists: {
            'a': const ['a1'],
            'b': _letters(30, 'b'),
            'c': const ['c1'],
          },
        ),
      );
      _columnScroll(tester, 'b').jumpTo(200);
      await tester.pump();
      expect(_inits['item-c1'], 1);

      _host(tester).change(() => _host(tester).lists.remove('a'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_inits['item-c1'], 1, reason: 'c1 was re-created');
      expect(_columnScroll(tester, 'b').pixels, 200);
    });

    testWidgets('reordering the columns keeps their state', (tester) async {
      await pumpFinesse(
        tester,
        _Host(
          lists: {
            'a': const ['a1'],
            'b': _letters(30, 'b'),
            'c': const ['c1'],
          },
        ),
      );
      _columnScroll(tester, 'b').jumpTo(200);
      await tester.pump();
      final host = _host(tester);
      host.change(() {
        final a = host.lists.remove('a')!;
        host.lists['a'] = a;
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(_inits['item-a1'], 1);
      expect(_inits['item-c1'], 1);
      expect(_columnScroll(tester, 'b').pixels, 200);
    });

    testWidgets("toggling enabled keeps every item's state", (tester) async {
      await pumpFinesse(tester, const _Host(lists: _abc));
      expect(_inits['item-a1'], 1);
      _host(tester).change(() => _host(tester).enabled = false);
      await tester.pumpAndSettle();
      expect(_inits['item-a1'], 1, reason: 're-created when disabled');
      _host(tester).change(() => _host(tester).enabled = true);
      await tester.pumpAndSettle();
      expect(_inits['item-a1'], 1, reason: 're-created when re-enabled');
    });

    testWidgets('toggling enabled keeps the state inside a drag handle', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(lists: _abc, dragTrigger: BoardDragTrigger.handle),
      );
      expect(_inits['handle-item-a1'], 1);
      _host(tester).change(() => _host(tester).enabled = false);
      await tester.pumpAndSettle();
      expect(_inits['handle-item-a1'], 1);
      // A disabled handle does not pick anything up.
      final gesture = await tester.startGesture(
        tester.getTopLeft(_item('a1')) + const Offset(12, 28),
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(gesture.removePointer);
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump();
      expect(_lifted('a1'), findsNothing);
      await gesture.up();
      _host(tester).change(() => _host(tester).enabled = true);
      await tester.pumpAndSettle();
      expect(_inits['handle-item-a1'], 1);
    });

    testWidgets('an item keeps its state when it moves to another column', (
      tester,
    ) async {
      final controller = BoardController<String>();
      addTearDown(controller.dispose);
      await pumpFinesse(tester, _Host(controller: controller, lists: _abc));
      expect(_inits['item-a1'], 1);
      controller.move('a1', toColumn: 'a', toIndex: 1);
      await tester.pumpAndSettle();
      expect(_inits['item-a1'], 1, reason: 'lost on a reorder');
      controller.move('a1', toColumn: 'b');
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], contains('a1'));
      expect(_inits['item-a1'], 1, reason: 'lost on a move across columns');
    });

    testWidgets('an item dragged to another column keeps its state', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(lists: _abc));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).lists['b'], contains('a1'));
      expect(_inits['item-a1'], 1);
    });

    testWidgets('the lifted copy keeps its state through the release and '
        'the fade', (tester) async {
      await pumpFinesse(tester, const _Host(lists: _abc));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 70));
      expect(_inits['lifted-a1'], 1);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a1'), findsOneWidget, reason: 'still flying');
      expect(_inits['lifted-a1'], 1, reason: 'rebuilt from scratch');
      // Removed mid-flight, it fades: one more change of wrappers.
      _host(tester).change(() => _host(tester).lists['a']!.remove('a1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(_lifted('a1'), findsOneWidget, reason: 'fading');
      expect(_inits['lifted-a1'], 1, reason: 'rebuilt when it began to fade');
      await tester.pumpAndSettle();
    });
  });

  testWidgets('an item sent to another column in the very frame motion is '
      'switched off is simply there, and the lazy list does not assert', (
    tester,
  ) async {
    // The new slot is created wanting to be kept alive — its item is about
    // to fly — and in the same frame the flight is called off. A lazy list
    // asserts if a child withdraws that wish before it has been told of it.
    var reduce = false;
    late StateSetter setReduce;
    await pumpFinesse(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          setReduce = setState;
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
            child: const _Host(lists: _abc),
          );
        },
      ),
    );
    final host = _host(tester);
    setReduce(() => reduce = true);
    host.change(() {
      host.lists['a']!.remove('a1');
      host.lists['b']!.add('a1');
    });
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(_lifted('a1'), findsNothing);
    expect(
      tester.getRect(_item('a1')).top,
      greaterThan(tester.getRect(_item('b1')).top),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_inits['item-a1'], 1);
  });

  group('reduced motion', () {
    testWidgets('nothing is drawn out of place in the frame after a drop', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpFinesse(tester, const _Host(lists: _abc));
      final slots = [
        for (final id in ['a1', 'a2', 'a3']) tester.getRect(_item(id)).top,
      ];
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 70));
      await gesture.up();
      // The frame in which the parent has rebuilt.
      await tester.pump();
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      expect(tester.getRect(_item('a2')).top, slots[0]);
      expect(tester.getRect(_item('a1')).top, slots[1]);
      expect(tester.getRect(_item('a3')).top, slots[2]);
      await tester.pumpAndSettle();
    });

    testWidgets('a move across columns leaves nothing out of place either', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpFinesse(tester, const _Host(lists: _abc));
      final slots = [
        for (final id in ['a1', 'a2', 'a3']) tester.getRect(_item(id)).top,
      ];
      final b1 = tester.getRect(_item('b1'));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      await gesture.up();
      await tester.pump();
      expect(_host(tester).lists['b'], ['a1', 'b1']);
      expect(tester.getRect(_item('a2')).top, slots[0]);
      expect(tester.getRect(_item('a3')).top, slots[1]);
      expect(tester.getRect(_item('a1')).top, b1.top);
      expect(tester.getRect(_item('b1')).top, slots[1]);
      await tester.pumpAndSettle();
    });
  });

  group('a drop is checked against the rules as they are when it happens', () {
    testWidgets('a keyboard drop into a column that filled up meanwhile is '
        'refused', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
          limits: {'b': 2},
        ),
      );
      await _focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      final host = _host(tester);
      host.change(() => host.lists['b']!.add('b2'));
      await tester.pumpAndSettle();
      expect(_lifted('a1'), findsOneWidget, reason: 'still held');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(host.moves, isEmpty);
      expect(host.lists['b'], hasLength(2));
      expect(_lifted('a1'), findsNothing);
    });

    testWidgets('a pointer drop is refused when canMove changed its mind '
        'without a rebuild', (tester) async {
      var allowed = true;
      final nav = GlobalKey<NavigatorState>();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);
      final moves = <BoardMove<String>>[];
      final lists = {
        'a': ['a1', 'a2'],
        'b': ['b1'],
      };
      await tester.pumpWidget(
        FinesseApp(
          navigatorKey: nav,
          home: Board<String>(
            expandColumns: false,
            canMove: (move) => allowed,
            columns: [
              for (final e in lists.entries)
                BoardColumn(id: e.key, label: e.key, items: e.value),
            ],
            itemBuilder: (context, item, details) => Card(
              style: const CardTheme(padding: EdgeInsets.zero),
              child: SizedBox(
                key: ValueKey('${details.dragging ? 'lifted' : 'item'}-$item'),
                height: 56,
                child: Text(item),
              ),
            ),
            onMove: moves.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      allowed = false;
      await gesture.up();
      await tester.pumpAndSettle();
      expect(moves, isEmpty);
    });
  });

  group('a drag costs what changes, not what moves', () {
    RenderObject liftedRender(WidgetTester tester) => tester.renderObject(
      find.byWidgetPredicate(
        (widget) => '${widget.runtimeType}' == '_ProxyTransform',
      ),
    );

    testWidgets('moving a held card builds nothing and paints nothing: it '
        'moves a layer', (tester) async {
      await pumpFinesse(tester, const _Host(lists: _abc));
      final gesture = await _pickUp(tester, 'a1');
      // Let the lift finish: its shadow fades in with it.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final builds = Map.of(_builds);
      var rebuilt = 0;
      debugOnRebuildDirtyWidget = (element, builtOnce) => rebuilt++;
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      final before = tester.getRect(_lifted('a1'));
      for (var i = 0; i < 10; i++) {
        // Sideways, within its own slot: the card moves and leans, and
        // nothing else has any reason to change.
        await gesture.moveBy(Offset(i.isEven ? 6 : -4, 0));
        final render = liftedRender(tester);
        expect(render.debugNeedsPaint, isFalse, reason: 'move $i');
        expect(render.debugNeedsCompositedLayerUpdate, isTrue);
        await tester.pump(const Duration(milliseconds: 16));
      }
      debugOnRebuildDirtyWidget = null;
      expect(rebuilt, 0, reason: 'widgets were rebuilt for a move');
      expect(_builds, builds, reason: 'the item builder ran for a move');
      // And it did move.
      expect(tester.getRect(_lifted('a1')).left, greaterThan(before.left + 5));
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a drop builds the lifted copy twice — when it is picked '
        'up and when the lists change — and no more', (tester) async {
      await pumpFinesse(tester, const _Host(lists: _abc));
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 72));
      expect(_builds['lifted-a1'], 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      expect(_builds['lifted-a1'], 2);
      expect(_inits['lifted-a1'], 1);
    });

    testWidgets('canMove is asked when the target changes and at the '
        'drop, not for every pointer event', (tester) async {
      final asked = <BoardMove<String>>[];
      await pumpFinesse(
        tester,
        _Host(
          lists: _abc,
          canMove: (move) {
            asked.add(move);
            return true;
          },
        ),
      );
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(300, 0));
      final overB = asked.length;
      expect(overB, greaterThan(0));
      expect(asked.last.toColumn, 'b');
      // Fifty events over the same slot.
      for (var i = 0; i < 50; i++) {
        await gesture.moveBy(Offset(i.isEven ? 1 : -1, 0));
        if (i % 5 == 0) await tester.pump(const Duration(milliseconds: 16));
      }
      expect(asked.length, overB);
      // A rebuild may have changed the rules: asked once more.
      _host(tester).change(() {});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(asked.length, overB + 1);
      await gesture.up();
      expect(asked.length, overB + 2, reason: 'not asked again at the drop');
      await tester.pumpAndSettle();
      expect(_host(tester).moves, hasLength(1));
    });

    testWidgets('items that make way tell the semantics tree where they '
        'are once they have arrived', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, const _Host(lists: _abc));
      final resting = tester.getSemantics(_item('a2')).rect;
      Rect inWindow(SemanticsNode node) => MatrixUtils.transformRect(
        node.transform ?? Matrix4.identity(),
        node.rect,
      );
      SemanticsNode slotNode(String id) {
        // The node of the slot's container, which carries its position.
        var node = tester.getSemantics(_item(id));
        while (node.transform == null && node.parent != null) {
          node = node.parent!;
        }
        return node;
      }

      final home = inWindow(slotNode('a2')).top;
      final gesture = await _pickUp(tester, 'a1');
      await _dragBy(tester, gesture, const Offset(0, 72));
      await tester.pumpAndSettle();
      // a2 has moved up into the slot a1 left, and the tree knows.
      final shifted = inWindow(slotNode('a2')).top;
      expect(shifted, lessThan(home - 40));
      expect(tester.getSemantics(_item('a2')).rect, resting);
      await gesture.up();
      await tester.pumpAndSettle();
      handle.dispose();
    });
  });

  group('keyboard', () {
    testWidgets('Tab drops a keyboard drag and the focus moves on', (
      tester,
    ) async {
      await pumpFinesse(tester, const _Host(lists: _abc));
      await _focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(_host(tester).lists['a'], ['a2', 'a1', 'a3']);
      expect(
        Focus.of(tester.element(_item('a1'))).hasFocus,
        isFalse,
        reason: 'focus came back to the dropped item after Tab',
      );
    });

    testWidgets('a move applied late keeps the keyboard focus on the item', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(
          applyMoves: false,
          lists: {
            'a': ['a1', 'a2'],
            'b': ['b1'],
          },
        ),
      );
      await _focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      final host = _host(tester);
      expect(host.moves, hasLength(1));
      // The parent applies the move after a server round trip.
      await tester.pump(const Duration(milliseconds: 300));
      host.change(() {
        final move = host.moves.single;
        move.apply(host.lists[move.fromColumn]!, host.lists[move.toColumn]!);
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(host.lists['b'], contains('a1'));
      expect(Focus.of(tester.element(_item('a1'))).hasFocus, isTrue);
    });

    testWidgets('an item whose copy is in the air is not a Tab stop, and '
        'Tab does not throw when a lazy list keeps it alive off screen', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        _Host(
          lists: {
            'a': _letters(30, 'a'),
            'b': const ['b1'],
          },
          // Cards that are buttons: a focus node inside each item, too.
          onItemPressed: (context, item) {},
        ),
      );
      final hidden = find.byKey(const ValueKey('item-a1'), skipOffstage: false);
      await _focus(tester, 'a0');
      final scope = FocusManager.instance.primaryFocus!.nearestScope!;
      final inner = Focus.of(tester.element(hidden));
      expect(scope.traversalDescendants, contains(inner));

      // Pick a1 up and hold it at the bottom edge until the column has
      // scrolled both it and the focused a0 out of view: the list keeps
      // both slots alive, with no position.
      final gesture = await _pickUp(tester, 'a1');
      await gesture.moveTo(
        Offset(tester.getCenter(_item('a2')).dx, 494),
      );
      for (var i = 0; i < 80; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(_columnScroll(tester, 'a').pixels, greaterThan(400));
      expect(hidden, findsOneWidget, reason: 'kept alive');
      expect(_item('a1'), findsNothing, reason: 'off screen');
      final stops = scope.traversalDescendants.toList();

      // The parent reorders the column under it, and the user presses Tab.
      final host = _host(tester);
      host.change(() {
        final list = host.lists['a']!;
        final reversed = list.reversed.toList();
        list
          ..clear()
          ..addAll(reversed);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'Tab $i');
      }
      expect(
        stops,
        isNot(contains(inner)),
        reason: 'a slot that paints nothing could be tabbed to',
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Back in their slots, the items are Tab stops again.
      _columnScroll(tester, 'a').jumpTo(0);
      await tester.pump();
      for (final id in host.lists['a']!.take(4)) {
        expect(
          scope.traversalDescendants,
          contains(Focus.of(tester.element(_item(id)))),
        );
      }
    });

    testWidgets('Tab from an item that is kept alive off screen, in a '
        'column reordered since, brings it into view and then moves on', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        _Host(
          lists: {
            'a': _letters(30, 'a'),
            'b': const ['b1'],
          },
          // Cards that are buttons: a second Tab stop inside each item.
          onItemPressed: (context, item) {},
        ),
      );
      final kept = find.byKey(const ValueKey('item-a0'), skipOffstage: false);
      // The item itself has the focus: the node above its card's.
      final inner = Focus.of(tester.element(kept));
      final outer = inner.ancestors.firstWhere(
        (node) => node.debugLabel == 'Board item',
      );
      outer.requestFocus();
      await tester.pump();
      expect(outer.hasPrimaryFocus, isTrue);

      // Scrolled away with the wheel, then moved to the end by the parent.
      _columnScroll(tester, 'a').jumpTo(700);
      await tester.pump();
      expect(kept, findsOneWidget, reason: 'kept alive: it has the focus');
      expect(_item('a0'), findsNothing, reason: 'off screen');
      final host = _host(tester);
      host.change(() {
        final list = host.lists['a']!;
        final reversed = list.reversed.toList();
        list
          ..clear()
          ..addAll(reversed);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      // The first Tab brings the item back; the focus has not moved.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(outer.hasPrimaryFocus, isTrue);
      expect(_item('a0'), findsOneWidget, reason: 'not brought into view');
      final rect = tester.getRect(_item('a0'));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(500));

      // The second moves on, to the button inside it.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(inner.hasPrimaryFocus, isTrue);
    });

    testWidgets('End in a long column scrolls to the slot and takes the '
        'held card there', (tester) async {
      await pumpFinesse(
        tester,
        _Host(
          lists: {
            'a': _letters(40, 'a'),
            'b': const ['b1'],
          },
        ),
      );
      await _focus(tester, 'a0');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final position = _columnScroll(tester, 'a');
      expect(position.pixels, position.maxScrollExtent);
      // The held card rests on the slot under the last item.
      final last = tester.getRect(_item('a39'));
      final held = tester.getRect(_lifted('a0'));
      expect(held.top, greaterThan(last.top));
      expect(held.top, lessThan(500));

      // And Home takes it back to the top.
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(position.pixels, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_host(tester).moves, isEmpty);
    });

    testWidgets('a step into a long column scrolled elsewhere brings the '
        'slot into view', (tester) async {
      await pumpFinesse(
        tester,
        _Host(
          lists: {
            'a': const ['a1'],
            'b': _letters(40, 'b'),
          },
        ),
      );
      final position = _columnScroll(tester, 'b');
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      await _focus(tester, 'a1');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(position.pixels, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });
  });
}
