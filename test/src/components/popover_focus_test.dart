import 'dart:ui' show PointerDeviceKind;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A row of three stops — `before`, the popover's field, `after` — with two
/// buttons in the popover. The popover hangs *below* the field, so plain
/// reading order would visit it last, after `after`.
class _Harness extends StatefulWidget {
  const _Harness({
    required this.controller,
    required this.field,
    this.requestFocus = false,
    this.shareGroup = false,
    this.above = false,
    this.onEscapeUnhandled,
  });

  final PopoverController controller;
  final FocusNode field;
  final bool requestFocus;

  /// Whether the field is in the popover's tap-region group.
  final bool shareGroup;

  /// Whether the popover opens above the field.
  final bool above;

  /// Called when Escape gets past the popover.
  final VoidCallback? onEscapeUnhandled;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final _group = Object();
  final before = FocusNode(debugLabel: 'before');
  final after = FocusNode(debugLabel: 'after');
  final first = FocusNode(debugLabel: 'first');
  final second = FocusNode(debugLabel: 'second');

  @override
  void dispose() {
    before.dispose();
    after.dispose();
    first.dispose();
    second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FinesseApp(
      home: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              widget.onEscapeUnhandled?.call(),
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  key: const Key('before'),
                  focusNode: before,
                ),
              ),
              Popover(
                controller: widget.controller,
                requestFocus: widget.requestFocus,
                groupId: _group,
                anchor: widget.above
                    ? const AnchorAuto(
                        offset: Offset(0, -4),
                        followerAnchor: Alignment.topCenter,
                        targetAnchor: Alignment.topCenter,
                      )
                    : null,
                popover: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('suggestions'),
                    Button(
                      focusNode: first,
                      onPressed: () {},
                      child: const Text('first'),
                    ),
                    Button(
                      focusNode: second,
                      onPressed: () {},
                      child: const Text('second'),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 160,
                  child: TextField(
                    key: const Key('field'),
                    focusNode: widget.field,
                    groupId: widget.shareGroup ? _group : null,
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(key: const Key('after'), focusNode: after),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  late PopoverController controller;
  late FocusNode field;

  setUp(() {
    controller = PopoverController();
    field = FocusNode(debugLabel: 'field');
  });

  tearDown(() {
    controller.dispose();
    field.dispose();
  });

  _HarnessState stateOf(WidgetTester tester) =>
      tester.state<_HarnessState>(find.byType(_Harness));

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Focuses the field and opens the popover.
  Future<void> open(
    WidgetTester tester, {
    bool requestFocus = false,
    bool shareGroup = false,
    bool above = false,
    VoidCallback? onEscapeUnhandled,
  }) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _Harness(
        controller: controller,
        field: field,
        requestFocus: requestFocus,
        shareGroup: shareGroup,
        above: above,
        onEscapeUnhandled: onEscapeUnhandled,
      ),
    );
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    expect(field.hasPrimaryFocus, isTrue);
    controller.show();
    await settle(tester);
    expect(find.text('suggestions'), findsOneWidget);
  }

  Future<void> tab(WidgetTester tester, {bool back = false}) async {
    if (back) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    if (back) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
  }

  group('a popover that does not take the focus', () {
    testWidgets('leaves it in the field it hangs under, and typing goes on', (
      tester,
    ) async {
      await open(tester);
      expect(
        field.hasPrimaryFocus,
        isTrue,
        reason: 'focus is on ${FocusManager.instance.primaryFocus}',
      );
      tester.testTextInput.enterText('abc');
      await tester.pump();
      expect(find.text('abc'), findsOneWidget);
      expect(find.text('suggestions'), findsOneWidget);
    });

    testWidgets('closes on Escape while its anchor has the focus, and lets '
        'Escape through while it is closed', (tester) async {
      var passed = 0;
      await open(tester, onEscapeUnhandled: () => passed++);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.text('suggestions'), findsNothing);
      expect(passed, 0);
      // The caret is still in the field.
      expect(field.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(passed, 1);
    });

    testWidgets('closes on a tap outside, not on a tap on its anchor or on '
        'itself', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const Key('field')));
      await settle(tester);
      expect(find.text('suggestions'), findsOneWidget);

      await tester.tap(find.text('suggestions'));
      await settle(tester);
      expect(find.text('suggestions'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await settle(tester);
      expect(find.text('suggestions'), findsNothing);
    });

    testWidgets('a click on the popover leaves the caret in a field that '
        'shares its tap-region group', (tester) async {
      await open(tester, shareGroup: true);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: const Offset(1, 1));
      await mouse.down(tester.getCenter(find.text('suggestions')));
      await mouse.up();
      await settle(tester);
      expect(find.text('suggestions'), findsOneWidget);
      expect(field.hasPrimaryFocus, isTrue);
    });

    for (final above in [false, true]) {
      testWidgets('Tab goes from the anchor into the popover and then on, '
          'and Shift+Tab back — opened ${above ? 'above' : 'below'}', (
        tester,
      ) async {
        await open(tester, above: above);
        final state = stateOf(tester);
        if (above) {
          expect(
            tester.getRect(find.text('first')).bottom,
            lessThan(tester.getRect(find.byKey(const Key('field'))).top),
          );
        }

        await tab(tester);
        expect(state.first.hasPrimaryFocus, isTrue);
        await tab(tester);
        expect(state.second.hasPrimaryFocus, isTrue);
        // Out of the popover, to what follows the anchor: it is no trap.
        await tab(tester);
        expect(state.after.hasPrimaryFocus, isTrue);
        // The popover is the app's to close; leaving it does not.
        expect(find.text('suggestions'), findsOneWidget);

        await tab(tester, back: true);
        expect(state.second.hasPrimaryFocus, isTrue);
        await tab(tester, back: true);
        expect(state.first.hasPrimaryFocus, isTrue);
        await tab(tester, back: true);
        expect(field.hasPrimaryFocus, isTrue);
        await tab(tester, back: true);
        expect(state.before.hasPrimaryFocus, isTrue);
      });
    }

    testWidgets('closed with Escape from inside, it gives the focus back to '
        'where it came from', (tester) async {
      var passed = 0;
      await open(tester, onEscapeUnhandled: () => passed++);
      final state = stateOf(tester);
      await tab(tester);
      await tab(tester);
      expect(state.second.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      // At once, not when the exit animation has finished.
      expect(field.hasPrimaryFocus, isTrue);
      expect(passed, 0);
      await settle(tester);
      expect(find.text('suggestions'), findsNothing);
      expect(field.hasPrimaryFocus, isTrue);
    });

    testWidgets('gives the focus back to the stop it was entered from, not '
        'to the one that had it when it opened', (tester) async {
      await open(tester);
      final state = stateOf(tester);
      // On to `after`, and back into the popover from there.
      await tab(tester);
      await tab(tester);
      await tab(tester);
      expect(state.after.hasPrimaryFocus, isTrue);
      await tab(tester, back: true);
      expect(state.second.hasPrimaryFocus, isTrue);

      controller.hide();
      await settle(tester);
      expect(state.after.hasPrimaryFocus, isTrue);
    });

    testWidgets('closed while the focus is elsewhere, it leaves it there', (
      tester,
    ) async {
      await open(tester);
      final state = stateOf(tester);
      await tab(tester);
      await tab(tester);
      await tab(tester);
      expect(state.after.hasPrimaryFocus, isTrue);
      controller.hide();
      await settle(tester);
      expect(state.after.hasPrimaryFocus, isTrue);
    });

    testWidgets('closed by a press on another field, the focus goes to that '
        'field', (tester) async {
      await open(tester);
      final state = stateOf(tester);
      await tab(tester);
      expect(state.first.hasPrimaryFocus, isTrue);

      await tester.tap(find.byKey(const Key('before')));
      await settle(tester);
      expect(find.text('suggestions'), findsNothing);
      expect(state.before.hasPrimaryFocus, isTrue);
    });
  });

