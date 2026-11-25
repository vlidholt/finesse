// Seeded random runs over a Board: drags with a mouse and a finger, keys,
// lists changed under it, columns added and removed, the board switched
// off, hidden, covered by a page and sent to the background — in any order.
//
// A run fails on any exception, on a lifted copy that is still there when
// everything has come to rest, and on a board that never comes to rest.
// The seeds kept here are a few ordinary ones and every one that has found
// something; to hunt, raise the count in `_seeds`.
import 'dart:math';

import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Seeds for a board whose columns scroll, and for a shrink-wrapped one.
///
/// Before the fixes they lock, 21 and 24 threw in Tab — the focus
/// traversal scrolling to a slot a lazy list was keeping alive off screen,
/// which has no position — 77 asserted in Tab, on a focus node that had
/// never been laid out, and 49, 68 and 132 asserted in the lazy list, on a
/// slot that gave up being kept alive in the frame it was created in.
const _seeds = <bool, List<int>>{
  false: [0, 1, 2, 3, 21, 24, 49, 68, 77, 132],
  true: [0, 1, 2, 3],
};

class _Host extends StatefulWidget {
  const _Host({required this.shrinkWrap});

  final bool shrinkWrap;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final lists = <String, List<String>>{
    'a': [for (var i = 0; i < 25; i++) 'a$i'],
    'b': [for (var i = 0; i < 3; i++) 'b$i'],
    'c': [],
    'd': [for (var i = 0; i < 12; i++) 'd$i'],
  };
  bool enabled = true;
  bool apply = true;
  bool reduce = false;
  bool rtl = false;
  bool ticking = true;
  bool visible = true;
  double width = 900;
  int? limitB;
  final controller = BoardController<String>();
  final pending = <BoardMove<String>>[];

  void change(VoidCallback body) => setState(body);

