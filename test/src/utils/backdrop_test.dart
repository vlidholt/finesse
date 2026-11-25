import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';
import '../../finesse_harness.dart';

/// A backdrop filter is a compositing layer, so the rule these lock is that
/// nothing pays for one unless it lets the backdrop through: `Backdrop`
/// builds none without a blur or a saturation, and `Card` builds one only
/// while its fill is translucent.
void main() {
  const marker = SizedBox(key: Key('child'), width: 40, height: 40);

  group('Backdrop', () {
    testWidgets('builds no BackdropFilter when blur is 0 and saturation is 1', (
      tester,
    ) async {
      await pumpFinesse(tester, const Center(child: Backdrop(child: marker)));

      expect(find.byKey(const Key('child')), findsOneWidget);
      final backdrop = find.byType(Backdrop);
      expect(
        find.descendant(of: backdrop, matching: find.byType(BackdropFilter)),
        findsNothing,
      );
      // Nor the clip a filter would need: the child is returned as it is.
      expect(
        find.descendant(of: backdrop, matching: find.byType(ClipRRect)),
        findsNothing,
      );
      expect(tester.getSize(backdrop), const Size.square(40));
    });

    testWidgets('a negative blur is no blur', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: Backdrop(blur: -4, child: marker)),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('a blur builds a filter clipped to the radius', (tester) async {
      const radius = BorderRadius.all(Radius.circular(12));
      await pumpFinesse(
        tester,
        const Center(
          child: Backdrop(blur: 24, borderRadius: radius, child: marker),
        ),
      );

      final backdrop = find.byType(Backdrop);
      final filter = find.descendant(
        of: backdrop,
        matching: find.byType(BackdropFilter),
      );
      expect(filter, findsOneWidget);
      final clip = tester.widget<ClipRRect>(
        find.descendant(of: backdrop, matching: find.byType(ClipRRect)),
      );
      expect(clip.borderRadius, radius);
      // The filter is confined to the child's own box, not the screen.
      expect(tester.getSize(filter), const Size.square(40));
      expect(tester.getSize(backdrop), const Size.square(40));
      expect(
        tester.widget<BackdropFilter>(filter).filter,
        same(Backdrop.filterFor(blur: 24)),
      );
    });

    testWidgets('a saturation alone builds a filter too', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: Backdrop(saturation: 1.6, child: marker)),
      );
      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      // With nothing to blur the filter is just the colour matrix.
      expect(filter.filter, isA<ui.ColorFilter>());
    });

    testWidgets('follows a change of blur in both directions', (tester) async {
      await pumpFinesse(tester, const Center(child: Backdrop(child: marker)));
      expect(find.byType(BackdropFilter), findsNothing);

      await pumpFinesse(
        tester,
        const Center(child: Backdrop(blur: 8, child: marker)),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);

      await pumpFinesse(tester, const Center(child: Backdrop(child: marker)));
      expect(find.byType(BackdropFilter), findsNothing);
    });

    test('filterFor is null when there is nothing to do', () {
      expect(Backdrop.filterFor(blur: 0), isNull);
      expect(Backdrop.filterFor(blur: -1), isNull);
      expect(Backdrop.filterFor(blur: 0, saturation: 1), isNull);
    });

    test('filterFor hands out one filter per pair of values', () {
      final a = Backdrop.filterFor(blur: 24, saturation: 1.6);
      final b = Backdrop.filterFor(blur: 24, saturation: 1.6);
      expect(a, isNotNull);
      expect(b, same(a));
      expect(Backdrop.filterFor(blur: 12, saturation: 1.6), isNot(same(a)));
      expect(Backdrop.filterFor(blur: 24, saturation: 1.2), isNot(same(a)));
      expect(Backdrop.filterFor(blur: 24), isNot(same(a)));
    });

    test('the filter cache is bounded: it is cleared once it holds more '
        'than 32 pairs', () {
      // Sigmas nothing else in this file asks for.
      var next = 5000.0;
      ui.ImageFilter fresh() => Backdrop.filterFor(blur: next += 1)!;
      const probe = 4999.5;
      ui.ImageFilter probed() => Backdrop.filterFor(blur: probe)!;

      // Whatever the cache held, enough new pairs push the probe out. An
      // animated blur asks for a new sigma every frame; without the bound
      // each would stay cached for the life of the app.
      final first = probed();
      expect(probed(), same(first));
      for (var i = 0; i < 40; i++) {
        fresh();
      }
      final second = probed();
      expect(second, isNot(same(first)));
      // The same filter by value, though: only the instance was dropped.
      expect(second, first);

      // Now count. Add pairs until the probe is dropped again: the lookup
      // that notices is the one that cleared the cache, so it holds the
      // probe and nothing else.
      var held = probed();
      while (identical(probed(), held)) {
        fresh();
        if (next > 6000) fail('the cache never dropped the probe');
      }
      held = probed();
      // The probe and 31 others make 32, which is kept…
      for (var i = 0; i < 31; i++) {
        fresh();
      }
      expect(probed(), same(held), reason: '32 pairs fit');
      // …and one more is past the bound.
      fresh();
      expect(probed(), isNot(same(held)), reason: 'the 33rd clears it');
    });

    test('a cleared cache goes back to sharing one filter per pair', () {
      for (var i = 0; i < 80; i++) {
        Backdrop.filterFor(blur: 7000.0 + i, saturation: 1.3);
      }
      final a = Backdrop.filterFor(blur: 24, saturation: 1.6);
      expect(Backdrop.filterFor(blur: 24, saturation: 1.6), same(a));
      expect(Backdrop.filterFor(blur: 0), isNull);
    });

    testWidgets('a backdrop still filters after the cache has overflowed', (
      tester,
    ) async {
      for (var i = 0; i < 80; i++) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Backdrop(blur: 8000.0 + i, child: marker),
            ),
          ),
        );
        expect(
          tester.widget<BackdropFilter>(find.byType(BackdropFilter)).filter,
          ui.ImageFilter.blur(
            sigmaX: 8000.0 + i,
            sigmaY: 8000.0 + i,
            tileMode: TileMode.mirror,
          ),
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('reports blur and saturation to the inspector', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: Backdrop(blur: 8, saturation: 1.5, child: marker)),
      );
      final description = tester
          .element(find.byType(Backdrop))
          .toDiagnosticsNode()
          .toStringDeep();
      expect(description, contains('blur: 8.0'));
      expect(description, contains('saturation: 1.5'));
    });
  });

  group('Card backdrop', () {
    Finder filterIn(Finder card) =>
        find.descendant(of: card, matching: find.byType(BackdropFilter));

    // finesse with the card blur its styles leave off.
    final glassCards = StyleTokens.finesse.copyWith(cardBlur: true);

    testWidgets('the finesse card is translucent and does not blur', (
      tester,
    ) async {
      // A card lies on the flat page, where a blur shows nothing and a
      // backdrop filter per card is paid on every frame.
      for (final brightness in Brightness.values) {
        for (final formFactor in FormFactor.values) {
          final theme = ThemeData(brightness: brightness);
          await pumpFinesse(
            tester,
            const Center(child: Card(child: Text('Hi'))),
            theme: theme,
            formFactor: formFactor,
          );
          final seen = themeOf(tester, find.byType(Card));
          expect(seen.formFactor, formFactor);
          expect(seen.cardTheme.backgroundColor!.a, lessThan(1));
          expect(seen.cardTheme.blur, 0);
          expect(seen.cardTheme.saturation, 1);
          expect(
            find.byType(BackdropFilter),
            findsNothing,
            reason: '$brightness $formFactor',
          );
        }
      }
    });

    testWidgets('a style with card blur on blurs behind its cards', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness, style: glassCards);
        await pumpFinesse(
          tester,
          const Center(child: Card(child: Text('Hi'))),
          theme: theme,
        );

        final card = find.byType(Card);
        expect(theme.cardTheme.backgroundColor!.a, lessThan(1));
        expect(theme.cardTheme.blur, 24);
        expect(theme.cardTheme.saturation, 1.6);
        expect(filterIn(card), findsOneWidget, reason: '$brightness');
        expect(
          tester.widget<BackdropFilter>(filterIn(card)).filter,
          same(Backdrop.filterFor(blur: 24, saturation: 1.6)),
        );
        // The filter is clipped to the card's own rounded outline.
        final clip = tester.widget<ClipRRect>(
          find.descendant(of: card, matching: find.byType(ClipRRect)).first,
        );
        expect(clip.borderRadius, theme.cardTheme.borderRadius);
        expect(tester.getSize(filterIn(card)), tester.getSize(card));
      }
    });

    testWidgets('the nova card is opaque, so it does not', (tester) async {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(
          style: StyleTokens.nova,
          brightness: brightness,
        );
        await pumpFinesse(
          tester,
          const Center(child: Card(child: Text('Hi'))),
          theme: theme,
        );

        expect(theme.cardTheme.blur, 0);
        expect(theme.cardTheme.backgroundColor, theme.colorScheme.card);
        expect(
          filterIn(find.byType(Card)),
          findsNothing,
          reason: '$brightness',
        );
      }
    });

    testWidgets('none of the shadcn styles blur their cards', (tester) async {
      for (final style in [
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        await pumpFinesse(
          tester,
          const Center(child: Card(child: Text('Hi'))),
          theme: ThemeData(
            style: style,
            colorScheme: const NeutralColorScheme.light(),
          ),
        );
        expect(find.byType(BackdropFilter), findsNothing, reason: style.name);
      }
    });

    testWidgets('a finesse card given an opaque fill stops blurring', (
      tester,
    ) async {
      // The layer is only worth it while the backdrop shows through.
      await pumpFinesse(
        tester,
        const Center(
          child: Card(
            style: CardTheme(backgroundColor: Color(0xff336699)),
            child: Text('Hi'),
          ),
        ),
        theme: ThemeData(style: glassCards),
      );
      expect(filterIn(find.byType(Card)), findsNothing);
    });

    testWidgets('a theme with the blur turned off does not blur a '
        'translucent card', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: Card(child: Text('Hi'))),
        theme: ThemeData(
          style: glassCards,
          cardTheme: const CardTheme(blur: 0),
        ),
      );
      expect(filterIn(find.byType(Card)), findsNothing);
    });

    testWidgets('the card theme alone can turn the blur on', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: Card(child: Text('Hi'))),
        theme: ThemeData(cardTheme: const CardTheme(blur: 12)),
      );
      expect(themeOf(tester, find.byType(Card)).cardTheme.blur, 12);
      expect(filterIn(find.byType(Card)), findsOneWidget);
    });

    testWidgets('the blurred card keeps its shadow, outside the clip', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: Card(child: Text('Hi'))),
        theme: ThemeData(style: glassCards),
      );
      final theme = themeOf(tester, find.byType(Card));
      final card = find.byType(Card);

      // A clip would cut an outward shadow off, so the shadow is carried by
      // a box around the filter rather than by the clipped surface.
      final shadowBox = tester.widget<DecoratedBox>(
        find.descendant(of: card, matching: find.byType(DecoratedBox)).first,
      );
      expect(shadowsOf(shadowBox.decoration), theme.cardTheme.shadows);
      expect(theme.cardTheme.shadows, isNotEmpty);
      final shadowElement = tester.element(
        find.descendant(of: card, matching: find.byType(DecoratedBox)).first,
      );
      var insideClip = false;
      shadowElement.visitAncestorElements((ancestor) {
        if (ancestor.widget is Card) return false;
        if (ancestor.widget is ClipRRect) insideClip = true;
        return true;
      });
      expect(insideClip, isFalse);

      // And the surface inside the clip paints the fill and the outline but
      // no shadow of its own, which would show through the glass as a grey
      // wash.
      final surface = tester.widget<Container>(
        find.descendant(of: card, matching: find.byType(Container)).first,
      );
      expect(surface.decoration, isA<BoxDecoration>());
      final decoration = surface.decoration! as BoxDecoration;
      expect(decoration.boxShadow, isNull);
      expect(decoration.color, theme.cardTheme.backgroundColor);
      expect(decoration.borderRadius, theme.cardTheme.borderRadius);
    });

    testWidgets('blurred or not, a card is the same size', (tester) async {
      Future<Size> sizeWith(ThemeData theme) async {
        await pumpFinesse(
          tester,
          const Center(
            child: SizedBox(
              width: 300,
              child: Card(
                title: Text('Title'),
                description: Text('Description'),
                child: Text('Hi'),
              ),
            ),
          ),
          theme: theme,
        );
        return tester.getSize(find.byType(Card));
      }

      final blurred = await sizeWith(ThemeData());
      final flat = await sizeWith(
        ThemeData(cardTheme: const CardTheme(blur: 0)),
      );
      expect(blurred, flat);
    });
  });
}
