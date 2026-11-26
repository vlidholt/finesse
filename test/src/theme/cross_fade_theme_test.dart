import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

/// How opaque the picture of the previous frame is drawn over the app, or
/// null when it is not drawn at all.
double? _overlayOpacity(WidgetTester tester) {
  final fade = tester.renderObject(
    find.byWidgetPredicate((w) => '${w.runtimeType}' == '_ThemeFade'),
  );
  final canvas = TestRecordingCanvas();
  fade.paint(TestRecordingPaintingContext(canvas), Offset.zero);
  for (final call in canvas.invocations) {
    if (call.invocation.memberName == #drawImageRect) {
      return (call.invocation.positionalArguments[3] as Paint).color.a;
    }
  }
  return null;
}

class _Probe extends StatelessWidget {
  const _Probe(this.builds);

  final List<Brightness> builds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    builds.add(theme.brightness);
    return ColoredBox(
      color: theme.colorScheme.background,
      child: const SizedBox.expand(),
    );
  }
}

void main() {
  final light = ThemeData(brightness: Brightness.light);
  final dark = ThemeData(brightness: Brightness.dark);

  Widget app(
    ThemeData theme,
    List<Brightness> builds, {
    bool reduceMotion = false,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: CrossFadeTheme(data: theme, child: _Probe(builds)),
    ),
  );

  testWidgets('a new theme is applied in one build and the old look fades '
      'out over it', (tester) async {
    final builds = <Brightness>[];
    await tester.pumpWidget(app(light, builds));
    expect(builds, [Brightness.light]);
    expect(_overlayOpacity(tester), isNull);

    await tester.pumpWidget(app(dark, builds));
    // The whole of the new theme at once: nothing in between.
    expect(builds, [Brightness.light, Brightness.dark]);
    expect(Theme.of(tester.element(find.byType(_Probe))), dark);
    // …under a picture of the frame before, which starts out covering it.
    expect(_overlayOpacity(tester), 1);

    // The fade is timed from the frame after the one that built the new
    // theme, which is the longest frame an app has: timed from that one, a
    // fade on a slow device is over before it is seen.
    await tester.pump(const Duration(milliseconds: 300));
    expect(_overlayOpacity(tester), 1);

    final opacities = <double>[];
    for (var i = 0; i < 9; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      opacities.add(_overlayOpacity(tester) ?? 0);
    }
    for (var i = 1; i < opacities.length; i++) {
      expect(opacities[i], lessThanOrEqualTo(opacities[i - 1]));
    }
    expect(opacities.first, inExclusiveRange(.8, 1));
    expect(opacities[4], closeTo(.5, .01));
    await tester.pump(const Duration(milliseconds: 40));
    expect(_overlayOpacity(tester), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);

    // The fade is paint: the app under it was built once.
    expect(builds, [Brightness.light, Brightness.dark]);
  });

  testWidgets('a frame of the fade paints the picture and nothing under '
      'it', (tester) async {
    final builds = <Brightness>[];
    await tester.pumpWidget(app(light, builds));
    await tester.pumpWidget(app(dark, builds));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    final painted = <String>[];
    debugOnProfilePaint = (object) {
      if (object.isRepaintBoundary && !object.debugNeedsPaint) return;
      painted.add('${object.runtimeType}');
    };
    addTearDown(() => debugOnProfilePaint = null);
    await tester.pump(const Duration(milliseconds: 20));
    debugOnProfilePaint = null;
    expect(painted, isEmpty, reason: 'the app was painted again');
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('an equal theme changes nothing', (tester) async {
    final builds = <Brightness>[];
    await tester.pumpWidget(app(light, builds));
    await tester.pumpWidget(
      app(ThemeData(brightness: Brightness.light), builds),
    );
    expect(_overlayOpacity(tester), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('with reduced motion the theme simply changes', (tester) async {
    final builds = <Brightness>[];
    await tester.pumpWidget(app(light, builds, reduceMotion: true));
    await tester.pumpWidget(app(dark, builds, reduceMotion: true));
    expect(builds.last, Brightness.dark);
    expect(_overlayOpacity(tester), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('themes that follow each other closely are followed '
      'directly', (tester) async {
    // A slider in a theme editor: the first change fades, and while they
    // keep coming no further picture is taken — each is a read-back of the
    // whole window.
    final builds = <Brightness>[];
    await tester.pumpWidget(app(light, builds));
    await tester.pumpWidget(app(dark, builds));
    expect(_overlayOpacity(tester), 1);

    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpWidget(
        app(
          ThemeData(
            brightness: Brightness.dark,
            radius: BorderRadius.circular(i.toDouble()),
          ),
          builds,
        ),
      );
    }
    // The one fade ran out under the drag and was not started again.
    expect(_overlayOpacity(tester), isNull);
    expect(builds, hasLength(32));

    // After a pause the next change is a switch again.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(app(light, builds));
    expect(_overlayOpacity(tester), 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(_overlayOpacity(tester), isNull);
  });

  testWidgets('a window resized under the fade drops the picture', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 600);
    final builds = <Brightness>[];
    await tester.pumpWidget(app(light, builds));
    await tester.pumpWidget(app(dark, builds));
    expect(_overlayOpacity(tester), 1);

    // A picture of another size is a picture of another layout.
    tester.view.physicalSize = const Size(400, 600);
    await tester.pump(const Duration(milliseconds: 20));
    expect(_overlayOpacity(tester), isNull);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('UnaApp changes theme this way', (tester) async {
    final builds = <Brightness>[];
    Widget unaApp(ThemeMode mode) => UnaApp(
      themeMode: mode,
      theme: light,
      darkTheme: dark,
      home: _Probe(builds),
    );
    await tester.pumpWidget(unaApp(ThemeMode.light));
    await tester.pumpWidget(unaApp(ThemeMode.dark));
    expect(builds, [Brightness.light, Brightness.dark]);
    expect(_overlayOpacity(tester), 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(builds, [Brightness.light, Brightness.dark]);
    expect(_overlayOpacity(tester), closeTo(.5, .01));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_overlayOpacity(tester), isNull);
  });

  group('a fill follows a change of theme at once', () {
    Widget fills(ThemeData theme, {required bool on}) => Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: theme,
        child: Builder(
          builder: (context) {
            final scheme = Theme.of(context).colorScheme;
            final color = on ? scheme.primary : scheme.muted;
            return Column(
              children: [
                AnimatedColorBuilder(
                  color: color,
                  duration: const Duration(milliseconds: 120),
                  builder: (context, value, _) => ColoredBox(
                    key: const ValueKey('builder'),
                    color: value!,
                    child: const SizedBox.square(dimension: 10),
                  ),
                ),
                AnimatedFill(
                  color: color,
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.linear,
                  child: const SizedBox.square(dimension: 10),
                ),
              ],
            );
          },
        ),
      ),
    );

    Color builderColor(WidgetTester tester) =>
        tester.widget<ColoredBox>(find.byKey(const ValueKey('builder'))).color;
    Color fillColor(WidgetTester tester) =>
        (tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: find.byType(AnimatedFill),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration)
            .color!;

    testWidgets('and still fades for a change of state', (tester) async {
      await tester.pumpWidget(fills(light, on: false));
      expect(builderColor(tester), light.colorScheme.muted);
      expect(fillColor(tester), light.colorScheme.muted);

      // The theme changes: no fade, and nothing left running.
      await tester.pumpWidget(fills(dark, on: false));
      expect(builderColor(tester), dark.colorScheme.muted);
      expect(fillColor(tester), dark.colorScheme.muted);
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);

      // The state changes: the fill fades.
      await tester.pumpWidget(fills(dark, on: true));
      await tester.pump(const Duration(milliseconds: 60));
      for (final color in [builderColor(tester), fillColor(tester)]) {
        expect(color, isNot(dark.colorScheme.muted));
        expect(color, isNot(dark.colorScheme.primary));
      }
      await tester.pump(const Duration(milliseconds: 80));
      expect(builderColor(tester), dark.colorScheme.primary);
      expect(fillColor(tester), dark.colorScheme.primary);
    });

    testWidgets('an equal theme built again is not a change', (tester) async {
      // An app that builds its `ThemeData` inline has a new instance on
      // every rebuild; a fill must not take that for a change of theme.
      await tester.pumpWidget(fills(light, on: false));
      await tester.pumpWidget(
        fills(ThemeData(brightness: Brightness.light), on: true),
      );
      await tester.pump(const Duration(milliseconds: 60));
      for (final color in [builderColor(tester), fillColor(tester)]) {
        expect(color, isNot(light.colorScheme.muted));
        expect(color, isNot(light.colorScheme.primary));
      }
      await tester.pump(const Duration(milliseconds: 80));
    });
  });
}
