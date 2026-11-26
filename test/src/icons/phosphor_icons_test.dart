import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// The Phosphor icons are vendored: the glyph fonts ship in this package, so
/// every `IconData` has to name una as its font package or the glyphs
/// resolve to nothing in an app.
void main() {
  group('vendored icon data', () {
    test('each weight names its own family in the una package', () {
      const expected = {
        'PhosphorRegular': PhosphorIconsRegular.house,
        'PhosphorBold': PhosphorIconsBold.house,
        'PhosphorFill': PhosphorIconsFill.house,
        'PhosphorLight': PhosphorIconsLight.house,
        'PhosphorThin': PhosphorIconsThin.house,
      };
      for (final entry in expected.entries) {
        expect(entry.value.fontFamily, entry.key);
        expect(entry.value.fontPackage, 'una', reason: entry.key);
      }
    });

    test('the regular house is the glyph it has always been', () {
      expect(PhosphorIconsRegular.house.codePoint, 0xe2c2);
      expect(PhosphorIconsRegular.house.fontFamily, 'PhosphorRegular');
      expect(PhosphorIconsRegular.house.fontPackage, 'una');
      // Plain `IconData`, so it works anywhere an icon is accepted.
      expect(PhosphorIconsRegular.house.runtimeType, IconData);
    });

    test('the same icon is the same code point in every weight', () {
      final codePoint = PhosphorIconsRegular.house.codePoint;
      for (final icon in const [
        PhosphorIconsBold.house,
        PhosphorIconsFill.house,
        PhosphorIconsLight.house,
        PhosphorIconsThin.house,
      ]) {
        expect(icon.codePoint, codePoint, reason: '${icon.fontFamily}');
      }
      // And the weights are still different icons.
      expect(PhosphorIconsRegular.house, isNot(PhosphorIconsFill.house));
    });

    test('a duotone icon is an outline over a fill, in the duotone family', () {
      const house = PhosphorIconsDuotone.house;
      expect(house.primary.fontFamily, 'PhosphorDuotone');
      expect(house.primary.fontPackage, 'una');
      expect(house.secondary, isNotNull);
      expect(house.secondary!.fontFamily, 'PhosphorDuotone');
      expect(house.secondary!.fontPackage, 'una');
      expect(house.primary.codePoint, isNot(house.secondary!.codePoint));
    });

    test('a duotone icon with no fill layer has only its outline', () {
      expect(PhosphorIconsDuotone.wifiNone.secondary, isNull);
      expect(
        PhosphorIconsDuotone.wifiNone.primary.fontFamily,
        'PhosphorDuotone',
      );
    });

    test('duotone data compares by value', () {
      const a = PhosphorDuotoneIconData(
        IconData(0xe2c3, fontFamily: 'PhosphorDuotone', fontPackage: 'una'),
        IconData(0xe2c2, fontFamily: 'PhosphorDuotone', fontPackage: 'una'),
      );
      expect(a, PhosphorIconsDuotone.house);
      expect(a.hashCode, PhosphorIconsDuotone.house.hashCode);
      expect(a, isNot(PhosphorIconsDuotone.wifiNone));
    });

    test('nothing under lib/ reaches for the phosphor_flutter package', () {
      // The fonts are declared in this package's own pubspec; an icon naming
      // another package would render as a missing glyph.
      expect(PhosphorIconsRegular.x.fontPackage, 'una');
      expect(PhosphorIconsRegular.caretDown.fontPackage, 'una');
      expect(PhosphorIconsRegular.calendarBlank.fontPackage, 'una');
    });
  });

  group('PhosphorDuotoneIcon', () {
    Finder icons() => find.descendant(
      of: find.byType(PhosphorDuotoneIcon),
      matching: find.byType(Icon),
    );

    testWidgets('is two stacked icons: the fill at 20% under the outline', (
      tester,
    ) async {
      const colour = Color(0xff176b83);
      await pumpUna(
        tester,
        const Center(
          child: PhosphorDuotoneIcon(
            PhosphorIconsDuotone.house,
            size: 24,
            color: colour,
          ),
        ),
      );
      expect(icons(), findsNWidgets(2));
      final lower = tester.widget<Icon>(icons().at(0));
      final upper = tester.widget<Icon>(icons().at(1));

      // A stack paints in order, so the fill comes first.
      expect(lower.icon, PhosphorIconsDuotone.house.secondary);
      expect(upper.icon, PhosphorIconsDuotone.house.primary);
      expect(upper.color, colour);
      expect(lower.color, colour.withValues(alpha: .2));
      expect(lower.size, 24);
      expect(upper.size, 24);
      // The two are the same box, one on the other.
      expect(tester.getRect(icons().at(0)), tester.getRect(icons().at(1)));
      expect(
        tester.getSize(find.byType(PhosphorDuotoneIcon)),
        const Size.square(24),
      );
    });

    testWidgets('an icon with no fill layer is a single icon', (tester) async {
      await pumpUna(
        tester,
        const Center(
          child: PhosphorDuotoneIcon(PhosphorIconsDuotone.wifiNone, size: 24),
        ),
      );
      expect(icons(), findsOneWidget);
      expect(
        tester.widget<Icon>(icons()).icon,
        PhosphorIconsDuotone.wifiNone.primary,
      );
      expect(
        find.descendant(
          of: find.byType(PhosphorDuotoneIcon),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );
      expect(
        tester.getSize(find.byType(PhosphorDuotoneIcon)),
        const Size.square(24),
      );
    });

    testWidgets('size and colour default to the ambient icon theme', (
      tester,
    ) async {
      const colour = Color(0xffcc3300);
      await pumpUna(
        tester,
        const Center(
          child: IconTheme(
            data: IconThemeData(size: 30, color: colour),
            child: PhosphorDuotoneIcon(PhosphorIconsDuotone.house),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(PhosphorDuotoneIcon)),
        const Size.square(30),
      );
      expect(tester.widget<Icon>(icons().at(1)).color, colour);
      expect(
        tester.widget<Icon>(icons().at(0)).color,
        colour.withValues(alpha: .2),
      );
    });

    testWidgets('takes its size from a button, like any icon', (tester) async {
      await pumpUna(
        tester,
        Center(
          child: IconButton(
            icon: const PhosphorDuotoneIcon(PhosphorIconsDuotone.house),
            onPressed: () {},
          ),
        ),
      );
      final theme = themeOf(tester, find.byType(IconButton));
      expect(
        tester.getSize(find.byType(PhosphorDuotoneIcon)),
        Size.square(theme.buttonSizesTheme.icon!.iconSize!),
      );
    });

    testWidgets('secondaryOpacity and secondaryColor set the fill', (
      tester,
    ) async {
      const outline = Color(0xff000000);
      const fill = Color(0xff00aa00);
      await pumpUna(
        tester,
        const Center(
          child: PhosphorDuotoneIcon(
            PhosphorIconsDuotone.house,
            color: outline,
            secondaryColor: fill,
            secondaryOpacity: .5,
          ),
        ),
      );
      expect(tester.widget<Icon>(icons().at(1)).color, outline);
      expect(
        tester.widget<Icon>(icons().at(0)).color,
        fill.withValues(alpha: .5),
      );
    });

    testWidgets('the fill opacity multiplies a translucent colour', (
      tester,
    ) async {
      const colour = Color(0x80112233);
      await pumpUna(
        tester,
        const Center(
          child: PhosphorDuotoneIcon(PhosphorIconsDuotone.house, color: colour),
        ),
      );
      expect(
        tester.widget<Icon>(icons().at(0)).color!.a,
        closeTo(colour.a * .2, 1e-6),
      );
    });

    testWidgets('is announced once, by its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(
          child: PhosphorDuotoneIcon(
            PhosphorIconsDuotone.house,
            semanticLabel: 'Home',
          ),
        ),
      );
      // The fill layer is decoration.
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      handle.dispose();
    });
  });
}
