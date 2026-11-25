import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// `LicensePage` and `showLicensePage`.
void main() {
  void register(Map<List<String>, String> licenses) {
    LicenseRegistry.reset();
    LicenseRegistry.addLicense(
      () => Stream.fromIterable([
        for (final MapEntry(:key, :value) in licenses.entries)
          LicenseEntryWithLineBreaks(key, value),
      ]),
    );
  }

  setUp(() {
    register({
      ['zebra']: 'Zebra licence text.',
      ['Alpha']: 'Alpha first licence.\n\nIts second paragraph.',
      ['Alpha', 'beta']: 'A licence shared by two packages.',
      ['Strand']: 'The licence of the app itself.',
    });
  });
  tearDown(LicenseRegistry.reset);

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1000, 700),
    TextDirection direction = TextDirection.ltr,
    double textScale = 1,
    Widget? home,
    String title = 'Strand',
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      FinesseApp(
        title: title,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Directionality(textDirection: direction, child: child!),
        ),
        home:
            home ??
            Builder(
              builder: (context) => Center(
                child: Button(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationVersion: '2.4.0',
                    applicationLegalese: '© Strand Labs',
                    applicationIcon: const PhosphorIcon(
                      PhosphorIconsFill.circlesThree,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
      ),
    );
  }

  /// A route transition, and the licences loading between frames.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await settle(tester);
  }

  testWidgets('shows a spinner until the licences are read, then lists the '
      'packages: the app first, then the alphabet, each with its count', (
    tester,
  ) async {
    // A registry that has not finished yet, on top of the one from setUp.
    final late = StreamController<LicenseEntry>();
    LicenseRegistry.addLicense(() => late.stream);
    await pump(tester);
    await tester.tap(find.text('Open'));
    // A spinner does not settle: fixed frames.
    await settle(tester);
    expect(find.byType(Spinner), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    // Under the fake clock the close is only delivered by the next pump.
    unawaited(late.close());
    await settle(tester);
    expect(find.byType(Spinner), findsNothing);

    final names = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title as Text).data)
        .toList();
    expect(names, ['Strand', 'Alpha', 'beta', 'zebra']);
    final counts = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.subtitle! as Text).data)
        .toList();
    expect(counts, ['1 license', '2 licenses', '1 license', '1 license']);
  });

  testWidgets('says what the app is above the list; the name falls back to '
      'the title of the app', (tester) async {
    await pump(tester);
    await open(tester);
    expect(find.text('Licenses'), findsOneWidget);
    // The header and the package of the same name.
    expect(find.text('Strand'), findsNWidgets(2));
    expect(find.text('2.4.0'), findsOneWidget);
    expect(find.text('© Strand Labs'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsFill.circlesThree), findsOneWidget);
    final theme = Theme.of(tester.element(find.text('2.4.0')));
    expect(
      tester.widget<Text>(find.text('2.4.0')).style,
      theme.textTheme.muted,
    );
  });

  testWidgets('a package opens on a page of its own with its licences in '
      'full, and Back comes back', (tester) async {
    await pump(tester);
    await open(tester);
    await tester.tap(find.text('Alpha'));
    await settle(tester);
    expect(find.text('Alpha first licence.'), findsOneWidget);
    expect(find.text('Its second paragraph.'), findsOneWidget);
    expect(find.text('A licence shared by two packages.'), findsOneWidget);
    // One hairline between its two licences.
    expect(find.byType(Divider), findsOneWidget);
    expect(find.text('Zebra licence text.'), findsNothing);

    await tester.tap(find.byType(IconButton));
    await settle(tester);
    expect(find.text('Alpha first licence.'), findsNothing);
    expect(find.text('zebra'), findsOneWidget);

    // And Back again leaves the licences altogether.
    await tester.tap(find.byType(IconButton));
    await settle(tester);
    expect(find.text('Licenses'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('the keyboard opens a package and Escape-free Back is a Tab '
      'stop with a name', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    await open(tester);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    // Back, then the first package.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await settle(tester);
    expect(find.text('The licence of the app itself.'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('as a page of its own it has no Back, and takes its name '
      'from the widget', (tester) async {
    await pump(
      tester,
      home: const LicensePage(applicationName: 'Other'),
    );
    await settle(tester);
    expect(find.byType(IconButton), findsNothing);
    expect(find.text('Other'), findsOneWidget);
    expect(find.text('zebra'), findsOneWidget);
  });

  testWidgets('no licences at all: the header and nothing else', (
    tester,
  ) async {
    LicenseRegistry.reset();
    await pump(tester, home: const LicensePage(applicationVersion: '1.0'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(Spinner), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('1.0'), findsOneWidget);
  });

  testWidgets('a long list is built as it is scrolled to', (tester) async {
    register({
      for (var i = 0; i < 400; i++)
        ['package_${i.toString().padLeft(3, '0')}']: 'Licence $i',
    });
    await pump(tester, home: const LicensePage());
    await settle(tester);
    expect(find.text('package_000'), findsOneWidget);
    expect(find.byType(ListTile).evaluate().length, lessThan(40));
    expect(find.text('package_399', skipOffstage: false), findsNothing);
  });

  testWidgets('the content keeps to the page: inside the margins on a '
      'phone, a centred column on a desktop, clear of the app bar', (
    tester,
  ) async {
    await pump(tester, size: const Size(390, 800), home: const LicensePage());
    await settle(tester);
    var theme = Theme.of(tester.element(find.byType(LicensePage)));
    final margin = theme.layoutTheme.pagePadding!.resolve(TextDirection.ltr);
    // The rows are on the section's card, which keeps to the margins; a
    // row is inside the card's hairline.
    var tile = tester.getRect(find.byType(ListTile).first);
    expect(find.byType(SliverListSection), findsOneWidget);
    expect(tile.left, inInclusiveRange(margin.left, margin.left + 2));
    expect(
      tile.right,
      inInclusiveRange(388 - margin.right, 390 - margin.right),
    );
    final bar = tester.getRect(find.byType(AppBar));
    expect(
      tester.getRect(find.text('Strand').first).top,
      greaterThan(bar.bottom),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await pump(tester, size: const Size(1400, 800), home: const LicensePage());
    await settle(tester);
    theme = Theme.of(tester.element(find.byType(LicensePage)));
    tile = tester.getRect(find.byType(ListTile).first);
    expect(tile.center.dx, moreOrLessEquals(700));
    expect(tile.width, lessThanOrEqualTo(720));
  });

  testWidgets('right to left, and at twice the text size, nothing overflows '
      'and the arrows point the other way', (tester) async {
    await pump(
      tester,
      size: const Size(390, 800),
      direction: TextDirection.rtl,
      textScale: 2,
    );
    await open(tester);
    expect(tester.takeException(), isNull);
    // The rows' chevrons, and the app bar's back button.
    expect(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.byIcon(PhosphorIconsRegular.caretLeft),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byType(BackButton),
        matching: find.byIcon(PhosphorIconsRegular.caretRight),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Alpha'));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving while the licences are still being read is quiet', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpWidget(const SizedBox.shrink());
    await settle(tester);
    expect(tester.takeException(), isNull);
  });
}
