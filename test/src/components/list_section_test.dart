import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/list_section.dart'
    show debugListSectionDivider;
import 'package:una/una.dart';

import '../../frame_sampler.dart';
import '../../una_harness.dart';

void main() {
  Widget section({
    ListSectionVariant variant = ListSectionVariant.card,
    bool dividers = true,
    double? dividerIndent,
    Widget? header = const Text('Account'),
    Widget? footer = const Text('Changes apply at once.'),
    VoidCallback? onTap,
    List<Widget>? children,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 360,
        child: ListSection(
          header: header,
          headerTrailing: const Text('See all'),
          footer: footer,
          variant: variant,
          dividers: dividers,
          dividerIndent: dividerIndent,
          children:
              children ??
              [
                ListTile(
                  key: const Key('a'),
                  leading: const SizedBox(width: 28, height: 28),
                  title: const Text('Name'),
                  onTap: onTap,
                ),
                ListTile(
                  key: const Key('b'),
                  title: const Text('Email'),
                  onTap: onTap,
                ),
                ListTile(
                  key: const Key('c'),
                  title: const Text('Phone'),
                  onTap: onTap,
                ),
              ],
        ),
      ),
    );
  }

  ({bool divider, double indent}) dividerOf(WidgetTester tester, Key key) =>
      debugListSectionDivider(tester.renderObject(find.byKey(key)))!;

  ListSectionScope scopeOf(WidgetTester tester, Key key) =>
      ListSectionScope.maybeOf(
        tester.element(
          find.descendant(
            of: find.byKey(key),
            matching: find.text(_title(key)),
          ),
        ),
      )!;

  group('ListSectionTheme', () {
    test('is fed by the style, the scheme and the form factor', () {
      final desktop = ThemeData();
      final phone = desktop.withFormFactor(FormFactor.mobile);
      final s = desktop.listSectionTheme;
      expect(s.dividerColor, desktop.colorScheme.border);
      expect(s.pressedColor, desktop.colorScheme.muted);
      expect(s.headerStyle!.fontSize, desktop.style.overline.fontSize);
      expect(s.headerStyle!.color, desktop.colorScheme.mutedForeground);
      expect(s.footerStyle, isNull);
      expect(s.minTileHeight, desktop.style.buttonHeight);
      // A row is a touch target on a phone.
      expect(phone.listSectionTheme.minTileHeight, greaterThanOrEqualTo(44));
      for (final style in [
        StyleTokens.crisp,
        StyleTokens.pebble,
        StyleTokens.sharp,
      ]) {
        final theme = ThemeData(
          style: style,
        ).withFormFactor(FormFactor.mobile);
        expect(
          theme.listSectionTheme.minTileHeight,
          greaterThanOrEqualTo(44),
        );
      }
    });

    test('follows the spacing step', () {
      final wide = ThemeData(spacing: const Spacing(step: 8));
      final base = ThemeData();
      expect(
        wide.listSectionTheme.minTileHeight,
        base.listSectionTheme.minTileHeight! * 2,
      );
    });

    test('an override reaches the theme, and equal themes are equal', () {
      ThemeData build() => ThemeData(
        listSectionTheme: const ListSectionTheme(dividerThickness: 2),
      );
      expect(build().listSectionTheme.dividerThickness, 2);
      expect(build(), build());
      expect(
        build()
            .copyWith(radius: BorderRadius.circular(2))
            .listSectionTheme
            .dividerThickness,
        2,
      );
    });
  });

  group('ListSection layout', () {
    testWidgets('builds in every layout without overflowing', (tester) async {
      await expectBuildsInEveryLayout(tester, (_) => section(onTap: () {}));
    });

    testWidgets('rows are positioned first, middle and last', (tester) async {
      await pumpUna(tester, section());
      expect(
        scopeOf(tester, const Key('a')).position,
        ListSectionPosition.first,
      );
      expect(
        scopeOf(tester, const Key('b')).position,
        ListSectionPosition.middle,
      );
      expect(
        scopeOf(tester, const Key('c')).position,
        ListSectionPosition.last,
      );

      await pumpUna(
        tester,
        section(
          children: [const ListTile(key: Key('a'), title: Text('Name'))],
        ),
      );
      final only = scopeOf(tester, const Key('a'));
      expect(only.position, ListSectionPosition.only);
      expect(only.position.isFirst && only.position.isLast, isTrue);
    });

    testWidgets('the card variant sits its rows on a clipping card', (
      tester,
    ) async {
      await pumpUna(tester, section());
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.style?.padding, EdgeInsets.zero);
      // The rows fill the card from edge to edge.
      final cardRect = tester.getRect(find.byType(Card));
      final rowRect = tester.getRect(find.byKey(const Key('b')));
      expect(rowRect.left, moreOrLessEquals(cardRect.left + 1));
      expect(rowRect.right, moreOrLessEquals(cardRect.right - 1));
    });

    testWidgets('the plain variant has no card and runs edge to edge', (
      tester,
    ) async {
      await pumpUna(tester, section(variant: ListSectionVariant.plain));
      expect(find.byType(Card), findsNothing);
      final rowRect = tester.getRect(find.byKey(const Key('b')));
      expect(rowRect.width, 360);
      expect(
        scopeOf(tester, const Key('a')).rowBorderRadius,
        BorderRadius.zero,
      );
    });

    testWidgets("the header lines up with the rows' text", (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(
          tester,
          section(),
          textDirection: direction,
        );
        final header = tester.getRect(find.text('Account'));
        final title = tester.getRect(find.text('Email'));
        final footer = tester.getRect(find.text('Changes apply at once.'));
        if (direction == TextDirection.ltr) {
          // The card's hairline outline is the only difference.
          expect(header.left, moreOrLessEquals(title.left - 1));
          expect(footer.left, moreOrLessEquals(title.left - 1));
          expect(
            tester.getRect(find.text('See all')).right,
            greaterThan(header.right),
          );
        } else {
          expect(header.right, moreOrLessEquals(title.right + 1));
          expect(footer.right, moreOrLessEquals(title.right + 1));
        }
      }
    });

    testWidgets("a tile takes the section's padding and least height", (
      tester,
    ) async {
      for (final formFactor in FormFactor.values) {
        await pumpUna(tester, section(), formFactor: formFactor);
        final theme = themeOf(tester, find.byType(ListSection));
        final row = tester.getRect(find.byKey(const Key('b')));
        expect(
          row.height,
          greaterThanOrEqualTo(theme.listSectionTheme.minTileHeight!),
          reason: formFactor.name,
        );
        if (formFactor == FormFactor.mobile) {
          expect(row.height, greaterThanOrEqualTo(44));
        }
        final padding = theme.listSectionTheme.tilePadding!.resolve(
          TextDirection.ltr,
        );
        expect(
          tester.getRect(find.text('Email')).left,
          moreOrLessEquals(row.left + padding.left),
        );
      }
    });

    testWidgets('a row grows with the text scale', (tester) async {
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: section(),
        ),
      );
      expect(tester.takeException(), isNull);
      final row = tester.getRect(find.byKey(const Key('b')));
      final title = tester.getRect(find.text('Email'));
      expect(row.top, lessThan(title.top));
      expect(row.bottom, greaterThan(title.bottom));
    });

    testWidgets('header and footer are optional', (tester) async {
      await pumpUna(
        tester,
        const Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 300,
            child: ListSection(
              children: [ListTile(title: Text('One'))],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('One'), findsOneWidget);
    });
  });

  group('ListSection dividers', () {
    testWidgets('every row but the last has one', (tester) async {
      await pumpUna(tester, section());
      expect(dividerOf(tester, const Key('a')).divider, isTrue);
      expect(dividerOf(tester, const Key('b')).divider, isTrue);
      expect(dividerOf(tester, const Key('c')).divider, isFalse);

      await pumpUna(tester, section(dividers: false));
      expect(dividerOf(tester, const Key('a')).divider, isFalse);
    });

    testWidgets("it starts at the row's text, in both directions", (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpUna(tester, section(), textDirection: direction);
        final ltr = direction == TextDirection.ltr;
        for (final (key, text) in [
          (const Key('a'), 'Name'),
          (const Key('b'), 'Email'),
        ]) {
          final row = tester.getRect(find.byKey(key));
          final title = tester.getRect(find.text(text));
          expect(
            dividerOf(tester, key).indent,
            moreOrLessEquals(
              ltr ? title.left - row.left : row.right - title.right,
            ),
            reason: '$text ${direction.name}',
          );
        }
        // The row with a leading widget is indented further.
        expect(
          dividerOf(tester, const Key('a')).indent,
          greaterThan(dividerOf(tester, const Key('b')).indent),
        );
      }
    });

    testWidgets('dividerIndent overrides the text column', (tester) async {
      await pumpUna(tester, section(dividerIndent: 0));
      expect(dividerOf(tester, const Key('a')).indent, 0);
      await pumpUna(tester, section(dividerIndent: 30));
      expect(dividerOf(tester, const Key('a')).indent, 30);
    });

    testWidgets("a row without an anchor starts at the section's padding", (
      tester,
    ) async {
      await pumpUna(
        tester,
        section(
          children: const [
            SizedBox(key: Key('a'), height: 40),
            SizedBox(key: Key('b'), height: 40),
          ],
        ),
      );
      final theme = themeOf(tester, find.byType(ListSection));
      expect(
        dividerOf(tester, const Key('a')).indent,
        theme.listSectionTheme.tilePadding!.resolve(TextDirection.ltr).left,
      );
    });

    testWidgets('a custom row marks its own start with ListDividerAnchor', (
      tester,
    ) async {
      await pumpUna(
        tester,
        section(
          children: const [
            Padding(
              key: Key('a'),
              padding: EdgeInsets.only(left: 77),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ListDividerAnchor(child: Text('Custom')),
              ),
            ),
            SizedBox(key: Key('b'), height: 40),
          ],
        ),
      );
      expect(dividerOf(tester, const Key('a')).indent, 77);
    });

    testWidgets('a paint transform does not move the hairline', (tester) async {
      await pumpUna(
        tester,
        section(
          children: [
            Transform.translate(
              key: const Key('a'),
              offset: const Offset(-120, 0),
              child: const ListTile(title: Text('Name')),
            ),
            const ListTile(key: Key('b'), title: Text('Email')),
          ],
        ),
      );
      expect(
        dividerOf(tester, const Key('a')).indent,
        dividerOf(tester, const Key('b')).indent,
      );
    });

    testWidgets('the hairline is painted in the divider colour', (
      tester,
    ) async {
      final sampler = FrameSampler();
      await pumpUna(
        tester,
        sampler.wrap(
          section(
            header: null,
            footer: null,
            children: const [
              SizedBox(key: Key('a'), height: 40),
              SizedBox(key: Key('b'), height: 40),
            ],
          ),
        ),
        theme: ThemeData(
          colorScheme: const GraphiteColorScheme.light(),
          listSectionTheme: const ListSectionTheme(
            dividerColor: Color(0xffff0000),
            dividerThickness: 2,
          ),
        ),
      );
      final row = tester.getRect(find.byKey(const Key('a')));
      final onLine = await sampler.pixel(
        tester,
        Offset(row.right - 20, row.bottom - 1),
      );
      final beforeIndent = await sampler.pixel(
        tester,
        Offset(row.left + 4, row.bottom - 1),
      );
      final above = await sampler.pixel(
        tester,
        Offset(row.right - 20, row.bottom - 6),
      );
      expect(rgbOf(onLine), [255, 0, 0]);
      expect(rgbOf(beforeIndent), isNot([255, 0, 0]));
      expect(rgbOf(above), isNot([255, 0, 0]));
    });
  });

  group('ListSection interaction', () {
    testWidgets('a pressed row darkens instead of scaling', (tester) async {
      await pumpUna(tester, section(onTap: () {}));
      final theme = themeOf(tester, find.byType(ListSection));
      AnimatedFill fill() => tester.widget<AnimatedFill>(
        find.descendant(
          of: find.byKey(const Key('b')),
          matching: find.byType(AnimatedFill),
        ),
      );
      expect(fill().color, const Color(0x00000000));
      expect(fill().borderRadius, BorderRadius.zero);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('b'))),
      );
      await tester.pump();
      expect(fill().color, theme.listSectionTheme.pressedColor);
      final pressable = tester.widget<Pressable>(
        find.descendant(
          of: find.byKey(const Key('b')),
          matching: find.byType(Pressable),
        ),
      );
      expect(pressable.pressScale, 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(fill().color, const Color(0x00000000));
    });

    testWidgets("the focus ring is inside and follows the card's corners", (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpUna(tester, section(onTap: () {}));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      FocusRing ring(Key key) => tester.widget<FocusRing>(
        find.descendant(of: find.byKey(key), matching: find.byType(FocusRing)),
      );
      expect(ring(const Key('a')).visible, isTrue);
      expect(ring(const Key('a')).inset, isTrue);
      final first = ring(const Key('a')).borderRadius;
      expect(first.topLeft, isNot(Radius.zero));
      expect(first.bottomLeft, Radius.zero);
      expect(ring(const Key('b')).borderRadius, BorderRadius.zero);
      final last = ring(const Key('c')).borderRadius;
      expect(last.topLeft, Radius.zero);
      expect(last.bottomRight, isNot(Radius.zero));

      // Tab walks the rows in order.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(ring(const Key('a')).visible, isFalse);
      expect(ring(const Key('b')).visible, isTrue);
    });

    testWidgets('a tap reaches the row', (tester) async {
      var taps = 0;
      await pumpUna(tester, section(onTap: () => taps++));
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('ListSection semantics', () {
    testWidgets('the header is a header and the rows are a list', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, section(onTap: () {}));
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.text('Account')),
        matchesSemantics(label: 'Account', isHeader: true),
      );
      final list = tester.getSemantics(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.role == SemanticsRole.list,
        ),
      );
      expect(list.role, SemanticsRole.list);
      var items = 0;
      list.visitChildren((child) {
        if (child.role == SemanticsRole.listItem) items++;
        return true;
      });
      expect(items, 3);
      handle.dispose();
    });
  });
}

String _title(Key key) => switch (key) {
  const Key('a') => 'Name',
  const Key('b') => 'Email',
  _ => 'Phone',
};
