import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
      await swipe(tester, -60);
      expect(shiftOf(tester), 0);
      expect(log, isEmpty);
    });

    testWidgets('a quick flick opens although the row has barely moved', (
      tester,
    ) async {
      await pumpFinesse(tester, host(row()));
      await tester.fling(find.text('Message'), const Offset(-50, 0), 1500);
      await tester.pumpAndSettle();
      expect(shiftOf(tester), lessThan(-100));
    });

    testWidgets('the settle is interruptible and comes to rest', (
      tester,
    ) async {
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
      await swipe(tester, -120);
      await tester.tapAt(const Offset(500, 20));
      await tester.pumpAndSettle();
      expect(shiftOf(tester), 0);
      expect(log, ['opened', 'closed']);
    });

    testWidgets('an open row closes on a tap outside it', (tester) async {
      await pumpFinesse(
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
      await pumpFinesse(tester, host(row()));
      await swipe(tester, 80);
      expect(shiftOf(tester), moreOrLessEquals(76, epsilon: .5));
      expect(find.text('Pin'), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
    });

    testWidgets('a side without actions does not move', (tester) async {
      await pumpFinesse(tester, host(row(leading: [])));
      await swipe(tester, 120, release: false);
      expect(shiftOf(tester), 0);
    });

    testWidgets('disabled, nothing moves', (tester) async {
      await pumpFinesse(tester, host(row(enabled: false)));
      await swipe(tester, -120, release: false);
      expect(shiftOf(tester), 0);
    });
  });

  group('SwipeActions full swipe', () {
    testWidgets('past the threshold the first action spreads, with a '
        'haptic, and runs on release', (tester) async {
      final calls = hapticCalls(tester);
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
      await swipe(tester, -300);
      expect(log, ['Delete']);
      expect(shiftOf(tester), 0);
    });

    testWidgets('with fullSwipe off the row resists past its actions and '
        'only opens', (tester) async {
      await pumpFinesse(tester, host(row(fullSwipe: false)));
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
      await pumpFinesse(
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
      await pumpFinesse(
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
      await pumpFinesse(
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
  });

  group('SwipeActions and other gestures', () {
    testWidgets('a vertical drag scrolls the list and moves no row', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpFinesse(
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
      await pumpFinesse(
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
      await pumpFinesse(
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
        await pumpFinesse(
          tester,
          Builder(
            builder: (context) => Center(
              child: Button(
                onPressed: () => Navigator.of(context).push(
                  FinessePageRoute<void>(
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
      await pumpFinesse(
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
      await pumpFinesse(
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
    testWidgets('a mouse drag does not move the row', (tester) async {
      await pumpFinesse(tester, host(row()));
      await swipe(tester, -120, kind: PointerDeviceKind.mouse, release: false);
      expect(shiftOf(tester), 0);
    });

    testWidgets('a trackpad pan does', (tester) async {
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(tester, host(row(contextMenu: false)));
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
      await pumpFinesse(tester, host(row()));
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
      await pumpFinesse(
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
      await pumpFinesse(
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

  group('SwipeActions in a ListSection', () {
    testWidgets('the card clips the uncovered actions', (tester) async {
      await pumpFinesse(
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
      expect(tester.widget<Card>(find.byType(Card)).clipBehavior, isNull);
    });
  });
}
