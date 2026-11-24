import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/card.dart'; // Adjust import path based on your project structure
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/material.dart' hide Card, Theme, ThemeData;
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child, {ThemeData? theme}) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      theme: theme,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Card', () {
    testWidgets('renders basic content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            title: Text('Card Title'),
            description: Text('Card Description'),
            footer: Text('Card Footer'),
            child: Text('Card Content'),
          ),
        ),
      );

      // Check if all content widgets are rendered
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card Description'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
      expect(find.text('Card Footer'), findsOneWidget);

      // Check basic layout (Container with Row). The card is an outer Row —
      // leading, content, trailing — wrapping a Column, and the title and
      // description sit in a header Row of their own inside that Column.
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      expect(find.byType(Row), findsNWidgets(2));
      expect(find.byType(Column), findsNWidgets(2));
    });

    testWidgets('renders with leading and trailing widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Main Content'),
          ),
        ),
      );

      // Check if leading, child, and trailing are rendered
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Main Content'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

      // Check layout includes all three in a Row
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      expect(
        find.descendant(of: rowFinder, matching: find.byType(Icon)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: rowFinder, matching: find.text('Main Content')),
        findsOneWidget,
      );
    });

    testWidgets('applies custom padding correctly', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.all(40);
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            padding: customPadding,
            child: Text('Padded Card'),
          ),
        ),
      );

      // Check Container applies custom padding
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      expect(container.padding, customPadding);
    });

    testWidgets('applies custom background color and radius correctly', (
      WidgetTester tester,
    ) async {
      const customBackgroundColor = Colors.blue;
      const customRadius = BorderRadius.all(Radius.circular(12));
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            backgroundColor: customBackgroundColor,
            radius: customRadius,
            child: Text('Styled Card'),
          ),
        ),
      );

      // Check Container applies custom background color and radius
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = boxDecorationOf(container.decoration);
      expect(decoration?.color, customBackgroundColor);
      expect(decoration?.borderRadius, customRadius);
    });

    testWidgets('applies custom width and height correctly', (
      WidgetTester tester,
    ) async {
      const customWidth = 300.0;
      const customHeight = 200.0;
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            width: customWidth,
            height: customHeight,
            child: Text('Sized Card'),
          ),
        ),
      );

      // Check Container applies custom width and height
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      expect(container.constraints?.maxWidth, customWidth);
      expect(container.constraints?.maxHeight, customHeight);
    });

    testWidgets('handles row alignment correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            rowMainAxisAlignment: MainAxisAlignment.center,
            rowCrossAxisAlignment: CrossAxisAlignment.center,
            child: Text('Aligned Card'),
          ),
        ),
      );

      // Check Row applies custom alignments
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final row = tester.widget<Row>(rowFinder.first);
      expect(row.mainAxisAlignment, MainAxisAlignment.center);
      expect(row.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('handles column alignment correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            title: Text('Title'),
            description: Text('Description'),
            columnMainAxisAlignment: MainAxisAlignment.center,
            columnCrossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
      );

      // The outer Column is the card's content stack; the inner one holds the
      // title and description inside the header row.
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);

      final header = tester.widget<Column>(find.byType(Column).last);
      expect(header.crossAxisAlignment, CrossAxisAlignment.center);
    });

    testWidgets('renders without optional content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            child: Text('Minimal Card'),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing); // No leading
      expect(find.text('Title'), findsNothing); // No title
      expect(find.text('Footer'), findsNothing); // No footer
    });

    testWidgets('applies default theme styles when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            child: Text('Default Styled Card'),
          ),
        ),
      );

      // Check Container uses default padding and theme styles
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = boxDecorationOf(container.decoration);
      // The default style is finesse: 20 of padding around a card colour
      // washed to 88%, which is what lets the backdrop blur show through.
      final theme = Theme.of(tester.element(containerFinder));
      expect(container.padding, const EdgeInsets.all(20));
      expect(
        decoration?.color,
        theme.colorScheme.card.withValues(alpha: .88),
      );
      expect(decoration?.color, theme.cardTheme.backgroundColor);
      expect(
        decoration?.borderRadius,
        Theme.of(tester.element(containerFinder)).cardTheme.radius,
      );
      expect(decoration?.border, isNotNull);
    });

    testWidgets('nova keeps the shadcn card: opaque, --spacing(4) padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(child: Text('Nova card')),
          theme: ThemeData(style: StyleTokens.nova),
        ),
      );

      final containerFinder = find.byType(Container);
      final container = tester.widget<Container>(containerFinder);
      final decoration = boxDecorationOf(container.decoration);
      expect(container.padding, const EdgeInsets.all(16));
      expect(
        decoration?.color,
        Theme.of(tester.element(containerFinder)).colorScheme.card,
      );
    });

    testWidgets('Card matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Card(
            title: Text('title'),
            description: Text('description'),
            footer: Text('footer'),
            leading: Text('leading'),
            trailing: Text('trailing'),
            child: Text('content'),
          ),
        ),
      );

      await expectLater(
        find.byType(Card),
        matchesGoldenFile('goldens/card.png'),
      );
    });
  });
}
