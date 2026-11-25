// Renders the images in the README to doc/images/.
//
//   flutter test scripts/readme_images/readme_images_test.dart
//
// Pass a name to render one image:
//
//   flutter test scripts/readme_images/readme_images_test.dart --name hero
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart';
import 'scenes/components.dart';
import 'scenes/form_factors.dart';
import 'scenes/hero.dart';
import 'scenes/palettes.dart';
import 'scenes/styles.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadFonts();
  });

  testWidgets('hero', (tester) async {
    await shoot(tester, 'hero', heroSize, const HeroScene());
  });

  for (final brightness in Brightness.values) {
    testWidgets('components-${brightness.name}', (tester) async {
      await shoot(
        tester,
        'components-${brightness.name}',
        componentsSize,
        ComponentsScene(brightness: brightness),
      );
    });
  }

  testWidgets('styles', (tester) async {
    await shoot(tester, 'styles', stylesSize, const StylesScene());
  });

  testWidgets('palettes', (tester) async {
    await shoot(tester, 'palettes', palettesSize, const PalettesScene());
  });

  testWidgets('accents', (tester) async {
    await shoot(tester, 'accents', accentsSize, const AccentsScene());
  });

  testWidgets('form-factors', (tester) async {
    await shoot(
      tester,
      'form-factors',
      formFactorsSize,
      const FormFactorsScene(),
    );
  });
}
