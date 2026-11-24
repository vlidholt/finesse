import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';
import '../../finesse_harness.dart';

void main() {
  BoxDecoration tileBox(WidgetTester tester) =>
      tester
              .widget<Container>(
                find.descendant(
                  of: find.byType(IconTile),
                  matching: find.byType(Container),
                ),
              )
              .decoration!
          as BoxDecoration;

  group('IconTileTheme', () {
    test('is a 40px accent square with a 22px tinted icon', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final tile = theme.iconTileTheme;
        expect(tile.size, 40);
        expect(tile.iconSize, 22);
        expect(tile.radius, theme.radii.lg);
        expect(tile.backgroundColor, theme.colorScheme.accent);
        expect(tile.foregroundColor, theme.colorScheme.tint);
      }
    });

    test('scales with the spacing unit', () {
      final theme = ThemeData(spacing: const Spacing(step: 5));
      expect(theme.iconTileTheme.size, 50);
      expect(theme.iconTileTheme.iconSize, 27.5);
    });
  });

  group('IconTile', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => const Center(
          child: IconTile(icon: Icon(PhosphorIconsRegular.bookmarkSimple)),
        ),
        check: (layout) async {
          expect(tester.getSize(find.byType(IconTile)), const Size.square(40));
        },
      );
    });

    testWidgets('sizes the tile and the icon from the theme', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IconTile(icon: Icon(PhosphorIconsRegular.bookmarkSimple)),
        ),
      );
      final theme = themeOf(tester, find.byType(IconTile));
      expect(tester.getSize(find.byType(IconTile)), const Size.square(40));
      expect(tester.getSize(find.byType(Icon)), const Size.square(22));
      expect(tileBox(tester).borderRadius, theme.radii.lg);
      // The icon is centred.
      expect(
        tester.getCenter(find.byType(Icon)),
        tester.getCenter(find.byType(IconTile)),
      );
    });

    testWidgets('takes the accent fill and the tint', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          const Center(
            child: IconTile(icon: Icon(PhosphorIconsRegular.bookmarkSimple)),
          ),
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(IconTile)).colorScheme;
        expect(tileBox(tester).color, s.accent, reason: '$brightness');
        expect(IconTheme.of(tester.element(find.byType(Icon))).color, s.tint);
      }
    });

    testWidgets('size, iconSize, colours and radius override the theme', (
      tester,
    ) async {
      const fill = Color(0xff102030);
      const ink = Color(0xffa0b0c0);
      const radius = BorderRadius.all(Radius.circular(3));
      await pumpFinesse(
        tester,
        const Center(
          child: IconTile(
            icon: Icon(PhosphorIconsRegular.bookmarkSimple),
            size: 56,
            iconSize: 30,
            backgroundColor: fill,
            foregroundColor: ink,
            borderRadius: radius,
          ),
        ),
      );
      expect(tester.getSize(find.byType(IconTile)), const Size.square(56));
      expect(tester.getSize(find.byType(Icon)), const Size.square(30));
      expect(tileBox(tester).color, fill);
      expect(tileBox(tester).borderRadius, radius);
      expect(IconTheme.of(tester.element(find.byType(Icon))).color, ink);
    });

    testWidgets('an icon with its own size and colour keeps them', (
      tester,
    ) async {
      const own = Color(0xffcc0000);
      await pumpFinesse(
        tester,
        const Center(
          child: IconTile(
            icon: Icon(
              PhosphorIconsRegular.bookmarkSimple,
              size: 12,
              color: own,
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(Icon)), const Size.square(12));
      expect(tester.widget<Icon>(find.byType(Icon)).color, own);
      expect(tester.getSize(find.byType(IconTile)), const Size.square(40));
    });

    testWidgets('follows a theme override', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IconTile(icon: Icon(PhosphorIconsRegular.bookmarkSimple)),
        ),
        theme: ThemeData(
          iconTileTheme: const IconTileTheme(size: 32, iconSize: 16),
        ),
      );
      expect(tester.getSize(find.byType(IconTile)), const Size.square(32));
      expect(tester.getSize(find.byType(Icon)), const Size.square(16));
    });

    testWidgets('stays square inside a stretching row', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                IconTile(icon: Icon(PhosphorIconsRegular.bookmarkSimple)),
                Expanded(child: Text('Saved')),
              ],
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(IconTile)), const Size.square(40));
    });
  });

  group('StatTile', () {
    Widget strip({VoidCallback? onTap, Widget? trailing, bool icon = true}) {
      return Center(
        child: SizedBox(
          width: 300,
          child: StatTile(
            icon: icon ? const Icon(PhosphorIconsRegular.bookmarkSimple) : null,
            value: const Text('6'),
            label: const Text('Saved'),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: StatTile(
                    icon: const Icon(PhosphorIconsRegular.bookmarkSimple),
                    value: const Text('6'),
                    label: const Text('Saved'),
                    onTap: () {},
                  ),
                ),
                const Expanded(
                  child: StatTile(value: Text('12'), label: Text('Views')),
                ),
              ],
            ),
          ),
        ),
      );
    });

    testWidgets('is a card with an icon tile, a number and a label', (
      tester,
    ) async {
      await pumpFinesse(tester, strip());
      final theme = themeOf(tester, find.byType(StatTile));

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(IconTile), findsOneWidget);
      expect(tester.getSize(find.byType(StatTile)).width, 300);
      expect(tester.widget<Card>(find.byType(Card)).radius, theme.radii.xl);
      // The number is a headline, the label a muted line under it.
      final value = DefaultTextStyle.of(tester.element(find.text('6'))).style;
      final label = DefaultTextStyle.of(
        tester.element(find.text('Saved')),
      ).style;
      expect(value.fontSize, theme.textTheme.h3.fontSize);
      expect(value.color, theme.colorScheme.foreground);
      expect(label.color, theme.colorScheme.mutedForeground);
      expect(label.fontSize, theme.textTheme.muted.fontSize);
      expect(
        tester.getRect(find.text('Saved')).top,
        tester.getRect(find.text('6')).bottom,
      );
    });

    testWidgets('pads and spaces by the layout gap scale', (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(tester, strip(), formFactor: formFactor);
        final layout = themeOf(tester, find.byType(StatTile)).layoutTheme;
        final card = tester.getRect(find.byType(StatTile));
        final tile = tester.getRect(find.byType(IconTile));
        final value = tester.getRect(find.text('6'));

        // `gapLg` at the sides (16 on a desktop, 12 on a phone), inside the
        // card's hairline; `gapMd` between the icon tile and the text.
        expect(tile.left, card.left + layout.gap(GapSize.lg) + 1);
        expect(value.left, tile.right + layout.gap(GapSize.md));
        expect(
          layout.gap(GapSize.lg),
          formFactor == FormFactor.mobile ? 12 : 16,
        );
      }
    });

    testWidgets('lays out in reading order', (tester) async {
      await pumpFinesse(
        tester,
        strip(
          trailing: const SizedBox(key: Key('trend'), width: 20, height: 20),
        ),
        textDirection: TextDirection.rtl,
      );
      final card = tester.getRect(find.byType(StatTile));
      final tile = tester.getRect(find.byType(IconTile));
      final trend = tester.getRect(find.byKey(const Key('trend')));
      expect(tile.right, lessThan(card.right));
      expect(tile.left, greaterThan(trend.right));
      expect(tester.getRect(find.text('6')).right, lessThan(tile.left));
    });

    testWidgets('without an icon the text starts at the padding', (
      tester,
    ) async {
      await pumpFinesse(tester, strip(icon: false));
      expect(find.byType(IconTile), findsNothing);
      final card = tester.getRect(find.byType(StatTile));
      expect(tester.getRect(find.text('6')).left, card.left + 16 + 1);
    });

    testWidgets('a trailing widget sits at the end, centred', (tester) async {
      await pumpFinesse(
        tester,
        strip(
          trailing: const SizedBox(key: Key('trend'), width: 20, height: 20),
        ),
      );
      final card = tester.getRect(find.byType(StatTile));
      final trend = tester.getRect(find.byKey(const Key('trend')));
      expect(trend.right, card.right - 16 - 1);
      expect(trend.center.dy, closeTo(card.center.dy, .5));
    });

    testWidgets('long values and labels truncate', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 160,
            child: StatTile(
              icon: Icon(PhosphorIconsRegular.bookmarkSimple),
              value: Text('1,234,567,890'),
              label: Text('A label that is much too long'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      for (final text in ['1,234,567,890', 'A label that is much too long']) {
        final paragraph = tester.widget<RichText>(
          find.descendant(
            of: find.text(text),
            matching: find.byType(RichText),
          ),
        );
        expect(paragraph.maxLines, 1);
        expect(paragraph.overflow, TextOverflow.ellipsis);
      }
    });

    testWidgets('padding can be set', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 300,
            child: StatTile(
              padding: EdgeInsets.all(4),
              value: Text('6'),
              label: Text('Saved'),
            ),
          ),
        ),
      );
      final card = tester.getRect(find.byType(StatTile));
      expect(tester.getRect(find.text('6')).left, card.left + 4 + 1);
    });

    testWidgets('onTap makes it a button; a tap and the keyboard call it', (
      tester,
    ) async {
      var taps = 0;
      await pumpFinesse(tester, strip(onTap: () => taps++));

      await tester.tap(find.text('Saved'));
      expect(taps, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 3);
    });

    testWidgets('an interactive tile is laid out like a static one', (
      tester,
    ) async {
      await pumpFinesse(tester, strip());
      final inert = tester.getRect(find.byType(StatTile));
      await pumpFinesse(tester, strip(onTap: () {}));
      expect(tester.getRect(find.byType(StatTile)), inert);
    });

    testWidgets('keyboard focus rings the card at its own radius', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, strip(onTap: () {}));
      final theme = themeOf(tester, find.byType(StatTile));
      expect(tester.widget<FocusRing>(find.byType(FocusRing)).visible, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = tester.widget<FocusRing>(find.byType(FocusRing));
      expect(ring.visible, isTrue);
      expect(ring.borderRadius, theme.radii.xl);
    });

    testWidgets('semantics: a button when tappable, plain text when not', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, strip(onTap: () {}));
      final button = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(button.flagsCollection.isButton, isTrue);
      expect(button.label, '6\nSaved');
      expect(button.hasAction(ui.SemanticsAction.tap), isTrue);

      await pumpFinesse(tester, strip());
      expect(find.byType(Pressable), findsNothing);
      final text = tester.getSemantics(find.text('6')).getSemanticsData();
      expect(text.flagsCollection.isButton, isFalse);
      handle.dispose();
    });

    testWidgets("the card keeps the theme's fill and shadow", (tester) async {
      await pumpFinesse(tester, strip());
      final theme = themeOf(tester, find.byType(StatTile));
      final surface = tester.widget<Container>(
        find
            .descendant(of: find.byType(Card), matching: find.byType(Container))
            .first,
      );
      expect(
        boxDecorationOf(surface.decoration)!.color,
        theme.cardTheme.backgroundColor,
      );
    });
  });
}
