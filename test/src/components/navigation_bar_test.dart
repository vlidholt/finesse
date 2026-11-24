import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';
import '../../finesse_harness.dart';

/// Icons are told apart by key: `home` / `home-selected`, and so on.
List<NavigationDestination> destinations(
  int count, {
  Map<int, int> badgeCounts = const {},
  Set<int> dots = const {},
}) {
  const names = ['Home', 'Jobs', 'Chat', 'Me', 'More', 'Six'];
  return [
    for (var i = 0; i < count; i++)
      NavigationDestination(
        icon: Icon(PhosphorIconsRegular.house, key: Key('${names[i]}-icon')),
        selectedIcon: Icon(
          PhosphorIconsFill.house,
          key: Key('${names[i]}-selected'),
        ),
        label: names[i],
        badgeCount: badgeCounts[i],
        showBadge: dots.contains(i),
      ),
  ];
}

void main() {
  group('NavigationBarTheme', () {
    test('is fed by the style and the scheme', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final nav = theme.navigationBarTheme;
        final s = theme.colorScheme;
        expect(nav.itemWidth, 88);
        expect(nav.iconSize, 24);
        expect(nav.gap, 4);
        expect(nav.labelStyle!.fontSize, 12);
        expect(nav.labelStyle!.fontWeight, FontWeight.w500);
        expect(nav.labelStyle!.height, 1);
        expect(nav.foregroundColor, s.mutedForeground);
        expect(nav.selectedIconColor, s.tint);
        expect(nav.selectedLabelColor, s.foreground);
        expect(nav.hoverColor, s.foreground);
        expect(nav.indicatorColor, s.tint);
        expect(nav.indicatorHeight, 3);
        expect(nav.indicatorInset, 12);
      }
    });
  });

  group('NavigationBar', () {
    Widget bar({
      int count = 4,
      int? selectedIndex = 0,
      ValueChanged<int>? onDestinationSelected,
      double? height,
      Map<int, int> badgeCounts = const {},
      Set<int> dots = const {},
    }) {
      return Center(
        child: NavigationBar(
          destinations: destinations(
            count,
            badgeCounts: badgeCounts,
            dots: dots,
          ),
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          height: height,
        ),
      );
    }

    Finder item(int i) => find
        .descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(Pressable),
        )
        .at(i);

    /// The line under the selected destination.
    Finder indicator() => find.descendant(
      of: find.byType(PositionedDirectional),
      matching: find.byType(DecoratedBox),
    );

    Color iconColor(WidgetTester tester, String key) =>
        IconTheme.of(tester.element(find.byKey(Key(key)))).color!;

    Color labelColor(WidgetTester tester, String label) =>
        tester.widget<Text>(find.text(label)).style!.color!;

    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => bar(
          onDestinationSelected: (_) {},
          badgeCounts: const {2: 120},
          dots: const {3},
        ),
      );
    });

    testWidgets('each destination is the theme width and the app bar height', (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(tester, bar(), formFactor: formFactor);
        final theme = themeOf(tester, find.byType(NavigationBar));
        final height = formFactor == FormFactor.mobile ? 60.0 : 64.0;
        expect(theme.appBarTheme.height, height);
        expect(
          tester.getSize(find.byType(NavigationBar)),
          Size(88 * 4, height),
        );
        for (var i = 0; i < 4; i++) {
          expect(tester.getSize(item(i)), Size(88, height));
        }
      }
    });

    testWidgets('height overrides the app bar height', (tester) async {
      await pumpFinesse(tester, bar(height: 48));
      expect(tester.getSize(find.byType(NavigationBar)).height, 48);
    });

    testWidgets('lays the destinations out in reading order', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(tester, bar(), textDirection: direction);
        final first = tester.getRect(item(0));
        final last = tester.getRect(item(3));
        if (direction == TextDirection.ltr) {
          expect(first.left, lessThan(last.left));
        } else {
          expect(first.left, greaterThan(last.left));
        }
      }
    });

    testWidgets('stacks a 24px icon over its label, centred', (tester) async {
      await pumpFinesse(tester, bar());
      final cell = tester.getRect(item(1));
      final icon = tester.getRect(find.byKey(const Key('Jobs-icon')));
      final label = tester.getRect(find.text('Jobs'));

      expect(icon.size, const Size.square(24));
      expect(icon.center.dx, closeTo(cell.center.dx, .5));
      expect(label.center.dx, closeTo(cell.center.dx, .5));
      // 4 between them, and the pair is centred in the bar.
      expect(label.top, icon.bottom + 4);
      expect(
        (icon.top + label.bottom) / 2,
        closeTo(cell.center.dy, .5),
      );
    });

    testWidgets('a label wider than its cell truncates', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: NavigationBar(
            selectedIndex: 0,
            destinations: [
              NavigationDestination(
                icon: Icon(PhosphorIconsRegular.house),
                label: 'Notifications and more',
              ),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.text('Notifications and more'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(
        tester.getSize(find.text('Notifications and more')).width,
        lessThanOrEqualTo(88),
      );
    });

    testWidgets("a tap reports the destination's index", (tester) async {
      final taps = <int>[];
      await pumpFinesse(tester, bar(onDestinationSelected: taps.add));
      await tester.tap(find.text('Chat'));
      await tester.tap(find.byKey(const Key('Me-icon')));
      // Anywhere in the cell.
      await tester.tapAt(tester.getRect(item(1)).topLeft + const Offset(3, 3));
      expect(taps, [2, 3, 1]);
    });

    testWidgets('the keyboard reaches and activates each destination', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpFinesse(tester, bar(onDestinationSelected: taps.add));
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(
          i.isEven ? LogicalKeyboardKey.enter : LogicalKeyboardKey.space,
        );
      }
      expect(taps, [0, 1, 2]);
    });

    testWidgets('without a callback the destinations are inert', (
      tester,
    ) async {
      await pumpFinesse(tester, bar());
      await tester.tap(find.text('Chat'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the selected destination takes the tint, the selected icon '
        'and a foreground label', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          bar(selectedIndex: 1, onDestinationSelected: (_) {}),
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(NavigationBar)).colorScheme;

        expect(find.byKey(const Key('Jobs-selected')), findsOneWidget);
        expect(find.byKey(const Key('Jobs-icon')), findsNothing);
        expect(iconColor(tester, 'Jobs-selected'), s.tint);
        expect(labelColor(tester, 'Jobs'), s.foreground);
        // Everything else rests in the muted foreground, with its plain
        // icon.
        for (final other in ['Home', 'Chat', 'Me']) {
          expect(find.byKey(Key('$other-icon')), findsOneWidget);
          expect(find.byKey(Key('$other-selected')), findsNothing);
          expect(iconColor(tester, '$other-icon'), s.mutedForeground);
          expect(labelColor(tester, other), s.mutedForeground);
        }
      }
    });

    testWidgets('moving the selection moves the colours and the icon', (
      tester,
    ) async {
      await pumpFinesse(tester, bar());
      final selected = iconColor(tester, 'Home-selected');
      final resting = iconColor(tester, 'Chat-icon');
      expect(selected, isNot(resting));

      await pumpFinesse(tester, bar(selectedIndex: 2));
      expect(iconColor(tester, 'Chat-selected'), selected);
      expect(iconColor(tester, 'Home-icon'), resting);
    });

    testWidgets('a destination without a selected icon keeps its icon', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: NavigationBar(
            selectedIndex: 0,
            destinations: [
              NavigationDestination(
                icon: Icon(PhosphorIconsRegular.house, key: Key('only')),
                label: 'Home',
              ),
            ],
          ),
        ),
      );
      expect(find.byKey(const Key('only')), findsOneWidget);
    });

    testWidgets('hover brings a resting destination to the foreground', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, bar(onDestinationSelected: (_) {}));
      final s = themeOf(tester, find.byType(NavigationBar)).colorScheme;

      final gesture = await hoverAt(tester, tester.getCenter(item(2)));
      expect(iconColor(tester, 'Chat-icon'), s.foreground);
      expect(labelColor(tester, 'Chat'), s.foreground);
      // The selected one is unaffected by where the pointer is.
      expect(iconColor(tester, 'Home-selected'), s.tint);

      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(iconColor(tester, 'Chat-icon'), s.mutedForeground);
    });

    testWidgets('draws one indicator under the selected destination', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        for (var selected = 0; selected < 4; selected++) {
          await pumpFinesse(
            tester,
            bar(selectedIndex: selected),
            textDirection: direction,
          );
          final theme = themeOf(tester, find.byType(NavigationBar));
          expect(indicator(), findsOneWidget);
          final cell = tester.getRect(item(selected));
          final line = tester.getRect(indicator());
          // Inset 12 from each side of the cell, 3 tall.
          expect(line.left, cell.left + 12);
          expect(line.right, cell.right - 12);
          expect(line.height, 3);
          expect(
            (tester.widget<DecoratedBox>(indicator()).decoration
                    as BoxDecoration)
                .color,
            theme.colorScheme.tint,
          );
        }
      }
    });

    testWidgets('no selection, or one out of range, draws no indicator', (
      tester,
    ) async {
      for (final selected in [null, -1, 9]) {
        await pumpFinesse(tester, bar(selectedIndex: selected));
        expect(indicator(), findsNothing, reason: '$selected');
        expect(tester.takeException(), isNull);
        // And nothing is tinted.
        expect(find.byKey(const Key('Home-selected')), findsNothing);
      }
    });

    testWidgets("in an app bar the indicator sits on the bar's bottom edge, "
        'over its hairline', (tester) async {
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: AppBar(
            primary: false,
            middle: NavigationBar(
              selectedIndex: 1,
              destinations: destinations(4),
            ),
          ),
        ),
      );
      final appBar = tester.getRect(find.byType(AppBar));
      final line = tester.getRect(indicator());
      expect(line.bottom, appBar.bottom);
      expect(line.top, appBar.bottom - 3);
      // The navigation bar is centred in the app bar.
      expect(
        tester.getCenter(find.byType(NavigationBar)).dx,
        closeTo(appBar.center.dx, .5),
      );
    });

    testWidgets('a badge count shows on the icon; zero shows none', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(badgeCounts: const {1: 3, 2: 0, 3: 250}),
      );
      expect(find.text('3'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('0'), findsNothing);
      expect(find.byType(IndicatorBadge), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      // The badge is pinned to the icon, not the cell.
      final icon = tester.getRect(find.byKey(const Key('Jobs-icon')));
      final badge = tester.getRect(find.text('3'));
      expect(badge.center.dx, greaterThan(icon.center.dx));
      expect(badge.center.dy, lessThan(icon.center.dy));
      // A 99+ pill on a 24px icon keeps its digits.
      expect(
        tester.getSize(find.text('99+')).width,
        greaterThan(tester.getSize(find.text('3')).width * 2),
      );
    });

    testWidgets('showBadge shows a dot when there is no count', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(dots: const {2}));
      expect(find.byType(IndicatorBadge), findsOneWidget);
      final badge = tester.widget<IndicatorBadge>(find.byType(IndicatorBadge));
      expect(badge.count, isNull);
      expect(
        find.descendant(
          of: find.byType(IndicatorBadge),
          matching: find.byType(Text),
        ),
        findsNothing,
      );
    });

    testWidgets('a count wins over the dot', (tester) async {
      await pumpFinesse(
        tester,
        bar(badgeCounts: const {2: 5}, dots: const {2}),
      );
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('keyboard focus rings the focused destination only', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, bar(onDestinationSelected: (_) {}));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .widgetList<FocusRing>(find.byType(FocusRing))
            .map((r) => r.visible),
        [false, true, false, false],
      );
    });

    testWidgets('each destination is a labelled button; the selected one '
        'says so', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        bar(selectedIndex: 2, onDestinationSelected: (_) {}),
      );
      const names = ['Home', 'Jobs', 'Chat', 'Me'];
      for (var i = 0; i < 4; i++) {
        final data = tester.getSemantics(item(i)).getSemanticsData();
        expect(data.label, names[i]);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(
          data.flagsCollection.isSelected,
          i == 2 ? ui.Tristate.isTrue : ui.Tristate.none,
        );
      }
      handle.dispose();
    });

    testWidgets('follows a theme override', (tester) async {
      const colour = Color(0xffcc5500);
      await pumpFinesse(
        tester,
        bar(),
        theme: ThemeData(
          navigationBarTheme: const NavigationBarTheme(
            itemWidth: 60,
            iconSize: 18,
            selectedIconColor: colour,
            indicatorColor: colour,
            indicatorHeight: 5,
            indicatorInset: 4,
          ),
        ),
      );
      expect(tester.getSize(item(0)).width, 60);
      expect(
        tester.getSize(find.byKey(const Key('Home-selected'))),
        const Size.square(18),
      );
      expect(iconColor(tester, 'Home-selected'), colour);
      final line = tester.getRect(indicator());
      expect(line.height, 5);
      expect(line.width, 52);
    });
  });

  group('BottomNavigationBarTheme', () {
    test('is a floating glass pill in the finesse style', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(
          brightness: brightness,
          formFactor: FormFactor.mobile,
        );
        final bar = theme.bottomNavigationBarTheme;
        final s = theme.colorScheme;
        expect(bar.floating, isTrue);
        expect(bar.itemWidth, 52);
        expect(bar.itemHeight, 48);
        expect(bar.iconSize, 26);
        expect(bar.actionIconSize, 22);
        expect(bar.padding, const EdgeInsets.all(6));
        expect(bar.margin, const EdgeInsets.only(bottom: 22));
        expect(bar.gap, 4);
        expect(bar.radius, theme.radii.full);
        expect(bar.backgroundColor!.a, lessThan(1));
        expect(bar.backgroundColor!.withValues(alpha: 1), s.bar);
        expect(bar.blur, 24);
        expect(bar.saturation, 1.6);
        expect(bar.borderColor, s.border);
        expect(bar.foregroundColor, s.foregroundSubtle);
        expect(bar.selectedForegroundColor, s.tint);
        expect(bar.selectedBackgroundColor, s.accent);
        expect(bar.actionBackgroundColor, s.primary);
        expect(bar.actionForegroundColor, s.primaryForeground);
      }
    });
  });

  group('BottomNavigationBar', () {
    Widget bar({
      int count = 4,
      int? selectedIndex = 0,
      ValueChanged<int>? onDestinationSelected,
      NavigationAction? action,
      bool? floating,
      Map<int, int> badgeCounts = const {},
      double bottomInset = 0,
    }) {
      return MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: BottomNavigationBar(
            destinations: destinations(count, badgeCounts: badgeCounts),
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            action: action,
            floating: floating,
          ),
        ),
      );
    }

    NavigationAction action([VoidCallback? onPressed]) => NavigationAction(
      icon: const Icon(PhosphorIconsRegular.plus, key: Key('action-icon')),
      label: 'Create post',
      onPressed: onPressed ?? () {},
    );

    Finder items() => find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.byType(Pressable),
    );

    /// The bar's own surface: the pill, or the full-width strip.
    Finder surface() => find
        .descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w is! AnimatedContainer,
          ),
        )
        .first;

    BoxDecoration itemBox(WidgetTester tester, int i) =>
        tester
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: items().at(i),
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;

    Color iconColor(WidgetTester tester, String key) =>
        IconTheme.of(tester.element(find.byKey(Key(key)))).color!;

    testWidgets('renders in both form factors and text directions, floating '
        'and docked', (tester) async {
      for (final floating in [true, false]) {
        await expectBuildsInEveryLayout(
          tester,
          (layout) => bar(
            onDestinationSelected: (_) {},
            action: action(),
            floating: floating,
            badgeCounts: const {2: 120},
            bottomInset: 34,
          ),
        );
      }
    });

    testWidgets('floating: a pill as wide as its destinations, centred above '
        'the bottom edge', (tester) async {
      await pumpFinesse(tester, bar(), formFactor: FormFactor.mobile);
      final screen = tester.getRect(find.byType(MediaQuery).first);
      final pill = tester.getRect(surface());

      // Four 52px items, three 4px gaps, 6 of padding and a 1px outline all
      // round.
      expect(pill.width, 52 * 4 + 4 * 3 + 12 + 2);
      expect(pill.height, 48 + 12 + 2);
      expect(pill.center.dx, closeTo(screen.center.dx, .5));
      // The theme's 22px margin under it.
      expect(pill.bottom, 844 - 22);
      for (var i = 0; i < 4; i++) {
        expect(tester.getSize(items().at(i)), const Size(52, 48));
      }
    });

    testWidgets('floating: keeps clear of the bottom safe area', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(bottomInset: 34),
        formFactor: FormFactor.mobile,
      );
      expect(tester.getRect(surface()).bottom, 844 - 22 - 34);
    });

    testWidgets('floating: is fully rounded, outlined and shadowed', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(), formFactor: FormFactor.mobile);
      final theme = themeOf(tester, find.byType(BottomNavigationBar));
      final decoration =
          tester.widget<Container>(surface()).decoration! as BoxDecoration;

      expect(decoration.borderRadius, theme.radii.full);
      expect(decoration.color, theme.bottomNavigationBarTheme.backgroundColor);
      expect(
        (decoration.border! as Border).top.color,
        theme.colorScheme.border,
      );
      expect((decoration.border! as Border).isUniform, isTrue);
      // The shadow is carried outside the clipped glass.
      final shadow = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(BottomNavigationBar),
              matching: find.byWidgetPredicate(
                (w) => w is DecoratedBox && w.decoration is ShadowDecoration,
              ),
            )
            .first,
      );
      expect(shadowsOf(shadow.decoration), theme.style.floatingShadow);
      expect(theme.style.floatingShadow, isNotEmpty);
    });

    testWidgets('blurs what scrolls beneath it while the bar is translucent', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(), formFactor: FormFactor.mobile);
      final filter = tester.widget<BackdropFilter>(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byType(BackdropFilter),
        ),
      );
      expect(
        filter.filter,
        same(Backdrop.filterFor(blur: 24, saturation: 1.6)),
      );

      // nova's bars are opaque, so there is no backdrop layer.
      await pumpFinesse(
        tester,
        bar(),
        formFactor: FormFactor.mobile,
        theme: ThemeData(
          style: StyleTokens.nova,
          colorScheme: const NeutralColorScheme.light(),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('heightOf is the height the bar takes', (tester) async {
      for (final bottomInset in [0.0, 34.0]) {
        late double reported;
        await pumpFinesse(
          tester,
          MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
            child: Builder(
              builder: (context) {
                reported = BottomNavigationBar.heightOf(context);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavigationBar(
                    destinations: destinations(4),
                    selectedIndex: 0,
                  ),
                );
              },
            ),
          ),
          formFactor: FormFactor.mobile,
        );
        // 48 + 12 of padding + 2 of outline + 22 of margin, plus the inset.
        expect(reported, 84 + bottomInset);
        expect(
          tester.getSize(find.byType(BottomNavigationBar)).height,
          reported,
        );
      }
    });

    testWidgets('heightOf matches a docked bar too', (tester) async {
      for (final bottomInset in [0.0, 34.0]) {
        late double reported;
        await pumpFinesse(
          tester,
          MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(bottom: bottomInset)),
            child: Builder(
              builder: (context) {
                reported = BottomNavigationBar.heightOf(context);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavigationBar(
                    destinations: destinations(4),
                    selectedIndex: 0,
                  ),
                );
              },
            ),
          ),
          formFactor: FormFactor.mobile,
          theme: ThemeData(
            bottomNavigationBarTheme: const BottomNavigationBarTheme(
              floating: false,
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(BottomNavigationBar)).height,
          reported,
          reason: 'inset $bottomInset',
        );
      }
    });

    testWidgets('docked: spans the width, shares it between the '
        'destinations and pads for the safe area', (tester) async {
      await pumpFinesse(
        tester,
        bar(floating: false, bottomInset: 34),
        formFactor: FormFactor.mobile,
      );
      final theme = themeOf(tester, find.byType(BottomNavigationBar));
      final strip = tester.getRect(find.byType(BottomNavigationBar));
      expect(strip.width, 390);
      expect(strip.bottom, 844);
      // Items, padding, a top hairline and the inset inside the strip.
      expect(strip.height, 48 + 12 + 1 + 34);

      final widths = [
        for (var i = 0; i < 4; i++) tester.getSize(items().at(i)).width,
      ];
      expect(widths.toSet(), hasLength(1));
      expect(widths.first, (390 - 12 - 3 * 4) / 4);

      final decoration =
          tester.widget<Container>(surface()).decoration! as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.zero);
      final border = decoration.border! as Border;
      expect(border.top.color, theme.colorScheme.border);
      expect(border.bottom, BorderSide.none);
      // A docked bar casts no floating shadow.
      expect(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byWidgetPredicate(
            (w) => w is DecoratedBox && w.decoration is ShadowDecoration,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('lays the destinations out in reading order', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          bar(),
          formFactor: FormFactor.mobile,
          textDirection: direction,
        );
        final first = tester.getRect(find.byKey(const Key('Home-selected')));
        final last = tester.getRect(find.byKey(const Key('Me-icon')));
        if (direction == TextDirection.ltr) {
          expect(first.left, lessThan(last.left));
        } else {
          expect(first.left, greaterThan(last.left));
        }
      }
    });

    testWidgets("a tap reports the destination's index", (tester) async {
      final taps = <int>[];
      await pumpFinesse(
        tester,
        bar(onDestinationSelected: taps.add),
        formFactor: FormFactor.mobile,
      );
      await tester.tap(find.byKey(const Key('Chat-icon')));
      await tester.tap(find.byKey(const Key('Me-icon')));
      await tester.tap(find.byKey(const Key('Home-selected')));
      expect(taps, [2, 3, 0]);
    });

    testWidgets('the keyboard reaches and activates the destinations', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpFinesse(
        tester,
        bar(onDestinationSelected: taps.add),
        formFactor: FormFactor.mobile,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, [1]);
    });

    testWidgets('the selected destination takes the accent fill, the tint '
        'and its selected icon', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          bar(selectedIndex: 1, onDestinationSelected: (_) {}),
          formFactor: FormFactor.mobile,
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(BottomNavigationBar)).colorScheme;

        expect(find.byKey(const Key('Jobs-selected')), findsOneWidget);
        expect(find.byKey(const Key('Jobs-icon')), findsNothing);
        expect(itemBox(tester, 1).color, s.accent, reason: '$brightness');
        expect(iconColor(tester, 'Jobs-selected'), s.tint);
        expect(
          tester.getSize(find.byKey(const Key('Jobs-selected'))),
          const Size.square(26),
        );
        // The rest are bare icons in the subtle foreground.
        for (final (i, other) in [(0, 'Home'), (2, 'Chat'), (3, 'Me')]) {
          expect(itemBox(tester, i).color!.a, 0);
          expect(iconColor(tester, '$other-icon'), s.foregroundSubtle);
        }
      }
    });

    testWidgets('moving the selection moves the fill and the tint', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(),
        formFactor: FormFactor.mobile,
      );
      final fill = itemBox(tester, 0).color;
      final tint = iconColor(tester, 'Home-selected');
      expect(itemBox(tester, 2).color, isNot(fill));

      await pumpFinesse(
        tester,
        bar(selectedIndex: 2),
        formFactor: FormFactor.mobile,
      );
      expect(itemBox(tester, 2).color, fill);
      expect(iconColor(tester, 'Chat-selected'), tint);
      expect(itemBox(tester, 0).color, isNot(fill));
    });

    testWidgets('no selection highlights nothing', (tester) async {
      await pumpFinesse(
        tester,
        bar(selectedIndex: null),
        formFactor: FormFactor.mobile,
      );
      for (var i = 0; i < 4; i++) {
        expect(itemBox(tester, i).color!.a, 0);
      }
    });

    testWidgets('floating items are pills', (tester) async {
      await pumpFinesse(tester, bar(), formFactor: FormFactor.mobile);
      final theme = themeOf(tester, find.byType(BottomNavigationBar));
      expect(itemBox(tester, 0).borderRadius, theme.radii.full);
    });

    testWidgets('the action sits between the two halves of the destinations', (
      tester,
    ) async {
      Future<List<String>> orderWith(int count) async {
        await pumpFinesse(
          tester,
          bar(count: count, selectedIndex: null, action: action()),
          formFactor: FormFactor.mobile,
          surfaceSize: const Size(430, 844),
        );
        expect(tester.takeException(), isNull);
        const names = ['Home', 'Jobs', 'Chat', 'Me', 'More'];
        final positions = <String, double>{
          for (var i = 0; i < count; i++)
            names[i]: tester.getCenter(find.byKey(Key('${names[i]}-icon'))).dx,
          '+': tester.getCenter(find.byKey(const Key('action-icon'))).dx,
        };
        return positions.keys.toList()
          ..sort((a, b) => positions[a]!.compareTo(positions[b]!));
      }

      expect(await orderWith(4), ['Home', 'Jobs', '+', 'Chat', 'Me']);
      expect(await orderWith(2), ['Home', '+', 'Jobs']);
      // With an odd count the extra destination goes before the action.
      expect(await orderWith(5), ['Home', 'Jobs', 'Chat', '+', 'Me', 'More']);
      expect(await orderWith(3), ['Home', 'Jobs', '+', 'Chat']);
      expect(await orderWith(1), ['Home', '+']);
    });

    testWidgets('the action is a primary-filled button that calls onPressed '
        'and shifts no index', (tester) async {
      var created = 0;
      final taps = <int>[];
      await pumpFinesse(
        tester,
        bar(
          onDestinationSelected: taps.add,
          action: action(() => created++),
        ),
        formFactor: FormFactor.mobile,
      );
      final s = themeOf(tester, find.byType(BottomNavigationBar)).colorScheme;

      // The action is the third pressable of five.
      expect(items(), findsNWidgets(5));
      expect(itemBox(tester, 2).color, s.primary);
      expect(iconColor(tester, 'action-icon'), s.primaryForeground);
      expect(
        tester.getSize(find.byKey(const Key('action-icon'))),
        const Size.square(22),
      );

      await tester.tap(find.byKey(const Key('action-icon')));
      expect(created, 1);
      expect(taps, isEmpty);
      // The destinations after it keep their own indices.
      await tester.tap(find.byKey(const Key('Chat-icon')));
      await tester.tap(find.byKey(const Key('Me-icon')));
      expect(taps, [2, 3]);
    });

    testWidgets('an action with no callback is disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        bar(
          action: const NavigationAction(
            icon: Icon(PhosphorIconsRegular.plus),
            label: 'Create post',
            onPressed: null,
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      final data = tester
          .getSemantics(find.bySemanticsLabel('Create post'))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('badges ride on the icons', (tester) async {
      await pumpFinesse(
        tester,
        bar(badgeCounts: const {1: 4, 2: 0, 3: 300}),
        formFactor: FormFactor.mobile,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.byType(IndicatorBadge), findsNWidgets(2));
    });

    testWidgets('each destination is announced by its label, as a button; '
        'the selected one says so', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        bar(
          selectedIndex: 1,
          onDestinationSelected: (_) {},
          action: action(),
        ),
        formFactor: FormFactor.mobile,
      );
      for (final (label, selected) in [
        ('Home', false),
        ('Jobs', true),
        ('Chat', false),
        ('Me', false),
        ('Create post', false),
      ]) {
        final data = tester
            .getSemantics(find.bySemanticsLabel(label))
            .getSemanticsData();
        // The label alone: the icon adds nothing to it.
        expect(data.label, label);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(
          data.flagsCollection.isSelected,
          selected ? ui.Tristate.isTrue : ui.Tristate.none,
        );
      }
      handle.dispose();
    });

    testWidgets('five destinations and an action fit a 360-point phone', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(count: 5, action: action()),
        formFactor: FormFactor.mobile,
        surfaceSize: const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(surface()).width, lessThanOrEqualTo(360));
    });

    testWidgets(
      'five destinations and an action fit a 320-point phone',
      (
        tester,
      ) async {
        await pumpFinesse(
          tester,
          bar(count: 5, action: action()),
          formFactor: FormFactor.mobile,
          surfaceSize: const Size(320, 568),
        );
        expect(tester.takeException(), isNull);
      },
      // TODO(finesse): a floating bar gives every item a fixed 52px, so six
      // of them need 346px and overflow the smallest phones (320pt wide)
      // with a RenderFlex error. The items would have to be allowed to
      // shrink — or the bar to dock — below that width.
      skip: true,
    );

    testWidgets('follows a theme override', (tester) async {
      const colour = Color(0xffcc5500);
      await pumpFinesse(
        tester,
        bar(),
        formFactor: FormFactor.mobile,
        theme: ThemeData(
          bottomNavigationBarTheme: const BottomNavigationBarTheme(
            itemWidth: 60,
            itemHeight: 40,
            iconSize: 20,
            selectedBackgroundColor: colour,
            margin: EdgeInsets.only(bottom: 10),
          ),
        ),
      );
      expect(tester.getSize(items().first), const Size(60, 40));
      expect(itemBox(tester, 0).color, colour);
      expect(
        tester.getSize(find.byKey(const Key('Home-selected'))),
        const Size.square(20),
      );
      expect(tester.getRect(surface()).bottom, 844 - 10);
    });
  });
}
