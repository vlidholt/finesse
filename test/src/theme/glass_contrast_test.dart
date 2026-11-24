import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The floating surfaces of the `finesse` style are glass, so what is read
/// on them depends on what is behind them. These walk every menu option in
/// both brightnesses over the page, over black and over white — the two
/// ends a blurred photograph can come out at — and hold the text to WCAG
/// contrast.
void main() {
  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + .05) / (lo + .05);
  }

  Color over(Color color, Color backdrop) => Color.alphaBlend(color, backdrop);

  const black = Color(0xff000000);
  const white = Color(0xffffffff);

  ThemeData themeOf(
    Brightness brightness, {
    bool? translucent,
    bool inverted = false,
    MenuAccent accent = MenuAccent.subtle,
    StyleTokens style = StyleTokens.finesse,
  }) => ThemeData(
    brightness: brightness,
    style: style,
    menuTranslucent: translucent,
    menuAccent: accent,
    menuColorScheme: inverted
        ? (brightness == Brightness.light
              ? const TealColorScheme.dark()
              : const TealColorScheme.light())
        : null,
  );

  test('the finesse style makes every floating surface glass', () {
    for (final brightness in Brightness.values) {
      final theme = themeOf(brightness);
      final style = theme.style;
      final filter = Backdrop.filterFor(
        blur: style.glassBlur,
        saturation: style.glassSaturation,
      );
      final opacity = brightness == Brightness.dark
          ? style.popoverOpacityDark ?? style.popoverOpacity
          : style.popoverOpacity;
      expect(opacity, lessThan(1));
      final fill = theme.colorScheme.popover.withValues(alpha: opacity);

      expect(theme.popoverTheme.decoration!.color, fill);
      expect(theme.popoverTheme.filter, filter);
      expect(theme.contextMenuTheme.decoration!.color, fill);
      expect(theme.contextMenuTheme.filter, filter);
      expect(theme.selectTheme.popoverDecoration!.color, fill);
      expect(theme.selectTheme.filter, filter);
      expect(theme.commandTheme.backgroundColor, fill);
      expect(theme.commandTheme.surfaceFilter, filter);
      expect(theme.tooltipTheme.filter, filter);
      expect(theme.tooltipTheme.decoration!.color!.a, lessThan(1));
      // The shadow is still there: it is painted outside the clip.
      expect(theme.popoverTheme.decoration!.shadows, isNotEmpty);
    }
  });

  test('the shadcn styles keep their solid surfaces', () {
    for (final style in [
      StyleTokens.nova,
      StyleTokens.maia,
      StyleTokens.lyra,
    ]) {
      for (final brightness in Brightness.values) {
        final theme = themeOf(brightness, style: style);
        final where = '${style.name} $brightness';
        expect(style.popoverOpacity, 1, reason: where);
        expect(style.tooltipOpacity, 1, reason: where);
        expect(theme.popoverTheme.decoration!.color!.a, 1, reason: where);
        expect(theme.popoverTheme.filter, isNull, reason: where);
        expect(theme.contextMenuTheme.decoration!.color!.a, 1, reason: where);
        expect(theme.contextMenuTheme.filter, isNull, reason: where);
        expect(theme.selectTheme.filter, isNull, reason: where);
        expect(theme.commandTheme.backgroundColor!.a, 1, reason: where);
        expect(theme.commandTheme.surfaceFilter, isNull, reason: where);
        expect(theme.tooltipTheme.filter, isNull, reason: where);
        expect(
          theme.tooltipTheme.decoration!.color,
          theme.colorScheme.foreground,
          reason: where,
        );
      }
    }
  });

  test('menuTranslucent overrides the style either way', () {
    for (final brightness in Brightness.values) {
      // False: solid menus in a glass style. Popovers stay glass.
      final solid = themeOf(brightness, translucent: false);
      expect(solid.contextMenuTheme.decoration!.color!.a, 1);
      expect(solid.contextMenuTheme.filter, isNull);
      expect(solid.selectTheme.filter, isNull);
      expect(solid.popoverTheme.filter, isNotNull);

      // True: shadcn's finish, `popover/70` with a foreground wash for the
      // highlight, over the style's own glass.
      final finish = themeOf(brightness, translucent: true);
      expect(finish.contextMenuTheme.decoration!.color!.a, closeTo(.7, .001));
      expect(finish.contextMenuTheme.filter, solid.popoverTheme.filter);
      expect(
        finish.contextMenuTheme.selectedBackgroundColor,
        finish.colorScheme.foreground.withValues(alpha: .1),
      );

      // In a solid style, true brings shadcn's own blur.
      final nova = themeOf(
        brightness,
        translucent: true,
        style: StyleTokens.nova,
      );
      expect(nova.contextMenuTheme.decoration!.color!.a, closeTo(.7, .001));
      expect(
        nova.contextMenuTheme.filter,
        Backdrop.filterFor(blur: 20, saturation: 1.5),
      );
    }
  });

  test('menu rows stay readable on glass in every mode', () {
    for (final brightness in Brightness.values) {
      for (final translucent in [null, true, false]) {
        for (final inverted in [false, true]) {
          for (final accent in MenuAccent.values) {
            final theme = themeOf(
              brightness,
              translucent: translucent,
              inverted: inverted,
              accent: accent,
            );
            final menu = theme.contextMenuTheme;
            final option = theme.selectOptionTheme;
            for (final backdrop in [
              theme.colorScheme.background,
              black,
              white,
            ]) {
              final where =
                  '$brightness translucent=$translucent inverted=$inverted '
                  '$accent over $backdrop';
              final onPage = backdrop == theme.colorScheme.background;
              final surface = over(menu.decoration!.color!, backdrop);

              // A resting row, and its shortcut.
              expect(
                contrast(menu.textStyle!.color!, surface),
                greaterThanOrEqualTo(4.5),
                reason: 'row: $where',
              );
              // Its shortcut is muted text. shadcn's own 70% finish, when
              // asked for, is held to that only over a page of its own
              // brightness.
              if (translucent != true || (onPage && !inverted)) {
                expect(
                  contrast(menu.trailingTextStyle!.color!, surface),
                  greaterThanOrEqualTo(3),
                  reason: 'shortcut: $where',
                );
              }

              // The highlighted row: its text on its highlight, and the
              // highlight itself told apart from the surface or — where the
              // two are close, as a pale accent on white glass is — by the
              // text changing colour.
              final highlight = over(menu.selectedBackgroundColor!, surface);
              expect(
                contrast(menu.selectedTextStyle!.color!, highlight),
                greaterThanOrEqualTo(onPage && !inverted ? 4.5 : 3),
                reason: 'highlighted row: $where',
              );
              expect(
                contrast(highlight, surface) > 1.04 ||
                    menu.selectedTextStyle!.color != menu.textStyle!.color,
                isTrue,
                reason: 'highlight invisible: $where',
              );

              // A select's options use the same pair, so a menu cannot
              // change colour halfway down.
              expect(
                option.hoveredBackgroundColor,
                menu.selectedBackgroundColor,
              );
              expect(
                option.selectedTextStyle!.color,
                menu.selectedTextStyle!.color,
              );

              // A destructive row. The scheme's red is the limit here, not
              // the glass — on the solid dark surface it is already only
              // 3:1 — so the glass is held to what the solid surface gives:
              // nearly all of it over the page, and at least half over the
              // brightest or darkest thing a photograph can blur to — or
              // over a page of the opposite brightness, which is what an
              // inverted menu sits on.
              final solid = menu.decoration!.color!.withValues(alpha: 1);
              if (translucent != true || (onPage && !inverted)) {
                expect(
                  contrast(menu.destructiveForegroundColor!, surface),
                  greaterThanOrEqualTo(
                    (onPage && !inverted ? .9 : .5) *
                        contrast(menu.destructiveForegroundColor!, solid),
                  ),
                  reason: 'destructive row: $where',
                );
              }

              // The hairline around the surface and between its groups.
              expect(menu.decoration!.border!.top!.color!.a, greaterThan(0));
            }
          }
        }
      }
    }
  });

  test('popover, command and tooltip text stays readable on glass', () {
    for (final brightness in Brightness.values) {
      final theme = themeOf(brightness);
      final scheme = theme.colorScheme;
      for (final backdrop in [scheme.background, black, white]) {
        final where = '$brightness over $backdrop';

        final popover = over(theme.popoverTheme.decoration!.color!, backdrop);
        expect(
          contrast(scheme.popoverForeground, popover),
          greaterThanOrEqualTo(4.5),
          reason: 'popover: $where',
        );
        expect(
          contrast(scheme.mutedForeground, popover),
          greaterThanOrEqualTo(3),
          reason: 'popover muted text: $where',
        );

        final command = over(theme.commandTheme.backgroundColor!, backdrop);
        final selected = over(
          theme.commandTheme.itemSelectedBackgroundColor!,
          command,
        );
        expect(
          contrast(
            theme.commandTheme.itemSelectedForegroundColor ??
                scheme.popoverForeground,
            selected,
          ),
          greaterThanOrEqualTo(4.5),
          reason: 'command: $where',
        );

        final tooltip = over(theme.tooltipTheme.decoration!.color!, backdrop);
        expect(
          contrast(theme.tooltipTheme.textStyle!.color!, tooltip),
          greaterThanOrEqualTo(4.5),
          reason: 'tooltip: $where',
        );
      }
    }
  });

  test('a glass theme is equal to its own rebuild', () {
    // The filters come from a cache, so two builds share them; a fresh
    // filter per build would make AnimatedTheme re-animate for ever.
    for (final brightness in Brightness.values) {
      expect(themeOf(brightness), themeOf(brightness));
      expect(
        themeOf(brightness, translucent: true),
        themeOf(brightness, translucent: true),
      );
      expect(
        themeOf(brightness, translucent: false),
        isNot(themeOf(brightness)),
      );
    }
  });
}
