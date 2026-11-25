import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixture_styles.dart';

void main() {
  group('Radii', () {
    // shadcn/ui's scale at the default --radius: sm 6, md 8, lg 10, xl 14,
    // 2xl 16, 4xl 32. Pinning the numbers is the only way this stays honest.
    const radii = Radii(BorderRadius.all(Radius.circular(8)));

    test('reproduces the shadcn scale from the md step', () {
      expect(radii.none, BorderRadius.zero);
      expect(radii.sm.topLeft.x, 6);
      expect(radii.md.topLeft.x, 8);
      expect(radii.lg.topLeft.x, 10);
      expect(radii.xl.topLeft.x, 14);
      expect(radii.xl2.topLeft.x, 16);
      expect(radii.xl4.topLeft.x, 32);
      expect(radii.full.topLeft.x, greaterThan(1000));
    });

    test('resolve covers every token', () {
      for (final token in RadiusToken.values) {
        expect(radii.resolve(token), isA<BorderRadius>());
      }
      expect(radii.resolve(RadiusToken.lg), radii.lg);
    });

    test('a zero base radius stays square at every step', () {
      const square = Radii(BorderRadius.zero);
      for (final token in RadiusToken.values) {
        if (token == RadiusToken.full) continue;
        expect(square.resolve(token), BorderRadius.zero, reason: '$token');
      }
    });

    test('scales each corner independently', () {
      const lopsided = Radii(
        BorderRadius.only(
          topLeft: Radius.circular(4),
          bottomRight: Radius.circular(8),
        ),
      );
      expect(lopsided.xl2.topLeft.x, 8);
      expect(lopsided.xl2.bottomRight.x, 16);
      expect(lopsided.xl2.topRight, Radius.zero);
    });

    test('equality is by the base radius', () {
      expect(
        const Radii(BorderRadius.all(Radius.circular(8))),
        const Radii(BorderRadius.all(Radius.circular(8))),
      );
      expect(
        const Radii(BorderRadius.all(Radius.circular(8))).hashCode,
        const Radii(BorderRadius.all(Radius.circular(8))).hashCode,
      );
      expect(
        const Radii(BorderRadius.all(Radius.circular(8))),
        isNot(const Radii(BorderRadius.all(Radius.circular(9)))),
      );
    });
  });

  group('RadiusScale', () {
    test("the default is Tailwind's", () {
      const scale = RadiusScale();
      expect(
        (scale.sm, scale.lg, scale.xl, scale.xl2, scale.xl3, scale.xl4),
        (.75, 1.25, 1.75, 2.0, 3.0, 4.0),
      );
      // Which is what a `Radii` built without one uses.
      expect(const Radii(BorderRadius.zero).scale, scale);
      expect(StyleTokens.nova.radiusScale, scale);
      expect(StyleTokens.maia.radiusScale, scale);
      expect(StyleTokens.lyra.radiusScale, scale);
    });

    test('finesse at a base of 10 gives 6/10/12/16/18/20/24', () {
      const radii = Radii(
        BorderRadius.all(Radius.circular(10)),
        RadiusScale(sm: .6, lg: 1.2, xl: 1.6, xl2: 1.8, xl3: 2, xl4: 2.4),
      );
      expect(StyleTokens.finesse.radius, 10);
      expect(StyleTokens.finesse.radiusScale, radii.scale);
      expect(StyleTokens.finesseMobile.radiusScale, radii.scale);

      expect(radii.none, BorderRadius.zero);
      expect(radii.sm.topLeft.x, closeTo(6, 1e-9));
      expect(radii.md.topLeft.x, 10);
      expect(radii.lg.topLeft.x, closeTo(12, 1e-9));
      expect(radii.xl.topLeft.x, closeTo(16, 1e-9));
      expect(radii.xl2.topLeft.x, closeTo(18, 1e-9));
      expect(radii.xl3.topLeft.x, closeTo(20, 1e-9));
      expect(radii.xl4.topLeft.x, closeTo(24, 1e-9));
      expect(radii.full.topLeft.x, greaterThan(1000));
      // Every corner, both axes.
      expect(radii.xl2.bottomRight.y, closeTo(18, 1e-9));
    });

    test('the default theme carries that scale and base', () {
      final theme = ThemeData();
      expect(theme.radius, const BorderRadius.all(Radius.circular(10)));
      expect(theme.radii.scale, StyleTokens.finesse.radiusScale);
      expect(
        [
          for (final token in [
            RadiusToken.sm,
            RadiusToken.md,
            RadiusToken.lg,
            RadiusToken.xl,
            RadiusToken.xl2,
            RadiusToken.xl3,
            RadiusToken.xl4,
          ])
            theme.radii.resolve(token).topLeft.x.roundToDouble(),
        ],
        [6, 10, 12, 16, 18, 20, 24],
      );
      // On both form factors.
      expect(
        ThemeData(formFactor: FormFactor.mobile).radii,
        theme.radii,
      );
    });

    test('the finesse surfaces land on the scale', () {
      final theme = ThemeData();
      double radiusOf(BorderRadiusGeometry? r) =>
          r!.resolve(TextDirection.ltr).topLeft.x;

      // Controls at the base, cards at 2xl, dialogs at 3xl, popovers at lg.
      expect(
        radiusOf(theme.primaryButtonTheme.decoration!.border!.borderRadius),
        10,
      );
      expect(
        radiusOf(theme.textFieldTheme.decoration!.border!.borderRadius),
        10,
      );
      expect(radiusOf(theme.cardTheme.borderRadius), closeTo(18, 1e-9));
      expect(
        radiusOf(theme.primaryDialogTheme.borderRadius),
        closeTo(20, 1e-9),
      );
      expect(
        radiusOf(theme.popoverTheme.decoration!.border!.borderRadius),
        closeTo(12, 1e-9),
      );
      expect(
        radiusOf(theme.tooltipTheme.decoration!.border!.borderRadius),
        closeTo(6, 1e-9),
      );
      // Glass panels are cards.
      expect(theme.glassTheme.borderRadius, theme.cardTheme.borderRadius);
    });

    test('a theme radius rescales the finesse steps', () {
      final theme = ThemeData(
        radius: const BorderRadius.all(Radius.circular(20)),
      );
      expect(theme.radii.sm.topLeft.x, closeTo(12, 1e-9));
      expect(theme.radii.xl2.topLeft.x, closeTo(36, 1e-9));
      expect(theme.cardTheme.borderRadius!.topLeft.x, closeTo(36, 1e-9));
    });

    test('the shadcn styles keep a base of 8 on the Tailwind scale', () {
      for (final style in [StyleTokens.nova, StyleTokens.maia]) {
        final theme = ThemeData(style: style);
        expect(theme.radius.topLeft.x, 8, reason: style.name);
        expect(theme.radii.sm.topLeft.x, 6, reason: style.name);
        expect(theme.radii.lg.topLeft.x, 10, reason: style.name);
        expect(theme.radii.xl.topLeft.x, 14, reason: style.name);
        expect(theme.radii.xl2.topLeft.x, 16, reason: style.name);
        expect(theme.radii.xl4.topLeft.x, 32, reason: style.name);
      }
    });

    test('equality, hash and toString are by value', () {
      const a = RadiusScale(sm: .6, lg: 1.2);
      // Built at runtime so the analyzer cannot canonicalise it with `a`.
      final b = RadiusScale(sm: [.6].first, lg: 1.2);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const RadiusScale(sm: .6)));
      expect(a.toString(), contains('sm: 0.6'));
    });

    test('a Radii compares its scale as well as its base', () {
      const base = BorderRadius.all(Radius.circular(10));
      expect(
        const Radii(base, RadiusScale(xl2: 1.8)),
        const Radii(base, RadiusScale(xl2: 1.8)),
      );
      expect(
        const Radii(base, RadiusScale(xl2: 1.8)).hashCode,
        const Radii(base, RadiusScale(xl2: 1.8)).hashCode,
      );
      expect(
        const Radii(base, RadiusScale(xl2: 1.8)),
        isNot(const Radii(base)),
      );
    });
  });

  group('StyleTokens', () {
    test('ships four styles, uniquely named, the default first', () {
      expect(StyleTokens.all, [
        StyleTokens.finesse,
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]);
      expect(
        StyleTokens.all.map((s) => s.name).toSet(),
        hasLength(4),
      );
      for (final style in StyleTokens.all) {
        expect(StyleTokens.fromName(style.name), style);
      }
    });

    test('fromName rejects an unknown name', () {
      expect(() => StyleTokens.fromName('nope'), throwsArgumentError);
      // The shadcn styles finesse dropped are unknown names now.
      for (final name in ['vega', 'mira', 'luma', 'sera', 'rhea']) {
        expect(
          () => StyleTokens.fromName(name),
          throwsArgumentError,
          reason: name,
        );
      }
    });

    test('the square styles are square everywhere', () {
      for (final style in [StyleTokens.lyra, FixtureStyles.sera]) {
        expect(style.buttonRadius, RadiusToken.none, reason: style.name);
        expect(style.cardRadius, RadiusToken.none, reason: style.name);
        expect(style.dialogRadius, RadiusToken.none, reason: style.name);
        expect(style.popoverRadius, RadiusToken.none, reason: style.name);
        expect(style.itemRadius, RadiusToken.none, reason: style.name);
      }
    });

    test('sera upper-cases and letter-spaces its labels', () {
      expect(FixtureStyles.sera.label.applyCase('Save'), 'SAVE');
      expect(FixtureStyles.vega.label.applyCase('Save'), 'Save');

      const base = TextStyle(fontSize: 14);
      final applied = FixtureStyles.sera.label.apply(base);
      expect(applied.fontSize, 12);
      expect(applied.fontWeight, FontWeight.w600);
      expect(applied.letterSpacing, 1.2);
    });

    test('a role keeps the colour and family it is applied to', () {
      const base = TextStyle(
        fontSize: 14,
        color: Color(0xFF00FF00),
        fontFamily: 'Geist',
      );
      final applied = StyleTokens.lyra.body.apply(base);
      expect(applied.fontSize, 12);
      expect(applied.color, const Color(0xFF00FF00));
      expect(applied.fontFamily, 'Geist');
    });

    test('roles size text per style', () {
      // The observation this models: the styles resize text, they do not just
      // reshape boxes.
      expect(StyleTokens.nova.body.fontSize, 14); // text-sm
      expect(StyleTokens.maia.body.fontSize, 14); // text-sm
      expect(StyleTokens.lyra.body.fontSize, 12); // text-xs
      expect(StyleTokens.nova.title.fontSize, 16); // text-base
      expect(StyleTokens.lyra.title.fontSize, 14); // text-sm
      expect(StyleTokens.nova.title.height, 1.375); // leading-snug
      // The defaults a custom style starts from are shadcn's `vega`.
      expect(const StyleTokens(name: 'custom').body.fontSize, 14);
      expect(const StyleTokens(name: 'custom').title.fontSize, 16);
    });

    test('line height defaults follow Tailwind', () {
      expect(TextRole.defaultHeightFor(12), 16 / 12);
      expect(TextRole.defaultHeightFor(14), 20 / 14);
      expect(TextRole.defaultHeightFor(16), 24 / 16);
      expect(TextRole.defaultHeightFor(18), 28 / 18);
    });

    test('a style without the app type roles keeps the prose scale', () {
      // shadcn's typography examples use fixed Tailwind classes; in a style
      // that names none of display/headline/subtitle/small, the other roles
      // reach components through their theme slots and leave the text theme
      // alone. mira and sera resize their body and label roles; vega is the
      // defaults.
      for (final style in const [
        FixtureStyles.vega,
        FixtureStyles.mira,
        FixtureStyles.sera,
      ]) {
        expect(style.display, isNull, reason: style.name);
        expect(style.headline, isNull, reason: style.name);
        expect(style.subtitle, isNull, reason: style.name);
        expect(style.small, isNull, reason: style.name);
      }
      final vega = ThemeData(style: FixtureStyles.vega);
      final mira = ThemeData(style: FixtureStyles.mira);
      final sera = ThemeData(style: FixtureStyles.sera);

      expect(vega.textTheme.small.fontSize, 14);
      expect(vega.textTheme.small.fontWeight, FontWeight.w500);
      expect(vega.textTheme.small.height, 1);
      expect(vega.textTheme.large.fontSize, 18);
      expect(vega.textTheme.large.fontWeight, FontWeight.w600);
      expect(vega.textTheme.muted.fontWeight, FontWeight.w400);
      expect(vega.textTheme.p.fontSize, 16);
      expect(mira.textTheme.small.fontSize, 14);
      expect(mira.textTheme.muted.fontSize, 14);
      expect(mira.textTheme.p.fontSize, 16);
      expect(sera.textTheme.large.fontSize, 18);
      expect(mira.textTheme.h4.fontSize, vega.textTheme.h4.fontSize);
      expect(vega.textTheme.h1.letterSpacing, -0.9);

      // Buttons still pick up the style's label role.
      expect(mira.primaryButtonTheme.textStyle!.fontSize, 12);
      expect(vega.primaryButtonTheme.textStyle!.fontSize, 14);
    });

    test('each shipped style publishes its own app type scale', () {
      // h1 takes `display`, h3 `headline`, h4 the `title` role, p the `body`
      // role, large `subtitle`, and small and muted `small`. A role that
      // names no weight (body, small) keeps the text theme's own.
      void expectScale(
        ThemeData theme, {
        required double h1,
        required double h1Tracking,
        required double h3,
        required double h4,
        required FontWeight h4Weight,
        required double p,
        required double large,
        required double small,
      }) {
        final name = '${theme.variant.baseStyle.name} ${theme.formFactor.name}';
        final text = theme.textTheme;
        expect(text.h1.fontSize, h1, reason: '$name h1');
        expect(text.h1.fontWeight, FontWeight.w700, reason: '$name h1');
        expect(text.h1.letterSpacing, h1Tracking, reason: '$name h1');
        expect(text.h3.fontSize, h3, reason: '$name h3');
        expect(text.h3.fontWeight, FontWeight.w600, reason: '$name h3');
        expect(text.h4.fontSize, h4, reason: '$name h4');
        expect(text.h4.fontWeight, h4Weight, reason: '$name h4');
        expect(text.p.fontSize, p, reason: '$name p');
        expect(text.p.fontWeight, FontWeight.w400, reason: '$name p');
        expect(text.list.fontSize, p, reason: '$name list');
        expect(text.large.fontSize, large, reason: '$name large');
        expect(text.large.fontWeight, FontWeight.w600, reason: '$name large');
        expect(text.small.fontSize, small, reason: '$name small');
        expect(text.small.fontWeight, FontWeight.w500, reason: '$name small');
        expect(text.muted.fontSize, small, reason: '$name muted');
        expect(text.muted.fontWeight, FontWeight.w400, reason: '$name muted');
      }

      // nova and maia share one scale: display 30/36, headline 20/28,
      // subtitle 14/20 and small 13/18, over a 16-point medium title and
      // 14-point body.
      for (final style in const [StyleTokens.nova, StyleTokens.maia]) {
        final theme = ThemeData(style: style);
        expectScale(
          theme,
          h1: 30,
          h1Tracking: -.75,
          h3: 20,
          h4: 16,
          h4Weight: FontWeight.w500,
          p: 14,
          large: 14,
          small: 13,
        );
        expect(theme.textTheme.h1.height, 36 / 30, reason: style.name);
        expect(theme.textTheme.h3.height, 28 / 20, reason: style.name);
        expect(theme.textTheme.h3.letterSpacing, -.4, reason: style.name);
        expect(theme.textTheme.large.height, 20 / 14, reason: style.name);
        expect(theme.textTheme.small.height, 18 / 13, reason: style.name);
        expect(theme.textTheme.muted.height, 18 / 13, reason: style.name);
      }

      // lyra is a step smaller throughout: display 24/32, headline 18/24,
      // subtitle 13/18 and small 12/16, over a 14-point title and 12-point
      // body.
      final lyra = ThemeData(style: StyleTokens.lyra);
      expectScale(
        lyra,
        h1: 24,
        h1Tracking: -.6,
        h3: 18,
        h4: 14,
        h4Weight: FontWeight.w500,
        p: 12,
        large: 13,
        small: 12,
      );
      expect(lyra.textTheme.h1.height, 32 / 24);
      expect(lyra.textTheme.h3.height, 24 / 18);
      expect(lyra.textTheme.large.height, 18 / 13);
      expect(lyra.textTheme.small.height, 16 / 12);
      expect(lyra.textTheme.muted.height, 16 / 12);

      // finesse is unchanged, on a desktop and on a phone.
      expectScale(
        ThemeData(),
        h1: 30,
        h1Tracking: -.75,
        h3: 20,
        h4: 16,
        h4Weight: FontWeight.w600,
        p: 14,
        large: 15,
        small: 13,
      );
      final phone = ThemeData(formFactor: FormFactor.mobile);
      expect(phone.textTheme.h1.fontSize, 28);
      expect(phone.textTheme.p.fontSize, 15);
      expect(phone.textTheme.h3.fontSize, 20);
      expect(phone.textTheme.large.fontSize, 15);
      expect(phone.textTheme.small.fontSize, 13);
      expect(phone.textTheme.muted.fontSize, 13);
    });

    test('a textarea keeps a moderate radius in the round styles', () {
      // maia has rounded-4xl buttons but a rounded-xl textarea: a 32px radius
      // on a tall box eats into the text.
      final maia = ThemeData(style: StyleTokens.maia);
      final buttonRadius =
          (maia.primaryButtonTheme.decoration!.border!.borderRadius!
                  as BorderRadius)
              .topLeft
              .x;
      final textareaRadius =
          (maia.textareaTheme.decoration!.border!.borderRadius! as BorderRadius)
              .topLeft
              .x;

      expect(buttonRadius, 32);
      expect(textareaRadius, 14);
      expect(textareaRadius, lessThan(buttonRadius));
    });

    test(
      'OTP slots round only the ends of the strip, at the control radius',
      () {
        final maia = ThemeData(style: StyleTokens.maia);

        expect(maia.otpFieldTheme.middleBorderRadius, BorderRadius.zero);
        expect(maia.otpFieldTheme.firstBorderRadius!.topLeft.x, 32);
        expect(maia.otpFieldTheme.firstBorderRadius!.topRight.x, 0);
        expect(maia.otpFieldTheme.lastBorderRadius!.topRight.x, 32);
        // A slot is the size of a control.
        expect(
          maia.otpFieldTheme.height,
          maia.buttonSizesTheme.regular!.height,
        );
      },
    );

    test('every field ring is concentric with its own shape', () {
      // The ring used to be built once from the control radius, so a textarea
      // — which has a radius of its own — was ringed in the wrong shape.
      final maia = ThemeData(style: StyleTokens.maia);

      final controlRing =
          maia.decoration.secondaryFocusedBorder!.borderRadius! as BorderRadius;
      final textareaRing =
          maia.textareaTheme.decoration!.secondaryFocusedBorder!.borderRadius!
              as BorderRadius;

      // Element radius plus ring width, in both cases.
      expect(controlRing.topLeft.x, 32 + maia.style.ringWidth);
      expect(textareaRing.topLeft.x, 14 + maia.style.ringWidth);
    });

    test('OTP slots ring like any other field', () {
      final vega = ThemeData(style: FixtureStyles.vega);
      final ring = vega.otpFieldTheme.decoration!.secondaryFocusedBorder!.top!;

      expect(ring.width, vega.style.ringWidth);
      expect(ring.color!.a, closeTo(vega.style.ringOpacity, .001));
      // The focused border itself is a hairline in the ring colour, not the
      // opaque 2px box it used to draw.
      expect(vega.otpFieldTheme.decoration!.focusedBorder!.top!.width, 1);
    });

    test('a textarea reads its own theme, not the input theme', () {
      // Textarea resolved padding, alignment and gap from `textFieldTheme`,
      // which made every textarea-specific value in `textareaTheme` dead —
      // a multi-line field was padded like a single-line one.
      final theme = ThemeData(style: StyleTokens.nova);

      expect(
        theme.textareaTheme.padding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      );
      expect(
        theme.textFieldTheme.padding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    });

    test('a single-line field centres its text in its fixed height', () {
      final theme = ThemeData(style: StyleTokens.nova);

      // nova sizes its fields `h-8`.
      expect(theme.textFieldTheme.constraints!.minHeight, 32);
      expect(theme.textFieldTheme.alignment, AlignmentDirectional.centerStart);
      expect(
        theme.textFieldTheme.placeholderAlignment,
        AlignmentDirectional.centerStart,
      );
    });

    test('checkbox and radio share their unchecked look', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final fill = theme.checkboxTheme.uncheckedColor;

        expect(fill, theme.radioTheme.decoration!.color, reason: '$brightness');
        expect(
          theme.checkboxTheme.decoration!.border!.top!.color,
          theme.colorScheme.input,
        );
        expect(
          theme.radioTheme.decoration!.border!.top!.color,
          theme.colorScheme.input,
        );
      }
    });

    test('overlays are light and blurred, as shadcn draws them', () {
      final theme = ThemeData();

      // `bg-black/10` — light enough that the palette behind stays visible,
      // which only works because the barrier is also blurred.
      expect(theme.primaryDialogTheme.barrierColor, const Color(0x1a000000));
      expect(theme.primaryDialogTheme.barrierBlurSigma, 2);
      expect(theme.alertDialogTheme.barrierColor, const Color(0x1a000000));
    });

    test('tabs are as wide as their labels, not the bar', () {
      // shadcn's TabsList is `w-fit`; ours stretched every tab across the
      // whole bar, which read as enormous padding inside it.
      final theme = ThemeData(style: StyleTokens.nova);
      expect(theme.tabsTheme.expandTabs ?? false, isFalse);
      expect(theme.tabsTheme.padding, const EdgeInsets.all(3)); // p-[3px]
      expect(
        theme.tabsTheme.tabPadding,
        // nova's `px-1.5 py-0.5`.
        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      );
    });

    test('dark borders are translucent overlays, as shadcn defines them', () {
      // shadcn v4 sets `--border: oklch(1 0 0 / 10%)` and `--input: 15%` in
      // dark mode, so a hairline lightens whatever it sits on. Ours were
      // opaque greys, which vanished on a card of the same value — that is why
      // a checkbox was hard to make out.
      const dark = NeutralColorScheme.dark();
      expect(dark.border, const Color(0x1affffff));
      expect(dark.input, const Color(0x26ffffff));
      // And the dark card is a step lighter than the page, per v4.
      expect(dark.card, isNot(dark.background));

      const light = NeutralColorScheme.light();
      expect(light.border, const Color(0xffe5e5e5)); // oklch(0.922 0 0)
      expect(light.input, const Color(0xffe5e5e5));
    });

    test('fields outline with --input, surfaces with a foreground wash', () {
      final theme = ThemeData(style: StyleTokens.nova);

      expect(
        theme.textFieldTheme.decoration!.border!.top!.color,
        theme.colorScheme.input,
      );
      expect(
        theme.checkboxTheme.decoration!.border!.top!.color,
        theme.colorScheme.input,
      );
      // `ring-foreground/10` rather than the border token.
      expect(
        theme.cardTheme.border!.top!.color,
        theme.colorScheme.foreground.withValues(alpha: .1),
      );
    });

    test('sera underlines its fields instead of boxing them', () {
      final sera = ThemeData(style: FixtureStyles.sera);
      final vega = ThemeData(style: FixtureStyles.vega);

      final seraBorder = sera.textFieldTheme.decoration!.border!;
      expect(seraBorder.bottom, isNotNull);
      expect(seraBorder.top, isNull);
      expect(seraBorder.borderRadius, BorderRadius.zero);

      expect(vega.textFieldTheme.decoration!.border!.top, isNotNull);
    });

    test('shadows differ per style', () {
      // The constructor default is vega's `shadow-xs`.
      expect(const StyleTokens(name: 'custom').cardShadow, Shadows.xs);
      expect(StyleTokens.nova.cardShadow, Shadows.none);
      expect(StyleTokens.maia.popoverShadow, Shadows.xl2);
      expect(StyleTokens.finesse.cardShadow, isNot(Shadows.none));
      expect(
        StyleTokens.finesse.cardShadowDark,
        isNot(StyleTokens.finesse.cardShadow),
      );
    });

    test('copyWith and equality', () {
      final tuned = FixtureStyles.vega.copyWith(ringWidth: 1);
      expect(tuned.ringWidth, 1);
      expect(tuned.ringOpacity, FixtureStyles.vega.ringOpacity);
      expect(tuned, isNot(FixtureStyles.vega));
      expect(
        FixtureStyles.vega.copyWith(),
        FixtureStyles.vega,
      );
      expect(
        FixtureStyles.vega.copyWith().hashCode,
        FixtureStyles.vega.hashCode,
      );
    });
  });

  group('Spacing', () {
    const spacing = Spacing();

    test("one step is Tailwind's 0.25rem", () {
      expect(spacing.step, 4);
      expect(spacing(6), 24);
      expect(spacing(1.5), 6);
      expect(spacing.xs, 4);
      expect(spacing.lg, 24);
    });

    test('builds insets in steps', () {
      expect(spacing.all(6), const EdgeInsets.all(24));
      expect(
        spacing.symmetric(horizontal: 4, vertical: 2),
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
      expect(spacing.only(top: 2), const EdgeInsets.only(top: 8));
      expect(
        spacing.directional(start: 2),
        const EdgeInsetsDirectional.only(start: 8),
      );
    });

    test('a different step rescales everything', () {
      const tight = Spacing(step: 2);
      expect(tight(6), 12);
      expect(tight.all(6), const EdgeInsets.all(12));
    });

    test('lerp, copyWith and equality', () {
      expect(
        Spacing.lerp(const Spacing(), const Spacing(step: 8), .5),
        const Spacing(step: 6),
      );
      expect(const Spacing().copyWith(step: 8), const Spacing(step: 8));
      // Built at runtime so the analyzer doesn't fold it into the default.
      final explicit = Spacing(step: [4.0].first);
      expect(const Spacing(), explicit);
      expect(const Spacing().hashCode, explicit.hashCode);
    });
  });

  group('ThemeData style and spacing', () {
    test('the card radius follows the theme radius', () {
      // The bug this pins: CardTheme.borderRadius was hardcoded to 8, so
      // setting a radius moved buttons and inputs but left cards alone.
      final small = ThemeData(
        style: StyleTokens.nova,
        radius: const BorderRadius.all(Radius.circular(4)),
      );
      final large = ThemeData(
        style: StyleTokens.nova,
        radius: const BorderRadius.all(Radius.circular(16)),
      );

      expect(small.cardTheme.borderRadius!.topLeft.x, 7); // 4 * 1.75
      expect(large.cardTheme.borderRadius!.topLeft.x, 28); // 16 * 1.75
      expect(
        large.cardTheme.borderRadius!.topLeft.x,
        greaterThan(large.radius.topLeft.x),
      );
    });

    test('a style reshapes every radius at once', () {
      final lyra = ThemeData(style: StyleTokens.lyra);
      expect(lyra.cardTheme.borderRadius, BorderRadius.zero);
      expect(lyra.primaryDialogTheme.borderRadius, BorderRadius.zero);
      expect(
        lyra.primaryButtonTheme.decoration!.border!.borderRadius,
        BorderRadius.zero,
      );

      final luma = ThemeData(style: FixtureStyles.luma);
      expect(luma.cardTheme.borderRadius!.topLeft.x, greaterThan(8));
    });

    test('button labels follow the style typography', () {
      final vega = ThemeData(style: FixtureStyles.vega);
      final sera = ThemeData(style: FixtureStyles.sera);

      expect(
        vega.primaryButtonTheme.textStyle!.fontSize,
        vega.textTheme.small.fontSize,
      );
      expect(sera.primaryButtonTheme.textStyle!.fontSize, 12);
      expect(sera.primaryButtonTheme.textStyle!.fontWeight, FontWeight.w600);
      expect(sera.primaryButtonTheme.textStyle!.letterSpacing, 1.2);
      // Every variant gets it, not just the primary one.
      expect(sera.ghostButtonTheme.textStyle!.letterSpacing, 1.2);
    });

    test("each style carries shadcn's own metrics", () {
      // Spot-checks against `registry/styles/style-*.css`, converting
      // Tailwind's scale at 4px per unit. These are the numbers that make the
      // styles visibly different sizes rather than just different radii.
      expect(StyleTokens.maia.buttonHeight, 36); // h-9
      expect(StyleTokens.nova.buttonHeight, 32); // h-8
      expect(StyleTokens.lyra.buttonHeight, 32); // h-8
      expect(StyleTokens.maia.buttonPaddingX, 12); // px-3
      expect(StyleTokens.nova.buttonPaddingX, 10); // px-2.5
      expect(StyleTokens.maia.sliderTrackHeight, 12); // h-3
      expect(StyleTokens.nova.sliderTrackHeight, 4); // h-1
      expect(StyleTokens.maia.cardPadding, 24); // --card-spacing: 6
      expect(StyleTokens.nova.cardPadding, 16); // --card-spacing: 4
    });

    test('the metrics reach the component themes', () {
      final mira = ThemeData(style: FixtureStyles.mira);
      final sera = ThemeData(style: FixtureStyles.sera);

      expect(mira.buttonSizesTheme.regular!.height, 28);
      expect(sera.buttonSizesTheme.regular!.height, 40);
      expect(
        sera.buttonSizesTheme.regular!.padding,
        const EdgeInsets.symmetric(horizontal: 24),
      );
      expect(mira.cardTheme.padding, const EdgeInsets.all(16));
      expect(sera.cardTheme.padding, const EdgeInsets.all(32));
      expect(mira.sliderTheme.trackHeight, 4);
      expect(mira.sliderTheme.thumbRadius, 6);
      expect(mira.switchTheme.width, 28);
      expect(mira.progressBarTheme.minHeight, 4);
      expect(
        sera.selectOptionTheme.padding,
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      );
      // The switch thumb is what is left after the inset on both sides.
      expect(
        sera.switchTheme.height! - sera.switchTheme.margin! * 2,
        FixtureStyles.sera.switchThumbSize,
      );
    });

    test('the focus ring follows the style', () {
      final lyra = ThemeData(style: StyleTokens.lyra);
      final vega = ThemeData(style: FixtureStyles.vega);

      expect(lyra.decoration.secondaryFocusedBorder!.top!.width, 1);
      expect(vega.decoration.secondaryFocusedBorder!.top!.width, 3);
      // offset == width is what removes the gap between element and ring.
      expect(vega.decoration.secondaryFocusedBorder!.offset, 3);
    });

    test('spacing drives component padding', () {
      final normal = ThemeData(style: StyleTokens.nova);
      final tight = ThemeData(
        style: StyleTokens.nova,
        spacing: const Spacing(step: 2),
      );

      // nova's `--card-spacing` is `--spacing(4)`, so it halves with the step.
      expect(normal.cardTheme.padding, const EdgeInsets.all(16));
      expect(tight.cardTheme.padding, const EdgeInsets.all(8));
      expect(tight.spacing(6), 12);

      // A style's metrics are stored in the pixels they render at the default
      // step, and rescale with it — exactly as Tailwind's `h-8` follows
      // `--spacing`. Its bracketed literals do not.
      expect(tight.buttonSizesTheme.regular!.height, 16);
      expect(tight.switchTheme.width, StyleTokens.nova.switchWidth);
    });

    test('style and spacing survive copyWith', () {
      final theme = ThemeData(
        style: FixtureStyles.rhea,
        spacing: const Spacing(step: 5),
      );
      final copy = theme.copyWith(disabledOpacity: .3);

      expect(copy.style, FixtureStyles.rhea);
      expect(copy.spacing, const Spacing(step: 5));
      expect(copy.cardTheme.borderRadius, theme.cardTheme.borderRadius);
    });

    test('an explicit radius rebuilds a supplied variant', () {
      // A variant bakes the radius into its component themes, so a theme built
      // with both has to push the radius back into the variant — otherwise the
      // theme's `radius` says one thing and every component renders another.
      //
      // Note this is about construction. `copyWith` forwards the already
      // resolved component themes, so it cannot re-derive them; changing the
      // radius of an existing theme means rebuilding it.
      final variant = DefaultThemeVariant(
        colorScheme: const NeutralColorScheme.light(),
        radius: const BorderRadius.all(Radius.circular(4)),
        effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
        style: FixtureStyles.rhea,
      );
      final theme = ThemeData(
        variant: variant,
        radius: const BorderRadius.all(Radius.circular(16)),
      );

      expect(theme.radius.topLeft.x, 16);
      expect(theme.variant.radius.topLeft.x, 16);
      // rhea cards are `rounded-[min(var(--radius-4xl),24px)]`: the 4xl step
      // (64 at an md of 16) hits the 24px cap.
      expect(theme.cardTheme.borderRadius!.topLeft.x, 24);
      // Rebuilding keeps everything the caller did not override.
      expect(theme.style, FixtureStyles.rhea);
    });

    test('a variant supplies the radius when none is given', () {
      final variant = DefaultThemeVariant(
        colorScheme: const NeutralColorScheme.light(),
        radius: const BorderRadius.all(Radius.circular(6)),
        effectiveTextTheme: DefaultThemeVariant.defaultTextTheme,
      );
      final theme = ThemeData(variant: variant);

      expect(theme.variant, same(variant));
      // The theme's own radius agrees with the variant rather than defaulting
      // to the style's behind its back.
      expect(theme.radius.topLeft.x, 6);
    });
  });
}
