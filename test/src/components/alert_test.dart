import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/alert.dart';
import 'package:finesse/src/components/decorator.dart';
import 'package:finesse/src/icons/phosphor_icons.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:flutter/material.dart' hide ThemeData;
import 'package:flutter_test/flutter_test.dart';

import '../../fixture_styles.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('alert theme resolution', () {
    // The values `.cn-alert` prescribes: `bg-card` behind both variants, a
    // plain `border` outline even on destructive (only the *text* turns
    // red), a `text-muted-foreground` description that destructive tints at
    // 90% (`text-destructive/90`), and sera's accent bar on the left edge.
    test('both variants sit on bg-card inside a plain border', () {
      final theme = ThemeData();
      for (final alert in [
        theme.primaryAlertTheme,
        theme.destructiveAlertTheme,
      ]) {
        expect(alert.decoration?.color, theme.colorScheme.card);
        expect(alert.decoration?.border?.top?.color, theme.colorScheme.border);
      }
      expect(
        theme.primaryAlertTheme.descriptionStyle?.color,
        theme.colorScheme.mutedForeground,
      );
      expect(
        theme.destructiveAlertTheme.descriptionStyle?.color,
        theme.colorScheme.destructive.withValues(alpha: 0.9),
      );
    });

    test('sera draws its accent bar as a thick left side', () {
      final theme = ThemeData(style: FixtureStyles.sera);
      final primary = theme.primaryAlertTheme.decoration?.border;
      final destructive = theme.destructiveAlertTheme.decoration?.border;
      expect(primary?.left?.width, 2);
      expect(primary?.left?.color, theme.colorScheme.foreground);
      expect(destructive?.left?.color, theme.colorScheme.destructive);
      // The other sides stay on the regular hairline.
      expect(primary?.top?.width, 1);
      expect(primary?.top?.color, theme.colorScheme.border);
    });

    for (final direction in TextDirection.values) {
      for (final variant in [AlertVariant.primary, AlertVariant.success]) {
        testWidgets('sera draws its accent bar on the start edge '
            '(${direction.name}, ${variant.name})', (tester) async {
          await tester.pumpWidget(
            FinesseApp(
              theme: ThemeData(style: FixtureStyles.sera),
              home: Directionality(
                textDirection: direction,
                child: Center(
                  child: Alert(
                    variant: variant,
                    title: const Text('Saved'),
                  ),
                ),
              ),
            ),
          );
          final border = tester
              .widget<Decorator>(
                find
                    .descendant(
                      of: find.byType(Alert),
                      matching: find.byType(Decorator),
                    )
                    .first,
              )
              .decoration!
              .border!;
          final (start, end) = direction == TextDirection.ltr
              ? (border.left!, border.right!)
              : (border.right!, border.left!);
          expect(start.width, 2);
          expect(end.width, 1);
          // The bar takes the accent whole; the far edge the hairline's.
          expect(start.color!.a, 1);
          expect(end.color, isNot(start.color));
        });
      }
    }

    test('mira compacts the icon, the shipped styles keep size-4', () {
      for (final style in StyleTokens.all) {
        expect(
          ThemeData(style: style).primaryAlertTheme.iconSize,
          16,
          reason: style.name,
        );
      }
      expect(
        ThemeData(
          style: FixtureStyles.mira,
        ).primaryAlertTheme.iconSize,
        14,
      );
    });
  });

  group('Alert', () {
    testWidgets('renders primary variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Alert(
            title: Text('Primary Alert'),
            description: Text('This is a primary alert'),
            icon: Icon(Icons.info),
          ),
        ),
      );

      // Check if components render
      expect(find.text('Primary Alert'), findsOneWidget);
      expect(find.text('This is a primary alert'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Check basic layout
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders destructive variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Alert.destructive(
            title: Text('Error Alert'),
            description: Text('This is a destructive alert'),
            icon: Icon(Icons.error),
          ),
        ),
      );

      // Check if components render
      expect(find.text('Error Alert'), findsOneWidget);
      expect(find.text('This is a destructive alert'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('renders without icon when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Alert(
            title: Text('No Icon Alert'),
            description: Text('This alert has no icon'),
          ),
        ),
      );

      // Check text renders
      expect(find.text('No Icon Alert'), findsOneWidget);
      expect(find.text('This alert has no icon'), findsOneWidget);

      // Check no icon is present
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('applies custom styles correctly', (WidgetTester tester) async {
      const customColor = Colors.red;
      const customPadding = EdgeInsets.all(20);

      await tester.pumpWidget(
        createTestWidget(
          const Alert(
            title: Text('Styled Alert'),
            icon: Icon(Icons.info),
            iconColor: customColor,
            iconPadding: customPadding,
            titleStyle: TextStyle(fontSize: 20),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the specific Alert widget
      final alertFinder = find.byType(Alert);
      expect(alertFinder, findsOneWidget);

      // Find the IconTheme within the Alert and check its color
      final iconThemeFinder = find.descendant(
        of: alertFinder,
        matching: find.byType(IconTheme),
      );
      expect(iconThemeFinder, findsOneWidget);
      final iconTheme = tester.widget<IconTheme>(iconThemeFinder);
      expect(iconTheme.data.color, customColor);

      // Find the specific padding that wraps the icon
      final paddingFinder = find.ancestor(
        of: find.byIcon(Icons.info),
        matching: find.byType(Padding),
      );
      final padding = tester.widget<Padding>(paddingFinder.first);
      expect(padding.padding, customPadding);

      // Find the DefaultTextStyle within the Alert that styles the title
      final defaultTextStyleFinder = find.descendant(
        of: alertFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is DefaultTextStyle,
        ),
      );
      expect(defaultTextStyleFinder, findsOneWidget);
      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        defaultTextStyleFinder,
      );
      expect(defaultTextStyle.style.fontSize, 20);
    });

    testWidgets('follows the ambient text direction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: Alert(
              icon: Icon(Icons.info),
              title: Text('RTL Alert'),
            ),
          ),
        ),
      );

      // The icon leads, so in RTL it is to the right of the title.
      expect(
        tester.getCenter(find.byIcon(Icons.info)).dx,
        greaterThan(tester.getCenter(find.text('RTL Alert')).dx),
      );
    });

    testWidgets('handles null title and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const Alert(icon: Icon(Icons.info))),
      );

      // Check icon renders
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Check no text widgets are present
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('ShardAlert matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Alert(
            icon: Icon(PhosphorIconsRegular.envelopeSimple),
            title: Text('Title'),
            description: Text('Description'),
          ),
        ),
      );

      await expectLater(
        find.byType(Alert),
        matchesGoldenFile('goldens/alert.png'),
      );
    });

    testWidgets('ShardAlert.destructive matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Alert.destructive(
            icon: Icon(PhosphorIconsRegular.envelopeSimple),
            title: Text('Title'),
            description: Text('Description'),
          ),
        ),
      );

      await expectLater(
        find.byType(Alert),
        matchesGoldenFile('goldens/alert_destructive.png'),
      );
    });
  });
}
