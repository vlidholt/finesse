// Runs under `flutter test --platform chrome`; the VM suite skips it.
@TestOn('browser')
library;

import 'dart:ui_web' as ui_web;

import 'package:flutter_test/flutter_test.dart';

import 'phosphor_icon_stroke_test.dart' as stroke;

/// `phosphor_icon_stroke_test.dart` again, in a browser.
///
/// A `PhosphorIcon` thickens a glyph by painting it a second time with a
/// stroking paint, and how wide a stroked glyph comes out, how fill and
/// outline overlap in a translucent layer and whether a shadow survives a
/// transparent fill are all the renderer's doing. The web's is not the
/// VM's, so the same measurements are taken there.
void main() {
  // A browser test draws all text in the test font, whatever family a
  // style names, so the glyph measured would be that font's box. This is
  // the tester's environment with real fonts let through.
  setUpAll(() {
    ui_web.TestEnvironment.setUp(
      const ui_web.TestEnvironment(
        ignorePlatformMessages: true,
        disableFontFallbacks: true,
        keepSemanticsDisabledOnUpdate: true,
        defaultToTestUrlStrategy: true,
      ),
    );
  });
  tearDownAll(() {
    ui_web.TestEnvironment.setUp(const ui_web.TestEnvironment.flutterTester());
  });

  stroke.main();
}
