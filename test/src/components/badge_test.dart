import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Badge, ThemeData;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/badge.dart'; // Adjust import path based on your project structure
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/style.dart';

void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child, {ThemeData? theme}) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      theme: theme,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Badge', () {
    testWidgets('renders primary variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge(
            child: Text('Primary Badge'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Primary Badge'), findsOneWidget);

      // Check basic layout (Container wraps the content)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      // Check Column contains the child
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);
    });

    testWidgets('renders secondary variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge.secondary(
            child: Text('Secondary Badge'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Secondary Badge'), findsOneWidget);

      // Check basic layout
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('renders outline variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge.outline(
            child: Text('Outline Badge'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Outline Badge'), findsOneWidget);

      // Check basic layout
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('renders destructive variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge.destructive(
            child: Text('Destructive Badge'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Destructive Badge'), findsOneWidget);

      // Check basic layout
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('takes a borderRadius, and is a pill without one', (
      WidgetTester tester,
    ) async {
      const corners = BorderRadius.all(Radius.circular(8));
      await tester.pumpWidget(
        createTestWidget(
          const Badge(borderRadius: corners, child: Text('Square')),
        ),
      );
      ShapeBorder shape() =>
          (tester.widget<Container>(find.byType(Container)).decoration!
                  as ShapeDecoration)
              .shape;
      expect(shape(), isA<RoundedRectangleBorder>());
      expect((shape() as RoundedRectangleBorder).borderRadius, corners);

      await tester.pumpWidget(
        createTestWidget(
          const Badge(child: Text('Pill')),
          theme: ThemeData(style: StyleTokens.nova),
        ),
      );
      expect(shape(), isA<StadiumBorder>());
    });

    testWidgets('an outline badge has the corners of the others', (
      WidgetTester tester,
    ) async {
      ShapeBorder shapeOf(String label) =>
          (tester
                      .widget<Container>(
                        find.ancestor(
                          of: find.text(label),
                          matching: find.byType(Container),
                        ),
                      )
                      .decoration!
                  as ShapeDecoration)
              .shape;
      await tester.pumpWidget(
        createTestWidget(
          const Row(
            children: [
              Badge(child: Text('Primary')),
              Badge.outline(child: Text('Outline')),
            ],
          ),
        ),
      );
      final primary = shapeOf('Primary') as RoundedRectangleBorder;
      final outline = shapeOf('Outline') as RoundedRectangleBorder;
      expect(outline.borderRadius, primary.borderRadius);
      expect(outline.side.style, BorderStyle.solid);
      expect(primary.side, BorderSide.none);
    });

    testWidgets('applies custom background and foreground colors correctly', (
      WidgetTester tester,
    ) async {
      const customBackgroundColor = Colors.blue;
      const customForegroundColor = Colors.yellow;
      await tester.pumpWidget(
        createTestWidget(
          const Badge(
            backgroundColor: customBackgroundColor,
            foregroundColor: customForegroundColor,
            child: Text('Colored Badge'),
          ),
        ),
      );

      // Check Container uses ShapeDecoration with custom background color
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as ShapeDecoration?;
      expect(decoration?.color, customBackgroundColor);

      // Check DefaultTextStyle applies custom foreground color
      final defaultTextStyleFinder = find.descendant(
        of: containerFinder,
        matching: find.byType(DefaultTextStyle),
      );
      expect(defaultTextStyleFinder, findsOneWidget);
      final defaultTextStyle = tester.widget<DefaultTextStyle>(
        defaultTextStyleFinder,
      );
      expect(defaultTextStyle.style.color, customForegroundColor);
    });

    testWidgets('applies custom padding correctly', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.all(10);
      await tester.pumpWidget(
        createTestWidget(
          const Badge(
            padding: customPadding,
            child: Text('Padded Badge'),
          ),
        ),
      );

      // Check Container applies custom padding
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      expect(container.padding, customPadding);
    });

    testWidgets('is a static pill: a pointer over it changes nothing, and it '
        'is not something to press', (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        createTestWidget(const Badge(child: Text('Status'))),
      );

      final containerFinder = find.byType(Container);
      final before =
          (tester.widget<Container>(containerFinder).decoration!
                  as ShapeDecoration)
              .color;

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Status')));
      await tester.pumpAndSettle();

      final after =
          (tester.widget<Container>(containerFinder).decoration!
                  as ShapeDecoration)
              .color;
      expect(after, before);
      // No cursor of its own, no gesture and no button role.
      expect(
        find.descendant(
          of: find.byType(Badge),
          matching: find.byType(MouseRegion),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(Badge),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
      final data = tester.getSemantics(find.text('Status')).getSemanticsData();
      expect(data.label, 'Status');
      expect(data.flagsCollection.isButton, isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('uses default shape when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge(
            child: Text('Default Shape Badge'),
          ),
        ),
      );

      // The una style rounds badges to its `sm` radius (6 at a base of
      // 10) instead of making them pills.
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as ShapeDecoration?;
      expect(
        decoration?.shape,
        isA<RoundedRectangleBorder>().having(
          (s) => s.borderRadius,
          'borderRadius',
          const BorderRadius.all(Radius.circular(6)),
        ),
      );
    });

    testWidgets('the shadcn styles keep the pill shape', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge(child: Text('Pill')),
          theme: ThemeData(style: StyleTokens.nova),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as ShapeDecoration?;
      expect(decoration?.shape, isA<StadiumBorder>());
    });

    testWidgets('a una badge is 24 tall, a nova badge hugs its text', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(const Center(child: Badge(child: Text('New')))),
      );
      // `badgeHeight: 24`; the label's 16px line is centred by the padding.
      expect(tester.getSize(find.byType(Badge)).height, 24);

      await tester.pumpWidget(
        createTestWidget(
          const Center(child: Badge(child: Text('New'))),
          theme: ThemeData(style: StyleTokens.nova),
        ),
      );
      await tester.pumpAndSettle();
      // `py-0.5` around a 16px line.
      expect(tester.getSize(find.byType(Badge)).height, 20);
    });

    testWidgets('Badge matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge(child: Text('Badge')),
        ),
      );

      await expectLater(
        find.byType(Badge),
        matchesGoldenFile('goldens/badge.png'),
      );
    });

    testWidgets('Badge.secondary matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge.secondary(child: Text('Badge')),
        ),
      );

      await expectLater(
        find.byType(Badge),
        matchesGoldenFile('goldens/badge_secondary.png'),
      );
    });

    testWidgets('Badge.outline matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge.outline(child: Text('Badge')),
        ),
      );

      await expectLater(
        find.byType(Badge),
        matchesGoldenFile('goldens/badge_outline.png'),
      );
    });

    testWidgets('Badge.destructive matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Badge.destructive(child: Text('Badge')),
        ),
      );

      await expectLater(
        find.byType(Badge),
        matchesGoldenFile('goldens/badge_destructive.png'),
      );
    });
  });
}
