import 'package:flutter/material.dart' hide Checkbox;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/checkbox.dart'; // Adjust import path based on your project structure
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/disabled.dart';
import 'package:una/src/utils/pop_in.dart';

void main() {
  // Helper method to create a test widget wrapped in UnaApp and Scaffold
  Widget createTestWidget(Widget child) {
    return UnaApp(
      builder: (context, child) => UnaMaterial(child: child!),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Checkbox', () {
    testWidgets('renders unchecked state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: false,
          ),
        ),
      );

      // Check no icon (unchecked state) inside PopIn
      final animatedSwitcherFinder = find.byType(PopIn);
      expect(animatedSwitcherFinder, findsOneWidget);
      expect(
        find.descendant(
          of: animatedSwitcherFinder,
          matching: find.bySubtype<Icon>(),
        ),
        findsNothing,
      );

      // A bare box has no row around it: there is no label to lay out.
      expect(find.byType(Row), findsNothing);
    });

    testWidgets('renders checked state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: true,
          ),
        ),
      );

      // Check icon is present (checked state) inside PopIn
      final animatedSwitcherFinder = find.byType(PopIn);
      expect(animatedSwitcherFinder, findsOneWidget);
      expect(
        find.descendant(
          of: animatedSwitcherFinder,
          matching: find.bySubtype<Icon>(),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders with label and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: false,
            label: Text('Checkbox Label'),
            description: Text('Checkbox Sublabel'),
          ),
        ),
      );

      // Check label and description are rendered
      expect(find.text('Checkbox Label'), findsOneWidget);
      expect(find.text('Checkbox Sublabel'), findsOneWidget);

      // Check layout includes checkbox, label, and description in a Row and
      // Column
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final columnFinder = find.descendant(
        of: rowFinder,
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);
      expect(
        find.descendant(of: columnFinder, matching: find.byType(Text)),
        findsNWidgets(2),
      );
    });

    testWidgets('toggles state on tap', (WidgetTester tester) async {
      var value = false;
      await tester.pumpWidget(
        createTestWidget(
          Checkbox(
            value: value,
            onChanged: (newValue) => value = newValue,
            key: ValueKey(value), // Force rebuild on value change
          ),
        ),
      );

      // Initially unchecked
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.bySubtype<Icon>(),
        ),
        findsNothing,
        reason: 'Initially unchecked, no icon should be present',
      );

      // Tap to toggle
      await tester.tap(find.byType(Checkbox));
      await tester.pumpWidget(
        // Rebuild with new state
        createTestWidget(
          Checkbox(
            value: true,
            onChanged: (newValue) => value = newValue,
            key: const ValueKey(true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify state changed to checked
      expect(value, true, reason: 'Value should toggle to true after tap');
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.bySubtype<Icon>(),
        ),
        findsOneWidget,
        reason: '''Checked state should show the checkmark icon within PopIn''',
      );

      // Tap again to toggle back
      await tester.tap(find.byType(Checkbox));
      await tester.pumpWidget(
        // Rebuild with new state
        createTestWidget(
          Checkbox(
            value: false,
            onChanged: (newValue) => value = newValue,
            key: const ValueKey(false),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify state changed to unchecked
      expect(
        value,
        false,
        reason: 'Value should toggle back to false after second tap',
      );
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.bySubtype<Icon>(),
        ),
        findsNothing,
        reason: 'Unchecked state should hide the icon',
      );
    });

    testWidgets('handles disabled state correctly', (
      WidgetTester tester,
    ) async {
      var value = false;
      await tester.pumpWidget(
        createTestWidget(
          Checkbox(
            value: value,
            enabled: false,
            onChanged: (newValue) => value = newValue,
          ),
        ),
      );

      // Attempt to tap the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Verify onChanged was not called (still false)
      expect(value, false);

      // Check Disabled is applied with absorbing pointer events
      final disabledFinder = find.byType(Disabled);
      expect(
        disabledFinder,
        findsNWidgets(2),
      ); // One for checkbox, one for outer wrapper
      final innerDisabled = tester.widget<Disabled>(disabledFinder.first);
      expect(innerDisabled.enabled, isFalse);
    });

    testWidgets('applies custom size correctly', (WidgetTester tester) async {
      const customSize = 24.0;
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: true,
            size: customSize,
          ),
        ),
      );

      // Check SizedBox applies custom size (target the one wrapping
      // PopIn)
      final sizedBoxFinder = find.descendant(
        of: find.byType(Checkbox),
        matching: find.ancestor(
          of: find.byType(PopIn),
          matching: find.byType(SizedBox),
        ),
      );
      expect(sizedBoxFinder, findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);

      // Check icon follows the custom size: shadcn's `[&>svg]:size-3.5` puts
      // the glyph 2px inside its box.
      final iconFinder = find.bySubtype<Icon>();
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.size, customSize - 2);
    });

    testWidgets('applies custom color correctly', (WidgetTester tester) async {
      const customColor = Colors.red;
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: true,
            color: customColor,
          ),
        ),
      );

      // Check Decorator applies custom color when checked
      final decoratorFinder = find.byType(Decorator);
      expect(decoratorFinder, findsOneWidget);
      final decorator = tester.widget<Decorator>(decoratorFinder);
      expect(decorator.decoration?.color, customColor);
    });

    testWidgets('applies custom padding correctly', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.all(16);
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: false,
            label: Text('Label'),
            padding: customPadding,
          ),
        ),
      );

      // Check Padding between checkbox and label applies custom padding
      final paddingFinder = find.descendant(
        of: find.byType(Row),
        matching: find.ancestor(
          of: find.byType(Column), // Target the Column with label/description
          matching: find.byType(Padding),
        ),
      );
      expect(paddingFinder, findsOneWidget);
      final padding = tester.widget<Padding>(paddingFinder);
      expect(padding.padding, customPadding);
    });

    testWidgets('handles focus correctly', (WidgetTester tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        createTestWidget(
          Checkbox(
            value: false,
            focusNode: focusNode,
          ),
        ),
      );

      // Focus the checkbox
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Verify focus is applied
      expect(focusNode.hasFocus, true);

      // Check Decorator reflects focused state
      final decoratorFinder = find.byType(Decorator);
      expect(decoratorFinder, findsOneWidget);
      final decorator = tester.widget<Decorator>(decoratorFinder);
      expect(decorator.focused, true);
    });

    testWidgets('renders without label and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: false,
          ),
        ),
      );

      // Check only checkbox is rendered (no label/description)
      expect(find.byType(Row), findsNothing);
      expect(
        find.byType(Column),
        findsNothing,
      ); // No Column for label/description
      expect(find.text('Label'), findsNothing);
    });

    testWidgets('Checkbox on matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: true,
            icon: Icon(Icons.air_rounded),
            label: Text('Label'),
            description: Text('Sublabel'),
          ),
        ),
      );

      await expectLater(
        find.byType(Checkbox),
        matchesGoldenFile('goldens/checkbox_on.png'),
      );
    });

    testWidgets('Checkbox off matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Checkbox(
            value: false,
            icon: Icon(Icons.air_rounded),
            label: Text('Label'),
            description: Text('Sublabel'),
          ),
        ),
      );

      await expectLater(
        find.byType(Checkbox),
        matchesGoldenFile('goldens/checkbox_off.png'),
      );
    });
  });
}
