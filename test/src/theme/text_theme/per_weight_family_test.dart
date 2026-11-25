import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A font source that, like `google_fonts`, registers one family per weight
/// and style.
TextStyle perWeightFont({
  TextStyle? textStyle,
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Locale? locale,
  Paint? foreground,
  Paint? background,
  List<ui.Shadow>? shadows,
  List<ui.FontFeature>? fontFeatures,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
}) {
  final weight = fontWeight ?? textStyle?.fontWeight ?? FontWeight.w400;
  final style = fontStyle ?? textStyle?.fontStyle ?? FontStyle.normal;
  final italic = style == FontStyle.italic ? 'i' : '';
  return (textStyle ?? const TextStyle()).copyWith(
    fontFamily: 'Fake_${weight.value}$italic',
    fontWeight: weight,
    fontStyle: style,
  );
}

String familyFor(TextStyle style) =>
    'Fake_${style.fontWeight!.value}'
    "${style.fontStyle == FontStyle.italic ? 'i' : ''}";

void main() {
  // A font that ships one file per weight has one family name per weight. A
  // style whose weight changes has to change family with it, or the text is
  // drawn from the old weight's file: a 700 heading in the 800 face, 400 text
  // in the 500 face. These lock that for every route a weight can change by.
  group('a per-weight font keeps family and weight together', () {
    final textTheme = TextTheme.fromGoogleFont(perWeightFont);

    void expectConsistent(TextStyle style, {String? reason}) {
      expect(
        style.fontFamily,
        familyFor(style),
        reason: reason ?? '$style',
      );
    }

    for (final style in StyleTokens.all) {
      for (final formFactor in FormFactor.values) {
        test('${style.name} on ${formFactor.name}: the published text theme '
            'and every component text style', () {
          final theme = ThemeData(
            style: style,
            formFactor: formFactor,
            textTheme: textTheme,
          );
          final t = theme.textTheme;
          for (final (name, s) in [
            ('h1Large', t.h1Large),
            ('h1', t.h1),
            ('h2', t.h2),
            ('h3', t.h3),
            ('h4', t.h4),
            ('p', t.p),
            ('blockquote', t.blockquote),
            ('table', t.table),
            ('list', t.list),
            ('lead', t.lead),
            ('large', t.large),
            ('small', t.small),
            ('muted', t.muted),
            ('caption', t.caption),
            ('button', theme.primaryButtonTheme.textStyle!),
            ('outline button', theme.outlineButtonTheme.textStyle!),
            ('badge', theme.secondaryBadgeTheme.textStyle!),
            ('card title', theme.cardTheme.titleStyle!),
            ('card description', theme.cardTheme.descriptionStyle!),
            ('chip', theme.chipTheme.textStyle!),
            ('list tile title', theme.listTileTheme.titleStyle!),
            ('list tile subtitle', theme.listTileTheme.subtitleStyle!),
            ('navigation label', theme.navigationBarTheme.labelStyle!),
            ('app bar title', theme.appBarTheme.titleStyle!),
            ('tab', theme.tabsTheme.tabTextStyle!),
            ('text field', theme.textFieldTheme.style!),
            ('indicator badge', theme.indicatorBadgeTheme.textStyle!),
            ('chat bubble', theme.chatBubbleTheme.textStyle!),
          ]) {
            expectConsistent(s, reason: name);
          }
        });
      }
    }

    test("the finesse heading is the 700 face, not the text theme's 800", () {
      final theme = ThemeData(textTheme: textTheme);
      expect(theme.textTheme.h1.fontWeight, FontWeight.w700);
      expect(theme.textTheme.h1.fontFamily, 'Fake_700');
    });

    test('a copy of a theme style follows its new weight, however many '
        'copies came before', () {
      final theme = ThemeData(textTheme: textTheme);
      final small = theme.textTheme.small;
      expect(small.fontFamily, 'Fake_500');

      final recoloured = small.copyWith(color: const Color(0xff112233));
      expect(recoloured.fontFamily, 'Fake_500');
      expectConsistent(recoloured.copyWith(fontWeight: FontWeight.w400));
      expectConsistent(
        recoloured
            .copyWith(fontSize: 12)
            .copyWith(height: 1)
            .copyWith(fontWeight: FontWeight.w700),
      );
      expectConsistent(
        small.merge(const TextStyle(fontWeight: FontWeight.w600)),
      );
    });

    test('a change of style keeps the weight and switches the face', () {
      final theme = ThemeData(textTheme: textTheme);
      final italic = theme.textTheme.p.copyWith(fontStyle: FontStyle.italic);
      expect(italic.fontFamily, 'Fake_400i');
      expect(
        italic.copyWith(fontWeight: FontWeight.w600).fontFamily,
        'Fake_600i',
      );
    });

    test('an explicit family opts a copy out of the builder', () {
      final theme = ThemeData(textTheme: textTheme);
      final mono = theme.textTheme.p.copyWith(fontFamily: 'Mono');
      expect(mono.fontFamily, 'Mono');
      expect(mono.copyWith(fontWeight: FontWeight.w700).fontFamily, 'Mono');
    });

    test('a text role applied to a theme style resolves the face', () {
      final theme = ThemeData(textTheme: textTheme);
      const role = TextRole(fontSize: 11, fontWeight: FontWeight.w700);
      expectConsistent(role.apply(theme.textTheme.muted));
    });

    test('two themes built the same way are still equal', () {
      expect(
        ThemeData(textTheme: textTheme),
        ThemeData(textTheme: TextTheme.fromGoogleFont(perWeightFont)),
      );
    });

    test('a theme with a plain family is untouched', () {
      final theme = ThemeData(textTheme: TextTheme(family: 'Inter'));
      expect(theme.textTheme.h1.fontFamily, 'Inter');
      expect(
        theme.textTheme.small.copyWith(fontWeight: FontWeight.w700).fontFamily,
        'Inter',
      );
    });
  });
}
