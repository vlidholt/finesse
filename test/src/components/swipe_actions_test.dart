import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../frame_sampler.dart';
import '../../una_harness.dart';

void main() {
  // Haptics are silent under `flutter test` unless a test asks.
  setUp(() => Haptics.debugEnabledInTests = true);
  tearDown(() => Haptics.debugEnabledInTests = false);

  late List<String> log;

  setUp(() => log = []);

  SwipeAction action(
    String label, {
    bool destructive = false,
    FutureOr<bool> Function()? onPressed,
  }) => SwipeAction(
    icon: const SizedBox(width: 20, height: 20),
    label: label,
    destructive: destructive,
    onPressed:
        onPressed ??
        () {
          log.add(label);
          return false;
        },
  );

  Widget row({
    List<SwipeAction>? leading,
    List<SwipeAction>? trailing,
    bool fullSwipe = true,
    bool enabled = true,
    bool contextMenu = true,
    VoidCallback? onRemoved,
    VoidCallback? onTap,
    Key key = const Key('row'),
    String title = 'Message',
  }) => SwipeActions(
    key: key,
    leading: leading ?? [action('Pin')],
    trailing:
        trailing ?? [action('Delete', destructive: true), action('Archive')],
    fullSwipe: fullSwipe,
    enabled: enabled,
    contextMenu: contextMenu,
    onOpened: () => log.add('opened'),
    onClosed: () => log.add('closed'),
    onRemoved: onRemoved,
    child: ListTile(
      title: Text(title),
      onTap: onTap ?? () => log.add('tap'),
    ),
  );

  Widget host(Widget child) => Align(
    alignment: Alignment.topCenter,
    child: SizedBox(width: 400, child: child),
  );

  /// How far the row's content is shifted, positive to the right.
  double shiftOf(WidgetTester tester, [Key key = const Key('row')]) {
    // The row's shift is the one keyed transform under it.
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byKey(key),
        matching: find.byWidgetPredicate(
          (widget) => widget is Transform && widget.key != null,
        ),
      ),
    );
    return transform.transform.getTranslation().x;
  }

  Future<void> swipe(
    WidgetTester tester,
    double dx, {
    Finder? on,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    bool release = true,
  }) async {
    final gesture = await tester.startGesture(
      tester.getCenter(on ?? find.text('Message')),
      kind: kind,
    );
    final step = dx.sign * 10;
    for (var moved = 0.0; moved.abs() < dx.abs(); moved += step) {
      await gesture.moveBy(Offset(step, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (release) {
      await gesture.up();
      await tester.pumpAndSettle();
    } else {
      addTearDown(gesture.removePointer);
    }
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

  group('SwipeActions at rest', () {
    testWidgets('builds no actions, clips nothing and schedules nothing', (
      tester,
    ) async {
      await pumpUna(tester, host(row()));
      expect(find.text('Delete'), findsNothing);
      final clip = tester.widget<ClipRect>(
        find.descendant(
          of: find.byKey(const Key('row')),
          matching: find.byType(ClipRect),
        ),
      );
      expect(clip.clipBehavior, Clip.none);
      expect(shiftOf(tester), 0);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a tap goes to the row', (tester) async {
      await pumpUna(tester, host(row()));
      await tester.tap(find.text('Message'));
      await tester.pumpAndSettle();
      expect(log, ['tap']);
    });

    testWidgets('builds in every layout at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: host(row()),
        ),
      );
    });
  });

  group('SwipeActions touch', () {
    testWidgets('the row follows the finger and uncovers the trailing '
        'actions', (tester) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -60, release: false);
      // The first ~18px are the touch slop.
      expect(shiftOf(tester), lessThan(-30));
      expect(shiftOf(tester), greaterThanOrEqualTo(-60));
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Pin'), findsNothing);
      // First is outermost: Delete at the right edge.
      expect(
        tester.getCenter(find.text('Delete')).dx,
        greaterThan(tester.getCenter(find.text('Archive')).dx),
      );
    });

    testWidgets('released past half it stays open, and a tap on an action '
        'runs it and closes', (tester) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -120);
      final open = shiftOf(tester);
      expect(open, moreOrLessEquals(-152, epsilon: .5));
      expect(log, ['opened']);
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      expect(log, ['opened', 'Archive', 'closed']);
      expect(shiftOf(tester), 0);
      expect(find.text('Archive'), findsNothing);
    });

    testWidgets('released short of half it closes', (tester) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -60);
      expect(shiftOf(tester), 0);
      expect(log, isEmpty);
    });

    testWidgets('a quick flick opens although the row has barely moved', (
      tester,
    ) async {
      await pumpUna(tester, host(row()));
      await tester.fling(find.text('Message'), const Offset(-50, 0), 1500);
      await tester.pumpAndSettle();
      expect(shiftOf(tester), lessThan(-100));
    });

    testWidgets('the settle is interruptible and comes to rest', (
      tester,
    ) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -120, release: false);
      final gesture = await tester.startGesture(const Offset(5, 500));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 30));
      // Mid-settle the finger takes the row again.
      await swipe(tester, 80, release: false);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });

    testWidgets('an open row closes on a tap on it, without tapping it', (
      tester,
    ) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -120);
      await tester.tapAt(const Offset(500, 20));
      await tester.pumpAndSettle();
      expect(shiftOf(tester), 0);
      expect(log, ['opened', 'closed']);
    });

    testWidgets('an open row closes on a tap outside it', (tester) async {
      await pumpUna(
        tester,
        host(
          Column(
            children: [
              row(),
              const SizedBox(height: 200, child: Text('Elsewhere')),
            ],
          ),
        ),
      );
      await swipe(tester, -120);
      await tester.tap(find.text('Elsewhere'));
      await tester.pumpAndSettle();
      expect(shiftOf(tester), 0);
    });

    testWidgets('swiping the other way uncovers the leading action', (
      tester,
    ) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, 80);
      expect(shiftOf(tester), moreOrLessEquals(76, epsilon: .5));
      expect(find.text('Pin'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('a side without actions does not move', (tester) async {
      await pumpUna(tester, host(row(leading: [])));
      await swipe(tester, 120, release: false);
      expect(shiftOf(tester), 0);
    });

    testWidgets('disabled, nothing moves', (tester) async {
      await pumpUna(tester, host(row(enabled: false)));
      await swipe(tester, -120, release: false);
      expect(shiftOf(tester), 0);
    });
  });

  group('SwipeActions full swipe', () {
    testWidgets('past the threshold the first action spreads, with a '
        'haptic, and runs on release', (tester) async {
      final calls = hapticCalls(tester);
      await pumpUna(tester, host(row()));
      await swipe(tester, -300, release: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, hasLength(1));
      expect(calls.single.arguments, 'HapticFeedbackType.mediumImpact');
      // Delete has taken over the strip.
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('Delete'),
                matching: find.byType(Pressable),
              ),
            )
            .width,
        greaterThan(200),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('releasing there runs the first action', (tester) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -300);
      expect(log, ['Delete']);
      expect(shiftOf(tester), 0);
    });

    testWidgets('with fullSwipe off the row resists past its actions and '
        'only opens', (tester) async {
      await pumpUna(tester, host(row(fullSwipe: false)));
      await swipe(tester, -380, release: false);
      expect(shiftOf(tester), greaterThan(-152 - 76));
      final gesture = await tester.startGesture(const Offset(5, 500));
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('SwipeActions removal', () {
    testWidgets('an action that returns true slides the row out, closes '
        'the gap, then reports', (tester) async {
      var removed = 0;
      await pumpUna(
        tester,
        host(
          Column(
            children: [
              row(
                trailing: [
                  action('Delete', destructive: true, onPressed: () => true),
                ],
                onRemoved: () => removed++,
              ),
              const Text('Below', key: Key('below')),
            ],
          ),
        ),
      );
      final before = tester.getTopLeft(find.byKey(const Key('below'))).dy;
      await swipe(tester, -80);
      await tester.tap(find.text('Delete'));
      final tops = <double>[];
      for (var i = 0; i < 90; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        tops.add(tester.getTopLeft(find.byKey(const Key('below'))).dy);
      }
      expect(removed, 1);
      expect(tops.first, before);
      expect(tops.last, moreOrLessEquals(0, epsilon: .01));
      // The gap only ever closes.
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], lessThanOrEqualTo(tops[i - 1] + 1e-6));
      }
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(const Key('row'))).height, 0);
    });

    testWidgets('a future keeps the row open until it completes', (
      tester,
    ) async {
      final answer = Completer<bool>();
      await pumpUna(
        tester,
        host(
          row(
            trailing: [action('Delete', onPressed: () => answer.future)],
          ),
        ),
      );
      await swipe(tester, -80);
      await tester.tap(find.text('Delete'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(shiftOf(tester), lessThan(0));
      answer.complete(false);
      await tester.pumpAndSettle();
      expect(shiftOf(tester), 0);
    });

    testWidgets('under Motion.none removal is immediate', (tester) async {
      var removed = 0;
      await pumpUna(
        tester,
        host(
          row(
            trailing: [action('Delete', onPressed: () => true)],
            onRemoved: () => removed++,
          ),
        ),
        theme: ThemeData(motion: Motion.none),
      );
      await swipe(tester, -80);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump();
      expect(removed, 1);
    });

    testWidgets('in a list without keys the row that takes a removed '
        "row's place is shown", (tester) async {
      final messages = ['M0', 'M1', 'M2'];
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) => host(
            SizedBox(
              height: 400,
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  // No key: the State of the removed row is given the next
                  // one's widget.
                  return SwipeActions(
                    trailing: [action('Delete', onPressed: () => true)],
                    onRemoved: () => setState(() => messages.remove(message)),
                    child: ListTile(title: Text(message)),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await swipe(tester, -80, on: find.text('M0'));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(messages, ['M1', 'M2']);
      final first = find.byType(SwipeActions, skipOffstage: false).first;
      expect(tester.getSize(first).height, greaterThan(0));
      expect(find.text('M1'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('M1')).dx,
        greaterThan(0),
        reason: 'the row is still slid out',
      );
      // And it can be swiped like any other.
      await swipe(tester, -80, on: find.text('M1'));
      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('SwipeActions and other gestures', () {
    testWidgets('a vertical drag scrolls the list and moves no row', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        ListView(
          controller: controller,
          children: [
            for (var i = 0; i < 30; i++)
              row(key: Key('row$i'), title: 'Message $i'),
          ],
        ),
      );
      await tester.drag(find.text('Message 3'), const Offset(4, -200));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(100));
    });

    testWidgets('scrolling closes an open row', (tester) async {
      await pumpUna(
        tester,
        ListView(
          children: [
            for (var i = 0; i < 30; i++)
              row(key: Key('row$i'), title: 'Message $i'),
          ],
        ),
      );
      await swipe(tester, -120, on: find.text('Message 2'));
      expect(shiftOf(tester, const Key('row2')), lessThan(-100));
      await tester.drag(find.text('Message 6'), const Offset(0, -80));
      await tester.pumpAndSettle();
      expect(shiftOf(tester, const Key('row2')), 0);
    });

    testWidgets('inside a horizontal page view, a row takes only the '
        'direction it has actions for', (tester) async {
      final controller = PageController(initialPage: 1);
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        PageView(
          controller: controller,
          children: [
            const Center(child: Text('Before')),
            Align(
              alignment: Alignment.topCenter,
              child: row(leading: []),
            ),
            const Center(child: Text('After')),
          ],
        ),
      );
      // Towards the start there are trailing actions: the row moves, the
      // page does not.
      await swipe(tester, -120);
      expect(shiftOf(tester), lessThan(-100));
      expect(controller.page, 1);
      await tester.tapAt(const Offset(600, 400));
      await tester.pumpAndSettle();

      // Towards the end there is nothing: the page view gets the drag.
      await tester.fling(find.text('Message'), const Offset(300, 0), 2000);
      await tester.pumpAndSettle();
      expect(controller.page, 0);
    });

    for (final direction in TextDirection.values) {
      testWidgets('a drag from the leading screen edge is left to the back '
          'swipe when the route can pop, ${direction.name}', (tester) async {
        await pumpUna(
          tester,
          Builder(
            builder: (context) => Center(
              child: Button(
                onPressed: () => Navigator.of(context).push(
                  UnaPageRoute<void>(
                    builder: (context) => Directionality(
                      textDirection: direction,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: row(),
                      ),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
          formFactor: FormFactor.mobile,
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final rect = tester.getRect(find.byKey(const Key('row')));
        final ltr = direction == TextDirection.ltr;

        // From inside the edge strip: nothing.
        var gesture = await tester.startGesture(
          Offset(ltr ? 8 : rect.right - 8, rect.center.dy),
        );
        for (var i = 0; i < 12; i++) {
          await gesture.moveBy(Offset(ltr ? 10 : -10, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(shiftOf(tester), 0, reason: direction.name);
        await gesture.up();
        await tester.pumpAndSettle();

        // From just past it: the row.
        gesture = await tester.startGesture(
          Offset(ltr ? 30 : rect.right - 30, rect.center.dy),
        );
        for (var i = 0; i < 12; i++) {
          await gesture.moveBy(Offset(ltr ? 10 : -10, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(shiftOf(tester).abs(), greaterThan(50), reason: direction.name);
        await gesture.up();
        await tester.pumpAndSettle();
      });
    }

    testWidgets("on the first route the leading edge is the row's", (
      tester,
    ) async {
      await pumpUna(
        tester,
        Align(alignment: Alignment.topCenter, child: row()),
        formFactor: FormFactor.mobile,
      );
      final rect = tester.getRect(find.byKey(const Key('row')));
      final gesture = await tester.startGesture(Offset(8, rect.center.dy));
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(shiftOf(tester), greaterThan(50));
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('SwipeActions right to left', () {
    testWidgets('leading is the start side: uncovered by a swipe to the '
        'left', (tester) async {
      await pumpUna(
        tester,
        host(row()),
        textDirection: TextDirection.rtl,
      );
      await swipe(tester, -80);
      expect(find.text('Pin'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
      await tester.tapAt(const Offset(500, 400));
      await tester.pumpAndSettle();
      await swipe(tester, 120);
      expect(find.text('Delete'), findsOneWidget);
      // First is still outermost: Delete at the left edge.
      expect(
        tester.getCenter(find.text('Delete')).dx,
        lessThan(tester.getCenter(find.text('Archive')).dx),
      );
    });
  });

  group('SwipeActions mouse and keyboard', () {
    testWidgets('a mouse drag moves the row', (tester) async {
      await pumpUna(tester, host(row()));
      await swipe(tester, -120, kind: PointerDeviceKind.mouse, release: false);
      expect(shiftOf(tester), lessThan(-50));
    });

    testWidgets('a mouse click that wobbles is still a click', (tester) async {
      var taps = 0;
      await pumpUna(tester, host(row(onTap: () => taps++)));
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Message')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(-1.5, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(shiftOf(tester), 0);
      expect(taps, 1);
    });

    testWidgets('inside a SelectionArea a mouse drag moves the row and '
        'selects nothing', (tester) async {
      await pumpUna(tester, SelectionArea(child: host(row())));
      await swipe(tester, -120, kind: PointerDeviceKind.mouse, release: false);
      expect(shiftOf(tester), lessThan(-50));
    });

    testWidgets('two fingers sideways in a browser (scroll events) drag the '
        'row, and it settles once they stop', (tester) async {
      await pumpUna(tester, host(row()));
      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.text('Message'))),
      );
      for (var i = 0; i < 12; i++) {
        await tester.sendEventToBinding(
          pointer.scroll(const Offset(10, 1)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(shiftOf(tester), lessThan(-100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      // Past half of the actions: it stays open.
      expect(shiftOf(tester), lessThan(-50));
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('a vertical scroll is left to the list', (tester) async {
      await pumpUna(tester, host(row()));
      final pointer = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.text('Message'))),
      );
      for (var i = 0; i < 6; i++) {
        await tester.sendEventToBinding(
          pointer.scroll(const Offset(2, 12)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pump(const Duration(milliseconds: 200));
      expect(shiftOf(tester), 0);
    });

    testWidgets('a trackpad pan does', (tester) async {
      await pumpUna(tester, host(row()));
      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.trackpad,
      );
      await gesture.panZoomStart(tester.getCenter(find.text('Message')));
      for (var i = 1; i <= 12; i++) {
        await gesture.panZoomUpdate(
          tester.getCenter(find.text('Message')),
          pan: Offset(-10.0 * i, 0),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(shiftOf(tester), lessThan(-50));
      await gesture.panZoomEnd();
      await tester.pumpAndSettle();
    });

    testWidgets('a secondary click shows the actions as a menu', (
      tester,
    ) async {
      await pumpUna(tester, host(row()));
      await tester.tap(
        find.text('Message'),
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Pin'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
      expect(log, contains('Archive'));
    });

    testWidgets('the menu key shows it for the focused row', (tester) async {
      await pumpUna(tester, host(row()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Delete'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    });

    testWidgets('with contextMenu off there is no menu', (tester) async {
      await pumpUna(tester, host(row(contextMenu: false)));
      await tester.tap(
        find.text('Message'),
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Delete'), findsNothing);
    });
  });

  group('SwipeActions semantics', () {
    testWidgets('every action is a custom action of the row', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, host(row()));
      final node = tester.getSemantics(find.byType(Pressable));
      final labels = [
        for (final id in node.getSemanticsData().customSemanticsActionIds!)
          CustomSemanticsAction.getAction(id)!.label,
      ];
      expect(labels, containsAll(<String>['Pin', 'Delete', 'Archive']));
      final id = CustomSemanticsAction.getIdentifier(
        const CustomSemanticsAction(label: 'Archive'),
      );
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.customAction,
        id,
      );
      await tester.pumpAndSettle();
      expect(log, ['Archive']);
      handle.dispose();
    });
  });

  group('SwipeActionsScope', () {
    testWidgets('opening a second row closes the first', (tester) async {
      await pumpUna(
        tester,
        SwipeActionsScope(
          child: ListView(
            children: [
              for (var i = 0; i < 5; i++)
                row(key: Key('row$i'), title: 'Message $i'),
            ],
          ),
        ),
      );
      await swipe(tester, -120, on: find.text('Message 1'));
      expect(shiftOf(tester, const Key('row1')), lessThan(-100));
      await swipe(tester, -120, on: find.text('Message 3'), release: false);
      await tester.pump(const Duration(milliseconds: 600));
      expect(shiftOf(tester, const Key('row1')), 0);
      expect(shiftOf(tester, const Key('row3')), lessThan(-50));
    });

    testWidgets('without a scope two rows can be open', (tester) async {
      await pumpUna(
        tester,
        Column(
          children: [
            for (var i = 0; i < 3; i++)
              row(key: Key('row$i'), title: 'Message $i'),
          ],
        ),
      );
      await swipe(tester, -120, on: find.text('Message 0'));
      // The second swipe starts with a pointer down outside the first row,
      // which closes it: that is the tap-outside rule, not the scope.
      expect(shiftOf(tester, const Key('row0')), lessThan(-100));
    });
  });

  group('SwipeActions closing', () {
    // Each side in a colour of its own, over a page of a third, so a frame
    // can tell which side's actions it shows.
    const pin = Color(0xFFFF00FF);
    const archive = Color(0xFF00FF00);
    const page = Color(0xFF0000FF);
    const row = Color(0xFFFFFFFF);

    SwipeAction coloured(String label, Color color) => SwipeAction(
      icon: const SizedBox(width: 20, height: 20),
      label: label,
      backgroundColor: color,
      onPressed: () => false,
    );

    Future<FrameSampler> pumpColoured(WidgetTester tester) async {
      final sampler = FrameSampler();
      await pumpUna(
        tester,
        sampler.wrap(
          ColoredBox(
            color: page,
            child: host(
              SwipeActions(
                key: const Key('row'),
                leading: [coloured('Pin', pin)],
                trailing: [coloured('Archive', archive)],
                child: const ColoredBox(
                  color: row,
                  child: SizedBox(width: double.infinity, height: 56),
                ),
              ),
            ),
          ),
        ),
        // No edge shadow: the samples are the actions' own colours.
        theme: ThemeData(
          swipeActionsTheme: const SwipeActionsTheme(edgeShadowWidth: 0),
        ),
      );
      return sampler;
    }

    /// Drags the open row [back] points towards shut at [speed] points a
    /// second and lets go, with timestamps a velocity tracker believes.
    Future<double> flickShut(
      WidgetTester tester, {
      required double direction,
      required double back,
      required double speed,
    }) async {
      final row = tester.getRect(find.byKey(const Key('row')));
      var time = const Duration(seconds: 100);
      final step = Duration(microseconds: (10 / speed * 1e6).round());
      final gesture = await tester.createGesture();
      await gesture.down(row.center, timeStamp: time);
      for (var moved = 0.0; moved < back; moved += 10) {
        time += step;
        await gesture.moveBy(Offset(direction * 10, 0), timeStamp: time);
        await tester.pump(step);
      }
      final released = shiftOf(tester);
      await gesture.up(timeStamp: time + const Duration(milliseconds: 1));
      return released;
    }

    for (final side in [-1.0, 1.0]) {
      final name = side < 0 ? 'trailing' : 'leading';
      for (final (back, speed) in [
        (0.0, 0.0),
        (30.0, 3000.0),
        (40.0, 1500.0),
        (50.0, 800.0),
        (60.0, 3000.0),
        (65.0, 6000.0),
      ]) {
        testWidgets('the $name side springs shut without showing the other '
            'side (back $back at $speed)', (tester) async {
          final sampler = await pumpColoured(tester);
          await swipe(tester, side * 120, on: find.byKey(const Key('row')));
          final open = shiftOf(tester);
          expect(open.sign, side);
          if (back == 0) {
            // A tap on the open row shuts it, with no fling at all.
            await tester.tap(find.byKey(const Key('row')));
          } else {
            final released = await flickShut(
              tester,
              direction: -side,
              back: back,
              speed: speed,
            );
            // Let go short of shut, on the side it was open on.
            expect(released.sign, side);
          }
          final rect = tester.getRect(find.byKey(const Key('row')));
          // The edge the other side's actions would come in at.
          final far = side < 0
              ? Offset(rect.left + 1, rect.center.dy)
              : Offset(rect.right - 2, rect.center.dy);
          final other = side < 0 ? pin : archive;
          final otherLabel = side < 0 ? 'Pin' : 'Archive';
          for (var frame = 0; frame < 40; frame++) {
            await tester.pump(const Duration(milliseconds: 16));
            final shift = shiftOf(tester);
            expect(
              shift.sign == -side,
              isFalse,
              reason: 'frame $frame: the row crossed shut to $shift',
            );
            expect(
              find.text(otherLabel),
              findsNothing,
              reason: 'frame $frame: the other side is built',
            );
            expect(
              await sampler.pixel(tester, far),
              isNot(other),
              reason: 'frame $frame: the other side shows',
            );
          }
          await tester.pumpAndSettle();
          expect(shiftOf(tester), 0);
        });
      }
    }

    testWidgets('a drag across shut hands over to the other side at once', (
      tester,
    ) async {
      // Without a strip per side the right-hand strip would take over the
      // left-hand one's fills and fade them from one colour to the other.
      final sampler = await pumpColoured(tester);
      final row = tester.getRect(find.byKey(const Key('row')));
      final gesture = await tester.startGesture(row.center);
      addTearDown(gesture.removePointer);
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(shiftOf(tester), greaterThan(20));
      // Across to the other side in one move.
      await gesture.moveBy(Offset(-shiftOf(tester) - 30, 0));
      await tester.pump();
      expect(shiftOf(tester), lessThan(-20));
      expect(
        await sampler.pixel(tester, Offset(row.right - 2, row.center.dy)),
        archive,
      );
    });
  });

  group('SwipeActions edge shadow', () {
    const fill = Color(0xFF00FF00);

    Future<FrameSampler> pumpOpen(
      WidgetTester tester, {
      ThemeData? theme,
    }) async {
      final sampler = FrameSampler();
      await pumpUna(
        tester,
        sampler.wrap(
          host(
            SwipeActions(
              key: const Key('row'),
              trailing: [
                SwipeAction(
                  icon: const SizedBox.shrink(),
                  label: 'Archive',
                  backgroundColor: fill,
                  onPressed: () => false,
                ),
              ],
              child: const ColoredBox(
                color: Color(0xFFFFFFFF),
                child: SizedBox(width: double.infinity, height: 56),
              ),
            ),
          ),
        ),
        theme: theme,
      );
      await swipe(tester, -120, on: find.byKey(const Key('row')));
      expect(shiftOf(tester), moreOrLessEquals(-76, epsilon: .5));
      return sampler;
    }

    /// The fill just inside the row's edge and well clear of it, on the
    /// action's top row of pixels (clear of its label).
    Future<(Color, Color)> samples(
      WidgetTester tester,
      FrameSampler sampler,
    ) async {
      final row = tester.getRect(find.byKey(const Key('row')));
      final edge = row.right - 76;
      final colors = await sampler.pixels(tester, [
        Offset(edge + .5, row.top + 2),
        Offset(edge + 40, row.top + 2),
      ]);
      return (colors[0], colors[1]);
    }

    testWidgets('the row casts a soft shadow onto the uncovered actions', (
      tester,
    ) async {
      final sampler = await pumpOpen(tester);
      final (atEdge, clear) = await samples(tester, sampler);
      expect(clear, fill);
      expect(atEdge, isNot(fill));
      // Darker, but only a little.
      expect(atEdge.g, lessThan(fill.g));
      expect(atEdge.g, greaterThan(.75));
    });

    testWidgets('it is a theme value, darker in a dark theme, and zero '
        'width draws none', (tester) async {
      final light = ThemeData().swipeActionsTheme;
      final dark = ThemeData(brightness: Brightness.dark).swipeActionsTheme;
      expect(light.edgeShadowWidth, greaterThan(0));
      expect(dark.edgeShadowColor!.a, greaterThan(light.edgeShadowColor!.a));

      final sampler = await pumpOpen(
        tester,
        theme: ThemeData(
          swipeActionsTheme: const SwipeActionsTheme(edgeShadowWidth: 0),
        ),
      );
      final (atEdge, clear) = await samples(tester, sampler);
      expect(atEdge, fill);
      expect(clear, fill);
    });

    testWidgets('it comes in with the swipe rather than at full strength', (
      tester,
    ) async {
      final sampler = FrameSampler();
      await pumpUna(
        tester,
        sampler.wrap(
          host(
            SwipeActions(
              key: const Key('row'),
              trailing: [
                SwipeAction(
                  icon: const SizedBox.shrink(),
                  label: 'Archive',
                  backgroundColor: fill,
                  onPressed: () => false,
                ),
              ],
              child: const ColoredBox(
                color: Color(0xFFFFFFFF),
                child: SizedBox(width: double.infinity, height: 56),
              ),
            ),
          ),
        ),
      );
      final row = tester.getRect(find.byKey(const Key('row')));
      final gesture = await tester.startGesture(row.center);
      addTearDown(gesture.removePointer);
      // Past the slop, then two points.
      for (var i = 0; i < 2; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.moveBy(Offset(-2 - shiftOf(tester), 0));
      await tester.pump();
      final shift = shiftOf(tester);
      expect(shift, moreOrLessEquals(-2, epsilon: .5));
      final near = await sampler.pixel(
        tester,
        Offset(row.right + shift + .5, row.top + 2),
      );
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      final wide = await sampler.pixel(
        tester,
        Offset(row.right + shiftOf(tester) + .5, row.top + 2),
      );
      // The same spot by the row's edge is darker once the shadow is in.
      expect(near.g, greaterThan(wide.g));
    });
  });

  group('SwipeActions in a ListSection', () {
    testWidgets('the card clips the uncovered actions', (tester) async {
      await pumpUna(
        tester,
        host(
          ListSection(
            children: [
              row(),
              const ListTile(title: Text('Another')),
            ],
          ),
        ),
      );
      await swipe(tester, -120);
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(Card));
      final delete = tester.getRect(
        find.ancestor(
          of: find.text('Delete'),
          matching: find.byType(Pressable),
        ),
      );
      expect(delete.right, lessThanOrEqualTo(card.right));
      expect(
        tester.widget<Card>(find.byType(Card)).style?.clipBehavior,
        isNull,
      );
    });
  });
}
