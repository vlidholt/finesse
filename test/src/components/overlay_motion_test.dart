import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/entrance.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';

/// Frame-by-frame checks of how the overlays arrive and leave: a popover,
/// a menu, a tooltip and a dialog grow out of the edge that faces what
/// opened them, move in one direction only, leave faster than they came,
/// turn around mid-flight without a jump, and with reduced motion only fade.
const _frame = Duration(milliseconds: 16);

// Springs without bounce, so "monotone" is exact. Solid surfaces (nova),
// so the fade is one opacity layer around the content; the glass route is
// locked by `backdrop_fade_test.dart`.
final _motion = Motion.lively.copyWith(snappy: const MotionSpring());

Widget _app(
  Widget home, {
  bool reduceMotion = false,
  Motion? motion,
  StyleTokens style = StyleTokens.nova,
}) {
  return FinesseApp(
    theme: ThemeData(style: style, motion: motion ?? _motion),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
        ),
        child: home,
      ),
    ),
  );
}

/// What the entrance around [content] looks like right now.
({double opacity, double scale, Offset offset, Alignment origin}) _entrance(
  WidgetTester tester,
  Finder content,
) {
  var opacity = 1.0;
  RenderObject? node = tester.renderObject(content);
  while (node != null) {
    if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
    if (node is RenderOpacity) opacity *= node.opacity;
    node = node.parent;
  }
  // The nearest entrance: a submenu is built under its parent menu's, and
  // a button inside has a press transform of its own.
  final transition = find
      .ancestor(
        of: content,
        matching: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_EntranceTransition',
        ),
      )
      .first;
  final transform = tester.widget<Transform>(
    find.descendant(of: transition, matching: find.byType(Transform)).first,
  );
  final translation = transform.transform.getTranslation();
  return (
    opacity: opacity,
    scale: transform.transform.storage[0],
    offset: Offset(translation.x, translation.y),
    origin: transform.alignment! as Alignment,
  );
}

void _expectMonotone(List<double> values, {required String reason}) {
  final rising = values.last >= values.first;
  for (var i = 1; i < values.length; i++) {
    final step = values[i] - values[i - 1];
    expect(
      rising ? step >= -1e-9 : step <= 1e-9,
      isTrue,
      reason: '$reason turned back at frame $i: $values',
    );
  }
}

/// No frame moves more than [limit] of the whole range: nothing jumps.
void _expectNoJump(
  List<double> values, {
  required String reason,
  double limit = .34,
}) {
  for (var i = 1; i < values.length; i++) {
    expect(
      (values[i] - values[i - 1]).abs(),
      lessThanOrEqualTo(limit),
      reason: '$reason jumps at frame $i: $values',
    );
  }
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: const Offset(1, 1));
  addTearDown(gesture.removePointer);
  return gesture;
}

/// The fill of the row around [label]: that of the nearest decorated box.
Color? _rowFill(WidgetTester tester, Finder label) => boxDecorationOf(
  tester
      .widget<DecoratedBox>(
        find.ancestor(of: label, matching: find.byType(DecoratedBox)).first,
      )
      .decoration,
)?.color;

RenderMovingIndicator _indicator(WidgetTester tester, Finder within) =>
    tester.renderObject<RenderMovingIndicator>(
      find
          .descendant(
            of: within,
            matching: find.byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_MovingIndicatorRenderWidget',
            ),
          )
          // The outermost: an open menu inside has one of its own.
          .first,
    );

