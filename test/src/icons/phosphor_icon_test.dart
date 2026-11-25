import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:finesse/src/icons/thickened_glyph.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// `PhosphorIcon` thickens the line of a small regular icon. A thickened
/// icon paints its glyph through a [ThickenedGlyph], whose `outline` is
/// what the line gains; an icon it leaves alone builds what an `Icon`
/// builds, a `RichText`.
void main() {
  Finder within(Type type, [Finder? icon]) => find.descendant(
    of: icon ?? find.byType(PhosphorIcon),
    matching: find.byType(type),
  );

  /// The outline of the one `PhosphorIcon` on screen (or of [icon]), or
  /// null when it is drawn as a plain `Icon`.
  double? outlineOf(WidgetTester tester, [Finder? icon]) {
    final glyph = within(ThickenedGlyph, icon);
    if (glyph.evaluate().isEmpty) {
      expect(within(RichText, icon), findsOneWidget);
      return null;
    }
    expect(within(RichText, icon), findsNothing);
    return tester.widget<ThickenedGlyph>(glyph).outline;
  }

  group('PhosphorIconTheme', () {
    test('every style thickens below 24, at half strength', () {
      for (final style in StyleTokens.all) {
        for (final formFactor in FormFactor.values) {
          final icons = ThemeData(
            style: style,
          ).withFormFactor(formFactor).phosphorIconTheme;
          final reason = '${style.name} ${formFactor.name}';
          expect(icons.referenceSize, 24, reason: reason);
          expect(icons.strength, .5, reason: reason);
        }
      }
    });

    test('the default line loses half of what the font loses', () {
      final icons = ThemeData().phosphorIconTheme;
      // size: (what is added, the line as drawn). The font alone gives
      // size / 16: 0.75 at 12, 1 at 16.
      const expected = [
        (12.0, .375, 1.125),
        (14.0, .3125, 1.1875),
        (16.0, .25, 1.25),
        (18.0, .1875, 1.3125),
        (20.0, .125, 1.375),
        (22.0, .0625, 1.4375),
        (24.0, 0.0, 1.5),
        (28.0, 0.0, 1.75),
        (32.0, 0.0, 2.0),
      ];
      for (final (size, extra, stroke) in expected) {
        expect(icons.extraStroke(size), extra, reason: '$size');
        expect(icons.strokeAt(size), stroke, reason: '$size');
      }
    });

    test('the line never thins or thickens by a step', () {
      const icons = PhosphorIconTheme();
      var previous = icons.strokeAt(8);
      for (var size = 8.25; size <= 40; size += .25) {
        final stroke = icons.strokeAt(size);
        expect(stroke, greaterThan(previous), reason: '$size');
        // A quarter pixel of size is never more than a sixty-fourth of a
        // pixel of line.
        expect(stroke - previous, lessThanOrEqualTo(.25 / 16 + 1e-9));
        previous = stroke;
      }
    });

    test('a null field falls back to 24 and a half', () {
      const icons = PhosphorIconTheme();
      expect(icons.extraStroke(16), .25);
      expect(icons.extraStroke(24), 0);
      expect(const PhosphorIconTheme(strength: 1).extraStroke(16), .5);
      expect(const PhosphorIconTheme(referenceSize: 20).extraStroke(16), .125);
    });

    test("full strength holds the reference size's line all the way "
        'down', () {
      const icons = PhosphorIconTheme(strength: 1);
      for (final size in const [10.0, 12.0, 16.0, 20.0, 24.0]) {
        expect(icons.strokeAt(size), 1.5, reason: '$size');
      }
      const smaller = PhosphorIconTheme(referenceSize: 20, strength: 1);
      expect(smaller.strokeAt(12), 1.25);
      expect(smaller.strokeAt(20), 1.25);
      expect(smaller.strokeAt(24), 1.5);
    });

    test('strength 0 adds nothing, and strength is kept between 0 and 1', () {
      const off = PhosphorIconTheme(strength: 0);
      for (final size in const [8.0, 12.0, 16.0, 24.0, 40.0]) {
        expect(off.extraStroke(size), 0);
        expect(off.strokeAt(size), size / 16);
      }
      expect(const PhosphorIconTheme(strength: -1).extraStroke(12), 0);
      expect(
        const PhosphorIconTheme(strength: 3).extraStroke(12),
        const PhosphorIconTheme(strength: 1).extraStroke(12),
      );
      // Nothing sensible to add to an icon of no size.
      expect(const PhosphorIconTheme().extraStroke(0), 0);
      expect(const PhosphorIconTheme().extraStroke(double.nan), 0);
    });

    test('the style tokens reach the theme, on both form factors', () {
      final style = StyleTokens.finesse.copyWith(
        iconOpticalSize: 20,
        iconOpticalStrength: .8,
      );
      for (final formFactor in FormFactor.values) {
        final icons = ThemeData(
          style: style,
        ).withFormFactor(formFactor).phosphorIconTheme;
        expect(icons.referenceSize, 20, reason: formFactor.name);
        expect(icons.strength, .8, reason: formFactor.name);
      }
      expect(style, isNot(StyleTokens.finesse));
    });

    test('the reference is a size on the screen, not spacing units', () {
      final icons = ThemeData(
        spacing: const Spacing(step: 5),
      ).phosphorIconTheme;
      expect(icons.referenceSize, 24);
      expect(icons.strength, .5);
    });

    test("an explicit theme is merged over the style's and survives a "
        'copyWith', () {
      final theme = ThemeData(
        phosphorIconTheme: const PhosphorIconTheme(strength: .8),
      );
      expect(theme.phosphorIconTheme.strength, .8);
      expect(theme.phosphorIconTheme.referenceSize, 24);

      final restyled = theme.copyWith(style: StyleTokens.lyra);
      expect(restyled.phosphorIconTheme.strength, .8);
      final replaced = theme.copyWith(
        phosphorIconTheme: const PhosphorIconTheme(strength: 0),
      );
      expect(replaced.phosphorIconTheme.strength, 0);
      expect(
        replaced,
        ThemeData(phosphorIconTheme: const PhosphorIconTheme(strength: 0)),
      );
    });

    test('compares by value, so a rebuilt theme does not re-animate', () {
      expect(
        const PhosphorIconTheme(referenceSize: 24, strength: .5),
        // Value equality, not const canonicalisation.
        // ignore: prefer_const_constructors
        PhosphorIconTheme(referenceSize: 24, strength: .5),
      );
      expect(ThemeData().phosphorIconTheme, ThemeData().phosphorIconTheme);
      expect(
        ThemeData().phosphorIconTheme,
        isNot(
          ThemeData(
            style: StyleTokens.finesse.copyWith(iconOpticalStrength: .8),
          ).phosphorIconTheme,
        ),
      );
    });

    test('lerps, so a change of style fades the line in', () {
      const a = PhosphorIconTheme(referenceSize: 20, strength: 0);
      const b = PhosphorIconTheme(referenceSize: 24, strength: 1);
      final half = PhosphorIconTheme.lerp(a, b, .5)!;
      expect(half.referenceSize, 22);
      expect(half.strength, .5);
    });
  });

  group('PhosphorIcon', () {
    testWidgets('thickens a regular icon below the reference size, by what '
        'the theme says', (tester) async {
      const outlines = {
        12: .375,
        14: .3125,
        16: .25,
        18: .1875,
        20: .125,
        23: .03125,
      };
      for (final MapEntry(key: size, value: outline) in outlines.entries) {
        await pumpFinesse(
          tester,
          Center(
            child: PhosphorIcon(
              PhosphorIconsRegular.house,
              size: size.toDouble(),
            ),
          ),
        );
        expect(outlineOf(tester), outline, reason: '$size');
        final glyph = tester.widget<ThickenedGlyph>(within(ThickenedGlyph));
        // The regular glyph, at the size asked for.
        expect(
          glyph.glyph,
          String.fromCharCode(PhosphorIconsRegular.house.codePoint),
        );
        expect(glyph.style.fontFamily, 'packages/finesse/PhosphorRegular');
        expect(glyph.style.fontSize, size);
        expect(
          tester.getSize(find.byType(PhosphorIcon)),
          Size.square(size.toDouble()),
        );
        expect(
          tester.getSize(within(ThickenedGlyph)),
          Size.square(size.toDouble()),
        );
      }
    });

    testWidgets('from the reference size up it is a plain Icon', (
      tester,
    ) async {
      for (final size in const [24.0, 26.0, 32.0, 48.0]) {
        await pumpFinesse(
          tester,
          Center(child: PhosphorIcon(PhosphorIconsRegular.house, size: size)),
        );
        expect(outlineOf(tester), isNull, reason: '$size');
        final text = tester.widget<RichText>(within(RichText));
        expect(
          text.text.style!.fontFamily,
          'packages/finesse/PhosphorRegular',
        );
        expect(tester.getSize(find.byType(PhosphorIcon)), Size.square(size));
      }
    });

    testWidgets('does not bother with an outline too fine to see', (
      tester,
    ) async {
      // 23.9: three thousandths of a pixel short of the font's own line.
      await pumpFinesse(
        tester,
        const Center(
          child: PhosphorIcon(PhosphorIconsRegular.house, size: 23.9),
        ),
      );
      expect(outlineOf(tester), isNull);
    });

    testWidgets('uses the size an IconTheme hands down', (tester) async {
      await pumpFinesse(
        tester,
        const Column(
          children: [
            IconTheme(
              data: IconThemeData(size: 14),
              child: PhosphorIcon(PhosphorIconsRegular.bell),
            ),
            IconTheme(
              data: IconThemeData(size: 24),
              child: PhosphorIcon(PhosphorIconsRegular.gear),
            ),
          ],
        ),
      );
      expect(
        outlineOf(tester, find.byIcon(PhosphorIconsRegular.bell)),
        .3125,
      );
      expect(
        outlineOf(tester, find.byIcon(PhosphorIconsRegular.gear)),
        isNull,
      );
    });

    testWidgets('follows the size a button gives its icon', (tester) async {
      // nova's buttons hand 16 down and the default style's 18.
      for (final (style, outline) in [
        (StyleTokens.nova, .25),
        (StyleTokens.finesse, .1875),
      ]) {
        await pumpFinesse(
          tester,
          Center(
            child: Button(
              leading: const PhosphorIcon(PhosphorIconsRegular.plus),
              onPressed: () {},
              child: const Text('New'),
            ),
          ),
          theme: ThemeData(style: style),
        );
        expect(outlineOf(tester), outline, reason: style.name);
      }
    });

    testWidgets('leaves an explicit weight alone at every size', (
      tester,
    ) async {
      for (final icon in const [
        PhosphorIconsBold.house,
        PhosphorIconsLight.house,
        PhosphorIconsThin.house,
        PhosphorIconsFill.house,
      ]) {
        expect(PhosphorIcon.adapts(icon), isFalse);
        for (final size in const [12.0, 24.0, 48.0]) {
          await pumpFinesse(
            tester,
            Center(child: PhosphorIcon(icon, size: size)),
          );
          expect(outlineOf(tester), isNull);
          expect(
            tester.widget<RichText>(within(RichText)).text.style!.fontFamily,
            'packages/finesse/${icon.fontFamily}',
            reason: '${icon.fontFamily} at $size',
          );
        }
      }
    });

    testWidgets('leaves an icon from another font alone', (tester) async {
      const material = IconData(0xe047, fontFamily: 'MaterialIcons');
      // The same family name in another package is not ours either.
      const foreign = IconData(
        0xe2c2,
        fontFamily: 'PhosphorRegular',
        fontPackage: 'phosphor_flutter',
      );
      for (final icon in const [material, foreign]) {
        expect(PhosphorIcon.adapts(icon), isFalse);
        await pumpFinesse(
          tester,
          Center(child: PhosphorIcon(icon, size: 12)),
        );
        expect(outlineOf(tester), isNull);
        expect(find.byIcon(icon), findsOneWidget);
      }
      expect(PhosphorIcon.adapts(PhosphorIconsRegular.house), isTrue);
    });

    testWidgets('with no icon it is an empty box of its size', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: PhosphorIcon(null, size: 14)),
      );
      expect(tester.getSize(find.byType(PhosphorIcon)), const Size.square(14));
      expect(within(RichText), findsNothing);
      expect(within(ThickenedGlyph), findsNothing);
    });

    testWidgets('is the one Icon a finder sees, holding the icon it was '
        'given', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: FinesseRow(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thickened, thickened and plain.
              PhosphorIcon(PhosphorIconsRegular.house, size: 14),
              PhosphorIcon(PhosphorIconsRegular.bell, size: 20),
              PhosphorIcon(PhosphorIconsRegular.gear, size: 32),
            ],
          ),
        ),
      );
      for (final icon in const [
        PhosphorIconsRegular.house,
        PhosphorIconsRegular.bell,
        PhosphorIconsRegular.gear,
      ]) {
        expect(find.byIcon(icon), findsOneWidget);
        expect(tester.widget<Icon>(find.byIcon(icon)).icon, icon);
        expect(tester.widget(find.byIcon(icon)), isA<PhosphorIcon>());
      }
      expect(find.bySubtype<Icon>(), findsNWidgets(3));
      expect(find.byType(PhosphorIcon), findsNWidgets(3));
      // `byType` matches the exact type, so it does not see these.
      expect(find.byType(Icon), findsNothing);
      expect(
        find.widgetWithIcon(FinesseRow, PhosphorIconsRegular.house),
        findsOneWidget,
      );
    });

    testWidgets('goes by the size it is drawn at when text scaling '
        'applies', (tester) async {
      Widget icon({required bool scaling}) => MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: Center(
          child: PhosphorIcon(
            PhosphorIconsRegular.house,
            size: 12,
            applyTextScaling: scaling,
          ),
        ),
      );

      // 12 × 1.5 = 18: drawn at 18, with what 18 gets.
      await pumpFinesse(tester, icon(scaling: true));
      expect(outlineOf(tester), .1875);
      expect(tester.getSize(find.byType(PhosphorIcon)), const Size.square(18));
      expect(
        tester.widget<ThickenedGlyph>(within(ThickenedGlyph)).style.fontSize,
        18,
      );

      // Without it the icon stays 12.
      await pumpFinesse(tester, icon(scaling: false));
      expect(outlineOf(tester), .375);
      expect(tester.getSize(find.byType(PhosphorIcon)), const Size.square(12));

      // The IconTheme can ask for scaling too: 16 × 1.5 = 24, plain.
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: Center(
            child: IconTheme(
              data: IconThemeData(size: 16, applyTextScaling: true),
              child: PhosphorIcon(PhosphorIconsRegular.house),
            ),
          ),
        ),
      );
      expect(outlineOf(tester), isNull);
      expect(tester.getSize(find.byType(PhosphorIcon)), const Size.square(24));
    });

    testWidgets('follows the theme: another strength, a local override and '
        'off', (tester) async {
      const icon = Center(
        child: PhosphorIcon(PhosphorIconsRegular.house, size: 16),
      );

      await pumpFinesse(tester, icon);
      expect(outlineOf(tester), .25);

      await pumpFinesse(
        tester,
        icon,
        theme: ThemeData(
          phosphorIconTheme: const PhosphorIconTheme(strength: 1),
        ),
      );
      expect(outlineOf(tester), .5);

      await pumpFinesse(
        tester,
        icon,
        theme: ThemeData(
          style: StyleTokens.finesse.copyWith(iconOpticalSize: 16),
        ),
      );
      expect(outlineOf(tester), isNull);

      await pumpFinesse(
        tester,
        icon,
        theme: ThemeData(
          style: StyleTokens.finesse.copyWith(iconOpticalStrength: 0),
        ),
      );
      expect(outlineOf(tester), isNull);

      // A subtree can differ from the app.
      await pumpFinesse(
        tester,
        Builder(
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              phosphorIconTheme: const PhosphorIconTheme(strength: 0),
            ),
            child: icon,
          ),
        ),
      );
      expect(outlineOf(tester), isNull);
    });

    testWidgets('thickens outside a finesse Theme, by the defaults', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: PhosphorIcon(PhosphorIconsRegular.house, size: 12),
          ),
        ),
      );
      expect(outlineOf(tester), .375);
    });

    testWidgets('gives the glyph everything an Icon would', (tester) async {
      const shadows = [Shadow(blurRadius: 2)];
      const color = Color(0xFF123456);

      // What an Icon of the same parameters draws its glyph with.
      await pumpFinesse(
        tester,
        const Center(
          child: IconTheme(
            data: IconThemeData(opacity: .5),
            child: Icon(
              PhosphorIconsRegular.house,
              size: 14,
              color: color,
              shadows: shadows,
              fill: 1,
              weight: 500,
              grade: 25,
              opticalSize: 20,
              textDirection: TextDirection.rtl,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      final plain = tester.widget<RichText>(
        find.descendant(
          of: find.byType(Icon),
          matching: find.byType(RichText),
        ),
      );
      final expected = plain.text.style!;

      await pumpFinesse(
        tester,
        const Center(
          child: IconTheme(
            data: IconThemeData(opacity: .5),
            child: PhosphorIcon(
              PhosphorIconsRegular.house,
              size: 14,
              color: color,
              shadows: shadows,
              fill: 1,
              weight: 500,
              grade: 25,
              opticalSize: 20,
              textDirection: TextDirection.rtl,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      final glyph = tester.widget<ThickenedGlyph>(within(ThickenedGlyph));
      // The font: the Icon's style without its paint.
      expect(glyph.style.inherit, isFalse);
      expect(glyph.style.fontFamily, expected.fontFamily);
      expect(glyph.style.fontSize, expected.fontSize);
      expect(glyph.style.fontVariations, expected.fontVariations);
      expect(glyph.style.fontWeight, expected.fontWeight);
      expect(glyph.style.fontFamilyFallback, expected.fontFamilyFallback);
      expect(glyph.style.height, expected.height);
      expect(glyph.style.leadingDistribution, expected.leadingDistribution);
      expect(glyph.style.color, isNull);
      expect(glyph.style.foreground, isNull);
      expect(glyph.style.shadows, isNull);
      expect(glyph.style.fontVariations, hasLength(4));
      expect(glyph.style.fontWeight, FontWeight.w700);
      expect(glyph.glyph, plain.text.toPlainText());
      // The paint: the colour with the IconTheme's opacity, the shadows.
      expect(glyph.color.a, closeTo(expected.color!.a, .01));
      expect(glyph.color.withValues(alpha: 1), color);
      expect(glyph.shadows, shadows);
      expect(glyph.blendMode, isNull);
      expect(glyph.textDirection, TextDirection.rtl);
      expect(glyph.outline, .3125);
    });

    testWidgets('takes shadows from the IconTheme, and a blend mode', (
      tester,
    ) async {
      const shadows = [Shadow(blurRadius: 3)];
      await pumpFinesse(
        tester,
        const Center(
          child: IconTheme(
            data: IconThemeData(shadows: shadows, color: Color(0xFF00FF00)),
            child: PhosphorIcon(
              PhosphorIconsRegular.house,
              size: 14,
              blendMode: BlendMode.multiply,
            ),
          ),
        ),
      );
      final glyph = tester.widget<ThickenedGlyph>(within(ThickenedGlyph));
      expect(glyph.shadows, shadows);
      expect(glyph.blendMode, BlendMode.multiply);
      expect(glyph.color, const Color(0xFF00FF00));
    });

    testWidgets('keeps its semantic label, and only that', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(
          child: PhosphorIcon(
            PhosphorIconsRegular.bell,
            size: 14,
            semanticLabel: 'Notifications',
          ),
        ),
      );
      expect(outlineOf(tester), isNotNull);
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
      // The glyph itself is not read out.
      expect(
        find.bySemanticsLabel(
          String.fromCharCode(PhosphorIconsRegular.bell.codePoint),
        ),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('lines up on a text baseline exactly as an Icon does', (
      tester,
    ) async {
      Future<double> top(Widget icon) async {
        await pumpFinesse(
          tester,
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text('Label', style: TextStyle(fontSize: 30)),
                icon,
              ],
            ),
          ),
        );
        return tester.getTopLeft(find.bySubtype<Icon>()).dy -
            tester.getTopLeft(find.text('Label')).dy;
      }

      final plain = await top(
        const Icon(PhosphorIconsRegular.house, size: 16),
      );
      final thick = await top(
        const PhosphorIcon(PhosphorIconsRegular.house, size: 16),
      );
      expect(outlineOf(tester), isNotNull);
      expect(thick, plain);
    });

    testWidgets('is hit like an Icon: a detector around it gets the tap', (
      tester,
    ) async {
      var taps = 0;
      await pumpFinesse(
        tester,
        Center(
          child: GestureDetector(
            // The default behaviour: only where a child is hit.
            onTap: () => taps++,
            child: const PhosphorIcon(PhosphorIconsRegular.house, size: 16),
          ),
        ),
      );
      expect(outlineOf(tester), isNotNull);
      await tester.tap(find.byType(PhosphorIcon));
      expect(taps, 1);
    });

    testWidgets('mirrors a glyph that asks to follow the text direction', (
      tester,
    ) async {
      const mirrored = IconData(
        0xe2c2,
        fontFamily: 'PhosphorRegular',
        fontPackage: 'finesse',
        matchTextDirection: true,
      );
      await pumpFinesse(
        tester,
        const Center(child: PhosphorIcon(mirrored, size: 16)),
        textDirection: TextDirection.rtl,
      );
      expect(outlineOf(tester), isNotNull);
      expect(within(Transform), findsOneWidget);

      await pumpFinesse(
        tester,
        const Center(child: PhosphorIcon(mirrored, size: 16)),
      );
      expect(within(Transform), findsNothing);
      // The package's own constants never ask.
      expect(PhosphorIconsRegular.caretRight.matchTextDirection, isFalse);
    });

    testWidgets('follows a change of size or theme', (tester) async {
      Widget at(double size) => Center(
        child: PhosphorIcon(PhosphorIconsRegular.house, size: size),
      );
      await pumpFinesse(tester, at(16));
      expect(outlineOf(tester), .25);
      await pumpFinesse(tester, at(20));
      expect(outlineOf(tester), .125);
      await pumpFinesse(tester, at(24));
      expect(outlineOf(tester), isNull);
      await pumpFinesse(
        tester,
        at(20),
        theme: ThemeData(
          phosphorIconTheme: const PhosphorIconTheme(strength: 1),
        ),
      );
      expect(outlineOf(tester), .25);
      expect(
        tester
            .renderObject<RenderThickenedGlyph>(within(ThickenedGlyph))
            .outline,
        .25,
      );
    });
  });

  group('ThickenedGlyph', () {
    Widget glyph({
      Color color = const Color(0xFF000000),
      double outline = .25,
      BlendMode? blendMode,
      List<Shadow>? shadows,
    }) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.square(
            dimension: 16,
            child: ThickenedGlyph(
              glyph: 'A',
              style: const TextStyle(inherit: false, fontSize: 16, height: 1),
              color: color,
              outline: outline,
              textDirection: TextDirection.ltr,
              blendMode: blendMode,
              shadows: shadows,
            ),
          ),
        ),
      );
    }

    /// How many layers and paragraphs painting the glyph takes.
    ({int layers, int paragraphs}) painted(WidgetTester tester) {
      final box = tester.renderObject<RenderThickenedGlyph>(
        find.byType(ThickenedGlyph),
      );
      final canvas = _CountingCanvas();
      box.paint(_CountingContext(canvas), Offset.zero);
      return (layers: canvas.layers, paragraphs: canvas.paragraphs);
    }

    testWidgets('an opaque glyph is two paragraphs and no layer', (
      tester,
    ) async {
      await tester.pumpWidget(glyph());
      expect(painted(tester), (layers: 0, paragraphs: 2));
      // Shadows ride on the fill.
      await tester.pumpWidget(glyph(shadows: const [Shadow(blurRadius: 2)]));
      expect(painted(tester), (layers: 0, paragraphs: 2));
    });

    testWidgets('a translucent or blended glyph is painted opaque inside '
        'one layer', (tester) async {
      await tester.pumpWidget(glyph(color: const Color(0x80000000)));
      expect(painted(tester), (layers: 1, paragraphs: 2));
      await tester.pumpWidget(glyph(blendMode: BlendMode.multiply));
      expect(painted(tester), (layers: 1, paragraphs: 2));
      // Its shadows are a third paragraph, outside the layer.
      await tester.pumpWidget(
        glyph(
          color: const Color(0x80000000),
          shadows: const [Shadow(blurRadius: 2)],
        ),
      );
      expect(painted(tester), (layers: 1, paragraphs: 3));
      // Back to opaque: no layer again.
      await tester.pumpWidget(glyph());
      expect(painted(tester), (layers: 0, paragraphs: 2));
    });

    testWidgets('takes the box it is given and repaints only on a change', (
      tester,
    ) async {
      await tester.pumpWidget(glyph());
      final box = tester.renderObject<RenderThickenedGlyph>(
        find.byType(ThickenedGlyph),
      );
      expect(box.size, const Size.square(16));
      expect(box.debugNeedsPaint, isFalse);
      await tester.pumpWidget(glyph());
      expect(box.debugNeedsLayout, isFalse);
      expect(box.debugNeedsPaint, isFalse);
      await tester.pumpWidget(glyph(outline: .5));
      expect(box.outline, .5);
      expect(box.size, const Size.square(16));
    });
  });
}

class _CountingContext extends PaintingContext {
  _CountingContext(this._canvas) : super(ContainerLayer(), Rect.largest);

  final Canvas _canvas;

  @override
  Canvas get canvas => _canvas;
}

class _CountingCanvas implements Canvas {
  int layers = 0;
  int paragraphs = 0;

  @override
  void saveLayer(Rect? bounds, Paint paint) => layers++;

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) => paragraphs++;

  @override
  void noSuchMethod(Invocation invocation) {}
}
