import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/main.dart';
import 'package:example/screens/components_screen.dart';
import 'package:example/strand/strand_shell.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  // google_fonts downloads faces on first use; there is no network in tests,
  // so that is turned off. The API still resolves, it just falls back to the
  // default face for rendering.
  setUpAll(setUpFonts);

  group('ThemeEditorConfig', () {
    test('the default config is the package default look', () {
      const config = ThemeEditorConfig();
      expect(config.style, StylePreset.finesse);
      expect(config.baseColor, BaseColor.teal);
      expect(config.accentColor, AccentColor.base);
      expect(config.fontTitle, 'Geist');
      // The radius is left to the style, which is 10 for Finesse.
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
        expect(theme.style, StyleTokens.finesse);
        expect(theme.radius, BorderRadius.circular(10));
        expect(theme.colorScheme, packageDefault.colorScheme);
        expect(
          theme.colorScheme,
          brightness == Brightness.light
              ? const TealColorScheme.light()
              : const TealColorScheme.dark(),
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
        BaseColor.teal.scheme(Brightness.light).primary,
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
      final finesse = const ThemeEditorConfig().build();

      expect(lyra.decoration.secondaryFocusedBorder!.top!.width, 1);
      expect(finesse.decoration.secondaryFocusedBorder!.top!.width, 3);
      expect(
        finesse.decoration.secondaryFocusedBorder!.top!.color!.a,
        closeTo(StyleTokens.finesse.ringOpacity, .01),
      );
    });

    test('a style retypes the components and keeps the chosen font', () {
      final finesse = const ThemeEditorConfig().build();
      final lyra = const ThemeEditorConfig(style: StylePreset.lyra).build();

      // Lyra is the compact, monospace-flavoured style: its menu rows are
      // set a step smaller than Finesse's.
      expect(lyra.commandTheme.itemTextStyle!.fontSize, 12);
      expect(
        finesse.commandTheme.itemTextStyle!.fontSize,
        greaterThan(lyra.commandTheme.itemTextStyle!.fontSize!),
      );
      // The chosen font survives the style's typography.
      expect(
        lyra.commandTheme.itemTextStyle!.fontFamily,
        finesse.textTheme.small.fontFamily,
      );
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
      expect(lyra.cardTheme.radius, BorderRadius.zero);
      // ...and a rounded one scales the card past the control radius.
      final finesse = const ThemeEditorConfig().build();
      expect(
        finesse.cardTheme.radius!.topLeft.x,
        greaterThan(finesse.radius.topLeft.x),
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
      expect(snippet, contains('StyleTokens.finesse'));
      // The class names of the package as it is now.
      expect(snippet, isNot(contains('Shad')));
      expect(snippet, startsWith('ThemeData('));
    });

    test('the snippet names every base colour scheme that exists', () {
      for (final base in BaseColor.values) {
        final snippet = ThemeEditorConfig(baseColor: base).toDartSnippet();
        final name = '${base.name[0].toUpperCase()}${base.name.substring(1)}';
        expect(snippet, contains('const ${name}ColorScheme.light()'));
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

  /// The theme Strand is built with — what the editor is driving.
  ThemeData strandTheme(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(StrandShell)));

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

    testWidgets('shows every setting', (tester) async {
      await pump(tester);

      for (final label in [
        'Style',
        'Base Color',
        'Theme',
        'Chart Color',
        'Heading',
        'Font',
        'Radius',
        'Menu',
        'Menu Accent',
        'Text Scale',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'missing $label');
      }
      // The defaults, as the pickers show them.
      expect(find.text('Finesse'), findsOneWidget);
      expect(find.text('Teal'), findsOneWidget);
      expect(find.text('Geist'), findsOneWidget);
      // Light/dark and direction are app-wide switches, not settings this
      // panel duplicates.
      expect(find.text('Mode'), findsNothing);
      expect(find.text('Direction'), findsNothing);
      // Radius has a preset picker; the raw px sliders were noise next to it.
      expect(find.text('Spacing Unit'), findsNothing);
      expect(find.text('Corner Radius'), findsNothing);
      // One icon set ships, so the picker was a control with nothing to pick.
      expect(find.text('Icon Library'), findsNothing);
      // There are no focus-ring knobs.
      expect(find.text('Ring'), findsNothing);
      expect(find.text('Opacity'), findsNothing);
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

    testWidgets('Strand follows the app-wide theme mode', (tester) async {
      await pump(tester);
      expect(strandTheme(tester).brightness, Brightness.light);

      themeModeProvider.of(appContext(tester)).value = ThemeMode.dark;
      await settle(tester);

      expect(strandTheme(tester).brightness, Brightness.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picking a theme applies the accent scheme', (tester) async {
      await pump(tester);

      // Picked from near the top of the list: the popover scrolls, and an
      // option below the fold is found but not hit-testable.
      await choose(tester, 'Theme', 'Blue');

      expect(
        strandTheme(tester).colorScheme.primary,
        AccentScheme.blueLight.primary,
      );
    });

    testWidgets('picking a base colour changes the neutrals', (tester) async {
      await pump(tester);

      await choose(tester, 'Base Color', 'Zinc');

      expect(
        strandTheme(tester).colorScheme.background,
        const ZincColorScheme.light().background,
      );
    });

    testWidgets('chart colour is independent of the main accent', (
      tester,
    ) async {
      await pump(tester);

      await choose(tester, 'Chart Color', 'Green');

      final scheme = strandTheme(tester).colorScheme;
      expect(scheme.chart1, AccentScheme.greenLight.chart1);
      // The primary is untouched by the chart picker.
      expect(scheme.primary, isNot(AccentScheme.greenLight.primary));
    });

    testWidgets('takes over a narrow viewport', (tester) async {
      await pump(tester, size: const Size(600, 1400));

      expect(find.text('Style'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('re-themes both halves of the app', (tester) async {
      await pump(tester);

      await choose(tester, 'Base Color', 'Zinc');
      await choose(tester, 'Style', 'Lyra');

      final zinc = const ZincColorScheme.light().background;
      expect(strandTheme(tester).colorScheme.background, zinc);
      expect(strandTheme(tester).style, StyleTokens.lyra);

      // The component library is themed from the same configuration.
      await openComponentLibrary(tester);
      final docsTheme = Theme.of(
        tester.element(find.byType(ComponentsScreen)),
      );
      expect(docsTheme.colorScheme.background, zinc);
      expect(docsTheme.style, StyleTokens.lyra);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Reset returns to the package default look', (tester) async {
      await pump(tester);
      await choose(tester, 'Style', 'Nova');
      expect(strandTheme(tester).style, StyleTokens.nova);

      await tester.tap(find.text('Reset'));
      await settle(tester);
      expect(
        themeConfigProvider.of(appContext(tester)).value,
        const ThemeEditorConfig(),
      );
      expect(strandTheme(tester).style, StyleTokens.finesse);
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

      expect(
        theme.contextMenuTheme.decoration!.color,
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
      // The row highlight is the dark accent pair, icons included.
      expect(
        theme.selectOptionTheme.hoveredBackgroundColor,
        dark.colorScheme.accent,
      );
      // The page's own popover is untouched: plain popovers do not invert.
      expect(theme.popoverTheme.decoration!.color, theme.colorScheme.popover);
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
        theme.contextMenuTheme.decoration!.color,
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

    test('bold points the accent pair at the primary pair', () {
      // The reference writes `accent = primary` into the generated theme, so
      // it is a scheme transformation, and menus pick it up through their
      // normal accent highlight.
      const config = ThemeEditorConfig(menuAccent: EditorMenuAccent.bold);
      final theme = config.build();

      expect(theme.colorScheme.accent, theme.colorScheme.primary);
      expect(
        theme.colorScheme.accentForeground,
        theme.colorScheme.primaryForeground,
      );
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
      // finesse bundles no fonts, so every option, Inter included, resolves
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
