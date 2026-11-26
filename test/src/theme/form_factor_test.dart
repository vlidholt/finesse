import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../fixture_styles.dart';

/// A style carries two sets of metrics, and the theme's form factor picks
/// one. These lock the numbers that make a phone layout a phone layout —
/// 44-point controls, 15-point body text, 16-point page margins — and the
/// plumbing that gets them from `StyleTokens` through `ThemeData` to
/// `UnaApp`.
void main() {
  group('una through ThemeData(formFactor:)', () {
    final desktop = ThemeData();
    final mobile = ThemeData(formFactor: FormFactor.mobile);

    test('a theme is desktop unless told otherwise', () {
      expect(desktop.formFactor, FormFactor.desktop);
      expect(desktop.style, StyleTokens.una);
      expect(mobile.formFactor, FormFactor.mobile);
      expect(mobile.style, StyleTokens.unaMobile);
      // The variant remembers the style it was asked for, not only the one
      // it resolved.
      expect(mobile.variant.baseStyle, StyleTokens.una);
      expect(desktop.variant.baseStyle, StyleTokens.una);
    });

    test('button, input and chip are 36/40/32 on a desktop', () {
      expect(desktop.buttonSizesTheme.regular!.height, 36);
      expect(desktop.buttonSizesTheme.sm!.height, 32);
      expect(desktop.buttonSizesTheme.lg!.height, 44);
      expect(desktop.buttonSizesTheme.icon!.height, 36);
      expect(desktop.textFieldTheme.constraints!.minHeight, 40);
      expect(desktop.selectTheme.minHeight, 40);
      expect(desktop.chipTheme.height, 32);
    });

    test('and 44/46/36 on a phone', () {
      expect(mobile.buttonSizesTheme.regular!.height, 44);
      expect(mobile.buttonSizesTheme.sm!.height, 36);
      expect(mobile.buttonSizesTheme.lg!.height, 48);
      expect(mobile.buttonSizesTheme.icon!.height, 44);
      expect(mobile.textFieldTheme.constraints!.minHeight, 46);
      expect(mobile.selectTheme.minHeight, 46);
      expect(mobile.chipTheme.height, 36);
    });

    test('body text is 14 on a desktop and 15 on a phone', () {
      expect(desktop.textTheme.p.fontSize, 14);
      expect(desktop.textTheme.list.fontSize, 14);
      expect(mobile.textTheme.p.fontSize, 15);
      expect(mobile.textTheme.list.fontSize, 15);
      expect(mobile.textTheme.p.height, closeTo(22 / 15, 1e-9));
      // The text inside a field follows.
      expect(desktop.textFieldTheme.style!.fontSize, 14);
      expect(mobile.textFieldTheme.style!.fontSize, 15);
    });

    test('the una style owns the prose scale', () {
      // shadcn's typography examples are a fixed prose scale; a style that
      // names display/headline/subtitle/small rewrites them.
      expect(desktop.textTheme.h1.fontSize, 30);
      expect(mobile.textTheme.h1.fontSize, 28);
      expect(desktop.textTheme.h3.fontSize, 20);
      expect(desktop.textTheme.h4.fontSize, 16);
      expect(desktop.textTheme.large.fontSize, 15);
      expect(desktop.textTheme.large.fontWeight, FontWeight.w600);
      expect(desktop.textTheme.small.fontSize, 13);
      expect(desktop.textTheme.muted.fontSize, 13);
      // vega names none of them, so its prose stays the shadcn scale.
      final vega = ThemeData(style: FixtureStyles.vega);
      expect(vega.textTheme.p.fontSize, 16);
      expect(vega.textTheme.small.fontSize, 14);
      expect(vega.textTheme.large.fontSize, 18);
    });

    test('page padding is 24 on a desktop and 16 on a phone', () {
      expect(desktop.layoutTheme.pagePadding, const EdgeInsets.all(24));
      expect(mobile.layoutTheme.pagePadding, const EdgeInsets.all(16));
      // The app bar lines its content up with the page.
      expect(
        desktop.appBarTheme.padding,
        const EdgeInsets.symmetric(horizontal: 24),
      );
      expect(
        mobile.appBarTheme.padding,
        const EdgeInsets.symmetric(horizontal: 16),
      );
    });

    test('the rest of the phone metrics follow', () {
      expect(desktop.appBarTheme.height, 64);
      expect(mobile.appBarTheme.height, 44);
      expect(desktop.layoutTheme.gap(GapSize.lg), 16);
      expect(mobile.layoutTheme.gap(GapSize.lg), 12);
      expect(desktop.layoutTheme.gap(GapSize.xl), 24);
      expect(mobile.layoutTheme.gap(GapSize.xl), 16);
      // The small steps are the same on both.
      for (final size in [GapSize.none, GapSize.xs, GapSize.sm, GapSize.md]) {
        expect(
          mobile.layoutTheme.gap(size),
          desktop.layoutTheme.gap(size),
          reason: '$size',
        );
      }
      // Cards round a step further on a phone: 2xl (18) against 3xl (20).
      expect(desktop.cardTheme.borderRadius!.topLeft.x, closeTo(18, 1e-9));
      expect(mobile.cardTheme.borderRadius!.topLeft.x, closeTo(20, 1e-9));
      expect(desktop.cardTheme.padding, const EdgeInsets.all(20));
      expect(mobile.cardTheme.padding, const EdgeInsets.all(16));
      expect(desktop.tabsTheme.tabHeight, 32);
      expect(mobile.tabsTheme.tabHeight, 36);
      expect(desktop.checkboxTheme.size, 18);
      expect(mobile.checkboxTheme.size, 20);
      expect(desktop.switchTheme.width, 36);
      expect(mobile.switchTheme.width, 58);
    });

    test('the mobile metrics apply to both variants', () {
      final noRing = ThemeData(
        formFactor: FormFactor.mobile,
        disableSecondaryBorder: true,
      );
      expect(noRing.variant, isA<DefaultThemeNoSecondaryBorderVariant>());
      expect(noRing.formFactor, FormFactor.mobile);
      expect(noRing.buttonSizesTheme.regular!.height, 44);
      expect(noRing.chipTheme.height, 36);
      expect(noRing.layoutTheme.pagePadding, const EdgeInsets.all(16));
    });

    test('the spacing unit scales the unit-based metrics on a phone too', () {
      final wide = ThemeData(
        formFactor: FormFactor.mobile,
        spacing: const Spacing(step: 5),
      );
      expect(wide.buttonSizesTheme.regular!.height, 55);
      expect(wide.chipTheme.height, 45);
      expect(wide.layoutTheme.pagePadding, const EdgeInsets.all(20));
    });
  });

  group('StyleTokens.forFormFactor', () {
    test('desktop is the style itself', () {
      for (final style in StyleTokens.all) {
        expect(
          style.forFormFactor(FormFactor.desktop),
          same(style),
          reason: style.name,
        );
      }
    });

    test('una names its mobile counterpart', () {
      expect(StyleTokens.una.mobile, same(StyleTokens.unaMobile));
      expect(
        StyleTokens.una.forFormFactor(FormFactor.mobile),
        same(StyleTokens.unaMobile),
      );
      expect(StyleTokens.unaMobile.name, 'una');
    });

    test('a style with no explicit mobile derives one', () {
      const nova = StyleTokens.nova;
      expect(nova.mobile, isNull);
      final mobile = nova.forFormFactor(FormFactor.mobile);

      expect(mobile, isNot(nova));
      expect(mobile.name, 'nova');
      // Controls grow to touch targets.
      expect(nova.buttonHeight, 32);
      expect(mobile.buttonHeight, 44);
      expect(mobile.buttonHeightSm, 36);
      expect(mobile.buttonHeightLg, 48);
      expect(mobile.iconButtonSize, 44);
      expect(mobile.iconButtonSizeLg, 48);
      expect(mobile.inputHeight, 44);
      expect(mobile.commandSearchHeight, 44);
      expect(mobile.calendarCellSize, 40);
      expect(mobile.sidebarItemHeight, 44);
      expect(mobile.menubarHeight, 44);
      expect(mobile.itemPaddingY, 10);
      expect(mobile.chipHeight, 36);
      expect(mobile.checkboxSize, 20);
      expect(mobile.radioSize, 20);
      // Body and field text grow to 15 on a 22px line.
      expect(mobile.body, const TextRole(fontSize: 15, height: 22 / 15));
      expect(mobile.field, const TextRole(fontSize: 15, height: 22 / 15));
      // Page chrome tightens.
      expect(mobile.pagePaddingX, 16);
      expect(mobile.pagePaddingY, 16);
      expect(mobile.appBarHeight, 60);
      expect(mobile.gapLg, 12);
      expect(mobile.gapXl, 16);
      // Everything that is not a touch metric is nova's still.
      expect(mobile.buttonRadius, nova.buttonRadius);
      expect(mobile.cardPadding, nova.cardPadding);
      expect(mobile.title, nova.title);
      expect(mobile.label, nova.label);
      expect(mobile.ringWidth, nova.ringWidth);
      expect(mobile.radius, nova.radius);
    });

    test('derivation only ever grows a control', () {
      // A style that is already larger than the touch minimum keeps its own
      // numbers.
      const roomy = StyleTokens(
        name: 'roomy',
        buttonHeight: 52,
        inputHeight: 56,
        chipHeight: 40,
        body: TextRole(fontSize: 17),
      );
      final mobile = roomy.forFormFactor(FormFactor.mobile);
      expect(mobile.buttonHeight, 52);
      expect(mobile.inputHeight, 56);
      expect(mobile.chipHeight, 40);
      expect(mobile.body, const TextRole(fontSize: 17));
    });

    test('a mobile style is a fixed point', () {
      // `theme.style` hands back the resolved style, and code that feeds it
      // into `copyWith(style:)` must not see the metrics move again.
      for (final style in StyleTokens.all) {
        final mobile = style.forFormFactor(FormFactor.mobile);
        expect(
          mobile.forFormFactor(FormFactor.mobile),
          mobile,
          reason: style.name,
        );
      }
    });

    test('the derived metrics reach the component themes', () {
      final theme = ThemeData(
        style: StyleTokens.nova,
        formFactor: FormFactor.mobile,
      );
      expect(theme.style, StyleTokens.nova.forFormFactor(FormFactor.mobile));
      expect(theme.variant.baseStyle, StyleTokens.nova);
      expect(theme.buttonSizesTheme.regular!.height, 44);
      expect(theme.textFieldTheme.constraints!.minHeight, 44);
      expect(theme.chipTheme.height, 36);
      expect(theme.textFieldTheme.style!.fontSize, 15);
      expect(theme.layoutTheme.pagePadding, const EdgeInsets.all(16));
      // nova names the app type roles, so it owns the scale and the body
      // role the phone grew to 15 is its paragraph size too.
      expect(theme.style.body.fontSize, 15);
      expect(theme.textTheme.p.fontSize, 15);
      // A style that names none of them keeps shadcn's prose scale, which is
      // not the style's to change: its body role still grows, its `p` does
      // not follow.
      final bare = ThemeData(
        style: FixtureStyles.vega,
        formFactor: FormFactor.mobile,
      );
      expect(bare.style.body.fontSize, 15);
      expect(bare.textFieldTheme.style!.fontSize, 15);
      expect(bare.textTheme.p.fontSize, 16);
    });

    test('every shipped style is at least touch-sized on a phone', () {
      for (final style in StyleTokens.all) {
        final theme = ThemeData(style: style, formFactor: FormFactor.mobile);
        expect(
          theme.buttonSizesTheme.regular!.height,
          greaterThanOrEqualTo(44),
          reason: style.name,
        );
        expect(
          theme.textFieldTheme.constraints!.minHeight,
          greaterThanOrEqualTo(44),
          reason: style.name,
        );
        expect(
          theme.chipTheme.height,
          greaterThanOrEqualTo(36),
          reason: style.name,
        );
      }
    });
  });

  group('ThemeData.withFormFactor', () {
    test('returns this when the form factor is unchanged', () {
      final desktop = ThemeData();
      final mobile = ThemeData(formFactor: FormFactor.mobile);
      expect(desktop.withFormFactor(FormFactor.desktop), same(desktop));
      expect(mobile.withFormFactor(FormFactor.mobile), same(mobile));
    });

    test('called twice it returns an equal theme, and the same instance', () {
      final desktop = ThemeData();
      final first = desktop.withFormFactor(FormFactor.mobile);
      final second = desktop.withFormFactor(FormFactor.mobile);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      // Cached per theme, so `UnaApp` can call it on every build.
      expect(second, same(first));
    });

    test('equals a theme built for that form factor directly', () {
      final direct = ThemeData(formFactor: FormFactor.mobile);
      final derived = ThemeData().withFormFactor(FormFactor.mobile);
      expect(derived.formFactor, FormFactor.mobile);
      expect(derived, direct);
      expect(derived.hashCode, direct.hashCode);
    });

    test('two equal themes derive equal themes without sharing a cache', () {
      // An app that builds its theme inline hands `UnaApp` a new
      // instance per build; the derived themes must still be `==`.
      final a = ThemeData().withFormFactor(FormFactor.mobile);
      final b = ThemeData().withFormFactor(FormFactor.mobile);
      expect(identical(a, b), isFalse);
      expect(a, b);
    });

    test('a round trip restores the original metrics', () {
      final desktop = ThemeData();
      final back = desktop
          .withFormFactor(FormFactor.mobile)
          .withFormFactor(FormFactor.desktop);
      expect(back.formFactor, FormFactor.desktop);
      expect(back, desktop);
    });

    test('keeps the inputs the theme was built from', () {
      final theme = ThemeData(
        colorScheme: const ZincColorScheme.dark(),
        style: StyleTokens.maia,
        radius: const BorderRadius.all(Radius.circular(4)),
        spacing: const Spacing(step: 5),
        disableSecondaryBorder: true,
        cardTheme: const CardTheme(padding: EdgeInsets.all(3)),
      );
      final mobile = theme.withFormFactor(FormFactor.mobile);

      expect(mobile.colorScheme, const ZincColorScheme.dark());
      expect(mobile.brightness, Brightness.dark);
      expect(mobile.variant.baseStyle, StyleTokens.maia);
      expect(mobile.radius.topLeft.x, 4);
      expect(mobile.spacing.step, 5);
      expect(mobile.variant, isA<DefaultThemeNoSecondaryBorderVariant>());
      expect(mobile.cardTheme.padding, const EdgeInsets.all(3));
      // 44 at the default step, scaled by 5/4.
      expect(mobile.buttonSizesTheme.regular!.height, 55);
    });

    test('rebuilds a supplied variant for the new form factor', () {
      final variant = DefaultThemeVariant(
        colorScheme: const NeutralColorScheme.light(),
        radius: const BorderRadius.all(Radius.circular(6)),
        effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
        style: StyleTokens.nova,
      );
      final theme = ThemeData(variant: variant);
      expect(theme.variant, same(variant));
      expect(theme.formFactor, FormFactor.desktop);

      final mobile = theme.withFormFactor(FormFactor.mobile);
      expect(mobile.formFactor, FormFactor.mobile);
      expect(mobile.variant.baseStyle, StyleTokens.nova);
      expect(mobile.radius.topLeft.x, 6);
      expect(mobile.buttonSizesTheme.regular!.height, 44);
    });

    test('a variant built for mobile makes a mobile theme', () {
      final theme = ThemeData(
        variant: DefaultThemeVariant(
          colorScheme: const BlueColorScheme.light(),
          radius: const BorderRadius.all(Radius.circular(10)),
          effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
          formFactor: FormFactor.mobile,
        ),
      );
      expect(theme.formFactor, FormFactor.mobile);
      expect(theme.style, StyleTokens.unaMobile);
      expect(theme.buttonSizesTheme.regular!.height, 44);
    });
  });

  group('lerp between form factors', () {
    test('does not throw anywhere along the way', () {
      for (final disableSecondaryBorder in [false, true]) {
        for (final brightness in Brightness.values) {
          final desktop = ThemeData(
            brightness: brightness,
            disableSecondaryBorder: disableSecondaryBorder,
          );
          final mobile = desktop.withFormFactor(FormFactor.mobile);
          for (final t in [0.0, .1, .25, .49, .5, .75, .99, 1.0]) {
            final mid = ThemeData.lerp(desktop, mobile, t);
            expect(mid, isNotNull, reason: 't=$t');
            final back = ThemeData.lerp(mobile, desktop, t);
            expect(back, isNotNull, reason: 't=$t');
          }
        }
      }
    });

    test('the metrics move continuously and the form factor flips halfway', () {
      final desktop = ThemeData();
      final mobile = ThemeData(formFactor: FormFactor.mobile);

      final early = ThemeData.lerp(desktop, mobile, .25)!;
      final late = ThemeData.lerp(desktop, mobile, .75)!;
      expect(early.formFactor, FormFactor.desktop);
      expect(late.formFactor, FormFactor.mobile);
      // 36 -> 44.
      expect(early.buttonSizesTheme.regular!.height, closeTo(38, 1e-6));
      expect(late.buttonSizesTheme.regular!.height, closeTo(42, 1e-6));
      // 32 -> 36.
      expect(early.chipTheme.height, closeTo(33, 1e-6));
      expect(
        ThemeData.lerp(desktop, mobile, .5)!.layoutTheme.pagePadding,
        const EdgeInsets.all(20),
      );
    });

    test('also between two different styles', () {
      final a = ThemeData(style: StyleTokens.nova);
      final b = ThemeData(
        style: StyleTokens.lyra,
        formFactor: FormFactor.mobile,
      );
      for (final t in [0.0, .3, .5, .7, 1.0]) {
        expect(ThemeData.lerp(a, b, t), isNotNull, reason: 't=$t');
      }
    });
  });

  group('UnaApp', () {
    Future<FormFactor> pumpAt(
      WidgetTester tester,
      double width, {
      FormFactor? formFactor,
      ThemeData? theme,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.reset);

      late ThemeData seen;
      await tester.pumpWidget(
        UnaApp(
          theme: theme,
          formFactor: formFactor,
          home: Builder(
            builder: (context) {
              seen = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // Past any theme transition a resize started.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      return seen.formFactor;
    }

    void expectSameMetrics(ThemeData actual, ThemeData expected) {
      expect(actual.variant, expected.variant);
      expect(actual.style, expected.style);
      expect(actual.textTheme, expected.textTheme);
      expect(actual.buttonSizesTheme, expected.buttonSizesTheme);
      expect(actual.primaryButtonTheme, expected.primaryButtonTheme);
      expect(actual.textFieldTheme, expected.textFieldTheme);
      expect(actual.cardTheme, expected.cardTheme);
      expect(actual.chipTheme, expected.chipTheme);
      expect(actual.appBarTheme, expected.appBarTheme);
      expect(
        actual.bottomNavigationBarTheme,
        expected.bottomNavigationBarTheme,
      );
      expect(actual.layoutTheme, expected.layoutTheme);
    }

    testWidgets('picks mobile below the md breakpoint', (tester) async {
      expect(await pumpAt(tester, 390), FormFactor.mobile);
      expect(await pumpAt(tester, 767), FormFactor.mobile);
    });

    testWidgets('picks desktop at and above it', (tester) async {
      expect(await pumpAt(tester, 768), FormFactor.desktop);
      expect(await pumpAt(tester, 1280), FormFactor.desktop);
    });

    testWidgets('follows the logical width, not the physical one', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(1170, 2532);
      addTearDown(tester.view.reset);

      late ThemeData seen;
      await tester.pumpWidget(
        UnaApp(
          home: Builder(
            builder: (context) {
              seen = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // 1170 physical pixels at 3x is a 390-point phone.
      expect(seen.formFactor, FormFactor.mobile);
      expect(seen.buttonSizesTheme.regular!.height, 44);
    });

    testWidgets("uses the theme's own md breakpoint", (tester) async {
      final theme = ThemeData(breakpoints: Breakpoints(md: 1000));
      expect(await pumpAt(tester, 900, theme: theme), FormFactor.mobile);
      expect(await pumpAt(tester, 1000, theme: theme), FormFactor.desktop);
    });

    testWidgets('an explicit formFactor wins over the window', (tester) async {
      expect(
        await pumpAt(tester, 390, formFactor: FormFactor.desktop),
        FormFactor.desktop,
      );
      expect(
        await pumpAt(tester, 1280, formFactor: FormFactor.mobile),
        FormFactor.mobile,
      );
    });

    testWidgets('switches on the very next frame when the window is resized '
        'across the breakpoint', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);

      final seen = <ThemeData>[];
      await tester.pumpWidget(
        UnaApp(
          home: Builder(
            builder: (context) {
              seen.add(Theme.of(context));
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.last.formFactor, FormFactor.desktop);
      expect(seen.last.buttonSizesTheme.regular!.height, 36);

      // One frame, and no time: the first frame in the narrower window must
      // already be laid out for a phone. A frame of desktop metrics at phone
      // width is the frame a desktop app bar overflows on.
      seen.clear();
      tester.view.physicalSize = const Size(390, 800);
      await tester.pump();
      expect(seen, isNotEmpty);
      for (final theme in seen) {
        expect(theme.formFactor, FormFactor.mobile);
        expect(theme.buttonSizesTheme.regular!.height, 44);
      }
      // Settled exactly on the mobile theme, not somewhere between the two.
      expectSameMetrics(seen.last, ThemeData(formFactor: FormFactor.mobile));

      // And nothing moves afterwards: two form factors are two layouts, not
      // the ends of a range to animate across.
      seen.clear();
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
      }
      for (final theme in seen) {
        expect(theme.buttonSizesTheme.regular!.height, 44);
      }

      seen.clear();
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pump();
      expect(seen.last.formFactor, FormFactor.desktop);
      expect(seen.last.buttonSizesTheme.regular!.height, 36);
      expectSameMetrics(seen.last, ThemeData());
    });

    testWidgets('never shows a metric between the two form factors', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);

      final heights = <double>{};
      await tester.pumpWidget(
        UnaApp(
          home: Builder(
            builder: (context) {
              heights.add(Theme.of(context).buttonSizesTheme.regular!.height);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      for (final width in [390.0, 1280.0, 500.0, 900.0]) {
        tester.view.physicalSize = Size(width, 800);
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 40));
        }
      }
      expect(heights, {36, 44});
    });

    testWidgets('a change of scheme alone is applied at once, under a '
        'cross-fade', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);

      final light = ThemeData(brightness: Brightness.light);
      final dark = ThemeData(brightness: Brightness.dark);
      late ThemeData seen;
      Widget app(ThemeMode mode) => UnaApp(
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        home: Builder(
          builder: (context) {
            seen = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      await tester.pumpWidget(app(ThemeMode.light));
      expect(seen.colorScheme.background, light.colorScheme.background);

      await tester.pumpWidget(app(ThemeMode.dark));
      // The app is never built with a theme between the two: the old look
      // fades out over the new one as a picture (`CrossFadeTheme`).
      expect(seen.colorScheme.background, dark.colorScheme.background);
      expect(seen.formFactor, FormFactor.desktop);
      expect(seen.buttonSizesTheme.regular!.height, 36);
      expect(tester.binding.hasScheduledFrame, isTrue, reason: 'the fade');

      // The fade is timed from the frame after the rebuild.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(seen.colorScheme.background, dark.colorScheme.background);
      await tester.pump(const Duration(milliseconds: 150));
      expect(seen.colorScheme.background, dark.colorScheme.background);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a form factor and a scheme changing together snap together', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.reset);

      final light = ThemeData(brightness: Brightness.light);
      final dark = ThemeData(brightness: Brightness.dark);
      late ThemeData seen;
      Widget app(ThemeMode mode) => UnaApp(
        theme: light,
        darkTheme: dark,
        themeMode: mode,
        home: Builder(
          builder: (context) {
            seen = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      );

      await tester.pumpWidget(app(ThemeMode.light));
      tester.view.physicalSize = const Size(390, 800);
      await tester.pumpWidget(app(ThemeMode.dark));
      expect(seen.formFactor, FormFactor.mobile);
      expect(seen.colorScheme.background, dark.colorScheme.background);
    });

    testWidgets('applies the form factor to the dark theme too', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 800);
      addTearDown(tester.view.reset);

      late ThemeData seen;
      await tester.pumpWidget(
        UnaApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: ThemeData(brightness: Brightness.dark),
          themeMode: ThemeMode.dark,
          home: Builder(
            builder: (context) {
              seen = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.brightness, Brightness.dark);
      expect(seen.colorScheme, const BlueColorScheme.dark());
      expect(seen.formFactor, FormFactor.mobile);
    });

    testWidgets('UnaApp.custom resolves it as well', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 800);
      addTearDown(tester.view.reset);

      late ThemeData seen;
      await tester.pumpWidget(
        UnaApp.custom(
          appBuilder: (context) {
            seen = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(seen.formFactor, FormFactor.mobile);
    });

    testWidgets('an inline theme does not re-animate on a phone', (
      tester,
    ) async {
      // `withFormFactor` caches per instance, and an inline theme is a new
      // instance per build; what keeps `AnimatedTheme` still is that the
      // derived themes are equal by value.
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 800);
      addTearDown(tester.view.reset);

      final rebuild = ValueNotifier(0);
      addTearDown(rebuild.dispose);
      final seen = <ThemeData>[];

      await tester.pumpWidget(
        ValueListenableBuilder<int>(
          valueListenable: rebuild,
          builder: (context, value, _) {
            return UnaApp(
              theme: ThemeData(),
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
      expect(settled.formFactor, FormFactor.mobile);
      seen.clear();

      rebuild.value = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(seen.every((theme) => theme == settled), isTrue);
    });
  });

  group('ThemeDataTween', () {
    test('snaps to the end when the form factor changes — at t = 0 too', () {
      final desktop = ThemeData();
      final mobile = ThemeData(formFactor: FormFactor.mobile);
      final tween = ThemeDataTween(begin: desktop, end: mobile);

      // `Tween.transform` hands back `begin` at 0 without calling `lerp`,
      // and an implicit animation's first frame is t = 0: that frame has to
      // be the new layout as well.
      for (final t in [0.0, .001, .5, .999, 1.0]) {
        expect(tween.transform(t), same(mobile), reason: 't=$t');
        expect(tween.lerp(t), same(mobile), reason: 't=$t');
      }
      final back = ThemeDataTween(begin: mobile, end: desktop);
      expect(back.transform(0), same(desktop));
    });

    test('interpolates when only something else changes', () {
      final light = ThemeData();
      final dark = ThemeData(brightness: Brightness.dark);
      final tween = ThemeDataTween(begin: light, end: dark);

      expect(tween.transform(0), same(light));
      expect(tween.transform(1), same(dark));
      final mid = tween.transform(.5);
      expect(
        mid.colorScheme.background,
        Color.lerp(
          light.colorScheme.background,
          dark.colorScheme.background,
          .5,
        ),
      );
      expect(mid.formFactor, FormFactor.desktop);
    });

    test('a style change within one form factor still interpolates', () {
      final tween = ThemeDataTween(
        begin: ThemeData(style: StyleTokens.nova),
        end: ThemeData(style: StyleTokens.maia),
      );
      // 32 -> 36.
      expect(
        tween.transform(.5).buttonSizesTheme.regular!.height,
        closeTo(34, 1e-6),
      );
    });
  });

  group('FormFactorBuilder', () {
    testWidgets("builds the branch for the theme's form factor", (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await tester.pumpWidget(
          UnaApp(
            formFactor: formFactor,
            home: FormFactorBuilder(
              mobile: (context) => const Text('phone'),
              desktop: (context) => const Text('desk'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          find.text(formFactor == FormFactor.mobile ? 'phone' : 'desk'),
          findsOneWidget,
        );
        expect(
          find.text(formFactor == FormFactor.mobile ? 'desk' : 'phone'),
          findsNothing,
        );
      }
    });
  });
}
