import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../frame_sampler.dart';

/// A floating surface's shadow is outside its shape and nowhere else.
///
/// The floating surfaces of the `finesse` style are glass, and anything
/// painted behind glass shows through it: a shadow under the surface reads
/// as a grey, dirty wash in the menu. There are three ways for it to get
/// there, and each has happened:
///
/// * the shadow is not clipped to the outside of the shape — on the web,
///   where `Path.combine` hands back its first operand, it never was;
/// * it is clipped to the outside of the *wrong* shape — a tooltip's bubble
///   without its arrow;
/// * it is outside, but painted before the backdrop filter, whose blur
///   reaches past the edge and drags it back in.
///
/// So these do not ask the widgets what they were given. They rasterise a
/// menu, a tooltip with its arrow, a command palette and a toast over white
/// and over a "photograph", once with their shadow and once without, at
/// rest and in the middle of the entrance, and require every pixel inside
/// the shape to be the same in both — and, over white, to be exactly the
/// tint over the backdrop. `glass_shadow_web_test.dart` runs the same in a
/// browser.
void main() {
  const white = Color(0xffffffff);

  // Hard-edged bands of dark, bright and saturated colour: what a blur
  // turns into the uneven backdrop a photograph gives.
  Widget photo() => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < 16; i++)
        Expanded(
          child: ColoredBox(
            color: const [
              Color(0xff0e1e25),
              Color(0xffe8c170),
              Color(0xff7a2e2e),
              Color(0xfff3f5f7),
              Color(0xff2e7d5b),
              Color(0xff1b3a4b),
              Color(0xff6cc0d6),
              Color(0xff000000),
            ][i % 8],
          ),
        ),
    ],
  );

  const heavy = [
    BoxShadow(
      color: Color(0x80000000),
      offset: Offset(0, 12),
      blurRadius: 30,
      spreadRadius: -4,
    ),
  ];

  Future<FrameSampler> pump(
    WidgetTester tester, {
    required ThemeData theme,
    required Widget backdrop,
    required Widget child,
    Size size = const Size(400, 400),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    // flutter_test drops the blur of every shadow; these are about it.
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    final sampler = FrameSampler();
    // A fresh tree each time: the second render of a pair must not inherit
    // an open overlay from the first.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      sampler.wrap(
        FinesseApp(
          theme: theme,
          darkTheme: theme,
          home: Stack(
            children: [
              Positioned.fill(child: backdrop),
              child,
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return sampler;
  }

  /// The frames an entrance is sampled at: `false` a few frames in, `true`
  /// once it has come to rest.
  Future<void> advance(WidgetTester tester, {required bool settled}) async {
    // The portal measures, positions, then shows; the entrance follows.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 40));
    if (settled) await tester.pump(const Duration(milliseconds: 800));
  }

  /// Points just inside each edge and corner of [rect] and in its middle,
  /// and two just outside it, where a shadow falls.
  ({List<Offset> inside, List<Offset> outside}) probes(
    Rect rect, {
    double corner = 10,
  }) => (
    inside: [
      rect.center,
      Offset(rect.center.dx, rect.top + 3),
      Offset(rect.center.dx, rect.bottom - 3),
      Offset(rect.left + 3, rect.center.dy),
      Offset(rect.right - 3, rect.center.dy),
      Offset(rect.left + corner, rect.top + corner),
      Offset(rect.right - corner, rect.top + corner),
      Offset(rect.left + corner, rect.bottom - corner),
      Offset(rect.right - corner, rect.bottom - corner),
    ],
    // Either side of the middle, where a tooltip has its arrow.
    outside: [
      Offset(rect.center.dx + 30, rect.bottom + 4),
      Offset(rect.center.dx - 30, rect.bottom + 6),
    ],
  );

  void expectSame(Color a, Color b, {required String reason}) {
    final x = rgbOf(a);
    final y = rgbOf(b);
    for (var c = 0; c < 3; c++) {
      expect(
        (x[c] - y[c]).abs(),
        lessThanOrEqualTo(1),
        reason:
            '$reason: ${x.join(',')} with the shadow, ${y.join(',')} '
            'without',
      );
    }
  }

  /// Renders [build] with and without its shadow and compares the two.
  ///
  /// [build] returns the widget to put on the backdrop for a theme, [open]
  /// shows the surface, and [surface] finds the box its shape fills.
  /// [extraInside] adds probes that are inside the shape but outside that
  /// box — a tooltip's arrow. [tint] is the surface's fill, for the check
  /// over white.
  Future<void> expectShadowOutside(
    WidgetTester tester, {
    required String name,
    required Widget Function({required bool shadow}) build,
    required ThemeData Function({required bool shadow}) theme,
    required Future<void> Function(WidgetTester tester) open,
    required Finder surface,
    required Color Function(ThemeData theme) tint,
    List<Offset> Function(WidgetTester tester)? extraInside,
    bool entrance = true,
    double corner = 10,
    Size size = const Size(400, 400),
  }) async {
    for (final (backdropName, backdrop) in [
      ('white', const ColoredBox(color: white) as Widget),
      ('photo', photo()),
    ]) {
      for (final settled in [if (entrance) false, true]) {
        final where =
            '$name over $backdropName, '
            '${settled ? 'at rest' : 'mid-entrance'}';
        final seen = <bool, ({List<Color> inside, List<Color> outside})>{};
        late List<Offset> insidePoints;
        for (final shadow in [true, false]) {
          final sampler = await pump(
            tester,
            theme: theme(shadow: shadow),
            backdrop: backdrop,
            child: build(shadow: shadow),
            size: size,
          );
          await open(tester);
          await advance(tester, settled: settled);
          final points = probes(tester.getRect(surface), corner: corner);
          insidePoints = [...points.inside, ...?extraInside?.call(tester)];
          seen[shadow] = (
            inside: await sampler.pixels(tester, insidePoints),
            // Mid-entrance a surface may still be partly off the screen.
            outside: settled
                ? await sampler.pixels(tester, points.outside)
                : const [],
          );
        }

        // Inside the shape the shadow changes nothing…
        for (var i = 0; i < insidePoints.length; i++) {
          expectSame(
            seen[true]!.inside[i],
            seen[false]!.inside[i],
            reason: '$where: the shadow shows inside at ${insidePoints[i]}',
          );
        }
        // …and it is really there outside it, so the above is not vacuous.
        if (settled && backdropName == 'white') {
          expect(
            rgbOf(seen[true]!.outside[0])[0],
            lessThan(rgbOf(seen[false]!.outside[0])[0] - 8),
            reason: '$where: no shadow under the surface',
          );
          expect(
            rgbOf(seen[true]!.outside[1])[0],
            lessThan(rgbOf(seen[false]!.outside[1])[0] - 4),
            reason: '$where: no shadow under the surface',
          );
          // Over white the glass is its tint over white and nothing more:
          // a blur and a saturation leave white alone. Read where there is
          // no content: just inside the edges.
          final expected = over(tint(theme(shadow: true)), white);
          for (var i = 1; i < 5; i++) {
            expectSame(
              seen[true]!.inside[i],
              expected,
              reason: '$where: not the bare tint at ${insidePoints[i]}',
            );
          }
        }
      }
    }
  }

  for (final brightness in Brightness.values) {
    final mode = brightness.name;

    testWidgets('$mode: a glass menu', (tester) async {
      late FinesseContextMenuController controller;
      await expectShadowOutside(
        tester,
        name: 'menu',
        theme: ({required shadow}) => ThemeData(
          brightness: brightness,
          style: shadow
              ? StyleTokens.finesse
              : StyleTokens.finesse.copyWith(popoverShadow: const []),
        ),
        build: ({required shadow}) {
          controller = FinesseContextMenuController();
          addTearDown(controller.dispose);
          return Align(
            alignment: const Alignment(0, -.5),
            child: ContextMenu(
              controller: controller,
              constraints: const BoxConstraints(minWidth: 180),
              items: [
                for (final label in ['One', 'Two', 'Three', 'Four'])
                  MenuItem(onPressed: () {}, child: Text(label)),
              ],
              child: const SizedBox(width: 40, height: 20),
            ),
          );
        },
        open: (tester) async => controller.open(),
        surface: find.byType(BackdropSurface),
        tint: (theme) => theme.contextMenuTheme.decoration!.color!,
      );
      // The menu really was glass, with a shadow to keep out of it.
      final theme = ThemeData(brightness: brightness);
      expect(theme.contextMenuTheme.filter, isNotNull);
      expect(theme.contextMenuTheme.decoration!.color!.a, lessThan(1));
      expect(
        theme.contextMenuTheme.shadows ?? theme.popoverTheme.shadows,
        isNotEmpty,
      );
    });

    testWidgets('$mode: a glass tooltip and its arrow', (tester) async {
      late PopoverController controller;
      Offset arrowTip(WidgetTester tester) {
        // The arrow is a square turned 45° around this box's centre, which
        // sits a fifth of its side inside the bubble's edge, its tip .7 of
        // a side out: this point is in the arrow and outside the bubble,
        // whatever the entrance has scaled the tooltip to.
        final arrow = tester.getRect(
          find.byKey(const ValueKey('finesse_tooltip_arrow')),
        );
        final below =
            arrow.center.dy >
            tester.getRect(find.byType(BackdropSurface)).center.dy;
        return arrow.center + Offset(0, (below ? .45 : -.45) * arrow.height);
      }

      await expectShadowOutside(
        tester,
        name: 'tooltip',
        theme: ({required shadow}) => ThemeData(brightness: brightness),
        build: ({required shadow}) {
          controller = PopoverController();
          addTearDown(controller.dispose);
          return Align(
            alignment: const Alignment(0, .2),
            child: Tooltip(
              controller: controller,
              // Tooltips cast no shadow by default; one that does must keep
              // it off the bubble *and* off the arrow.
              decoration: shadow
                  ? const FinesseDecoration(shadows: heavy)
                  : null,
              builder: (context) => const SizedBox(width: 120, height: 24),
              child: const SizedBox(width: 60, height: 24),
            ),
          );
        },
        open: (tester) async => controller.open(),
        surface: find.byType(BackdropSurface),
        tint: (theme) => theme.tooltipTheme.decoration!.color!,
        extraInside: (tester) => [arrowTip(tester)],
        corner: 6,
      );

      // And the arrow is there at all: the bubble's colour, not the
      // backdrop's. (On the web a path union once returned the bubble
      // alone.)
      final theme = ThemeData(brightness: brightness);
      final sampler = await pump(
        tester,
        theme: theme,
        backdrop: const ColoredBox(color: white),
        child: Align(
          alignment: const Alignment(0, .2),
          child: Tooltip(
            controller: controller = PopoverController(),
            builder: (context) => const SizedBox(width: 120, height: 24),
            child: const SizedBox(width: 60, height: 24),
          ),
        ),
      );
      addTearDown(controller.dispose);
      controller.open();
      await advance(tester, settled: true);
      expectSame(
        await sampler.pixel(tester, arrowTip(tester)),
        over(theme.tooltipTheme.decoration!.color!, white),
        reason: 'the arrow is not painted',
      );
    });

    // A popover with an arrow is one outline too, with a line round it: its
    // shadow is cut out of box and arrow alike — through the clip over
    // glass, and by being covered under a solid fill.
    for (final (finish, style) in [
      ('glass', StyleTokens.finesse),
      ('solid', StyleTokens.nova),
    ]) {
      testWidgets('$mode: a $finish popover and its arrow', (tester) async {
        late PopoverController controller;
        Offset arrowTip(WidgetTester tester) {
          // In the arrow and outside the box, as for the tooltip: the
          // popover hangs below its trigger, the arrow on its top edge.
          final arrow = tester.getRect(find.byKey(SurfacePainter.arrowKey));
          return arrow.center - Offset(0, .45 * arrow.height);
        }

        await expectShadowOutside(
          tester,
          name: '$finish popover',
          theme: ({required shadow}) => ThemeData(
            brightness: brightness,
            style: shadow ? style : style.copyWith(popoverShadow: const []),
          ),
          build: ({required shadow}) {
            controller = PopoverController();
            addTearDown(controller.dispose);
            return Align(
              alignment: const Alignment(0, -.5),
              child: Popover(
                controller: controller,
                showArrow: true,
                // As heavy as the tooltip's, so the solid styles' faint
                // one does not make the check under the surface vacuous.
                shadows: shadow ? heavy : null,
                builder: (context) => const SizedBox(width: 180, height: 80),
                child: const SizedBox(width: 40, height: 20),
              ),
            );
          },
          open: (tester) async => controller.open(),
          surface: find.byType(BackdropSurface),
          tint: (theme) => theme.popoverTheme.decoration!.color!,
          extraInside: (tester) => [arrowTip(tester)],
        );

        final theme = ThemeData(brightness: brightness, style: style);
        expect(theme.popoverTheme.filter, finish == 'glass' ? isNotNull : null);
        expect(
          theme.popoverTheme.decoration!.color!.a,
          finish == 'glass' ? lessThan(1) : 1,
        );

        // And the arrow is there: the surface's colour, not the backdrop's.
        final sampler = await pump(
          tester,
          theme: theme,
          backdrop: const ColoredBox(color: white),
          child: Align(
            alignment: const Alignment(0, -.5),
            child: Popover(
              controller: controller = PopoverController(),
              showArrow: true,
              builder: (context) => const SizedBox(width: 180, height: 80),
              child: const SizedBox(width: 40, height: 20),
            ),
          ),
        );
        addTearDown(controller.dispose);
        controller.open();
        await advance(tester, settled: true);
        expectSame(
          await sampler.pixel(tester, arrowTip(tester)),
          over(theme.popoverTheme.decoration!.color!, white),
          reason: 'the arrow is not painted',
        );
      });
    }

    testWidgets('$mode: a glass command palette', (tester) async {
      await expectShadowOutside(
        tester,
        name: 'command',
        theme: ({required shadow}) => ThemeData(brightness: brightness),
        build: ({required shadow}) => Align(
          alignment: const Alignment(0, -.4),
          child: Command(
            width: 260,
            showSearch: false,
            decoration: shadow ? const FinesseDecoration(shadows: heavy) : null,
            groups: const [
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
        open: (tester) async {},
        surface: find.byType(BackdropSurface),
        tint: (theme) => theme.commandTheme.backgroundColor!,
        // It is in the page, not an overlay: there is no entrance.
        entrance: false,
      );
    });

    testWidgets('$mode: a glass toast', (tester) async {
      await expectShadowOutside(
        tester,
        name: 'toast',
        theme: ({required shadow}) => ThemeData(
          brightness: brightness,
          style: shadow
              ? StyleTokens.finesse
              : StyleTokens.finesse.copyWith(
                  sheetShadow: const [],
                  floatingShadowDark: const [],
                ),
          // Room under the toast for its shadow to be read.
          toasterTheme: const ToasterTheme(padding: EdgeInsets.all(40)),
        ),
        build: ({required shadow}) => const SizedBox(key: Key('host')),
        open: (tester) async {
          Toaster.of(tester.element(find.byKey(const Key('host')))).show(
            const Toast(
              title: Text('Invitation sent'),
              description: Text('She will see it in her network tab.'),
            ),
          );
        },
        surface: find.byType(BackdropSurface),
        tint: (theme) => theme.toastTheme.backgroundColor!,
        // Wide enough for the toast to sit in a corner with room under it.
        size: const Size(900, 500),
      );
      // Let the toast's timer run out before the test ends.
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
