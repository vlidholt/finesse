import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

/// A segmented tab strip shows which tab is selected in every style,
/// scheme and brightness: the selected pill stands apart from the strip.
///
/// shadcn paints the pill in the page colour, white there; una's pages are
/// a grey nearly the strip's own, and the selection was invisible in every
/// style but Fluid.
void main() {
  test('the selected tab stands apart from its strip', () {
    for (final scheme in ColorSchemes.values) {
      for (final style in StyleTokens.all) {
        for (final brightness in Brightness.values) {
          final theme = ThemeData(
            style: style,
            brightness: brightness,
            colorScheme: scheme.of(brightness),
          );
          final page = theme.colorScheme.background;
          final strip = Color.alphaBlend(
            theme.tabsTheme.decoration!.color!,
            page,
          );
          final pill = Color.alphaBlend(
            theme.tabsTheme.tabSelectedBackgroundColor!,
            strip,
          );
          final why = '${scheme.name} ${style.name} ${brightness.name}';
          expect(_contrast(pill, strip), greaterThan(1.15), reason: why);
        }
      }
    }
  });
}
