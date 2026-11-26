import 'package:example/common/app_shell.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/common/theme_editor/presets.dart';
import 'package:example/main.dart';
import 'package:example/screens/components_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'support.dart';

void main() {
  // google_fonts downloads faces on first use; there is no network in tests,
  // so that is turned off. The API still resolves, it just falls back to the
  // default face for rendering.
  setUpAll(setUpFonts);

  group('ThemeEditorConfig Liquid Glass', () {
    test('auto leaves the theme at the package default', () {
      expect(
        const ThemeEditorConfig().build().liquidGlass,
        const LiquidGlassTheme(),
      );
    });

    test('on and off force the mode on every platform', () {
      const on = ThemeEditorConfig(liquidGlass: EditorLiquidGlass.on);
      const off = ThemeEditorConfig(liquidGlass: EditorLiquidGlass.off);
      expect(on.build().liquidGlass.mode, LiquidGlassMode.always);
      expect(off.build().liquidGlass.mode, LiquidGlassMode.never);
      // A value: the same configuration builds an equal theme.
      expect(on.build(), on.build());
    });

    test('is a preview setting: kept across presets, not part of the look', () {
      const on = ThemeEditorConfig(liquidGlass: EditorLiquidGlass.on);
      expect(on.look, const ThemeEditorConfig());
      expect(ThemePreset.of(on), ThemePreset.original);
      for (final preset in ThemePreset.values) {
        expect(preset.applyTo(on).liquidGlass, EditorLiquidGlass.on);
      }
    });

    test('is exported when it is not auto', () {
      expect(
        const ThemeEditorConfig().toDartSnippet(),
        isNot(contains('liquidGlass')),
      );
      expect(
        const ThemeEditorConfig(
          liquidGlass: EditorLiquidGlass.on,
        ).toDartSnippet(),
        contains(
          'liquidGlass: const LiquidGlassTheme(mode: LiquidGlassMode.always),',
        ),
      );
    });
  });

  group('ThemeEditorConfig', () {
    test('the default config is the package default look', () {
      const config = ThemeEditorConfig();
      expect(config.style, StylePreset.una);
      expect(config.baseColor, BaseColor.blue);
      expect(config.accentColor, AccentColor.base);
      expect(config.fontTitle, 'Geist');
      // The radius is left to the style, which is 10 for Una.
      expect(config.usesStyleRadius, isTrue);
      expect(config.effectiveRadius, 10);

      // Apart from the font — the package bundles none — the editor's
      // default theme is the theme an app gets by passing nothing at all.
      for (final brightness in Brightness.values) {
        final theme = config.copyWith(brightness: brightness).build();
        final packageDefault = ThemeData(
          brightness: brightness,
          textTheme: config.textTheme,
        );
        expect(theme.style, StyleTokens.una);
        expect(theme.radius, BorderRadius.circular(10));
        expect(theme.colorScheme, packageDefault.colorScheme);
        expect(
          theme.colorScheme,
          brightness == Brightness.light
              ? const BlueColorScheme.light()
              : const BlueColorScheme.dark(),
        );
        expect(theme, packageDefault, reason: '$brightness');
      }
    });

    test('the radius follows the style until a preset is picked', () {
      expect(
        const ThemeEditorConfig(style: StylePreset.lyra).build().radius,
        ThemeData(style: StyleTokens.lyra).radius,
      );
      const medium = ThemeEditorConfig(radius: RadiusPreset.medium);
      expect(medium.usesStyleRadius, isFalse);
      expect(medium.build().radius, BorderRadius.circular(8));
    });

    test('accent re-tints primary and ring but not the neutrals', () {
      const base = ThemeEditorConfig();
      final accented = base.copyWith(accentColor: AccentColor.blue);

      expect(
        accented.colorScheme.primary,
        AccentScheme.blueLight.primary,
      );
      expect(
        accented.colorScheme.ring,
        AccentScheme.blueLight.primary,
      );
      // Neutrals are untouched — that is the whole point of separating the
      // base palette from the accent.
      expect(accented.colorScheme.background, base.colorScheme.background);
      expect(accented.colorScheme.border, base.colorScheme.border);
      expect(accented.colorScheme.muted, base.colorScheme.muted);
    });

    test('"base" accent leaves the palette alone', () {
      const config = ThemeEditorConfig(accentColor: AccentColor.base);
      expect(
        config.colorScheme.primary,
        BaseColor.blue.scheme(Brightness.light).primary,
      );
    });

    test('a custom radius overrides the preset', () {
      const config = ThemeEditorConfig(radius: RadiusPreset.large);
      expect(config.effectiveRadius, RadiusPreset.large.value);
      expect(config.copyWith(customRadius: 3).effectiveRadius, 3);
      expect(
        config
            .copyWith(customRadius: 3)
            .copyWith(clearCustomRadius: true)
            .effectiveRadius,
        RadiusPreset.large.value,
      );
    });

    test('the focus ring comes from the style, not from the editor', () {
      // There are no ring knobs; the style owns it.
      final lyra = const ThemeEditorConfig(style: StylePreset.lyra).build();
      final una = const ThemeEditorConfig().build();

      expect(lyra.decoration.secondaryFocusedBorder!.top!.width, 1);
      expect(una.decoration.secondaryFocusedBorder!.top!.width, 3);
      expect(
        una.decoration.secondaryFocusedBorder!.top!.color!.a,
        closeTo(StyleTokens.una.ringOpacity, .01),
      );
    });

    test('a style retypes the components and keeps the chosen font', () {
      final una = const ThemeEditorConfig().build();
      final lyra = const ThemeEditorConfig(style: StylePreset.lyra).build();

      // Lyra is the compact, monospace-flavoured style: its menu rows are
      // set a step smaller than Una's.
      expect(lyra.commandTheme.itemTextStyle!.fontSize, 12);
      expect(
        una.commandTheme.itemTextStyle!.fontSize,
        greaterThan(lyra.commandTheme.itemTextStyle!.fontSize!),
      );
      // The chosen font survives the style's typography, in the face for
      // the weight the style gives the row: a per-weight font has one family
      // name per weight, and the row is body text, not the medium `small`.
      final item = lyra.commandTheme.itemTextStyle!;
      expect(item.fontFamily, startsWith('Geist'));
      expect(item.fontWeight, FontWeight.w400);
      expect(item.fontFamily, lyra.textTheme.p.fontFamily);
    });

    test('every style builds, and carries its own radii and ring', () {
      expect(StylePreset.values.map((s) => s.name), [
        for (final style in StyleTokens.all) style.name,
      ]);
      for (final preset in StylePreset.values) {
        final theme = ThemeEditorConfig(style: preset).build();
        expect(theme.style, preset.tokens);
        expect(
          theme.decoration.secondaryFocusedBorder!.top!.width,
          preset.tokens.ringWidth,
        );
      }

      // Square styles really are square, all the way out to the card.
      final lyra = const ThemeEditorConfig(style: StylePreset.lyra).build();
      expect(lyra.cardTheme.borderRadius, BorderRadius.zero);
      // ...and a rounded one scales the card past the control radius.
      final una = const ThemeEditorConfig().build();
      expect(
        una.cardTheme.borderRadius!.topLeft.x,
        greaterThan(una.radius.topLeft.x),
      );
    });

    test('every base/accent/brightness combination builds', () {
      for (final brightness in Brightness.values) {
        for (final base in BaseColor.values) {
          for (final accent in AccentColor.values) {
            final theme = ThemeEditorConfig(
              brightness: brightness,
              baseColor: base,
              accentColor: accent,
            ).build();
            expect(theme.colorScheme, isNotNull);
          }
        }
      }
    });

    test('the generated snippet reflects the configuration', () {
      const config = ThemeEditorConfig(
        brightness: Brightness.dark,
        baseColor: BaseColor.zinc,
        accentColor: AccentColor.violet,
      );
      final snippet = config.toDartSnippet();

      expect(snippet, contains('Brightness.dark'));
      expect(snippet, contains('ZincColorScheme.dark()'));
      expect(snippet, contains('applyAccentScheme'));
      // Una is the package default style, so it is not spelled out…
      expect(snippet, isNot(contains('style:')));
      // …and any other is.
      expect(
        config.copyWith(style: StylePreset.maia).toDartSnippet(),
        contains('  style: StyleTokens.maia,\n'),
      );
      // The class names of the package as it is now.
      expect(snippet, isNot(contains('Shad')));
      expect(snippet, startsWith('ThemeData('));
    });

    test('the snippet names every base colour scheme that exists', () {
      for (final base in BaseColor.values) {
        final snippet = ThemeEditorConfig(baseColor: base).toDartSnippet();
        final name = '${base.name[0].toUpperCase()}${base.name.substring(1)}';
        if (base == BaseColor.blue) {
          // The package default: `ThemeData` picks it by itself.
          expect(snippet, isNot(contains('colorScheme:')));
        } else {
          expect(snippet, contains('const ${name}ColorScheme.light()'));
        }
        // …and the scheme it names is the one the config builds.
        expect(
          ThemeEditorConfig(baseColor: base).colorScheme,
          ColorScheme.fromName(base.name),
        );
      }
    });

    test('the snippet leaves the radius out while it is the style\'s', () {
      expect(
        const ThemeEditorConfig().toDartSnippet(),
        isNot(contains('radius:')),
      );
      expect(
        const ThemeEditorConfig(radius: RadiusPreset.large).toDartSnippet(),
        contains('radius: BorderRadius.circular(11.2)'),
      );
    });

    test('the snippet omits applyAccent when the accent is the base', () {
      const config = ThemeEditorConfig();
      expect(config.toDartSnippet(), isNot(contains('applyAccentScheme')));
    });
  });

  /// The theme the docs browser is built with — what the editor is driving.
  ThemeData pageTheme(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(ComponentsSection)));

  /// Lets a `RenderFlex` overflow pass for the rest of the current test,
  /// and nothing else.
  ///
  /// For the tests that re-theme the *docs pages* with settings they were
  /// not drawn for. The test font is a square per glyph — nearly twice
  /// as wide as any real face — so a label that fits its button with room
  /// to spare in Geist can miss by a pixel here once a theme changes the
  /// type size or the card padding. That is the test font's doing, in
  /// screens these tests are not about; a throw, a failed assertion or any
  /// other layout error still fails the test. The panel's own overflow is
  /// checked strictly, in `theme_editor_panel_test.dart`.
  void tolerateTextOverflow() {
    final report = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().startsWith('A RenderFlex overflowed')) {
        return;
      }
      report?.call(details);
    };
    addTearDown(() => FlutterError.onError = report);
  }

  group('the customizer panel', () {
    /// Pumps the whole app and opens the editor.
    ///
    /// The app itself is what the panel edits, so the test drives [App]
    /// rather than a page: that is the wiring under test.
    Future<void> pump(
      WidgetTester tester, {
      Size size = const Size(1600, 1400),
    }) async {
      await pumpApp(tester, size: size);
      await openThemeEditor(tester);
    }

    Finder inPanel(Finder finder) => find.descendant(
      of: find.byType(ThemeCustomizerPanel),
      matching: finder,
    );

    /// Opens the picker labelled [label] and chooses [option].
    ///
    /// The value lives inside a popover, so it has to be opened first. Fixed
    /// pumps are used throughout rather than pumpAndSettle, which never
    /// returns once a spinner or a skeleton is on screen.
    Future<void> choose(
      WidgetTester tester,
      String label,
      String option,
    ) async {
      await tester.ensureVisible(find.text(label));
      await tester.pump();
      await tester.tap(find.text(label));
      // Popover wraps its content in an IgnorePointer while the entrance
      // animation runs, so the option is not tappable until it finishes.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.tap(find.text(option).last);
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('shows the presets and every open section', (tester) async {
      await pump(tester);

      for (final preset in ThemePreset.values) {
        expect(inPanel(find.text(preset.label)), findsOneWidget);
      }
      for (final label in [
        'Base Color',
        'Accent',
        'Heading',
        'Font',
        'Style',
        'Radius',
        'Focus Ring',
        'Form Factor',
        'Text Scale',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'missing $label');
      }
      // The defaults, as the pickers show them.
      expect(find.text('Una'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Geist'), findsOneWidget);
      // Light/dark and direction are app-wide switches, not settings this
      // panel duplicates.
      expect(find.text('Mode'), findsNothing);
      expect(find.text('Direction'), findsNothing);
      // Nothing in the app draws the chart ramp any more.
      expect(find.text('Chart Color'), findsNothing);
      // One icon set ships, so the picker was a control with nothing to pick.
      expect(find.text('Icon Library'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offers exactly the styles and base colours the package has', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('Style'));
      await settle(tester);
      for (final style in StylePreset.values) {
        expect(
          find.text(style.label),
          findsWidgets,
          reason: 'missing ${style.label}',
        );
      }
      for (final gone in ['Vega', 'Mira', 'Luma', 'Sera', 'Rhea']) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      await tester.tapAt(const Offset(20, 20));
      await settle(tester);

      await tester.tap(find.text('Base Color'));
      await settle(tester);
      for (final base in BaseColor.values) {
        expect(find.text(base.label), findsWidgets, reason: base.label);
      }
      for (final gone in ['Slate', 'Gray', 'Mauve', 'Olive', 'Mist', 'Taupe']) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('the page follows the app-wide theme mode', (tester) async {
      await pump(tester);
      expect(pageTheme(tester).brightness, Brightness.light);

      themeModeProvider.of(appContext(tester)).value = ThemeMode.dark;
      await settle(tester);

      expect(pageTheme(tester).brightness, Brightness.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picking a theme applies the accent scheme', (tester) async {
      await pump(tester);

      // Picked from near the top of the list: the popover scrolls, and an
      // option below the fold is found but not hit-testable.
      await choose(tester, 'Accent', 'Blue');

      expect(
        pageTheme(tester).colorScheme.primary,
        AccentScheme.blueLight.primary,
      );
    });

    testWidgets('picking a base colour changes the neutrals', (tester) async {
      await pump(tester);

      await choose(tester, 'Base Color', 'Zinc');

      expect(
        pageTheme(tester).colorScheme.background,
        const ZincColorScheme.light().background,
      );
    });

    testWidgets('takes over a narrow viewport', (tester) async {
      await pump(tester, size: const Size(600, 1400));

      expect(find.text('Style'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('re-themes the component library', (tester) async {
      await pump(tester);

      await choose(tester, 'Base Color', 'Zinc');
      await choose(tester, 'Style', 'Lyra');

      final docsTheme = Theme.of(
        tester.element(find.byType(ComponentsScreen)),
      );
      expect(
        docsTheme.colorScheme.background,
        const ZincColorScheme.light().background,
      );
      expect(docsTheme.style, StyleTokens.lyra);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Reset returns to the package default look', (tester) async {
      await pump(tester);
      await choose(tester, 'Style', 'Nova');
      expect(pageTheme(tester).style, StyleTokens.nova);

      await tester.tap(find.text('Reset'));
      await settle(tester);
      expect(
        themeConfigProvider.of(appContext(tester)).value,
        const ThemeEditorConfig(),
      );
      expect(pageTheme(tester).style, StyleTokens.una);
    });

    testWidgets('a preset re-themes the app, and a change after it is Custom', (
      tester,
    ) async {
      await pump(tester);
      expect(inPanel(find.text('Custom')), findsNothing);

      await tester.tap(inPanel(find.text('Classic')));
      // Its font loads first; offline that ends at the load's timeout.
      await tester.pump(const Duration(seconds: 6));
      await settle(tester);

      final config = themeConfigProvider.of(appContext(tester));
      expect(ThemePreset.of(config.value), ThemePreset.classic);
      final theme = pageTheme(tester);
      expect(theme.colorScheme, const NeutralColorScheme.light());
      expect(theme.cardTheme.backgroundColor!.a, 1);
      expect(theme.bottomNavigationBarTheme.floating, isFalse);
      expect(theme.textTheme.p.fontFamily, contains('Inter'));
      expect(inPanel(find.text('Custom')), findsNothing);

      await choose(tester, 'Radius', 'Large');
      expect(ThemePreset.of(config.value), isNull);
      expect(inPanel(find.text('Custom')), findsOneWidget);
      expect(pageTheme(tester).radius, BorderRadius.circular(14 * .8));
      expect(tester.takeException(), isNull);
    });

    testWidgets('every preset themes the docs in light and dark, desktop and '
        'phone, without an error', (tester) async {
      tolerateTextOverflow();
      for (final size in [desktopSize, mobileSize]) {
        await pumpApp(tester, size: size);
        final config = themeConfigProvider.of(appContext(tester));
        final mode = themeModeProvider.of(appContext(tester));
        for (final preset in ThemePreset.values) {
          for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
            config.value = preset.config;
            mode.value = themeMode;
            await settle(tester);
            final where = '${preset.label} $themeMode at $size';
            expect(tester.takeException(), isNull, reason: where);
            final theme = pageTheme(tester);
            expect(theme.style.name, preset.config.style.name, reason: where);
            expect(
              theme.brightness,
              themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
              reason: where,
            );
            expect(
              theme.formFactor,
              size == mobileSize ? FormFactor.mobile : FormFactor.desktop,
              reason: where,
            );
          }
        }
        mode.value = ThemeMode.light;
        config.value = const ThemeEditorConfig();
        await settle(tester);
      }
    });

    testWidgets(
      'the glass and layout overrides reach the app, on a phone too',
      (
        tester,
      ) async {
        tolerateTextOverflow();
        for (final size in [desktopSize, mobileSize]) {
          await pumpApp(tester, size: size);
          final config = themeConfigProvider.of(appContext(tester));
          config.value = config.value.copyWith(
            cardOpacity: () => .5,
            cardBlur: () => true,
            barOpacity: () => .6,
            glassBlur: () => 8,
            cardPaddingScale: 1.5,
            bottomBarFloating: () => false,
          );
          // The Card page, which has cards to look at.
          tester
              .state<ComponentsScreenState>(find.byType(ComponentsScreen))
              .open('card');
          await settle(tester);

          final theme = pageTheme(tester);
          final phone = size == mobileSize;
          expect(
            theme.formFactor,
            phone ? FormFactor.mobile : FormFactor.desktop,
          );
          expect(theme.cardTheme.backgroundColor!.a, closeTo(.5, .005));
          expect(theme.appBarTheme.backgroundColor!.a, closeTo(.6, .005));
          expect(theme.cardTheme.blur, 8);
          expect(theme.appBarTheme.blur, 8);
          // And it is a real filter on screen, not only a number in the
          // theme: the cards on the page are over a backdrop.
          expect(
            find.descendant(
              of: find.byType(Card),
              matching: find.byType(BackdropFilter),
            ),
            findsWidgets,
          );
          expect(theme.cardTheme.padding, EdgeInsets.all(phone ? 24 : 30));
          expect(theme.bottomNavigationBarTheme.floating, isFalse);
          expect(tester.takeException(), isNull, reason: '$size');
        }
      },
    );
  });

  group('the form factor', () {
    Signal<ThemeEditorConfig> configOf(WidgetTester tester) =>
        themeConfigProvider.of(appContext(tester));

    Future<void> setFormFactor(
      WidgetTester tester,
      EditorFormFactor mode,
    ) async {
      configOf(tester).value = configOf(tester).value.copyWith(
        formFactor: mode,
      );
      // Past the theme's 200 ms hand-over from one layout to the other.
      await settle(tester);
    }

    ThemeData appTheme(WidgetTester tester) => Theme.of(appContext(tester));

    testWidgets('Auto follows the width', (tester) async {
      await pumpApp(tester);
      expect(configOf(tester).value.formFactor, EditorFormFactor.auto);
      expect(appTheme(tester).formFactor, FormFactor.desktop);
      expect(find.byType(Sidebar), findsOneWidget);
      expect(tester.getSize(find.byType(ComponentsSection)), desktopSize);

      await pumpApp(tester, size: mobileSize);
      expect(appTheme(tester).formFactor, FormFactor.mobile);
      // The sidebar is a sheet on a phone, closed.
      expect(find.byType(Sidebar), findsNothing);
      expect(tester.getSize(find.byType(ComponentsSection)), mobileSize);
    });

    testWidgets('Mobile shows the phone layout on a wide window, in a '
        'phone-sized frame', (tester) async {
      await pumpApp(tester);
      await setFormFactor(tester, EditorFormFactor.mobile);

      expect(appTheme(tester).formFactor, FormFactor.mobile);
      expect(pageTheme(tester).formFactor, FormFactor.mobile);
      expect(pageTheme(tester).style, StyleTokens.unaMobile);
      // The phone's chrome: the sidebar is a sheet, closed.
      expect(find.byType(Sidebar), findsNothing);
      // Laid out at a phone's size, centred in the window.
      final shell = tester.getRect(find.byType(ComponentsSection));
      expect(shell.width, AppShell.phoneFrame.width);
      expect(shell.height, AppShell.phoneFrame.height);
      expect(shell.center.dx, desktopSize.width / 2);
      expect(shell.center.dy, desktopSize.height / 2);
      // Breakpoints inside see a phone as well.
      expect(
        MediaQuery.sizeOf(tester.element(find.byType(ComponentsSection))),
        AppShell.phoneFrame,
      );
      expect(tester.takeException(), isNull);

      // Beside the docked editor the frame is centred in what is left.
      await openThemeEditor(tester);
      final docked = tester.getRect(find.byType(ComponentsSection));
      expect(docked.size, shell.size);
      expect(
        docked.center.dx,
        (desktopSize.width - ThemeCustomizerPanel.width) / 2,
      );
      expect(tester.takeException(), isNull);

      // Back to Auto: the desktop layout, at the page's full size.
      await setFormFactor(tester, EditorFormFactor.auto);
      expect(appTheme(tester).formFactor, FormFactor.desktop);
      expect(find.byType(Sidebar), findsOneWidget);
      expect(
        tester.getSize(find.byType(ComponentsSection)),
        Size(
          desktopSize.width - ThemeCustomizerPanel.width,
          desktopSize.height,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Mobile on a short window keeps a margin around the frame', (
      tester,
    ) async {
      await pumpApp(tester, size: const Size(1200, 600));
      await setFormFactor(tester, EditorFormFactor.mobile);

      final shell = tester.getRect(find.byType(ComponentsSection));
      expect(shell.width, AppShell.phoneFrame.width);
      expect(shell.height, 600 - 32);
      expect(shell.top, 16);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Mobile on a phone-sized window is just the phone', (
      tester,
    ) async {
      await pumpApp(tester, size: mobileSize);
      await setFormFactor(tester, EditorFormFactor.mobile);

      expect(appTheme(tester).formFactor, FormFactor.mobile);
      expect(tester.getSize(find.byType(ComponentsSection)), mobileSize);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Desktop shows the desktop layout on a narrow window, scaled '
        'to fit rather than overflowing', (tester) async {
      await pumpApp(tester, size: mobileSize);
      expect(find.byType(Sidebar), findsNothing);
      await setFormFactor(tester, EditorFormFactor.desktop);

      expect(appTheme(tester).formFactor, FormFactor.desktop);
      expect(pageTheme(tester).style, StyleTokens.una);
      // The desktop's sidebar, beside the page.
      expect(find.byType(Sidebar), findsOneWidget);
      // Laid out at the narrowest width a desktop layout is designed for…
      final breakpoint = appTheme(tester).breakpoints.md.value;
      final shell = find.byType(ComponentsSection);
      expect(tester.getSize(shell).width, breakpoint);
      expect(
        MediaQuery.sizeOf(tester.element(shell)).width,
        breakpoint,
      );
      // …and painted across exactly the window.
      final box = tester.renderObject<RenderBox>(shell);
      final painted = MatrixUtils.transformRect(
        box.getTransformTo(null),
        Offset.zero & box.size,
      );
      expect(painted.left, closeTo(0, .01));
      expect(painted.top, closeTo(0, .01));
      expect(painted.width, closeTo(mobileSize.width, .01));
      expect(painted.height, closeTo(mobileSize.height, .01));
      expect(tester.takeException(), isNull);

      await setFormFactor(tester, EditorFormFactor.auto);
      expect(appTheme(tester).formFactor, FormFactor.mobile);
      expect(tester.getSize(shell), mobileSize);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Desktop keeps the desktop layout beside the docked editor', (
      tester,
    ) async {
      // 900 - 272 is below the phone breakpoint: Auto would switch.
      await pumpApp(tester, size: const Size(900, 800));
      await setFormFactor(tester, EditorFormFactor.desktop);
      await openThemeEditor(tester);

      expect(appTheme(tester).formFactor, FormFactor.desktop);
      expect(find.byType(Sidebar), findsOneWidget);
      final shell = find.byType(ComponentsSection);
      expect(
        tester.getSize(shell).width,
        appTheme(tester).breakpoints.md.value,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('switching keeps the page you were on', (tester) async {
      await pumpApp(tester);
      final screen = find.byType(ComponentsScreen);
      final state = tester.state(screen);

      for (final mode in [
        EditorFormFactor.mobile,
        EditorFormFactor.desktop,
        EditorFormFactor.auto,
      ]) {
        await setFormFactor(tester, mode);
        expect(tester.state(screen), same(state), reason: '$mode');
        expect(tester.takeException(), isNull, reason: '$mode');
      }
    });

    testWidgets('the picker in the panel sets it', (tester) async {
      await pumpApp(tester);
      await openThemeEditor(tester);

      await tester.ensureVisible(find.text('Form Factor'));
      await tester.pump();
      await tester.tap(find.text('Form Factor'));
      await settle(tester);
      await tester.tap(find.text('Mobile').last);
      await settle(tester);

      expect(configOf(tester).value.formFactor, EditorFormFactor.mobile);
      expect(appTheme(tester).formFactor, FormFactor.mobile);
      expect(find.byType(Sidebar), findsNothing);
      expect(tester.takeException(), isNull);
    });

    test('the app and the shell agree on it', () {
      FormFactor at(
        double window, {
        bool editorOpen = false,
        EditorFormFactor mode = EditorFormFactor.auto,
      }) => AppShell.formFactorFor(
        window,
        editorOpen: editorOpen,
        mode: mode,
        breakpoint: 768,
      );

      expect(at(1440), FormFactor.desktop);
      expect(at(390), FormFactor.mobile);
      // The docked editor takes its width out of the page's.
      expect(at(900), FormFactor.desktop);
      expect(at(900, editorOpen: true), FormFactor.mobile);
      // Below the docking breakpoint the editor covers the page instead.
      expect(at(690, editorOpen: true), FormFactor.mobile);
      // Pinned, the width does not come into it.
      expect(at(390, mode: EditorFormFactor.desktop), FormFactor.desktop);
      expect(
        at(1440, editorOpen: true, mode: EditorFormFactor.mobile),
        FormFactor.mobile,
      );
    });
  });

  group('menu settings', () {
    // Contrast is judged against what is actually painted: a translucent
    // surface or highlight is composited before its luminance is read.
    Color composite(Color over, Color base) => Color.alphaBlend(over, base);

    test('inverted menus take the whole dark palette in light mode', () {
      // shadcn implements "Inverted" by giving menu surfaces the `dark`
      // class — every token flips, not just the surface and text.
      const config = ThemeEditorConfig(menuColor: MenuSurfaceColor.inverted);
      final theme = config.build();
      final dark = const ThemeEditorConfig(
        brightness: Brightness.dark,
      ).build();

      // The default style's menus are glass, so compare the colour under
      // the opacity.
      expect(
        theme.contextMenuTheme.decoration!.color!.withValues(alpha: 1),
        dark.colorScheme.popover,
      );
      expect(
        theme.contextMenuTheme.textStyle!.color,
        dark.colorScheme.popoverForeground,
      );
      expect(
        theme.selectOptionTheme.textStyle!.color,
        dark.colorScheme.popoverForeground,
      );
      // The row highlight is the dark menu's, icons included: in the default
      // style a wash of the dark foreground that leaves the row's text its
      // resting colour, not an accent fill.
      expect(
        theme.selectOptionTheme.hoveredBackgroundColor,
        dark.colorScheme.foreground.withValues(
          alpha: theme.style.menuHighlightOpacityDark,
        ),
      );
      expect(
        theme.selectOptionTheme.hoveredBackgroundColor,
        dark.selectOptionTheme.hoveredBackgroundColor,
      );
      expect(
        theme.selectOptionTheme.selectedTextStyle!.color,
        dark.colorScheme.popoverForeground,
      );
      // The page's own popover is untouched: plain popovers do not invert.
      expect(
        theme.popoverTheme.decoration!.color!.withValues(alpha: 1),
        theme.colorScheme.popover,
      );
    });

    test('inverted is a no-op in dark mode, as in the reference', () {
      // The reference toggles the `dark` class on menu surfaces; when the
      // page is already dark that changes nothing.
      const config = ThemeEditorConfig(
        brightness: Brightness.dark,
        menuColor: MenuSurfaceColor.inverted,
      );
      final theme = config.build();
      expect(
        theme.contextMenuTheme.decoration!.color!.withValues(alpha: 1),
        theme.colorScheme.popover,
      );
    });

    test('translucent lowers the menu surface, not the page popover', () {
      const config = ThemeEditorConfig(
        menuFinish: MenuSurfaceFinish.translucent,
      );
      final theme = config.build();
      // `bg-popover/70` behind a backdrop blur…
      expect(theme.contextMenuTheme.decoration!.color!.a, closeTo(.7, .01));
      expect(theme.selectTheme.popoverDecoration!.color!.a, closeTo(.7, .01));
      expect(theme.contextMenuTheme.filter, isNotNull);
      expect(theme.selectTheme.filter, isNotNull);
      // …with row highlights as a foreground wash so they read through.
      expect(theme.selectOptionTheme.hoveredBackgroundColor!.a, lessThan(.2));
      // The page palette itself stays opaque.
      expect(theme.colorScheme.popover.a, 1);
    });

    test('bold fills menu rows with the primary pair, and only them', () {
      // The reference writes `accent = primary` into the generated theme.
      // Here the accent is also the soft wash of a selected card, a chat
      // bubble and an icon tile, so the choice is the menus' alone and the
      // scheme keeps its accent.
      const config = ThemeEditorConfig(menuAccent: EditorMenuAccent.bold);
      final theme = config.build();
      final subtle = const ThemeEditorConfig().build();

      expect(theme.colorScheme, subtle.colorScheme);
      expect(theme.colorScheme.accent, isNot(theme.colorScheme.primary));
      expect(theme.chatBubbleTheme, subtle.chatBubbleTheme);
      expect(theme.iconTileTheme, subtle.iconTileTheme);
      expect(theme.chipTheme, subtle.chipTheme);
      expect(
        theme.selectOptionTheme.hoveredBackgroundColor,
        theme.colorScheme.primary,
      );
      expect(
        theme.selectOptionTheme.selectedTextStyle!.color,
        theme.colorScheme.primaryForeground,
      );
      expect(
        theme.selectOptionTheme.textStyle!.color,
        theme.colorScheme.popoverForeground,
      );
    });

    test('every mode reads correctly in both brightnesses', () {
      // Walks the whole matrix — brightness x surface x finish x accent — and
      // checks the states a menu row can be in. Guessing at one combination
      // is what kept breaking the others.
      for (final brightness in Brightness.values) {
        for (final color in MenuSurfaceColor.values) {
          for (final finish in MenuSurfaceFinish.values) {
            for (final accent in EditorMenuAccent.values) {
              final config = ThemeEditorConfig(
                brightness: brightness,
                menuColor: color,
                menuFinish: finish,
                menuAccent: accent,
              );
              final theme = config.build();
              final where = '$brightness/$color/$finish/$accent';

              final surface = composite(
                theme.contextMenuTheme.decoration!.color!,
                theme.colorScheme.background,
              );

              double contrast(Color a, Color b) =>
                  (a.computeLuminance() - b.computeLuminance()).abs();

              // Resting row.
              expect(
                contrast(theme.selectOptionTheme.textStyle!.color!, surface),
                greaterThan(.2),
                reason: 'resting row unreadable: $where',
              );
              // Hovered row: the option and the context menu use the same
              // pair, so a menu cannot change colour halfway down.
              final highlight = theme.selectOptionTheme.hoveredBackgroundColor!;
              expect(
                theme.contextMenuTheme.selectedBackgroundColor,
                highlight,
                reason: 'context menu != select: $where',
              );
              final paintedHighlight = composite(highlight, surface);
              expect(
                contrast(
                  theme.selectOptionTheme.selectedTextStyle!.color!,
                  paintedHighlight,
                ),
                greaterThan(.2),
                reason: 'highlighted row unreadable: $where',
              );
              expect(
                contrast(
                  theme.contextMenuTheme.selectedTextStyle!.color!,
                  paintedHighlight,
                ),
                greaterThan(.2),
                reason: 'highlighted menu item unreadable: $where',
              );
              // And the highlight is distinguishable from the surface. The
              // reference's dark accent really is a near-black on near-black
              // wash, so the bar here is visibility, not drama.
              expect(
                contrast(paintedHighlight, surface),
                greaterThan(.005),
                reason: 'highlight invisible: $where',
              );
            }
          }
        }
      }
    });
  });

  group('fonts', () {
    test('every shadcn font is offered', () {
      expect(EditorFont.all.length, greaterThanOrEqualTo(26));
      expect(EditorFont.all.map((f) => f.title), contains('Inter'));
      expect(EditorFont.all.map((f) => f.title), contains('Playfair Display'));
    });

    test('every font comes from Google Fonts through a cached builder', () {
      // una bundles no fonts, so every option, Inter included, resolves
      // through google_fonts.
      for (final font in EditorFont.all) {
        expect(
          font.textTheme().googleFontBuilder,
          isNotNull,
          reason: font.title,
        );
      }
      // The builder and theme are cached: a fresh closure per access would
      // make ThemeData unequal to itself.
      final inter = EditorFont.byTitle('Inter');
      expect(identical(inter.builder, inter.builder), isTrue);
      expect(identical(inter.textTheme(), inter.textTheme()), isTrue);
    });

    test('load completes when runtime fetching is disabled', () async {
      await EditorFont.byTitle('Roboto').load(
        timeout: const Duration(milliseconds: 200),
      );
    });

    test('the heading font overrides only h1..h4', () {
      const config = ThemeEditorConfig(
        fontTitle: 'Geist',
        headingFontTitle: 'Playfair Display',
      );
      final text = config.textTheme;
      // Headings take the heading face...
      expect(text.h1.fontFamily, isNot(text.p.fontFamily));
      // ...body styles keep the body face.
      expect(text.p.fontFamily, contains('Geist'));
      expect(text.small.fontFamily, contains('Geist'));
    });

    test('"same as body" leaves the text theme alone', () {
      const config = ThemeEditorConfig(fontTitle: 'Geist');
      // google_fonts registers one family per weight (`Geist_800`), so compare
      // the family the weights belong to.
      String base(TextStyle s) => s.fontFamily!.split('_').first;
      expect(base(config.textTheme.h1), base(config.textTheme.p));
    });

    test('picking a font changes the theme text', () {
      const geist = ThemeEditorConfig();
      const inter = ThemeEditorConfig(fontTitle: 'Inter');
      expect(inter.textTheme.family, isNot(geist.textTheme.family));
    });
  });
}
