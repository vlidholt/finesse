import 'dart:math' as math;

import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/arrow_surface.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';
import '../../frame_sampler.dart';

/// `Popover(showArrow: true)`: an arrow on the edge that faces the trigger,
/// pointing at the middle of it, part of the surface's own outline.
void main() {
  const trigger = ValueKey('trigger');
  final arrow = find.byKey(SurfacePainter.arrowKey);

  Finder surface() => find.byType(BackdropSurface);

  /// A popover, already open, whose trigger sits at [alignment].
  Future<void> pumpPopover(
    WidgetTester tester, {
    Alignment alignment = Alignment.center,
    AnchorBase? anchor,
    bool? showArrow = true,
    Size content = const Size(160, 60),
    Size triggerSize = const Size(40, 24),
    EdgeInsets inset = EdgeInsets.zero,
    FormFactor formFactor = FormFactor.desktop,
    TextDirection textDirection = TextDirection.ltr,
    ThemeData? theme,
    Size surfaceSize = const Size(600, 500),
    double textScale = 1,
    bool disableAnimations = false,
  }) async {
    await pumpFinesse(
      tester,
      MediaQuery(
        data: MediaQueryData(
          size: surfaceSize,
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: inset,
            child: Popover(
              visible: true,
              showArrow: showArrow,
              anchor: anchor,
              popover: (context) => SizedBox.fromSize(
                size: content,
                child: const Text('Panel'),
              ),
              child: SizedBox.fromSize(key: trigger, size: triggerSize),
            ),
          ),
        ),
      ),
      formFactor: formFactor,
      textDirection: textDirection,
      theme: theme,
      surfaceSize: surfaceSize,
    );
    // Measured, placed, shown; then the entrance, which scales the surface
    // about its origin until it settles.
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  double protrusion(WidgetTester tester) {
    final theme = Theme.of(tester.element(find.byType(Popover)));
    return ArrowShape.protrusionOf(
      theme.popoverTheme.arrowSize!,
      theme.popoverTheme.arrowRadius!,
    );
  }

  group('which edge', () {
    testWidgets('below its trigger, the arrow rides the top edge', (
      tester,
    ) async {
      await pumpPopover(tester);
      final box = tester.getRect(surface());
      final target = tester.getRect(find.byKey(trigger));
      expect(box.top, greaterThan(target.bottom));
      final mark = tester.getCenter(arrow);
      expect(mark.dy, closeTo(box.top + ArrowShape.inset, .01));
      expect(mark.dx, closeTo(target.center.dx, .5));
    });

    testWidgets('the tip stands the gap of the anchor off the trigger', (
      tester,
    ) async {
      await pumpPopover(tester);
      final box = tester.getRect(surface());
      final target = tester.getRect(find.byKey(trigger));
      // The theme's anchor leaves 4; the arrow's height is added to it.
      expect(box.top - target.bottom, closeTo(4 + protrusion(tester), .01));
    });

    testWidgets('falling back above, it flips to the bottom edge', (
      tester,
    ) async {
      await pumpPopover(tester, alignment: Alignment.bottomCenter);
      final box = tester.getRect(surface());
      final target = tester.getRect(find.byKey(trigger));
      expect(box.bottom, lessThan(target.top));
      expect(target.top - box.bottom, closeTo(4 + protrusion(tester), .01));
      final mark = tester.getCenter(arrow);
      expect(mark.dy, closeTo(box.bottom - ArrowShape.inset, .01));
      expect(mark.dx, closeTo(target.center.dx, .5));
    });

    for (final (name, anchor, edge) in [
      (
        'to the right',
        const Anchor(
          childAlignment: Alignment.centerRight,
          overlayAlignment: Alignment.centerLeft,
          offset: Offset(4, 0),
        ),
        AxisDirection.left,
      ),
      (
        'to the left',
        const Anchor(
          childAlignment: Alignment.centerLeft,
          overlayAlignment: Alignment.centerRight,
          offset: Offset(-4, 0),
        ),
        AxisDirection.right,
      ),
      (
        'above',
        const Anchor(
          childAlignment: Alignment.topCenter,
          overlayAlignment: Alignment.bottomCenter,
          offset: Offset(0, -4),
        ),
        AxisDirection.down,
      ),
    ]) {
      testWidgets('anchored $name, the arrow faces the trigger', (
        tester,
      ) async {
        await pumpPopover(tester, anchor: anchor);
        final box = tester.getRect(surface());
        final target = tester.getRect(find.byKey(trigger));
        final mark = tester.getCenter(arrow);
        final gap = 4 + protrusion(tester);
        switch (edge) {
          case AxisDirection.left:
            expect(box.left - target.right, closeTo(gap, .01));
            expect(mark.dx, closeTo(box.left + ArrowShape.inset, .01));
            expect(mark.dy, closeTo(target.center.dy, .5));
          case AxisDirection.right:
            expect(target.left - box.right, closeTo(gap, .01));
            expect(mark.dx, closeTo(box.right - ArrowShape.inset, .01));
            expect(mark.dy, closeTo(target.center.dy, .5));
          case AxisDirection.down:
            expect(target.top - box.bottom, closeTo(gap, .01));
            expect(mark.dy, closeTo(box.bottom - ArrowShape.inset, .01));
            expect(mark.dx, closeTo(target.center.dx, .5));
          case AxisDirection.up:
            fail('not tested here');
        }
      });
    }

    testWidgets('a side anchor given as an AnchorAuto works the same', (
      tester,
    ) async {
      await pumpPopover(
        tester,
        anchor: const AnchorAuto(
          offset: Offset(4, 0),
          followerAnchor: Alignment.centerRight,
          targetAnchor: Alignment.centerRight,
        ),
      );
      final box = tester.getRect(surface());
      final target = tester.getRect(find.byKey(trigger));
      expect(box.left, greaterThan(target.right));
      final mark = tester.getCenter(arrow);
      expect(mark.dx, closeTo(box.left + ArrowShape.inset, .01));
      expect(mark.dy, closeTo(target.center.dy, .5));
    });

    testWidgets('centred over its trigger there is no edge to point from', (
      tester,
    ) async {
      await pumpPopover(
        tester,
        anchor: const Anchor(
          childAlignment: Alignment.center,
          overlayAlignment: Alignment.center,
        ),
      );
      expect(find.text('Panel'), findsOneWidget);
      expect(arrow, findsNothing);
    });

    testWidgets('at a point, it points from the corner that is on it', (
      tester,
    ) async {
      await pumpPopover(
        tester,
        anchor: const GlobalAnchor(Offset(300, 200)),
      );
      final box = tester.getRect(surface());
      expect(box.top, closeTo(200, .01));
      final mark = tester.getCenter(arrow);
      expect(mark.dy, closeTo(box.top + ArrowShape.inset, .01));
      expect(mark.dx, closeTo(300, .5));
    });
  });

  group('where along the edge', () {
    testWidgets('it stays over a trigger the popover was pushed off', (
      tester,
    ) async {
      await pumpPopover(
        tester,
        alignment: Alignment.centerRight,
        inset: const EdgeInsets.only(right: 60),
        content: const Size(260, 60),
      );
      final box = tester.getRect(surface());
      final target = tester.getRect(find.byKey(trigger));
      expect(box.right, lessThanOrEqualTo(600));
      expect(
        box.center.dx,
        lessThan(target.center.dx - 20),
        reason: 'the popover should have been pushed well off the trigger',
      );
      expect(tester.getCenter(arrow).dx, closeTo(target.center.dx, 1));
    });

    testWidgets('it stops short of the corner', (tester) async {
      await pumpPopover(
        tester,
        alignment: Alignment.centerRight,
        content: const Size(400, 60),
      );
      final box = tester.getRect(surface());
      final theme = Theme.of(tester.element(find.byType(Popover)));
      final radius = theme.popoverTheme.decoration!.border!.borderRadius!
          .resolve(TextDirection.ltr)
          .topRight
          .x;
      final keepClear = radius + theme.popoverTheme.arrowSize! * math.sqrt2 / 2;
      final mark = tester.getCenter(arrow).dx;
      expect(mark, lessThanOrEqualTo(box.right - keepClear + .5));
      expect(mark, greaterThan(box.center.dx));
    });

    for (final direction in TextDirection.values) {
      testWidgets(
        'aligned with the start of a wide trigger, it points at its '
        'middle (${direction.name})',
        (tester) async {
          await pumpPopover(
            tester,
            textDirection: direction,
            triggerSize: const Size(120, 24),
            content: const Size(260, 60),
            anchor: const Anchor(
              childAlignment: AlignmentDirectional.bottomStart,
              overlayAlignment: AlignmentDirectional.topStart,
              offset: Offset(0, 4),
            ),
          );
          final box = tester.getRect(surface());
          final target = tester.getRect(find.byKey(trigger));
          if (direction == TextDirection.ltr) {
            expect(box.left, closeTo(target.left, .01));
          } else {
            expect(box.right, closeTo(target.right, .01));
          }
          expect(tester.getCenter(arrow).dx, closeTo(target.center.dx, .5));
        },
      );
    }

    testWidgets('under a trigger wider than itself, it goes as far as it '
        'can', (tester) async {
      await pumpPopover(
        tester,
        triggerSize: const Size(500, 24),
        content: const Size(120, 60),
        anchor: const Anchor(
          childAlignment: Alignment.bottomLeft,
          overlayAlignment: Alignment.topLeft,
          offset: Offset(0, 4),
        ),
      );
      final box = tester.getRect(surface());
      final mark = tester.getCenter(arrow).dx;
      expect(mark, greaterThan(box.center.dx));
      expect(mark, lessThan(box.right));
    });
  });

  group('one shape with the surface', () {
    testWidgets('the popover is the same size with and without its arrow', (
      tester,
    ) async {
      await pumpPopover(tester, showArrow: false);
      final plain = tester.getSize(surface());
      expect(arrow, findsNothing);
      await tester.pumpWidget(const SizedBox());
      await pumpPopover(tester);
      expect(tester.getSize(surface()), plain);
      // And the content is where it was, inside the border.
      final box = tester.getRect(surface());
      final theme = Theme.of(tester.element(find.byType(Popover)));
      final padding = theme.popoverTheme.padding!.resolve(TextDirection.ltr);
      expect(
        tester.getTopLeft(find.text('Panel')),
        box.topLeft + Offset(padding.left + 1, padding.top + 1),
      );
    });

    for (final brightness in Brightness.values) {
      for (final (styleName, style) in [
        ('finesse', StyleTokens.finesse),
        ('nova', StyleTokens.nova),
      ]) {
        testWidgets(
          'the arrow is filled with the surface and outlined with it '
          '($styleName, ${brightness.name})',
          (tester) async {
            final theme = ThemeData(brightness: brightness, style: style);
            final sampler = FrameSampler();
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = const Size(400, 300);
            addTearDown(tester.view.reset);
            await tester.pumpWidget(
              sampler.wrap(
                FinesseApp(
                  theme: theme,
                  darkTheme: theme,
                  home: ColoredBox(
                    color: const Color(0xffffffff),
                    child: Center(
                      child: Popover(
                        visible: true,
                        showArrow: true,
                        shadows: const [],
                        popover: (context) =>
                            const SizedBox(width: 160, height: 60),
                        child: const SizedBox(
                          key: trigger,
                          width: 40,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            for (var i = 0; i < 16; i++) {
              await tester.pump(const Duration(milliseconds: 50));
            }
            const white = Color(0xffffffff);
            final box = tester.getRect(surface());
            final mark = tester.getCenter(arrow);
            final fill = over(
              theme.popoverTheme.decoration!.color!,
              white,
            );
            final line = over(
              theme.popoverTheme.decoration!.border!.top!.color!,
              fill,
            );
            final out = protrusion(tester);
            final pixels = await sampler.pixels(tester, [
              // In the arrow, outside the box: the fill.
              Offset(mark.dx, box.top - out / 2),
              // Where the box's edge would have crossed the arrow's foot:
              // the fill again, and no line.
              Offset(mark.dx, box.top + .5),
              // On the box's edge beside the arrow: the line.
              Offset(mark.dx + 30, box.top + .5),
              // Beside the arrow, above the edge: the page.
              Offset(mark.dx + 14, box.top - out / 2),
              // Inside the box, clear of the content: the fill.
              Offset(mark.dx, box.top + 6),
            ]);
            void same(Color a, Color b, String reason) {
              for (var c = 0; c < 3; c++) {
                expect(
                  (rgbOf(a)[c] - rgbOf(b)[c]).abs(),
                  lessThanOrEqualTo(2),
                  reason: '$reason: ${rgbOf(a)} is not ${rgbOf(b)}',
                );
              }
            }

            same(pixels[0], fill, 'the arrow is not filled');
            same(pixels[1], fill, 'a line crosses the foot of the arrow');
            same(pixels[2], line, 'the box has lost its line');
            same(pixels[3], white, 'something is painted beside the arrow');
            same(pixels[4], fill, 'the box is not filled');
          },
        );
      }
    }

    testWidgets('a glass popover is clipped to box and arrow as one', (
      tester,
    ) async {
      await pumpPopover(tester);
      final theme = Theme.of(tester.element(find.byType(Popover)));
      expect(theme.popoverTheme.filter, isNotNull);
      final clip = tester.widget<ClipPath>(
        find.descendant(of: surface(), matching: find.byType(ClipPath)),
      );
      final size = tester.getSize(surface());
      final path = clip.clipper!.getClip(size);
      final mark = tester.getCenter(arrow) - tester.getTopLeft(surface());
      expect(path.contains(Offset(mark.dx, -protrusion(tester) / 2)), isTrue);
      expect(path.contains(size.center(Offset.zero)), isTrue);
      expect(path.contains(Offset(mark.dx + 14, -2)), isFalse);
      // One contour: nothing to count twice, nothing to draw a line across.
      expect(path.computeMetrics().length, 1);
    });
  });

  group('theme and switches', () {
    testWidgets('off by default, on from the theme', (tester) async {
      await pumpPopover(tester, showArrow: null);
      expect(arrow, findsNothing);
      await tester.pumpWidget(const SizedBox());
      await pumpPopover(
        tester,
        showArrow: null,
        theme: ThemeData(popoverTheme: const PopoverTheme(showArrow: true)),
      );
      expect(arrow, findsOneWidget);
    });

    testWidgets('the theme sizes the arrow', (tester) async {
      await pumpPopover(
        tester,
        theme: ThemeData(popoverTheme: const PopoverTheme(arrowSize: 24)),
      );
      expect(tester.getSize(arrow), const Size(24, 24));
      final box = tester.getRect(surface());
      final target = tester.getRect(find.byKey(trigger));
      expect(
        box.top - target.bottom,
        closeTo(4 + ArrowShape.protrusionOf(24, 2), .01),
      );
    });

    testWidgets('a square style keeps the tip sharp', (tester) async {
      expect(ThemeData(style: StyleTokens.lyra).popoverTheme.arrowRadius, 0);
      expect(ThemeData().popoverTheme.arrowRadius, 2);
    });

    for (final layout in kLayouts) {
      testWidgets(
        'points at its trigger on ${layout.formFactor.name}, '
        '${layout.textDirection.name}',
        (tester) async {
          await pumpPopover(
            tester,
            formFactor: layout.formFactor,
            textDirection: layout.textDirection,
            surfaceSize: kSurfaceSizes[layout.formFactor]!,
          );
          expect(tester.takeException(), isNull);
          final target = tester.getRect(find.byKey(trigger));
          expect(tester.getCenter(arrow).dx, closeTo(target.center.dx, .5));
        },
      );
    }

    testWidgets('at twice the text size', (tester) async {
      await pumpPopover(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      final target = tester.getRect(find.byKey(trigger));
      expect(tester.getCenter(arrow).dx, closeTo(target.center.dx, .5));
    });

    for (final (name, theme, reduced) in [
      ('reduced motion', null, true),
      ('Motion.none', ThemeData(motion: Motion.none), false),
    ]) {
      testWidgets('with $name it is in place and at rest', (tester) async {
        await pumpPopover(tester, theme: theme, disableAnimations: reduced);
        final box = tester.getRect(surface());
        final target = tester.getRect(find.byKey(trigger));
        expect(box.top - target.bottom, closeTo(4 + protrusion(tester), .01));
        expect(tester.getCenter(arrow).dx, closeTo(target.center.dx, .5));
        await tester.pumpAndSettle();
      });
    }

    testWidgets('the entrance still grows from the trigger', (tester) async {
      await pumpPopover(tester);
      final origin = MotionOrigin.maybeOf(tester.element(arrow));
      expect(origin, Alignment.topCenter);
    });

    testWidgets('an arrowed popover opens, closes and settles', (
      tester,
    ) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Popover(
            controller: controller,
            showArrow: true,
            popover: (context) => const SizedBox(width: 160, height: 60),
            child: const SizedBox(key: trigger, width: 40, height: 24),
          ),
        ),
      );
      expect(arrow, findsNothing);
      controller.show();
      await tester.pumpAndSettle();
      expect(arrow, findsOneWidget);
      controller.hide();
      await tester.pumpAndSettle();
      expect(arrow, findsNothing);
    });
  });
}
