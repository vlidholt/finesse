import 'package:example/common/theme_editor/color_tokens.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/picker.dart';

import 'theme_fixtures.dart';

import 'package:example/common/theme_editor/style_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/una.dart';

import 'support.dart';

/// The panel on its own: pumped in a bare [UnaApp] with a host that
/// holds the configuration, so nothing here depends on the docs pages
/// or the docs browser compiling.
void main() {
  setUpAll(setUpFonts);

  /// Every section, by the title its header shows.
  const sections = [
    'LOOK',
    'COLOR',
    'FONTS',
    'SHAPE',
    'GLASS',
    'LAYOUT',
    'MENUS',
    'PREVIEW',
    'ALL SETTINGS',
  ];

  /// Every setting, by section.
  const settings = {
    'LOOK': ['Fluid', 'Crisp', 'Pebble', 'Sharp', 'Liquid Glass'],
    'COLOR': ['Color', 'Neutral', 'Primary', 'All colors'],
    'FONTS': ['Heading', 'Font'],
    'SHAPE': ['Radius', 'Focus Ring'],
    'GLASS': ['Card Opacity', 'Card Blur', 'Bar Opacity', 'Blur Strength'],
    'LAYOUT': ['Density', 'Page Margin', 'Card Padding', 'Bottom Bar'],
    'MENUS': ['Menu', 'Menu Accent'],
    'PREVIEW': ['Form Factor', 'Text Scale'],
    'ALL SETTINGS': ['Buttons', 'Fields'],
  };

  /// The sections that open folded away.
  const folded = ['GLASS', 'LAYOUT', 'MENUS', 'ALL SETTINGS'];

  late ThemeEditorConfig config;
  late int closes;

  /// Pumps the panel [docked] at its own width in a wide window, or covering
  /// a phone-sized one.
  Future<void> pumpPanel(
    WidgetTester tester, {
    bool docked = true,
    ThemeEditorConfig initial = const ThemeEditorConfig(),
    Size? size,
  }) async {
    config = initial;
    closes = 0;
    tester.view.physicalSize =
        size ?? (docked ? const Size(1200, 900) : const Size(390, 844));
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UnaApp(
        builder: (context, child) => UnaMaterial(child: child!),
        home: StatefulBuilder(
          builder: (context, setState) {
            final panel = ThemeCustomizerPanel(
              config: config,
              onChanged: (next) => setState(() => config = next),
              docked: docked,
              onClose: docked ? null : () => closes++,
            );
            return docked
                ? Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: ThemeCustomizerPanel.width,
                      child: panel,
                    ),
                  )
                : panel;
          },
        ),
      ),
    );
    await tester.pump();
  }

  Finder inPanel(Finder finder) => find.descendant(
    of: find.byType(ThemeCustomizerPanel),
    matching: finder,
  );

  /// Scrolls [finder] into the panel's viewport and taps it.
  Future<void> tapInPanel(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await settle(tester);
  }

  /// Opens every section that is folded away.
  Future<void> unfoldAll(WidgetTester tester) async {
    for (final title in folded) {
      await tapInPanel(tester, find.text(title));
    }
  }

  /// Opens the picker labelled [label] and chooses [option].
  Future<void> choose(WidgetTester tester, String label, String option) async {
    await tapInPanel(tester, find.text(label));
    await tester.tap(find.text(option).last);
    await settle(tester);
  }

  /// Lets a font load run its course.
  ///
  /// A preset or a font is applied once its faces are in. There is no
  /// network here and `testWidgets` runs on a fake clock, so the load ends
  /// the way it does offline: by giving up after its five-second timeout.
  Future<void> waitForFonts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
  }

  group('sections', () {
    testWidgets('are all listed, the finer ones folded away', (tester) async {
      await pumpPanel(tester);

      for (final title in sections) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      for (final MapEntry(key: section, value: labels) in settings.entries) {
        for (final label in labels) {
          expect(
            find.text(label),
            folded.contains(section) ? findsNothing : findsOneWidget,
            reason: '$section / $label',
          );
        }
      }
      // The defaults, as the rows show them.
      expect(find.text('Slate'), findsOneWidget);
      expect(find.text('Geist'), findsOneWidget);
      expect(find.text('Fluid'), findsOneWidget);
      // Form factor and Liquid Glass.
      expect(find.text('Auto'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('unfold to show every setting, and fold again', (tester) async {
      await pumpPanel(tester);
      await unfoldAll(tester);

      for (final labels in settings.values) {
        for (final label in labels) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
      }
      // What the editor no longer offers: light/dark and direction are
      // app-wide switches; nothing draws the chart ramp any more; there are
      // no focus-ring measurements to set, only where it is drawn.
      for (final gone in [
        'Mode',
        'Direction',
        'Chart Color',
        'Icon Library',
        'Spacing Unit',
        'Corner Radius',
      ]) {
        expect(find.text(gone), findsNothing, reason: gone);
      }

      await tapInPanel(tester, find.text('COLOR'));
      expect(find.text('Neutral'), findsNothing);
      expect(find.text('All colors'), findsNothing);
      await tapInPanel(tester, find.text('COLOR'));
      expect(find.text('Neutral'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('fits', () {
    /// Configurations chosen for their long labels and for every state a
    /// row can be in: each preset, the longest font names in both pickers,
    /// overridden sliders (which grow a reset button), a locked switch and
    /// a locked picker, and a custom configuration (a sixth tile).
    final configs = <String, ThemeEditorConfig>{
      for (final preset in ThemePreset.values) preset.label: preset.config,
      'a seed and a neutral': const ThemeEditorConfig(
        seed: Color(0xFF0EA5E9),
        neutral: Color(0xFF78716C),
      ),
      'long labels': const ThemeEditorConfig(
        fontTitle: 'Playfair Display',
        headingFontTitle: 'Instrument Serif',
        colors: ColorSchemes.ember,
        density: Density.comfortable,
        menuColor: MenuSurfaceColor.inverted,
        menuFinish: MenuSurfaceFinish.translucent,
        focusRing: FocusRingPlacement.inside,
        formFactor: EditorFormFactor.desktop,
        cardOpacity: 1,
        barOpacity: .55,
        glassBlur: 48,
        pageMarginScale: 2,
        cardPaddingScale: .5,
        bottomBarFloating: false,
        textScale: 1.6,
      ),
    };

    for (final docked in [true, false]) {
      final where = docked ? 'docked at 272' : 'covering a 390 viewport';

      testWidgets('every section without overflow, $where', (tester) async {
        for (final MapEntry(key: name, value: initial) in configs.entries) {
          await pumpPanel(tester, docked: docked, initial: initial);
          expect(
            tester.getSize(find.byType(ThemeCustomizerPanel)).width,
            docked ? ThemeCustomizerPanel.width : 390,
          );
          await unfoldAll(tester);
          expect(tester.takeException(), isNull, reason: '$name, $where');

          // Everything is there, and inside the panel's width.
          final panel = tester.getRect(find.byType(ThemeCustomizerPanel));
          for (final labels in settings.values) {
            for (final label in labels) {
              final finder = inPanel(find.text(label));
              expect(finder, findsOneWidget, reason: '$name / $label');
              final rect = tester.getRect(finder);
              expect(rect.left, greaterThanOrEqualTo(panel.left));
              expect(rect.right, lessThanOrEqualTo(panel.right));
            }
          }
          for (final label in ['Copy Theme', 'Code', 'Reset']) {
            final rect = tester.getRect(inPanel(find.text(label)));
            expect(rect.left, greaterThanOrEqualTo(panel.left), reason: label);
            expect(rect.right, lessThanOrEqualTo(panel.right), reason: label);
          }

          // Scroll the whole list past: a row that overflows only reports
          // it when it is laid out.
          final scrollable = inPanel(find.byType(Scrollable)).first;
          for (var i = 0; i < 6; i++) {
            await tester.drag(scrollable, const Offset(0, -300));
            await tester.pump();
            expect(tester.takeException(), isNull, reason: '$name, $where');
          }
          // Unmount, so the next configuration starts with fresh state.
          await tester.pumpWidget(const SizedBox());
        }
      });

      testWidgets('every picker\'s popover without overflow, $where', (
        tester,
      ) async {
        await pumpPanel(tester, docked: docked);
        await unfoldAll(tester);

        // Each picker, and an option its popover has to show. A choice of
        // two or three is a segmented control, with no popover.
        const pickers = {
          'Heading': 'Inter',
          'Font': 'Inter',
          'Radius': 'Large',
          'Density': 'Spacious',
          'Menu': 'Translucent',
        };
        final window = Offset.zero & tester.view.physicalSize;
        for (final MapEntry(key: label, value: option) in pickers.entries) {
          await tapInPanel(tester, inPanel(find.text(label)));
          expect(tester.takeException(), isNull, reason: '$label, $where');
          // The popover opened, inside the window.
          final shown = find.text(option).last;
          expect(shown, findsOneWidget, reason: '$label / $option');
          final rect = tester.getRect(shown);
          expect(
            window.contains(rect.topLeft) && window.contains(rect.bottomRight),
            isTrue,
            reason: '$label / $option at $rect, $where',
          );
          // Close it again by tapping the row.
          await tester.tap(inPanel(find.text(label)));
          await settle(tester);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a short window scrolls the settings and keeps the actions', (
      tester,
    ) async {
      await pumpPanel(tester, size: const Size(1200, 420));
      expect(tester.takeException(), isNull);
      final window = Offset.zero & tester.view.physicalSize;
      expect(window.contains(tester.getCenter(find.text('Reset'))), isTrue);
      expect(
        window.contains(tester.getCenter(find.text('Copy Theme'))),
        isTrue,
      );
    });
  });

  group('chrome', () {
    testWidgets('is fixed and dark, whatever theme it is editing', (
      tester,
    ) async {
      await pumpPanel(tester);
      final scroll = tester.element(inPanel(find.byType(Scrollable)).first);
      final chrome = Theme.of(scroll);
      expect(chrome.brightness, Brightness.dark);
      expect(chrome.colorScheme, const GraphiteColorScheme.dark());
      expect(chrome.style, StyleTokens.crisp);
      expect(MediaQuery.textScalerOf(scroll), TextScaler.noScaling);

      // Editing changes the configuration, not the panel.
      await tapInPanel(tester, inPanel(find.text('Sharp')));
      expect(config.style, StylePreset.sharp);
      expect(
        Theme.of(tester.element(inPanel(find.byType(Scrollable)).first)),
        chrome,
      );
    });

    testWidgets('docked, it has no close button', (tester) async {
      await pumpPanel(tester);
      expect(find.text('Theme editor'), findsNothing);
      expect(find.byIcon(PhosphorIconsRegular.x), findsNothing);
    });

    testWidgets('covering a narrow viewport, it closes itself and has '
        'touch-sized controls', (tester) async {
      await pumpPanel(tester, docked: false);
      expect(find.text('Theme editor'), findsOneWidget);

      final close = find.byIcon(PhosphorIconsRegular.x);
      expect(close, findsOneWidget);
      final button = find.ancestor(
        of: close,
        matching: find.byType(IconButton),
      );
      expect(tester.getSize(button).shortestSide, greaterThanOrEqualTo(44));
      // A section header is a full touch target too.
      expect(
        Theme.of(tester.element(find.text('GLASS'))).formFactor,
        FormFactor.mobile,
      );

      await tester.tap(close);
      await tester.pump();
      expect(closes, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('the look and the colours', () {
    testWidgets('the four looks are offered, the current one selected, and '
        'a tap picks one', (tester) async {
      await pumpPanel(tester);
      for (final style in StylePreset.values) {
        expect(inPanel(find.text(style.label)), findsOneWidget);
      }
      expect(
        tester.getSemantics(inPanel(find.text('Fluid'))),
        isSemantics(isSelected: true, hasSelectedState: true, isButton: true),
      );
      await tapInPanel(tester, inPanel(find.text('Pebble')));
      expect(config.style, StylePreset.pebble);
      expect(
        tester.getSemantics(inPanel(find.text('Pebble'))),
        isSemantics(isSelected: true, hasSelectedState: true, isButton: true),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Liquid Glass is in view as the panel opens', (tester) async {
      await pumpPanel(tester);
      final row = inPanel(find.text('Liquid Glass'));
      expect(row, findsOneWidget);
      expect(
        tester.getRect(row).bottom,
        lessThan(tester.getRect(find.byType(ThemeCustomizerPanel)).height / 2),
      );
      await tapInPanel(tester, inPanel(find.text('On')));
      expect(config.liquidGlass, EditorLiquidGlass.on);
    });

    testWidgets('the colour reads its palette by name, and resets to the '
        'default', (tester) async {
      await pumpPanel(
        tester,
        initial: ColorPalette.forest.applyTo(const ThemeEditorConfig()),
      );
      expect(inPanel(find.text('Forest')), findsOneWidget);
      // The colour row's button, above the Radius row's own "Default".
      await tapInPanel(tester, inPanel(find.text('Default')).first);
      expect(config.colors, ColorSchemes.slate);
      expect(config.seed, isNull);
    });

    testWidgets('the neutral follows the colour until one is picked, and '
        'clears back', (tester) async {
      await pumpPanel(tester);
      expect(inPanel(find.text('Follows the color')), findsOneWidget);

      await pumpPanel(
        tester,
        initial: ThemeEditorConfig(neutral: NeutralPreset.stone.color),
      );
      expect(inPanel(find.text('Stone')), findsOneWidget);
      await tapInPanel(tester, inPanel(find.text('Clear')).first);
      expect(config.neutral, isNull);
    });

    testWidgets('Reset returns to the package default', (tester) async {
      await pumpPanel(
        tester,
        initial: const ThemeEditorConfig(
          style: StylePreset.sharp,
          seed: Color(0xFFDB2777),
          formFactor: EditorFormFactor.mobile,
        ),
      );
      await tapInPanel(tester, find.text('Reset').last);
      expect(config, const ThemeEditorConfig());
    });
  });

  group('controls', () {
    testWidgets('a choice of two or three is a segmented control, every '
        'option in view', (tester) async {
      await pumpPanel(tester);
      await unfoldAll(tester);

      const rows = {
        'Focus Ring': ['Outside', 'Inside'],
        'Bottom Bar': ['Floating', 'Docked'],
        'Menu Accent': ['Subtle', 'Bold'],
        'Form Factor': ['Auto', 'Desktop', 'Mobile'],
      };
      for (final MapEntry(key: label, value: options) in rows.entries) {
        final row = find.ancestor(
          of: find.text(label),
          matching: find.byWidgetPredicate((w) => w is ThemeSegments),
        );
        expect(row, findsOneWidget, reason: label);
        final control = find.descendant(
          of: row,
          matching: find.byWidgetPredicate((w) => w is SegmentedControl),
        );
        expect(control, findsOneWidget, reason: label);
        for (final option in options) {
          expect(
            find.descendant(of: control, matching: find.text(option)),
            findsOneWidget,
            reason: '$label / $option',
          );
        }
      }

      // One tap sets it.
      await tapInPanel(tester, find.text('Inside'));
      expect(config.focusRing, FocusRingPlacement.inside);
      await tapInPanel(tester, find.text('Mobile'));
      expect(config.formFactor, EditorFormFactor.mobile);
      await tapInPanel(tester, find.text('Bold'));
      expect(config.menuAccent, EditorMenuAccent.bold);

      // The accent has no effect on a translucent menu, and says so.
      await choose(tester, 'Menu', 'Translucent');
      final accent = find.descendant(
        of: find.ancestor(
          of: find.text('Menu Accent'),
          matching: find.byWidgetPredicate((w) => w is ThemeSegments),
        ),
        matching: find.byWidgetPredicate((w) => w is SegmentedControl),
      );
      expect(
        (tester.widget(accent) as SegmentedControl<EditorMenuAccent>).enabled,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('sliders are the package\'s, with the value in a bubble '
        'while dragged', (tester) async {
      await pumpPanel(tester);
      final slider = find.descendant(
        of: find.ancestor(
          of: find.text('Text Scale'),
          matching: find.byType(ThemeSlider),
        ),
        matching: find.byType(Slider),
      );
      expect(slider, findsOneWidget);
      final widget = tester.widget<Slider>(slider);
      expect(widget.valueIndicator, SliderValueIndicator.whileDragging);
      expect(widget.valueLabel!(1.2), '120%');
      // One division per step, so a drag lands on a value the code can
      // write back out.
      expect(widget.divisions, 16);

      await tester.ensureVisible(slider);
      await tester.pump();
      final gesture = await tester.startGesture(tester.getCenter(slider));
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(10, 0));
        await tester.pump();
      }
      await settle(tester);
      expect(config.textScale, greaterThan(1));
      // The bubble shows what the row says.
      expect(
        find.text('${(config.textScale * 100).round()}%'),
        findsNWidgets(2),
      );
      await gesture.up();
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Card Blur is locked off while cards are opaque', (
      tester,
    ) async {
      await pumpPanel(tester, initial: ThemePreset.classic.config);
      await unfoldAll(tester);

      // Nova's cards are opaque: nothing to blur.
      await tapInPanel(tester, find.text('Card Blur'));
      expect(config.cardBlur, isNull);
      expect(config, ThemePreset.classic.config);
    });

    testWidgets('Card Blur toggles, and back on the style\'s value is no '
        'override', (tester) async {
      await pumpPanel(tester);
      await unfoldAll(tester);

      // Off in the Original preset, as in the package's default style.
      expect(config.effectiveCardBlur, isFalse);
      await tapInPanel(tester, find.text('Card Blur'));
      expect(config.cardBlur, isTrue);
      expect(config.build().cardTheme.blur, StyleTokens.fluid.glassBlur);
      await tapInPanel(tester, find.text('Card Blur'));
      expect(config.cardBlur, isNull);
      expect(config, const ThemeEditorConfig());
      expect(config.build().cardTheme.blur, 0);
    });

    testWidgets('pickers set what they are labelled', (tester) async {
      await pumpPanel(tester);
      await unfoldAll(tester);

      await choose(tester, 'Density', 'Compact');
      expect(config.density, Density.compact);
      await choose(tester, 'Focus Ring', 'Inside');
      expect(config.focusRing, FocusRingPlacement.inside);
      await choose(tester, 'Radius', 'Large');
      expect(config.radius, RadiusPreset.large);
      await choose(tester, 'Form Factor', 'Desktop');
      expect(config.formFactor, EditorFormFactor.desktop);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picking a font applies it once it has loaded', (tester) async {
      await pumpPanel(tester);

      await choose(tester, 'Font', 'Inter');
      // Still Geist while Inter loads; the row says what is coming.
      expect(config.fontTitle, 'Geist');
      expect(inPanel(find.text('Inter')), findsOneWidget);
      expect(inPanel(find.byType(Spinner)), findsOneWidget);
      await waitForFonts(tester);
      expect(config.fontTitle, 'Inter');
      expect(inPanel(find.byType(Spinner)), findsNothing);

      await choose(tester, 'Heading', 'Noto Sans');
      await waitForFonts(tester);
      expect(config.headingFontTitle, 'Noto Sans');
      // Nothing to load for this one.
      await choose(tester, 'Heading', 'Same as body');
      expect(config.headingFontTitle, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('the code', () {
    late List<String> clipboard;

    setUp(() {
      clipboard = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboard.add((call.arguments as Map)['text'] as String);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('Copy Theme copies the app snippet', (tester) async {
      await pumpPanel(tester, initial: ThemePreset.frost.config);
      await tester.tap(find.text('Copy Theme'));
      await settle(tester);

      expect(clipboard, [ThemePreset.frost.config.toAppSnippet()]);
      expect(clipboard.single, contains('StyleTokens.fluid.copyWith('));
      expect(find.text('Theme copied to clipboard'), findsOneWidget);
      // Let the toast go.
      await tester.pump(const Duration(seconds: 6));
      await settle(tester);
    });

    testWidgets('Code shows it', (tester) async {
      await pumpPanel(tester, initial: ThemePreset.classic.config);
      await tester.tap(find.text('Code'));
      await settle(tester);

      expect(find.text('Theme code'), findsOneWidget);
      expect(
        find.text(ThemePreset.classic.config.toAppSnippet()),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Copy'));
      await settle(tester);
      expect(clipboard, [ThemePreset.classic.config.toAppSnippet()]);
      expect(find.text('Theme code'), findsNothing);
    });
  });

  group('the long lists', () {
    testWidgets('a colour group opens to its tokens, and a pinned one can be '
        'reset', (tester) async {
      await pumpPanel(tester);
      expect(find.text('Primary foreground'), findsNothing);
      await tapInPanel(tester, inPanel(find.text('All colors')));
      await tapInPanel(tester, inPanel(find.text('Brand')));
      expect(find.text('Primary foreground'), findsOneWidget);
      expect(inPanel(find.byType(ColorPickerButton)), findsWidgets);

      // Picked by hand (as the picker would report it), the row shows its
      // hex and a reset button.
      final primary = ColorToken.byName('primary');
      config = config.withColor(
        primary,
        Brightness.light,
        const Color(0xFFDB2777),
      );
      // A fresh panel, so the group starts folded again.
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpPanel(tester, initial: config);
      // Primary is one of the colours in view without unfolding.
      expect(find.text('#DB2777'), findsOneWidget);
      await tapInPanel(tester, find.bySemanticsLabel('Reset Primary'));
      expect(config.lightColors.isEmpty, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('All settings searches every style field and edits one', (
      tester,
    ) async {
      await pumpPanel(tester);
      await tapInPanel(tester, find.text('ALL SETTINGS'));
      for (final group in StyleFieldGroup.values) {
        expect(find.text(group.label), findsOneWidget, reason: group.label);
      }
      await tester.enterText(
        inPanel(find.byType(EditableText)).last,
        'concentric',
      );
      await settle(tester);
      expect(find.text('Concentric tabs'), findsOneWidget);
      final toggle = find.descendant(
        of: find
            .ancestor(
              of: find.text('Concentric tabs'),
              matching: find.byType(Row),
            )
            .first,
        matching: find.byType(Switch),
      );
      final before = config.styleTokens.concentricTabs;
      await tapInPanel(tester, toggle);
      expect(config.styleTokens.concentricTabs, !before);
      expect(config.styleEdits['concentricTabs'], !before);
      expect(tester.takeException(), isNull);
    });
  });
}
