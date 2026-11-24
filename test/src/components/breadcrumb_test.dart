import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/breadcrumb.dart';
import 'package:finesse/src/components/button.dart';
import 'package:finesse/src/theme/components/breadcrumb.dart';
import 'package:finesse/src/theme/data.dart';
import 'package:flutter/material.dart' hide ThemeData;
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  // Helper method to create a test widget wrapped in FinesseApp and Scaffold
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Breadcrumb', () {
    testWidgets('renders basic breadcrumb correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: const Breadcrumb(
              children: [
                Text('Home'),
                Text('Library'),
                Text('Data'),
              ],
            ),
          ),
        ),
      );

      // Check if all breadcrumb items render
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);

      // Check basic layout (Wrap should contain the children and separators)
      final wrapFinder = find.byType(Wrap);
      expect(wrapFinder, findsOneWidget);

      // Should have 2 separators between 3 items (chevron icons)
      final iconFinder = find.byIcon(LucideIcons.chevronRight);
      expect(iconFinder, findsNWidgets(2));
    });

    testWidgets('renders with custom separator', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: const Breadcrumb(
              separator: Icon(Icons.arrow_forward_ios),
              children: [
                Text('Home'),
                Text('Library'),
              ],
            ),
          ),
        ),
      );

      // Check if custom separator is used
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronRight), findsNothing);
    });

    testWidgets('renders breadcrumb links correctly', (
      WidgetTester tester,
    ) async {
      var homeTapped = false;
      var libraryTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: Breadcrumb(
              children: [
                BreadcrumbLink(
                  onPressed: () => homeTapped = true,
                  child: const Text('Home'),
                ),
                BreadcrumbLink(
                  onPressed: () => libraryTapped = true,
                  child: const Text('Library'),
                ),
                const Text('Current'),
              ],
            ),
          ),
        ),
      );

      // Test tapping links
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(homeTapped, true);

      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(libraryTapped, true);
    });

    testWidgets('renders ellipsis correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: const Breadcrumb(
              children: [
                Text('Home'),
                BreadcrumbEllipsis(),
                Text('Library'),
                Text('Current'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BreadcrumbEllipsis), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
    });

    testWidgets('handles text direction correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: const Breadcrumb(
              textDirection: TextDirection.rtl,
              children: [
                Text('Home'),
                Text('Library'),
              ],
            ),
          ),
        ),
      );

      // Check Wrap reflects RTL text direction
      final wrapFinder = find.byType(Wrap);
      expect(wrapFinder, findsOneWidget);
      final wrap = tester.widget<Wrap>(wrapFinder);
      expect(wrap.textDirection, TextDirection.rtl);
    });
  });

  group('BreadcrumbLink', () {
    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: BreadcrumbLink(
              onPressed: () => wasTapped = true,
              child: const Text('Clickable'),
            ),
          ),
        ),
      );

      expect(find.text('Clickable'), findsOneWidget);

      await tester.tap(find.text('Clickable'));
      await tester.pump();

      expect(wasTapped, true);
    });

    testWidgets('handles hover correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          FinesseApp(
            builder: (context, child) => FinesseMaterial(child: child!),
            home: BreadcrumbLink(
              onPressed: () {},
              child: const Text('Hoverable'),
            ),
          ),
        ),
      );

      expect(find.text('Hoverable'), findsOneWidget);
      final button = find.widgetWithText(Button, 'Hoverable');
      expect(
        find.descendant(of: button, matching: find.byType(MouseRegion)),
        findsOneWidget,
      );
    });
  });

  group('BreadcrumbSeparator', () {
    testWidgets('renders default separator correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const BreadcrumbSeparator(),
        ),
      );

      expect(find.byType(BreadcrumbSeparator), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronRight), findsOneWidget);
    });
  });

  group('BreadcrumbEllipsis', () {
    testWidgets('renders default ellipsis correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const BreadcrumbEllipsis(),
        ),
      );

      expect(find.byType(BreadcrumbEllipsis), findsOneWidget);
      expect(find.byIcon(LucideIcons.ellipsis), findsOneWidget);
    });
  });

  group('BreadcrumbDropdown', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Item 1')),
              ],
              child: Text('Dropdown'),
            ),
          ),
        ),
      );

      expect(find.text('Dropdown'), findsOneWidget);
    });

    testWidgets('displays chevron down icon', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Item 1')),
              ],
              child: Text('Dropdown'),
            ),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);
    });

    testWidgets('shows popover when clicked', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Item 1')),
                BreadcrumbDropMenuItem(child: Text('Item 2')),
              ],
              child: Text('Dropdown'),
            ),
          ),
        ),
      );

      // Initially, dropdown items should not be visible
      expect(find.text('Item 1'), findsNothing);
      expect(find.text('Item 2'), findsNothing);

      // Tap to open dropdown
      await tester.tap(find.text('Dropdown'));
      await tester.pumpAndSettle();

      // Dropdown items should now be visible
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    testWidgets('hides popover when clicked again', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Item 1')),
              ],
              child: Text('Dropdown'),
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Dropdown'));
      await tester.pumpAndSettle();
      expect(find.text('Item 1'), findsOneWidget);

      // Close dropdown
      await tester.tap(find.text('Dropdown'));
      await tester.pumpAndSettle();
      expect(find.text('Item 1'), findsNothing);
    });

    testWidgets('displays multiple dropdown items', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Components')),
                BreadcrumbDropMenuItem(child: Text('Documentation')),
                BreadcrumbDropMenuItem(child: Text('Themes')),
              ],
              child: Text('More'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Components'), findsOneWidget);
      expect(find.text('Documentation'), findsOneWidget);
      expect(find.text('Themes'), findsOneWidget);
    });

    testWidgets('respects theme spacing', (tester) async {
      const testSpacing = 10.0;

      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          theme: ThemeData(
            brightness: Brightness.light,
            breadcrumbTheme: const BreadcrumbTheme(
              spacing: testSpacing,
            ),
          ),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Item 1')),
              ],
              child: Text('Dropdown'),
            ),
          ),
        ),
      );

      // Verify the widget builds without error
      expect(find.text('Dropdown'), findsOneWidget);
    });

    testWidgets('controller is disposed properly', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(child: Text('Item 1')),
              ],
              child: Text('Dropdown'),
            ),
          ),
        ),
      );

      // Remove the widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // If we get here without errors, disposal worked correctly
      expect(find.byType(BreadcrumbDropdown), findsNothing);
    });
  });

  group('BreadcrumbDropMenuItem', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropMenuItem(
              child: Text('Menu Item'),
            ),
          ),
        ),
      );

      expect(find.text('Menu Item'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: Scaffold(
            body: BreadcrumbDropMenuItem(
              onPressed: () => wasPressed = true,
              child: const Text('Clickable Item'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clickable Item'));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('does not call onPressed when null', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropMenuItem(
              child: Text('Non-clickable Item'),
            ),
          ),
        ),
      );

      // Should not throw error when tapped with null onPressed
      await tester.tap(find.text('Non-clickable Item'));
      await tester.pumpAndSettle();

      expect(find.text('Non-clickable Item'), findsOneWidget);
    });

    testWidgets('applies default padding', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropMenuItem(
              child: Text('Item'),
            ),
          ),
        ),
      );

      final button = tester.widget<Button>(find.byType(Button));
      expect(
        button.padding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.all(12);

      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropMenuItem(
              itemPadding: customPadding,
              child: Text('Item'),
            ),
          ),
        ),
      );

      final button = tester.widget<Button>(find.byType(Button));
      expect(button.padding, customPadding);
    });

    testWidgets('uses ghost button variant', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropMenuItem(
              child: Text('Item'),
            ),
          ),
        ),
      );

      final button = tester.widget<Button>(find.byType(Button));
      expect(button.variant, ButtonVariant.ghost);
    });

    testWidgets('renders complex child widget', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropMenuItem(
              child: Row(
                children: [
                  Icon(Icons.home),
                  SizedBox(width: 8),
                  Text('Home'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('BreadcrumbDropdown integration', () {
    testWidgets('dropdown items respond to tap', (tester) async {
      var selectedItem = '';

      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: Scaffold(
            body: BreadcrumbDropdown(
              items: [
                BreadcrumbDropMenuItem(
                  onPressed: () => selectedItem = 'Item 1',
                  child: const Text('Item 1'),
                ),
                BreadcrumbDropMenuItem(
                  onPressed: () => selectedItem = 'Item 2',
                  child: const Text('Item 2'),
                ),
              ],
              child: const Text('Select'),
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Tap an item
      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();

      expect(selectedItem, 'Item 2');
    });

    testWidgets('works with empty children list', (tester) async {
      await tester.pumpWidget(
        FinesseApp(
          builder: (context, child) => FinesseMaterial(child: child!),
          home: const Scaffold(
            body: BreadcrumbDropdown(
              items: [],
              child: Text('Empty'),
            ),
          ),
        ),
      );

      expect(find.text('Empty'), findsOneWidget);

      // Should be able to toggle even with no items
      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();
    });
  });
}
