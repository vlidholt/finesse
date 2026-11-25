import 'dart:async';

import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/surface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  late List<String> log;

  setUp(() => log = []);

  Widget products() => SizedBox(
    width: 320,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavigationMenuLink(
          title: const Text('Analytics'),
          description: const Text('Traffic, live.'),
          onPressed: () => log.add('analytics'),
        ),
        NavigationMenuLink(
          title: const Text('Automation'),
          onPressed: () => log.add('automation'),
        ),
      ],
    ),
  );

  Widget resources() => SizedBox(
    width: 200,
    child: NavigationMenuLink(
      title: const Text('Docs'),
      onPressed: () => log.add('docs'),
    ),
  );

  Widget menu({
    bool? collapsed,
    bool openOnHover = true,
    AlignmentGeometry alignment = Alignment.topCenter,
    bool selectPricing = false,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: NavigationMenu(
          collapsed: collapsed,
          openOnHover: openOnHover,
          onOpenChanged: (index) => log.add('open $index'),
          items: [
            NavigationMenuItem(
              label: const Text('Products'),
              builder: (_) => products(),
            ),
            NavigationMenuItem(
              label: const Text('Resources'),
              builder: (_) => resources(),
            ),
            NavigationMenuItem(
              label: const Text('Pricing'),
              selected: selectPricing,
              onPressed: () => log.add('pricing'),
            ),
            const NavigationMenuItem(label: Text('Soon'), enabled: false),
          ],
        ),
      ),
    );
  }

  /// The panel's surface.
  Rect panelRect(WidgetTester tester) => tester.getRect(
    find.ancestor(
      of: find.byType(SpringSize),
      matching: find.byType(SurfacePainter),
    ),
  );

  Future<TestGesture> mouse(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(1, 700));
    addTearDown(gesture.removePointer);
    return gesture;
  }

  Future<void> frames(WidgetTester tester, [int count = 30]) async {
    for (var i = 0; i < count; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  group('NavigationMenuTheme', () {
    test('is fed by the style, the scheme and the spacing', () {
      for (final style in [
        StyleTokens.finesse,
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        for (final brightness in Brightness.values) {
          final theme = ThemeData(style: style, brightness: brightness);
          final t = theme.navigationMenuTheme;
          expect(t.gap, 4);
          expect(t.panelOffset, 6);
          expect(t.linkBorderRadius, isNotNull);
          expect(t.selectedColor!.a, greaterThan(0));
          expect(t.linkHoverColor!.a, greaterThan(0));
          expect(t.linkSelectedColor!.a, lessThan(t.linkHoverColor!.a));
          expect(
            t.linkDescriptionStyle!.color,
            theme.colorScheme.mutedForeground,
          );
          expect(t.openDelay, isNotNull);
          expect(t.closeDelay, isNotNull);
        }
      }
      // A wash of the foreground where floating surfaces are glass.
      final finesse = ThemeData();
      expect(
        finesse.navigationMenuTheme.linkHoverColor!.a,
        closeTo(finesse.style.menuHighlightOpacity!, .001),
      );
      final wide = ThemeData(spacing: const Spacing(step: 6));
      expect(wide.navigationMenuTheme.gap, 6);
    });

    test('a theme override reaches the menu, and equal themes are equal', () {
      const override = NavigationMenuTheme(gap: 20);
      final theme = ThemeData(navigationMenuTheme: override);
      expect(theme.navigationMenuTheme.gap, 20);
      expect(theme.navigationMenuTheme.panelOffset, 6);
      expect(
        ThemeData().navigationMenuTheme,
        ThemeData().navigationMenuTheme,
      );
      expect(
        theme.copyWith(radius: BorderRadius.zero).navigationMenuTheme.gap,
        20,
      );
    });
  });

  group('NavigationMenu row', () {
    testWidgets('builds in every layout at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: menu(),
        ),
      );
    });

    testWidgets('at rest it schedules nothing', (tester) async {
      await pumpFinesse(tester, menu());
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('a link calls back; a trigger opens its panel and a second '
        'press closes it', (tester) async {
      await pumpFinesse(tester, menu());
      await tester.tap(find.text('Pricing'));
      await tester.pump();
      expect(log, ['pricing']);

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      expect(log, ['pricing', 'open 0']);
      // Under the row, starting where its trigger does.
      final panel = panelRect(tester);
      final trigger = tester.getRect(
        find.ancestor(of: find.text('Products'), matching: find.byType(Button)),
      );
      expect(panel.top, closeTo(trigger.bottom + 6, 1));
      expect(panel.left, closeTo(trigger.left, 1));

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsNothing);
      expect(log.last, 'open null');
    });

    testWidgets('a disabled entry does nothing', (tester) async {
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: NavigationMenu(
            onOpenChanged: (index) => log.add('open $index'),
            items: [
              NavigationMenuItem(
                label: const Text('Products'),
                enabled: false,
                builder: (_) => products(),
              ),
              NavigationMenuItem(
                label: const Text('Pricing'),
                enabled: false,
                onPressed: () => log.add('pricing'),
              ),
            ],
          ),
        ),
      );
      // A press where each entry is: a disabled entry takes no pointer,
      // so `tap` on its finder would land on whatever is below it.
      for (final label in ['Products', 'Pricing']) {
        await tester.tapAt(tester.getCenter(find.text(label)));
        await tester.pumpAndSettle();
      }
      expect(find.text('Analytics'), findsNothing);
      expect(log, isEmpty);
    });

    testWidgets('a press outside closes the panel; a press on a link in it '
        'closes it and calls back', (tester) async {
      await pumpFinesse(tester, menu());
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 700));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsNothing);

      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Automation'));
      await tester.pumpAndSettle();
      expect(find.text('Automation'), findsNothing);
      expect(log, ['open 0', 'open null', 'open 0', 'open null', 'automation']);
    });

    testWidgets('the fill marks the selected entry, and the open trigger '
        'while a panel is open', (tester) async {
      await pumpFinesse(tester, menu(selectPricing: true));
      bool marked(String label) => tester
          .widget<MovingIndicatorTarget>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(MovingIndicatorTarget),
            ),
          )
          .selected;
      expect(marked('Pricing'), isTrue);
      expect(marked('Products'), isFalse);
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(marked('Pricing'), isFalse);
      expect(marked('Products'), isTrue);
      // One indicator for the row.
      expect(find.byType(MovingIndicator), findsOneWidget);
    });
  });

  group('NavigationMenu hover', () {
    testWidgets('resting on a trigger opens its panel after the delay; '
        'leaving closes it after another', (tester) async {
      await pumpFinesse(tester, menu());
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Analytics'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      await frames(tester);
      expect(find.text('Analytics'), findsOneWidget);

      await pointer.moveTo(const Offset(1, 700));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Analytics'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('a pointer that only passes over a trigger opens nothing', (
      tester,
    ) async {
      await pumpFinesse(tester, menu());
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 50));
      await pointer.moveTo(const Offset(1, 700));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Analytics'), findsNothing);
      expect(log, isEmpty);
    });

    testWidgets('the pointer can cross from the trigger into the panel', (
      tester,
    ) async {
      await pumpFinesse(tester, menu());
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 200));
      await frames(tester);
      // Through the gap between the two, then onto a link.
      final panel = panelRect(tester);
      await pointer.moveTo(Offset(panel.left + 30, panel.top - 3));
      await tester.pump(const Duration(milliseconds: 60));
      await pointer.moveTo(tester.getCenter(find.text('Automation')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Automation'), findsOneWidget);
      expect(log, ['open 0']);
    });

    testWidgets('moving to another trigger keeps the one panel: it slides '
        'under the new trigger and resizes, monotonically', (tester) async {
      await pumpFinesse(tester, menu());
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      final surface = tester.element(
        find.ancestor(
          of: find.byType(SpringSize),
          matching: find.byType(SurfacePainter),
        ),
      );
      final from = panelRect(tester);

      await pointer.moveTo(tester.getCenter(find.text('Resources')));
      await tester.pump();
      // At once: no delay between two panels, and the same surface.
      expect(log, ['open 0', 'open 1']);
      expect(find.byType(Popover), findsOneWidget);
      final lefts = <double>[];
      final widths = <double>[];
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final rect = panelRect(tester);
        lefts.add(rect.left);
        widths.add(rect.width);
      }
      expect(
        tester.element(
          find.ancestor(
            of: find.byType(SpringSize),
            matching: find.byType(SurfacePainter),
          ),
        ),
        same(surface),
      );
      expect(find.text('Docs'), findsOneWidget);
      expect(find.text('Analytics'), findsNothing);

      final trigger = tester.getRect(
        find.ancestor(
          of: find.text('Resources'),
          matching: find.byType(Button),
        ),
      );
      expect(lefts.last, closeTo(trigger.left, 1));
      expect(lefts.last, greaterThan(from.left + 20));
      expect(widths.last, lessThan(from.width - 50));
      // On the way: somewhere in between, and never back.
      expect(
        lefts.where((x) => x > from.left + 2 && x < lefts.last - 2),
        isNotEmpty,
      );
      for (var i = 1; i < lefts.length; i++) {
        expect(lefts[i], greaterThanOrEqualTo(lefts[i - 1] - .01));
        expect(widths[i], lessThanOrEqualTo(widths[i - 1] + .01));
      }
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('moving on to a plain link closes the panel', (tester) async {
      await pumpFinesse(tester, menu());
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      await pointer.moveTo(tester.getCenter(find.text('Pricing')));
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('with openOnHover off only a press opens', (tester) async {
      await pumpFinesse(tester, menu(openOnHover: false));
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Analytics'), findsNothing);
      await pointer.down(tester.getCenter(find.text('Products')));
      await pointer.up();
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      // And it stays while the pointer wanders off.
      await pointer.moveTo(const Offset(1, 700));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('with reduced motion the panel is simply under the new '
        'trigger', (tester) async {
      await pumpFinesse(
        tester,
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: menu(),
          ),
        ),
      );
      await tester.tap(find.text('Products'));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Resources')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final trigger = tester.getRect(
        find.ancestor(
          of: find.text('Resources'),
          matching: find.byType(Button),
        ),
      );
      expect(panelRect(tester).left, closeTo(trigger.left, 1));
    });
  });

  group('NavigationMenu placement', () {
    testWidgets('a panel that would leave the screen is kept on it', (
      tester,
    ) async {
      await pumpFinesse(tester, menu(alignment: Alignment.topRight));
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      final panel = panelRect(tester);
      final margin = themeOf(
        tester,
        find.byType(NavigationMenu),
      ).navigationMenuTheme.panelMargin!;
      expect(panel.right, lessThanOrEqualTo(1280 - margin + 1));
      expect(panel.width, greaterThan(300));
    });

    testWidgets("right to left, the panel hangs from its trigger's right "
        'edge', (tester) async {
      await pumpFinesse(
        tester,
        menu(),
        textDirection: TextDirection.rtl,
      );
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      final trigger = tester.getRect(
        find.ancestor(of: find.text('Products'), matching: find.byType(Button)),
      );
      expect(panelRect(tester).right, closeTo(trigger.right, 1));
    });
  });

  group('NavigationMenu keyboard', () {
    String? focusedLabel(WidgetTester tester) {
      final context = FocusManager.instance.primaryFocus?.context;
      if (context == null) return null;
      final texts = find.descendant(
        of: find.byElementPredicate((element) => element == context),
        matching: find.byType(Text),
      );
      return texts.evaluate().isEmpty
          ? null
          : tester.widget<Text>(texts.first).data;
    }

    testWidgets('each entry is a Tab stop, and the arrows, Home and End '
        'walk the row past a disabled entry', (tester) async {
      await pumpFinesse(tester, menu());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedLabel(tester), 'Products');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedLabel(tester), 'Resources');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focusedLabel(tester), 'Pricing');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedLabel(tester), 'Pricing');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(focusedLabel(tester), 'Products');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedLabel(tester), 'Resources');
    });

    testWidgets('Enter opens a panel, Tab goes into it and on to the next '
        'entry, and Escape closes it from the row', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, menu());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      expect(focusedLabel(tester), 'Products');

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedLabel(tester), 'Analytics');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focusedLabel(tester), 'Automation');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      // The focus went on along the row, and took the panel with it.
      expect(focusedLabel(tester), 'Resources');
      expect(find.text('Docs'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Docs'), findsNothing);
      expect(focusedLabel(tester), 'Resources');
    });

    testWidgets('the down arrow opens the panel and goes into it; Escape '
        'there closes it and gives the focus back to the trigger', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, menu());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(focusedLabel(tester), 'Analytics');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsNothing);
      expect(focusedLabel(tester), 'Products');
      expect(log, ['open 0', 'open null']);
    });

    testWidgets('Enter on a link in the panel follows it', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, menu());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(log, ['open 0', 'open null', 'analytics']);
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('Escape closes a panel the pointer opened, wherever the '
        'focus is', (tester) async {
      await pumpFinesse(tester, menu());
      final pointer = await mouse(tester);
      await pointer.moveTo(tester.getCenter(find.text('Products')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsNothing);
    });

    testWidgets('collapsed with a panel open, it closes the panel and leaves '
        'Escape to the sheet', (tester) async {
      late StateSetter rebuild;
      var collapsed = false;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return menu(collapsed: collapsed);
          },
        ),
      );
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      rebuild(() => collapsed = true);
      await tester.pumpAndSettle();
      expect(log, ['open 0', 'open null']);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(find.text('Pricing'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Pricing'), findsNothing);
    });

    testWidgets('under a dialog, Escape is the dialog\'s', (tester) async {
      await pumpFinesse(tester, menu());
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Analytics'), findsOneWidget);
      unawaited(
        showDialog<void>(
          context: tester.element(find.text('Products')),
          builder: (_) => const Dialog(child: Text('Dialog')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Dialog'), findsNothing);
    });
  });

  group('NavigationMenu semantics', () {
    testWidgets('the menu has a name, and a trigger says whether its panel '
        'is open', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, menu(selectPricing: true));
      expect(find.bySemanticsLabel('Navigation menu'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Products')),
        // One node for the button and the state of its panel.
        containsSemantics(
          label: 'Products',
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Products')),
        containsSemantics(label: 'Products', isExpanded: true),
      );
      handle.dispose();
    });
  });

  group('NavigationMenu collapsed', () {
    testWidgets('on a phone it is one named button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, menu(), formFactor: FormFactor.mobile);
      expect(find.text('Products'), findsNothing);
      expect(find.bySemanticsLabel('Open menu'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the button opens a sheet with the links as rows and each '
        "trigger's content under its label", (tester) async {
      await pumpFinesse(tester, menu(), formFactor: FormFactor.mobile);
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      expect(log, ['open 0']);
      for (final text in [
        'Products',
        'Analytics',
        'Automation',
        'Resources',
        'Docs',
        'Pricing',
        'Soon',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      // Top to bottom, in the row's order, each row a touch target and as
      // wide as the sheet lets it be.
      final tops = [
        for (final text in ['Products', 'Analytics', 'Resources', 'Pricing'])
          tester.getTopLeft(find.text(text)).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      final docs = tester.getSize(
        find.ancestor(
          of: find.text('Docs'),
          matching: find.byType(NavigationMenuLink),
        ),
      );
      expect(docs.height, greaterThanOrEqualTo(44));
      expect(docs.width, greaterThan(300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a link in the sheet closes it and calls back', (tester) async {
      await pumpFinesse(tester, menu(), formFactor: FormFactor.mobile);
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();
      expect(find.text('Docs'), findsNothing);
      expect(log, ['open 0', 'docs', 'open null']);

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pricing'));
      await tester.pumpAndSettle();
      expect(log.sublist(3), ['open 0', 'pricing', 'open null']);
    });

    testWidgets('collapsed: true collapses a desktop menu, and false keeps '
        "a phone's a row", (tester) async {
      await pumpFinesse(tester, menu(collapsed: true));
      expect(find.text('Products'), findsNothing);
      expect(find.byType(IconButton), findsOneWidget);
      await pumpFinesse(
        tester,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: menu(collapsed: false),
        ),
        formFactor: FormFactor.mobile,
      );
      expect(find.text('Products'), findsOneWidget);
    });
  });

  group('NavigationMenuLink', () {
    testWidgets('outside a menu it is a link like any other', (tester) async {
      var pressed = 0;
      await pumpFinesse(
        tester,
        Center(
          child: SizedBox(
            width: 240,
            child: NavigationMenuLink(
              title: const Text('Docs'),
              description: const Text('Guides and reference.'),
              leading: const PhosphorIcon(PhosphorIconsRegular.book),
              onPressed: () => pressed++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
      expect(tester.getSize(find.byType(NavigationMenuLink)).width, 240);
    });

    testWidgets('it highlights under the pointer without a flash, and a '
        'selected link rests on a fainter fill', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: SizedBox(
            width: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavigationMenuLink(title: const Text('One'), onPressed: () {}),
                NavigationMenuLink(
                  title: const Text('Two'),
                  selected: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      Color? fill(String title) => tester
          .widget<AnimatedFill>(
            find.ancestor(
              of: find.text(title),
              matching: find.byType(AnimatedFill),
            ),
          )
          .color;
      final theme = themeOf(
        tester,
        find.byType(NavigationMenuLink).first,
      ).navigationMenuTheme;
      expect(fill('One')!.a, 0);
      expect(fill('Two'), theme.linkSelectedColor);
      await hoverAt(tester, tester.getCenter(find.text('One')));
      await tester.pump();
      expect(fill('One'), theme.linkHoverColor);
      await tester.pumpAndSettle();
    });
  });
}
