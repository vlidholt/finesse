import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  var presses = 0;
  setUp(() => presses = 0);

  Widget panel({
    required bool disabled,
    bool showForbiddenCursor = false,
    double? disabledOpacity,
  }) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(onPressed: () {}, child: const Text('Before')),
        Disabled(
          key: const ValueKey('group'),
          enabled: !disabled,
          showForbiddenCursor: showForbiddenCursor,
          disabledOpacity: disabledOpacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                onPressed: () => presses++,
                child: const Text('Inside'),
              ),
              const SizedBox(width: 200, child: TextField()),
            ],
          ),
        ),
        Button(onPressed: () {}, child: const Text('After')),
      ],
    ),
  );

  double opacityOf(WidgetTester tester) => tester
      .widget<Opacity>(
        find
            .descendant(
              of: find.byKey(const ValueKey('group')),
              matching: find.byType(Opacity),
            )
            .first,
      )
      .opacity;

  bool focusIsIn(WidgetTester tester, Finder finder) {
    final focus = FocusManager.instance.primaryFocus?.context;
    if (focus == null) return false;
    final target = tester.element(finder);
    var found = identical(focus, target);
    focus.visitAncestorElements((ancestor) {
      if (identical(ancestor, target)) found = true;
      return !found;
    });
    return found;
  }

  group('Disabled', () {
    testWidgets('enabled, it changes nothing', (tester) async {
      await pumpFinesse(tester, panel(disabled: false));
      expect(opacityOf(tester), 1);
      await tester.tap(find.text('Inside'));
      await tester.pump();
      expect(presses, 1);
    });

    testWidgets('disabled, it takes no taps and is dimmed by the theme', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        panel(disabled: true),
        theme: ThemeData(disabledOpacity: .3),
      );
      expect(opacityOf(tester), .3);
      await tester.tap(find.text('Inside'), warnIfMissed: false);
      await tester.pump();
      expect(presses, 0);

      // Its own opacity wins over the theme's.
      await pumpFinesse(
        tester,
        panel(disabled: true, disabledOpacity: .8),
        theme: ThemeData(disabledOpacity: .3),
      );
      expect(opacityOf(tester), .8);
    });

    testWidgets('disabled, Tab skips it and the keyboard cannot press it', (
      tester,
    ) async {
      await pumpFinesse(tester, panel(disabled: true));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusIsIn(tester, find.widgetWithText(Button, 'Before')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // Straight past the group.
      expect(focusIsIn(tester, find.byKey(const ValueKey('group'))), isFalse);
      expect(focusIsIn(tester, find.widgetWithText(Button, 'After')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(presses, 0);
    });

    testWidgets('enabled, Tab goes through it', (tester) async {
      await pumpFinesse(tester, panel(disabled: false));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusIsIn(tester, find.widgetWithText(Button, 'Inside')), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 1);
    });

    testWidgets('a control that has the focus gives it up when disabled', (
      tester,
    ) async {
      await pumpFinesse(tester, panel(disabled: false));
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focusIsIn(tester, find.byType(TextField)), isTrue);

      await pumpFinesse(tester, panel(disabled: true));
      expect(focusIsIn(tester, find.byKey(const ValueKey('group'))), isFalse);
      // Typing reaches nothing.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(presses, 0);
    });

    testWidgets('the child keeps its state when switched off and on', (
      tester,
    ) async {
      await pumpFinesse(tester, panel(disabled: false));
      await tester.enterText(find.byType(EditableText), 'kept');
      final before = tester.state(find.byType(EditableText));
      await pumpFinesse(tester, panel(disabled: true));
      expect(tester.state(find.byType(EditableText)), same(before));
      expect(find.text('kept'), findsOneWidget);
      await pumpFinesse(tester, panel(disabled: false));
      expect(tester.state(find.byType(EditableText)), same(before));
    });

    testWidgets('the forbidden cursor shows only while disabled, and only '
        'when asked for', (tester) async {
      Future<MouseCursor> cursorOver(Widget widget) async {
        await pumpFinesse(tester, widget);
        final mouse = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await mouse.addPointer(location: tester.getCenter(find.text('Inside')));
        await tester.pump();
        final cursor = RendererBinding.instance.mouseTracker
            .debugDeviceActiveCursor(1);
        await mouse.removePointer();
        await tester.pump();
        return cursor!;
      }

      expect(
        await cursorOver(panel(disabled: true, showForbiddenCursor: true)),
        SystemMouseCursors.forbidden,
      );
      expect(
        await cursorOver(panel(disabled: true)),
        isNot(SystemMouseCursors.forbidden),
      );
      expect(
        await cursorOver(panel(disabled: false, showForbiddenCursor: true)),
        isNot(SystemMouseCursors.forbidden),
      );
    });

    testWidgets('assistive technology can read it but not act on it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, panel(disabled: true));
      final node = tester.getSemantics(find.text('Inside'));
      expect(node.label, contains('Inside'));
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );
      handle.dispose();
    });
  });
}