void main() {
  const content = Key('content');

  Widget popoverAt(
    Alignment alignment,
    PopoverController controller,
  ) => Align(
    alignment: alignment,
    child: Popover(
      controller: controller,
      builder: (context) =>
          const SizedBox(key: content, width: 200, height: 120),
      child: const SizedBox(width: 60, height: 30),
    ),
  );

  /// Opens [controller]'s popover and pumps to the first frame it is on
  /// screen, which is the first frame of its entrance.
  Future<void> open(WidgetTester tester, PopoverController controller) async {
    controller.open();
    // Build the portal, lay the overlay out unseen, then show it in place.
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  group('Popover', () {
    testWidgets('grows out of the edge facing its trigger, in one movement, '
        'and none of the entrance is spent before it is on screen', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(popoverAt(const Alignment(0, -.5), controller)),
      );
      await open(tester, controller);

      // The first frame it can be seen on is the start of the entrance.
      final first = _entrance(tester, find.byKey(content));
      expect(first.opacity, 0);
      expect(first.scale, closeTo(_motion.overlayScale, 1e-6));
      // Below its trigger: it grows from its top edge, and starts pulled
      // up towards it.
      expect(first.origin, Alignment.topCenter);
      expect(first.offset.dy, closeTo(-_motion.overlayTravel, 1e-6));
      expect(first.offset.dx, 0);

      final opacity = <double>[first.opacity];
      final scale = <double>[first.scale];
      final travel = <double>[first.offset.dy];
      for (var i = 0; i < 30; i++) {
        await tester.pump(_frame);
        final now = _entrance(tester, find.byKey(content));
        opacity.add(now.opacity);
        scale.add(now.scale);
        travel.add(now.offset.dy);
      }
      _expectMonotone(opacity, reason: 'opacity');
      _expectMonotone(scale, reason: 'scale');
      _expectMonotone(travel, reason: 'travel');
      _expectNoJump(opacity, reason: 'opacity');
      expect(opacity.last, 1);
      expect(scale.last, 1);
      expect(travel.last, 0);
      // Readable well before it has settled: fully opaque within 120 ms.
      expect(opacity[8], 1);
    });

    testWidgets('above its trigger it grows from its bottom edge', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      // No room below: the portal falls back to above.
      await tester.pumpWidget(
        _app(popoverAt(const Alignment(0, .95), controller)),
      );
      await open(tester, controller);
      await tester.pump(_frame);
      final entrance = _entrance(tester, find.byKey(content));
      expect(entrance.origin, Alignment.bottomCenter);
      expect(entrance.offset.dy, greaterThan(0));
      expect(
        tester.getRect(find.byKey(content)).bottom,
        lessThan(tester.getRect(find.byType(Popover)).top + 1),
      );
    });

    testWidgets('pushed sideways by the screen edge, it still grows from '
        'its trigger', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(popoverAt(const Alignment(-1, -.5), controller)),
      );
      await open(tester, controller);
      await tester.pump(_frame);
      final entrance = _entrance(tester, find.byKey(content));
      // The trigger is at the left edge, so the popover hangs to its right
      // and its origin is left of its own centre.
      expect(entrance.origin.y, -1);
      expect(entrance.origin.x, lessThan(-.3));
    });

    testWidgets('leaves at once, in one movement, faster than it came', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(popoverAt(const Alignment(0, -.5), controller)),
      );
      await open(tester, controller);
      await tester.pump(const Duration(milliseconds: 600));

      controller.close();
      await tester.pump();
      final opacity = <double>[];
      final scale = <double>[];
      var frames = 0;
      while (find.byKey(content).evaluate().isNotEmpty && frames < 40) {
        final now = _entrance(tester, find.byKey(content));
        opacity.add(now.opacity);
        scale.add(now.scale);
        await tester.pump(_frame);
        frames++;
      }
      _expectMonotone(opacity, reason: 'opacity');
      _expectMonotone(scale, reason: 'scale');
      // It has visibly started to go by the second frame: the entrance
      // played backwards would hold still here.
      expect(opacity[2], lessThan(1));
      expect(scale[2], lessThan(1));
      // Gone within the fast duration, give or take the frame it takes the
      // portal to let go.
      expect(frames * 16, lessThanOrEqualTo(_motion.fast.inMilliseconds + 48));
      expect(
        _motion.fast,
        lessThan(_motion.snappy.settleDuration),
        reason: 'the exit is the shorter of the two',
      );
    });

    testWidgets('closed mid-entrance and reopened mid-exit, it turns around '
        'where it is', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(popoverAt(const Alignment(0, -.5), controller)),
      );
      await open(tester, controller);
      final scale = <double>[];
      final opacity = <double>[];
      void sample() {
        final now = _entrance(tester, find.byKey(content));
        scale.add(now.scale);
        opacity.add(now.opacity);
      }

      for (var i = 0; i < 10; i++) {
        await tester.pump(_frame);
        sample();
      }
      final turnedAt = scale.length;
      controller.close();
      for (var i = 0; i < 2; i++) {
        await tester.pump(_frame);
        sample();
      }
      final reopenedAt = scale.length;
      controller.open();
      for (var i = 0; i < 30; i++) {
        await tester.pump(_frame);
        sample();
      }
      // In, out, in again — each leg monotone, and no frame anywhere moves
      // more than a fraction of the range.
      _expectMonotone(scale.sublist(0, turnedAt), reason: 'in');
      _expectMonotone(scale.sublist(turnedAt - 1, reopenedAt), reason: 'out');
      _expectMonotone(scale.sublist(reopenedAt - 1), reason: 'in again');
      // (A controller started between two frames moves on the second.)
      expect(scale[turnedAt + 1], lessThan(scale[turnedAt - 1]));
      expect(scale[reopenedAt + 1], greaterThan(scale[reopenedAt - 1]));
      final range = 1 - _motion.overlayScale;
      _expectNoJump(scale, reason: 'scale', limit: range * .34);
      _expectNoJump(opacity, reason: 'opacity');
      expect(scale.last, 1);
      expect(opacity.last, 1);
    });

    testWidgets('is interactive long before it has settled', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: const Alignment(0, -.5),
            child: Popover(
              controller: controller,
              builder: (context) => Button(
                onPressed: () => taps++,
                child: const Text('Inside'),
              ),
              child: const SizedBox(width: 60, height: 30),
            ),
          ),
        ),
      );
      controller.open();
      // 100 ms after it was asked for, counting the frames the portal
      // needs.
      for (var i = 0; i < 6; i++) {
        await tester.pump(_frame);
      }
      await tester.tap(find.text('Inside'));
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('with reduced motion it only fades', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          popoverAt(const Alignment(0, -.5), controller),
          reduceMotion: true,
        ),
      );
      await open(tester, controller);
      final opacity = <double>[];
      for (var i = 0; i < 12; i++) {
        final now = _entrance(tester, find.byKey(content));
        expect(now.scale, 1);
        expect(now.offset, Offset.zero);
        opacity.add(now.opacity);
        await tester.pump(_frame);
      }
      expect(opacity.first, 0);
      expect(opacity.last, 1);
      _expectMonotone(opacity, reason: 'opacity');
      expect(opacity.where((o) => o > 0 && o < 1), isNotEmpty);
    });

    testWidgets('with no motion it is there at once, and gone at once', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(
          popoverAt(const Alignment(0, -.5), controller),
          motion: Motion.none,
        ),
      );
      await open(tester, controller);
      expect(
        find.ancestor(
          of: find.byKey(content),
          matching: find.byType(OverlayEntrance),
        ),
        findsNothing,
      );
      expect(find.byKey(content), findsOneWidget);
      controller.close();
      await tester.pump();
      await tester.pump();
      expect(find.byKey(content), findsNothing);
    });
  });

  group('ContextMenu', () {
    Widget region(Alignment alignment) => Align(
      alignment: alignment,
      child: ContextMenuRegion(
        items: [
          MenuItem(onPressed: () {}, child: const Text('Back')),
          MenuItem(onPressed: () {}, child: const Text('Forward')),
          MenuItem(onPressed: () {}, child: const Text('Reload')),
          MenuItem(
            items: [
              MenuItem(onPressed: () {}, child: const Text('Save')),
            ],
            child: const Text('More'),
          ),
        ],
        child: const SizedBox(key: Key('area'), width: 120, height: 80),
      ),
    );

    Future<void> rightClick(WidgetTester tester, Offset at) async {
      final gesture = await tester.startGesture(
        at,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.up();
      await gesture.removePointer();
      await tester.pump();
      await tester.pump();
      await tester.pump();
    }

    testWidgets('grows from the pointer', (tester) async {
      await tester.pumpWidget(_app(region(const Alignment(-.5, -.5))));
      final at = tester.getCenter(find.byKey(const Key('area')));
      await rightClick(tester, at);
      await tester.pump(_frame);
      final entrance = _entrance(tester, find.text('Back'));
      expect(entrance.origin, Alignment.topLeft);
      expect(entrance.scale, lessThan(1));
      await tester.pump(const Duration(milliseconds: 600));
      // Its corner is on the pointer.
      final menu = tester.getRect(
        find.ancestor(
          of: find.text('Back'),
          matching: find.byType(OverlayEntrance),
        ),
      );
      expect(menu.topLeft.dx, closeTo(at.dx, 1));
      expect(menu.topLeft.dy, closeTo(at.dy, 1));
    });

    testWidgets('mirrored at the corner of the screen, it grows from the '
        'pointer still', (tester) async {
      await tester.pumpWidget(_app(region(Alignment.bottomRight)));
      await rightClick(
        tester,
        tester.getCenter(find.byKey(const Key('area'))),
      );
      // The mirrored origin is known once the menu has been laid out.
      await tester.pump(_frame);
      await tester.pump(_frame);
      final entrance = _entrance(tester, find.text('Back'));
      expect(entrance.origin, Alignment.bottomRight);
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('a submenu slides out of its parent row', (tester) async {
      await tester.pumpWidget(_app(region(const Alignment(-.5, -.5))));
      await rightClick(
        tester,
        tester.getCenter(find.byKey(const Key('area'))),
      );
      await tester.pump(const Duration(milliseconds: 600));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('More')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(_frame);
      final entrance = _entrance(tester, find.text('Save'));
      // To the right of its row: it grows from its left edge, and starts
      // pulled left, towards the row.
      expect(entrance.origin.x, -1);
      expect(entrance.offset.dx, lessThan(0));
      await tester.pump(const Duration(milliseconds: 600));
    });

    for (final style in [StyleTokens.nova, StyleTokens.finesse]) {
      testWidgets("${style.name}: a row's highlight is its own fill — there at "
          'once, gone at once, and nothing travels between the rows', (
        tester,
      ) async {
        await tester.pumpWidget(
          _app(region(const Alignment(-.5, -.5)), style: style),
        );
        await rightClick(
          tester,
          tester.getCenter(find.byKey(const Key('area'))),
        );
        await tester.pump(const Duration(milliseconds: 600));
        final menu = find.ancestor(
          of: find.text('Back'),
          matching: find.byType(OverlayEntrance),
        );
        // No shared highlight to glide: each row paints its own.
        expect(
          find.descendant(of: menu, matching: find.byType(MovingIndicator)),
          findsNothing,
        );
        final highlight = Theme.of(
          tester.element(find.text('Back')),
        ).contextMenuTheme.selectedBackgroundColor!;
        List<String> lit() => [
          for (final label in ['Back', 'Forward', 'Reload', 'More'])
            if (_rowFill(tester, find.text(label)) == highlight) label,
        ];
        expect(lit(), isEmpty);

        // On the frame after the pointer arrives, at full strength…
        final mouse = await _mouse(tester);
        await mouse.moveTo(tester.getCenter(find.text('Back')));
        await tester.pump();
        expect(lit(), ['Back']);

        // …and on the frame after it moves two rows down it is there and
        // only there: nothing passes over the row between, and nothing is
        // left fading on the row it came from.
        await mouse.moveTo(tester.getCenter(find.text('Reload')));
        await tester.pump();
        for (var i = 0; i < 12; i++) {
          expect(lit(), ['Reload'], reason: 'frame $i');
          await tester.pump(_frame);
        }

        // Gone at once when the pointer leaves.
        await mouse.moveTo(const Offset(1, 1));
        await tester.pump();
        expect(lit(), isEmpty);

        // The arrow keys move it the same way: a row at a time, at once.
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        final first = lit();
        expect(first, hasLength(1));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pump();
        final second = lit();
        expect(second, hasLength(1));
        expect(second, isNot(first));
        for (var i = 0; i < 12; i++) {
          await tester.pump(_frame);
          expect(lit(), second, reason: 'frame $i');
        }
      });
    }

    testWidgets('with a bold accent a row is filled and its text recoloured '
        'on the same frame, so it is never white on white', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(
            style: StyleTokens.nova,
            motion: _motion,
            menuAccent: MenuAccent.bold,
          ),
          home: region(const Alignment(-.5, -.5)),
        ),
      );
      await rightClick(
        tester,
        tester.getCenter(find.byKey(const Key('area'))),
      );
      await tester.pump(const Duration(milliseconds: 600));
      final theme = Theme.of(tester.element(find.text('Back')));
      Color textColor(String label) =>
          DefaultTextStyle.of(tester.element(find.text(label))).style.color!;
      expect(textColor('Reload'), theme.colorScheme.popoverForeground);

      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Reload')));
      await tester.pump();
      expect(_rowFill(tester, find.text('Reload')), theme.colorScheme.primary);
      expect(textColor('Reload'), theme.colorScheme.primaryForeground);
      await mouse.moveTo(tester.getCenter(find.text('Back')));
      await tester.pump();
      expect(
        _rowFill(tester, find.text('Reload')),
        isNot(theme.colorScheme.primary),
      );
      expect(textColor('Reload'), theme.colorScheme.popoverForeground);
    });
  });

  group('Menubar', () {
    Widget menubar() => const Align(
      alignment: Alignment.topLeft,
      child: Menubar(
        items: [
          MenubarItem(
            items: [MenuItem(child: Text('New file'))],
            child: Text('File'),
          ),
          MenubarItem(
            items: [MenuItem(child: Text('Undo'))],
            child: Text('Edit'),
          ),
        ],
      ),
    );

    testWidgets('the first menu grows in; the one switched to only fades, '
        'and the trigger fill slides across', (tester) async {
      await tester.pumpWidget(_app(menubar()));
      await tester.tap(find.text('File'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(_frame);
      expect(_entrance(tester, find.text('New file')).scale, lessThan(1));
      await tester.pump(const Duration(milliseconds: 600));

      final strip = _indicator(tester, find.byType(Menubar));
      final onFile = strip.indicatorRect!;

      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final lefts = <double>[];
      final opacity = <double>[];
      for (var i = 0; i < 30; i++) {
        lefts.add(strip.indicatorRect!.left);
        if (find.text('Undo').evaluate().isNotEmpty) {
          final entrance = _entrance(tester, find.text('Undo'));
          // No second pop beside the first.
          expect(entrance.scale, 1);
          expect(entrance.offset, Offset.zero);
          opacity.add(entrance.opacity);
        }
        await tester.pump(_frame);
      }
      _expectMonotone(opacity, reason: 'the second menu');
      expect(opacity.last, 1);
      expect(opacity.where((o) => o > 0 && o < 1), isNotEmpty);
      // One fill, sliding from File to Edit.
      _expectMonotone(lefts, reason: 'the trigger fill');
      expect(lefts.last, greaterThan(onFile.left + 10));
      expect(find.text('New file'), findsNothing);
    });
  });

  group('Tooltip', () {
    Widget pair({Duration? wait}) => Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            waitDuration: wait,
            builder: (context) => const Text('First tip'),
            // Something to hit: an empty box takes no pointer.
            child: const ColoredBox(
              key: Key('a'),
              color: Color(0xff808080),
              child: SizedBox(width: 60, height: 30),
            ),
          ),
          Tooltip(
            waitDuration: wait,
            builder: (context) => const Text('Second tip'),
            // Something to hit: an empty box takes no pointer.
            child: const ColoredBox(
              key: Key('b'),
              color: Color(0xff808080),
              child: SizedBox(width: 60, height: 30),
            ),
          ),
        ],
      ),
    );

    testWidgets('pops out of the side facing its trigger, and fades out', (
      tester,
    ) async {
      await tester.pumpWidget(_app(pair()));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('a'))));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final scale = <double>[];
      final opacity = <double>[];
      for (var i = 0; i < 24; i++) {
        final now = _entrance(tester, find.text('First tip'));
        // Above the trigger: it grows from its bottom edge.
        expect(now.origin, Alignment.bottomCenter);
        scale.add(now.scale);
        opacity.add(now.opacity);
        await tester.pump(_frame);
      }
      expect(scale.first, lessThan(1));
      expect(opacity.first, lessThan(.2));
      _expectMonotone(scale, reason: 'scale');
      _expectMonotone(opacity, reason: 'opacity');
      expect(scale.last, 1);
      expect(opacity.last, 1);

      await mouse.moveTo(const Offset(1, 1));
      await tester.pump();
      final leaving = <double>[];
      var frames = 0;
      while (find.text('First tip').evaluate().isNotEmpty && frames < 30) {
        leaving.add(_entrance(tester, find.text('First tip')).opacity);
        await tester.pump(_frame);
        frames++;
      }
      _expectMonotone(leaving, reason: 'leaving');
      expect(leaving.where((o) => o > 0 && o < 1), isNotEmpty);
      expect(frames * 16, lessThanOrEqualTo(_motion.fast.inMilliseconds + 48));
    });

    testWidgets('the tooltip of the next trigger follows without the wait '
        'and without a second pop', (tester) async {
      const wait = Duration(milliseconds: 400);
      await tester.pumpWidget(_app(pair(wait: wait)));
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('a'))));
      await tester.pump(const Duration(milliseconds: 200));
      // Still waiting.
      expect(find.text('First tip'), findsNothing);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('First tip'), findsOneWidget);

      await mouse.moveTo(tester.getCenter(find.byKey(const Key('b'))));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(_frame);
      // Well inside the wait, and it is already on its way in…
      expect(find.text('Second tip'), findsOneWidget);
      final opacity = <double>[];
      for (var i = 0; i < 16; i++) {
        final now = _entrance(tester, find.text('Second tip'));
        // …as a plain fade.
        expect(now.scale, 1);
        expect(now.offset, Offset.zero);
        opacity.add(now.opacity);
        await tester.pump(_frame);
      }
      _expectMonotone(opacity, reason: 'the second tooltip');
      expect(opacity.last, 1);
      expect(find.text('First tip'), findsNothing);

      // Left alone for a while, the next one waits and pops again.
      await mouse.moveTo(const Offset(1, 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      expect(find.text('Second tip'), findsNothing);
      await mouse.moveTo(tester.getCenter(find.byKey(const Key('a'))));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('First tip'), findsNothing);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      await tester.pump();
      await tester.pump(_frame);
      expect(_entrance(tester, find.text('First tip')).scale, lessThan(1));
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('a pointer that comes back while it is leaving keeps it', (
      tester,
    ) async {
      await tester.pumpWidget(_app(pair()));
      final mouse = await _mouse(tester);
      final trigger = tester.getCenter(find.byKey(const Key('a')));
      await mouse.moveTo(trigger);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(_entrance(tester, find.text('First tip')).opacity, 1);

      await mouse.moveTo(const Offset(1, 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 48));
      final leaving = _entrance(tester, find.text('First tip')).opacity;
      expect(leaving, inExclusiveRange(0, 1));

      await mouse.moveTo(trigger);
      await tester.pump();
      await tester.pump(_frame);
      // It carries on from where it was, back up.
      final back = _entrance(tester, find.text('First tip')).opacity;
      expect(back, greaterThanOrEqualTo(leaving));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('First tip'), findsOneWidget);
      expect(_entrance(tester, find.text('First tip')).opacity, 1);
    });
  });

  group('Dialog', () {
    Widget opener() => Center(
      child: Builder(
        builder: (context) => Button(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => Dialog(
              title: const Text('Title'),
              actions: [
                Button(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );

    testWidgets('scales up from the middle while it fades in, and leaves '
        'faster', (tester) async {
      await tester.pumpWidget(_app(opener()));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();
      final scale = <double>[];
      final opacity = <double>[];
      var arriving = 0;
      for (var i = 0; i < 40; i++) {
        // Its entrance, not the stretch a scrollable has on Android.
        final transforms = find.ancestor(
          of: find.text('Title'),
          matching: find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_EntranceTransition',
          ),
        );
        if (transforms.evaluate().isEmpty) break;
        final now = _entrance(tester, find.text('Title'));
        expect(now.origin, Alignment.center);
        // From the centre there is nowhere to travel from.
        expect(now.offset, Offset.zero);
        scale.add(now.scale);
        opacity.add(now.opacity);
        arriving++;
        await tester.pump(_frame);
      }
      expect(scale.first, lessThan(1));
      _expectMonotone(scale, reason: 'scale');
      _expectMonotone(opacity, reason: 'opacity');
      _expectNoJump(opacity, reason: 'opacity');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Close'));
      await tester.pump();
      final leaving = <double>[];
      var frames = 0;
      while (find.text('Title').evaluate().isNotEmpty && frames < 40) {
        var o = 1.0;
        RenderObject? node = tester.renderObject(find.text('Title'));
        while (node != null) {
          if (node is RenderAnimatedOpacity) o *= node.opacity.value;
          node = node.parent;
        }
        leaving.add(o);
        await tester.pump(_frame);
        frames++;
      }
      _expectMonotone(leaving, reason: 'leaving');
      expect(leaving.last, lessThan(.2));
      expect(frames, lessThan(arriving));
    });

    testWidgets('with reduced motion it only fades', (tester) async {
      await tester.pumpWidget(_app(opener(), reduceMotion: true));
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();
      await tester.pump(_frame);
      final now = _entrance(tester, find.text('Title'));
      expect(now.scale, 1);
      expect(now.opacity, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 400));
    });
  });

  group('Select and Command', () {
    testWidgets("a select's list grows from its trigger, and its highlight "
        'is on the option under the pointer at once', (tester) async {
      await tester.pumpWidget(
        _app(
          Align(
            alignment: const Alignment(0, -.6),
            child: Select<String>(
              onChanged: (_) {},
              placeholder: const Text('Fruit'),
              options: const [
                SelectOption(value: 'apple', child: Text('Apple')),
                SelectOption(value: 'banana', child: Text('Banana')),
                SelectOption(value: 'cherry', child: Text('Cherry')),
              ],
              selectedOptionBuilder: (context, value) => Text(value),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Fruit'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(_frame);
      final entrance = _entrance(tester, find.text('Apple'));
      expect(entrance.origin.y, -1);
      expect(entrance.scale, lessThan(1));
      await tester.pump(const Duration(milliseconds: 600));

      // The highlight is each option's own fill: nothing travels.
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('Apple'),
            matching: find.byType(OverlayEntrance),
          ),
          matching: find.byType(MovingIndicator),
        ),
        findsNothing,
      );
      final highlight = Theme.of(
        tester.element(find.text('Apple')),
      ).selectOptionTheme.hoveredBackgroundColor!;
      List<String> lit() => [
        for (final label in ['Apple', 'Banana', 'Cherry'])
          if (_rowFill(tester, find.text(label)) == highlight) label,
      ];
      final mouse = await _mouse(tester);
      await mouse.moveTo(tester.getCenter(find.text('Apple')));
      await tester.pump();
      expect(lit(), ['Apple']);
      await mouse.moveTo(tester.getCenter(find.text('Cherry')));
      await tester.pump();
      for (var i = 0; i < 12; i++) {
        expect(lit(), ['Cherry'], reason: 'frame $i');
        await tester.pump(_frame);
      }
    });

    testWidgets("a command palette's highlight moves with the arrow keys, "
        'an item at a time and at once', (tester) async {
      await tester.pumpWidget(
        _app(
          const Center(
            child: Command(
              width: 300,
              groups: [
                CommandGroup(
                  items: [
                    CommandItem(value: 'a', label: 'Calendar'),
                    CommandItem(value: 'b', label: 'Calculator'),
                    CommandItem(value: 'c', label: 'Settings'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.descendant(
          of: find.byType(Command),
          matching: find.byType(MovingIndicator),
        ),
        findsNothing,
      );
      final highlight = Theme.of(
        tester.element(find.byType(Command)),
      ).commandTheme.itemSelectedBackgroundColor!;
      List<String> lit() => [
        for (final label in ['Calendar', 'Calculator', 'Settings'])
          if (_rowFill(tester, find.text(label)) == highlight) label,
      ];
      expect(lit(), ['Calendar']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      for (var i = 0; i < 12; i++) {
        expect(lit(), ['Calculator'], reason: 'frame $i');
        await tester.pump(_frame);
      }
    });
  });
}
