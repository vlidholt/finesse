import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    hide ButtonTheme, IconButton, Theme, ThemeData;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/material.dart';
import 'package:una/src/app.dart';
import 'package:una/src/components/button.dart';
import 'package:una/src/components/decorator.dart';
import 'package:una/src/components/icon_button.dart';
import 'package:una/src/icons/phosphor_icon.dart';
import 'package:una/src/icons/phosphor_icons_regular.dart';
import 'package:una/src/theme/components/button.dart';
import 'package:una/src/theme/data.dart';
import 'package:una/src/theme/style.dart';
import 'package:una/src/theme/theme.dart';

import '../../una_harness.dart';

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

  group('Button', () {
    testWidgets('an expanding button keeps a Flexible child as it is', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const SizedBox(
            width: 120,
            child: Button(
              style: ButtonTheme(width: double.infinity),
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
            style: ButtonTheme(
              backgroundColor: customBackgroundColor,
              padding: customPadding,
              width: customWidth,
            ),
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
      final opacityFinder = find
          .descendant(
            of: find.byType(Button),
            matching: find.byType(Opacity),
          )
          .first;
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

    testWidgets("a disabled button is dimmed by the theme's disabledOpacity", (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          Button(enabled: false, onPressed: () {}, child: const Text('X')),
          theme: ThemeData(disabledOpacity: .3),
        ),
      );
      final opacity = tester.widget<Opacity>(
        find
            .descendant(
              of: find.byType(Button),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(opacity.opacity, .3);
    });

    group('with no onPressed, no onLongPress and not loading', () {
      for (final (name, button) in <(String, Widget Function(FocusNode))>[
        ('Button', (node) => Button(focusNode: node, child: const Text('X'))),
        (
          'IconButton',
          (node) => IconButton(
            focusNode: node,
            icon: const PhosphorIcon(PhosphorIconsRegular.archive),
          ),
        ),
      ]) {
        testWidgets('$name is disabled: no Tab stop, no click cursor, '
            'dimmed', (tester) async {
          final node = FocusNode();
          addTearDown(node.dispose);
          await tester.pumpWidget(
            createTestWidget(Center(child: button(node))),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
          expect(node.hasFocus, isFalse);

          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          addTearDown(mouse.removePointer);
          await mouse.moveTo(tester.getCenter(find.byType(Button)));
          await tester.pump();
          expect(
            RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
            isNot(SystemMouseCursors.click),
          );
          final opacity = tester.widget<Opacity>(
            find
                .descendant(
                  of: find.byType(Button),
                  matching: find.byType(Opacity),
                )
                .first,
          );
          expect(opacity.opacity, ThemeData().disabledOpacity);
        });
      }

      testWidgets('a long press alone, or loading, keeps it enabled', (
        tester,
      ) async {
        final nodes = [FocusNode(), FocusNode()];
        for (final n in nodes) {
          addTearDown(n.dispose);
        }
        await tester.pumpWidget(
          createTestWidget(
            Column(
              children: [
                Button(
                  focusNode: nodes[0],
                  onLongPress: () {},
                  child: const Text('Hold'),
                ),
                Button(
                  focusNode: nodes[1],
                  loading: true,
                  child: const Text('Busy'),
                ),
              ],
            ),
          ),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(nodes[0].hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(nodes[1].hasFocus, isTrue);
      });
    });

    testWidgets('handles focus correctly', (WidgetTester tester) async {
      // As on a desktop, where the focus shows.
      useTraditionalHighlights();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        createTestWidget(
          Button(
            focusNode: focusNode,
            onPressed: () {},
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

    testWidgets('a focus that came from code on a touch screen does not '
        'show until a key is pressed', (WidgetTester tester) async {
      // CSS's `:focus-visible`, as for every control built on Pressable.
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final changes = <bool>[];
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              Button(
                focusNode: focusNode,
                onFocusChange: changes.add,
                onPressed: () {},
                child: const Text('First'),
              ),
              Button(onPressed: () {}, child: const Text('Second')),
            ],
          ),
        ),
      );
      bool ringed(String label) => tester
          .widget<Decorator>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(Decorator),
            ),
          )
          .focused;

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);
      // The caller hears of it either way.
      expect(changes, [true]);
      expect(ringed('First'), isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(ringed('First'), isFalse);
      expect(ringed('Second'), isTrue);
    });

    testWidgets('follows the ambient text direction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: Button(
              leading: Icon(Icons.arrow_back),
              trailing: Icon(Icons.arrow_forward),
              child: Text('RTL Button'),
            ),
          ),
        ),
      );

      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);
      final row = tester.widget<Row>(rowFinder);
      expect(row.children.elementAt(0), isA<Icon>()); // leading
      expect(row.children.elementAt(1), isA<SizedBox>()); // space
      expect(row.children.elementAt(2), isA<Text>()); // child
      expect(row.children.elementAt(3), isA<SizedBox>()); // space
      expect(row.children.elementAt(4), isA<Icon>()); // trailing

      // In RTL the leading widget is at the right and the trailing one at
      // the left.
      final label = tester.getCenter(find.text('RTL Button')).dx;
      expect(
        tester.getCenter(find.byIcon(Icons.arrow_back)).dx,
        greaterThan(label),
      );
      expect(
        tester.getCenter(find.byIcon(Icons.arrow_forward)).dx,
        lessThan(label),
      );
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
            onPressed: _noop,
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
            onPressed: _noop,
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
            onPressed: _noop,
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
            onPressed: _noop,
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
            onPressed: _noop,
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
            onPressed: _noop,
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
      // The `.cn-button` sizes quoted below are shadcn's nova.
      final nova = ThemeData(style: StyleTokens.crisp);

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
            theme: nova,
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
            theme: nova,
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

      testWidgets("a style's iconSize overrides the size's", (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            const Button(
              style: ButtonTheme(iconSize: 10),
              leading: Icon(Icons.star),
              child: Text('Button'),
            ),
          ),
        );

        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(10));
      });

      testWidgets('an icon-only button is an IconButton: the square size '
          'with its own glyph size', (tester) async {
        // shadcn has no separate IconButton — it is `<Button size="icon">`.
        // Here that size is IconButton's alone.
        await tester.pumpWidget(
          createTestWidget(
            const IconButton(
              semanticLabel: 'Favourite',
              icon: Icon(Icons.star),
            ),
            theme: nova,
          ),
        );

        expect(tester.getSize(find.byType(Button)), const Size.square(32));
        expect(tester.getSize(find.byIcon(Icons.star)), const Size.square(16));
      });
    });
  });
}

/// A callback, so a button is enabled.
void _noop() {}
