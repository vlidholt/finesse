import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../fixture_styles.dart';
import '../../una_harness.dart';

/// What the theme gained when the Demo screens were folded back in:
/// `textTheme.muted`'s colour, seven style tokens, `ThemeData.baseStyle`,
/// `ThemeData.buttonDecoration` and the variant's wider equality.
void main() {
  const styles = [
    StyleTokens.una,
    StyleTokens.nova,
    StyleTokens.maia,
    StyleTokens.lyra,
  ];

  group('textTheme.muted', () {
    test("carries the scheme's muted foreground in every style, brightness, "
        'form factor and variant', () {
      for (final style in styles) {
        for (final brightness in Brightness.values) {
          for (final formFactor in FormFactor.values) {
            for (final disableSecondaryBorder in [false, true]) {
              final theme = ThemeData(
                style: style,
                brightness: brightness,
                formFactor: formFactor,
                disableSecondaryBorder: disableSecondaryBorder,
              );
              expect(
                theme.textTheme.muted.color,
                theme.colorScheme.mutedForeground,
                reason:
                    '${style.name} $brightness ${formFactor.name} '
                    'disableSecondaryBorder: $disableSecondaryBorder',
              );
            }
          }
        }
      }
    });

    test('the colour differs between the brightnesses, so it is really the '
        "scheme's", () {
      for (final style in styles) {
        final light = ThemeData(style: style);
        final dark = ThemeData(style: style, brightness: Brightness.dark);
        expect(
          light.textTheme.muted.color,
          isNot(dark.textTheme.muted.color),
          reason: style.name,
        );
      }
    });

    test('follows the scheme of each base palette', () {
      for (final scheme in const <ColorScheme>[
        BlueColorScheme.light(),
        BlueColorScheme.dark(),
        NeutralColorScheme.light(),
        NeutralColorScheme.dark(),
        ZincColorScheme.light(),
        ZincColorScheme.dark(),
        StoneColorScheme.light(),
        StoneColorScheme.dark(),
      ]) {
        for (final style in styles) {
          expect(
            ThemeData(colorScheme: scheme, style: style).textTheme.muted.color,
            scheme.mutedForeground,
            reason: style.name,
          );
        }
      }
    });

    test('a copy with another scheme recolours it', () {
      final theme = ThemeData();
      final copy = theme.copyWith(colorScheme: const ZincColorScheme.dark());
      expect(
        copy.textTheme.muted.color,
        const ZincColorScheme.dark().mutedForeground,
      );
      expect(copy.textTheme.muted.color, isNot(theme.textTheme.muted.color));
    });

    test("only the colour is added: the size is still the style's", () {
      // Every shipped style sets `muted` in its small role: 13/18, or 12/16
      // in lyra. The role names no weight, so the text theme's own stays.
      for (final style in styles) {
        final theme = ThemeData(style: style);
        final raw = theme.variant.effectiveTextTheme.muted;
        final role = style.small!;
        expect(
          theme.textTheme.muted.fontSize,
          role.fontSize,
          reason: style.name,
        );
        expect(
          theme.textTheme.muted.fontSize,
          theme.textTheme.small.fontSize,
          reason: style.name,
        );
        expect(theme.textTheme.muted.height, role.height, reason: style.name);
        expect(
          theme.textTheme.muted.fontWeight,
          raw.fontWeight,
          reason: style.name,
        );
      }
      // A style without the role leaves the text theme's own `text-sm`.
      for (final style in const [
        FixtureStyles.vega,
        StyleTokens(name: 'bare'),
      ]) {
        final theme = ThemeData(style: style);
        final raw = theme.variant.effectiveTextTheme.muted;
        expect(theme.textTheme.muted.fontSize, 14, reason: style.name);
        expect(
          theme.textTheme.muted.fontSize,
          raw.fontSize,
          reason: style.name,
        );
        expect(
          theme.textTheme.muted.fontWeight,
          raw.fontWeight,
          reason: style.name,
        );
        expect(theme.textTheme.muted.height, raw.height, reason: style.name);
      }
    });

    test('the other roles are not coloured along with it', () {
      for (final style in styles) {
        final theme = ThemeData(style: style);
        final raw = theme.variant.effectiveTextTheme;
        expect(
          theme.textTheme.small.color,
          raw.small.color,
          reason: style.name,
        );
        expect(theme.textTheme.p.color, raw.p.color, reason: style.name);
        expect(
          theme.textTheme.large.color,
          raw.large.color,
          reason: style.name,
        );
      }
    });

    test('the raw text theme components build on is left alone', () {
      for (final style in styles) {
        final theme = ThemeData(style: style);
        // The variant's input: what `Card`, `ListTile` and the rest read
        // and colour themselves.
        expect(
          theme.variant.effectiveTextTheme.muted.color,
          isNull,
          reason: style.name,
        );
      }
    });

    test('a text theme that states its own muted colour keeps it: the '
        "scheme's is a default", () {
      const own = Color(0xff8844aa);
      for (final style in styles) {
        final theme = ThemeData(
          style: style,
          textTheme: TextTheme(muted: const TextStyle(color: own)),
        );
        expect(theme.textTheme.muted.color, own, reason: style.name);
        // Components read the same colour from the raw text theme, so the
        // two cannot disagree.
        expect(
          theme.variant.effectiveTextTheme.muted.color,
          own,
          reason: style.name,
        );
      }
      // A text theme that changes something else about `muted` still gets
      // the scheme's colour. (vega: a style with a small role would set the
      // size itself.)
      final sized = ThemeData(
        style: FixtureStyles.vega,
        textTheme: TextTheme(muted: const TextStyle(fontSize: 11)),
      );
      expect(sized.textTheme.muted.fontSize, 11);
      expect(sized.textTheme.muted.color, sized.colorScheme.mutedForeground);
    });

    test('two themes still compare equal', () {
      expect(ThemeData().textTheme, ThemeData().textTheme);
      expect(
        ThemeData(style: StyleTokens.nova).textTheme.muted,
        ThemeData(style: StyleTokens.nova).textTheme.muted,
      );
    });

    testWidgets('app code reading Theme.of(context).textTheme.muted gets '
        'muted text', (tester) async {
      for (final brightness in Brightness.values) {
        late TextStyle seen;
        await pumpUna(
          tester,
          Builder(
            builder: (context) {
              seen = Theme.of(context).textTheme.muted;
              return Text('Supporting text', style: seen);
            },
          ),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.text('Supporting text'));
        expect(seen.color, theme.colorScheme.mutedForeground);
        final text = tester.widget<RichText>(
          find.descendant(
            of: find.text('Supporting text'),
            matching: find.byType(RichText),
          ),
        );
        expect(text.text.style!.color, theme.colorScheme.mutedForeground);
      }
    });
  });

  group('the new style tokens', () {
    test('default to the shadcn values and are set by una', () {
      const defaults = StyleTokens.nova;
      expect(defaults.secondaryButtonFill, SurfaceFill.secondary);
      expect(defaults.secondaryBadgeFill, SurfaceFill.secondary);
      expect(defaults.secondaryBadgeSubtle, isFalse);
      expect(defaults.progressTrackFill, SurfaceFill.muted);
      expect(defaults.progressTinted, isFalse);
      expect(defaults.dividerMargin, 16);
      expect(defaults.timelineLineGap, 6);
      for (final style in [StyleTokens.maia, StyleTokens.lyra]) {
        expect(style.secondaryButtonFill, defaults.secondaryButtonFill);
        expect(style.secondaryBadgeFill, defaults.secondaryBadgeFill);
        expect(style.secondaryBadgeSubtle, defaults.secondaryBadgeSubtle);
        expect(style.progressTrackFill, defaults.progressTrackFill);
        expect(style.progressTinted, defaults.progressTinted);
        expect(style.dividerMargin, defaults.dividerMargin);
        expect(style.timelineLineGap, defaults.timelineLineGap);
      }

      for (final style in [StyleTokens.una, StyleTokens.unaMobile]) {
        expect(
          style.secondaryButtonFill,
          SurfaceFill.muted,
          reason: style.name,
        );
        expect(style.secondaryBadgeFill, SurfaceFill.muted, reason: style.name);
        expect(style.secondaryBadgeSubtle, isTrue, reason: style.name);
        expect(
          style.progressTrackFill,
          SurfaceFill.secondary,
          reason: style.name,
        );
        expect(style.progressTinted, isTrue, reason: style.name);
        expect(style.dividerMargin, 0, reason: style.name);
        expect(style.timelineLineGap, 8, reason: style.name);
      }
    });

    test("are part of a style's value", () {
      const base = StyleTokens.nova;
      for (final changed in [
        base.copyWith(secondaryButtonFill: SurfaceFill.muted),
        base.copyWith(secondaryBadgeFill: SurfaceFill.muted),
        base.copyWith(secondaryBadgeSubtle: true),
        base.copyWith(progressTrackFill: SurfaceFill.secondary),
        base.copyWith(progressTinted: true),
        base.copyWith(dividerMargin: 0),
        base.copyWith(timelineLineGap: 8),
      ]) {
        expect(changed, isNot(base));
        expect(changed.hashCode, isNot(base.hashCode));
      }
      expect(base.copyWith(dividerMargin: 16), base);
    });

    for (final brightness in Brightness.values) {
      for (final formFactor in FormFactor.values) {
        final label = '${brightness.name}, ${formFactor.name}';

        test('secondaryButtonFill reaches secondaryButtonTheme ($label)', () {
          final una = ThemeData(
            brightness: brightness,
            formFactor: formFactor,
          );
          final nova = ThemeData(
            style: StyleTokens.nova,
            brightness: brightness,
            formFactor: formFactor,
          );
          // The quiet round icon buttons: `--fill`.
          expect(
            una.secondaryButtonTheme.backgroundColor,
            una.colorScheme.muted,
          );
          expect(
            una.secondaryButtonTheme.hoverBackgroundColor,
            Color.lerp(
              una.colorScheme.muted,
              una.colorScheme.foreground,
              .05,
            ),
          );
          expect(
            nova.secondaryButtonTheme.backgroundColor,
            nova.colorScheme.secondary,
          );
          expect(
            nova.secondaryButtonTheme.hoverBackgroundColor,
            Color.lerp(
              nova.colorScheme.secondary,
              nova.colorScheme.foreground,
              .05,
            ),
          );
        });

        test('secondaryBadgeFill and secondaryBadgeSubtle reach '
            'secondaryBadgeTheme ($label)', () {
          final una = ThemeData(
            brightness: brightness,
            formFactor: formFactor,
          );
          final nova = ThemeData(
            style: StyleTokens.nova,
            brightness: brightness,
            formFactor: formFactor,
          );
          // The grey tag: `--fill` under `--ink-2`.
          expect(
            una.secondaryBadgeTheme.backgroundColor,
            una.colorScheme.muted,
          );
          expect(
            una.secondaryBadgeTheme.foregroundColor,
            una.colorScheme.foregroundSubtle,
          );
          expect(
            nova.secondaryBadgeTheme.backgroundColor,
            nova.colorScheme.secondary,
          );
          expect(
            nova.secondaryBadgeTheme.foregroundColor,
            nova.colorScheme.secondaryForeground,
          );
        });

        test('progressTrackFill and progressTinted reach progressBarTheme '
            '($label)', () {
          final una = ThemeData(
            brightness: brightness,
            formFactor: formFactor,
          );
          final nova = ThemeData(
            style: StyleTokens.nova,
            brightness: brightness,
            formFactor: formFactor,
          );
          // Track `--fill-2`, fill `--accent`.
          expect(una.progressBarTheme.color, una.colorScheme.tint);
          expect(
            una.progressBarTheme.trackColor,
            una.colorScheme.secondary,
          );
          expect(nova.progressBarTheme.color, nova.colorScheme.primary);
          expect(
            nova.progressBarTheme.trackColor,
            nova.colorScheme.muted,
          );
        });

        test('dividerMargin reaches dividerTheme ($label)', () {
          final una = ThemeData(
            brightness: brightness,
            formFactor: formFactor,
          );
          final nova = ThemeData(
            style: StyleTokens.nova,
            brightness: brightness,
            formFactor: formFactor,
          );
          expect(una.dividerTheme.horizontalMargin, EdgeInsets.zero);
          expect(una.dividerTheme.verticalMargin, EdgeInsets.zero);
          expect(
            nova.dividerTheme.horizontalMargin,
            const EdgeInsets.symmetric(vertical: 16),
          );
          expect(
            nova.dividerTheme.verticalMargin,
            const EdgeInsets.symmetric(horizontal: 16),
          );
        });

        test('timelineLineGap reaches timelineTheme ($label)', () {
          final una = ThemeData(
            brightness: brightness,
            formFactor: formFactor,
          );
          final nova = ThemeData(
            style: StyleTokens.nova,
            brightness: brightness,
            formFactor: formFactor,
          );
          expect(una.timelineTheme.lineGap, 8);
          expect(nova.timelineTheme.lineGap, 6);
        });
      }
    }

    test('each token moves its component theme on its own', () {
      final nova = ThemeData(style: StyleTokens.nova);
      final scheme = nova.colorScheme;
      ThemeData withStyle(StyleTokens style) => ThemeData(style: style);

      expect(
        withStyle(
          StyleTokens.nova.copyWith(secondaryButtonFill: SurfaceFill.muted),
        ).secondaryButtonTheme.backgroundColor,
        scheme.muted,
      );
      final badgeFill = withStyle(
        StyleTokens.nova.copyWith(secondaryBadgeFill: SurfaceFill.muted),
      ).secondaryBadgeTheme;
      expect(badgeFill.backgroundColor, scheme.muted);
      // The fill alone does not change the text colour…
      expect(badgeFill.foregroundColor, scheme.secondaryForeground);
      final badgeSubtle = withStyle(
        StyleTokens.nova.copyWith(secondaryBadgeSubtle: true),
      ).secondaryBadgeTheme;
      // …and the text colour alone does not change the fill.
      expect(badgeSubtle.foregroundColor, scheme.foregroundSubtle);
      expect(badgeSubtle.backgroundColor, scheme.secondary);

      final track = withStyle(
        StyleTokens.nova.copyWith(progressTrackFill: SurfaceFill.secondary),
      ).progressBarTheme;
      expect(track.trackColor, scheme.secondary);
      expect(track.color, scheme.primary);
      final tinted = withStyle(
        StyleTokens.nova.copyWith(progressTinted: true),
      ).progressBarTheme;
      expect(tinted.color, scheme.tint);
      expect(tinted.trackColor, scheme.muted);

      expect(
        withStyle(
          StyleTokens.nova.copyWith(dividerMargin: 4),
        ).dividerTheme.horizontalMargin,
        const EdgeInsets.symmetric(vertical: 4),
      );
      expect(
        withStyle(
          StyleTokens.nova.copyWith(timelineLineGap: 10),
        ).timelineTheme.lineGap,
        10,
      );
    });

    test('the two unit-based tokens follow the spacing step', () {
      const spacing = Spacing(step: 6);
      final nova = ThemeData(style: StyleTokens.nova, spacing: spacing);
      expect(
        nova.dividerTheme.horizontalMargin,
        const EdgeInsets.symmetric(vertical: 24),
      );
      expect(nova.timelineTheme.lineGap, 9);
      final una = ThemeData(spacing: spacing);
      expect(una.dividerTheme.horizontalMargin, EdgeInsets.zero);
      expect(una.timelineTheme.lineGap, 12);
    });

    test('the other variant derives the same five themes', () {
      for (final style in [StyleTokens.una, StyleTokens.nova]) {
        final a = ThemeData(style: style);
        final b = ThemeData(style: style, disableSecondaryBorder: true);
        expect(
          b.secondaryButtonTheme.backgroundColor,
          a.secondaryButtonTheme.backgroundColor,
          reason: style.name,
        );
        expect(
          b.secondaryBadgeTheme,
          a.secondaryBadgeTheme,
          reason: style.name,
        );
        expect(b.progressBarTheme, a.progressBarTheme, reason: style.name);
        expect(b.dividerTheme, a.dividerTheme, reason: style.name);
        expect(b.timelineTheme, a.timelineTheme, reason: style.name);
      }
    });

    testWidgets('a una Divider takes no room beyond its line; a nova one '
        'keeps 16 either side', (tester) async {
      Widget rule() => const Center(
        child: SizedBox(width: 200, child: Divider()),
      );
      await pumpUna(tester, rule());
      expect(tester.getSize(find.byType(Divider)).height, 1);

      await pumpUna(
        tester,
        rule(),
        theme: ThemeData(style: StyleTokens.nova),
      );
      expect(tester.getSize(find.byType(Divider)).height, 1 + 16 * 2);

      Widget upright() => const Center(
        child: SizedBox(height: 100, child: Divider.vertical()),
      );
      await pumpUna(tester, upright());
      expect(tester.getSize(find.byType(Divider)).width, 1);
      await pumpUna(
        tester,
        upright(),
        theme: ThemeData(style: StyleTokens.nova),
      );
      expect(tester.getSize(find.byType(Divider)).width, 1 + 16 * 2);
    });

    testWidgets('the tokens reach the widgets: secondary button and badge '
        'fills, the progress bar', (tester) async {
      for (final style in [StyleTokens.una, StyleTokens.nova]) {
        await pumpUna(
          tester,
          Center(
            child: Column(
              key: const Key('column'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Button.secondary(onPressed: () {}, child: const Text('Go')),
                const Badge.secondary(child: Text('Tag')),
                const SizedBox(width: 200, child: ProgressBar(value: .5)),
              ],
            ),
          ),
          theme: ThemeData(style: style),
        );
        expect(tester.takeException(), isNull, reason: style.name);
        final theme = themeOf(tester, find.byKey(const Key('column')));
        final una = style == StyleTokens.una;
        final scheme = theme.colorScheme;

        bool paintsFill(Finder of, Color color) => find
            .descendant(
              of: of,
              matching: find.byWidgetPredicate((w) {
                final decoration = switch (w) {
                  DecoratedBox(:final decoration) => decoration,
                  Container(:final decoration?) => decoration,
                  _ => null,
                };
                return switch (decoration) {
                      ShadowDecoration(:final decoration) =>
                        decoration is BoxDecoration &&
                            decoration.color == color,
                      BoxDecoration(color: final fill) => fill == color,
                      ShapeDecoration(color: final fill) => fill == color,
                      _ => false,
                    } ||
                    (w is ColoredBox && w.color == color);
              }),
            )
            .evaluate()
            .isNotEmpty;

        expect(
          paintsFill(
            find.byType(Button),
            una ? scheme.muted : scheme.secondary,
          ),
          isTrue,
          reason: '${style.name} secondary button',
        );
        expect(
          paintsFill(
            find.byType(Badge),
            una ? scheme.muted : scheme.secondary,
          ),
          isTrue,
          reason: '${style.name} secondary badge',
        );
        expect(
          DefaultTextStyle.of(tester.element(find.text('Tag'))).style.color,
          una ? scheme.foregroundSubtle : scheme.secondaryForeground,
          reason: '${style.name} secondary badge text',
        );
        // The progress bar: its track is a filled box, its fill a widget
        // that is handed the colour.
        expect(
          paintsFill(
            find.byType(ProgressBar),
            una ? scheme.secondary : scheme.muted,
          ),
          isTrue,
          reason: '${style.name} progress track',
        );
        expect(
          (tester
                      .widget<DecoratedBox>(
                        find.descendant(
                          of: find.descendant(
                            of: find.byType(ProgressBar),
                            matching: find.byType(FractionallySizedBox),
                          ),
                          matching: find.byType(DecoratedBox),
                        ),
                      )
                      .decoration
                  as BoxDecoration)
              .color,
          una ? scheme.tint : scheme.primary,
          reason: '${style.name} progress fill',
        );
      }
    });
  });

  group('ThemeData.baseStyle', () {
    test('on a desktop theme it is the style, and so is style', () {
      for (final style in styles) {
        final theme = ThemeData(style: style);
        expect(theme.baseStyle, style, reason: style.name);
        expect(theme.style, style, reason: style.name);
      }
    });

    test('on a phone it is still the style the theme was created with, '
        'while style is the phone metrics', () {
      for (final style in styles) {
        final theme = ThemeData(style: style, formFactor: FormFactor.mobile);
        expect(theme.baseStyle, style, reason: style.name);
        expect(theme.baseStyle, theme.variant.baseStyle, reason: style.name);
        expect(
          theme.style,
          style.forFormFactor(FormFactor.mobile),
          reason: style.name,
        );
        expect(theme.style, isNot(theme.baseStyle), reason: style.name);
        // The difference that matters: a phone's button is not a desktop's.
        expect(theme.style.buttonHeight, greaterThan(style.buttonHeight));
        expect(theme.baseStyle.buttonHeight, style.buttonHeight);
      }
      expect(
        ThemeData(formFactor: FormFactor.mobile).style,
        StyleTokens.unaMobile,
      );
    });

    test('survives withFormFactor in both directions', () {
      for (final style in styles) {
        final desktop = ThemeData(style: style);
        final mobile = desktop.withFormFactor(FormFactor.mobile);
        expect(mobile.baseStyle, style, reason: style.name);
        expect(
          mobile.withFormFactor(FormFactor.desktop).baseStyle,
          style,
          reason: style.name,
        );
      }
    });

    test('copyWith(style: theme.baseStyle) is a round trip on both form '
        'factors', () {
      for (final style in styles) {
        for (final formFactor in FormFactor.values) {
          for (final brightness in Brightness.values) {
            final theme = ThemeData(
              style: style,
              formFactor: formFactor,
              brightness: brightness,
            );
            final copy = theme.copyWith(style: theme.baseStyle);
            final reason = '${style.name} ${formFactor.name} $brightness';
            expect(copy, theme, reason: reason);
            expect(copy.hashCode, theme.hashCode, reason: reason);
            expect(copy.baseStyle, style, reason: reason);
            expect(copy.style, theme.style, reason: reason);
            expect(copy.formFactor, formFactor, reason: reason);
            expect(
              copy.buttonSizesTheme,
              theme.buttonSizesTheme,
              reason: reason,
            );
          }
        }
      }
    });

    test("ThemeData(style: other.baseStyle) reproduces a phone theme's "
        'style on either form factor', () {
      for (final style in styles) {
        final phone = ThemeData(style: style, formFactor: FormFactor.mobile);
        expect(
          ThemeData(style: phone.baseStyle, formFactor: FormFactor.mobile),
          phone,
          reason: style.name,
        );
        expect(
          ThemeData(style: phone.baseStyle),
          ThemeData(style: style),
          reason: style.name,
        );
      }
    });

    test("carrying a phone theme's style, not its baseStyle, bakes the "
        'phone metrics in as the desktop ones', () {
      final phone = ThemeData(formFactor: FormFactor.mobile);
      final wrong = ThemeData(style: phone.style);
      final right = ThemeData(style: phone.baseStyle);
      // A desktop theme with 44-point buttons: the mistake `baseStyle`
      // exists to avoid.
      expect(wrong.style.buttonHeight, 44);
      expect(right.style.buttonHeight, 36);
      expect(wrong, isNot(right));
    });

    test('a style changed on a phone theme keeps the phone', () {
      final phone = ThemeData(formFactor: FormFactor.mobile);
      final copy = phone.copyWith(style: StyleTokens.nova);
      expect(copy.baseStyle, StyleTokens.nova);
      expect(copy.formFactor, FormFactor.mobile);
      expect(copy.style, StyleTokens.nova.forFormFactor(FormFactor.mobile));
    });

    testWidgets('a UnaApp on a phone reports the style it was given', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const SizedBox.expand(key: Key('page')),
        theme: ThemeData(style: StyleTokens.maia),
        formFactor: FormFactor.mobile,
      );
      final theme = themeOf(tester, find.byKey(const Key('page')));
      expect(theme.formFactor, FormFactor.mobile);
      expect(theme.baseStyle, StyleTokens.maia);
      expect(theme.style, StyleTokens.maia.forFormFactor(FormFactor.mobile));
    });
  });

  group('ThemeData.buttonDecoration', () {
    const pill = BorderRadius.all(Radius.circular(999));
    const eight = BorderRadius.all(Radius.circular(8));

    test('applies the radius to the border', () {
      for (final style in styles) {
        final theme = ThemeData(style: style);
        for (final radius in [pill, eight, BorderRadius.zero]) {
          final decoration = theme.buttonDecoration(radius: radius);
          expect(decoration.border!.borderRadius, radius, reason: style.name);
        }
        expect(
          theme.buttonDecoration(radius: theme.radii.full).border!.borderRadius,
          theme.radii.full,
          reason: style.name,
        );
      }
    });

    test("the ring's radius is the radius plus the ring width, so the two "
        'curves are concentric', () {
      for (final style in styles) {
        for (final brightness in Brightness.values) {
          final theme = ThemeData(style: style, brightness: brightness);
          final ringWidth = theme.style.ringWidth;
          final ring = theme
              .buttonDecoration(radius: eight)
              .secondaryFocusedBorder!;
          final reason = '${style.name} $brightness';

          expect(
            ring.borderRadius,
            BorderRadius.all(Radius.circular(8 + ringWidth)),
            reason: reason,
          );
          // The theme's ring: its width, its colour at its opacity, flush
          // against the button.
          expect(ring.top!.width, ringWidth, reason: reason);
          expect(
            ring.top!.color,
            theme.colorScheme.ring.withValues(alpha: theme.style.ringOpacity),
            reason: reason,
          );
          expect(ring.offset, ringWidth, reason: reason);
        }
      }
    });

    test('each corner is inflated on its own, and a square corner stays '
        'square', () {
      final theme = ThemeData();
      final ringWidth = theme.style.ringWidth;
      const radius = BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(12),
        bottomRight: Radius.elliptical(6, 10),
      );
      final ring = theme
          .buttonDecoration(radius: radius)
          .secondaryFocusedBorder!;
      expect(
        ring.borderRadius,
        BorderRadius.only(
          topLeft: Radius.circular(4 + ringWidth),
          topRight: Radius.circular(12 + ringWidth),
          bottomRight: Radius.elliptical(6 + ringWidth, 10 + ringWidth),
          // bottomLeft was zero and stays zero: rounding it would round the
          // ring on a square button.
        ),
      );
      expect(
        theme
            .buttonDecoration(radius: BorderRadius.zero)
            .secondaryFocusedBorder!
            .borderRadius,
        BorderRadius.zero,
      );
    });

    test('there is no ring under disableSecondaryBorder: true', () {
      for (final style in styles) {
        for (final formFactor in FormFactor.values) {
          final theme = ThemeData(
            style: style,
            formFactor: formFactor,
            disableSecondaryBorder: true,
          );
          final decoration = theme.buttonDecoration(radius: pill);
          final reason = '${style.name} ${formFactor.name}';
          expect(decoration.secondaryFocusedBorder, isNull, reason: reason);
          // The shape is still applied.
          expect(decoration.border!.borderRadius, pill, reason: reason);
        }
      }
    });

    test('it sets the shape and the ring and nothing else', () {
      final decoration = ThemeData().buttonDecoration(radius: pill);
      expect(decoration.color, isNull);
      expect(decoration.shadows, isNull);
      expect(decoration.focusedBorder, isNull);
      expect(decoration.secondaryBorder, isNull);
      // No sides: the button's own outline, or lack of one, is kept.
      expect(decoration.border!.top, isNull);
      expect(decoration.border!.bottom, isNull);
    });

    test('it is a value: two calls compare equal', () {
      final theme = ThemeData();
      expect(
        theme.buttonDecoration(radius: pill),
        theme.buttonDecoration(radius: pill),
      );
      expect(
        theme.buttonDecoration(radius: pill),
        isNot(theme.buttonDecoration(radius: eight)),
      );
    });

    testWidgets('reshapes a Button, and its focus ring with it', (
      tester,
    ) async {
      useTraditionalHighlights();
      late ThemeData theme;
      await pumpUna(
        tester,
        Center(
          child: Builder(
            builder: (context) {
              theme = Theme.of(context);
              return Button.outline(
                style: ButtonTheme(
                  decoration: theme.buttonDecoration(
                    radius: theme.radii.full,
                  ),
                ),
                onPressed: () {},
                child: const Text('Follow'),
              );
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final decorator = tester.widget<Decorator>(
        find.descendant(
          of: find.byType(Button),
          matching: find.byType(Decorator),
        ),
      );
      expect(decorator.decoration!.border!.borderRadius, theme.radii.full);
      expect(
        decorator.decoration!.secondaryFocusedBorder!.borderRadius,
        theme
            .buttonDecoration(radius: theme.radii.full)
            .secondaryFocusedBorder!
            .borderRadius,
      );
      // An outline button keeps its outline: only the corners changed.
      final size = tester.getSize(find.byType(Button));
      expect(size.height, 36);
    });

    testWidgets('IconButton builds its shape through it', (tester) async {
      for (final disableSecondaryBorder in [false, true]) {
        await pumpUna(
          tester,
          Center(
            child: IconButton.secondary(
              icon: const Icon(PhosphorIconsRegular.plus),
              onPressed: () {},
            ),
          ),
          theme: ThemeData(disableSecondaryBorder: disableSecondaryBorder),
        );
        final theme = themeOf(tester, find.byType(IconButton));
        // una rounds its icon buttons through a style token.
        final token = theme.style.iconButtonRadius;
        expect(token, isNotNull);
        final expected = theme.buttonDecoration(
          radius: theme.radii.resolve(token!),
        );
        final decorator = tester.widget<Decorator>(
          find.descendant(
            of: find.byType(IconButton),
            matching: find.byType(Decorator),
          ),
        );
        final reason = 'disableSecondaryBorder: $disableSecondaryBorder';
        expect(
          decorator.decoration!.border!.borderRadius,
          expected.border!.borderRadius,
          reason: reason,
        );
        expect(
          decorator.decoration!.secondaryFocusedBorder?.borderRadius,
          expected.secondaryFocusedBorder?.borderRadius,
          reason: reason,
        );
        if (disableSecondaryBorder) {
          expect(expected.secondaryFocusedBorder, isNull);
        }
      }
    });
  });

  group('DefaultThemeVariant equality', () {
    DefaultThemeVariant variant({
      StyleTokens style = StyleTokens.una,
      FormFactor formFactor = FormFactor.desktop,
      ColorScheme? menuColorScheme,
      bool menuTranslucent = false,
      ColorScheme colorScheme = const BlueColorScheme.light(),
    }) {
      return DefaultThemeVariant(
        colorScheme: colorScheme,
        radius: const BorderRadius.all(Radius.circular(8)),
        effectiveTextTheme: TextTheme(),
        style: style,
        formFactor: formFactor,
        menuColorScheme: menuColorScheme,
        menuTranslucent: menuTranslucent,
      );
    }

    test('two variants built alike are equal and hash alike', () {
      expect(variant(), variant());
      expect(variant().hashCode, variant().hashCode);
      final full = variant(
        style: StyleTokens.nova,
        formFactor: FormFactor.mobile,
        menuColorScheme: const BlueColorScheme.dark(),
        menuTranslucent: true,
      );
      final same = variant(
        style: StyleTokens.nova,
        formFactor: FormFactor.mobile,
        menuColorScheme: const BlueColorScheme.dark(),
        menuTranslucent: true,
      );
      expect(full, same);
      expect(full.hashCode, same.hashCode);
    });

    test('the form factor tells two variants apart', () {
      final desktop = variant();
      final mobile = variant(formFactor: FormFactor.mobile);
      expect(mobile, isNot(desktop));
      expect(mobile.hashCode, isNot(desktop.hashCode));
    });

    test('the base style tells two variants apart even when their resolved '
        'styles agree', () {
      // A phone variant of una and a desktop variant handed una's
      // phone metrics resolve to the same `style`…
      final phone = variant(formFactor: FormFactor.mobile);
      final baked = variant(style: StyleTokens.unaMobile);
      expect(baked.style, phone.style);
      // …but are not the same variant: one goes back to 36-point buttons on
      // a desktop and the other does not.
      expect(baked.baseStyle, isNot(phone.baseStyle));
      expect(baked, isNot(phone));

      // And the same base style on the same form factor is what matters.
      final mobileOfMobile = variant(
        style: StyleTokens.unaMobile,
        formFactor: FormFactor.mobile,
      );
      expect(mobileOfMobile.style, phone.style);
      expect(mobileOfMobile, isNot(phone));
    });

    test('a different style tells two variants apart', () {
      expect(variant(style: StyleTokens.nova), isNot(variant()));
      expect(
        variant(style: StyleTokens.una.copyWith(dividerMargin: 4)),
        isNot(variant()),
      );
    });

    test('the menu colour scheme tells two variants apart', () {
      final plain = variant();
      final inverted = variant(menuColorScheme: const BlueColorScheme.dark());
      expect(inverted, isNot(plain));
      expect(inverted.hashCode, isNot(plain.hashCode));
      expect(
        inverted,
        isNot(variant(menuColorScheme: const ZincColorScheme.dark())),
      );
      // Null is "follow the page", which is not the same as naming the
      // page's own scheme.
      expect(
        variant(menuColorScheme: const BlueColorScheme.light()),
        isNot(plain),
      );
    });

    test('menuTranslucent tells two variants apart', () {
      final solid = variant();
      final glass = variant(menuTranslucent: true);
      expect(glass, isNot(solid));
      expect(glass.hashCode, isNot(solid.hashCode));
    });

    test('rebuild with nothing changed is equal; with any of the four '
        'changed it is not', () {
      final base = variant(
        menuColorScheme: const BlueColorScheme.dark(),
        menuTranslucent: true,
      );
      expect(base.rebuild(), base);
      expect(base.rebuild().hashCode, base.hashCode);
      expect(base.rebuild(formFactor: FormFactor.mobile), isNot(base));
      expect(base.rebuild(style: StyleTokens.nova), isNot(base));
      expect(base.rebuild(menuColorScheme: null), isNot(base));
      expect(base.rebuild(menuTranslucent: false), isNot(base));
      // And back again.
      expect(
        base
            .rebuild(formFactor: FormFactor.mobile)
            .rebuild(formFactor: FormFactor.desktop),
        base,
      );
    });

    test('the two variant classes are never equal to each other', () {
      final secondary = variant();
      final none = DefaultThemeNoSecondaryBorderVariant(
        colorScheme: const BlueColorScheme.light(),
        radius: const BorderRadius.all(Radius.circular(8)),
        effectiveTextTheme: TextTheme(),
      );
      expect(none, isNot(secondary));
      expect(secondary, isNot(none));
      expect(
        none,
        DefaultThemeNoSecondaryBorderVariant(
          colorScheme: const BlueColorScheme.light(),
          radius: const BorderRadius.all(Radius.circular(8)),
          effectiveTextTheme: TextTheme(),
        ),
      );
    });

    test('themes that differ only in a menu setting are different themes', () {
      final plain = ThemeData();
      expect(ThemeData(menuTranslucent: true), isNot(plain));
      expect(
        ThemeData(menuColorScheme: const BlueColorScheme.dark()),
        isNot(plain),
      );
      expect(
        ThemeData(menuTranslucent: true),
        ThemeData(menuTranslucent: true),
      );
      expect(
        ThemeData(menuColorScheme: const BlueColorScheme.dark()),
        ThemeData(menuColorScheme: const BlueColorScheme.dark()),
      );
    });
  });
}
