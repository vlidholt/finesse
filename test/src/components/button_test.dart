import 'package:finesse/material.dart';
import 'package:finesse/src/app.dart';
import 'package:finesse/src/components/button.dart'; // Adjust import path based on your project structure
import 'package:finesse/src/theme/components/decorator.dart';
import 'package:finesse/src/theme/theme.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_test/flutter_test.dart';

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

  group('Button', () {
    testWidgets('an expanding button keeps a Flexible child as it is', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 120,
            child: Button(
              width: double.infinity,
              expands: true,
              child: Flexible(
                child: Text(
                  'A label far too long for the button',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Expanded), findsNothing);
    });

    testWidgets('renders primary variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button(
            child: Text('Primary Button'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Primary Button'), findsOneWidget);

      // Check basic layout (Row should contain the child)
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);

      // Verify the button is enabled by default
      expect(find.byType(Button), findsOneWidget);
      final button = tester.widget<Button>(find.byType(Button));
      expect(button.enabled, true);
    });

    testWidgets('renders destructive variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.destructive(
            child: Text('Destructive Button'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Destructive Button'), findsOneWidget);

      // Check basic layout
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders outline variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.outline(
            child: Text('Outline Button'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Outline Button'), findsOneWidget);

      // Check basic layout
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders secondary variant correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.secondary(
            child: Text('Secondary Button'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Secondary Button'), findsOneWidget);

      // Check basic layout
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders ghost variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.ghost(
            child: Text('Ghost Button'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Ghost Button'), findsOneWidget);

      // Check basic layout
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders link variant correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.link(
            child: Text('Link Button'),
          ),
        ),
      );

      // Check if the child content renders
      expect(find.text('Link Button'), findsOneWidget);

      // Check basic layout (no leading/trailing, so just the child)
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders with leading and trailing widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button with Icons'),
          ),
        ),
      );

      // Check if all components render
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Button with Icons'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

      // Check layout includes all three widgets in a Row
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      expect(
        find.descendant(of: rowFinder, matching: find.byType(Icon)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: rowFinder,
          matching: find.text('Button with Icons'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('applies custom styles correctly', (WidgetTester tester) async {
      const customBackgroundColor = Colors.blue;
      const customPadding = EdgeInsets.all(20);
      const customWidth = 200.0;

      await tester.pumpWidget(
        createTestWidget(
          const Button(
            backgroundColor: customBackgroundColor,
            padding: customPadding,
            width: customWidth,
            child: Text('Styled Button'),
          ),
        ),
      );

      // Find the Button widget
      final buttonFinder = find.byType(Button);
      expect(buttonFinder, findsOneWidget);

      // Find the ConstrainedBox that applies width constraints
      final constrainedBoxFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final constrainedBox = tester.widget<ConstrainedBox>(
        constrainedBoxFinder,
      );
      expect(constrainedBox.constraints.minWidth, customWidth);

      // The content padding is the nearest Padding above the label. The
      // decorator sits inside the ConstrainedBox (the button's size is
      // border-box), so matching every Padding under it would also catch the
      // decorator's own zero-padding wrappers.
      final paddingFinder = find
          .ancestor(
            of: find.text('Styled Button'),
            matching: find.byType(Padding),
          )
          .first;
      final padding = tester.widget<Padding>(paddingFinder);
      expect(padding.padding, customPadding);

      // Find the Decorator and check background color
      final decoratorFinder = find.descendant(
        of: buttonFinder,
        matching: find.byType(Decorator),
      );
      expect(decoratorFinder, findsOneWidget);
      final decorator = tester.widget<Decorator>(decoratorFinder);
      expect(decorator.decoration?.color, customBackgroundColor);
    });

    testWidgets('handles disabled state correctly', (
      WidgetTester tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          Button(
            enabled: false,
            onPressed: () => pressed = true,
            child: const Text('Disabled Button'),
          ),
        ),
      );

      // Verify the button renders
      expect(find.text('Disabled Button'), findsOneWidget);

      // Verify onPressed isn’t callable without tapping (since it’s disabled)
      expect(pressed, false);

      // Check opacity is reduced for disabled state
      final opacityFinder = find.descendant(
        of: find.byType(Button),
        matching: find.byType(Opacity),
      );
      expect(opacityFinder, findsOneWidget);
      final opacity = tester.widget<Opacity>(opacityFinder);
      expect(opacity.opacity, 0.5);

      // Verify AbsorbPointer is present and absorbing events
      final absorbPointerFinder = find.descendant(
        of: find.byType(Button),
        matching: find.byType(AbsorbPointer),
      );
      expect(absorbPointerFinder, findsOneWidget);
      final absorbPointer = tester.widget<AbsorbPointer>(absorbPointerFinder);
      expect(absorbPointer.absorbing, true);
    });

    testWidgets('handles focus correctly', (WidgetTester tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        createTestWidget(
          Button(
            focusNode: focusNode,
            child: const Text('Focusable Button'),
          ),
        ),
      );

      // Focus the button
      focusNode.requestFocus();
      await tester.pumpAndSettle();

      // Verify the button is focused
      expect(focusNode.hasFocus, true);

      // Check that Decorator reflects the focused state
      final decoratorFinder = find.descendant(
        of: find.byType(Button),
        matching: find.byType(Decorator),
      );
      expect(decoratorFinder, findsOneWidget);
      final decorator = tester.widget<Decorator>(decoratorFinder);
      expect(decorator.focused, true);
    });

    testWidgets('handles text direction correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button(
            textDirection: TextDirection.rtl,
            leading: Icon(Icons.arrow_back),
            trailing: Icon(Icons.arrow_forward),
            child: Text('RTL Button'),
          ),
        ),
      );

      // Check Row reflects RTL text direction
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final row = tester.widget<Row>(rowFinder);
      expect(row.textDirection, TextDirection.rtl);

      expect(row.children.elementAt(0), isA<Icon>()); // trailing
      expect(row.children.elementAt(1), isA<SizedBox>()); // space
      expect(row.children.elementAt(2), isA<Text>()); // child
      expect(row.children.elementAt(3), isA<SizedBox>()); // space
      expect(row.children.elementAt(4), isA<Icon>()); // leading
    });

    testWidgets('handles size variations correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button(
            size: ButtonSize.lg,
            child: Text('Large Button'),
          ),
        ),
      );

      // Verify the button renders with large size
      final constrainedBoxFinder = find.descendant(
        of: find.byType(Button),
        matching: find.byType(ConstrainedBox),
      );
      expect(constrainedBoxFinder, findsOneWidget);
      final constrainedBox = tester.widget<ConstrainedBox>(
        constrainedBoxFinder,
      );
      final theme = Theme.of(tester.element(find.byType(Button)));
      expect(
        constrainedBox.constraints.minHeight,
        theme.buttonSizesTheme.lg?.height,
      );
    });

    testWidgets('executes onPressed callback on tap', (
      WidgetTester tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          Button(
            child: const Text('Press Me'),
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.text('Press Me'));
      await tester.pumpAndSettle();

      // Verify onPressed was called
      expect(pressed, true);
    });

    testWidgets('Button matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button'),
          ),
        ),
      );

      await expectLater(
        find.byType(Button),
        matchesGoldenFile('goldens/button.png'),
      );
    });

    testWidgets('Button.destructive matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.destructive(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button'),
          ),
        ),
      );

      await expectLater(
        find.byType(Button),
        matchesGoldenFile('goldens/button_destructive.png'),
      );
    });

    testWidgets('Button.outline matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.outline(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button'),
          ),
        ),
      );

      await expectLater(
        find.byType(Button),
        matchesGoldenFile('goldens/button_outline.png'),
      );
    });

    testWidgets('Button.secondary matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.secondary(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button'),
          ),
        ),
      );

      await expectLater(
        find.byType(Button),
        matchesGoldenFile('goldens/button_secondary.png'),
      );
    });

    testWidgets('Button.ghost matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.ghost(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button'),
          ),
        ),
      );

      await expectLater(
        find.byType(Button),
        matchesGoldenFile('goldens/button_ghost.png'),
      );
    });

    testWidgets('Button.link matches goldens', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Button.link(
            leading: Icon(Icons.star),
            trailing: Icon(Icons.arrow_forward),
            child: Text('Button'),
          ),
        ),
      );

      await expectLater(
        find.byType(Button),
        matchesGoldenFile('goldens/button_link.png'),
      );
    });

    group('icon sizing', () {
      testWidgets('leading and trailing icons take the style default', (
        tester,
      ) async {
        // `.cn-button` is `[&_svg:not([class*='size-'])]:size-4`. Before this
        // the button passed the size through untouched, so icons fell back to
        // Flutter's 24.
        await tester.pumpWidget(
          createTestWidget(
            const Button(
              leading: Icon(Icons.star),
              trailing: Icon(Icons.arrow_forward),
              child: Text('Button'),
            ),
          ),
        );

        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(16));
        expect(
          tester.getSize(find.byIcon(Icons.arrow_forward)),
          const Size.square(16),
        );
      });

      testWidgets('the small size shrinks them, per the style', (
        tester,
      ) async {
        // nova's `.cn-button-size-sm` is `[&_svg…]:size-3.5`.
        await tester.pumpWidget(
          createTestWidget(
            const Button(
              size: ButtonSize.sm,
              leading: Icon(Icons.star),
              child: Text('Button'),
            ),
          ),
        );

        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(14));
      });

      testWidgets('an explicit size on the icon wins', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const Button(
              leading: Icon(Icons.star, size: 22),
              child: Text('Button'),
            ),
          ),
        );

        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(22));
      });

      testWidgets('Button.iconSize overrides the style', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const Button(
              iconSize: 10,
              leading: Icon(Icons.star),
              child: Text('Button'),
            ),
          ),
        );

        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(10));
      });

      testWidgets('size: icon is the icon button, without the wrapper', (
        tester,
      ) async {
        // shadcn has no separate IconButton — `<Button size="icon">` is the
        // whole of it, and IconButton is a convenience over this.
        await tester.pumpWidget(
          createTestWidget(
            const Button(
              size: ButtonSize.icon,
              child: Icon(Icons.star),
            ),
          ),
        );

        expect(tester.getSize(find.byType(Button)), const Size.square(32));
        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(16));
      });
    });
  });
}
