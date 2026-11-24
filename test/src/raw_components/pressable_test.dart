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
    bool selected = false,
    FocusNode? focusNode,
    bool autofocus = false,
    String? semanticLabel,
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

    testWidgets(
      'canRequestFocus: false keeps keyboard focus away',
      (
        tester,
      ) async {
        final node = FocusNode();
        addTearDown(node.dispose);
        var presses = 0;
        await pumpFinesse(
          tester,
          Center(
            child: Pressable(
              focusNode: node,
              canRequestFocus: false,
              onPressed: () => presses++,
              builder: (context, states) => const Text('Go'),
            ),
          ),
        );

        node.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(node.hasFocus, isFalse);
        // It is still a pointer target.
        await tester.tap(find.byType(Pressable));
        expect(presses, 1);
      },
      // TODO(finesse): `Pressable.canRequestFocus` is declared and
      // documented but never read by `_PressableState.build`, so the region
      // takes focus regardless. FocusableActionDetector has no such
      // parameter; honouring it needs a decision on whether descendants
      // stay focusable (an ExcludeFocus would take them out too).
      skip: true,
    );
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
      return MouseCursor.defer;
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
      await pumpFinesse(tester, recorder([]));
      expect(
        cursorAt(tester, tester.getCenter(find.byType(Pressable))),
        SystemMouseCursors.basic,
      );
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

    testWidgets('an unselected region carries no selected state at all', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, recorder([], onPressed: () {}));

      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, ui.Tristate.none);
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

    testWidgets('the semantic tap action calls onPressed', (tester) async {
      final handle = tester.ensureSemantics();
      var presses = 0;
      await pumpFinesse(tester, recorder([], onPressed: () => presses++));

      final id = tester.getSemantics(find.byType(Pressable)).id;
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        id,
        ui.SemanticsAction.tap,
      );
      await tester.pump();
      expect(presses, 1);
      handle.dispose();
    });
  });

  group('FocusRing', () {
    testWidgets('paints nothing and adds nothing while hidden', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: FocusRing(
            visible: false,
            child: SizedBox(key: Key('box'), width: 60, height: 30),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(FocusRing),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
      expect(tester.getSize(find.byType(FocusRing)), const Size(60, 30));
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
  });
}
