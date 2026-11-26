import 'package:flutter/material.dart' hide Radio;
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/disabled.dart';
import 'package:una/src/components/radio.dart';
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

  group('UnaRadioGroup and Radio', () {
    testWidgets('renders with no initial selection correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            items: [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );

      // Check both radios are rendered (use a more specific finder)
      final radioFinder = find.byWidgetPredicate(
        (widget) => widget is Radio<String>,
        description: 'Radio<String>',
      );
      expect(
        radioFinder,
        findsNWidgets(2),
        reason: 'Should find 2 Radio<String> widgets',
      );

      // Check label texts are present
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);

      // Check no radio is selected (no filled circles)
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
        reason: 'No radio should be selected initially',
      );

      // Check Wrap layout
      final wrapFinder = find.byType(Wrap);
      expect(wrapFinder, findsOneWidget);
    });

    testWidgets('renders with initial selection correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            initialValue: 'option1',
            items: [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );

      // Check one radio is selected (filled circle)
      final animatedSwitcherFinder = find.byType(PopIn);
      expect(animatedSwitcherFinder, findsNWidgets(2));
      expect(
        find.descendant(
          of: animatedSwitcherFinder,
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('toggles selection on tap', (WidgetTester tester) async {
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          UnaRadioGroup<String>(
            onChanged: (value) => selectedValue = value,
            items: const [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );

      // Initially no selection
      expect(selectedValue, isNull);
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
      );

      // Tap first option
      await tester.tap(find.text('Option 1'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify selection changed
      expect(selectedValue, 'option1');
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );

      // Tap second option
      await tester.tap(find.text('Option 2'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      // Verify selection changed again
      expect(selectedValue, 'option2');
    });

    testWidgets('handles disabled state correctly', (
      WidgetTester tester,
    ) async {
      String? selectedValue;
      await tester.pumpWidget(
        createTestWidget(
          UnaRadioGroup<String>(
            enabled: false,
            onChanged: (value) => selectedValue = value,
            items: const [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );

      // Attempt to tap the Radio widget instead of the Text
      final radioFinder = find.byWidgetPredicate(
        (widget) => widget is Radio<String> && widget.value == 'option1',
        description: 'Radio with value "option1"',
      );
      expect(
        radioFinder,
        findsOneWidget,
        reason: 'Should find the first Radio',
      );
      await tester.tap(radioFinder);
      await tester.pumpAndSettle();

      // Verify no selection change
      expect(
        selectedValue,
        isNull,
        reason: 'Selection should not change when disabled',
      );

      // Check Disabled is applied
      final disabledFinder = find.byType(Disabled);
      expect(
        disabledFinder,
        findsWidgets,
        reason: 'Disabled should be present in the tree',
      );

      // Optional: Verify the GestureDetector is disabled
      final gestureFinder = find.descendant(
        of: radioFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is GestureDetector && widget.onTap == null,
          description: 'Disabled GestureDetector',
        ),
      );
      expect(
        gestureFinder,
        findsOneWidget,
        reason: 'GestureDetector should have no onTap callback when disabled',
      );
    });

    testWidgets('applies custom size correctly', (WidgetTester tester) async {
      const customSize = 24.0;
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            items: [
              Radio(
                value: 'option1',
                label: Text('Option 1'),
                size: customSize,
              ),
            ],
          ),
        ),
      );

      // Verify Radio is rendered
      final radioFinder = find.byWidgetPredicate(
        (widget) => widget is Radio<String>,
        description: 'Radio<String>',
      );
      expect(
        radioFinder,
        findsOneWidget,
        reason: 'Radio should be rendered in the group',
      );

      // Check SizedBox applies custom size
      final sizedBoxFinder = find.descendant(
        of: radioFinder,
        matching: find.ancestor(
          of: find.byType(PopIn),
          matching: find.byType(SizedBox),
        ),
      );
      expect(
        sizedBoxFinder,
        findsOneWidget,
        reason: 'Should find a SizedBox wrapping PopIn in Radio',
      );
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(
        sizedBox.width,
        customSize,
        reason: 'Width should match customSize',
      );
      expect(
        sizedBox.height,
        customSize,
        reason: 'Height should match customSize',
      );
    });

    testWidgets('applies custom color correctly', (WidgetTester tester) async {
      const customColor = Colors.red;
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            initialValue: 'option1',
            items: [
              Radio(
                value: 'option1',
                label: Text('Option 1'),
                color: customColor,
              ),
            ],
          ),
        ),
      );

      // Check DecoratedBox applies custom color when selected
      final decoratedBoxFinder = find.descendant(
        of: find.byType(PopIn),
        matching: find.byType(DecoratedBox),
      );
      expect(decoratedBoxFinder, findsOneWidget);
      final decoratedBox =
          tester.widget<DecoratedBox>(decoratedBoxFinder).decoration
              as BoxDecoration;
      expect(decoratedBox.color, customColor);
    });

    testWidgets('applies custom spacing correctly', (
      WidgetTester tester,
    ) async {
      const customSpacing = 16.0;
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            spacing: customSpacing,
            items: [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );

      // Check Wrap applies custom spacing
      final wrapFinder = find.byType(Wrap);
      expect(wrapFinder, findsOneWidget);
      final wrap = tester.widget<Wrap>(wrapFinder);
      expect(wrap.spacing, customSpacing);
    });

    testWidgets('handles focus correctly', (WidgetTester tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        createTestWidget(
          UnaRadioGroup<String>(
            onChanged: _ignore,
            items: [
              Radio(
                value: 'option1',
                label: const Text('Option 1'),
                focusNode: focusNode,
              ),
            ],
          ),
        ),
      );

      // Focus the radio
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

    testWidgets('renders with label and description', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            items: [
              Radio(
                value: 'option1',
                label: Text('Option 1'),
                description: Text('Sublabel'),
              ),
            ],
          ),
        ),
      );

      // Check label and description are rendered
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Sublabel'), findsOneWidget);

      // Check layout includes radio, label, and description
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final columnFinder = find.descendant(
        of: rowFinder,
        matching: find.byType(Column),
      );
      expect(columnFinder, findsOneWidget);
    });

    testWidgets('updates initialValue correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            key: ValueKey('initial'),
            initialValue: 'option1',
            items: [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );

      // Check initial selection
      expect(
        find.descendant(
          of: find.byType(PopIn),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );

      // Update with new initialValue
      await tester.pumpWidget(
        createTestWidget(
          const UnaRadioGroup<String>(
            onChanged: _ignore,
            key: ValueKey('updated'),
            initialValue: 'option2',
            items: [
              Radio(value: 'option1', label: Text('Option 1')),
              Radio(value: 'option2', label: Text('Option 2')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify selection updated (count DecoratedBox instances)
      final decoratedBoxFinder = find.descendant(
        of: find.byType(PopIn),
        matching: find.byType(DecoratedBox),
      );
      expect(decoratedBoxFinder, findsOneWidget);
    });

    testWidgets('Radio matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          UnaRadioGroup<bool>(
            onChanged: _ignore,
            items: List.generate(
              3,
              (index) => Radio<bool>(
                value: index.isEven,
                label: Text('Label $index'),
                description: Text('Sublabel $index'),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(UnaRadioGroup<bool>),
        matchesGoldenFile('goldens/radio.png'),
      );
    });
  });
}

/// A callback for a group that is enabled but whose choices nobody reads.
void _ignore(Object? _) {}
