import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/presets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'support.dart';

/// Each control in the editor's Glass, Layout and Preview sections, and the
/// resolved theme value it is there to change — on a desktop and on a phone.
///
/// The phone matters: a style's phone metrics are a second set of tokens, so
/// an override that only reached the first one would do nothing on a phone.
void main() {
  setUpAll(setUpFonts);

  const base = ThemeEditorConfig();

  /// [config]'s theme in [brightness], laid out for [formFactor].
  ThemeData themed(
    ThemeEditorConfig config, {
    Brightness brightness = Brightness.light,
    FormFactor formFactor = FormFactor.desktop,
  }) => config
      .copyWith(brightness: brightness)
      .build()
      .withFormFactor(formFactor);

  /// Runs [check] for both brightnesses and both form factors.
  void everywhere(
    ThemeEditorConfig config,
    void Function(ThemeData theme, String where) check,
  ) {
    for (final brightness in Brightness.values) {
      for (final formFactor in FormFactor.values) {
        check(
          themed(config, brightness: brightness, formFactor: formFactor),
          '$brightness $formFactor',
        );
      }
    }
  }

  test(
    'with nothing overridden the style is the package\'s, phone and all',
    () {
      for (final style in StylePreset.values) {
        final config = ThemeEditorConfig(style: style);
        expect(identical(config.styleTokens, style.tokens), isTrue);
        expect(themed(config).style, style.tokens);
        expect(
          themed(config, formFactor: FormFactor.mobile).style,
          style.tokens.forFormFactor(FormFactor.mobile),
        );
      }
      expect(
        themed(base, formFactor: FormFactor.mobile).style,
        StyleTokens.unaMobile,
      );
    },
  );

  test('the phone metrics are exactly the style\'s own with the overrides '
      'applied, however the package\'s copyWith treats them', () {
    // A style's phone metrics are a second token set. Whether a `copyWith`
    // on the style reaches them is the package's business — and has been
    // both ways; the editor resolves the overrides against each set and
    // checks, so its result does not depend on the answer.
    final overridden = [
      base.copyWith(cardOpacity: () => 1),
      base.copyWith(cardBlur: () => true, glassBlur: () => 6),
      base.copyWith(barOpacity: () => .5, bottomBarFloating: () => false),
      base.copyWith(pageMarginScale: 1.5),
      base.copyWith(cardPaddingScale: .7),
      base.copyWith(
        cardOpacity: () => .6,
        pageMarginScale: 2,
        cardPaddingScale: 1.3,
      ),
    ];
    for (final style in StylePreset.values) {
      for (final override in overridden) {
        final config = override.copyWith(style: style);
        final desktopBase = style.tokens;
        final phoneBase = desktopBase.forFormFactor(FormFactor.mobile);

        final tokens = config.styleTokens;
        expect(
          // The phone set is compared whole; the desktop one apart from the
          // phone set it now carries.
          tokens.copyWith(mobile: phoneBase),
          StyleOverrides.resolve(
            config,
            desktopBase,
          ).apply(desktopBase).copyWith(mobile: phoneBase),
          reason: '${style.name} desktop',
        );
        expect(
          tokens.forFormFactor(FormFactor.mobile),
          StyleOverrides.resolve(config, phoneBase).apply(phoneBase),
          reason: '${style.name} phone',
        );
        // …and that is what the theme is built from.
        expect(
          themed(config, formFactor: FormFactor.mobile).style,
          tokens.forFormFactor(FormFactor.mobile),
        );
      }
    }
  });

  group('Card Opacity', () {
    test('sets the card fill\'s opacity in both brightnesses', () {
      // Una's own cards are 88% in light and 82% in dark.
      expect(themed(base).cardTheme.backgroundColor!.a, closeTo(.88, .005));
      expect(
        themed(base, brightness: Brightness.dark).cardTheme.backgroundColor!.a,
        closeTo(.82, .005),
      );

      everywhere(base.copyWith(cardOpacity: () => .6), (theme, where) {
        expect(theme.style.cardOpacity, .6, reason: where);
        expect(theme.style.cardOpacityDark, .6, reason: where);
        expect(
          theme.cardTheme.backgroundColor!.a,
          closeTo(.6, .005),
          reason: where,
        );
        // The colour itself is still the scheme's card.
        expect(
          theme.cardTheme.backgroundColor!.withValues(alpha: 1),
          theme.colorScheme.card,
          reason: where,
        );
      });
    });

    test('at 100% makes cards opaque, which also stops them blurring', () {
      everywhere(base.copyWith(cardOpacity: () => 1), (theme, where) {
        expect(theme.cardTheme.backgroundColor!.a, 1, reason: where);
        expect(theme.cardTheme.backgroundColor, theme.colorScheme.card);
      });
      expect(base.copyWith(cardOpacity: () => 1).cardsAreTranslucent, isFalse);
      expect(base.cardsAreTranslucent, isTrue);
    });

    test('makes an opaque style translucent', () {
      const nova = ThemeEditorConfig(style: StylePreset.nova);
      expect(themed(nova).cardTheme.backgroundColor!.a, 1);
      expect(nova.cardsAreTranslucent, isFalse);
      everywhere(nova.copyWith(cardOpacity: () => .5), (theme, where) {
        expect(
          theme.cardTheme.backgroundColor!.a,
          closeTo(.5, .005),
          reason: where,
        );
      });
    });

    test('states only what differs from the style', () {
      // 88% is already Una's light value: only the dark one moves.
      final overrides = StyleOverrides.resolve(
        base.copyWith(cardOpacity: () => .88),
        StyleTokens.una,
      );
      expect(overrides.cardOpacity, isNull);
      expect(overrides.cardOpacityDark, .88);
      expect(overrides.code, ['cardOpacityDark: 0.88']);
      expect(StyleOverrides.resolve(base, StyleTokens.una).isEmpty, isTrue);
    });
  });

  group('Card Blur', () {
    test('turns the backdrop blur behind a translucent card on and off', () {
      // Una's cards are translucent and do not blur: a card lies on
      // the flat page, where a backdrop filter per card shows nothing.
      expect(base.effectiveCardBlur, isFalse);
      everywhere(base, (theme, where) {
        expect(theme.style.cardBlur, isFalse, reason: where);
        expect(theme.cardTheme.blur, 0, reason: where);
        expect(theme.cardTheme.saturation, 1, reason: where);
        expect(theme.cardTheme.backgroundColor!.a, lessThan(1), reason: where);
      });

      // Switched on, a card is glass like the bars: the style's blur and
      // saturation behind the same fill.
      final blurred = base.copyWith(cardBlur: () => true);
      expect(blurred.effectiveCardBlur, isTrue);
      everywhere(blurred, (theme, where) {
        expect(theme.style.cardBlur, isTrue, reason: where);
        expect(theme.cardTheme.blur, theme.style.glassBlur, reason: where);
        expect(theme.cardTheme.blur, greaterThan(0), reason: where);
        expect(
          theme.cardTheme.saturation,
          theme.style.glassSaturation,
          reason: where,
        );
        // The card is as translucent as it was.
        expect(
          theme.cardTheme.backgroundColor,
          themed(
            base,
            brightness: theme.brightness,
            formFactor: theme.formFactor,
          ).cardTheme.backgroundColor,
          reason: where,
        );
      });

      // And off again is the style itself, not an override of it.
      expect(blurred.copyWith(cardBlur: () => null), base);
      everywhere(blurred.copyWith(cardBlur: () => false), (theme, where) {
        expect(theme.cardTheme.blur, 0, reason: where);
      });
    });

    test('turns it on for a style that has none', () {
      final glassyNova = const ThemeEditorConfig(
        style: StylePreset.nova,
      ).copyWith(cardOpacity: () => .7, cardBlur: () => true);
      everywhere(glassyNova, (theme, where) {
        expect(theme.style.cardBlur, isTrue, reason: where);
        expect(theme.cardTheme.blur, StyleTokens.nova.glassBlur, reason: where);
      });
    });
  });

  group('Bar Opacity', () {
    test('sets the opacity of the app bar and the bottom bar', () {
      everywhere(base.copyWith(barOpacity: () => .6), (theme, where) {
        expect(theme.style.barOpacity, .6, reason: where);
        expect(
          theme.appBarTheme.backgroundColor!.a,
          closeTo(.6, .005),
          reason: where,
        );
        expect(
          theme.bottomNavigationBarTheme.backgroundColor!.a,
          closeTo(.6, .005),
          reason: where,
        );
        // A see-through bar blurs what scrolls under it.
        expect(theme.appBarTheme.blur, greaterThan(0), reason: where);
      });
    });

    test('at 100% makes the bars solid and drops their blur', () {
      everywhere(base.copyWith(barOpacity: () => 1), (theme, where) {
        expect(theme.appBarTheme.backgroundColor!.a, 1, reason: where);
        expect(theme.appBarTheme.blur, 0, reason: where);
        expect(theme.bottomNavigationBarTheme.blur, 0, reason: where);
      });
    });
  });

  group('Blur Strength', () {
    test('sets the blur behind glass and bars, and behind cards that '
        'blur', () {
      expect(base.effectiveGlassBlur, StyleTokens.una.glassBlur);
      everywhere(base.copyWith(glassBlur: () => 6), (theme, where) {
        expect(theme.style.glassBlur, 6, reason: where);
        expect(theme.glassTheme.blur, 6, reason: where);
        expect(theme.appBarTheme.blur, 6, reason: where);
        expect(theme.bottomNavigationBarTheme.blur, 6, reason: where);
        // Card Blur is off: the strength has nothing to act on there.
        expect(theme.cardTheme.blur, 0, reason: where);
      });
      everywhere(
        base.copyWith(glassBlur: () => 6, cardBlur: () => true),
        (theme, where) => expect(theme.cardTheme.blur, 6, reason: where),
      );
      // Frost is the preset that has it on, at its own strength.
      everywhere(ThemePreset.frost.config, (theme, where) {
        expect(theme.cardTheme.blur, 32, reason: where);
        expect(theme.glassTheme.blur, 32, reason: where);
      });
    });
  });

  group('Density', () {
    test('is the spacing step every metric is a multiple of', () {
      expect(themed(base).spacing.step, 4);
      for (final density in Density.values) {
        everywhere(base.copyWith(density: density), (theme, where) {
          expect(theme.spacing.step, density.step, reason: where);
          // A button's height is `h-9` in spacing units: it follows.
          expect(
            theme.buttonSizesTheme.regular!.height,
            theme.style.buttonHeight * density.step / 4,
            reason: '$density $where',
          );
        });
      }
      // Compact really is smaller, spacious larger.
      double buttonHeight(Density d) =>
          themed(base.copyWith(density: d)).buttonSizesTheme.regular!.height;
      expect(
        buttonHeight(Density.compact),
        lessThan(buttonHeight(Density.normal)),
      );
      expect(
        buttonHeight(Density.spacious),
        greaterThan(buttonHeight(Density.normal)),
      );
    });
  });

  group('Page Margin', () {
    EdgeInsets pagePadding(ThemeData theme) =>
        theme.layoutTheme.pagePadding!.resolve(TextDirection.ltr);

    test('scales each form factor\'s own margins', () {
      // Una: 24 on a desktop, 16 on a phone.
      expect(pagePadding(themed(base)), const EdgeInsets.all(24));
      expect(
        pagePadding(themed(base, formFactor: FormFactor.mobile)),
        const EdgeInsets.all(16),
      );

      final wide = base.copyWith(pageMarginScale: 1.5);
      expect(themed(wide).style.pagePaddingX, 36);
      expect(pagePadding(themed(wide)), const EdgeInsets.all(36));
      expect(
        pagePadding(themed(wide, formFactor: FormFactor.mobile)),
        const EdgeInsets.all(24),
      );
      // The app bar lines up with the page it sits over.
      expect(
        themed(wide).appBarTheme.padding!.resolve(TextDirection.ltr).left,
        36,
      );

      final none = base.copyWith(pageMarginScale: 0);
      expect(pagePadding(themed(none)), EdgeInsets.zero);
      expect(
        pagePadding(themed(none, formFactor: FormFactor.mobile)),
        EdgeInsets.zero,
      );
    });

    test('reaches the phone metrics a style only derives', () {
      // Nova has no phone tokens of its own; `forFormFactor` derives them,
      // and pins the page margin to 16 while doing so.
      final nova = const ThemeEditorConfig(
        style: StylePreset.nova,
      ).copyWith(pageMarginScale: 2);
      expect(pagePadding(themed(nova)), const EdgeInsets.all(48));
      expect(
        pagePadding(themed(nova, formFactor: FormFactor.mobile)),
        const EdgeInsets.all(32),
      );
      // …and the rest of the derived phone metrics are still there.
      expect(
        themed(nova, formFactor: FormFactor.mobile).style.buttonHeight,
        StyleTokens.nova.forFormFactor(FormFactor.mobile).buttonHeight,
      );
    });
  });

  group('Card Padding', () {
    test('scales each form factor\'s own card padding', () {
      // Una: 20 on a desktop, 16 on a phone.
      expect(themed(base).cardTheme.padding, const EdgeInsets.all(20));
      expect(
        themed(base, formFactor: FormFactor.mobile).cardTheme.padding,
        const EdgeInsets.all(16),
      );

      final roomy = base.copyWith(cardPaddingScale: 1.5);
      expect(themed(roomy).style.cardPadding, 30);
      expect(themed(roomy).cardTheme.padding, const EdgeInsets.all(30));
      expect(themed(roomy).cardTheme.sectionGap, 30);
      expect(
        themed(roomy, formFactor: FormFactor.mobile).cardTheme.padding,
        const EdgeInsets.all(24),
      );

      final tight = base.copyWith(cardPaddingScale: .5);
      expect(themed(tight).cardTheme.padding, const EdgeInsets.all(10));
      expect(
        themed(tight, formFactor: FormFactor.mobile).cardTheme.padding,
        const EdgeInsets.all(8),
      );
    });

    test('rounds to whole pixels', () {
      final config = base.copyWith(cardPaddingScale: 1.1);
      expect(themed(config).style.cardPadding, 22);
      // 16 * 1.1 = 17.6
      expect(
        themed(config, formFactor: FormFactor.mobile).style.cardPadding,
        18,
      );
    });
  });

  group('Bottom Bar', () {
    test('floats or docks the phone\'s navigation bar', () {
      expect(base.effectiveBottomBarFloating, isTrue);
      everywhere(base, (theme, where) {
        expect(theme.bottomNavigationBarTheme.floating, isTrue, reason: where);
      });

      final docked = base.copyWith(bottomBarFloating: () => false);
      expect(docked.effectiveBottomBarFloating, isFalse);
      everywhere(docked, (theme, where) {
        expect(theme.style.bottomNavigationFloating, isFalse, reason: where);
        expect(theme.bottomNavigationBarTheme.floating, isFalse, reason: where);
      });

      // Saying what the style already says is not an override.
      expect(
        identical(
          base.copyWith(bottomBarFloating: () => true).styleTokens,
          StyleTokens.una,
        ),
        isTrue,
      );
    });
  });

  group('Focus Ring', () {
    test('inside is the no-secondary-border variant', () {
      expect(themed(base).variant, isA<DefaultThemeVariant>());
      expect(
        themed(base).variant,
        isNot(isA<DefaultThemeNoSecondaryBorderVariant>()),
      );
      everywhere(base.copyWith(focusRing: FocusRingPlacement.inside), (
        theme,
        where,
      ) {
        expect(
          theme.variant,
          isA<DefaultThemeNoSecondaryBorderVariant>(),
          reason: where,
        );
      });
    });
  });

  group('Form Factor', () {
    test('pins the theme\'s form factor, or leaves it to the width', () {
      // Auto builds a theme with no opinion: `UnaApp` lays it out.
      expect(base.build().formFactor, FormFactor.desktop);
      expect(
        base.copyWith(formFactor: EditorFormFactor.mobile).build().formFactor,
        FormFactor.mobile,
      );
      expect(
        base.copyWith(formFactor: EditorFormFactor.desktop).build().formFactor,
        FormFactor.desktop,
      );

      // The phone theme has the phone metrics.
      final phone = base.copyWith(formFactor: EditorFormFactor.mobile).build();
      expect(phone.style, StyleTokens.unaMobile);
      expect(phone.buttonSizesTheme.regular!.height, 44);
    });

    test('resolves against the page width', () {
      const breakpoint = 768.0;
      FormFactor at(EditorFormFactor mode, double width) =>
          mode.resolve(width, breakpoint: breakpoint);

      expect(at(EditorFormFactor.auto, 390), FormFactor.mobile);
      expect(at(EditorFormFactor.auto, 767), FormFactor.mobile);
      expect(at(EditorFormFactor.auto, 768), FormFactor.desktop);
      expect(at(EditorFormFactor.auto, 1440), FormFactor.desktop);
      for (final width in [390.0, 768.0, 1440.0]) {
        expect(at(EditorFormFactor.mobile, width), FormFactor.mobile);
        expect(at(EditorFormFactor.desktop, width), FormFactor.desktop);
      }
    });

    test('every override survives a pinned phone layout', () {
      final config = base.copyWith(
        formFactor: EditorFormFactor.mobile,
        cardOpacity: () => .5,
        barOpacity: () => .5,
        glassBlur: () => 10,
        cardPaddingScale: 1.5,
        pageMarginScale: 1.5,
        bottomBarFloating: () => false,
      );
      final theme = config.build();
      expect(theme.formFactor, FormFactor.mobile);
      expect(theme.cardTheme.backgroundColor!.a, closeTo(.5, .005));
      expect(theme.appBarTheme.backgroundColor!.a, closeTo(.5, .005));
      expect(theme.glassTheme.blur, 10);
      expect(theme.cardTheme.padding, const EdgeInsets.all(24));
      expect(
        theme.layoutTheme.pagePadding!.resolve(TextDirection.ltr),
        const EdgeInsets.all(24),
      );
      expect(theme.bottomNavigationBarTheme.floating, isFalse);
      // And it is still a phone: touch-sized controls, phone body text.
      expect(theme.buttonSizesTheme.regular!.height, 44);
      expect(
        theme.style.body.fontSize,
        StyleTokens.unaMobile.body.fontSize,
      );
    });
  });

  group('Text Scale', () {
    test('is a preview setting: it does not change the theme', () {
      expect(
        base.copyWith(textScale: 1.4).build(),
        base.build(),
      );
    });
  });

  group('the configuration is a value', () {
    test('copyWith can clear an override', () {
      final overridden = base.copyWith(
        cardOpacity: () => .5,
        cardBlur: () => true,
        barOpacity: () => .5,
        glassBlur: () => 4,
        bottomBarFloating: () => false,
      );
      expect(overridden, isNot(base));
      // Untouched by an unrelated copy…
      expect(overridden.copyWith(density: Density.compact).cardOpacity, .5);
      // …and cleared by a getter that returns null.
      expect(
        overridden.copyWith(
          cardOpacity: () => null,
          cardBlur: () => null,
          barOpacity: () => null,
          glassBlur: () => null,
          bottomBarFloating: () => null,
        ),
        base,
      );
    });

    test('equal configurations are equal, and hash alike', () {
      ThemeEditorConfig make() => const ThemeEditorConfig().copyWith(
        cardOpacity: () => .7,
        pageMarginScale: 1.2,
        formFactor: EditorFormFactor.mobile,
      );
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
    });
  });
}