  /// Carries [move] out if it still makes sense: the lists may have been
  /// changed since it was asked for.
  void applyMove(BoardMove<String> move) {
    final from = lists[move.fromColumn];
    final to = lists[move.toColumn];
    if (from == null || to == null) return;
    if (!from.remove(move.item)) return;
    to.insert(min(move.toIndex, to.length), move.item);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = Board<String>(
      controller: controller,
      enabled: enabled,
      shrinkWrap: widget.shrinkWrap,
      expandColumns: false,
      columns: [
        for (final entry in lists.entries)
          BoardColumn(
            id: entry.key,
            label: entry.key,
            items: entry.value,
            limit: entry.key == 'b' ? limitB : null,
          ),
      ],
      itemBuilder: (context, item, details) => Card(
        padding: EdgeInsets.zero,
        // Every other card is a button: a focus node inside the item.
        onTap: item.hashCode.isEven ? () {} : null,
        child: SizedBox(
          key: ValueKey('${details.dragging ? 'lifted' : 'item'}-$item'),
          height: 40 + (item.hashCode % 3) * 14,
          child: Text(item),
        ),
      ),
      onMove: (move) {
        if (apply) {
          setState(() => applyMove(move));
        } else {
          pending.add(move);
        }
      },
    );
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      // No overscroll glow: Flutter's own indicator starts its ticker twice
      // when a TickerMode above it is toggled mid-glow, which is not what
      // this is looking for.
      child: ScrollConfiguration(
        behavior: const _NoGlow(),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: 500,
              child: IndexedStack(
                index: visible ? 0 : 1,
                children: [
                  TickerMode(
                    enabled: ticking,
                    child: widget.shrinkWrap
                        ? SingleChildScrollView(child: board)
                        : board,
                  ),
                  const Text('elsewhere'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoGlow extends ScrollBehavior {
  const _NoGlow();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

bool _keyStartsWith(Widget widget, String prefix) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith(prefix);
}

const _keys = [
  LogicalKeyboardKey.tab,
  LogicalKeyboardKey.space,
  LogicalKeyboardKey.arrowDown,
  LogicalKeyboardKey.arrowUp,
  LogicalKeyboardKey.arrowRight,
  LogicalKeyboardKey.arrowLeft,
  LogicalKeyboardKey.escape,
  LogicalKeyboardKey.end,
  LogicalKeyboardKey.home,
  LogicalKeyboardKey.enter,
];

const _lifecycle = [
  AppLifecycleState.resumed,
  AppLifecycleState.inactive,
  AppLifecycleState.hidden,
  AppLifecycleState.paused,
];

void main() {
  for (final MapEntry(key: shrinkWrap, value: seeds) in _seeds.entries) {
    for (final seed in seeds) {
      testWidgets('seed $seed, shrinkWrap $shrinkWrap', (tester) async {
        final random = Random(seed);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 600);
        addTearDown(tester.view.reset);
        addTearDown(
          () => tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          ),
        );
        await tester.pumpWidget(
          FinesseApp(home: _Host(shrinkWrap: shrinkWrap)),
        );
        await tester.pump(const Duration(milliseconds: 300));

        final hostFinder = find.byType(_Host, skipOffstage: false);
        final host = tester.state<_HostState>(hostFinder);
        NavigatorState navigator() => Navigator.of(tester.element(hostFinder));
        TestGesture? gesture;
        var counter = 0;
        var routes = 0;
        final log = <int>[];

        void check() {
          final exception = tester.takeException();
          if (exception != null) {
            fail('seed $seed: $exception\nops: ${log.join(', ')}');
          }
        }

        List<String> all() => [for (final list in host.lists.values) ...list];
        T pick<T>(List<T> from) => from[random.nextInt(from.length)];

        for (var step = 0; step < 120; step++) {
          final op = random.nextInt(27);
          log.add(op);
          switch (op) {
            case 0 || 1:
              if (gesture != null) break;
              final candidates = find
                  .byWidgetPredicate((w) => _keyStartsWith(w, 'item-'))
                  .hitTestable()
                  .evaluate()
                  .toList();
              if (candidates.isEmpty) break;
              final box = pick(candidates).renderObject! as RenderBox;
              gesture = await tester.startGesture(
                box.localToGlobal(box.size.center(Offset.zero)),
                kind: random.nextBool()
                    ? PointerDeviceKind.mouse
                    : PointerDeviceKind.touch,
              );
              if (random.nextBool()) {
                await tester.pump(const Duration(milliseconds: 600));
              }
            case 2 || 3 || 4 || 5:
              await gesture?.moveBy(
                Offset(
                  (random.nextDouble() - .5) * 500,
                  (random.nextDouble() - .5) * 400,
                ),
              );
            case 6:
              await gesture?.up();
              gesture = null;
            case 7:
              if (gesture != null && random.nextInt(3) == 0) {
                await gesture.cancel();
                gesture = null;
              }
            case 8:
              final items = all();
              if (items.isEmpty) break;
              final victim = pick(items);
              host.change(() {
                for (final list in host.lists.values) {
                  list.remove(victim);
                }
              });
            case 9:
              final list = host.lists[pick(host.lists.keys.toList())]!;
              host.change(
                () => list.insert(
                  random.nextInt(list.length + 1),
                  'n${counter++}',
                ),
              );
            case 10:
              final keys = host.lists.keys.toList();
              if (keys.length > 1 && random.nextInt(3) == 0) {
                host.change(() => host.lists.remove(pick(keys)));
              } else if (random.nextInt(3) == 0) {
                host.change(
                  () => host.lists['k${counter++}'] = ['n${counter++}'],
                );
              }
            case 11:
              host.change(() => host.enabled = !host.enabled);
            case 12:
              host.change(() {
                host.apply = !host.apply;
                if (host.apply) {
                  host.pending
                    ..forEach(host.applyMove)
                    ..clear();
                }
              });
            case 13:
              host.change(() => host.reduce = random.nextInt(4) == 0);
            case 14:
              final items = all();
              if (items.isEmpty) break;
              host.controller.move(
                pick(items),
                toColumn: pick(host.lists.keys.toList()),
                toIndex: random.nextBool() ? random.nextInt(5) : null,
              );
            case 15:
              host.change(() {
                for (final list in host.lists.values) {
                  list.shuffle(random);
                }
              });
            case 16:
              await tester.sendKeyEvent(pick(_keys));
            case 17:
              host.change(
                () => host.width = 300 + random.nextInt(700).toDouble(),
              );
            case 18:
              host.change(() => host.rtl = random.nextInt(4) == 0);
            case 19:
              host.change(() => host.limitB = random.nextBool() ? null : 3);
            case 20:
              host.controller.cancelDrag();
            case 21:
              // Not awaited: it completes only as frames are pumped.
              host.controller
                  .showColumn(pick(host.lists.keys.toList()))
                  .ignore();
            case 22:
              host.change(() => host.ticking = random.nextInt(3) != 0);
            case 23:
              host.change(() => host.visible = random.nextInt(3) != 0);
            case 24:
              if (routes < 2 && random.nextBool()) {
                routes++;
                navigator()
                    .push(
                      random.nextBool()
                          ? FinessePageRoute<void>(
                              builder: (context) => const Text('page'),
                            )
                          : PageRouteBuilder<void>(
                              opaque: false,
                              pageBuilder: (context, _, _) =>
                                  const Text('veil'),
                            ),
                    )
                    .ignore();
              } else if (routes > 0) {
                routes--;
                navigator().pop();
              }
            case 25:
              tester.binding.handleAppLifecycleStateChanged(pick(_lifecycle));
            case 26:
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          }
          await tester.pump(
            Duration(milliseconds: pick(const [0, 1, 16, 16, 16, 50, 400])),
          );
          check();
        }

        // Everything is let go of, shown again and given time: the board
        // comes to rest and no copy is left behind.
        await gesture?.up();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        while (routes-- > 0) {
          navigator().pop();
          await tester.pump();
        }
        host.controller.cancelDrag();
        host.change(() {
          host
            ..apply = true
            ..enabled = true
            ..ticking = true
            ..visible = true;
          host.pending.clear();
        });
        for (var i = 0; i < 200; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        check();
        expect(
          find.byWidgetPredicate(
            (w) => _keyStartsWith(w, 'lifted-'),
            skipOffstage: false,
          ),
          findsNothing,
          reason: 'seed $seed ops: ${log.join(', ')}',
        );
        expect(
          tester.binding.hasScheduledFrame,
          isFalse,
          reason: 'seed $seed: still animating. ops: ${log.join(', ')}',
        );
        await tester.pumpWidget(const SizedBox());
        check();
      });
    }
  }
}
