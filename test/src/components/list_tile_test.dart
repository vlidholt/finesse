import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';
import '../../fixture_styles.dart';

void main() {
  TextStyle styleOf(WidgetTester tester, String text) =>
      DefaultTextStyle.of(tester.element(find.text(text))).style;

  /// The highlight behind an interactive row.
  BoxDecoration highlightOf(WidgetTester tester) {
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(ListTile),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return container.decoration! as BoxDecoration;
  }

  Widget tile({
    VoidCallback? onTap,
    bool selected = false,
    Widget? leading = const SizedBox(key: Key('lead'), width: 40, height: 40),
    Widget? subtitle = const Text('Sub'),
    Widget? trailing = const SizedBox(key: Key('trail'), width: 24, height: 24),
    FocusNode? focusNode,
  }) {
    return Center(
      child: SizedBox(
        width: 320,
        child: ListTile(
          leading: leading,
          title: const Text('Title'),
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
          selected: selected,
          focusNode: focusNode,
        ),
      ),
    );
  }

  group('ListTileTheme', () {
    test('is fed by the style and the scheme', () {
      final theme = ThemeData();
      final tile = theme.listTileTheme;
      expect(
        tile.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
      expect(tile.gap, 12);
      expect(tile.titleGap, 0);
      expect(tile.radius, theme.radii.lg);
      // finesse's subtitle and small roles.
      expect(tile.titleStyle!.fontSize, 15);
      expect(tile.titleStyle!.fontWeight, FontWeight.w600);
      expect(tile.subtitleStyle!.fontSize, 13);
      expect(tile.hoverColor, theme.colorScheme.muted);
      expect(tile.selectedColor, theme.colorScheme.accent);
    });

    test('a style without those roles falls back to label and body', () {
      // vega names neither `subtitle` nor `small`.
      expect(FixtureStyles.vega.subtitle, isNull);
      expect(FixtureStyles.vega.small, isNull);
      final tile = ThemeData(style: FixtureStyles.vega).listTileTheme;
      expect(tile.titleStyle!.fontSize, 14);
      expect(tile.titleStyle!.fontWeight, FontWeight.w500);
      expect(tile.subtitleStyle!.fontSize, 14);
    });

    test("the shadcn styles' own subtitle and small roles reach it too", () {
      final nova = ThemeData(style: StyleTokens.nova).listTileTheme;
      expect(nova.titleStyle!.fontSize, 14);
      expect(nova.titleStyle!.fontWeight, FontWeight.w600);
      expect(nova.subtitleStyle!.fontSize, 13);
      final lyra = ThemeData(style: StyleTokens.lyra).listTileTheme;
      expect(lyra.titleStyle!.fontSize, 13);
      expect(lyra.titleStyle!.fontWeight, FontWeight.w600);
      expect(lyra.subtitleStyle!.fontSize, 12);
    });
  });

  group('ListTile layout', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => Column(
          children: [
            ListTile(
              leading: const SizedBox(width: 40, height: 40),
              title: const Text('Omar Rahimi'),
              subtitle: const Text('Design lead'),
              trailing: Button.outline(
                onPressed: () {},
                child: const Text('Follow'),
              ),
              onTap: () {},
            ),
            const ListTile(title: Text('Only a title')),
            ListTile(
              title: const Text('Selected'),
              selected: true,
              onTap: () {},
            ),
          ],
        ),
      );
    });

    testWidgets('pads by the theme and separates its parts by the gap', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(tester, tile(), textDirection: direction);
        final row = tester.getRect(find.byType(ListTile));
        final lead = tester.getRect(find.byKey(const Key('lead')));
        final title = tester.getRect(find.text('Title'));
        final trail = tester.getRect(find.byKey(const Key('trail')));

        expect(row.width, 320);
        // 10 of vertical padding around the 40px leading widget.
        expect(row.height, 60);
        if (direction == TextDirection.ltr) {
          expect(lead.left, row.left + 12);
          expect(title.left, lead.right + 12);
          expect(trail.right, row.right - 12);
        } else {
          expect(lead.right, row.right - 12);
          expect(title.right, lead.left - 12);
          expect(trail.left, row.left + 12);
        }
        // Leading and trailing are centred against the text by default.
        expect(lead.center.dy, row.center.dy);
        expect(trail.center.dy, row.center.dy);
      }
    });

    testWidgets('the subtitle sits directly under the title', (tester) async {
      await pumpFinesse(tester, tile());
      final title = tester.getRect(find.text('Title'));
      final subtitle = tester.getRect(find.text('Sub'));
      expect(subtitle.top, title.bottom);
      expect(subtitle.left, title.left);
    });

    testWidgets('the text takes the width the other parts leave', (
      tester,
    ) async {
      await pumpFinesse(tester, tile());
      final row = tester.getRect(find.byType(ListTile));
      final lead = tester.getRect(find.byKey(const Key('lead')));
      final trail = tester.getRect(find.byKey(const Key('trail')));
      final column = tester.getRect(
        find
            .ancestor(of: find.text('Title'), matching: find.byType(Column))
            .first,
      );
      expect(column.left, lead.right + 12);
      expect(column.right, trail.left - 12);
      expect(row.width, 320);
    });

    testWidgets('long text truncates to one line each by default', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 240,
            child: ListTile(
              leading: SizedBox(width: 40, height: 40),
              title: Text('A very long title that will not fit on one line'),
              subtitle: Text('An even longer subtitle that goes on and on'),
              trailing: SizedBox(width: 24, height: 24),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
        expect(text.maxLines, 1);
        expect(text.overflow, TextOverflow.ellipsis);
      }
      expect(tester.getSize(find.byType(ListTile)).height, 60);
    });

    testWidgets('titleMaxLines and subtitleMaxLines let the text wrap', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 240,
            child: ListTile(
              title: Text('A very long title that will not fit on one line'),
              subtitle: Text('An even longer subtitle that goes on and on'),
              titleMaxLines: 2,
              subtitleMaxLines: null,
            ),
          ),
        ),
      );
      final title = tester.widget<RichText>(
        find.descendant(
          of: find.textContaining('A very long title'),
          matching: find.byType(RichText),
        ),
      );
      final subtitle = tester.widget<RichText>(
        find.descendant(
          of: find.textContaining('An even longer'),
          matching: find.byType(RichText),
        ),
      );
      expect(title.maxLines, 2);
      expect(subtitle.maxLines, isNull);
      expect(
        tester.getSize(find.textContaining('An even longer')).height,
        greaterThan(40),
      );
    });

    testWidgets('crossAxisAlignment moves leading and trailing', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              crossAxisAlignment: CrossAxisAlignment.start,
              leading: SizedBox(key: Key('lead'), width: 20, height: 20),
              title: Text('Title'),
              subtitle: Text('Sub'),
              subtitleMaxLines: null,
            ),
          ),
        ),
      );
      final row = tester.getRect(find.byType(ListTile));
      expect(tester.getRect(find.byKey(const Key('lead'))).top, row.top + 10);
    });

    testWidgets('padding and gap can be set per tile', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              padding: EdgeInsets.all(4),
              gap: 20,
              leading: SizedBox(key: Key('lead'), width: 40, height: 40),
              title: Text('Title'),
            ),
          ),
        ),
      );
      final row = tester.getRect(find.byType(ListTile));
      final lead = tester.getRect(find.byKey(const Key('lead')));
      expect(lead.left, row.left + 4);
      expect(row.height, 48);
      expect(tester.getRect(find.text('Title')).left, lead.right + 20);
    });

    testWidgets('an interactive tile is laid out exactly like an inert one', (
      tester,
    ) async {
      await pumpFinesse(tester, tile());
      final inert = tester.getRect(find.byType(ListTile));
      final inertTitle = tester.getRect(find.text('Title'));

      await pumpFinesse(tester, tile(onTap: () {}));
      expect(tester.getRect(find.byType(ListTile)), inert);
      expect(tester.getRect(find.text('Title')), inertTitle);
    });
  });

  group('ListTile text', () {
    testWidgets('the title takes the foreground, the subtitle the muted '
        'foreground', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          tile(),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byType(ListTile));
        final title = styleOf(tester, 'Title');
        final subtitle = styleOf(tester, 'Sub');

        expect(title.color, theme.colorScheme.foreground);
        expect(title.fontSize, 15);
        expect(title.fontWeight, FontWeight.w600);
        expect(subtitle.color, theme.colorScheme.mutedForeground);
        expect(subtitle.fontSize, 13);
      }
    });

    testWidgets("titleStyle and subtitleStyle replace the theme's", (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              title: Text('Title'),
              subtitle: Text('Sub'),
              titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
              subtitleStyle: TextStyle(fontSize: 9),
            ),
          ),
        ),
      );
      expect(styleOf(tester, 'Title').fontSize, 22);
      expect(styleOf(tester, 'Title').fontWeight, FontWeight.w300);
      expect(styleOf(tester, 'Sub').fontSize, 9);
    });

    testWidgets('a colour given in titleStyle or subtitleStyle is kept', (
      tester,
    ) async {
      const titleColor = Color(0xffaa0000);
      const subtitleColor = Color(0xff00aa00);
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              title: Text('Title'),
              subtitle: Text('Sub'),
              titleStyle: TextStyle(color: titleColor),
              subtitleStyle: TextStyle(color: subtitleColor),
            ),
          ),
        ),
      );
      // The scheme's foreground is only a default.
      expect(styleOf(tester, 'Title').color, titleColor);
      expect(styleOf(tester, 'Sub').color, subtitleColor);
    });

    testWidgets("a colour in the theme's title style is kept too", (
      tester,
    ) async {
      const titleColor = Color(0xff0000aa);
      await pumpFinesse(
        tester,
        tile(),
        theme: ThemeData(
          listTileTheme: const ListTileTheme(
            titleStyle: TextStyle(fontSize: 17, color: titleColor),
          ),
        ),
      );
      expect(styleOf(tester, 'Title').color, titleColor);
      expect(styleOf(tester, 'Title').fontSize, 17);
    });
  });

  group('ListTile interaction', () {
    testWidgets('a tap calls onTap', (tester) async {
      var taps = 0;
      await pumpFinesse(tester, tile(onTap: () => taps++));
      await tester.tap(find.text('Title'));
      expect(taps, 1);
      // Anywhere in the row, padding included.
      final row = tester.getRect(find.byType(ListTile));
      await tester.tapAt(row.topLeft + const Offset(2, 2));
      expect(taps, 2);
    });

    testWidgets('Enter and Space activate the focused row', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      var taps = 0;
      await pumpFinesse(tester, tile(onTap: () => taps++, focusNode: node));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 2);
    });

    testWidgets('a trailing button keeps its own tap', (tester) async {
      var rowTaps = 0;
      var buttonTaps = 0;
      await pumpFinesse(
        tester,
        Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              title: const Text('Title'),
              trailing: Button.outline(
                onPressed: () => buttonTaps++,
                child: const Text('Go'),
              ),
              onTap: () => rowTaps++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(buttonTaps, 1);
      expect(rowTaps, 0);
    });

    testWidgets('an inert tile builds no pressable at all', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpFinesse(tester, tile(focusNode: node));
      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(Pressable),
        ),
        findsNothing,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('a selected tile with no onTap is highlighted, and still not '
        'a control', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          tile(selected: true, focusNode: node),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byType(ListTile));

        // The accent fill, on the tile's own radius…
        final fill = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.byType(DecoratedBox),
          ),
        );
        final decoration = fill.decoration as BoxDecoration;
        expect(
          decoration.color,
          theme.colorScheme.accent,
          reason: '$brightness',
        );
        expect(decoration.color, theme.listTileTheme.selectedColor);
        expect(decoration.borderRadius, theme.listTileTheme.radius);
        expect(
          tester.getRect(find.byWidget(fill)),
          tester.getRect(find.byType(ListTile)),
        );

        // …and none of a button's machinery.
        for (final type in [Pressable, FocusRing, AnimatedContainer]) {
          expect(
            find.descendant(
              of: find.byType(ListTile),
              matching: find.byType(type),
            ),
            findsNothing,
            reason: '$type',
          );
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(node.hasFocus, isFalse);
      }
    });

    testWidgets('an inert selected tile does not react to the pointer', (
      tester,
    ) async {
      await pumpFinesse(tester, tile(selected: true));
      Color fill() =>
          (tester
                      .widget<DecoratedBox>(
                        find.descendant(
                          of: find.byType(ListTile),
                          matching: find.byType(DecoratedBox),
                        ),
                      )
                      .decoration
                  as BoxDecoration)
              .color!;
      final before = fill();
      await hoverAt(tester, tester.getCenter(find.byType(ListTile)));
      await settle(tester);
      expect(fill(), before);
      await tester.tap(find.byType(ListTile), warnIfMissed: false);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an inert selected tile is laid out like any other', (
      tester,
    ) async {
      await pumpFinesse(tester, tile());
      final plain = tester.getRect(find.byType(ListTile));
      final title = tester.getRect(find.text('Title'));

      await pumpFinesse(tester, tile(selected: true));
      expect(tester.getRect(find.byType(ListTile)), plain);
      expect(tester.getRect(find.text('Title')), title);

      await pumpFinesse(tester, tile(selected: true, onTap: () {}));
      expect(tester.getRect(find.byType(ListTile)), plain);
    });

    testWidgets("an inert selected tile takes the theme's selected colour "
        'and the radius it is given', (tester) async {
      const colour = Color(0xff224466);
      const radius = BorderRadius.all(Radius.circular(3));
      await pumpFinesse(
        tester,
        const Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              title: Text('Title'),
              selected: true,
              borderRadius: radius,
            ),
          ),
        ),
        theme: ThemeData(
          listTileTheme: const ListTileTheme(selectedColor: colour),
        ),
      );
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(ListTile),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      expect(decoration.color, colour);
      expect(decoration.borderRadius, radius);
    });

    testWidgets('an inert unselected tile paints no fill', (tester) async {
      await pumpFinesse(tester, tile());
      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('hover highlights an interactive row in the muted colour', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, tile(onTap: () {}));
      final theme = themeOf(tester, find.byType(ListTile));
      expect(highlightOf(tester).color!.a, 0);

      final gesture = await hoverAt(
        tester,
        tester.getCenter(find.byType(ListTile)),
      );
      await settle(tester);
      expect(highlightOf(tester).color, theme.colorScheme.muted);
      expect(highlightOf(tester).borderRadius, theme.listTileTheme.radius);

      await gesture.moveTo(Offset.zero);
      await settle(tester);
      expect(highlightOf(tester).color!.a, 0);
    });

    testWidgets('selected fills the row with the accent, hovered or not', (
      tester,
    ) async {
      useTraditionalHighlights();
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          tile(onTap: () {}, selected: true),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byType(ListTile));
        expect(highlightOf(tester).color, theme.colorScheme.accent);

        final gesture = await hoverAt(
          tester,
          tester.getCenter(find.byType(ListTile)),
        );
        await settle(tester);
        expect(highlightOf(tester).color, theme.colorScheme.accent);
        await gesture.removePointer();
      }
    });

    testWidgets('selecting changes the resolved fill', (tester) async {
      await pumpFinesse(tester, tile(onTap: () {}));
      final off = highlightOf(tester).color;
      await pumpFinesse(tester, tile(onTap: () {}, selected: true));
      expect(highlightOf(tester).color, isNot(off));
    });

    testWidgets('borderRadius shapes the highlight and the focus ring', (
      tester,
    ) async {
      useTraditionalHighlights();
      const radius = BorderRadius.all(Radius.circular(3));
      await pumpFinesse(
        tester,
        Center(
          child: SizedBox(
            width: 320,
            child: ListTile(
              title: const Text('Title'),
              borderRadius: radius,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(highlightOf(tester).borderRadius, radius);
      expect(tester.widget<FocusRing>(find.byType(FocusRing)).visible, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = tester.widget<FocusRing>(find.byType(FocusRing));
      expect(ring.visible, isTrue);
      expect(ring.borderRadius, radius);
    });
  });

  group('ListTile semantics', () {
    testWidgets('an interactive row is one button labelled by its text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile(onTap: () {}, trailing: null));

      expect(
        tester.getSemantics(find.byType(Pressable)),
        matchesSemantics(
          label: 'Title\nSub',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('the selected row is announced as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile(onTap: () {}, selected: true));
      final data = tester
          .getSemantics(find.byType(Pressable))
          .getSemanticsData();
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(data.flagsCollection.isButton, isTrue);
      handle.dispose();
    });

    testWidgets('an unselected interactive row is a plain button: no '
        'selected state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile(onTap: () {}));
      expect(
        tester
            .getSemantics(find.byType(Pressable))
            .getSemanticsData()
            .flagsCollection
            .isSelected,
        ui.Tristate.none,
      );
      handle.dispose();
    });

    testWidgets('an inert selected row is announced as selected, and not as '
        'a button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile(selected: true, trailing: null));
      final data = tester.getSemantics(find.text('Title')).getSemanticsData();
      expect(data.label, 'Title\nSub');
      expect(data.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.flagsCollection.isEnabled, ui.Tristate.none);
      expect(data.hasAction(ui.SemanticsAction.focus), isFalse);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('an inert row is plain text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile());
      final data = tester.getSemantics(find.text('Title')).getSemanticsData();
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.flagsCollection.isSelected, ui.Tristate.none);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      handle.dispose();
    });
  });
}
