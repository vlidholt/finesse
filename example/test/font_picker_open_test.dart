import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/common/theme_editor/editor_config.dart';
import 'package:example/common/theme_editor/fonts.dart';
import 'package:finesse/finesse.dart';
import 'package:finesse/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The font pickers list every font in its own face, and asking
/// `google_fonts` for a face is what downloads it. These tests pin *when*
/// that happens: for the rows on screen, as they come on screen — not for
/// all twenty-six families the moment the panel opens.
void main() {
  setUpAll(setUpFonts);

  late ThemeEditorConfig config;

  Future<void> pumpPanel(
    WidgetTester tester, {
    ThemeEditorConfig initial = const ThemeEditorConfig(),
  }) async {
    config = initial;
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        builder: (context, child) => FinesseMaterial(child: child!),
        home: StatefulBuilder(
          builder: (context, setState) => Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: ThemeCustomizerPanel.width,
              child: ThemeCustomizerPanel(
                config: config,
                onChanged: (next) => setState(() => config = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// The list inside the open picker.
  Finder list() => find.byType(ListView);

  setUp(EditorFont.debugResetPreviews);

  testWidgets('opening the panel fetches no font previews', (tester) async {
    await pumpPanel(tester);
    await settle(tester);

    expect(find.text('Font'), findsOneWidget);
    expect(find.text('Heading'), findsOneWidget);
    expect(EditorFont.debugPreviewedFamilies, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the font picker opens, previewing only the rows in view', (
    tester,
  ) async {
    await pumpPanel(tester);
    // The default body font is the one the picker shows.
    await tester.tap(find.text(const ThemeEditorConfig().fontTitle));
    await settle(tester);

    expect(list(), findsOneWidget);
    // The top of the list is there, each in its own face…
    final first = EditorFont.all.take(8).map((f) => f.family);
    for (final family in first) {
      expect(
        find.descendant(of: list(), matching: find.text(family)),
        findsOneWidget,
        reason: family,
      );
      expect(EditorFont.debugPreviewedFamilies, contains(family));
    }
    // …and the rest has not been built, so it has not been fetched.
    final previewed = EditorFont.debugPreviewedFamilies;
    expect(previewed.length, lessThan(EditorFont.all.length ~/ 2));
    for (final later in ['Roboto Slab', 'Lora', 'Instrument Serif']) {
      expect(find.text(later), findsNothing, reason: later);
      expect(previewed, isNot(contains(later)), reason: later);
    }
    // Exactly the rows that were built: the ones on screen, plus the one
    // row the list keeps ready past its edge (which a finder does not see).
    final onScreen = find
        .descendant(of: list(), matching: find.byType(Text))
        .evaluate()
        .length;
    expect(previewed.length, inInclusiveRange(onScreen, onScreen + 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling a row into view fetches its preview', (tester) async {
    await pumpPanel(tester);
    await tester.tap(find.text('Font'));
    await settle(tester);
    expect(EditorFont.debugPreviewedFamilies, isNot(contains('Roboto Slab')));

    // Thirteen rows down; `dragUntilVisible` would overshoot to the end.
    await tester.drag(list(), const Offset(0, -450));
    await settle(tester);
    expect(find.text('Roboto Slab'), findsOneWidget);
    expect(EditorFont.debugPreviewedFamilies, contains('Roboto Slab'));
    // The very last one is still out of view.
    expect(
      EditorFont.debugPreviewedFamilies,
      isNot(contains('Instrument Serif')),
    );

    // All the way down: every font is reachable.
    await tester.drag(list(), const Offset(0, -2000));
    await settle(tester);
    expect(find.text('Instrument Serif'), findsOneWidget);
    expect(EditorFont.debugPreviewedFamilies, contains('Instrument Serif'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the picker opens at the selected font', (tester) async {
    await pumpPanel(
      tester,
      initial: const ThemeEditorConfig(fontTitle: 'Lora'),
    );
    await tester.tap(find.text('Font'));
    await settle(tester);

    // Lora is the twenty-third of twenty-six: far below the fold.
    expect(
      find.descendant(of: list(), matching: find.text('Lora')),
      findsOneWidget,
    );
    expect(EditorFont.debugPreviewedFamilies, contains('Lora'));
    // …and the top of the list was never built.
    expect(EditorFont.debugPreviewedFamilies, isNot(contains('Inter')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing a font applies it only after it has loaded', (
    tester,
  ) async {
    await pumpPanel(tester);
    await tester.tap(find.text('Font'));
    await settle(tester);
    await tester.tap(
      find.descendant(of: list(), matching: find.text('Figtree')),
    );
    await settle(tester);

    // Loading: the row names the font that is coming and shows a spinner,
    // and the configuration — so the app — has not changed yet.
    expect(list(), findsNothing);
    expect(find.text('Figtree'), findsOneWidget);
    expect(find.byType(Spinner), findsOneWidget);
    expect(config.fontTitle, 'Geist');

    // With no network the load gives up after its timeout, and the font is
    // applied in whatever state it is in.
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
    expect(config.fontTitle, 'Figtree');
    expect(find.byType(Spinner), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a newer pick supersedes one still loading', (tester) async {
    await pumpPanel(tester);

    Future<void> pick(String title) async {
      await tester.tap(find.text('Font'));
      await settle(tester);
      await tester.tap(find.descendant(of: list(), matching: find.text(title)));
      await settle(tester);
    }

    await pick('Inter');
    await pick('Roboto');
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);

    expect(config.fontTitle, 'Roboto');
    expect(tester.takeException(), isNull);
  });
}
