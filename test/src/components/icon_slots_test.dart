import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// An icon is a widget, in a component and in its theme. A theme's icon is
/// drawn at the size and in the colour the built-in one is.
void main() {
  Widget app(Widget child, {ThemeData? theme}) => FinesseApp(
    theme: theme,
    darkTheme: theme,
    home: Center(child: child),
  );

  IconThemeData iconThemeAt(WidgetTester tester, Finder finder) =>
      IconTheme.of(tester.element(finder));

  group('Accordion', () {
    Widget accordion({Widget? icon}) => Accordion<int>(
      children: [
        AccordionItem(
          value: 1,
          title: const Text('Title'),
          icon: icon,
          child: const Text('Content'),
        ),
      ],
    );

    testWidgets('the built-in caret is 16 large in the foreground colour', (
      tester,
    ) async {
      final theme = ThemeData();
      await tester.pumpWidget(app(accordion(), theme: theme));
      final caret = find.byIcon(PhosphorIconsRegular.caretDown);
      expect(caret, findsOneWidget);
      final iconTheme = iconThemeAt(tester, caret);
      expect(iconTheme.size, 16);
      expect(iconTheme.color, theme.colorScheme.foreground);
    });

    testWidgets("the theme's icon stands in for it, drawn the same way", (
      tester,
    ) async {
      final base = ThemeData();
      final theme = base.copyWith(
        accordionTheme: base.accordionTheme.copyWith(
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
      );
      await tester.pumpWidget(app(accordion(), theme: theme));
      expect(find.byIcon(PhosphorIconsRegular.caretDown), findsNothing);
      final plus = find.byIcon(PhosphorIconsRegular.plus);
      expect(iconThemeAt(tester, plus).size, 16);
      expect(iconThemeAt(tester, plus).color, theme.colorScheme.foreground);
    });

    testWidgets("an item's own icon wins", (tester) async {
      await tester.pumpWidget(
        app(accordion(icon: const PhosphorIcon(PhosphorIconsRegular.minus))),
      );
      expect(find.byIcon(PhosphorIconsRegular.caretDown), findsNothing);
      expect(find.byIcon(PhosphorIconsRegular.minus), findsOneWidget);
    });
  });

  group('Calendar', () {
    testWidgets('the navigation carets are drawn at the theme size', (
      tester,
    ) async {
      final theme = ThemeData();
      await tester.pumpWidget(app(const Calendar(), theme: theme));
      for (final icon in [
        PhosphorIconsRegular.caretLeft,
        PhosphorIconsRegular.caretRight,
      ]) {
        final caret = find.byIcon(icon);
        expect(caret, findsOneWidget);
        expect(
          iconThemeAt(tester, caret).size,
          theme.calendarTheme.navigationButtonIconSize,
        );
      }
    });

    testWidgets("the theme's icons stand in for them", (tester) async {
      final base = ThemeData();
      final theme = base.copyWith(
        calendarTheme: base.calendarTheme.copyWith(
          backNavigationButtonIcon: const PhosphorIcon(
            PhosphorIconsRegular.arrowLeft,
          ),
          forwardNavigationButtonIcon: const PhosphorIcon(
            PhosphorIconsRegular.arrowRight,
          ),
        ),
      );
      await tester.pumpWidget(app(const Calendar(), theme: theme));
      expect(find.byIcon(PhosphorIconsRegular.caretLeft), findsNothing);
      expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNothing);
      final back = find.byIcon(PhosphorIconsRegular.arrowLeft);
      expect(
        iconThemeAt(tester, back).size,
        theme.calendarTheme.navigationButtonIconSize,
      );
      expect(find.byIcon(PhosphorIconsRegular.arrowRight), findsOneWidget);
    });
  });

  test('a theme with a constant icon compares equal to its twin', () {
    AccordionTheme theme() => const AccordionTheme(
      icon: PhosphorIcon(PhosphorIconsRegular.plus),
    );
    expect(theme(), theme());
    expect(
      ThemeData().accordionTheme.icon,
      same(ThemeData().accordionTheme.icon),
    );
    expect(
      ThemeData().calendarTheme.backNavigationButtonIcon,
      same(ThemeData().calendarTheme.backNavigationButtonIcon),
    );
  });
}
