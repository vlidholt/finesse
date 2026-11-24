import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../frame_sampler.dart';

/// Glass has to stay glass while it fades in.
///
/// A backdrop filter under an opacity layer samples that layer, which is
/// empty, so on renderers that cannot fold the opacity into the filter the
/// blur is missing for the whole entrance and snaps in at its end. The
/// floating surfaces therefore take the fade over from their entrance
/// animation: nothing above the filter is ever translucent, and the tint
/// and content fade inside it while the blur grows.
void main() {
  /// The lowest opacity of any opacity layer above [finder]'s render object.
  double opacityAbove(WidgetTester tester, Finder finder) {
    var lowest = 1.0;
    var node = tester.renderObject(finder).parent;
    while (node != null) {
      if (node is RenderAnimatedOpacity) {
        if (node.opacity.value < lowest) lowest = node.opacity.value;
      } else if (node is RenderOpacity) {
        if (node.opacity < lowest) lowest = node.opacity;
      }
      node = node.parent;
    }
    return lowest;
  }

  Future<PopoverController> pumpPopover(
    WidgetTester tester,
    ThemeData theme, {
    FrameSampler? sampler,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 400);
    addTearDown(tester.view.reset);
    final controller = PopoverController();
    addTearDown(controller.dispose);
    final app = FinesseApp(
      theme: theme,
      darkTheme: theme,
      home: Stack(
        children: [
          // Stripes, so a blur is visible to a pixel probe.
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < 40; i++)
                  Expanded(
                    child: ColoredBox(
                      color: i.isEven
                          ? const Color(0xff000000)
                          : const Color(0xffffffff),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0, -.6),
            child: Popover(
              controller: controller,
              popover: (context) => const SizedBox(
                key: Key('content'),
                width: 160,
                height: 120,
              ),
              child: const SizedBox(width: 40, height: 20),
            ),
          ),
        ],
      ),
    );
    await tester.pumpWidget(sampler?.wrap(app) ?? app);
    await tester.pump(const Duration(milliseconds: 800));
    return controller;
  }

  testWidgets('a glass popover fades inside its filter, not above it', (
    tester,
  ) async {
    final controller = await pumpPopover(tester, ThemeData());
    controller.show();
    // The portal measures, positions, then shows; the entrance is 150 ms.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 40));

    final filter = find.byType(BackdropFilter);
    expect(filter, findsOneWidget);
    // Mid-entrance: nothing above the filter is translucent…
    expect(opacityAbove(tester, filter), 1);
    // …the content under it is…
    final inside = opacityAbove(tester, find.byKey(const Key('content')));
    expect(inside, greaterThan(0));
    expect(inside, lessThan(1));
    // …and the filter's result is on its way in, not at full strength
    // from frame one.
    final full = Theme.of(tester.element(filter)).popoverTheme.filter;
    expect(tester.widget<BackdropFilter>(filter).filter, isNot(full));
    expect(tester.widget<BackdropFilter>(filter).enabled, isTrue);

    await tester.pump(const Duration(milliseconds: 800));
    expect(opacityAbove(tester, find.byKey(const Key('content'))), 1);
    expect(tester.widget<BackdropFilter>(filter).filter, full);

    // And the same on the way out.
    controller.hide();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(opacityAbove(tester, filter), 1);
    expect(
      opacityAbove(tester, find.byKey(const Key('content'))),
      lessThan(1),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.byKey(const Key('content')), findsNothing);
  });

  testWidgets('a solid popover is faded as a whole, as before', (
    tester,
  ) async {
    final controller = await pumpPopover(
      tester,
      ThemeData(style: StyleTokens.nova),
    );
    controller.show();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 40));
    expect(find.byType(BackdropFilter), findsNothing);
    final opacity = opacityAbove(tester, find.byKey(const Key('content')));
    expect(opacity, greaterThan(0));
    expect(opacity, lessThan(1));
    await tester.pump(const Duration(milliseconds: 800));
    expect(opacityAbove(tester, find.byKey(const Key('content'))), 1);
  });

  testWidgets('the glass arrives in one movement: no pop at the end', (
    tester,
  ) async {
    final sampler = FrameSampler();
    final controller = await pumpPopover(
      tester,
      ThemeData(),
      sampler: sampler,
    );
    controller.show();
    await tester.pump();
    await tester.pump();
    // Two probes inside the popover, one over a black stripe and one over a
    // white one. Blurred glass brings both toward the same grey; a blur
    // that only appeared when the fade ended would jump there.
    final rect = tester.getRect(find.byKey(const Key('content')));
    final column = (rect.center.dx / 10).floor();
    final overA = Offset(column * 10 + 5, rect.center.dy);
    final overB = Offset((column + 1) * 10 + 5, rect.center.dy);
    final a = <Color>[];
    final b = <Color>[];
    for (var i = 0; i < 40; i++) {
      final seen = await sampler.pixels(tester, [overA, overB]);
      a.add(seen[0]);
      b.add(seen[1]);
      await tester.pump(const Duration(milliseconds: 16));
    }
    expectMonotone(a, reason: 'over one stripe', slack: 3);
    expectMonotone(b, reason: 'over the next', slack: 3);
    // Settled, the two are close: the stripes are blurred away.
    expect((rgbOf(a.last)[0] - rgbOf(b.last)[0]).abs(), lessThan(24));
    // And the journey is a cross-fade: the frames in the middle sit
    // between the ends, in step — no frame makes more than a third of it.
    for (final frames in [a, b]) {
      final values = [for (final f in frames) rgbOf(f)[0]];
      final total = (values.last - values.first).abs();
      for (var i = 1; i < values.length; i++) {
        expect(
          (values[i] - values[i - 1]).abs(),
          lessThanOrEqualTo(total / 3 + 2),
          reason: 'frame $i jumps: $values',
        );
      }
    }
  });

  group('Backdrop.faded', () {
    test('is nothing at zero, the filter itself at one, a new one between', () {
      final filter = Backdrop.filterFor(blur: 24, saturation: 1.6)!;
      expect(Backdrop.faded(filter, 0), isNull);
      expect(Backdrop.faded(filter, 1), same(filter));
      final half = Backdrop.faded(filter, .5)!;
      expect(half, isNot(filter));
      expect(half, Backdrop.faded(filter, .5));
      expect(half, isNot(Backdrop.faded(filter, .25)));
    });
  });

  group('BackdropFadeHost', () {
    testWidgets('fades its child when nothing claims the fade', (tester) async {
      final animation = AnimationController(vsync: tester, value: .25);
      addTearDown(animation.dispose);
      await tester.pumpWidget(
        BackdropFadeHost(
          opacity: animation,
          child: const SizedBox(key: Key('child'), width: 10, height: 10),
        ),
      );
      expect(opacityAbove(tester, find.byKey(const Key('child'))), .25);
    });

    testWidgets('hands the fade to a surface with a filter, and takes it '
        'back when the filter goes', (tester) async {
      final animation = AnimationController(vsync: tester, value: .25);
      addTearDown(animation.dispose);
      Widget host(ui.ImageFilter? filter) => Directionality(
        textDirection: TextDirection.ltr,
        child: BackdropFadeHost(
          opacity: animation,
          child: BackdropSurface(
            filter: filter,
            child: const SizedBox(key: Key('child'), width: 10, height: 10),
          ),
        ),
      );
      final filter = Backdrop.filterFor(blur: 10);
      await tester.pumpWidget(host(filter));
      expect(opacityAbove(tester, find.byType(BackdropFilter)), 1);
      expect(opacityAbove(tester, find.byKey(const Key('child'))), .25);

      await tester.pumpWidget(host(null));
      expect(find.byType(BackdropFilter), findsNothing);
      expect(opacityAbove(tester, find.byKey(const Key('child'))), .25);
    });
  });
}
