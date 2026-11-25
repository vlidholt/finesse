// Throwaway: renders batch 2's widgets to PNG with real fonts.
// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/docs/examples/list_detail_layout/list_detail_layout_basic.dart';
import 'package:example/docs/examples/navigation_bar/navigation_bar_labels.dart';
import 'package:example/docs/examples/navigation_rail/navigation_rail_basic.dart';
import 'package:example/docs/examples/page_route/page_route_push.dart';
import 'package:example/docs/examples/scaffold/scaffold_navigation.dart';
import 'package:example/docs/examples/segmented_control/segmented_control_basic.dart';
import 'package:example/docs/examples/segmented_control/segmented_control_expanded.dart';
import 'package:example/docs/examples/segmented_control/segmented_control_icons.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_expanded.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_scrollable.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_segmented.dart';
import 'package:example/docs/examples/tab_bar/tab_bar_view.dart';
import 'package:example/docs/examples/tabs/tabs_basic.dart';
import 'package:example/docs/examples/tabs/tabs_underline.dart';
import 'package:example/docs/examples/toolbar/toolbar_basic.dart';
import 'package:example/docs/examples/toolbar/toolbar_docked.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const out =
    '/private/tmp/claude-501/-Users-viktor--claude-spares-spare-uR1oJ0/'
    '0bd8769e-50f2-4479-bfe1-529a1b328425/scratchpad/wave_c/batch2';
const fonts = '/Users/viktor/Projects/shad_demo/assets/fonts';

Future<void> loadFont(String family, String path) async {
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(File(path).readAsBytesSync().buffer)));
  await loader.load();
}

final _key = GlobalKey();

