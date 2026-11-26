import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:example/common/theme_editor/presets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:una/una.dart';

import 'support.dart';

/// The WCAG contrast ratio between two opaque colours, from 1 to 21.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + .05) / (darker + .05);
}

void main() {
  setUpAll(setUpFonts);

  group('the presets', () {
    test('are Original, a classic, a soft and a sharp one, and more', () {
      expect(ThemePreset.values.length, greaterThanOrEqualTo(4));
      expect(ThemePreset.values.first, ThemePreset.original);
      // One word each.
      for (final preset in ThemePreset.values) {
        expect(preset.label, matches(RegExp(r'^[A-Z][a-z]+$')));
      }

      // Original is the package default look.
      expect(ThemePreset.original.config, const ThemeEditorConfig());

      // The classic shadcn look: Nova on neutral in Inter, opaque cards.
      final classic = ThemePreset.classic.config;
      expect(classic.style, StylePreset.nova);
      expect(classic.baseColor, BaseColor.neutral);
      expect(classic.fontTitle, 'Inter');
      expect(classic.build().cardTheme.backgroundColor!.a, 1);
      expect(classic.build().cardTheme.blur, 0);

      // The soft one: Maia on a warm base with a colourful accent.
      final bloom = ThemePreset.bloom.config;
      expect(bloom.style, StylePreset.maia);
      expect(bloom.baseColor, BaseColor.stone);
      expect(bloom.accentColor, isNot(AccentColor.base));
      expect(
        bloom.build().radius.topLeft.x,
        greaterThan(ThemeData(style: StyleTokens.maia).radius.topLeft.x),
      );

      // The sharp one: Lyra, square all the way out, serif and mono.
      final press = ThemePreset.press.config;
      expect(press.style, StylePreset.lyra);
      expect(press.baseColor, BaseColor.zinc);
      expect(press.build().radius, BorderRadius.zero);
      expect(press.build().cardTheme.borderRadius, BorderRadius.zero);
      expect(press.font.category, FontCategory.mono);
      expect(press.headingFont!.category, FontCategory.serif);
    });

    test('use only fonts the editor offers', () {
      final titles = EditorFont.all.map((f) => f.title).toSet();
      for (final preset in ThemePreset.values) {
        expect(titles, contains(preset.config.fontTitle), reason: preset.label);
        final heading = preset.config.headingFontTitle;
        if (heading != null) {
          expect(titles, contains(heading), reason: preset.label);
        }
      }
    });

    test('look clearly different from one another', () {
      // No two share a style *and* a base colour, and no two share a font:
      // each differs from every other in shape or palette, and in type.
      final presets = ThemePreset.values;
      for (var i = 0; i < presets.length; i++) {
        for (var j = i + 1; j < presets.length; j++) {
          final a = presets[i].config;
          final b = presets[j].config;
          final where = '${presets[i].label} / ${presets[j].label}';
          expect(
            a.style != b.style || a.baseColor != b.baseColor,
            isTrue,
            reason: where,
          );
          expect(a.fontTitle, isNot(b.fontTitle), reason: where);
          expect(
            a.build().colorScheme.primary,
            isNot(b.build().colorScheme.primary),
            reason: where,
          );
        }
      }
    });

    test('build light and dark, on both form factors, with readable text', () {
      for (final preset in ThemePreset.values) {
        for (final brightness in Brightness.values) {
          for (final formFactor in FormFactor.values) {
            final where = '${preset.label} $brightness $formFactor';
            final theme = preset.config
                .copyWith(brightness: brightness)
                .build()
                .withFormFactor(formFactor);
            final colors = theme.colorScheme;

            expect(theme.brightness, brightness, reason: where);
            expect(theme.formFactor, formFactor, reason: where);

            // Body text on the page.
            expect(
              contrast(colors.foreground, colors.background),
              greaterThanOrEqualTo(4.5),
              reason: 'foreground on background: $where',
            );
            // Body text on a card. A translucent card is judged as it is
            // painted: its fill over the page.
            final card = Color.alphaBlend(
              theme.cardTheme.backgroundColor!,
              colors.background,
            );
            expect(
              contrast(colors.cardForeground, card),
              greaterThanOrEqualTo(4.5),
              reason: 'card foreground on card: $where',
            );
            expect(
              contrast(colors.foreground, card),
              greaterThanOrEqualTo(4.5),
              reason: 'foreground on card: $where',
            );
            // Secondary text has to hold on both too.
            expect(
              contrast(colors.mutedForeground, colors.background),
              greaterThanOrEqualTo(3),
              reason: 'muted foreground on background: $where',
            );
            // A primary button's label.
            expect(
              contrast(colors.primaryForeground, colors.primary),
              greaterThanOrEqualTo(3),
              reason: 'primary foreground on primary: $where',
            );
            // The brand tint draws straight on surfaces: the selected
            // navigation icon, links.
            expect(
              contrast(colors.tint, colors.background),
              greaterThanOrEqualTo(3),
              reason: 'tint on background: $where',
            );
            // The bars: their foreground on their own (maybe translucent)
            // fill over the page.
            final bar = Color.alphaBlend(
              theme.appBarTheme.backgroundColor!,
              colors.background,
            );
            expect(
              contrast(theme.appBarTheme.foregroundColor!, bar),
              greaterThanOrEqualTo(4.5),
              reason: 'app bar: $where',
            );
          }
        }
      }
    });

    test('carry the whole type scale the screens read, fine print '
        'included, in their own font', () {
      for (final preset in ThemePreset.values) {
        for (final formFactor in FormFactor.values) {
          final theme = preset.config.build().withFormFactor(formFactor);
          final reason = '${preset.label}, ${formFactor.name}';
          final text = theme.textTheme;
          final style = theme.style;

          // Each style an app screen uses is the preset style's role —
          // nothing is left at the package's prose defaults.
          expect(text.h1.fontSize, style.display!.fontSize, reason: reason);
          expect(text.h3.fontSize, style.headline!.fontSize, reason: reason);
          expect(text.h4.fontSize, style.title.fontSize, reason: reason);
          expect(text.large.fontSize, style.subtitle!.fontSize, reason: reason);
          expect(text.p.fontSize, style.body.fontSize, reason: reason);
          expect(text.small.fontSize, style.small!.fontSize, reason: reason);
          expect(text.muted.fontSize, style.small!.fontSize, reason: reason);
          expect(text.caption.fontSize, style.caption.fontSize, reason: reason);

          // Fine print is regular and muted, and in the body face: a
          // copy with another weight asks the font for that weight's file.
          expect(text.caption.fontWeight, FontWeight.w400, reason: reason);
          expect(
            text.caption.color,
            theme.colorScheme.mutedForeground,
            reason: reason,
          );
          expect(text.caption, isA<BuilderTextStyle>(), reason: reason);
          expect(
            text.caption.fontFamily,
            text.muted.fontFamily,
            reason: reason,
          );
        }
      }
    });

    test('an accent carries the tint with it, and keeps it legible', () {
      // TealColorScheme names its own tint; `applyAccentScheme` leaves it,
      // which would put a teal selected-tab icon beside rose buttons.
      const onTeal = ThemeEditorConfig(accentColor: AccentColor.rose);
      expect(onTeal.colorScheme.primary, AccentScheme.roseLight.primary);
      expect(onTeal.colorScheme.tint, AccentScheme.roseLight.primary);
      expect(
        onTeal.colorScheme.tintForeground,
        AccentScheme.roseLight.primaryForeground,
      );
      expect(onTeal.colorScheme.accentBorder.a, closeTo(.32, .01));

      // The neutrals follow their primary by themselves in light mode…
      const onZinc = ThemeEditorConfig(
        baseColor: BaseColor.zinc,
        accentColor: AccentColor.rose,
      );
      expect(
        onZinc.colorScheme,
        const ZincColorScheme.light().applyAccentScheme(
          AccentScheme.roseLight,
        ),
      );

      // …but shadcn's dark accent primaries are button fills, far too dark
      // to draw an icon in on a dark page. Every base and accent gets a
      // tint that reads, in both brightnesses, from the accent's own ramp.
      for (final base in BaseColor.values) {
        for (final accent in AccentColor.values) {
          for (final brightness in Brightness.values) {
            final scheme = ThemeEditorConfig(
              brightness: brightness,
              baseColor: base,
              accentColor: accent,
            ).colorScheme;
            final where = '${base.name} ${accent.name} $brightness';
            expect(
              contrast(scheme.tint, scheme.background),
              greaterThanOrEqualTo(4.5),
              reason: 'tint on background: $where',
            );
            expect(
              contrast(scheme.tint, scheme.card),
              greaterThanOrEqualTo(4.5),
              reason: 'tint on card: $where',
            );
            expect(
              contrast(scheme.tintForeground, scheme.tint),
              greaterThanOrEqualTo(3),
              reason: 'tint foreground: $where',
            );
            final overlay = accent.scheme(brightness);
            if (overlay != null) {
              expect(
                [
                  overlay.primary,
                  overlay.chart1,
                  overlay.chart2,
                  overlay.chart3,
                  overlay.chart4,
                  overlay.chart5,
                ],
                contains(scheme.tint),
                reason: 'the tint is one of the accent\'s colours: $where',
              );
              // The buttons keep the accent's own primary pair.
              expect(scheme.primary, overlay.primary, reason: where);
            }
          }
        }
      }
    });
  });

  group('matching a configuration to its preset', () {
    test('every preset is recognised', () {
      for (final preset in ThemePreset.values) {
        expect(ThemePreset.of(preset.config), preset);
      }
    });

    test('how a theme is viewed does not make it custom', () {
      for (final preset in ThemePreset.values) {
        final viewed = preset.config.copyWith(
          brightness: Brightness.dark,
          formFactor: EditorFormFactor.mobile,
          textScale: 1.3,
        );
        expect(ThemePreset.of(viewed), preset, reason: preset.label);
      }
    });

    test('changing any one option of the look does', () {
      const base = ThemeEditorConfig();
      final tweaks = <String, ThemeEditorConfig>{
        'style': base.copyWith(style: StylePreset.nova),
        'base colour': base.copyWith(baseColor: BaseColor.zinc),
        'accent': base.copyWith(accentColor: AccentColor.blue),
        'font': base.copyWith(fontTitle: 'Inter'),
        'heading font': base.copyWith(headingFontTitle: 'Lora'),
        'radius': base.copyWith(radius: RadiusPreset.large),
        'focus ring': base.copyWith(focusRing: FocusRingPlacement.inside),
        'card opacity': base.copyWith(cardOpacity: () => 1),
        'card blur': base.copyWith(cardBlur: () => true),
        'bar opacity': base.copyWith(barOpacity: () => .6),
        'blur strength': base.copyWith(glassBlur: () => 8),
        'density': base.copyWith(density: Density.compact),
        'page margin': base.copyWith(pageMarginScale: 1.5),
        'card padding': base.copyWith(cardPaddingScale: .8),
        'bottom bar': base.copyWith(bottomBarFloating: () => false),
        'menu colour': base.copyWith(menuColor: MenuSurfaceColor.inverted),
        'menu finish': base.copyWith(
          menuFinish: MenuSurfaceFinish.translucent,
        ),
        'menu accent': base.copyWith(menuAccent: EditorMenuAccent.bold),
      };
      for (final MapEntry(:key, :value) in tweaks.entries) {
        expect(value, isNot(base), reason: key);
        expect(ThemePreset.of(value), isNull, reason: key);
      }
    });

    test('a preset applies to the current view, not over it', () {
      const viewing = ThemeEditorConfig(
        brightness: Brightness.dark,
        formFactor: EditorFormFactor.mobile,
        textScale: 1.2,
        accentColor: AccentColor.red,
      );
      final applied = ThemePreset.classic.applyTo(viewing);
      expect(ThemePreset.of(applied), ThemePreset.classic);
      expect(applied.accentColor, AccentColor.base);
      expect(applied.brightness, Brightness.dark);
      expect(applied.formFactor, EditorFormFactor.mobile);
      expect(applied.textScale, 1.2);
    });
  });

  group('theme equality', () {
    test('the same configuration built twice is the same theme', () {
      // `AnimatedTheme` restarts a 200 ms lerp across every component theme
      // whenever the theme is not `==` to the last one, so this is what keeps
      // an unrelated rebuild of `App` from re-animating the whole app.
      final configs = [
        for (final preset in ThemePreset.values) preset.config,
        // Every override at once, built from separate instances.
        const ThemeEditorConfig().copyWith(
          cardOpacity: () => .6,
          cardBlur: () => true,
          barOpacity: () => .7,
          glassBlur: () => 12,
          pageMarginScale: 1.5,
          cardPaddingScale: .8,
          bottomBarFloating: () => false,
          density: Density.compact,
          focusRing: FocusRingPlacement.inside,
        ),
      ];
      for (final config in configs) {
        for (final brightness in Brightness.values) {
          ThemeData build() => config
              .copyWith(brightness: brightness)
              .build(customTextStyles: const {'x': TextStyle(fontSize: 16)});
          final a = build();
          final b = build();
          expect(a, b);
          expect(a.hashCode, b.hashCode);
          // …and laid out for a phone, which is a second set of tokens.
          expect(
            a.withFormFactor(FormFactor.mobile),
            b.withFormFactor(FormFactor.mobile),
          );
          expect(a.style, b.style);
        }
      }
    });

    test('an overridden style is one object per configuration', () {
      final config = const ThemeEditorConfig().copyWith(
        cardOpacity: () => .55,
      );
      final again = const ThemeEditorConfig().copyWith(cardOpacity: () => .55);
      expect(identical(config.styleTokens, again.styleTokens), isTrue);
      // Light and dark share it: brightness is not part of a style.
      expect(
        identical(
          config.styleTokens,
          config.copyWith(brightness: Brightness.dark).styleTokens,
        ),
        isTrue,
      );
      // With nothing overridden it is the package's own constant.
      expect(
        identical(const ThemeEditorConfig().styleTokens, StyleTokens.una),
        isTrue,
      );
      expect(
        identical(ThemePreset.classic.config.styleTokens, StyleTokens.nova),
        isFalse,
        reason: 'Classic docks the bottom bar',
      );
    });

    test('the default configuration is the package default, in Geist', () {
      for (final brightness in Brightness.values) {
        final theme = ThemePreset.original.config
            .copyWith(brightness: brightness)
            .build();
        expect(
          theme,
          ThemeData(
            brightness: brightness,
            textTheme: EditorFont.byTitle('Geist').textTheme(),
          ),
        );
        expect(theme.textTheme.p.fontFamily, contains('Geist'));
      }
    });
  });

  group('the exported code', () {
    test('for the default configuration is ThemeData with its font', () {
      expect(const ThemeEditorConfig().toDartSnippet(), '''
ThemeData(
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
)''');
      // Dark differs only in saying so: the package picks the teal scheme
      // for the brightness itself.
      expect(
        const ThemeEditorConfig(brightness: Brightness.dark).toDartSnippet(),
        '''
ThemeData(
  brightness: Brightness.dark,
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
)''',
      );
      // …and it is true: that code is this theme, the font aside (a font
      // builder compares by identity, and the editor caches its own).
      final exported = ThemeData(
        textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
      );
      final built = const ThemeEditorConfig().build();
      expect(built.style, exported.style);
      expect(built.colorScheme, exported.colorScheme);
      expect(built.radius, exported.radius);
      expect(built.spacing, exported.spacing);
      expect(built.textTheme.p.fontFamily, exported.textTheme.p.fontFamily);
    });

    test('for the whole app names both themes', () {
      expect(const ThemeEditorConfig().toAppSnippet(), '''
// flutter pub add google_fonts
UnaApp(
  theme: ThemeData(
    textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
  ),
  // home, routes and the rest of your app.
)''');
      // A pinned form factor is the app's to pass, not the theme's.
      expect(
        const ThemeEditorConfig(
          formFactor: EditorFormFactor.mobile,
        ).toAppSnippet(),
        contains('\n  formFactor: FormFactor.mobile,\n'),
      );
      // The text scale previews a platform setting; it is not exported.
      expect(
        const ThemeEditorConfig(textScale: 1.4).toAppSnippet(),
        const ThemeEditorConfig().toAppSnippet(),
      );
    });

    test('for a preset with overrides copies the style', () {
      // Whether a `copyWith` on a style reaches the phone tokens it carries
      // is the package's to decide. The export asks rather than assumes:
      // where it does, the overrides are written once; where it does not,
      // they are repeated on the phone tokens. Both are checked against the
      // package as it is.
      final copyWithReachesPhone =
          StyleTokens.una
              .copyWith(glassBlur: 1)
              .forFormFactor(FormFactor.mobile)
              .glassBlur ==
          1;

      final snippet = ThemePreset.frost.config.toDartSnippet();
      expect(
        snippet,
        copyWithReachesPhone
            ? '''
ThemeData(
  colorScheme: const ZincColorScheme.light().applyAccentScheme(
    AccentScheme.indigoLight,
  ),
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.manrope),
  style: StyleTokens.una.copyWith(
    cardOpacity: 0.7,
    cardOpacityDark: 0.7,
    cardBlur: true,
    barOpacity: 0.8,
    barOpacityDark: 0.8,
    glassBlur: 32,
  ),
  menuTranslucent: true,
)'''
            : '''
ThemeData(
  colorScheme: const ZincColorScheme.light().applyAccentScheme(
    AccentScheme.indigoLight,
  ),
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.manrope),
  style: StyleTokens.una.copyWith(
    cardOpacity: 0.7,
    cardOpacityDark: 0.7,
    cardBlur: true,
    barOpacity: 0.8,
    barOpacityDark: 0.8,
    glassBlur: 32,
    mobile: StyleTokens.una.forFormFactor(FormFactor.mobile).copyWith(
      cardOpacity: 0.7,
      cardOpacityDark: 0.7,
      cardBlur: true,
      barOpacity: 0.8,
      barOpacityDark: 0.8,
      glassBlur: 32,
    ),
  ),
  menuTranslucent: true,
)''',
      );

      // The same code, compiled. If a snippet above is edited, edit its
      // twin with it: this is what proves the export reproduces the theme.
      final style = copyWithReachesPhone
          ? StyleTokens.una.copyWith(
              cardOpacity: 0.7,
              cardOpacityDark: 0.7,
              cardBlur: true,
              barOpacity: 0.8,
              barOpacityDark: 0.8,
              glassBlur: 32,
            )
          : StyleTokens.una.copyWith(
              cardOpacity: 0.7,
              cardOpacityDark: 0.7,
              cardBlur: true,
              barOpacity: 0.8,
              barOpacityDark: 0.8,
              glassBlur: 32,
              mobile: StyleTokens.una
                  .forFormFactor(FormFactor.mobile)
                  .copyWith(
                    cardOpacity: 0.7,
                    cardOpacityDark: 0.7,
                    cardBlur: true,
                    barOpacity: 0.8,
                    barOpacityDark: 0.8,
                    glassBlur: 32,
                  ),
            );
      final exported = ThemeData(
        colorScheme: const ZincColorScheme.light().applyAccentScheme(
          AccentScheme.indigoLight,
        ),
        textTheme: TextTheme.fromGoogleFont(GoogleFonts.manrope),
        style: style,
        menuTranslucent: true,
      );
      final built = ThemePreset.frost.config.build();
      for (final formFactor in FormFactor.values) {
        final a = built.withFormFactor(formFactor);
        final b = exported.withFormFactor(formFactor);
        expect(a.style, b.style, reason: '$formFactor');
        expect(a.colorScheme, b.colorScheme);
        expect(a.radius, b.radius);
        expect(a.cardTheme.backgroundColor, b.cardTheme.backgroundColor);
        expect(a.cardTheme.backgroundColor!.a, closeTo(.7, .005));
        expect(a.appBarTheme.backgroundColor, b.appBarTheme.backgroundColor);
        expect(a.glassTheme.blur, 32);
        expect(a.glassTheme.blur, b.glassTheme.blur);
        expect(
          a.contextMenuTheme.decoration!.color,
          b.contextMenuTheme.decoration!.color,
        );
        expect(a.textTheme.p.fontFamily, b.textTheme.p.fontFamily);
      }
    });

    test('spells out the phone tokens where they need their own values', () {
      // A scaled margin is a different number on each form factor — 24 and
      // 16 become 36 and 24 — so no `copyWith` on the style alone can say
      // it.
      final config = const ThemeEditorConfig().copyWith(pageMarginScale: 1.5);
      expect(config.toDartSnippet(), '''
ThemeData(
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
  style: StyleTokens.una.copyWith(
    pagePaddingX: 36,
    pagePaddingY: 36,
    mobile: StyleTokens.una.forFormFactor(FormFactor.mobile).copyWith(
      pagePaddingX: 24,
      pagePaddingY: 24,
    ),
  ),
)''');

      final exported = ThemeData(
        textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
        style: StyleTokens.una.copyWith(
          pagePaddingX: 36,
          pagePaddingY: 36,
          mobile: StyleTokens.una
              .forFormFactor(FormFactor.mobile)
              .copyWith(pagePaddingX: 24, pagePaddingY: 24),
        ),
      );
      final built = config.build();
      for (final formFactor in FormFactor.values) {
        final a = built.withFormFactor(formFactor);
        final b = exported.withFormFactor(formFactor);
        expect(a.style, b.style, reason: '$formFactor');
        expect(a.layoutTheme, b.layoutTheme, reason: '$formFactor');
      }
      expect(
        built
            .withFormFactor(FormFactor.mobile)
            .layoutTheme
            .pagePadding!
            .resolve(TextDirection.ltr),
        const EdgeInsets.all(24),
      );
    });

    test('for a preset with everything else is the code that builds it', () {
      final snippet = ThemePreset.press.config.toDartSnippet();
      // Lyra derives its phone metrics from itself, so the docked bottom
      // bar reaches them without being repeated.
      expect(snippet, '''
ThemeData(
  colorScheme: const ZincColorScheme.light(),
  radius: BorderRadius.circular(0),
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.jetBrainsMono).copyWith(
    h1Large: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h1Large,
    h1: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h1,
    h2: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h2,
    h3: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h3,
    h4: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h4,
  ),
  style: StyleTokens.lyra.copyWith(
    bottomNavigationFloating: false,
  ),
  disableSecondaryBorder: true,
  menuColorScheme: const ZincColorScheme.dark(),
  menuAccent: MenuAccent.bold,
)''');

      final exported = ThemeData(
        colorScheme: const ZincColorScheme.light(),
        radius: BorderRadius.circular(0),
        textTheme: TextTheme.fromGoogleFont(GoogleFonts.jetBrainsMono).copyWith(
          h1Large: TextTheme.fromGoogleFont(
            GoogleFonts.playfairDisplay,
          ).h1Large,
          h1: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h1,
          h2: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h2,
          h3: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h3,
          h4: TextTheme.fromGoogleFont(GoogleFonts.playfairDisplay).h4,
        ),
        style: StyleTokens.lyra.copyWith(bottomNavigationFloating: false),
        disableSecondaryBorder: true,
        menuColorScheme: const ZincColorScheme.dark(),
        menuAccent: MenuAccent.bold,
      );
      final built = ThemePreset.press.config.build();
      for (final formFactor in FormFactor.values) {
        final a = built.withFormFactor(formFactor);
        final b = exported.withFormFactor(formFactor);
        expect(a.style, b.style, reason: '$formFactor');
        expect(a.colorScheme, b.colorScheme);
        expect(a.radius, b.radius);
        expect(a.variant.runtimeType, b.variant.runtimeType);
        expect(a.bottomNavigationBarTheme.floating, isFalse);
        expect(
          a.bottomNavigationBarTheme.floating,
          b.bottomNavigationBarTheme.floating,
        );
        expect(
          a.contextMenuTheme.decoration!.color,
          b.contextMenuTheme.decoration!.color,
        );
        expect(
          a.selectOptionTheme.hoveredBackgroundColor,
          b.selectOptionTheme.hoveredBackgroundColor,
        );
        expect(a.textTheme.p.fontFamily, b.textTheme.p.fontFamily);
        expect(a.textTheme.h1.fontFamily, b.textTheme.h1.fontFamily);
        expect(a.textTheme.h1.fontFamily, isNot(a.textTheme.p.fontFamily));
      }
    });

    test('an accent on teal replaces the teal tint, with no extra code', () {
      const config = ThemeEditorConfig(accentColor: AccentColor.rose);
      expect(config.toDartSnippet(), '''
ThemeData(
  colorScheme: const TealColorScheme.light().applyAccentScheme(
    AccentScheme.roseLight,
  ),
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
)''');
      final exported = const TealColorScheme.light().applyAccentScheme(
        AccentScheme.roseLight,
      );
      expect(config.colorScheme, exported);
      expect(exported.tint, AccentScheme.roseLight.primary);
    });

    test('a dark accent takes its tint from the accent\'s ramp', () {
      const config = ThemeEditorConfig(
        brightness: Brightness.dark,
        baseColor: BaseColor.zinc,
        accentColor: AccentColor.indigo,
      );
      expect(config.toDartSnippet(), '''
ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ZincColorScheme.dark().applyAccentScheme(
    AccentScheme.indigoDark,
  ),
  textTheme: TextTheme.fromGoogleFont(GoogleFonts.geist),
)''');
      final exported = const ZincColorScheme.dark().applyAccentScheme(
        AccentScheme.indigoDark,
      );
      expect(config.colorScheme, exported);
      // The package picks the legible step itself.
      expect(exported.tint, AccentScheme.indigoDark.chart1);
      expect(exported.tintForeground, const Color(0xff09090b));
    });

    test('names every font by its google_fonts accessor', () {
      // Read off `GoogleFonts` itself; each of these is a real static.
      const accessors = {
        'Inter': GoogleFonts.inter,
        'Geist': GoogleFonts.geist,
        'Noto Sans': GoogleFonts.notoSans,
        'Nunito Sans': GoogleFonts.nunitoSans,
        'Figtree': GoogleFonts.figtree,
        'Roboto': GoogleFonts.roboto,
        'Raleway': GoogleFonts.raleway,
        'DM Sans': GoogleFonts.dmSans,
        'Public Sans': GoogleFonts.publicSans,
        'Outfit': GoogleFonts.outfit,
        'Oxanium': GoogleFonts.oxanium,
        'Manrope': GoogleFonts.manrope,
        'Space Grotesk': GoogleFonts.spaceGrotesk,
        'Montserrat': GoogleFonts.montserrat,
        'IBM Plex Sans': GoogleFonts.ibmPlexSans,
        'Source Sans 3': GoogleFonts.sourceSans3,
        'Instrument Sans': GoogleFonts.instrumentSans,
        'JetBrains Mono': GoogleFonts.jetBrainsMono,
        'Geist Mono': GoogleFonts.geistMono,
        'Noto Serif': GoogleFonts.notoSerif,
        'Roboto Slab': GoogleFonts.robotoSlab,
        'Merriweather': GoogleFonts.merriweather,
        'Lora': GoogleFonts.lora,
        'Playfair Display': GoogleFonts.playfairDisplay,
        'EB Garamond': GoogleFonts.ebGaramond,
        'Instrument Serif': GoogleFonts.instrumentSerif,
      };
      const names = {
        'Inter': 'inter',
        'Geist': 'geist',
        'Noto Sans': 'notoSans',
        'Nunito Sans': 'nunitoSans',
        'Figtree': 'figtree',
        'Roboto': 'roboto',
        'Raleway': 'raleway',
        'DM Sans': 'dmSans',
        'Public Sans': 'publicSans',
        'Outfit': 'outfit',
        'Oxanium': 'oxanium',
        'Manrope': 'manrope',
        'Space Grotesk': 'spaceGrotesk',
        'Montserrat': 'montserrat',
        'IBM Plex Sans': 'ibmPlexSans',
        'Source Sans 3': 'sourceSans3',
        'Instrument Sans': 'instrumentSans',
        'JetBrains Mono': 'jetBrainsMono',
        'Geist Mono': 'geistMono',
        'Noto Serif': 'notoSerif',
        'Roboto Slab': 'robotoSlab',
        'Merriweather': 'merriweather',
        'Lora': 'lora',
        'Playfair Display': 'playfairDisplay',
        'EB Garamond': 'ebGaramond',
        'Instrument Serif': 'instrumentSerif',
      };
      expect(accessors.keys, names.keys);
      expect(EditorFont.all.map((f) => f.title), names.keys);
      for (final font in EditorFont.all) {
        expect(
          ThemeEditorConfig(fontTitle: font.title).toDartSnippet(),
          contains(
            'TextTheme.fromGoogleFont(GoogleFonts.${names[font.title]}),',
          ),
          reason: font.title,
        );
        // The accessor resolves to the family the editor itself loads.
        expect(
          accessors[font.title]!().fontFamily,
          font.previewStyle().fontFamily,
          reason: font.title,
        );
      }
    });

    test('never names the package it was forked from', () {
      for (final preset in ThemePreset.values) {
        final snippet = preset.config.toAppSnippet();
        expect(snippet, isNot(contains('Shad')), reason: preset.label);
        expect(snippet, contains('UnaApp('));
        expect(snippet, contains('darkTheme: ThemeData('));
        // The dark half names the dark schemes and accents.
        if (preset.config.accentColor != AccentColor.base) {
          final accent = preset.config.accentColor.name;
          expect(snippet, contains('AccentScheme.${accent}Light'));
          expect(snippet, contains('AccentScheme.${accent}Dark'));
        }
      }
    });
  });
}
