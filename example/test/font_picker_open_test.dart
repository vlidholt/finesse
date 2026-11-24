import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:finesse/finesse.dart';
import 'package:finesse/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  setUpAll(setUpFonts);

  testWidgets('the font picker opens', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        builder: (context, child) => FinesseMaterial(child: child!),
        home: Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: ThemeCustomizerPanel.width,
            child: ThemeCustomizerPanel(
              config: const ThemeEditorConfig(),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // The default body font is the one the picker shows.
    await tester.tap(find.text(const ThemeEditorConfig().fontTitle));
    await settle(tester);
    expect(find.text('Roboto Slab'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
