// Seeded random runs over a reorderable list, as `board_fuzz_test.dart`
// does over a board: drags with a mouse and a finger by the row and by its
// handle, keys, the list changed underneath, scrolled, switched off,
// hidden, covered by a page and sent to the background — in any order.
//
// A run fails on any exception, on a lifted copy that is still there when
// everything has come to rest, and on a list that never comes to rest. To
// hunt, run with `--dart-define=FUZZ_HUNT=300` (that many seeds per form);
// keep every seed that finds something in `_seeds`.
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// How the list is hosted.
enum _Form {
  /// A `ReorderableListView` that fills its box and scrolls.
  box,

  /// A `SliverReorderableListView` between other slivers.
  sliver,

  /// A shrink-wrapped list in a page that scrolls.
  shrinkWrap,
}

const _hunt = int.fromEnvironment('FUZZ_HUNT');

const _seeds = <_Form, List<int>>{
  _Form.box: [0, 1, 2, 3, 63, 104, 145, 149, 175],
  _Form.sliver: [0, 1, 2, 3, 63, 104, 145, 149, 175],
  _Form.shrinkWrap: [0, 1, 2, 3, 63, 104, 175],
};

class _Host extends StatefulWidget {
  const _Host({required this.form});

  final _Form form;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  List<String> items = [for (var i = 0; i < 30; i++) 'r$i'];
  bool enabled = true;
  bool apply = true;
  bool reduce = false;
  bool rtl = false;
  bool ticking = true;
  bool visible = true;
  bool longPress = true;
  double width = 420;
  final scroll = ScrollController();
  final pending = <(String, int)>[];

  void change(VoidCallback body) => setState(body);

  /// Carries a move out if it still makes sense: the list may have been
  /// changed since it was asked for.
  void applyMove(String item, int to) {
    if (!items.remove(item)) return;
    items.insert(min(to, items.length), item);
  }

  void onReorder(int from, int to) {
    if (from >= items.length) return;
    final item = items[from];
    if (apply) {
      setState(() => applyMove(item, to));
    } else {
      pending.add((item, to));
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  Widget row(BuildContext context, int index) {
    final item = items[index];
    final number = int.tryParse(item.substring(1)) ?? 0;
    return ListTile(
      key: ValueKey('row-$item'),
      // Every third row is a button: a focus node inside the row.
      onTap: number % 3 == 0 ? () {} : null,
      title: Text(item),
      subtitle: number.isEven ? const Text('more') : null,
      // Every fourth has no handle and is its own Tab stop.
      trailing: number % 4 == 1 ? null : const ReorderableDragHandle(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget list = switch (widget.form) {
      _Form.box => ReorderableListView.builder(
        controller: scroll,
        enabled: enabled,
        longPressToDrag: longPress,
        itemCount: items.length,
        itemId: (index) => items[index],
        itemBuilder: row,
        onReorder: onReorder,
      ),
      _Form.sliver => CustomScrollView(
        controller: scroll,
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 130)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverReorderableListView(
              enabled: enabled,
              longPressToDrag: longPress,
              itemCount: items.length,
              itemId: (index) => items[index],
              itemBuilder: row,
              onReorder: onReorder,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 700)),
        ],
      ),
      _Form.shrinkWrap => SingleChildScrollView(
        controller: scroll,
        child: Column(
          children: [
            const SizedBox(height: 90),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              enabled: enabled,
              longPressToDrag: longPress,
              onReorder: onReorder,
              children: [
                for (var i = 0; i < items.length; i++) row(context, i),
              ],
            ),
            const SizedBox(height: 300),
          ],
        ),
      ),
    };
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      // No overscroll effect: Flutter's own indicator starts its ticker
      // twice when a TickerMode above it is toggled mid-glow, which is not
      // what this is looking for.
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
                  TickerMode(enabled: ticking, child: list),
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
  for (final MapEntry(key: form, value: kept) in _seeds.entries) {
    final seeds = _hunt > 0 ? [for (var i = 0; i < _hunt; i++) i] : kept;
    for (final seed in seeds) {
      testWidgets('seed $seed, ${form.name}', (tester) async {
        final random = Random(seed);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1000, 600);
        addTearDown(tester.view.reset);
        addTearDown(
          () => tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          ),
        );
        await tester.pumpWidget(UnaApp(home: _Host(form: form)));
        await tester.pump(const Duration(milliseconds: 300));

        final hostFinder = find.byType(_Host, skipOffstage: false);
        final host = tester.state<_HostState>(hostFinder);
        NavigatorState navigator() => Navigator.of(tester.element(hostFinder));
        final copies = find.byWidgetPredicate(
          (widget) => '${widget.runtimeType}'.startsWith('_ProxyView'),
          skipOffstage: false,
        );
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

        T pick<T>(List<T> from) => from[random.nextInt(from.length)];

        for (var step = 0; step < 120; step++) {
          final op = random.nextInt(27);
          log.add(op);
          switch (op) {
            case 0 || 1:
              // Press on a row, or on a handle.
              if (gesture != null) break;
              final candidates =
                  (random.nextBool()
                          ? find.byType(ReorderableDragHandle)
                          : find.byType(ListTile))
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
                  (random.nextDouble() - .5) * 300,
                  (random.nextDouble() - .5) * 500,
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
              if (host.items.isEmpty) break;
              final victim = pick(host.items);
              host.change(() => host.items.remove(victim));
            case 9:
              host.change(
                () => host.items.insert(
                  random.nextInt(host.items.length + 1),
                  'n${counter++}',
                ),
              );
            case 10:
              // Everything goes, or a few come back.
              if (random.nextInt(6) == 0) {
                host.change(() => host.items = []);
              } else if (host.items.length < 4) {
                host.change(
                  () => host.items = [
                    for (var i = 0; i < 12; i++) 'n${counter++}',
                  ],
                );
              }
            case 11:
              host.change(() => host.enabled = !host.enabled);
            case 12:
              host.change(() {
                host.apply = !host.apply;
                if (host.apply) {
                  for (final (item, to) in host.pending) {
                    host.applyMove(item, to);
                  }
                  host.pending.clear();
                }
              });
            case 13:
              host.change(() => host.reduce = random.nextInt(4) == 0);
            case 14:
              host.change(() => host.longPress = random.nextBool());
            case 15:
              host.change(() => host.items.shuffle(random));
            case 16:
              await tester.sendKeyEvent(pick(_keys));
            case 17:
              host.change(
                () => host.width = 260 + random.nextInt(600).toDouble(),
              );
            case 18:
              host.change(() => host.rtl = random.nextInt(4) == 0);
            case 19 || 20:
              if (!host.scroll.hasClients) break;
              final position = host.scroll.position;
              final to =
                  position.minScrollExtent +
                  random.nextDouble() *
                      (position.maxScrollExtent - position.minScrollExtent);
              if (random.nextBool()) {
                position.jumpTo(to);
              } else {
                // Not awaited: it completes only as frames are pumped.
                position
                    .animateTo(
                      to,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    )
                    .ignore();
              }
            case 21:
              host.change(() => host.items = host.items.reversed.toList());
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
                          ? UnaPageRoute<void>(
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

        // Everything is let go of, shown again and given time: the list
        // comes to rest and no copy is left behind.
        await gesture?.up();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        while (routes-- > 0) {
          navigator().pop();
          await tester.pump();
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
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
          copies,
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
