import 'package:example/common/app_state.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/screens/components_screen.dart';
import 'package:example/showcase/showcase_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import 'support.dart';

/// The showcase is what the app opens on; the top bar switches to the
/// reference; on a desktop the editor opens beside it by itself.
void main() {
  setUpAll(setUpFonts);

  Finder visible<T>() => find.byType(T);

  testWidgets('the app opens on the showcase, and the bar switches to the '
      'reference and back, keeping each', (tester) async {
    await pumpApp(tester, startOn: AppSection.showcase);
    expect(visible<ShowcaseScreen>(), findsOneWidget);
    expect(visible<ComponentsScreen>(), findsNothing);

    await tester.tap(find.text('Components').first);
    await settle(tester);
    expect(visible<ComponentsScreen>(), findsOneWidget);
    expect(visible<ShowcaseScreen>(), findsNothing);
    // Still built, off stage: its state is kept.
    expect(
      find.byType(ShowcaseScreen, skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.text('Showcase').first);
    await settle(tester);
    expect(visible<ShowcaseScreen>(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a desktop the editor opens by itself; on a phone it does '
      'not', (tester) async {
    await pumpApp(tester, startOn: AppSection.showcase, openEditor: true);
    expect(find.byType(ThemeCustomizerPanel), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await pumpApp(
      tester,
      size: mobileSize,
      startOn: AppSection.showcase,
      openEditor: true,
    );
    expect(find.byType(ThemeCustomizerPanel), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets("the header's buttons open the editor and the reference", (
    tester,
  ) async {
    await pumpApp(tester, startOn: AppSection.showcase);
    await tester.tap(find.text('Customize the theme'));
    await settle(tester);
    expect(find.byType(ThemeCustomizerPanel), findsOneWidget);

    await tester.tap(find.text('Browse components'));
    await settle(tester);
    expect(
      appSectionProvider.of(appContext(tester)).value,
      AppSection.components,
    );
    expect(tester.takeException(), isNull);
  });

  for (final (name, size) in [
    ('desktop', desktopSize),
    ('phone', mobileSize),
  ]) {
    testWidgets('builds every card on a $name, light and dark', (
      tester,
    ) async {
      await pumpApp(tester, size: size, startOn: AppSection.showcase);
      // Scroll the whole page through, so every card is laid out.
      final scrollable = find
          .descendant(
            of: find.byType(ShowcaseScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      for (var i = 0; i < 12; i++) {
        await tester.drag(scrollable, const Offset(0, -600));
        await settle(tester);
      }
      themeModeProvider.of(appContext(tester)).value = ThemeMode.dark;
      await settle(tester);
      expect(find.text('Quick actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
