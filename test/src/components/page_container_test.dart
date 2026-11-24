import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  const content = SizedBox(key: Key('content'), height: 100);

  group('LayoutTheme', () {
    test('page padding and the gap scale follow the form factor', () {
      final desktop = ThemeData().layoutTheme;
      final mobile = ThemeData(formFactor: FormFactor.mobile).layoutTheme;
      expect(desktop.pagePadding, const EdgeInsets.all(24));
      expect(mobile.pagePadding, const EdgeInsets.all(16));
      expect(desktop.pageMaxWidth, 1280);
      expect(mobile.pageMaxWidth, 1280);
    });

    test('a theme with nothing set falls back to the default scale', () {
      const empty = LayoutTheme();
      expect(empty.gap(GapSize.none), 0);
      expect(empty.gap(GapSize.xs), 4);
      expect(empty.gap(GapSize.sm), 8);
      expect(empty.gap(GapSize.md), 12);
      expect(empty.gap(GapSize.lg), 16);
      expect(empty.gap(GapSize.xl), 24);
    });

    test('lerps and compares by value', () {
      final a = ThemeData().layoutTheme;
      final b = ThemeData(formFactor: FormFactor.mobile).layoutTheme;
      expect(LayoutTheme.lerp(a, b, .5)!.gap(GapSize.lg), 14);
      expect(LayoutTheme.lerp(a, b, .5)!.pagePadding, const EdgeInsets.all(20));
      expect(a, ThemeData().layoutTheme);
      expect(a, isNot(b));
    });
  });

  group('PageContainer', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      for (final scrollable in [false, true]) {
        await expectBuildsInEveryLayout(
          tester,
          (layout) => PageContainer(
            scrollable: scrollable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jobs'),
                for (var i = 0; i < 4; i++)
                  Card(child: Text('A card with some content, number $i')),
              ],
            ),
          ),
        );
      }
    });

    testWidgets("gives the content the theme's page margins", (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          const PageContainer(child: content),
          formFactor: formFactor,
        );
        final width = kSurfaceSizes[formFactor]!.width;
        final margin = formFactor == FormFactor.mobile ? 16.0 : 24.0;
        final rect = tester.getRect(find.byKey(const Key('content')));

        expect(rect.left, margin, reason: '$formFactor');
        expect(rect.right, width - margin);
        expect(rect.top, margin);
      }
    });

    testWidgets('the content fills the page width instead of hugging itself', (
      tester,
    ) async {
      // A narrow child — a column of short lines — is still given the whole
      // page width, so it starts at the page margin rather than floating in
      // the middle of the window.
      await pumpFinesse(
        tester,
        const PageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Hi')],
          ),
        ),
      );
      expect(tester.getRect(find.text('Hi')).left, 24);
      expect(tester.getSize(find.byType(Column)).width, 1280 - 48);
    });

    testWidgets('on a wide window the content is capped and centred', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const PageContainer(child: content),
        surfaceSize: const Size(2000, 900),
      );
      final rect = tester.getRect(find.byKey(const Key('content')));
      // The cap is on the padding box: 1280 with the 24px margins inside it.
      expect(rect.width, 1280 - 48);
      expect(rect.center.dx, 1000);
      expect(rect.left, (2000 - 1280) / 2 + 24);
    });

    testWidgets('lines up with an app bar above it', (tester) async {
      await pumpFinesse(
        tester,
        const Scaffold(
          appBar: AppBar(
            leading: SizedBox(key: Key('logo'), width: 32, height: 32),
          ),
          body: PageContainer(child: content),
        ),
        surfaceSize: const Size(2000, 900),
      );
      final logo = tester.getRect(find.byKey(const Key('logo')));
      final page = tester.getRect(find.byKey(const Key('content')));
      // The bar's content is as wide as the page's padding box, so its ends
      // sit one page margin outside the page content.
      expect(page.left - logo.left, 24);

      // Below the maximum width the two share the same margin.
      await pumpFinesse(
        tester,
        const Scaffold(
          appBar: AppBar(
            leading: SizedBox(key: Key('logo'), width: 32, height: 32),
          ),
          body: PageContainer(child: content),
        ),
      );
      expect(
        tester.getRect(find.byKey(const Key('content'))).left,
        tester.getRect(find.byKey(const Key('logo'))).left,
      );
    });

    testWidgets('maxWidth and padding override the theme', (tester) async {
      await pumpFinesse(
        tester,
        const PageContainer(
          maxWidth: 600,
          padding: EdgeInsets.fromLTRB(10, 20, 30, 40),
          child: content,
        ),
      );
      final rect = tester.getRect(find.byKey(const Key('content')));
      expect(rect.left, (1280 - 600) / 2 + 10);
      expect(rect.right, 1280 - (1280 - 600) / 2 - 30);
      expect(rect.top, 20);
    });

    testWidgets('alignment places capped content', (tester) async {
      await pumpFinesse(
        tester,
        const PageContainer(
          maxWidth: 600,
          alignment: Alignment.topLeft,
          child: content,
        ),
      );
      expect(tester.getRect(find.byKey(const Key('content'))).left, 24);
    });

    testWidgets('adds the safe area to the padding', (tester) async {
      await pumpFinesse(
        tester,
        const MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.fromLTRB(30, 44, 10, 34)),
          child: PageContainer(child: content),
        ),
        formFactor: FormFactor.mobile,
      );
      final rect = tester.getRect(find.byKey(const Key('content')));
      expect(rect.left, 16 + 30);
      expect(rect.top, 16 + 44);
      expect(rect.right, 390 - 16 - 10);
    });

    testWidgets('the safe area is spent: descendants do not add it again', (
      tester,
    ) async {
      late EdgeInsets seen;
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.fromLTRB(30, 44, 10, 34),
          ),
          child: PageContainer(
            child: Builder(
              builder: (context) {
                seen = MediaQuery.paddingOf(context);
                return const SafeArea(
                  child: SizedBox(key: Key('inner'), height: 50),
                );
              },
            ),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      expect(seen, EdgeInsets.zero);
      // A nested SafeArea therefore adds nothing.
      expect(tester.getRect(find.byKey(const Key('inner'))).top, 16 + 44);
    });

    testWidgets('inside a scaffold the content starts below the app bar', (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(
          tester,
          const Scaffold(
            appBar: AppBar(title: Text('Jobs')),
            body: PageContainer(child: content),
          ),
          formFactor: formFactor,
        );
        final appBar = tester.getRect(find.byType(AppBar));
        final margin = formFactor == FormFactor.mobile ? 16.0 : 24.0;
        expect(
          tester.getRect(find.byKey(const Key('content'))).top,
          appBar.bottom + margin,
        );
      }
    });

    testWidgets('scrollable content scrolls, beneath the app bar', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Scaffold(
          appBar: AppBar(title: Text('Jobs')),
          body: PageContainer(
            scrollable: true,
            child: SizedBox(key: Key('tall'), height: 3000),
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      final appBar = tester.getRect(find.byType(AppBar));
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('tall'))).top,
        appBar.bottom + 16,
      );

      await tester.drag(find.byType(PageContainer), const Offset(0, -200));
      await tester.pump();
      // The content has moved up under the bar: the viewport is the whole
      // page, and only the padding kept it clear.
      expect(
        tester.getRect(find.byKey(const Key('tall'))).top,
        appBar.bottom + 16 - 200,
      );
    });

    testWidgets('scrollable content still fills the width and hugs its '
        'height', (tester) async {
      await pumpFinesse(
        tester,
        const PageContainer(scrollable: true, child: content),
      );
      final rect = tester.getRect(find.byKey(const Key('content')));
      expect(rect.width, 1280 - 48);
      expect(rect.height, 100);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the controller it is given', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await pumpFinesse(
        tester,
        PageContainer(
          scrollable: true,
          controller: controller,
          child: const SizedBox(height: 3000),
        ),
      );
      controller.jumpTo(150);
      await tester.pump();
      expect(controller.offset, 150);
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .controller,
        controller,
      );
    });

    testWidgets('a non-scrollable page gives its child the remaining height', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const PageContainer(
          child: Column(
            children: [
              SizedBox(height: 50),
              Expanded(child: SizedBox.expand(key: Key('rest'))),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const Key('rest'))).height,
        800 - 48 - 50,
      );
    });

    testWidgets('follows a theme override', (tester) async {
      await pumpFinesse(
        tester,
        const PageContainer(child: content),
        theme: ThemeData(
          layoutTheme: const LayoutTheme(
            pagePadding: EdgeInsets.all(40),
            pageMaxWidth: 800,
          ),
        ),
      );
      final rect = tester.getRect(find.byKey(const Key('content')));
      expect(rect.width, 800 - 80);
      expect(rect.top, 40);
    });
  });
}