  group('a popover that takes the focus (the default)', () {
    testWidgets('takes it when it opens and keeps Tab inside', (tester) async {
      await open(tester, requestFocus: true);
      final state = stateOf(tester);
      expect(field.hasFocus, isFalse);

      await tab(tester);
      expect(state.first.hasPrimaryFocus, isTrue);
      await tab(tester);
      expect(state.second.hasPrimaryFocus, isTrue);
      await tab(tester);
      expect(state.after.hasFocus, isFalse);
      expect(state.first.hasPrimaryFocus, isTrue);
    });

    testWidgets('gives it back to where it was when it closes, at once', (
      tester,
    ) async {
      await open(tester, requestFocus: true);
      final state = stateOf(tester);
      await tab(tester);
      expect(state.first.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(field.hasPrimaryFocus, isTrue);
      await settle(tester);
      expect(find.text('suggestions'), findsNothing);
      expect(field.hasPrimaryFocus, isTrue);
    });

    testWidgets('closed by a press on another field, the focus goes to that '
        'field', (tester) async {
      await open(tester, requestFocus: true);
      final state = stateOf(tester);
      await tester.tap(find.byKey(const Key('after')));
      await settle(tester);
      expect(find.text('suggestions'), findsNothing);
      expect(state.after.hasPrimaryFocus, isTrue);
    });
  });
  group('what builds on Popover passes requestFocus on', () {
    Future<void> settleMenu(WidgetTester tester) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    Future<FinesseContextMenuController> pumpMenu(
      WidgetTester tester, {
      required bool requestFocus,
    }) async {
      final menu = FinesseContextMenuController();
      addTearDown(menu.dispose);
      await tester.pumpWidget(
        FinesseApp(
          home: Center(
            child: DropdownMenu(
              controller: menu,
              requestFocus: requestFocus,
              items: [
                ContextMenuItem(onPressed: () {}, child: const Text('One')),
                ContextMenuItem(onPressed: () {}, child: const Text('Two')),
              ],
              builder: (context, controller, _) => SizedBox(
                width: 200,
                child: TextField(focusNode: field),
              ),
            ),
          ),
        ),
      );
      field.requestFocus();
      await tester.pump();
      menu.show();
      await settleMenu(tester);
      expect(find.text('One'), findsOneWidget);
      return menu;
    }

    FocusNode focusOf(WidgetTester tester, String item) =>
        Focus.of(tester.element(find.text(item)));

    testWidgets('a menu takes the focus by default', (tester) async {
      await pumpMenu(tester, requestFocus: true);
      expect(field.hasFocus, isFalse);
    });

    testWidgets('a menu that does not: the caret stays, Tab enters the '
        'list, the arrows move in it, and Escape gives the focus back', (
      tester,
    ) async {
      await pumpMenu(tester, requestFocus: false);
      expect(field.hasPrimaryFocus, isTrue);
      tester.testTextInput.enterText('ab');
      await tester.pump();
      expect(find.text('ab'), findsOneWidget);
      expect(find.text('One'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusOf(tester, 'One').hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(focusOf(tester, 'Two').hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(find.text('One'), findsNothing);
      expect(field.hasPrimaryFocus, isTrue);
    });

    testWidgets('a menu that does not closes on Escape from its anchor', (
      tester,
    ) async {
      await pumpMenu(tester, requestFocus: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(find.text('One'), findsNothing);
      expect(field.hasPrimaryFocus, isTrue);
    });

    testWidgets('a date picker that does not leaves the focus on its '
        'trigger; Tab moves into the calendar', (tester) async {
      final picker = PopoverController();
      final trigger = FocusNode(debugLabel: 'trigger');
      addTearDown(picker.dispose);
      addTearDown(trigger.dispose);
      await tester.pumpWidget(
        FinesseApp(
          home: Center(
            child: DatePicker(
              popoverController: picker,
              buttonFocusNode: trigger,
              requestFocus: false,
            ),
          ),
        ),
      );
      trigger.requestFocus();
      await tester.pump();
      picker.show();
      await settleMenu(tester);
      expect(find.byType(Calendar), findsOneWidget);
      expect(trigger.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!;
      expect(trigger.hasFocus, isFalse);
      var inCalendar = false;
      focused.context!.visitAncestorElements((element) {
        inCalendar = element.widget is Calendar;
        return !inCalendar;
      });
      expect(inCalendar, isTrue, reason: 'the focus is on $focused');

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(find.byType(Calendar), findsNothing);
      expect(trigger.hasPrimaryFocus, isTrue);
    });

    testWidgets("a date picker form field's focus node is its trigger's: a "
        'failed validation focuses the button', (tester) async {
      for (final range in [false, true]) {
        final formKey = GlobalKey<FinesseFormState>();
        final node = FocusNode(debugLabel: 'form field');
        addTearDown(node.dispose);
        await tester.pumpWidget(
          FinesseApp(
            home: Center(
              child: FinesseForm(
                key: formKey,
                child: range
                    ? DateRangePickerFormField(
                        id: 'when',
                        focusNode: node,
                        validator: (value) => value == null ? 'Pick' : null,
                      )
                    : DatePickerFormField(
                        id: 'when',
                        focusNode: node,
                        validator: (value) => value == null ? 'Pick' : null,
                      ),
              ),
            ),
          ),
        );
        expect(formKey.currentState!.validate(), isFalse);
        await tester.pump();
        // The node is a widget's, not an orphan under the route's scope.
        expect(node.context, isNotNull, reason: 'range: $range');
        expect(node.hasPrimaryFocus, isTrue, reason: 'range: $range');
        var inButton = false;
        node.context!.visitAncestorElements((element) {
          inButton = element.widget is Button;
          return !inButton;
        });
        expect(inButton, isTrue, reason: 'range: $range');
        await tester.pumpWidget(const SizedBox());
      }
    });
  });
}
