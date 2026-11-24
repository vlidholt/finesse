import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  /// A pressable that records the states it was last built with.
  Widget recorder(
    List<Set<WidgetState>> log, {
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    bool? selected,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
    String? semanticValue,
    MouseCursor cursor = SystemMouseCursors.click,
    Size size = const Size(120, 40),
  }) {
    return Center(
      child: Pressable(
        onPressed: onPressed,
        onLongPress: onLongPress,
        selected: selected,
        focusNode: focusNode,
        autofocus: autofocus,
        semanticLabel: semanticLabel,
        semanticValue: semanticValue,
        cursor: cursor,
        builder: (context, states) {
          log.add({...states});
          return SizedBox.fromSize(size: size, child: const Text('Go'));
        },
      ),
    );
  }

  Future<TestGesture> hover(WidgetTester tester, Offset position) =>
      hoverAt(tester, position);

  // As on a desktop; see the helper for why a test has to say so.
  setUp(useTraditionalHighlights);

  group('Pressable activation', () {
    testWidgets('a tap calls onPressed', (tester) async {
      var presses = 0;
      await pumpFinesse(tester, recorder([], onPressed: () => presses++));

      await tester.tap(find.byType(Pressable));
      await tester.pump();
      expect(presses, 1);
    });

    testWidgets('the whole region is the target, not only its content', (
      tester,
    ) async {
      var presses = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Pressable(
            onPressed: () => presses++,
            // A transparent region with nothing painted in its corner.
            builder: (context, states) => const SizedBox(
              width: 200,
              height: 80,
              child: Align(alignment: Alignment.topLeft, child: Text('Go')),
            ),
          ),
        ),
      );

      final rect = tester.getRect(find.byType(Pressable));
      await tester.tapAt(rect.bottomRight - const Offset(4, 4));
      await tester.pump();
      expect(presses, 1);
    });

    testWidgets('a long press calls onLongPress and not onPressed', (
      tester,
    ) async {
      var presses = 0;
      var longPresses = 0;
      await pumpFinesse(
        tester,
        recorder(
          [],
          onPressed: () => presses++,
          onLongPress: () => longPresses++,
        ),
      );

      await tester.longPress(find.byType(Pressable));
      await tester.pump();
      expect(longPresses, 1);
      expect(presses, 0);
    });

    testWidgets('Enter and Space activate the focused region', (tester) async {
      var presses = 0;
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpFinesse(
        tester,
        recorder([], onPressed: () => presses++, focusNode: node),
      );

      node.requestFocus();
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(presses, 2);
    });

    testWidgets('Tab reaches it and moves past it', (tester) async {
      final first = FocusNode(debugLabel: 'first');
      final second = FocusNode(debugLabel: 'second');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await pumpFinesse(
        tester,
        Column(
          children: [
            Pressable(
              focusNode: first,
              onPressed: () {},
              builder: (context, states) => const Text('One'),
            ),
            Pressable(
              focusNode: second,
              onPressed: () {},
              builder: (context, states) => const Text('Two'),
            ),
          ],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(first.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(second.hasPrimaryFocus, isTrue);
    });

    testWidgets('autofocus takes focus on the first build', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final log = <Set<WidgetState>>[];
      await pumpFinesse(
        tester,
        recorder(log, onPressed: () {}, focusNode: node, autofocus: true),
      );
      expect(node.hasPrimaryFocus, isTrue);
    });
  });

  group('Pressable states', () {
    testWidgets('an idle, enabled region reports none', (tester) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onPressed: () {}));
      expect(log.last, isEmpty);
    });

    testWidgets('hover is reported while the pointer is over it', (
      tester,
    ) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onPressed: () {}));

      final gesture = await hover(
        tester,
        tester.getCenter(find.byType(Pressable)),
      );
      expect(log.last, {WidgetState.hovered});

      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(log.last, isEmpty);
    });

    testWidgets('hover is reported in touch highlight mode too', (
      tester,
    ) async {
      // A touch-first platform with a mouse attached: the focus manager
      // stays in touch mode until a key is pressed, and the action
      // detector's own hover callback never fires there.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onPressed: () {}));
      expect(FocusManager.instance.highlightMode, FocusHighlightMode.touch);

      final gesture = await hover(
        tester,
        tester.getCenter(find.byType(Pressable)),
      );
      expect(log.last, {WidgetState.hovered});

      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(log.last, isEmpty);
    });

    testWidgets('hover is reported in the automatic highlight mode a test '
        'starts in', (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onPressed: () {}));

      await hover(tester, tester.getCenter(find.byType(Pressable)));
      expect(log.last, {WidgetState.hovered});
    });

    testWidgets('hover on one region leaves its neighbour alone', (
      tester,
    ) async {
      final first = <Set<WidgetState>>[];
      final second = <Set<WidgetState>>[];
      await pumpFinesse(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (key, log) in [('one', first), ('two', second)])
                Pressable(
                  key: Key(key),
                  onPressed: () {},
                  builder: (context, states) {
                    log.add({...states});
                    return const SizedBox(width: 80, height: 40);
                  },
                ),
            ],
          ),
        ),
      );
      final gesture = await hover(
        tester,
        tester.getCenter(find.byKey(const Key('one'))),
      );
      expect(first.last, {WidgetState.hovered});
      expect(second.last, isEmpty);

      await gesture.moveTo(tester.getCenter(find.byKey(const Key('two'))));
      await tester.pump();
      expect(first.last, isEmpty);
      expect(second.last, {WidgetState.hovered});
    });

    testWidgets('pressed is reported between down and up', (tester) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onPressed: () {}));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      expect(log.last, contains(WidgetState.pressed));

      await gesture.up();
      await tester.pump();
      expect(log.last, isNot(contains(WidgetState.pressed)));
    });

    testWidgets('pressed is dropped when the gesture is cancelled', (
      tester,
    ) async {
      final log = <Set<WidgetState>>[];
      var presses = 0;
      await pumpFinesse(tester, recorder(log, onPressed: () => presses++));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      expect(log.last, contains(WidgetState.pressed));

      // Dragging away turns the tap into nothing.
      await gesture.moveBy(const Offset(0, 300));
      await gesture.up();
      await tester.pump();
      expect(log.last, isNot(contains(WidgetState.pressed)));
      expect(presses, 0);
    });

    testWidgets('focused is reported while it has keyboard focus', (
      tester,
    ) async {
      final log = <Set<WidgetState>>[];
      final node = FocusNode();
      final other = FocusNode();
      addTearDown(node.dispose);
      addTearDown(other.dispose);
      await pumpFinesse(
        tester,
        Column(
          children: [
            Pressable(
              focusNode: node,
              onPressed: () {},
              builder: (context, states) {
                log.add({...states});
                return const Text('One');
              },
            ),
            Focus(focusNode: other, child: const Text('Two')),
          ],
        ),
      );
      expect(log.last, isEmpty);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
      expect(log.last, {WidgetState.focused});

      other.requestFocus();
      // One frame for the focus change to land, one for the rebuild.
      await tester.pump();
      await tester.pump();
      expect(node.hasFocus, isFalse);
      expect(log.last, isEmpty);
    });

    testWidgets('selected is reported alongside the interaction states', (
      tester,
    ) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(
        tester,
        recorder(log, onPressed: () {}, selected: true),
      );
      expect(log.last, {WidgetState.selected});

      await hover(tester, tester.getCenter(find.byType(Pressable)));
      expect(log.last, {WidgetState.selected, WidgetState.hovered});
    });

    testWidgets('selected: false and null both report no selected state', (
      tester,
    ) async {
      for (final selected in [false, null]) {
        final log = <Set<WidgetState>>[];
        await pumpFinesse(
          tester,
          recorder(log, onPressed: () {}, selected: selected),
        );
        expect(log.last, isEmpty, reason: 'selected: $selected');
      }
    });

    testWidgets('with no callbacks it is disabled', (tester) async {
      final log = <Set<WidgetState>>[];
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpFinesse(tester, recorder(log, focusNode: node));
      expect(log.last, {WidgetState.disabled});

      // Hover and press are not reported…
      await hover(tester, tester.getCenter(find.byType(Pressable)));
      expect(log.last, {WidgetState.disabled});
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Pressable)),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(log.last, {WidgetState.disabled});
      await gesture.up();
      await gesture.removePointer();

      // …and it takes no focus.
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('a disabled selected region still reports selected', (
      tester,
    ) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, selected: true));
      expect(log.last, {WidgetState.disabled, WidgetState.selected});
    });

    testWidgets('only onLongPress is enough to enable it', (tester) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onLongPress: () {}));
      expect(log.last, isEmpty);
    });

    testWidgets('losing its callback while hovered drops the hover', (
      tester,
    ) async {
      final log = <Set<WidgetState>>[];
      await pumpFinesse(tester, recorder(log, onPressed: () {}));
      await hover(tester, tester.getCenter(find.byType(Pressable)));
      expect(log.last, {WidgetState.hovered});

      await pumpFinesse(tester, recorder(log));
      expect(log.last, {WidgetState.disabled});
    });
  });

  group('Pressable cursor', () {
    /// The cursor the mouse tracker resolves at [position]: the first
    /// region on the hit path that names one, or the basic cursor when
    /// every region defers.
    MouseCursor cursorAt(WidgetTester tester, Offset position) {
      final result = HitTestResult();
      RendererBinding.instance.hitTestInView(
        result,
        position,
        tester.view.viewId,
      );
      for (final entry in result.path) {
        final target = entry.target;
        if (target is RenderMouseRegion && target.cursor != MouseCursor.defer) {
          return target.cursor;
        }
      }
      return SystemMouseCursors.basic;
    }

    testWidgets('an enabled region shows the click cursor', (tester) async {
      await pumpFinesse(tester, recorder([], onPressed: () {}));
      expect(
        cursorAt(tester, tester.getCenter(find.byType(Pressable))),
        SystemMouseCursors.click,
      );
    });

    testWidgets('or the one it is given', (tester) async {
      await pumpFinesse(
        tester,
        recorder([], onPressed: () {}, cursor: SystemMouseCursors.grab),
      );
      expect(
        cursorAt(tester, tester.getCenter(find.byType(Pressable))),
        SystemMouseCursors.grab,
      );
    });

    testWidgets('a disabled region shows the basic cursor', (tester) async {
      await pumpFinesse(
        tester,
        recorder([], cursor: SystemMouseCursors.grab),
      );
      expect(
        cursorAt(tester, tester.getCenter(find.byType(Pressable))),
        SystemMouseCursors.basic,
      );
      // Its own region names no cursor at all while disabled.
      final region = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byType(Pressable),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(region.cursor, MouseCursor.defer);
    });
  });

  group('Pressable semantics', () {
    testWidgets('an enabled region is a tappable, focusable button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, recorder([], onPressed: () {}));

      expect(
        tester.getSemantics(find.byType(Pressable)),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a selected region is announced as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, recorder([], onPressed: () {}, selected: true));

      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('a plain button (selected: null, the default) carries no '
        'selected state at all', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, recorder([], onPressed: () {}));

      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, ui.Tristate.none);
      expect(const Pressable(builder: _empty).selected, isNull);
      handle.dispose();
    });

    testWidgets('selected: false is announced as not selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        recorder([], onPressed: () {}, selected: false),
      );

      expect(
        tester.getSemantics(find.byType(Pressable)),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          hasSelectedState: true,
          // isSelected stays false.
        ),
      );
      expect(
        tester
            .getSemantics(find.byType(Pressable))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        ui.Tristate.isFalse,
      );
      handle.dispose();
    });

    testWidgets('the three selected values are told apart, enabled or not', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      for (final enabled in [true, false]) {
        for (final (selected, expected) in [
          (null, ui.Tristate.none),
          (false, ui.Tristate.isFalse),
          (true, ui.Tristate.isTrue),
        ]) {
          await pumpFinesse(
            tester,
            recorder([], onPressed: enabled ? () {} : null, selected: selected),
          );
          expect(
            tester
                .getSemantics(find.byType(Pressable))
                .getSemanticsData()
                .flagsCollection
                .isSelected,
            expected,
            reason: 'selected: $selected, enabled: $enabled',
          );
        }
      }
      handle.dispose();
    });

    testWidgets('a disabled region is a disabled button with no tap action', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, recorder([]));

      expect(
        tester.getSemantics(find.byType(Pressable)),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          // Not enabled, not focusable, nothing to do.
        ),
      );
      handle.dispose();
    });

    testWidgets('semanticLabel names a region whose content is an icon', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Pressable(
            onPressed: () {},
            semanticLabel: 'Create post',
            builder: (context, states) =>
                const ExcludeSemantics(child: Icon(PhosphorIconsRegular.plus)),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Create post'), findsOneWidget);
      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.label, 'Create post');
      expect(data.flagsCollection.isButton, isTrue);
      handle.dispose();
    });

    testWidgets("a semanticLabel replaces the content's own semantics", (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Pressable(
            onPressed: () {},
            semanticLabel: 'Open profile',
            builder: (context, states) => const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Omar Rahimi'),
                Icon(PhosphorIconsRegular.user, semanticLabel: 'Person'),
              ],
            ),
          ),
        ),
      );

      // The label alone, not "Open profile Omar Rahimi Person".
      final node = tester.getSemantics(find.byType(Pressable));
      expect(node.getSemanticsData().label, 'Open profile');
      expect(find.bySemanticsLabel(RegExp('Omar')), findsNothing);
      expect(find.bySemanticsLabel('Person'), findsNothing);
      // The content is still painted.
      expect(find.text('Omar Rahimi'), findsOneWidget);
      // And the region is still one a screen reader can focus and activate:
      // only the content is excluded, not the detectors' actions.
      expect(
        node,
        matchesSemantics(
          label: 'Open profile',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('excludeSemantics: false keeps the content under a label, '
        'controls included', (tester) async {
      final handle = tester.ensureSemantics();
      var outer = 0;
      var inner = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Pressable(
            onPressed: () => outer++,
            semanticLabel: 'Open profile',
            excludeSemantics: false,
            builder: (context, states) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Omar Rahimi'),
                Pressable(
                  onPressed: () => inner++,
                  semanticLabel: 'Follow',
                  builder: (context, states) =>
                      const SizedBox(width: 40, height: 40),
                ),
              ],
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(Pressable).first);
      // The label first, then the content it no longer replaces.
      expect(node.getSemanticsData().label, 'Open profile\nOmar Rahimi');
      // The control inside is its own node, with its own action.
      final follow = tester.getSemantics(find.bySemanticsLabel('Follow'));
      expect(follow.id, isNot(node.id));
      expect(
        follow.getSemanticsData().hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      final owner = node.owner!;
      owner.performAction(follow.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect((outer, inner), (0, 1));
      owner.performAction(node.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect((outer, inner), (1, 1));
      handle.dispose();
    });

    testWidgets('by default a label hides a control inside the region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Pressable(
            onPressed: () {},
            semanticLabel: 'Open profile',
            builder: (context, states) => Pressable(
              onPressed: () {},
              semanticLabel: 'Follow',
              builder: (context, states) =>
                  const SizedBox(width: 40, height: 40),
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Open profile'), findsOneWidget);
      expect(find.bySemanticsLabel('Follow'), findsNothing);
      expect(const Pressable(builder: _empty).excludeSemantics, isNull);
      handle.dispose();
    });

    testWidgets('excludeSemantics: true drops the content even without a '
        'label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Center(
          child: Pressable(
            onPressed: () {},
            excludeSemantics: true,
            builder: (context, states) => const Text('Decoration'),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Decoration'), findsNothing);
      // Still a button a screen reader can activate.
      expect(
        tester.getSemantics(find.byType(Pressable)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('the semantic tap action reaches a labelled region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await pumpFinesse(
        tester,
        recorder([], onPressed: () => presses++, semanticLabel: 'Go now'),
      );

      final node = tester.getSemantics(find.byType(Pressable));
      node.owner!.performAction(node.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect(presses, 1);
      handle.dispose();
    });

    testWidgets('without a semanticLabel the content is what is read', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, recorder([], onPressed: () {}));
      expect(
        tester.getSemantics(find.byType(Pressable)).getSemanticsData().label,
        'Go',
      );
      handle.dispose();
    });

    testWidgets('semanticValue is read after the label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        recorder(
          [],
          onPressed: () {},
          semanticLabel: 'Messages',
          semanticValue: '3',
        ),
      );
      var data = tester.getSemantics(find.byType(Pressable)).getSemanticsData();
      expect(data.label, 'Messages');
      expect(data.value, '3');

      // It needs no label of its own: the content names the region.
      await pumpFinesse(
        tester,
        recorder([], onPressed: () {}, semanticValue: '12 unread'),
      );
      data = tester.getSemantics(find.byType(Pressable)).getSemanticsData();
      expect(data.label, 'Go');
      expect(data.value, '12 unread');

      // And none by default.
      await pumpFinesse(tester, recorder([], onPressed: () {}));
      data = tester.getSemantics(find.byType(Pressable)).getSemanticsData();
      expect(data.value, isEmpty);
      handle.dispose();
    });

    testWidgets('the semantic tap action calls onPressed', (tester) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await pumpFinesse(tester, recorder([], onPressed: () => presses++));

      final node = tester.getSemantics(find.byType(Pressable));
      node.owner!.performAction(node.id, ui.SemanticsAction.tap);
      await tester.pump();
      expect(presses, 1);
      handle.dispose();
    });
  });

  group('FocusRing', () {
    testWidgets('paints nothing and takes no space while hidden', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: FocusRing(
            visible: false,
            child: SizedBox(key: Key('box'), width: 60, height: 30),
          ),
        ),
      );
      // The paint widget is there either way — see the next test — but it
      // has nothing to paint.
      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(FocusRing),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(paint.painter, isNull);
      expect(paint.foregroundPainter, isNull);
      expect(tester.getSize(find.byType(FocusRing)), const Size(60, 30));
    });

    testWidgets("showing and hiding the ring keeps the child's state", (
      tester,
    ) async {
      // Returning the child bare while hidden moved it in the tree whenever
      // focus came or went, which re-created its State and snapped any
      // implicit animation it was running.
      var created = 0;
      Widget ring({required bool visible}) => Center(
        child: FocusRing(
          visible: visible,
          child: _Counted(onCreate: () => created++),
        ),
      );
      await pumpFinesse(tester, ring(visible: false));
      await pumpFinesse(tester, ring(visible: true));
      await pumpFinesse(tester, ring(visible: false));
      expect(created, 1);
    });

    testWidgets('takes no space in layout while visible', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: FocusRing(
            visible: true,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            child: SizedBox(key: Key('box'), width: 60, height: 30),
          ),
        ),
      );
      expect(tester.getSize(find.byType(FocusRing)), const Size(60, 30));
      expect(tester.getSize(find.byKey(const Key('box'))), const Size(60, 30));
    });

    testWidgets('is drawn outside the child, flush against it, in the '
        "theme's ring", (tester) async {
      // On white, so the expected pixel is a plain blend.
      final boundary = GlobalKey();
      await pumpFinesse(
        tester,
        Center(
          child: RepaintBoundary(
            key: boundary,
            child: const ColoredBox(
              color: Color(0xffffffff),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: FocusRing(
                  visible: true,
                  child: SizedBox(width: 60, height: 30),
                ),
              ),
            ),
          ),
        ),
      );
      final theme = themeOf(tester, find.byType(FocusRing));
      final ringWidth = theme.style.ringWidth;
      expect(ringWidth, 3);
      final ring = Color.alphaBlend(
        theme.colorScheme.ring.withValues(alpha: theme.style.ringOpacity),
        const Color(0xffffffff),
      );

      late final ui.Image image;
      await tester.runAsync(() async {
        image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
      });
      final data = (await tester.runAsync(() => image.toByteData()))!;
      Color pixel(double x, double y) {
        final index = (y.floor() * image.width + x.floor()) * 4;
        return Color.fromARGB(
          data.getUint8(index + 3),
          data.getUint8(index),
          data.getUint8(index + 1),
          data.getUint8(index + 2),
        );
      }

      void expectClose(Color actual, Color expected, String reason) {
        for (final (a, b) in [
          (actual.r, expected.r),
          (actual.g, expected.g),
          (actual.b, expected.b),
        ]) {
          expect((a - b).abs(), lessThan(3 / 255), reason: reason);
        }
      }

      const white = Color(0xffffffff);
      // The child's box is at (20, 20)–(80, 50) in the boundary.
      // Inside the child: nothing.
      expectClose(pixel(50, 35), white, 'inside the child');
      expectClose(pixel(21, 35), white, 'just inside the left edge');
      // The ring's band, on each side, starts right at the edge.
      expectClose(pixel(20 - 1.5, 35), ring, 'left band');
      expectClose(pixel(80 + 1.5, 35), ring, 'right band');
      expectClose(pixel(50, 20 - 1.5), ring, 'top band');
      expectClose(pixel(50, 50 + 1.5), ring, 'bottom band');
      expectClose(pixel(20 - .5, 35), ring, 'flush against the left edge');
      // And ends a ring width out.
      expectClose(pixel(20 - ringWidth - 1.5, 35), white, 'past the ring');
      expectClose(pixel(50, 50 + ringWidth + 1.5), white, 'below the ring');
    });

    testWidgets('inset: true draws the ring just inside the bounds and '
        'nothing outside them', (tester) async {
      final boundary = GlobalKey();
      await pumpFinesse(
        tester,
        Center(
          child: RepaintBoundary(
            key: boundary,
            child: const ColoredBox(
              color: Color(0xffffffff),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: FocusRing(
                  visible: true,
                  inset: true,
                  child: SizedBox(width: 60, height: 30),
                ),
              ),
            ),
          ),
        ),
      );
      // It still takes no space.
      expect(tester.getSize(find.byType(FocusRing)), const Size(60, 30));
      final theme = themeOf(tester, find.byType(FocusRing));
      final ringWidth = theme.style.ringWidth;
      expect(ringWidth, 3);
      const white = Color(0xffffffff);
      final ring = Color.alphaBlend(
        theme.colorScheme.ring.withValues(alpha: theme.style.ringOpacity),
        white,
      );

      late final ui.Image image;
      await tester.runAsync(() async {
        image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
      });
      final data = (await tester.runAsync(() => image.toByteData()))!;
      Color pixel(double x, double y) {
        final index = (y.floor() * image.width + x.floor()) * 4;
        return Color.fromARGB(
          data.getUint8(index + 3),
          data.getUint8(index),
          data.getUint8(index + 1),
          data.getUint8(index + 2),
        );
      }

      void expectClose(Color actual, Color expected, String reason) {
        for (final (a, b) in [
          (actual.r, expected.r),
          (actual.g, expected.g),
          (actual.b, expected.b),
        ]) {
          expect((a - b).abs(), lessThan(3 / 255), reason: reason);
        }
      }

      // The child's box is at (20, 20)–(80, 50) in the boundary.
      // Nothing outside it, on any side or at any corner.
      expectClose(pixel(20 - .5, 35), white, 'outside the left edge');
      expectClose(pixel(80 + .5, 35), white, 'outside the right edge');
      expectClose(pixel(50, 20 - .5), white, 'above the top edge');
      expectClose(pixel(50, 50 + .5), white, 'below the bottom edge');
      expectClose(pixel(20 - 1.5, 20 - 1.5), white, 'outside the corner');
      // The band starts at the edge…
      expectClose(pixel(20 + .5, 35), ring, 'flush inside the left edge');
      expectClose(pixel(20 + 1.5, 35), ring, 'left band');
      expectClose(pixel(80 - 1.5, 35), ring, 'right band');
      expectClose(pixel(50, 20 + 1.5), ring, 'top band');
      expectClose(pixel(50, 50 - 1.5), ring, 'bottom band');
      expectClose(pixel(80 - .5, 50 - .5), ring, 'the corner itself');
      // …and ends a ring width in.
      expectClose(pixel(20 + ringWidth + 1.5, 35), white, 'past the band');
      expectClose(pixel(50, 50 - ringWidth - 1.5), white, 'above the band');
      expectClose(pixel(50, 35), white, 'the middle of the child');
    });

    testWidgets('an inset ring follows the border radius, inside it', (
      tester,
    ) async {
      final canvas = _RecordingCanvas();
      for (final inset in [false, true]) {
        await pumpFinesse(
          tester,
          Center(
            child: FocusRing(
              visible: true,
              inset: inset,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: const SizedBox(width: 60, height: 30),
            ),
          ),
        );
        final paint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(FocusRing),
            matching: find.byType(CustomPaint),
          ),
        );
        // In front of the child, so the child's own fill cannot hide it.
        expect(paint.painter, isNull);
        canvas.rings.clear();
        paint.foregroundPainter!.paint(canvas, const Size(60, 30));
        final (outer, inner) = canvas.rings.single;
        const bounds = Rect.fromLTWH(0, 0, 60, 30);
        if (inset) {
          expect(outer.outerRect, bounds);
          expect(outer.tlRadiusX, 10);
          expect(inner.outerRect, bounds.deflate(3));
          expect(inner.tlRadiusX, 7);
        } else {
          expect(outer.outerRect, bounds.inflate(3));
          expect(outer.tlRadiusX, 13);
          expect(inner.outerRect, bounds);
          expect(inner.tlRadiusX, 10);
        }
      }
    });

    testWidgets('switching inset repaints', (tester) async {
      CustomPainter painterOf() => tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(FocusRing),
              matching: find.byType(CustomPaint),
            ),
          )
          .foregroundPainter!;
      Widget ring({required bool inset}) => Center(
        child: FocusRing(
          visible: true,
          inset: inset,
          child: const SizedBox(width: 60, height: 30),
        ),
      );

      await pumpFinesse(tester, ring(inset: false));
      final outside = painterOf();
      await pumpFinesse(tester, ring(inset: false));
      expect(painterOf().shouldRepaint(outside), isFalse);
      await pumpFinesse(tester, ring(inset: true));
      expect(painterOf().shouldRepaint(outside), isTrue);
    });
  });

  group('AnimatedFill', () {
    testWidgets("an outline that comes and goes keeps the child's state, "
        'and takes its width in layout only while it shows', (tester) async {
      // The padding that makes room for the outline used to be in the tree
      // only while there was one, so the child changed parent — and was
      // re-created — when the outline appeared and again when it had faded
      // out.
      var created = 0;
      // Pumped by hand, not through the harness: it settles, and this looks
      // at the middle of the fade.
      final theme = ThemeData();
      Widget fill(Color? border) => Theme(
        data: theme,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AnimatedFill(
              color: const Color(0xFFFFFFFF),
              borderColor: border,
              borderWidth: 2,
              child: _Counted(onCreate: () => created++),
            ),
          ),
        ),
      );
      Size size() => tester.getSize(find.byType(AnimatedFill));
      await tester.pumpWidget(fill(null));
      expect(created, 1);
      expect(size(), const Size(60, 30));

      await tester.pumpWidget(fill(const Color(0xFF000000)));
      expect(size(), const Size(64, 34));
      await tester.pump(const Duration(milliseconds: 300));
      expect(created, 1, reason: 'the outline appeared');

      await tester.pumpWidget(fill(null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      // Fading out, it still holds its place.
      expect(size(), const Size(64, 34));
      await tester.pump(const Duration(milliseconds: 300));
      expect(created, 1, reason: 'the outline faded out');
      expect(tester.getSize(find.byType(AnimatedFill)), const Size(60, 30));
    });

    const red = Color(0xFFFF0000);
    const blue = Color(0xFF0000FF);

    // What the box paints, read off the tree.
    Color? painted(WidgetTester tester, [Finder? within]) {
      final fill = within == null
          ? find.byType(AnimatedFill)
          : find.descendant(of: within, matching: find.byType(AnimatedFill));
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: fill, matching: find.byType(DecoratedBox)).first,
      );
      return (box.decoration as BoxDecoration).color;
    }

    // Pumped by hand, not through the harness: it settles, and these look
    // at the frames of the fade.
    Widget themed(
      Motion motion,
      Color color, {
      bool reduceMotion = false,
      Duration? duration,
      Curve? curve,
    }) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Theme(
        data: ThemeData(motion: motion),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AnimatedFill(
              color: color,
              duration: duration,
              curve: curve,
              child: const SizedBox(width: 60, height: 30),
            ),
          ),
        ),
      ),
    );

    testWidgets("with no duration it fades on the theme's fast duration "
        'and standard curve', (tester) async {
      // Neither is the 120 ms and the straight line it once had built in.
      const motion = Motion(
        fast: Duration(milliseconds: 400),
        standard: Curves.easeIn,
      );
      await tester.pumpWidget(themed(motion, red));
      expect(painted(tester), red);

      await tester.pumpWidget(themed(motion, blue));
      await tester.pump(const Duration(milliseconds: 200));
      final half = painted(tester)!;
      expect(
        half.b,
        closeTo(Curves.easeIn.transform(.5), .01),
        reason: 'half way through 400 ms, on the ease-in curve',
      );
      await tester.pump(const Duration(milliseconds: 199));
      expect(painted(tester)!.toARGB32(), isNot(blue.toARGB32()));
      await tester.pump(const Duration(milliseconds: 1));
      expect(painted(tester)!.toARGB32(), blue.toARGB32());
    });

    testWidgets('under Motion.none the colours change at once', (
      tester,
    ) async {
      await tester.pumpWidget(themed(Motion.none, red));
      await tester.pumpWidget(themed(Motion.none, blue));
      expect(
        painted(tester)!.toARGB32(),
        blue.toARGB32(),
        reason: 'the frame that brings the new colour paints it',
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('under reduced motion it is the short plain fade that is '
        'left: the fast duration on the standard curve', (tester) async {
      // A fill moves nothing, so reduced motion keeps it (`Motion.reduce`).
      // What it must not do is fade on when the theme has no motion at all.
      const motion = Motion(
        fast: Duration(milliseconds: 400),
        standard: Curves.linear,
      );
      await tester.pumpWidget(themed(motion, red, reduceMotion: true));
      await tester.pumpWidget(themed(motion, blue, reduceMotion: true));
      await tester.pump(const Duration(milliseconds: 200));
      expect(painted(tester)!.b, closeTo(.5, .01));
      await tester.pump(const Duration(milliseconds: 200));
      expect(painted(tester)!.toARGB32(), blue.toARGB32());

      await tester.pumpWidget(themed(Motion.none, red, reduceMotion: true));
      await tester.pumpWidget(themed(Motion.none, blue, reduceMotion: true));
      expect(painted(tester)!.toARGB32(), blue.toARGB32());
    });

    testWidgets('a duration and a curve of its own win over the theme', (
      tester,
    ) async {
      Widget fill(Color color) => themed(
        Motion.none,
        color,
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      await tester.pumpWidget(fill(red));
      await tester.pumpWidget(fill(blue));
      await tester.pump(const Duration(milliseconds: 100));
      expect(painted(tester)!.b, closeTo(.5, .01));
      await tester.pump(const Duration(milliseconds: 100));
      expect(painted(tester)!.toARGB32(), blue.toARGB32());

      // And a zero duration switches the fade off under a theme that has
      // one.
      Widget instant(Color color) =>
          themed(Motion.lively, color, duration: Duration.zero);
      await tester.pumpWidget(instant(red));
      await tester.pumpWidget(instant(blue));
      expect(painted(tester)!.toARGB32(), blue.toARGB32());
    });

    testWidgets('given both, it needs no theme above it', (tester) async {
      await tester.pumpWidget(
        const Center(
          child: AnimatedFill(
            color: red,
            duration: Duration(milliseconds: 100),
            curve: Curves.linear,
            child: SizedBox(width: 60, height: 30),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(painted(tester), red);
    });

    for (final (name, reduceMotion) in [
      ('Motion.none', false),
      ('Motion.none and reduced motion', true),
    ]) {
      testWidgets('a list tile and a chip take their hover fill at once '
          'under $name', (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduceMotion);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await pumpFinesse(
          tester,
          Center(
            child: SizedBox(
              width: 300,
              child: FinesseColumn(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(title: const Text('Row'), onTap: () {}),
                  Chip(label: const Text('Chip'), onSelected: (_) {}),
                ],
              ),
            ),
          ),
          theme: ThemeData(motion: Motion.none),
        );
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: const Offset(1, 1));
        addTearDown(gesture.removePointer);
        await tester.pump();

        for (final control in [find.byType(ListTile), find.byType(Chip)]) {
          final resting = painted(tester, control);
          await gesture.moveTo(tester.getCenter(control));
          // One frame: the hover is seen and the fill is there, whole.
          await tester.pump();
          final hovered = painted(tester, control);
          expect(hovered, isNot(resting), reason: '$control is hovered');
          await tester.pump(const Duration(milliseconds: 300));
          expect(
            hovered,
            painted(tester, control),
            reason: '$control faded for a while after the hover',
          );
        }
      });
    }
  });
}

Widget _empty(BuildContext context, Set<WidgetState> states) =>
    const SizedBox.shrink();

/// Records the rounded rectangles a ring painter draws between.
class _RecordingCanvas implements Canvas {
  final List<(RRect, RRect)> rings = [];

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) =>
      rings.add((outer, inner));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

class _Counted extends StatefulWidget {
  const _Counted({required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 60, height: 30);
}
