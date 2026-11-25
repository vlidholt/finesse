import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// `HoverCard`: a popover nobody has to open. The pointer resting on the
/// trigger opens it, as do the keyboard's focus and a long press; it stays
/// while the pointer is on trigger or card and goes when both were left.
void main() {
  const openDelay = Duration(milliseconds: 600);
  const closeDelay = Duration(milliseconds: 200);
  final card = find.text('Card');

  Widget hoverCard({
    Widget? child,
    WidgetBuilder? builder,
    Duration open = openDelay,
    Duration close = closeDelay,
    bool enabled = true,
    bool? showArrow,
    ValueChanged<bool>? onOpenChanged,
  }) => HoverCard(
    openDelay: open,
    closeDelay: close,
    enabled: enabled,
    showArrow: showArrow,
    onOpenChanged: onOpenChanged,
    builder:
        builder ??
        (context) => const SizedBox(width: 200, height: 80, child: Text('Card')),
    child: child ?? const SizedBox(width: 80, height: 24, child: Text('Name')),
  );

  /// Lets an entrance or an exit play out.
  Future<void> play(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<TestGesture> mouse(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(5, 5));
    addTearDown(gesture.removePointer);
    return gesture;
  }

  group('with a mouse', () {
    testWidgets('opens once the pointer has rested on the trigger', (
      tester,
    ) async {
      final changes = <bool>[];
      await pumpFinesse(
        tester,
        Center(child: hoverCard(onOpenChanged: changes.add)),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay - const Duration(milliseconds: 20));
      await tester.pump();
      expect(card, findsNothing);
      expect(changes, isEmpty);

      await tester.pump(const Duration(milliseconds: 40));
      await play(tester);
      expect(card, findsOneWidget);
      expect(changes, [true]);
    });

    testWidgets('a pointer passing through opens nothing', (tester) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(const Duration(milliseconds: 300));
      await pointer.moveTo(const Offset(5, 5));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(card, findsNothing);
    });

    testWidgets('closes a moment after the pointer has left', (tester) async {
      final changes = <bool>[];
      await pumpFinesse(
        tester,
        Center(child: hoverCard(onOpenChanged: changes.add)),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);

      await pointer.moveTo(const Offset(5, 5));
      await tester.pump(closeDelay - const Duration(milliseconds: 20));
      expect(changes, [true], reason: 'it closed before its delay');
      await tester.pump(const Duration(milliseconds: 40));
      expect(changes, [true, false]);
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('the pointer can travel into the card', (tester) async {
      final changes = <bool>[];
      await pumpFinesse(
        tester,
        Center(child: hoverCard(onOpenChanged: changes.add)),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);

      // Across the gap, where it is over neither…
      final name = tester.getRect(find.text('Name'));
      await pointer.moveTo(name.bottomCenter + const Offset(0, 2));
      await tester.pump(const Duration(milliseconds: 100));
      // …and on to the card, at its very edge: the padding counts.
      final surface = tester.getRect(find.byType(BackdropSurface));
      await pointer.moveTo(surface.topCenter + const Offset(0, 2));
      await tester.pump(const Duration(seconds: 2));
      expect(changes, [true]);
      expect(card, findsOneWidget);

      // Back to the trigger the same way.
      await pointer.moveTo(name.center);
      await tester.pump(const Duration(seconds: 2));
      expect(changes, [true]);

      // And away from both.
      await pointer.moveTo(surface.bottomRight + const Offset(40, 40));
      await tester.pump(closeDelay + const Duration(milliseconds: 20));
      expect(changes, [true, false]);
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('a card on its way out is not caught by the pointer', (
      tester,
    ) async {
      final changes = <bool>[];
      await pumpFinesse(
        tester,
        Center(child: hoverCard(onOpenChanged: changes.add)),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      final surface = tester.getRect(find.byType(BackdropSurface));

      await pointer.moveTo(const Offset(5, 5));
      await tester.pump(closeDelay + const Duration(milliseconds: 10));
      expect(changes, [true, false]);
      // Still on screen, fading: the pointer lands on it.
      await tester.pump(const Duration(milliseconds: 30));
      expect(card, findsOneWidget);
      await pointer.moveTo(surface.center);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(changes, [true, false]);
      expect(card, findsNothing);
    });

    testWidgets('a click on a focusable trigger does not pin the card', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: hoverCard(
            child: Button(onPressed: () {}, child: const Text('Name')),
          ),
        ),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);
      await pointer.down(tester.getCenter(find.text('Name')));
      await pointer.up();
      await tester.pump();

      await pointer.moveTo(const Offset(5, 5));
      await tester.pump(closeDelay + const Duration(milliseconds: 20));
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('a click elsewhere closes it at once', (tester) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);
      await pointer.moveTo(const Offset(5, 5));
      await pointer.down(const Offset(5, 5));
      await pointer.up();
      await play(tester);
      expect(card, findsNothing);
      // Nothing left waiting.
      await tester.pump(const Duration(seconds: 2));
      expect(card, findsNothing);
    });

    testWidgets('with no delays it opens and closes with the pointer', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: hoverCard(open: Duration.zero, close: Duration.zero),
        ),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await play(tester);
      expect(card, findsOneWidget);
      await pointer.moveTo(const Offset(5, 5));
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('settles while open', (tester) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
    });
  });

  group('with the keyboard', () {
    Widget focusable(String label) =>
        Button(onPressed: () {}, child: Text(label));

    testWidgets('focus on the trigger opens it, moving on closes it', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hoverCard(child: focusable('Name')),
              const SizedBox(height: 120),
              focusable('Next'),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(openDelay - const Duration(milliseconds: 20));
      expect(card, findsNothing);
      await tester.pump(const Duration(milliseconds: 40));
      await play(tester);
      expect(card, findsOneWidget);

      // The card did not take the focus.
      final focus = FocusManager.instance.primaryFocus!;
      expect(
        find.descendant(
          of: find.byType(Button).first,
          matching: find.byElementPredicate(
            (element) => element == focus.context,
          ),
        ),
        findsOneWidget,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(closeDelay + const Duration(milliseconds: 20));
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('Tab goes on into the card, which stays while it has the '
        'focus', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hoverCard(
                child: focusable('Name'),
                builder: (context) => SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [const Text('Card'), focusable('Follow')],
                  ),
                ),
              ),
              const SizedBox(height: 160),
              focusable('Next'),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(card, findsOneWidget);
      final focus = FocusManager.instance.primaryFocus!;
      expect(
        find.ancestor(
          of: find.byElementPredicate((e) => e == focus.context),
          matching: find.widgetWithText(Button, 'Follow'),
        ),
        findsOneWidget,
      );

      // And out the far side.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(closeDelay + const Duration(milliseconds: 20));
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('Escape closes it and is used up', (tester) async {
      var outer = 0;
      await pumpFinesse(
        tester,
        DismissShortcut(
          isActive: () => true,
          onDismiss: () => outer++,
          child: Center(child: hoverCard(child: focusable('Name'))),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await play(tester);
      expect(card, findsNothing);
      expect(outer, 0, reason: 'one press closed two layers');
      // Still focused, it does not come back by itself.
      await tester.pump(const Duration(seconds: 2));
      expect(card, findsNothing);

      // Closed, the key is not the card's any more.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(outer, 1);
    });

    testWidgets('Escape closes a card the pointer opened, wherever the '
        'focus is', (tester) async {
      var outer = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hoverCard(),
              const SizedBox(height: 120),
              DismissShortcut(
                isActive: () => true,
                onDismiss: () => outer++,
                child: Button(
                  autofocus: true,
                  onPressed: () {},
                  child: const Text('Elsewhere'),
                ),
              ),
            ],
          ),
        ),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await play(tester);
      expect(card, findsNothing);
      expect(outer, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(outer, 1);
    });
  });

  group('with a finger', () {
    testWidgets('a long press opens it at once and it stays', (tester) async {
      final changes = <bool>[];
      await pumpFinesse(
        tester,
        Center(child: hoverCard(onOpenChanged: changes.add)),
        formFactor: FormFactor.mobile,
      );
      final finger = await tester.startGesture(
        tester.getCenter(find.text('Name')),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
      expect(changes, [true]);
      await finger.up();
      await play(tester);
      expect(card, findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(card, findsOneWidget);

      // A tap outside closes it.
      await tester.tapAt(const Offset(5, 5));
      await play(tester);
      expect(card, findsNothing);
      expect(changes, [true, false]);
    });

    testWidgets('a tap opens nothing and reaches the trigger', (tester) async {
      var pressed = 0;
      await pumpFinesse(
        tester,
        Center(
          child: hoverCard(
            child: Button(onPressed: () => pressed++, child: const Text('Go')),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.text('Go'));
      await tester.pump(const Duration(seconds: 2));
      expect(pressed, 1);
      expect(card, findsNothing);
    });

    testWidgets('a mouse held down is not a long press', (tester) async {
      await pumpFinesse(
        tester,
        Center(child: hoverCard(open: const Duration(seconds: 30))),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await pointer.down(tester.getCenter(find.text('Name')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
      await pointer.up();
      await tester.pump();
      expect(card, findsNothing);
    });
  });

  group('lifecycle', () {
    testWidgets('disabled, nothing opens it; disabling closes it', (
      tester,
    ) async {
      var enabled = false;
      late StateSetter setState;
      await pumpFinesse(
        tester,
        Center(
          child: StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return hoverCard(enabled: enabled);
            },
          ),
        ),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(card, findsNothing);

      setState(() => enabled = true);
      await tester.pump();
      await pointer.moveTo(const Offset(5, 5));
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);

      setState(() => enabled = false);
      await play(tester);
      expect(card, findsNothing);
    });

    testWidgets('removed while waiting to open, it leaves no timer behind', (
      tester,
    ) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(const SizedBox());
      // A pending timer fails the test when it ends.
    });

    testWidgets('removed while waiting to close, it leaves no timer behind', (
      tester,
    ) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      await pointer.moveTo(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('nothing is scheduled at rest', (tester) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.binding.transientCallbackCount, 0);
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('its trigger hidden, the card is gone with it', (
      tester,
    ) async {
      var shown = true;
      late StateSetter setState;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return IndexedStack(
              index: shown ? 0 : 1,
              children: [
                Center(child: hoverCard()),
                const Center(child: Text('Other')),
              ],
            );
          },
        ),
      );
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      expect(card, findsOneWidget);

      setState(() => shown = false);
      await tester.pump();
      await tester.pump();
      expect(find.text('Card', skipOffstage: false), findsNothing);
      // The pointer is over the other page now: the card closes for good.
      await tester.pump(closeDelay + const Duration(milliseconds: 50));
      setState(() => shown = true);
      await play(tester);
      expect(card, findsNothing);
    });
  });

  group('looks and semantics', () {
    testWidgets('is a popover surface, padded by the popover theme', (
      tester,
    ) async {
      await pumpFinesse(tester, Center(child: hoverCard()));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      final theme = Theme.of(tester.element(find.byType(HoverCard)));
      final padding = theme.popoverTheme.padding!.resolve(TextDirection.ltr);
      final surface = tester.getRect(find.byType(BackdropSurface));
      // The line round the surface is inside its box.
      expect(
        tester.getTopLeft(card),
        surface.topLeft + Offset(padding.left + 1, padding.top + 1),
      );
      expect(surface.width, 200 + padding.horizontal + 2);
      // Below the trigger, centred on it.
      final name = tester.getRect(find.text('Name'));
      expect(surface.top, greaterThan(name.bottom));
      expect(surface.center.dx, closeTo(name.center.dx, .5));
      expect(find.byKey(SurfacePainter.arrowKey), findsNothing);
    });

    testWidgets('takes an arrow', (tester) async {
      await pumpFinesse(tester, Center(child: hoverCard(showArrow: true)));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Name')));
      await tester.pump(openDelay);
      await play(tester);
      final name = tester.getRect(find.text('Name'));
      expect(
        tester.getCenter(find.byKey(SurfacePainter.arrowKey)).dx,
        closeTo(name.center.dx, .5),
      );
    });

    for (final layout in kLayouts) {
      testWidgets(
        'opens in place on ${layout.formFactor.name}, '
        '${layout.textDirection.name}, at twice the text size',
        (tester) async {
          await pumpFinesse(
            tester,
            MediaQuery(
              data: MediaQueryData(
                size: kSurfaceSizes[layout.formFactor]!,
                textScaler: const TextScaler.linear(2),
              ),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: HoverCard(
                  openDelay: Duration.zero,
                  builder: (context) => const SizedBox(
                    width: 220,
                    child: Text('A longer line of text that has to wrap.'),
                  ),
                  child: const Text('Name'),
                ),
              ),
            ),
            formFactor: layout.formFactor,
            textDirection: layout.textDirection,
          );
          final finger = await tester.startGesture(
            tester.getCenter(find.text('Name')),
          );
          await tester.pump(
            kLongPressTimeout + const Duration(milliseconds: 20),
          );
          await finger.up();
          await play(tester);
          expect(tester.takeException(), isNull);
          final surface = tester.getRect(find.byType(BackdropSurface));
          final screen = Offset.zero & kSurfaceSizes[layout.formFactor]!;
          expect(screen.contains(surface.topLeft), isTrue);
          expect(surface.right, lessThanOrEqualTo(screen.right));
        },
      );
    }

    for (final (name, theme, reduced) in [
      ('reduced motion', null, true),
      ('Motion.none', ThemeData(motion: Motion.none), false),
    ]) {
      testWidgets('with $name it opens, closes and settles', (tester) async {
        await pumpFinesse(
          tester,
          MediaQuery(
            data: MediaQueryData(
              size: const Size(1280, 800),
              disableAnimations: reduced,
            ),
            child: Center(child: hoverCard()),
          ),
          theme: theme,
        );
        final pointer = await mouse(tester);
        await pointer.moveTo(tester.getCenter(find.text('Name')));
        await tester.pump(openDelay);
        await tester.pumpAndSettle();
        expect(card, findsOneWidget);
        await pointer.moveTo(const Offset(5, 5));
        await tester.pump(closeDelay);
        await tester.pumpAndSettle();
        expect(card, findsNothing);
      });
    }

    testWidgets('a screen reader can show the card and dismiss it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, Center(child: hoverCard()));
      final trigger = tester.getSemantics(find.text('Name'));
      expect(
        trigger.getSemanticsData().hasAction(SemanticsAction.longPress),
        isTrue,
      );
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        trigger.id,
        SemanticsAction.longPress,
      );
      await play(tester);
      expect(card, findsOneWidget);

      final node = tester.getSemantics(card);
      SemanticsNode? dismissable = node;
      while (dismissable != null &&
          !dismissable.getSemanticsData().hasAction(SemanticsAction.dismiss)) {
        dismissable = dismissable.parent;
      }
      expect(dismissable, isNotNull, reason: 'the card cannot be dismissed');
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        dismissable!.id,
        SemanticsAction.dismiss,
      );
      await play(tester);
      expect(card, findsNothing);
      handle.dispose();
    });
  });
}
