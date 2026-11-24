import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `showMenu` puts a `ContextMenu` in a route of its own, for a menu with
/// no widget to hang on. These hold what the route adds: where the menu
/// lands, what the future completes with, and that closing it — by a row,
/// a tap outside, Escape, or a pop from elsewhere — takes exactly one
/// route away.
void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<BuildContext> pumpPage(
    WidgetTester tester, {
    Widget? child,
    TextDirection textDirection = TextDirection.ltr,
    Size size = const Size(800, 600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        // Around the navigator: a route is not under its opener.
        builder: (context, child) =>
            Directionality(textDirection: textDirection, child: child!),
        home: KeyedSubtree(
          key: const ValueKey('page'),
          child: child ?? const SizedBox.expand(),
        ),
      ),
    );
    return tester.element(find.byKey(const ValueKey('page')));
  }

  Rect menuRect(WidgetTester tester, String label) => tester.getRect(
    find.ancestor(of: find.text(label), matching: find.byType(Decorator)).last,
  );

  const items = <Widget>[
    ContextMenuItem(value: 'copy', child: Text('Copy')),
    ContextMenuItem(value: 'paste', child: Text('Paste')),
    ContextMenuItem(child: Text('Nothing')),
  ];

  group('placement', () {
    testWidgets('at a position the menu opens with its corner there', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      showMenu<String>(
        context: context,
        position: const Offset(200, 150),
        items: items,
      ).ignore();
      await tester.pumpAndSettle();
      final rect = menuRect(tester, 'Copy');
      expect(rect.topLeft, const Offset(200, 150));
    });

    testWidgets('right to left its top end corner is at the position', (
      tester,
    ) async {
      final context = await pumpPage(
        tester,
        textDirection: TextDirection.rtl,
      );
      showMenu<String>(
        context: context,
        position: const Offset(500, 150),
        items: items,
      ).ignore();
      await tester.pumpAndSettle();
      final rect = menuRect(tester, 'Copy');
      expect(rect.topRight, const Offset(500, 150));
    });

    testWidgets('near the bottom right corner it is mirrored to fit', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      showMenu<String>(
        context: context,
        position: const Offset(790, 590),
        items: items,
      ).ignore();
      await tester.pumpAndSettle();
      final rect = menuRect(tester, 'Copy');
      expect(rect.bottomRight, const Offset(790, 590));
    });

    testWidgets('under a rectangle it opens below, at the start edge', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      const anchor = Rect.fromLTWH(100, 80, 60, 30);
      showMenu<String>(
        context: context,
        anchorRect: anchor,
        items: items,
      ).ignore();
      await tester.pumpAndSettle();
      final rect = menuRect(tester, 'Copy');
      expect(rect.left, moreOrLessEquals(anchor.left, epsilon: .5));
      expect(rect.top, moreOrLessEquals(anchor.bottom + 4, epsilon: .5));
    });

    testWidgets('a rectangle near the bottom gets the menu above it', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      const anchor = Rect.fromLTWH(100, 560, 60, 30);
      showMenu<String>(
        context: context,
        anchorRect: anchor,
        items: items,
      ).ignore();
      await tester.pumpAndSettle();
      final rect = menuRect(tester, 'Copy');
      expect(rect.bottom, moreOrLessEquals(anchor.top - 4, epsilon: .5));
      expect(rect.left, moreOrLessEquals(anchor.left, epsilon: .5));
    });

    testWidgets('in a nested navigator the position is still global', (
      tester,
    ) async {
      late BuildContext inner;
      await pumpPage(
        tester,
        child: Padding(
          padding: const EdgeInsets.only(left: 120, top: 70),
          child: Navigator(
            onGenerateRoute: (settings) => PageRouteBuilder<void>(
              pageBuilder: (context, _, _) {
                inner = context;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      showMenu<String>(
        context: inner,
        position: const Offset(300, 200),
        items: items,
      ).ignore();
      await tester.pumpAndSettle();
      expect(menuRect(tester, 'Copy').topLeft, const Offset(300, 200));
    });
  });

  group('result', () {
    testWidgets('completes with the value of the row that was chosen', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      String? result = 'unset';
      var done = false;
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: items,
      ).then((value) {
        result = value;
        done = true;
      }).ignore();
      await settle(tester);
      await tester.tap(find.text('Paste'));
      await tester.pumpAndSettle();
      expect(done, isTrue);
      expect(result, 'paste');
      expect(find.text('Paste'), findsNothing);
    });

    testWidgets('a row without a value completes with null and still runs '
        'its onPressed', (tester) async {
      final context = await pumpPage(tester);
      Object? result = 'unset';
      var pressed = 0;
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: [
          ContextMenuItem(
            onPressed: () => pressed++,
            child: const Text('Run'),
          ),
        ],
      ).then((value) => result = value).ignore();
      await settle(tester);
      await tester.tap(find.text('Run'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      expect(result, isNull);
    });

    testWidgets('a value of another type completes with null', (tester) async {
      final context = await pumpPage(tester);
      Object? result = 'unset';
      showMenu<int>(
        context: context,
        position: const Offset(100, 100),
        items: items,
      ).then((value) => result = value).ignore();
      await settle(tester);
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(result, isNull);
    });

    testWidgets('a row in a submenu hands its value back too', (tester) async {
      final context = await pumpPage(tester);
      Object? result = 'unset';
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: const [
          ContextMenuItem(
            items: [ContextMenuItem(value: 'pdf', child: Text('PDF'))],
            child: Text('Export'),
          ),
        ],
      ).then((value) => result = value).ignore();
      await settle(tester);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Export')));
      await settle(tester);
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();
      expect(result, 'pdf');
    });

    testWidgets('a row that pops the route itself is not popped twice', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      Object? result = 'unset';
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: [
          Builder(
            builder: (context) => ContextMenuItem(
              onPressed: () => Navigator.of(context).pop('own'),
              child: const Text('Pop'),
            ),
          ),
        ],
      ).then((value) => result = value).ignore();
      await settle(tester);
      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();
      expect(result, 'own');
      // The page under the menu is still there.
      expect(find.byKey(const ValueKey('page')), findsOneWidget);
    });
  });

  group('dismissal', () {
    testWidgets('a tap outside closes the menu with null and does not press '
        'what is under it', (tester) async {
      var pressed = 0;
      final context = await pumpPage(
        tester,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Button(
            onPressed: () => pressed++,
            child: const Text('Under'),
          ),
        ),
      );
      Object? result = 'unset';
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: items,
      ).then((value) => result = value).ignore();
      await settle(tester);
      await tester.tap(find.text('Under'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(pressed, 0);
      expect(find.text('Copy'), findsNothing);

      // Closed, the page takes taps again.
      await tester.tap(find.text('Under'));
      await tester.pump();
      expect(pressed, 1);
    });

    testWidgets('Escape closes the menu and nothing under it', (tester) async {
      final context = await pumpPage(tester);
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          title: const Text('Dialog'),
          child: Builder(
            builder: (context) => Button(
              onPressed: () => showMenu<String>(
                context: context,
                position: const Offset(300, 300),
                items: items,
              ),
              child: const Text('Open menu'),
            ),
          ),
        ),
      ).ignore();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open menu'));
      await settle(tester);
      expect(find.text('Copy'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsNothing);
      expect(find.text('Dialog'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsNothing);
    });

    testWidgets('Escape in a submenu closes the submenu first', (tester) async {
      final context = await pumpPage(tester);
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: const [
          ContextMenuItem(
            items: [ContextMenuItem(value: 'pdf', child: Text('PDF'))],
            child: Text('Export'),
          ),
        ],
      ).ignore();
      await settle(tester);
      // Focusing a row with a submenu opens it; the right arrow enters.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(find.text('PDF'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await settle(tester);
      expect(Focus.of(tester.element(find.text('PDF'))).hasFocus, isTrue);

      // Out of the submenu, and the menu itself is still there.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('Export'), findsOneWidget);
      expect(Focus.of(tester.element(find.text('Export'))).hasFocus, isTrue);

      // Further presses take the rest away, and never the page under it.
      for (var i = 0; i < 2 && find.text('Export').evaluate().isNotEmpty; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
      }
      expect(find.text('Export'), findsNothing);
      expect(find.byKey(const ValueKey('page')), findsOneWidget);
    });

    testWidgets('popped from outside, it plays its exit and completes', (
      tester,
    ) async {
      final context = await pumpPage(tester);
      var done = false;
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: items,
      ).then((_) => done = true).ignore();
      await settle(tester);
      Navigator.of(context).pop();
      await tester.pump();
      // Still on screen: it is leaving, not gone.
      expect(find.text('Copy'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsNothing);
      expect(done, isTrue);
      expect(find.byKey(const ValueKey('page')), findsOneWidget);
    });

    testWidgets('a row that opens a dialog leaves the dialog and takes the '
        'menu away', (tester) async {
      final context = await pumpPage(tester);
      Object? result = 'unset';
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: [
          Builder(
            builder: (context) => ContextMenuItem(
              value: 'opened',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const Dialog(title: Text('Rename')),
              ),
              child: const Text('Rename…'),
            ),
          ),
        ],
      ).then((value) => result = value).ignore();
      await settle(tester);
      await tester.tap(find.text('Rename…'));
      await tester.pumpAndSettle();
      // The menu was under the dialog by the time it closed, and still
      // completed with its row's value.
      expect(result, 'opened');
      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Rename…'), findsNothing);
    });
  });

  group('focus and keys', () {
    testWidgets('the arrows walk it, Enter chooses, and the focus goes back '
        'to where it was', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final context = await pumpPage(
        tester,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Button(
            focusNode: node,
            onPressed: () {},
            child: const Text('Opener'),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      Object? result = 'unset';
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: items,
      ).then((value) => result = value).ignore();
      await settle(tester);
      expect(node.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(Focus.of(tester.element(find.text('Paste'))).hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(result, 'paste');
      expect(node.hasFocus, isTrue);
    });

    testWidgets('a screen reader can dismiss it from the barrier', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final context = await pumpPage(tester);
      showMenu<String>(
        context: context,
        position: const Offset(100, 100),
        items: items,
      ).ignore();
      await settle(tester);
      final barrier = find.bySemanticsLabel('Dismiss');
      expect(barrier, findsOneWidget);
      expect(
        tester.getSemantics(barrier),
        matchesSemantics(
          label: 'Dismiss',
          hasTapAction: true,
          hasDismissAction: true,
        ),
      );
      tester.semantics.dismiss(find.semantics.byLabel('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsNothing);
      handle.dispose();
    });
  });

  testWidgets('follows a theme applied to the subtree it was opened from', (
    tester,
  ) async {
    late BuildContext themed;
    final local = ThemeData(
      colorScheme: const NeutralColorScheme.dark(),
      style: StyleTokens.nova,
    );
    await pumpPage(
      tester,
      child: ThemeScope(
        data: local,
        child: Builder(
          builder: (context) {
            themed = context;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    showMenu<String>(
      context: themed,
      position: const Offset(100, 100),
      items: items,
    ).ignore();
    await settle(tester);
    expect(Theme.of(tester.element(find.text('Copy'))), local);
  });

  testWidgets('with motion switched off it is there and gone at once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late BuildContext context;
    await tester.pumpWidget(
      FinesseApp(
        theme: ThemeData(motion: Motion.none),
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    Object? result = 'unset';
    showMenu<String>(
      context: context,
      position: const Offset(100, 100),
      items: items,
    ).then((value) => result = value).ignore();
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Copy'), findsOneWidget);
    await tester.tap(find.text('Copy'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Copy'), findsNothing);
    expect(result, 'copy');
  });
}
