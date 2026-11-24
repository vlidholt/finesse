import 'dart:io';

import 'package:finesse/finesse.dart';
import 'package:finesse/src/icons/phosphor_font_anchor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a theme keeps one glyph of every bundled icon font in use', (
    tester,
  ) async {
    // A font no constant of which is left in the compiled app is bundled
    // whole, not shrunk to nothing: half a megabyte for each weight an app
    // does not draw, which a web build downloads before its first frame.
    // See `PhosphorFontAnchor`. A release build is the proof (a minimal
    // app's six fonts come to 6 kB with the anchor and 2.6 MB without);
    // this holds the anchor in place and in step with the pubspec.
    await tester.pumpWidget(
      Theme(data: ThemeData(), child: const SizedBox.shrink()),
    );
    final anchor = tester.widget<PhosphorFontAnchor>(
      find.byType(PhosphorFontAnchor),
    );
    final anchored = {
      for (final glyph in [
        anchor.regular,
        anchor.bold,
        anchor.fill,
        anchor.light,
        anchor.thin,
        anchor.duotone.primary,
      ])
        glyph.fontFamily,
    };

    final declared = RegExp(r'^\s*- family: (\S+)$', multiLine: true)
        .allMatches(File('pubspec.yaml').readAsStringSync())
        .map((match) => match.group(1))
        .toSet();
    expect(declared, hasLength(6));
    expect(anchored, declared);
  });
}
