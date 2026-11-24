import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Locks the value-equality chain behind [ThemeData].
///
/// [FinesseApp] wraps its child in a [AnimatedTheme], an
/// [ImplicitlyAnimatedWidget] that starts a 200ms transition whenever the new
/// theme is not `==` the old one. Every field of [ThemeData] therefore has
/// to be a proper value type, or an app that constructs its theme inline
/// re-lerps all 54 component themes on every single rebuild.
void main() {
  ThemeData buildTheme() => ThemeData(
    colorScheme: const NeutralColorScheme.light(),
    brightness: Brightness.light,
  );

  group('ThemeData equality', () {
    test('two identically-constructed themes are equal', () {
      final a = buildTheme();
      final b = buildTheme();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('decoration is a value type (FinesseBorder ==)', () {
      // Regression: FinesseBorder had no operator==, so FinesseDecoration.== fell
      // back to identity and every ThemeData was unequal.
      expect(buildTheme().decoration, equals(buildTheme().decoration));
    });

    test('breakpoints is a value type (Breakpoints ==)', () {
      // Regression: Breakpoints had no operator== and the factory
      // allocates a fresh instance per ThemeData.
      expect(buildTheme().breakpoints, equals(buildTheme().breakpoints));
      expect(Breakpoints(), equals(Breakpoints()));
      expect(Breakpoints().hashCode, equals(Breakpoints().hashCode));
    });

    test('breakpoints of different sizes are not equal', () {
      expect(Breakpoints(), isNot(equals(Breakpoints(md: 900))));
    });

    test('copyWith with no arguments returns an equal theme', () {
      final theme = buildTheme();
      expect(theme.copyWith(), equals(theme));
    });

    test('copyWith preserves a custom variant', () {
      // Regression: `variant` was constructor-only and never stored, so
      // copyWith silently reset it to DefaultThemeVariant. Dialog,
      // Tooltip and Sonner all call copyWith in build().
      final variant = DefaultThemeNoSecondaryBorderVariant(
        colorScheme: const NeutralColorScheme.light(),
        radius: const BorderRadius.all(Radius.circular(6)),
        effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
      );
      final theme = ThemeData(
        colorScheme: const NeutralColorScheme.light(),
        brightness: Brightness.light,
        variant: variant,
      );

      expect(theme.variant, same(variant));
      expect(theme.copyWith().variant, same(variant));
      expect(theme.copyWith(disabledOpacity: .3).variant, same(variant));
    });

    test('a genuine difference still compares unequal', () {
      final a = buildTheme();
      final b = ThemeData(
        colorScheme: const NeutralColorScheme.dark(),
        brightness: Brightness.dark,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('FinesseBorder / FinesseBorderSide equality', () {
    test('identical border sides are equal and hash alike', () {
      // Regression: `==` and `hashCode` referenced the `merge` METHOD tear-off
      // instead of the `canMerge` field, so every instance hashed uniquely.
      const a = FinesseBorderSide(color: Color(0xFF00FF00), width: 2);
      const b = FinesseBorderSide(color: Color(0xFF00FF00), width: 2);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('border sides differing only in canMerge are not equal', () {
      const a = FinesseBorderSide(color: Color(0xFF00FF00), canMerge: false);
      const b = FinesseBorderSide(color: Color(0xFF00FF00));
      expect(a, isNot(equals(b)));
    });

    test('identical borders are equal and hash alike', () {
      final a = FinesseBorder.all(color: const Color(0xFF0000FF), width: 1);
      final b = FinesseBorder.all(color: const Color(0xFF0000FF), width: 1);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('borders differing in a single field are not equal', () {
      expect(
        FinesseBorder.all(width: 1),
        isNot(equals(FinesseBorder.all(width: 2))),
      );
    });

    test('copyWith preserves canMerge', () {
      expect(FinesseBorder.none.copyWith(offset: 2).canMerge, isFalse);
    });

    test('== is symmetric against the superellipse subclass', () {
      const base = FinesseBorder(offset: 2);
      const sub = FinesseRoundedSuperellipseBorder(canMerge: false);

      expect(base == sub, isFalse);
      expect(sub == base, isFalse);
    });

    test('superellipse borders compare all fields', () {
      const a = FinesseRoundedSuperellipseBorder(
        radius: BorderRadius.all(Radius.circular(4)),
      );
      const b = FinesseRoundedSuperellipseBorder(
        radius: BorderRadius.all(Radius.circular(4)),
      );
      const c = FinesseRoundedSuperellipseBorder(
        radius: BorderRadius.all(Radius.circular(8)),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      // Regression: hashCode was `side.hashCode`, ignoring radius.
      expect(a, isNot(equals(c)));
      expect(a.hashCode, isNot(equals(c.hashCode)));
    });
  });

  group('ColorScheme', () {
    test('swapping two colors changes the hash', () {
      // Regression: hashCode was a chain of `^`, which is commutative.
      const a = NeutralColorScheme.light();
      final swapped = a.copyWith(primary: a.secondary, secondary: a.primary);

      expect(a, isNot(equals(swapped)));
      expect(a.hashCode, isNot(equals(swapped.hashCode)));
    });

    test('copyWith preserves canMerge', () {
      // Regression: copyWith dropped canMerge, and merge() is built on
      // copyWith, so the "replace, don't merge" opt-out was unrecoverable.
      final scheme = const NeutralColorScheme.light().copyWith(
        canMerge: false,
      );
      expect(scheme.copyWith(primary: const Color(0xFFFF0000)).canMerge, false);
    });

    test('equal custom maps hash alike', () {
      // Regression: hashed MapEntry objects, which hash by identity, while
      // `==` used mapEquals.
      final a = const NeutralColorScheme.light().copyWith(
        custom: {'brand': const Color(0xFF123456)},
      );
      final b = const NeutralColorScheme.light().copyWith(
        custom: {'brand': const Color(0xFF123456)},
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('TextTheme', () {
    // copyWith has no canMerge parameter, so rebuild through .custom.
    TextTheme withCanMerge(TextTheme base, {required bool canMerge}) =>
        TextTheme.custom(
          canMerge: canMerge,
          h1Large: base.h1Large,
          h1: base.h1,
          h2: base.h2,
          h3: base.h3,
          h4: base.h4,
          p: base.p,
          blockquote: base.blockquote,
          table: base.table,
          list: base.list,
          lead: base.lead,
          large: base.large,
          small: base.small,
          muted: base.muted,
          family: base.family,
          googleFontBuilder: base.googleFontBuilder,
          custom: base.custom,
        );

    test('themes differing only in canMerge are equal and hash alike', () {
      // Regression: canMerge was in hashCode but not in ==, so two themes
      // could be equal while hashing differently.
      final a = TextTheme(family: 'Geist');
      final b = withCanMerge(a, canMerge: false);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('lerp preserves canMerge', () {
      final a = withCanMerge(TextTheme(family: 'Geist'), canMerge: false);
      final b = withCanMerge(TextTheme(family: 'Geist'), canMerge: false);

      expect(TextTheme.lerp(a, b, 0)!.canMerge, isFalse);
      expect(TextTheme.lerp(a, b, 1)!.canMerge, isFalse);
    });

    test('lerp of two nulls returns null instead of throwing', () {
      expect(TextTheme.lerp(null, null, .5), isNull);
    });
  });

  testWidgets('an inline theme does not re-animate on every rebuild', (
    tester,
  ) async {
    // The end-to-end symptom: FinesseApp rebuilding with an equal-but-new
    // ThemeData used to restart a 200ms lerp across all component themes,
    // republishing a new theme every frame.
    final rebuild = ValueNotifier(0);
    addTearDown(rebuild.dispose);
    final seen = <ThemeData>[];

    await tester.pumpWidget(
      ValueListenableBuilder<int>(
        valueListenable: rebuild,
        builder: (context, value, _) {
          return FinesseApp(
            theme: ThemeData(
              colorScheme: const NeutralColorScheme.light(),
              brightness: Brightness.light,
            ),
            home: Builder(
              builder: (context) {
                seen.add(Theme.of(context));
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    final settled = seen.last;
    seen.clear();

    rebuild.value = 1;
    await tester.pump();
    // Advance past where a 200ms theme transition would have run.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      seen.every((theme) => theme == settled),
      isTrue,
      reason: 'the theme should not be animated when it did not change',
    );
  });

  group('list fields compare by value', () {
    // A theme built inline allocates fresh lists on every build; the
    // generated `==` alone compared them by identity.
    List<BoxShadow> shadows() => [
      const BoxShadow(blurRadius: 3, color: Color(0x11000000)),
    ];

    test('component themes with equal, non-identical lists are equal', () {
      final a = PopoverTheme(shadows: shadows());
      final b = PopoverTheme(shadows: shadows());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        CardTheme(shadows: shadows()),
        CardTheme(shadows: shadows()),
      );
      // Deliberately non-const: const lists would be identical anyway.
      expect(
        // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
        SheetTheme(snapSizes: [0.5, 1]),
        // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
        SheetTheme(snapSizes: [0.5, 1]),
      );
    });

    test('different lists still differ', () {
      expect(
        PopoverTheme(shadows: shadows()),
        isNot(const PopoverTheme(shadows: [])),
      );
    });

    test('a theme with an inline override equals its rebuild', () {
      ThemeData build() => ThemeData(
        colorScheme: const NeutralColorScheme.light(),
        brightness: Brightness.light,
        cardTheme: CardTheme(shadows: shadows()),
      );
      expect(build(), build());
    });
  });

  group('the default theme and the finesse component themes', () {
    // The eleven themes the fork added, read off a theme.
    List<Object?> finesseThemes(ThemeData t) => [
      t.glassTheme,
      t.appBarTheme,
      t.navigationBarTheme,
      t.bottomNavigationBarTheme,
      t.chipTheme,
      t.listTileTheme,
      t.chatBubbleTheme,
      t.indicatorBadgeTheme,
      t.iconTileTheme,
      t.timelineTheme,
      t.layoutTheme,
    ];

    test('two separately built default themes are equal', () {
      // What `FinesseApp()` with no theme, or `theme: ThemeData()` written
      // inline, hands `AnimatedTheme` on every build.
      final a = ThemeData();
      final b = ThemeData();
      expect(identical(a, b), isFalse);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a.variant, equals(b.variant));
      expect(a.variant.hashCode, equals(b.variant.hashCode));
    });

    test('in both brightnesses, form factors and variants', () {
      for (final brightness in Brightness.values) {
        for (final formFactor in FormFactor.values) {
          for (final disableSecondaryBorder in [false, true]) {
            ThemeData build() => ThemeData(
              brightness: brightness,
              formFactor: formFactor,
              disableSecondaryBorder: disableSecondaryBorder,
            );
            final reason = '$brightness $formFactor $disableSecondaryBorder';
            expect(build(), equals(build()), reason: reason);
            expect(build().hashCode, build().hashCode, reason: reason);
          }
        }
      }
    });

    test('for every shipped style', () {
      for (final style in StyleTokens.all) {
        for (final formFactor in FormFactor.values) {
          ThemeData build() => ThemeData(style: style, formFactor: formFactor);
          expect(build(), equals(build()), reason: style.name);
          expect(build().hashCode, build().hashCode, reason: style.name);
        }
      }
    });

    test('each new component theme is a value type', () {
      for (final brightness in Brightness.values) {
        final a = finesseThemes(ThemeData(brightness: brightness));
        final b = finesseThemes(ThemeData(brightness: brightness));
        for (var i = 0; i < a.length; i++) {
          expect(a[i], equals(b[i]), reason: '${a[i].runtimeType}');
          expect(
            a[i].hashCode,
            b[i].hashCode,
            reason: '${a[i].runtimeType}',
          );
        }
      }
    });

    test('each new component theme tells a real difference apart', () {
      final light = finesseThemes(ThemeData());
      final dark = finesseThemes(ThemeData(brightness: Brightness.dark));
      for (var i = 0; i < light.length; i++) {
        // The layout theme is all metrics, so brightness does not move it.
        if (light[i] is LayoutTheme) {
          expect(light[i], equals(dark[i]));
        } else {
          expect(
            light[i],
            isNot(equals(dark[i])),
            reason: '${light[i].runtimeType}',
          );
        }
      }
      expect(
        ThemeData().layoutTheme,
        isNot(ThemeData(formFactor: FormFactor.mobile).layoutTheme),
      );
    });

    test('a form factor, a style or a scheme makes a different theme', () {
      final base = ThemeData();
      expect(base, isNot(ThemeData(formFactor: FormFactor.mobile)));
      expect(base, isNot(ThemeData(style: StyleTokens.nova)));
      expect(
        base,
        isNot(ThemeData(colorScheme: const NeutralColorScheme.light())),
      );
      expect(base, isNot(ThemeData(brightness: Brightness.dark)));
      // And saying the defaults out loud does not.
      expect(
        base,
        ThemeData(
          style: StyleTokens.finesse,
          colorScheme: const TealColorScheme.light(),
          formFactor: FormFactor.desktop,
          brightness: Brightness.light,
          radius: const BorderRadius.all(Radius.circular(10)),
        ),
      );
    });

    test('an override of a new component theme survives and compares', () {
      ThemeData build() => ThemeData(
        chipTheme: const ChipTheme(height: 28),
        layoutTheme: const LayoutTheme(gapLg: 20),
        glassTheme: const GlassTheme(blur: 8),
      );
      final theme = build();
      expect(theme.chipTheme.height, 28);
      // Merged over the derived theme, not replacing it.
      expect(theme.chipTheme.radius, ThemeData().chipTheme.radius);
      expect(theme.layoutTheme.gap(GapSize.lg), 20);
      expect(theme.layoutTheme.gap(GapSize.md), 12);
      expect(theme.glassTheme.blur, 8);
      expect(theme.glassTheme.saturation, ThemeData().glassTheme.saturation);
      expect(theme, equals(build()));
      expect(theme, isNot(ThemeData()));
      // And it outlives a form-factor switch.
      final mobile = theme.withFormFactor(FormFactor.mobile);
      expect(mobile.chipTheme.height, 28);
      expect(mobile.layoutTheme.gap(GapSize.lg), 20);
    });

    test('StyleTokens compare by value, mobile counterpart included', () {
      expect(StyleTokens.finesse.copyWith(), StyleTokens.finesse);
      expect(
        StyleTokens.finesse.copyWith().hashCode,
        StyleTokens.finesse.hashCode,
      );
      expect(StyleTokens.finesse, isNot(StyleTokens.finesseMobile));
      // Two derived mobile styles are separate instances and equal.
      final a = StyleTokens.nova.forFormFactor(FormFactor.mobile);
      final b = StyleTokens.nova.forFormFactor(FormFactor.mobile);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      // A style that differs only in its mobile counterpart is different.
      expect(
        StyleTokens.nova.copyWith(mobile: StyleTokens.finesseMobile),
        isNot(StyleTokens.nova),
      );
    });

    testWidgets('a default FinesseApp does not re-animate on a rebuild', (
      tester,
    ) async {
      final rebuild = ValueNotifier(0);
      addTearDown(rebuild.dispose);
      final seen = <ThemeData>[];

      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: rebuild,
          builder: (context, value, _) {
            return FinesseApp(
              // No theme: the app builds its default one on every build.
              home: Builder(
                builder: (context) {
                  seen.add(Theme.of(context));
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      final settled = seen.last;
      seen.clear();

      rebuild.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(seen.every((theme) => theme == settled), isTrue);
    });
  });
}
