import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where the portal puts an overlay: at a point given in *global*
/// coordinates, wherever the overlay it is drawn in begins, and never right
/// against the edge of the screen.
void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // An app with a panel docked beside its navigator: the navigator, and
  // the overlay its menus are drawn in, start at (200, 100).
  Widget docked(Widget page) => FinesseApp(
    theme: ThemeData(motion: Motion.none),
    home: Padding(
      padding: const EdgeInsets.only(left: 200, top: 100),
      child: Navigator(
        onGenerateRoute: (settings) => PageRouteBuilder<void>(
          pageBuilder: (context, _, _) => page,
        ),
      ),
    ),
  );

  group('a global point in a navigator that does not start at the origin', () {
    testWidgets('a context menu opens with its corner at the pointer', (
      tester,
    ) async {
      await tester.pumpWidget(
        docked(
          const ContextMenuRegion(
            items: [MenuItem(child: Text('Copy'))],
            child: SizedBox.expand(),
          ),
        ),
      );
      await tester.tapAt(
        const Offset(400, 300),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await settle(tester);
      final menu = tester.getRect(
        find.ancestor(
          of: find.text('Copy'),
          matching: find.byType(BackdropSurface),
        ),
      );
      expect(menu.left, closeTo(400, 1.5));
      expect(menu.top, closeTo(300, 1.5));
    });

    testWidgets('PopoverController.openAt takes a global point too', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        docked(
          Align(
            alignment: Alignment.topLeft,
            child: Popover(
              controller: controller,
              padding: EdgeInsets.zero,
              builder: (context) => const SizedBox(
                key: Key('content'),
                width: 100,
                height: 40,
              ),
              child: const SizedBox(width: 80, height: 30),
            ),
          ),
        ),
      );
      controller.openAt(const Offset(420, 310));
      await settle(tester);
      final at = tester.getTopLeft(find.byKey(const Key('content')));
      expect(at.dx, closeTo(420, 2));
      expect(at.dy, closeTo(310, 2));
    });

    testWidgets('FinesseGestureDetector reports the global position, so '
        'what it hands showMenu lands at the pointer', (tester) async {
      final downs = <Offset>[];
      await tester.pumpWidget(
        docked(
          Builder(
            builder: (context) => FinesseGestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => downs.add(details.globalPosition),
              onSecondaryTapDown: (details) {
                downs.add(details.globalPosition);
                showMenu<void>(
                  context: context,
                  position: details.globalPosition,
                  items: const [MenuItem(child: Text('Paste'))],
                );
              },
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.tapAt(const Offset(380, 260));
      await tester.tapAt(
        const Offset(400, 300),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await settle(tester);
      expect(downs, const [Offset(380, 260), Offset(400, 300)]);
      final menu = tester.getRect(
        find.ancestor(
          of: find.text('Paste'),
          matching: find.byType(BackdropSurface),
        ),
      );
      expect(menu.left, closeTo(400, 1.5));
      expect(menu.top, closeTo(300, 1.5));
    });

    testWidgets('showMenu opens at the point it is given', (tester) async {
      late BuildContext page;
      await tester.pumpWidget(
        docked(
          Builder(
            builder: (context) {
              page = context;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      showMenu<void>(
        context: page,
        position: const Offset(400, 300),
        items: const [MenuItem(child: Text('Copy'))],
      ).ignore();
      await settle(tester);
      final menu = tester.getRect(
        find.ancestor(
          of: find.text('Copy'),
          matching: find.byType(BackdropSurface),
        ),
      );
      expect(menu.left, closeTo(400, 1.5));
      expect(menu.top, closeTo(300, 1.5));
    });

    testWidgets('showPopover opens at the rectangle it is given', (
      tester,
    ) async {
      late BuildContext page;
      await tester.pumpWidget(
        docked(
          Builder(
            builder: (context) {
              page = context;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      showPopover<void>(
        context: page,
        anchorRect: const Rect.fromLTWH(380, 280, 40, 20),
        padding: EdgeInsets.zero,
        builder: (context) =>
            const SizedBox(key: Key('content'), width: 100, height: 40),
      ).ignore();
      await settle(tester);
      final rect = tester.getRect(find.byKey(const Key('content')));
      // Centred under it, four below.
      expect(rect.center.dx, closeTo(400, 1.5));
      expect(rect.top, closeTo(304, 1.5));
    });
  });

  group('the gap an overlay keeps from the edge of the screen', () {
    Rect surface(WidgetTester tester, Finder content) => tester.getRect(
      find.ancestor(of: content, matching: find.byType(BackdropSurface)).first,
    );

    testWidgets('a popover pushed in from the side stops short of the edge', (
      tester,
    ) async {
      for (final alignment in [Alignment.topLeft, Alignment.topRight]) {
        final controller = PopoverController(isOpen: true);
        await tester.pumpWidget(
          FinesseApp(
            key: ValueKey(alignment),
            theme: ThemeData(motion: Motion.none),
            home: Align(
              alignment: alignment,
              child: Popover(
                controller: controller,
                builder: (context) => const SizedBox(
                  key: Key('content'),
                  width: 240,
                  height: 60,
                ),
                child: const SizedBox(width: 40, height: 30),
              ),
            ),
          ),
        );
        await settle(tester);
        final gap = Theme.of(
          tester.element(find.byType(Popover)),
        ).layoutTheme.gap(GapSize.sm);
        final rect = surface(tester, find.byKey(const Key('content')));
        expect(
          rect.left,
          greaterThanOrEqualTo(gap - .01),
          reason: '$alignment',
        );
        expect(
          rect.right,
          lessThanOrEqualTo(800 - gap + .01),
          reason: '$alignment',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      }
    });

    testWidgets('a menu that fits neither side of its point is moved onto '
        'the screen with the gap', (tester) async {
      tester.view.physicalSize = const Size(200, 120);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(motion: Motion.none),
          home: const ContextMenuRegion(
            constraints: BoxConstraints(minWidth: 150),
            items: [
              MenuItem(child: Text('Copy')),
              MenuItem(child: Text('Paste')),
            ],
            child: SizedBox.expand(),
          ),
        ),
      );
      await tester.tapAt(
        const Offset(120, 80),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await settle(tester);
      final rect = surface(tester, find.text('Copy'));
      expect(rect.width, greaterThan(120));
      expect(rect.right, closeTo(192, .01));
      expect(rect.left, greaterThanOrEqualTo(8 - .01));
      expect(rect.top, greaterThanOrEqualTo(8 - .01));
      expect(rect.bottom, lessThanOrEqualTo(112.01));
    });

    testWidgets('a menu mirrored at its point fits, and stays on the point', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(motion: Motion.none),
          home: const ContextMenuRegion(
            items: [MenuItem(child: Text('Copy'))],
            child: SizedBox.expand(),
          ),
        ),
      );
      await tester.tapAt(
        const Offset(797, 597),
        buttons: kSecondaryButton,
        kind: PointerDeviceKind.mouse,
      );
      await settle(tester);
      final rect = surface(tester, find.text('Copy'));
      // Its far corner is on the pointer: nothing was pushed anywhere.
      expect(rect.right, closeTo(797, 1.5));
      expect(rect.bottom, closeTo(597, 1.5));
    });

    testWidgets('a popover in line with a trigger at the edge stays in line', (
      tester,
    ) async {
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(motion: Motion.none),
          home: Align(
            alignment: Alignment.topLeft,
            child: DropdownMenu(
              items: const [MenuItem(child: Text('Profile'))],
              builder: (context, controller, _) => Button.outline(
                onPressed: controller.toggle,
                child: const Text('Account'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Account'));
      await settle(tester);
      expect(surface(tester, find.text('Profile')).left, closeTo(0, 1));
    });

    testWidgets('an overlay that has room keeps its place', (tester) async {
      final controller = PopoverController(isOpen: true);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(motion: Motion.none),
          home: Center(
            child: Popover(
              controller: controller,
              builder: (context) => const SizedBox(
                key: Key('content'),
                width: 240,
                height: 60,
              ),
              child: const SizedBox(width: 40, height: 30),
            ),
          ),
        ),
      );
      await settle(tester);
      final rect = surface(tester, find.byKey(const Key('content')));
      expect(rect.center.dx, closeTo(400, .5));
      // Four below its child.
      expect(rect.top, closeTo(300 + 15 + 4, .5));
    });
  });
}
