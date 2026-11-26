import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

void main() {
  final navigator = GlobalKey<NavigatorState>();

  /// Pumps a home page and pushes [page] over it.
  Future<void> pushPage(
    WidgetTester tester,
    Widget page, {
    FormFactor formFactor = FormFactor.desktop,
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = kSurfaceSizes[formFactor]!;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        navigatorKey: navigator,
        formFactor: formFactor,
        builder: (context, child) =>
            Directionality(textDirection: direction, child: child!),
        home: const Center(child: Text('Home')),
      ),
    );
    navigator.currentState!.push(
      UnaPageRoute<void>(builder: (_) => Center(child: page)),
    );
    await tester.pumpAndSettle();
  }

  group('BackButton', () {
    testWidgets('builds in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => const Center(
          child: UnaRow(
            mainAxisSize: MainAxisSize.min,
            children: [BackButton(), CloseButton()],
          ),
        ),
      );
    });

    testWidgets('pops the page it is on', (tester) async {
      await pushPage(tester, const BackButton());
      expect(find.text('Home'), findsNothing);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('asks the page first: a PopScope can refuse', (tester) async {
      var asked = 0;
      await pushPage(
        tester,
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) => asked++,
          child: const BackButton(),
        ),
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(asked, 1);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('onPressed replaces the pop', (tester) async {
      var pressed = 0;
      await pushPage(tester, BackButton(onPressed: () => pressed++));
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('on the first page there is nothing to pop, and nothing '
        'happens', (tester) async {
      await pumpUna(tester, const Center(child: BackButton()));
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('the caret points at the start of the line', (tester) async {
      await pumpUna(tester, const Center(child: BackButton()));
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsOneWidget);
      await pumpUna(
        tester,
        const Center(child: BackButton()),
        textDirection: TextDirection.rtl,
      );
      expect(find.byIcon(PhosphorIconsRegular.caretRight), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsNothing);
    });

    testWidgets('an icon of its own replaces the caret', (tester) async {
      await pumpUna(
        tester,
        const Center(
          child: BackButton(icon: PhosphorIcon(PhosphorIconsRegular.arrowLeft)),
        ),
      );
      expect(find.byIcon(PhosphorIconsRegular.arrowLeft), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsNothing);
    });

    testWidgets('is one button named "Back", or what it is told', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, const Center(child: BackButton()));
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      final data = tester
          .getSemantics(find.bySemanticsLabel('Back'))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);

      await pumpUna(
        tester,
        const Center(child: BackButton(semanticLabel: 'Back to inbox')),
      );
      expect(find.bySemanticsLabel('Back to inbox'), findsOneWidget);
      expect(find.bySemanticsLabel('Back'), findsNothing);
      handle.dispose();
    });

    testWidgets('the keyboard reaches and presses it', (tester) async {
      useTraditionalHighlights();
      await pushPage(tester, const BackButton());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('enabled: false does nothing', (tester) async {
      await pushPage(tester, const BackButton(enabled: false));
      await tester.tap(find.byType(BackButton), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('on a desktop its name is also its tooltip; on a phone a '
        'finger gets none', (tester) async {
      await pumpUna(tester, const Center(child: BackButton()));
      expect(find.byType(Tooltip), findsOneWidget);
      await hoverAt(tester, tester.getCenter(find.byType(BackButton)));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Back'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpUna(
        tester,
        const Center(child: BackButton()),
        formFactor: FormFactor.mobile,
      );
      expect(find.byType(Tooltip), findsNothing);
    });
  });

  group('CloseButton', () {
    testWidgets('is a cross named "Close" that pops the page', (tester) async {
      final handle = tester.ensureSemantics();
      await pushPage(tester, const CloseButton());
      expect(find.byIcon(PhosphorIconsRegular.x), findsOneWidget);
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('onPressed, icon and semanticLabel replace the defaults', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var pressed = 0;
      await pushPage(
        tester,
        CloseButton(
          onPressed: () => pressed++,
          icon: const PhosphorIcon(PhosphorIconsRegular.arrowDown),
          semanticLabel: 'Discard',
        ),
      );
      expect(find.byIcon(PhosphorIconsRegular.arrowDown), findsOneWidget);
      expect(find.bySemanticsLabel('Discard'), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      handle.dispose();
    });

    testWidgets('does not turn round in a right-to-left language', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(child: CloseButton()),
        textDirection: TextDirection.rtl,
      );
      expect(find.byIcon(PhosphorIconsRegular.x), findsOneWidget);
    });
  });
}
