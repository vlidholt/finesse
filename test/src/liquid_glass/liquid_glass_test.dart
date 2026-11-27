import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
import 'package:liquid_glass_widgets/widgets/shared/glass_effect.dart';
import 'package:una/src/liquid_glass/controls.dart' show LiquidGlassSliderThumb;
import 'package:una/src/liquid_glass/liquid_glass.dart'
    show
        LiquidGlassBarGroup,
        LiquidGlassScrollEdge,
        LiquidGlassSurface,
        glassThemeDataOf,
        legibleOverlaySettings,
        overlayEdgeColor,
        withoutInvisibleBlur;
import 'package:una/src/liquid_glass/menu.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// Runs [body] with Flutter reporting [platform], and puts it back.
///
/// A test has no shader filters; [shaderFilters] says whether to report
/// them anyway, as a phone's renderer (Impeller) does, or not, as the web
/// does.
Future<void> onPlatform(
  TargetPlatform platform,
  Future<void> Function() body, {
  bool shaderFilters = true,
}) async {
  debugDefaultTargetPlatformOverride = platform;
  LiquidGlass.debugHasShaderFilters = shaderFilters;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
    LiquidGlass.debugHasShaderFilters = null;
  }
}

void main() {
  group('LiquidGlass.resolve', () {
    test('auto means Liquid Glass on iOS and macOS only', () {
      for (final platform in TargetPlatform.values) {
        expect(
          LiquidGlass.resolve(mode: LiquidGlassMode.auto, platform: platform),
          platform == TargetPlatform.iOS || platform == TargetPlatform.macOS,
          reason: '$platform',
        );
        expect(
          LiquidGlass.resolve(mode: LiquidGlassMode.always, platform: platform),
          isTrue,
          reason: '$platform',
        );
        expect(
          LiquidGlass.resolve(mode: LiquidGlassMode.never, platform: platform),
          isFalse,
          reason: '$platform',
        );
      }
    });

    test('gives way to high contrast and to shaders that did not load', () {
      expect(
        LiquidGlass.resolve(
          mode: LiquidGlassMode.always,
          platform: TargetPlatform.iOS,
          highContrast: true,
        ),
        isFalse,
      );
      LiquidGlass.debugUnavailable = true;
      addTearDown(() => LiquidGlass.debugUnavailable = false);
      expect(
        LiquidGlass.resolve(
          mode: LiquidGlassMode.always,
          platform: TargetPlatform.iOS,
        ),
        isFalse,
      );
    });
  });

  group('LiquidGlassTheme', () {
    test('defaults to auto with the iOS 27 material', () {
      final theme = ThemeData();
      expect(theme.liquidGlass, const LiquidGlassTheme());
      expect(theme.liquidGlass.mode, LiquidGlassMode.auto);
      expect(theme.liquidGlass.style, GlassStyle.ios27);
    });

    test('survives copyWith and keeps theme equality', () {
      const config = LiquidGlassTheme(
        mode: LiquidGlassMode.always,
        style: GlassStyle.ios26,
        quality: GlassQuality.standard,
        light: GlassThemeSettings(blur: 8),
      );
      final theme = ThemeData(liquidGlass: config);
      expect(theme.liquidGlass, config);
      expect(ThemeData(liquidGlass: config), theme);
      expect(theme.copyWith(radius: BorderRadius.zero).liquidGlass, config);
      expect(
        theme.copyWith(liquidGlass: const LiquidGlassTheme()).liquidGlass,
        const LiquidGlassTheme(),
      );
      expect(ThemeData.lerp(ThemeData(), theme, 1)!.liquidGlass, config);
    });

    test("tints the package's glass from the scheme, once per theme", () {
      final theme = ThemeData();
      final data = glassThemeDataOf(theme);
      expect(identical(glassThemeDataOf(theme), data), isTrue);
      expect(data.style, lg.GlassStyle.ios27);
      expect(data.brightness, Brightness.light);
      final glass = data.light.settings!.glassColor!;
      expect(glass.r, theme.colorScheme.bar.r);
      expect(glass.g, theme.colorScheme.bar.g);
      expect(glass.b, theme.colorScheme.bar.b);
      expect(glass.a, lessThan(1));
      expect(data.light.glowColors!.primary, theme.colorScheme.primary);
    });

    test("lays the caller's settings over the scheme's", () {
      final data = glassThemeDataOf(
        ThemeData(
          liquidGlass: const LiquidGlassTheme(
            style: GlassStyle.ios26,
            tintFromColorScheme: false,
            dark: GlassThemeSettings(blur: 11),
          ),
        ),
      );
      expect(data.style, lg.GlassStyle.ios26);
      expect(data.dark.settings!.blur, 11);
      expect(
        data.light.settings!.glassColor,
        lg.GlassThemeVariant.ios26Light.settings!.glassColor,
      );
    });
  });

  group('components', () {
    Future<void> pump(
      WidgetTester tester,
      Widget child, {
      LiquidGlassTheme liquidGlass = const LiquidGlassTheme(),
      FormFactor formFactor = FormFactor.mobile,
    }) => pumpUna(
      tester,
      child,
      formFactor: formFactor,
      theme: ThemeData(liquidGlass: liquidGlass),
    );

    final cases = <String, (Widget, Type)>{
      'Switch': (Switch(value: true, onChanged: (_) {}), lg.GlassSwitch),
      'Slider': (Slider(value: .5, onChanged: (_) {}), LiquidGlassSliderThumb),
      'SegmentedControl': (
        SegmentedControl<int>(
          value: 0,
          onChanged: (_) {},
          segments: const [
            Segment(value: 0, label: Text('Day')),
            Segment(value: 1, label: Text('Week')),
          ],
        ),
        lg.GlassSegmentedControl,
      ),
      'BottomNavigationBar': (
        BottomNavigationBar(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          destinations: const [
            NavigationDestination(
              icon: SizedBox.square(dimension: 20),
              label: 'Home',
            ),
            NavigationDestination(
              icon: SizedBox.square(dimension: 20),
              label: 'Jobs',
            ),
          ],
        ),
        lg.GlassTabBar,
      ),
      'Glass': (
        const Glass(child: SizedBox(width: 80, height: 40)),
        lg.GlassContainer,
      ),
      'Toast': (const Toast(title: Text('Saved')), lg.GlassContainer),
      'AppBar': (
        AppBar(
          title: const Text('Title'),
          actions: [IconButton(icon: const SizedBox(), onPressed: () {})],
        ),
        LiquidGlassBarGroup,
      ),
      'SliverAppBar': (
        const SizedBox(
          height: 400,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(title: Text('Title')),
              SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        ),
        LiquidGlassScrollEdge,
      ),
    };

    for (final MapEntry(key: name, value: (widget, type)) in cases.entries) {
      testWidgets('$name draws with Liquid Glass on iOS', (tester) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await pump(tester, Center(child: widget));
          expect(find.byType(type), findsWidgets);
          expect(tester.takeException(), isNull);
        });
      });

      testWidgets('$name stays frosted on Android', (tester) async {
        await onPlatform(TargetPlatform.android, () async {
          await pump(tester, Center(child: widget));
          expect(find.byType(type), findsNothing);
        });
      });

      testWidgets('$name stays frosted under LiquidGlassMode.never', (
        tester,
      ) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await pump(
            tester,
            Center(child: widget),
            liquidGlass: const LiquidGlassTheme(mode: LiquidGlassMode.never),
          );
          expect(find.byType(type), findsNothing);
        });
      });
    }

    testWidgets('a glass bottom bar with no action stays at the bottom', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationDestination(
                  icon: SizedBox.square(dimension: 20),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: SizedBox.square(dimension: 20),
                  label: 'Jobs',
                ),
              ],
            ),
            body: const SizedBox.expand(),
          ),
        );
        // Centred across, at its own height: a `Center` took the whole
        // slot and put the capsule mid-screen.
        final bar = tester.getRect(find.byType(lg.GlassTabBar));
        final screen = tester.getRect(find.byType(Scaffold));
        expect(bar.height, lessThan(screen.height / 3));
        expect(bar.bottom, greaterThan(screen.bottom - 60));
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('a glass slider in a short row keeps its thumb on its track', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          SizedBox(
            width: 200,
            height: 24,
            child: Center(child: Slider(value: .5, onChanged: (_) {})),
          ),
        );
        final thumb = find.byType(LiquidGlassSliderThumb);
        final row = find.byType(SizedBox).first;
        // The capsule is centred on the row, on the track.
        expect(tester.getCenter(thumb).dy, tester.getCenter(row).dy);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('a fast drag squashes the glass thumb, with room to', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        var value = .2;
        await pump(
          tester,
          Center(
            child: SizedBox(
              width: 300,
              child: StatefulBuilder(
                builder: (context, setState) => Slider(
                  value: value,
                  onChanged: (v) => setState(() => value = v),
                ),
              ),
            ),
          ),
        );
        final thumb = find.byType(LiquidGlassSliderThumb);
        Matrix4 jelly() => tester
            .widgetList<Transform>(
              find.descendant(of: thumb, matching: find.byType(Transform)),
            )
            .first
            .transform;
        final gesture = await tester.startGesture(tester.getCenter(thumb));
        for (var i = 0; i < 6; i++) {
          await gesture.moveBy(const Offset(30, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        // The package's jelly: narrower along the track, taller across it.
        expect(jelly().storage[0], lessThan(1));
        expect(jelly().storage[5], greaterThan(1));
        // And the lens has room for the stretch, which the package's
        // slider gives it none of.
        final lens = tester.widget<GlassEffect>(
          find.descendant(of: thumb, matching: find.byType(GlassEffect)),
        );
        expect(lens.clipExpansion.vertical, greaterThan(0));
        await gesture.up();
        await tester.pump(const Duration(seconds: 1));
      });
    });

    testWidgets('a component theme overrides the theme', (tester) async {
      await onPlatform(TargetPlatform.android, () async {
        await pumpUna(
          tester,
          Center(child: Switch(value: true, onChanged: (_) {})),
          theme: ThemeData(
            switchTheme: const SwitchTheme(liquidGlass: LiquidGlassMode.always),
          ),
        );
        expect(find.byType(lg.GlassSwitch), findsOneWidget);
      });
      await onPlatform(TargetPlatform.iOS, () async {
        await pumpUna(
          tester,
          Center(child: Switch(value: true, onChanged: (_) {})),
          theme: ThemeData(
            switchTheme: const SwitchTheme(liquidGlass: LiquidGlassMode.never),
          ),
        );
        expect(find.byType(lg.GlassSwitch), findsNothing);
      });
    });

    testWidgets('gives way to high contrast', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: UnaApp(
              home: Center(child: Switch(value: true, onChanged: (_) {})),
            ),
          ),
        );
        expect(find.byType(lg.GlassSwitch), findsNothing);
      });
    });

    testWidgets('the app bar blurs the scroll edge and groups its actions', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          Column(
            children: [
              AppBar(
                title: const Text('Title'),
                actions: [
                  IconButton(icon: const SizedBox(), onPressed: () {}),
                  IconButton(icon: const SizedBox(), onPressed: () {}),
                ],
              ),
            ],
          ),
        );
        expect(find.byType(LiquidGlassScrollEdge), findsOneWidget);
        // At the top of the page nothing is under the bar, and the edge
        // waits for content to scroll beneath it.
        expect(
          find.descendant(
            of: find.byType(LiquidGlassScrollEdge),
            matching: find.byType(BackdropFilter),
          ),
          findsNothing,
        );
        // Both actions share one capsule.
        expect(find.byType(LiquidGlassBarGroup), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(LiquidGlassBarGroup),
            matching: find.byType(IconButton),
          ),
          findsNWidgets(2),
        );
      });
    });

    testWidgets('the bottom bar puts its action beside the tabs', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              selectedIndex: 1,
              onDestinationSelected: (_) {},
              action: NavigationAction(
                icon: const SizedBox.square(dimension: 20),
                label: 'Compose',
                onPressed: () {},
              ),
              destinations: const [
                NavigationDestination(icon: SizedBox(), label: 'Home'),
                NavigationDestination(icon: SizedBox(), label: 'Jobs'),
                NavigationDestination(icon: SizedBox(), label: 'Me'),
              ],
            ),
          ),
        );
        final bar = tester.widget<lg.GlassTabBar>(find.byType(lg.GlassTabBar));
        expect(bar.tabs, hasLength(3));
        expect(bar.selectedIndex, 1);
        expect(bar.extraButton, isNotNull);
        expect(bar.extraButton!.label, 'Compose');
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('a bar with nothing selected keeps the glass, with no lens', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          Center(
            child: BottomNavigationBar(
              selectedIndex: null,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationDestination(icon: SizedBox(), label: 'Home'),
                NavigationDestination(icon: SizedBox(), label: 'Jobs'),
              ],
            ),
          ),
        );
        final bar = tester.widget<lg.GlassTabBar>(find.byType(lg.GlassTabBar));
        expect(bar.showIndicator, isFalse);
      });
    });

    testWidgets('the tabs keep their own width; the action takes the end', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        Widget bottomBar({NavigationAction? action}) => Align(
          alignment: Alignment.bottomCenter,
          child: BottomNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
            action: action,
            destinations: const [
              NavigationDestination(icon: SizedBox(), label: 'Home'),
              NavigationDestination(icon: SizedBox(), label: 'Jobs'),
            ],
          ),
        );
        await pump(
          tester,
          bottomBar(
            action: NavigationAction(
              icon: const SizedBox(),
              label: 'Compose',
              onPressed: () {},
            ),
          ),
        );
        final bar = tester.widget<lg.GlassTabBar>(find.byType(lg.GlassTabBar));
        expect(bar.tabWidth, isNotNull);
        // Two tabs on a phone leave room: they are not stretched to it.
        final screen = tester.getSize(find.byType(lg.GlassTabBar));
        expect(bar.tabWidth! * 2, lessThan(screen.width / 2));

        // Without an action the capsule is centred.
        await pump(tester, bottomBar());
        final rect = tester.getRect(find.byType(lg.GlassTabBar));
        final window = tester.view.physicalSize / tester.view.devicePixelRatio;
        expect(rect.center.dx, closeTo(window.width / 2, 1));
        expect(rect.width, lessThan(window.width / 2));
      });
    });

    testWidgets('a glass bar with no status bar keeps a margin above it', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          const Column(children: [AppBar(title: Text('Title'))]),
        );
        // The test window has no status bar.
        final bar = tester.getRect(find.byType(AppBar));
        final title = tester.getRect(find.text('Title'));
        final frosted = AppBar.heightOf(tester.element(find.byType(AppBar)));
        expect(bar.height, frosted);
        expect(bar.height, greaterThan(44 + 1));
        expect(title.top, greaterThan(bar.top + 8));
      });
    });

    testWidgets('a switch is the same size frosted and liquid', (tester) async {
      Future<Size> sizeOn(TargetPlatform platform, Type type) async {
        late Size size;
        await onPlatform(platform, () async {
          await pump(
            tester,
            Center(child: Switch(value: true, onChanged: (_) {})),
          );
          size = tester.getSize(find.byType(type).first);
        });
        await tester.pumpWidget(const SizedBox.shrink());
        return size;
      }

      final liquid = await sizeOn(TargetPlatform.iOS, lg.GlassSwitch);
      final frosted = await sizeOn(TargetPlatform.android, Switch);
      expect(liquid, const Size(58, 26));
      expect(frosted, const Size(58, 26));
    });

    testWidgets('Glass lays its content out the same frosted and liquid', (
      tester,
    ) async {
      const content = Key('content');
      Future<(Rect, Rect)> rectsOn(TargetPlatform platform) async {
        late (Rect, Rect) rects;
        await onPlatform(platform, () async {
          await pump(
            tester,
            const Center(
              child: Glass(
                padding: EdgeInsets.all(12),
                child: SizedBox(key: content, width: 80, height: 40),
              ),
            ),
          );
          rects = (
            tester.getRect(find.byType(Glass)),
            tester.getRect(find.byKey(content)),
          );
        });
        await tester.pumpWidget(const SizedBox.shrink());
        return rects;
      }

      final liquid = await rectsOn(TargetPlatform.iOS);
      final frosted = await rectsOn(TargetPlatform.android);
      expect(liquid, frosted);
    });

    testWidgets('a switch on glass still toggles', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        var value = false;
        await pump(
          tester,
          Center(
            child: StatefulBuilder(
              builder: (context, setState) => Switch(
                value: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(lg.GlassSwitch));
        await tester.pump(const Duration(milliseconds: 500));
        expect(value, isTrue);
      });
    });

    for (final formFactor in [FormFactor.desktop, FormFactor.mobile]) {
      for (final expand in [false, true]) {
        testWidgets('a glass segment with an icon and a label fits the '
            'control (${formFactor.name}${expand ? ', expanded' : ''})', (
          tester,
        ) async {
          await onPlatform(TargetPlatform.iOS, () async {
            await pump(
              tester,
              Center(
                child: SizedBox(
                  width: expand ? 320 : null,
                  child: SegmentedControl<int>(
                    value: 0,
                    expand: expand,
                    onChanged: (_) {},
                    segments: const [
                      Segment(
                        value: 0,
                        icon: SizedBox.square(key: Key('icon0'), dimension: 16),
                        label: Text('Day'),
                      ),
                      Segment(
                        value: 1,
                        icon: SizedBox.square(key: Key('icon1'), dimension: 16),
                        label: Text('Week'),
                      ),
                    ],
                  ),
                ),
              ),
              formFactor: formFactor,
            );
            // The package stacked the icon over the label, which spilled
            // out of a control one line high (a RenderFlex overflow).
            expect(tester.takeException(), isNull);
            final control = tester.getRect(
              find.byType(lg.GlassSegmentedControl),
            );
            for (final (i, label) in ['Day', 'Week'].indexed) {
              final icon = tester.getRect(find.byKey(Key('icon$i')));
              final text = tester.getRect(find.text(label));
              // Side by side, on one line, inside the control.
              expect(icon.right, lessThanOrEqualTo(text.left));
              expect(icon.center.dy, moreOrLessEquals(text.center.dy));
              expect(control.contains(text.topLeft), isTrue);
              expect(control.contains(text.bottomRight), isTrue);
            }
            // The segment is still named for a screen reader.
            final glass = tester.widget<lg.GlassSegmentedControl>(
              find.byType(lg.GlassSegmentedControl),
            );
            expect(glass.segments.map((s) => s.semanticLabel), [
              'Day',
              'Week',
            ]);
          });
        });
      }
    }

    testWidgets('Glass keeps the tint of its level, its blur and its '
        'saturation on Liquid Glass', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Glass(child: SizedBox(width: 80, height: 40)),
                Glass(
                  level: GlassLevel.strong,
                  child: SizedBox(width: 80, height: 40),
                ),
              ],
            ),
          ),
        );
        final theme = Theme.of(tester.element(find.byType(Column)));
        final glass = theme.glassTheme;
        final card = glass.color ?? theme.colorScheme.card;
        // Left to the iOS presets, both levels were the same clear glass,
        // and off Impeller (the web) not blurred at all: nothing like the
        // frosted surface, and text on it unreadable over a photograph.
        final surfaces = tester
            .widgetList<LiquidGlassSurface>(find.byType(LiquidGlassSurface))
            .toList();
        expect(surfaces.map((s) => s.tint), [
          card.withValues(alpha: card.a * glass.opacity!),
          card.withValues(alpha: card.a * glass.strongOpacity!),
        ]);
        for (final surface in surfaces) {
          expect(surface.blur, glass.blur);
          expect(surface.saturation, glass.saturation);
        }
        final containers = tester
            .widgetList<lg.GlassContainer>(find.byType(lg.GlassContainer))
            .toList();
        for (final (i, container) in containers.indexed) {
          expect(container.settings!.glassColor, surfaces[i].tint);
          expect(container.settings!.blur, greaterThanOrEqualTo(glass.blur!));
        }
      });
    });

    testWidgets('a segmented control on glass reports its value', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        int? chosen;
        await pump(
          tester,
          Center(
            child: SegmentedControl<int>(
              value: 0,
              onChanged: (value) => chosen = value,
              segments: const [
                Segment(value: 0, label: Text('Day')),
                Segment(value: 1, label: Text('Week')),
              ],
            ),
          ),
        );
        final control = tester.widget<lg.GlassSegmentedControl>(
          find.byType(lg.GlassSegmentedControl),
        );
        expect(control.segments.map((s) => s.label), ['Day', 'Week']);
        control.onSegmentSelected(1);
        expect(chosen, 1);
      });
    });
    testWidgets('a desktop app bar is solid unless its theme says always', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.macOS, () async {
        Widget bar() => Column(
          children: [
            AppBar(
              title: const Text('Title'),
              actions: [IconButton(icon: const SizedBox(), onPressed: () {})],
            ),
          ],
        );
        await pump(tester, bar(), formFactor: FormFactor.desktop);
        expect(find.byType(LiquidGlassScrollEdge), findsNothing);
        expect(find.byType(LiquidGlassBarGroup), findsNothing);

        await pumpUna(
          tester,
          bar(),
          theme: ThemeData(
            appBarTheme: const AppBarTheme(liquidGlass: LiquidGlassMode.always),
          ),
        );
        expect(find.byType(LiquidGlassScrollEdge), findsOneWidget);
      });
    });

    testWidgets('a logo stands bare; a leading button gets a capsule', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          const Column(
            children: [AppBar(leading: Text('logo'), title: Text('Title'))],
          ),
        );
        expect(find.byType(LiquidGlassBarGroup), findsNothing);

        await pump(
          tester,
          Column(
            children: [
              AppBar(
                leading: IconButton(icon: const SizedBox(), onPressed: () {}),
                title: const Text('Title'),
              ),
            ],
          ),
        );
        expect(find.byType(LiquidGlassBarGroup), findsOneWidget);
      });
    });

    testWidgets('a bar on glass draws no hairline of its own', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          const Column(children: [AppBar(title: Text('Title'))]),
        );
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is DecoratedBox &&
                  w.decoration is BoxDecoration &&
                  (w.decoration as BoxDecoration).border != null,
            ),
          ),
          findsNothing,
        );
      });
    });

    testWidgets('the scroll edge is the graduated blur, below its box', (
      tester,
    ) async {
      await pump(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 50,
            child: LiquidGlassScrollEdge(color: Color(0xFFFFFFFF)),
          ),
        ),
      );
      final blur = find.byType(lg.ProgressiveBlur);
      expect(blur, findsOneWidget);
      // It covers the box and its overhang.
      expect(tester.getRect(blur).height, 50 + 24);
    });

    testWidgets('without shader filters a glass app bar is solid', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, shaderFilters: false, () async {
        await pump(
          tester,
          Column(
            children: [
              AppBar(
                title: const Text('Title'),
                actions: [
                  IconButton(icon: const SizedBox(), onPressed: () {}),
                ],
              ),
            ],
          ),
        );
        final bar = find.byType(AppBar);
        // No scroll edge, no capsules, nothing blurred behind it.
        expect(find.byType(LiquidGlassScrollEdge), findsNothing);
        expect(find.byType(LiquidGlassBarGroup), findsNothing);
        expect(
          find.descendant(of: bar, matching: find.byType(BackdropFilter)),
          findsNothing,
        );
        // The bar colour, opaque, with the bar's hairline, at rest too.
        final fills = tester
            .widgetList<Container>(
              find.descendant(of: bar, matching: find.byType(Container)),
            )
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .where((d) => d.color != null)
            .toList();
        expect(fills, hasLength(1));
        final theme = Theme.of(tester.element(bar));
        expect(
          fills.single.color,
          theme.appBarTheme.backgroundColor!.withValues(alpha: 1),
        );
        expect(fills.single.border, isNotNull);
      });
    });

    testWidgets('a solid bar is as tall as a frosted one', (tester) async {
      Future<double> heightOn({required bool shaderFilters}) async {
        var height = 0.0;
        await onPlatform(
          TargetPlatform.iOS,
          shaderFilters: shaderFilters,
          () async {
            await pump(
              tester,
              const Column(children: [AppBar(title: Text('Title'))]),
              liquidGlass: shaderFilters
                  ? const LiquidGlassTheme(mode: LiquidGlassMode.never)
                  : const LiquidGlassTheme(),
            );
            height = tester.getRect(find.byType(AppBar)).height;
          },
        );
        return height;
      }

      // The glass bar's margin above it is for its capsules; with no
      // capsules there is none.
      final frosted = await heightOn(shaderFilters: true);
      final solid = await heightOn(shaderFilters: false);
      expect(solid, frosted);
    });

    testWidgets('without shader filters a glass sliver bar is solid', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, shaderFilters: false, () async {
        await pump(
          tester,
          const SizedBox(
            height: 400,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(title: Text('Title')),
                SliverToBoxAdapter(child: SizedBox(height: 800)),
              ],
            ),
          ),
        );
        expect(find.byType(LiquidGlassScrollEdge), findsNothing);
        expect(find.byType(LiquidGlassBarGroup), findsNothing);
        expect(
          find.descendant(
            of: find.byType(SliverAppBar),
            matching: find.byType(BackdropFilter),
          ),
          findsNothing,
        );
      });
    });

    testWidgets("a docked bottom bar is the page's scroll edge, not a slab", (
      tester,
    ) async {
      Widget page() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Toolbar(
            floating: false,
            children: [IconButton(icon: const SizedBox(), onPressed: () {})],
          ),
        ],
      );
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(tester, page());
        final edge = tester.widget<LiquidGlassScrollEdge>(
          find.byType(LiquidGlassScrollEdge),
        );
        expect(edge.fromBottom, isTrue);
        expect(find.byType(LiquidGlassSurface), findsNothing);
      });
      // Without shader filters, solid with its hairline, as the top bar is.
      await onPlatform(TargetPlatform.iOS, shaderFilters: false, () async {
        await pump(tester, page());
        expect(find.byType(LiquidGlassScrollEdge), findsNothing);
        expect(find.byType(LiquidGlassSurface), findsNothing);
        expect(
          find.descendant(
            of: find.byType(Toolbar),
            matching: find.byType(BackdropFilter),
          ),
          findsNothing,
        );
      });
    });

    testWidgets('a menu on a phone morphs out of its trigger', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await pump(
          tester,
          Center(
            child: DropdownMenu(
              items: const [MenuItem(child: Text('Profile'))],
              builder: (context, controller, _) => Button(
                onPressed: controller.toggle,
                child: const Text('Account'),
              ),
            ),
          ),
        );
        expect(find.byType(LiquidGlassMorphPopover), findsOneWidget);
        expect(find.byType(lg.GlassPopover), findsOneWidget);
        await tester.tap(find.text('Account'));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Profile'), findsOneWidget);
        // A tap on a row closes it through the una controller.
        await tester.tap(find.text('Profile'));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Profile'), findsNothing);
      });
    });

    testWidgets('a desktop menu and a region menu stay una popovers', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        Widget menu() => Center(
          child: DropdownMenu(
            items: const [MenuItem(child: Text('Profile'))],
            builder: (context, controller, _) => Button(
              onPressed: controller.toggle,
              child: const Text('Account'),
            ),
          ),
        );
        await pump(tester, menu(), formFactor: FormFactor.desktop);
        expect(find.byType(LiquidGlassMorphPopover), findsNothing);

        await pump(
          tester,
          const Center(
            child: ContextMenuRegion(
              items: [MenuItem(child: Text('Copy'))],
              child: SizedBox.square(dimension: 100),
            ),
          ),
        );
        expect(find.byType(LiquidGlassMorphPopover), findsNothing);
      });
    });
  });

  group('legibility without shader filters', () {
    test('an overlay is blurred, whitened and edged', () {
      // Its rim is not darkened: a meniscus band over a light page framed
      // the rows inside it as a white block.
      final light = ThemeData();
      const preset = lg.LiquidGlassSettings(blur: .6);
      final settings = legibleOverlaySettings(preset, light);
      expect(settings.blur, light.style.glassBlur / 2);
      expect(settings.whitenStrength, greaterThan(0));
      expect(settings.edgeAbsorption, preset.edgeAbsorption);
      expect(overlayEdgeColor(light).a, greaterThan(0));

      final dark = ThemeData(brightness: Brightness.dark);
      expect(legibleOverlaySettings(preset, dark).whitenStrength, 0);
    });

    test('a blur too faint to see is dropped, not paid for', () {
      const faint = lg.GlassThemeSettings(blur: .6);
      expect(withoutInvisibleBlur(faint).blur, 0);
      const real = lg.GlassThemeSettings(blur: 8);
      expect(withoutInvisibleBlur(real).blur, 8);
      // The derived theme carries it.
      expect(glassThemeDataOf(ThemeData()).light.settings!.blur, 0);
    });
  });

  group('phone metrics', () {
    test('are close to the Liquid Glass sizes', () {
      const phone = StyleTokens.fluidMobile;
      expect(phone.appBarHeight, 44);
      expect(phone.bottomNavigationItemHeight + 2 * 6, 64);
      expect(phone.switchWidth, 58);
      expect(phone.switchHeight, 26);
      expect(phone.sliderThumbSize, 28);
    });

    test('leave the desktop style alone', () {
      expect(StyleTokens.fluid.appBarHeight, 64);
      expect(StyleTokens.fluid.switchWidth, 36);
    });
  });
}
