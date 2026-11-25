import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// When [Portal.onShown] fires.
///
/// A popover starts its entrance from it, on a controller whose duration is
/// set by the animate widget *inside* the overlay. A report that comes before
/// the overlay has been built therefore starts the entrance on whatever
/// duration the controller had before — the framework default the first
/// time, the previous effects' length after that.
void main() {
  const anchors = <(String, AnchorBase)>[
    ('Anchor', Anchor(childAlignment: Alignment.bottomCenter)),
    ('GlobalAnchor', GlobalAnchor(Offset(200, 200))),
    ('AnchorAuto', AnchorAuto(offset: Offset(0, 4))),
  ];

  for (final (name, anchor) in anchors) {
    testWidgets('$name: onShown comes after the overlay has been built, once '
        'per showing', (tester) async {
      final visible = ValueNotifier(false);
      addTearDown(visible.dispose);
      var builds = 0;
      final buildsWhenShown = <int>[];
      await tester.pumpWidget(
        FinesseApp(
          home: Center(
            child: ValueListenableBuilder(
              valueListenable: visible,
              builder: (context, visible, _) => Portal(
                visible: visible,
                anchor: anchor,
                onShown: () => buildsWhenShown.add(builds),
                portalBuilder: (context) {
                  builds++;
                  return const Text('Content');
                },
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      );

      for (var showing = 1; showing <= 2; showing++) {
        builds = 0;
        buildsWhenShown.clear();
        visible.value = true;
        for (var i = 0; i < 6; i++) {
          await tester.pump();
        }
        expect(find.text('Content'), findsOneWidget);
        expect(buildsWhenShown, hasLength(1), reason: 'showing $showing');
        expect(
          buildsWhenShown.single,
          greaterThan(0),
          reason: 'showing $showing: reported before the overlay was built',
        );

        visible.value = false;
        for (var i = 0; i < 3; i++) {
          await tester.pump();
        }
        expect(find.text('Content'), findsNothing);
      }
    });

    testWidgets('$name: hidden again before its first frame, it reports '
        'nothing', (tester) async {
      final visible = ValueNotifier(false);
      addTearDown(visible.dispose);
      var shown = 0;
      await tester.pumpWidget(
        FinesseApp(
          home: Center(
            child: ValueListenableBuilder(
              valueListenable: visible,
              builder: (context, visible, _) => Portal(
                visible: visible,
                anchor: anchor,
                onShown: () => shown++,
                portalBuilder: (context) => const Text('Content'),
                child: const Text('Trigger'),
              ),
            ),
          ),
        ),
      );

      visible.value = true;
      // One frame: the portal has been told to show, the overlay is not
      // built yet.
      await tester.pump();
      visible.value = false;
      for (var i = 0; i < 4; i++) {
        await tester.pump();
      }
      expect(find.text('Content'), findsNothing);
      expect(shown, 0);
    });

    testWidgets('$name: the first and the second entrance of a popover take '
        'the same time', (tester) async {
      final controller = PopoverController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        FinesseApp(
          theme: ThemeData(style: StyleTokens.nova),
          home: Center(
            child: Popover(
              controller: controller,
              anchor: anchor,
              // One second, linear: the opacity is the elapsed time.
              effects: const [
                FadeEffect(
                  duration: Duration(seconds: 1),
                  curve: Curves.linear,
                ),
              ],
              builder: (context) => const Text('Content'),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      Future<double> openAndSample() async {
        controller.open();
        // Until it is on screen and its entrance has started.
        for (var i = 0; i < 4; i++) {
          await tester.pump();
        }
        await tester.pump(const Duration(milliseconds: 200));
        final value = _opacity(tester, find.text('Content'));
        controller.close();
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        expect(find.text('Content'), findsNothing);
        return value;
      }

      final first = await openAndSample();
      final second = await openAndSample();
      // 200 ms into a one-second linear fade.
      expect(second, closeTo(.2, .05), reason: 'second opening');
      expect(first, closeTo(.2, .05), reason: 'first opening');
    });
  }
}

/// The opacity [content] is painted at: the product of every opacity layer
/// above it.
double _opacity(WidgetTester tester, Finder content) {
  var opacity = 1.0;
  RenderObject? node = tester.renderObject(content);
  while (node != null) {
    if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
    if (node is RenderOpacity) opacity *= node.opacity;
    node = node.parent;
  }
  return opacity;
}
