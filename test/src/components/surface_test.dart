import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a popover surface matches a Popover', (tester) async {
    final controller = PopoverController(isOpen: true);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: Column(
          children: [
            const Surface(child: Text('surface')),
            Popover(
              controller: controller,
              popover: (_) => const Text('popover'),
              child: const SizedBox(width: 10, height: 10),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    FinesseDecoration decorationAbove(String text) => tester
        .widget<Decorator>(
          find
              .ancestor(
                of: find.text(text),
                matching: find.byType(Decorator),
              )
              .first,
        )
        .decoration!;

    final surface = decorationAbove('surface');
    final popover = decorationAbove('popover');
    expect(surface.color, popover.color);
    expect(surface.border, popover.border);
    expect(surface.shadows, popover.shadows);
  });

  group('showPopover', () {
    Future<void> open(WidgetTester tester, Rect anchor) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        FinesseApp(
          home: Builder(
            builder: (context) => Button(
              onPressed: () => showPopover<void>(
                context: context,
                anchorRect: anchor,
                builder: (_) => const SizedBox(
                  width: 120,
                  height: 80,
                  child: Text('content'),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Rect surfaceRect(WidgetTester tester) => tester.getRect(
      find
          .ancestor(
            of: find.text('content'),
            matching: find.byType(Decorator),
          )
          .first,
    );

    testWidgets('opens below the rectangle, centred on it', (tester) async {
      const anchor = Rect.fromLTWH(300, 100, 40, 20);
      await open(tester, anchor);
      final rect = surfaceRect(tester);
      expect(rect.top, moreOrLessEquals(anchor.bottom + 4, epsilon: .5));
      expect(rect.center.dx, moreOrLessEquals(anchor.center.dx, epsilon: .5));
    });

    testWidgets('moves above when there is no room below', (tester) async {
      const anchor = Rect.fromLTWH(300, 560, 40, 20);
      await open(tester, anchor);
      final rect = surfaceRect(tester);
      expect(rect.bottom, moreOrLessEquals(anchor.top - 4, epsilon: .5));
    });

    testWidgets('its transition is set up once, not on every tick', (
      tester,
    ) async {
      // The framework calls `buildTransitions` on every tick of the route's
      // animation. It used to make its animation objects there, so sixty
      // times a second the scale and the fade below dropped their listener
      // and subscribed to a new one. They are kept with the route now.
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var contentBuilds = 0;
      await tester.pumpWidget(
        FinesseApp(
          home: Builder(
            builder: (context) => Button(
              onPressed: () => showPopover<void>(
                context: context,
                anchorRect: const Rect.fromLTWH(300, 100, 40, 20),
                builder: (_) {
                  contentBuilds++;
                  return const SizedBox(
                    width: 120,
                    height: 80,
                    child: Text('content'),
                  );
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      ScaleTransition scale() => tester.widget(
        find
            .ancestor(
              of: find.text('content'),
              matching: find.byType(ScaleTransition),
            )
            .first,
      );
      BackdropFadeHost host() => tester.widget(
        find.ancestor(
          of: find.text('content'),
          matching: find.byType(BackdropFadeHost),
        ),
      );
      final scaleAnimation = scale().scale;
      final fadeAnimation = host().opacity;
      final transitions = {scale()};
      final sizes = <double>{};
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        transitions.add(scale());
        sizes.add(scale().scale.value);
        expect(scale().scale, same(scaleAnimation));
        expect(host().opacity, same(fadeAnimation));
      }
      // The transition was rebuilt on those ticks, and it is moving…
      expect(transitions.length, greaterThan(4));
      expect(sizes.length, greaterThan(4));
      // …on the same animations, around content that was built once.
      expect(contentBuilds, 1);

      // The exit runs on them too, in a straight line from where it is.
      await tester.pump(const Duration(seconds: 1));
      expect(scaleAnimation.value, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(scale().scale, same(scaleAnimation));
      expect(host().opacity, same(fadeAnimation));
      expect(scaleAnimation.value, lessThan(1));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsNothing);
    });

    group('requestFocus', () {
      final field = FocusNode(debugLabel: 'field');
      tearDownAll(field.dispose);

      /// A focused field with a popover shown over it; [dialog] puts both
      /// the field and the button in a dialog.
      Future<void> openOverField(
        WidgetTester tester, {
        required bool requestFocus,
        bool dialog = false,
      }) async {
        tester.view.physicalSize = const Size(800, 600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        Widget page(BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 200, child: TextField(focusNode: field)),
            Button(
              onPressed: () => showPopover<void>(
                context: context,
                anchorRect: const Rect.fromLTWH(300, 400, 40, 20),
                requestFocus: requestFocus,
                builder: (_) => const SizedBox(
                  width: 120,
                  height: 40,
                  child: Text('content'),
                ),
              ),
              child: const Text('open'),
            ),
          ],
        );
        await tester.pumpWidget(
          FinesseApp(
            home: Builder(
              builder: (context) => Center(
                child: dialog
                    ? Button(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) => Dialog(
                            title: const Text('Dialog'),
                            child: page(context),
                          ),
                        ),
                        child: const Text('dialog'),
                      )
                    : page(context),
              ),
            ),
          ),
        );
        if (dialog) {
          await tester.tap(find.text('dialog'));
          await tester.pumpAndSettle();
        }
        field.requestFocus();
        await tester.pump();
        expect(field.hasPrimaryFocus, isTrue);
        // Not a tap on the button, which would take the focus itself.
        tester.widget<Button>(find.widgetWithText(Button, 'open')).onPressed!();
        await tester.pumpAndSettle();
        expect(find.text('content'), findsOneWidget);
      }

      testWidgets('by default the popover takes the focus', (tester) async {
        await openOverField(tester, requestFocus: true);
        expect(field.hasPrimaryFocus, isFalse);
      });

      testWidgets('with false the focus stays where it was, and typing '
          'goes on', (tester) async {
        await openOverField(tester, requestFocus: false);
        expect(field.hasPrimaryFocus, isTrue);
        tester.testTextInput.enterText('abc');
        await tester.pump();
        expect(find.text('abc'), findsOneWidget);
        expect(find.text('content'), findsOneWidget);
      });

      testWidgets('with false, Escape still closes it — once, and the '
          'focus stays', (tester) async {
        await openOverField(tester, requestFocus: false);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('content'), findsNothing);
        expect(field.hasPrimaryFocus, isTrue);
      });

      testWidgets('with false, over a dialog, Escape closes the popover and '
          'leaves the dialog', (tester) async {
        await openOverField(tester, requestFocus: false, dialog: true);
        expect(field.hasPrimaryFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('content'), findsNothing);
        expect(find.text('Dialog'), findsOneWidget);
        expect(field.hasPrimaryFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Dialog'), findsNothing);
      });

      testWidgets('with false, its Escape handler is there only while it '
          'is open', (tester) async {
        var passed = 0;
        KeyEventResult count(KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            passed++;
          }
          return KeyEventResult.ignored;
        }

        await openOverField(tester, requestFocus: false);
        // Removes the focus, so nothing in the focus tree takes the key.
        field.unfocus();
        await tester.pump();
        FocusManager.instance.addLateKeyEventHandler(count);
        addTearDown(
          () => FocusManager.instance.removeLateKeyEventHandler(count),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('content'), findsNothing);
        expect(passed, 0);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();
        expect(passed, 1);
      });

      testWidgets('with false, a tap outside still closes it', (tester) async {
        await openOverField(tester, requestFocus: false);
        await tester.tapAt(const Offset(700, 80));
        await tester.pumpAndSettle();
        expect(find.text('content'), findsNothing);
      });
    });

    testWidgets('closes on Escape and on a tap outside', (tester) async {
      await open(tester, const Rect.fromLTWH(300, 100, 40, 20));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('content'), findsNothing);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsNothing);
    });
  });
}