Future<void> capture(WidgetTester tester, String name) async {
  final boundary =
      _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$out/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

typedef Act = Future<void> Function(WidgetTester tester, String name);

Future<void> render(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(520, 360),
  Brightness brightness = Brightness.light,
  StylePreset style = StylePreset.finesse,
  FormFactor formFactor = FormFactor.desktop,
  TextDirection direction = TextDirection.ltr,
  bool center = true,
  Act? act,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) =>
      errors.add(details.exceptionAsString().split('\n').first);
  try {
    final theme = ThemeEditorConfig(
      brightness: brightness,
      style: style,
    ).build();
    await tester.pumpWidget(
      RepaintBoundary(
        key: _key,
        child: FinesseApp(
          theme: theme,
          formFactor: formFactor,
          home: Directionality(
            textDirection: direction,
            child: center ? Center(child: child) : child,
          ),
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    if (act == null) {
      await capture(tester, name);
    } else {
      await act(tester, name);
    }
  } finally {
    FlutterError.onError = previous;
    debugDisableShadows = true;
  }
  if (errors.isNotEmpty) print('ERRORS $name: ${errors.toSet()}');
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    Directory(out).createSync(recursive: true);
    for (final (variant, weight) in [
      ('regular', '400'),
      ('500', '500'),
      ('600', '600'),
      ('700', '700'),
    ]) {
      await loadFont('Geist_$variant', '$fonts/Geist-$weight.ttf');
    }
    await loadFont('JetBrainsMono', '$fonts/JetBrainsMono-400.ttf');
    const icons = '../fonts/phosphor';
    await loadFont('packages/finesse/PhosphorRegular', '$icons/Phosphor.ttf');
    await loadFont('packages/finesse/PhosphorFill', '$icons/Phosphor-Fill.ttf');
    await loadFont('packages/finesse/PhosphorBold', '$icons/Phosphor-Bold.ttf');
  });

  const which = String.fromEnvironment('WHICH', defaultValue: 'all');
  bool on(String group) => which == 'all' || which == group;

  if (on('segmented')) {
    for (final (brightness, style) in [
      (Brightness.light, StylePreset.finesse),
      (Brightness.dark, StylePreset.finesse),
      (Brightness.light, StylePreset.nova),
      (Brightness.dark, StylePreset.lyra),
      (Brightness.light, StylePreset.maia),
    ]) {
      final tag = '${style.name}_${brightness.name}';
      testWidgets('segmented $tag', (tester) async {
        await render(
          tester,
          'segmented_$tag',
          const Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              SegmentedControlBasicExample(),
              SegmentedControlIconsExample(),
              SegmentedControlExpandedExample(),
            ],
          ),
          size: const Size(520, 520),
          brightness: brightness,
          style: style,
        );
      });
    }
    testWidgets('segmented phone', (tester) async {
      await render(
        tester,
        'segmented_phone',
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              SegmentedControlBasicExample(),
              SegmentedControlIconsExample(),
              SegmentedControlExpandedExample(),
            ],
          ),
        ),
        size: const Size(390, 520),
        formFactor: FormFactor.mobile,
      );
    });
    testWidgets('segmented travel filmstrip', (tester) async {
      await render(
        tester,
        'segmented_travel',
        const SegmentedControlBasicExample(),
        size: const Size(420, 140),
        act: (tester, name) async {
          await tester.tap(find.text('Spacious'));
          await tester.pump();
          for (var i = 0; i < 6; i++) {
            await tester.pump(const Duration(milliseconds: 32));
            await capture(tester, '${name}_$i');
          }
        },
      );
    });
  }

  if (on('tabs')) {
    for (final (brightness, style) in [
      (Brightness.light, StylePreset.finesse),
      (Brightness.dark, StylePreset.finesse),
      (Brightness.light, StylePreset.nova),
    ]) {
      final tag = '${style.name}_${brightness.name}';
      testWidgets('tab bars $tag', (tester) async {
        await render(
          tester,
          'tab_bars_$tag',
          const Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              TabBarExpandedExample(),
              TabBarScrollableExample(),
              TabBarSegmentedExample(),
              TabsUnderlineExample(),
            ],
          ),
          size: const Size(560, 640),
          brightness: brightness,
          style: style,
        );
      });
    }
    testWidgets('tabs basic', (tester) async {
      await render(
        tester,
        'tabs_basic',
        const TabsBasicExample(),
        size: const Size(520, 480),
      );
    });
    for (final brightness in Brightness.values) {
      testWidgets('tab bar view swipe ${brightness.name}', (tester) async {
        await render(
          tester,
          'tab_bar_view_${brightness.name}',
          const TabBarViewExample(),
          size: const Size(400, 480),
          brightness: brightness,
          act: (tester, name) async {
            await capture(tester, '${name}_rest');
            final gesture = await tester.startGesture(const Offset(300, 300));
            await gesture.moveBy(const Offset(-40, 0));
            await gesture.moveBy(const Offset(-100, 0));
            await tester.pump();
            await capture(tester, '${name}_drag');
            await gesture.moveBy(const Offset(-80, 0));
            await tester.pump(const Duration(milliseconds: 300));
            await gesture.up();
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 48));
            await capture(tester, '${name}_settling');
            await tester.pumpAndSettle();
            await capture(tester, '${name}_done');
          },
        );
      });
    }
    testWidgets('tabs underline swipe height', (tester) async {
      await render(
        tester,
        'tabs_underline',
        const TabsUnderlineExample(),
        size: const Size(480, 300),
        act: (tester, name) async {
          await capture(tester, '${name}_rest');
          final gesture = await tester.startGesture(const Offset(240, 100));
          await gesture.moveBy(const Offset(-40, 0));
          await gesture.moveBy(const Offset(-170, 0));
          await tester.pump();
          await capture(tester, '${name}_drag');
          await gesture.up();
          await tester.pumpAndSettle();
          await capture(tester, '${name}_done');
        },
      );
    });
  }

  if (on('route')) {
    testWidgets('back swipe filmstrip', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await render(
        tester,
        'back_swipe',
        const PageRoutePushExample(),
        size: const Size(400, 520),
        act: (tester, name) async {
          await tester.tap(find.text('Push a page'));
          await tester.pumpAndSettle();
          await capture(tester, '${name}_0_pushed');
          final left = tester.getTopLeft(find.byType(Navigator).last).dx;
          final gesture = await tester.startGesture(Offset(left + 4, 300));
          await gesture.moveBy(const Offset(30, 0));
          await gesture.moveBy(const Offset(60, 0));
          await tester.pump();
          await capture(tester, '${name}_1_drag');
          await gesture.moveBy(const Offset(120, 0));
          await tester.pump();
          await capture(tester, '${name}_2_drag');
          await tester.pump(const Duration(milliseconds: 300));
          await gesture.up();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 48));
          await capture(tester, '${name}_3_leaving');
          await tester.pumpAndSettle();
          await capture(tester, '${name}_4_gone');
        },
      );
      debugDefaultTargetPlatformOverride = null;
    });
    testWidgets('predictive back', (tester) async {
      await render(
        tester,
        'predictive_back',
        const PageRoutePushExample(),
        size: const Size(400, 520),
        brightness: Brightness.dark,
        act: (tester, name) async {
          await tester.tap(find.text('Push a page'));
          await tester.pumpAndSettle();
          Future<void> send(String method, [double progress = 0]) async {
            await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              'flutter/backgesture',
              const StandardMethodCodec().encodeMethodCall(
                MethodCall(
                  method,
                  method.contains('ommit')
                      ? null
                      : <String, Object?>{
                          'touchOffset': <double>[5, 300],
                          'progress': progress,
                          'swipeEdge': 0,
                        },
                ),
              ),
              (_) {},
            );
            await tester.pump();
          }

          await send('startBackGesture');
          await send('updateBackGestureProgress', 1);
          await capture(tester, '${name}_pulled');
          await send('commitBackGesture');
          await tester.pump(const Duration(milliseconds: 60));
          await capture(tester, '${name}_leaving');
          await tester.pumpAndSettle();
        },
      );
    });
  }

  if (on('nav')) {
    for (final (brightness, style) in [
      (Brightness.light, StylePreset.finesse),
      (Brightness.dark, StylePreset.finesse),
      (Brightness.light, StylePreset.nova),
    ]) {
      final tag = '${style.name}_${brightness.name}';
      testWidgets('rail $tag', (tester) async {
        await render(
          tester,
          'rail_$tag',
          const NavigationRailBasicExample(),
          size: const Size(620, 480),
          brightness: brightness,
          style: style,
          act: (tester, name) async {
            await capture(tester, name);
            await tester.tap(find.bySemanticsLabel('Expand'));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 90));
            await capture(tester, '${name}_morph');
            await tester.pumpAndSettle();
            await capture(tester, '${name}_extended');
          },
        );
      });
      testWidgets('bottom bar labels $tag', (tester) async {
        await render(
          tester,
          'nav_labels_$tag',
          const NavigationBarLabelsExample(),
          size: const Size(420, 300),
          formFactor: FormFactor.mobile,
          brightness: brightness,
          style: style,
        );
      });
    }
    for (final (brightness, style) in [
      (Brightness.light, StylePreset.finesse),
      (Brightness.dark, StylePreset.finesse),
      (Brightness.light, StylePreset.nova),
    ]) {
      testWidgets('toolbar ${style.name} ${brightness.name}', (tester) async {
        await render(
          tester,
          'toolbar_${style.name}_${brightness.name}',
          const Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [ToolbarBasicExample(), ToolbarDockedExample()],
          ),
          size: const Size(820, 480),
          brightness: brightness,
          style: style,
        );
      });
    }
    testWidgets('list detail', (tester) async {
      await render(
        tester,
        'list_detail',
        const ListDetailLayoutBasicExample(),
        size: const Size(760, 500),
        act: (tester, name) async {
          await tester.tap(find.text('Jonas Lind'));
          await tester.pumpAndSettle();
          await capture(tester, '${name}_desktop');
          await tester.tap(find.text('Phone'));
          await tester.pumpAndSettle();
          await capture(tester, '${name}_phone_detail');
          await tester.tap(find.bySemanticsLabel('Back'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          await capture(tester, '${name}_phone_leaving');
          await tester.pumpAndSettle();
          await capture(tester, '${name}_phone_list');
        },
      );
    });
    testWidgets('scaffold layouts', (tester) async {
      await render(
        tester,
        'scaffold_layouts',
        const ScaffoldNavigationExample(),
        size: const Size(820, 560),
        act: (tester, name) async {
          await capture(tester, '${name}_desktop');
          await tester.tap(find.text('Tablet'));
          await tester.pumpAndSettle();
          await capture(tester, '${name}_tablet');
          await tester.tap(find.text('Phone'));
          await tester.pumpAndSettle();
          await capture(tester, '${name}_phone');
        },
      );
    });
  }
}
