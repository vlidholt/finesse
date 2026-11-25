import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  group('Focusable', () {
    testWidgets('rebuilds its builder when the focus comes and goes, and '
        'not its child', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final states = <bool>[];
      final changes = <bool>[];
      var childBuilds = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Focusable(
            focusNode: node,
            onFocusChange: changes.add,
            builder: (context, focused, child) {
              states.add(focused);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [Text(focused ? 'focused' : 'idle'), child!],
              );
            },
            child: Builder(
              builder: (context) {
                childBuilds++;
                return const Text('static');
              },
            ),
          ),
        ),
      );
      expect(find.text('idle'), findsOneWidget);
      expect(states, [false]);
      expect(childBuilds, 1);

      node.requestFocus();
      // The focus moves in a microtask; the frame after it shows it.
      await tester.pump();
      await tester.pump();
      expect(find.text('focused'), findsOneWidget);
      expect(states, [false, true]);
      expect(changes, [true]);

      node.unfocus();
      // The focus moves in a microtask; the frame after it shows it.
      await tester.pump();
      await tester.pump();
      expect(find.text('idle'), findsOneWidget);
      expect(states, [false, true, false]);
      expect(changes, [true, false]);
      // The part that does not depend on the focus was built once.
      expect(childBuilds, 1);
    });

    testWidgets('without a node it makes one, which Tab reaches', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Focusable(
                builder: (context, focused, _) => Text(focused ? 'A on' : 'A'),
              ),
              Focusable(
                builder: (context, focused, _) => Text(focused ? 'B on' : 'B'),
              ),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.text('A on'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B on'), findsOneWidget);
    });

    testWidgets('autofocus takes the focus on the first build', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Focusable(
            autofocus: true,
            builder: (context, focused, _) => Text(focused ? 'on' : 'off'),
          ),
        ),
      );
      expect(find.text('on'), findsOneWidget);
    });

    testWidgets('canRequestFocus: false and skipTraversal keep Tab away', (
      tester,
    ) async {
      Widget row({bool canRequestFocus = true, bool? skipTraversal}) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focusable(
              canRequestFocus: canRequestFocus,
              skipTraversal: skipTraversal,
              builder: (context, focused, _) => Text(focused ? 'A on' : 'A'),
            ),
            Focusable(
              builder: (context, focused, _) => Text(focused ? 'B on' : 'B'),
            ),
          ],
        ),
      );

      await pumpFinesse(tester, row(canRequestFocus: false));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B on'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFinesse(tester, row(skipTraversal: true));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B on'), findsOneWidget);
    });

    testWidgets('onKeyEvent hears keys only while it has the focus', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final keys = <LogicalKeyboardKey>[];
      await pumpFinesse(
        tester,
        Center(
          child: Focusable(
            focusNode: node,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;
              keys.add(event.logicalKey);
              return KeyEventResult.handled;
            },
            builder: (context, focused, _) => const Text('meter'),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      expect(keys, isEmpty);
      node.requestFocus();
      // The focus moves in a microtask; the frame after it shows it.
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(keys, [LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.arrowDown]);
    });

    testWidgets('descendantsAreFocusable: false keeps the focus out of what '
        'it wraps', (tester) async {
      final inner = FocusNode();
      addTearDown(inner.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Focusable(
            descendantsAreFocusable: false,
            builder: (context, focused, child) => child!,
            child: Focus(focusNode: inner, child: const Text('inner')),
          ),
        ),
      );
      inner.requestFocus();
      // The focus moves in a microtask; the frame after it shows it.
      await tester.pump();
      await tester.pump();
      expect(inner.hasFocus, isFalse);
    });

    testWidgets('a focus inside it counts as focused', (tester) async {
      final inner = FocusNode();
      addTearDown(inner.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Focusable(
            builder: (context, focused, child) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text(focused ? 'within' : 'outside'), child!],
            ),
            child: Focus(focusNode: inner, child: const Text('inner')),
          ),
        ),
      );
      expect(find.text('outside'), findsOneWidget);
      inner.requestFocus();
      // The focus moves in a microtask; the frame after it shows it.
      await tester.pump();
      await tester.pump();
      expect(find.text('within'), findsOneWidget);
    });

    testWidgets('it can be removed while focused', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Focusable(
            autofocus: true,
            builder: (context, focused, _) => Text(focused ? 'on' : 'off'),
          ),
        ),
      );
      expect(find.text('on'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  });
}
