import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/badge.dart'; // Adjust import path based on your project structure
import 'package:finesse/src/theme/data.dart';
import 'package:finesse/src/theme/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Badge, ThemeData;
import 'package:flutter_test/flutter_test.dart';

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

    testWidgets('applies custom shape correctly', (WidgetTester tester) async {
      const customShape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );
      await tester.pumpWidget(
        createTestWidget(
          const Badge(
            shape: customShape,
            child: Text('Custom Shape Badge'),
          ),
        ),
      );

      // Check Container uses ShapeDecoration with custom shape
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as ShapeDecoration?;
      expect(decoration?.shape, customShape);
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

    testWidgets('changes background color on hover', (
      WidgetTester tester,
    ) async {
      const customHoverBackgroundColor = Colors.red;
      await tester.pumpWidget(
        createTestWidget(
          const Badge(
            hoverBackgroundColor: customHoverBackgroundColor,
            child: Text('Hover Badge'),
          ),
        ),
      );

      // Initially, hover background shouldn’t apply
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);
      var container = tester.widget<Container>(containerFinder);
      var decoration = container.decoration as ShapeDecoration?;
      expect(decoration?.color, isNot(customHoverBackgroundColor));

      // Simulate hover
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.text('Hover Badge'))),
      );
      await tester.pumpAndSettle();

      // Check hover background color applies
      container = tester.widget<Container>(containerFinder);
      decoration = container.decoration as ShapeDecoration?;
      expect(decoration?.color, customHoverBackgroundColor);
    });

    testWidgets('executes onPressed callback on tap', (
      WidgetTester tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          Badge(
            child: const Text('Press Me'),
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Tap the badge
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();

      // Verify onPressed was called
      expect(pressed, true);
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

      // The finesse style rounds badges to its `sm` radius (6 at a base of
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

    testWidgets('a finesse badge is 24 tall, a nova badge hugs its text', (
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
