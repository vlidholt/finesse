import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/accordion.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  /// Wraps a widget with necessary providers and material app structure for
  /// testing.
  Widget createTestWidget(Widget child) {
    return FinesseApp(
      builder: (context, child) => FinesseMaterial(child: child!),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Accordion', () {
    testWidgets('renders single variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Accordion<String>(
            initialValue: 'item1',
            children: const [
              AccordionItem(
                value: 'item1',
                title: Text('Item 1'),
                child: Text('Content 1'),
              ),
              AccordionItem(
                value: 'item2',
                title: Text('Item 2'),
                child: Text('Content 2'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check initial state
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsNothing);

      // Tap to collapse
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(find.text('Content 1'), findsNothing);

      // Tap second item
      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(find.text('Content 2'), findsOneWidget);
    });

    testWidgets('renders multiple variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Accordion.multiple(
            initialValues: const ['item1'],
            children: const [
              AccordionItem(
                value: 'item1',
                title: Text('Item 1'),
                child: Text('Content 1'),
              ),
              AccordionItem(
                value: 'item2',
                title: Text('Item 2'),
                child: Text('Content 2'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check initial state
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsNothing);

      // Expand second item
      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(find.text('Content 1'), findsOneWidget);
      expect(find.text('Content 2'), findsOneWidget);

      // Collapse first item
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(find.text('Content 1'), findsNothing);
      expect(find.text('Content 2'), findsOneWidget);
    });

    /// Tests that custom styles are applied correctly to the accordion item.
    testWidgets('applies custom styles correctly', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(20);
      const customColor = Colors.red;

      await tester.pumpWidget(
        createTestWidget(
          Accordion<String>(
            children: const [
              AccordionItem(
                value: 'item1',
                title: Text('Item 1'),
                padding: customPadding,
                icon: Icon(Icons.star, color: customColor),
                titleStyle: TextStyle(fontSize: 20),
                child: Text('Content 1'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the AccordionItem
      final itemFinder = find.byType(AccordionItem<String>);
      expect(itemFinder, findsOneWidget);

      // Check padding - look for the Padding widget that wraps the Row
      final paddingFinder = find.descendant(
        of: itemFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Padding && widget.padding == customPadding,
        ),
      );
      expect(
        paddingFinder,
        findsOneWidget,
        reason: 'Should find Padding with custom padding',
      );
      final padding = tester.widget<Padding>(paddingFinder);
      expect(padding.padding, customPadding);

      // Check icon color
      final iconFinder = find.descendant(
        of: itemFinder,
        matching: find.byType(Icon),
      );
      expect(iconFinder, findsOneWidget, reason: 'Should find the custom Icon');
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, customColor);

      // Check title style
      final defaultTextStyleFinder = find.descendant(
        of: itemFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is DefaultTextStyle && widget.style.fontSize == 20,
        ),
      );
      expect(
        defaultTextStyleFinder,
        findsOneWidget,
        reason: 'Should find DefaultTextStyle with fontSize 20',
      );
    });

    /// Tests the hover effect on the title, ensuring underline appears when
    /// hovered.
    testWidgets('handles hover effect correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Accordion<String>(
            children: const [
              AccordionItem(
                value: 'item1',
                title: Text('Item 1'),
                underlineTitleOnHover: true,
                child: Text('Content 1'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the AccordionItem
      final itemFinder = find.byType(AccordionItem<String>);
      expect(itemFinder, findsOneWidget);

      // Initial state - no underline
      final textStyleFinder = find.descendant(
        of: itemFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is DefaultTextStyle &&
              widget.child is Text &&
              (widget.child as Text).data == 'Item 1',
        ),
      );
      expect(
        textStyleFinder,
        findsOneWidget,
        reason: 'Should find DefaultTextStyle wrapping title',
      );
      final initialTextStyle = tester.widget<DefaultTextStyle>(textStyleFinder);
      expect(
        initialTextStyle.style.decoration,
        TextDecoration.none,
        reason: 'No underline initially',
      );

      // Simulate hover by entering pointer
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('Item 1')));
      await tester.pumpAndSettle();

      final hoverTextStyle = tester.widget<DefaultTextStyle>(textStyleFinder);
      expect(
        hoverTextStyle.style.decoration,
        TextDecoration.underline,
        reason: 'Underline should appear on hover',
      );

      // Exit hover
      await gesture.moveTo(Offset.infinite);
      await tester.pumpAndSettle();
      final exitTextStyle = tester.widget<DefaultTextStyle>(textStyleFinder);
      expect(
        exitTextStyle.style.decoration,
        TextDecoration.none,
        reason: 'Underline should disappear after hover',
      );
    });

    testWidgets('Accordion matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Accordion<String>(
            children: List.generate(2, (index) {
              return AccordionItem(
                value: 'item$index',
                title: Text('Item $index'),
                child: Text('Content $index'),
              );
            }),
          ),
        ),
      );

      await expectLater(
        find.byType(Accordion<String>),
        matchesGoldenFile('goldens/accordion.png'),
      );
    });
  });

  group('Accordion focus and semantics', () {
    testWidgets('a header is a button that says whether it is expanded', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Accordion<String>(
          children: const [
            AccordionItem(
              value: 'a',
              title: Text('Shipping'),
              child: Text('Content'),
            ),
          ],
        ),
      );
      expect(
        tester.getSemantics(find.text('Shipping')),
        containsSemantics(
          label: 'Shipping',
          isButton: true,
          hasExpandedState: true,
          isExpanded: false,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.text('Shipping'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Shipping')),
        containsSemantics(isButton: true, isExpanded: true),
      );
      handle.dispose();
    });

    testWidgets('a closed item with maintainState is not a Tab stop, takes '
        'no tap and says nothing', (tester) async {
      final handle = tester.ensureSemantics();
      final inner = FocusNode(debugLabel: 'inner');
      addTearDown(inner.dispose);
      var tapped = 0;
      await pumpFinesse(
        tester,
        Accordion<String>(
          maintainState: true,
          children: [
            AccordionItem(
              value: 'a',
              title: const Text('Shipping'),
              child: GestureDetector(
                onTap: () => tapped++,
                child: Focus(focusNode: inner, child: const Text('Content')),
              ),
            ),
            const AccordionItem(
              value: 'b',
              title: Text('Returns'),
              child: Text('More'),
            ),
          ],
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(inner.hasFocus, isFalse, reason: 'Tab $i');
      }
      await tester.tap(
        find.text('Content', skipOffstage: false),
        warnIfMissed: false,
      );
      expect(tapped, 0);
      expect(find.bySemanticsLabel('Content'), findsNothing);

      // Open, the content is there to use again.
      await tester.tap(find.text('Shipping'));
      await tester.pumpAndSettle();
      inner.requestFocus();
      await tester.pump();
      expect(inner.hasFocus, isTrue);
      await tester.tap(find.text('Content'));
      expect(tapped, 1);
      handle.dispose();
    });
  });
}
