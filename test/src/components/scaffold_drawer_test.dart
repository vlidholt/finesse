import 'dart:ui' show PointerDeviceKind;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _panel = Key('panel');
const _endPanel = Key('end-panel');
const _phone = Size(390, 844);

void main() {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final log = <String>[];

  setUp(log.clear);

  Widget panel(Key key, [String label = 'Menu']) => SizedBox.expand(
    key: key,
    child: Align(alignment: Alignment.topLeft, child: Text(label)),
  );

  Widget scaffold({
    bool drawer = true,
    bool endDrawer = false,
    bool edgeDrag = true,
    String label = 'Menu',
  }) => Scaffold(
    key: scaffoldKey,
    drawer: drawer ? panel(_panel, label) : null,
    endDrawer: endDrawer ? panel(_endPanel, 'End') : null,
    drawerEdgeDragEnabled: edgeDrag,
    onDrawerChanged: (open) => log.add('start $open'),
    onEndDrawerChanged: (open) => log.add('end $open'),
    body: const SizedBox.expand(),
  );

  Future<void> pumpApp(
    WidgetTester tester,
    Widget home, {
    Size size = _phone,
    TextDirection direction = TextDirection.ltr,
    bool reduce = false,
    ThemeData? theme,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        navigatorKey: navigatorKey,
        theme: theme,
        formFactor: FormFactor.mobile,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
          child: Directionality(textDirection: direction, child: child!),
        ),
        home: home,
      ),
    );
    await tester.pump();
  }

  ScaffoldState state() => scaffoldKey.currentState!;
  Rect panelRect(WidgetTester tester, [Key key = _panel]) =>
      tester.getRect(find.byKey(key));

  group('opening and closing', () {
    testWidgets('openDrawer slides the panel in from the start edge, over a '
        'scrim; it is 85% of a phone and never wider than 360', (tester) async {
      await pumpApp(tester, scaffold());
      expect(state().hasDrawer, isTrue);
      expect(state().hasEndDrawer, isFalse);
      expect(state().isDrawerOpen, isFalse);
      expect(find.byKey(_panel), findsNothing);

      state().openDrawer();
      expect(state().isDrawerOpen, isTrue);
      expect(log, ['start true']);
      await tester.pump();

      // It comes in from off the edge, never moving back out.
      final rights = <double>[];
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        rights.add(panelRect(tester).right);
      }
      expect(rights.first, lessThan(100));
      for (var i = 1; i < rights.length; i++) {
        expect(rights[i], greaterThanOrEqualTo(rights[i - 1] - .01));
      }
      await tester.pumpAndSettle();
      final rect = panelRect(tester);
      expect(rect.left, 0);
      expect(rect.width, 390 * .85);
      expect(rect.height, 844);
      expect(find.byType(ModalBarrier), findsWidgets);

      // Opening it again does nothing.
      state().openDrawer();
      await tester.pump();
      expect(find.byKey(_panel), findsOneWidget);
      expect(log, ['start true']);

      // On a wide screen it stops at 360.
      state().closeDrawer();
      await tester.pumpAndSettle();
      await pumpApp(tester, scaffold(), size: const Size(1280, 800));
      state().openDrawer();
      await tester.pumpAndSettle();
      expect(panelRect(tester).width, 360);
    });

    testWidgets('the scrim, Escape, the system back and closeDrawer all '
        'close it, and each is reported once', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await pumpApp(tester, scaffold(), navigatorKey: navigator);

      Future<void> open() async {
        state().openDrawer();
        await tester.pumpAndSettle();
        expect(find.byKey(_panel), findsOneWidget);
        log.clear();
      }

      await open();
      await tester.tapAt(const Offset(380, 400));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      expect(state().isDrawerOpen, isFalse);
      expect(log, ['start false']);

      await open();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      expect(log, ['start false']);

      await open();
      expect(await navigator.currentState!.maybePop(), isTrue);
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      expect(log, ['start false']);

      await open();
      state().closeDrawer();
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      expect(log, ['start false']);
      // Closing a closed drawer is nothing.
      state().closeDrawer();
      expect(log, ['start false']);
    });

    testWidgets('it leaves faster than it came, in one direction', (
      tester,
    ) async {
      await pumpApp(tester, scaffold());
      state().openDrawer();
      await tester.pumpAndSettle();
      state().closeDrawer();
      await tester.pump();
      final rights = <double>[];
      var frames = 0;
      while (find.byKey(_panel).evaluate().isNotEmpty && frames < 60) {
        rights.add(panelRect(tester).right);
        await tester.pump(const Duration(milliseconds: 16));
        frames++;
      }
      expect(frames, lessThan(20));
      for (var i = 1; i < rights.length; i++) {
        expect(rights[i], lessThanOrEqualTo(rights[i - 1] + .01));
      }
    });

    testWidgets('closed in the middle of opening, it turns round where it is', (
      tester,
    ) async {
      await pumpApp(tester, scaffold());
      state().openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 80));
      final mid = panelRect(tester).right;
      expect(mid, inExclusiveRange(0, 390 * .85));
      state().closeDrawer();
      await tester.pump();
      expect(panelRect(tester).right, closeTo(mid, 1));
      await tester.pump(const Duration(milliseconds: 16));
      expect(panelRect(tester).right, lessThanOrEqualTo(mid));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('the end drawer comes from the other side, and both sides '
        'swap in a right-to-left language', (tester) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(const SizedBox.shrink());
        await pumpApp(
          tester,
          scaffold(endDrawer: true),
          direction: direction,
        );
        final ltr = direction == TextDirection.ltr;

        state().openDrawer();
        await tester.pumpAndSettle();
        expect(
          ltr ? panelRect(tester).left : panelRect(tester).right,
          ltr ? 0 : 390,
          reason: '$direction start',
        );
        state().closeDrawer();
        await tester.pumpAndSettle();

        state().openEndDrawer();
        expect(state().isEndDrawerOpen, isTrue);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 32));
        // On its way in from its own side.
        final entering = panelRect(tester, _endPanel);
        expect(
          ltr ? entering.left : entering.right,
          ltr ? greaterThan(390 * .15) : lessThan(390 * .85),
        );
        await tester.pumpAndSettle();
        final rect = panelRect(tester, _endPanel);
        expect(ltr ? rect.right : rect.left, ltr ? 390 : 0);
        state().closeEndDrawer();
        await tester.pumpAndSettle();
        expect(log, ['start true', 'start false', 'end true', 'end false']);
        log.clear();
      }
    });

    testWidgets('with reduced motion it fades in place; with motion off it '
        'is simply there', (tester) async {
      await pumpApp(tester, scaffold(), reduce: true);
      state().openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      // In place from the first frame, fading.
      expect(panelRect(tester).left, 0);
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byKey(_panel),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, lessThan(1));
      await tester.pumpAndSettle();
      expect(fade.opacity.value, 1);
      state().closeDrawer();
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpApp(tester, scaffold(), theme: ThemeData(motion: Motion.none));
      state().openDrawer();
      await tester.pump();
      await tester.pump();
      expect(panelRect(tester).left, 0);
      expect(tester.binding.hasScheduledFrame, isFalse);
      state().closeDrawer();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(_panel), findsNothing);
    });
  });

  group('Scaffold.of', () {
    testWidgets('finds the scaffold from below, and its dependents follow '
        'the drawers', (tester) async {
      final seen = <String>[];
      Widget home({required bool drawer}) => Scaffold(
        drawer: drawer ? panel(_panel) : null,
        body: Builder(
          builder: (context) {
            final scaffold = Scaffold.of(context);
            seen.add('${scaffold.hasDrawer} ${scaffold.isDrawerOpen}');
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: scaffold.openDrawer,
            );
          },
        ),
      );
      await pumpApp(tester, home(drawer: false));
      expect(seen.last, 'false false');
      await pumpApp(tester, home(drawer: true));
      expect(seen.last, 'true false');
      await tester.tapAt(const Offset(200, 400));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsOneWidget);
      expect(seen.last, 'true true');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(seen.last, 'true false');
    });

    testWidgets('the drawer finds its scaffold, so an item can close it', (
      tester,
    ) async {
      ScaffoldState? found;
      await pumpApp(
        tester,
        Scaffold(
          key: scaffoldKey,
          drawer: Builder(
            builder: (context) {
              found = Scaffold.maybeOf(context);
              return GestureDetector(
                key: _panel,
                behavior: HitTestBehavior.opaque,
                onTap: () => Scaffold.of(context).closeDrawer(),
              );
            },
          ),
          body: const SizedBox.expand(),
        ),
      );
      state().openDrawer();
      await tester.pumpAndSettle();
      expect(state().isDrawerOpen, isTrue);
      expect(found, same(state()));
      await tester.tap(find.byKey(_panel));
      await tester.pumpAndSettle();
      expect(state().isDrawerOpen, isFalse);
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('maybeOf is null with no scaffold above; of says why', (
      tester,
    ) async {
      late BuildContext outside;
      await pumpApp(
        tester,
        Builder(
          builder: (context) {
            outside = context;
            return const SizedBox();
          },
        ),
      );
      expect(Scaffold.maybeOf(outside), isNull);
      expect(() => Scaffold.of(outside), throwsAssertionError);
    });
  });

  group('the drawer itself', () {
    testWidgets('takes the focus, keeps Tab inside and names itself', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final inside = FocusNode(debugLabel: 'inside');
      final outside = FocusNode(debugLabel: 'outside');
      addTearDown(inside.dispose);
      addTearDown(outside.dispose);
      await pumpApp(
        tester,
        Scaffold(
          key: scaffoldKey,
          drawer: Focus(focusNode: inside, child: const Text('Menu')),
          body: Focus(
            focusNode: outside,
            autofocus: true,
            child: const Text('Page'),
          ),
        ),
      );
      expect(outside.hasFocus, isTrue);
      state().openDrawer();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(inside.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(outside.hasFocus, isFalse);
      expect(find.bySemanticsLabel('Navigation menu'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      // Back where it was.
      expect(outside.hasFocus, isTrue);
      handle.dispose();
    });

    testWidgets('shows the drawer the scaffold has now, and closes when the '
        'scaffold loses it', (tester) async {
      await pumpApp(tester, scaffold(label: 'One'));
      state().openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);

      await pumpApp(tester, scaffold(label: 'Two'));
      await tester.pump();
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('One'), findsNothing);

      await pumpApp(tester, scaffold(drawer: false));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      expect(state().isDrawerOpen, isFalse);
    });

    testWidgets('is taken down with its scaffold', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await pumpApp(tester, scaffold(), navigatorKey: navigator);
      state().openDrawer();
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsOneWidget);

      // The page under the drawer is replaced: its scaffold is gone.
      navigator.currentState!.pushAndRemoveUntil(
        FinessePageRoute<void>(builder: (_) => const Text('Other')),
        (route) => route is! FinessePageRoute,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Other'), findsOneWidget);
    });

    testWidgets('follows the app theme while it is open', (tester) async {
      await pumpApp(tester, scaffold());
      state().openDrawer();
      await tester.pumpAndSettle();
      Color fill() => tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.byKey(_panel),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((decoration) => decoration.color != null)
          .color!;
      final light = ThemeData();
      final dark = ThemeData(brightness: Brightness.dark);
      expect(fill(), light.colorScheme.background);
      await pumpApp(tester, scaffold(), theme: dark);
      await tester.pump(const Duration(milliseconds: 400));
      expect(fill(), dark.colorScheme.background);
    });

    testWidgets('keeps its content out of the status bar and the keyboard, '
        'and off the side that faces the page', (tester) async {
      late MediaQueryData seen;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = _phone;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        FinesseApp(
          formFactor: FormFactor.mobile,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.fromLTRB(20, 44, 30, 34),
            ),
            child: child!,
          ),
          home: Scaffold(
            key: scaffoldKey,
            drawer: Builder(
              builder: (context) {
                seen = MediaQuery.of(context);
                return const SizedBox.expand();
              },
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      state().openDrawer();
      await tester.pumpAndSettle();
      expect(seen.padding, const EdgeInsets.fromLTRB(20, 44, 0, 34));
    });
  });

  group('dragging', () {
    Future<TestGesture> touchDown(WidgetTester tester, Offset at) =>
        tester.startGesture(at);

    testWidgets('a finger dragging in from the start edge pulls the panel '
        'with it, and letting go past half way opens it', (tester) async {
      await pumpApp(tester, scaffold());
      const width = 390 * .85;
      final gesture = await touchDown(tester, const Offset(5, 400));
      // Past the slop, then on with the finger.
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      // Not a route yet — pushing one would take the finger's drag away —
      // but there, under the finger, over a scrim.
      expect(state().isDrawerOpen, isFalse);
      expect(log, isEmpty);
      final start = panelRect(tester).right;
      expect(start, inInclusiveRange(1, 30));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      // Point for point.
      expect(panelRect(tester).right, closeTo(start + 100, .5));
      expect(panelRect(tester).right, lessThan(width));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      expect(panelRect(tester).right, closeTo(start + 200, .5));
      // Held still, it stays where the finger is.
      await tester.pump(const Duration(milliseconds: 300));
      expect(panelRect(tester).right, closeTo(start + 200, .5));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(panelRect(tester).left, 0);
      expect(log, ['start true']);
    });

    testWidgets('let go before half way, it goes back and is closed', (
      tester,
    ) async {
      await pumpApp(tester, scaffold());
      final gesture = await touchDown(tester, const Offset(5, 400));
      await gesture.moveBy(const Offset(30, 0));
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      expect(state().isDrawerOpen, isFalse);
      // It never opened, so nothing is reported.
      expect(log, isEmpty);
    });

    testWidgets('a flick opens it from anywhere, and a flick back closes it', (
      tester,
    ) async {
      await pumpApp(tester, scaffold());
      await tester.flingFrom(const Offset(5, 400), const Offset(60, 0), 1200);
      await tester.pumpAndSettle();
      expect(panelRect(tester).left, 0);

      // On the panel now: a short flick towards the edge.
      await tester.flingFrom(
        const Offset(200, 400),
        const Offset(-60, 0),
        1200,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('a drag on the open panel moves it, and it settles on the '
        'nearer side', (tester) async {
      await pumpApp(tester, scaffold());
      state().openDrawer();
      await tester.pumpAndSettle();
      final width = panelRect(tester).width;

      var gesture = await touchDown(tester, const Offset(200, 400));
      await gesture.moveBy(const Offset(-30, 0));
      await gesture.moveBy(const Offset(-50, 0));
      await tester.pump();
      expect(panelRect(tester).left, lessThan(0));
      expect(panelRect(tester).left, greaterThan(-width / 2));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(panelRect(tester).left, 0);

      gesture = await touchDown(tester, const Offset(300, 400));
      await gesture.moveBy(const Offset(-30, 0));
      await gesture.moveBy(const Offset(-230, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('in a right-to-left language the start edge is the right one', (
      tester,
    ) async {
      await pumpApp(tester, scaffold(), direction: TextDirection.rtl);
      // Nothing from the left edge.
      await tester.dragFrom(const Offset(5, 400), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);

      await tester.dragFrom(const Offset(385, 400), const Offset(-250, 0));
      await tester.pumpAndSettle();
      expect(panelRect(tester).right, 390);
    });

    testWidgets('the end edge opens the end drawer', (tester) async {
      await pumpApp(tester, scaffold(endDrawer: true));
      await tester.dragFrom(const Offset(385, 400), const Offset(-250, 0));
      await tester.pumpAndSettle();
      expect(panelRect(tester, _endPanel).right, 390);
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('a mouse does not drag it open, a drag from further in does '
        'not, and neither does anything when the edge drag is off', (
      tester,
    ) async {
      await pumpApp(tester, scaffold());
      await tester.dragFrom(
        const Offset(5, 400),
        const Offset(250, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);

      await tester.dragFrom(const Offset(60, 400), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);

      await pumpApp(tester, scaffold(edgeDrag: false));
      await tester.dragFrom(const Offset(5, 400), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('on a page that can be popped the edge is left to the way '
        'back', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await pumpApp(
        tester,
        const Scaffold(body: Text('Home')),
        navigatorKey: navigator,
      );
      navigator.currentState!.push(
        FinessePageRoute<void>(builder: (_) => scaffold()),
      );
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(5, 400), const Offset(250, 0));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
      // The button still opens it.
      state().openDrawer();
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsOneWidget);
    });

    testWidgets('what is under the edge still takes taps and vertical '
        'scrolls', (tester) async {
      var taps = 0;
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpApp(
        tester,
        Scaffold(
          key: scaffoldKey,
          drawer: panel(_panel),
          body: ListView(
            controller: controller,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox(height: 600),
              ),
              const SizedBox(height: 1200),
            ],
          ),
        ),
      );
      await tester.tapAt(const Offset(5, 300));
      await tester.pump();
      expect(taps, 1);
      await tester.dragFrom(const Offset(5, 500), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(100));
      expect(find.byKey(_panel), findsNothing);
    });
  });
}
