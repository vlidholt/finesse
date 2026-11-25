import 'package:finesse/finesse.dart';
import 'package:finesse/src/components/button_group.dart'
    show RenderButtonGroup;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../frame_sampler.dart';

/// `ButtonGroup` joins its children: squared corners where two meet, one
/// hairline between two outlines, and nothing moved by the joining.
void main() {
  const styles = [
    StyleTokens.finesse,
    StyleTokens.nova,
    StyleTokens.maia,
    StyleTokens.lyra,
  ];

  ThemeData themeOf(
    StyleTokens style, {
    Brightness brightness = Brightness.light,
    bool insideRing = false,
  }) => ThemeData(
    style: style,
    brightness: brightness,
    disableSecondaryBorder: insideRing,
  );

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
    TextDirection direction = TextDirection.ltr,
    double textScale = 1,
    FrameSampler? sampler,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SizedBox.shrink());
    final app = FinesseApp(
      theme: theme,
      darkTheme: theme,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: child!),
      ),
      home: Center(child: child),
    );
    await tester.pumpWidget(sampler == null ? app : sampler.wrap(app));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Widget outline(String label, {VoidCallback? onPressed}) => Button.outline(
    onPressed: onPressed ?? () {},
    child: Text(label),
  );

  /// The decoration a button is drawn with, as its `Decorator` got it.
  FinesseDecoration decorationOf(WidgetTester tester, Finder button) => tester
      .widget<Decorator>(
        find.descendant(of: button, matching: find.byType(Decorator)).first,
      )
      .decoration!;

  BorderRadius radiusOf(WidgetTester tester, Finder button) =>
      decorationOf(tester, button).border!.borderRadius! as BorderRadius;

  Finder buttonOf(String label) => find.widgetWithText(Button, label);

  group('layout', () {
    testWidgets('the children lie edge to edge, each exactly as wide as it '
        'is on its own, with its label where it was', (tester) async {
      for (final insideRing in [false, true]) {
        final theme = themeOf(StyleTokens.finesse, insideRing: insideRing);
        await pump(
          tester,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [outline('Aa'), outline('Bbbb'), outline('C')],
          ),
          theme: theme,
        );
        final alone = {
          for (final label in ['Aa', 'Bbbb', 'C'])
            label: (
              tester.getSize(buttonOf(label)),
              tester.getTopLeft(find.text(label)) -
                  tester.getTopLeft(buttonOf(label)),
            ),
        };
        await pump(
          tester,
          ButtonGroup(
            children: [outline('Aa'), outline('Bbbb'), outline('C')],
          ),
          theme: theme,
        );
        var edge = tester.getRect(find.byType(ButtonGroup)).left;
        for (final label in ['Aa', 'Bbbb', 'C']) {
          final rect = tester.getRect(buttonOf(label));
          final where = '$label, inside ring: $insideRing';
          expect(rect.left, edge, reason: where);
          expect(rect.size, alone[label]!.$1, reason: where);
          expect(
            tester.getTopLeft(find.text(label)) - rect.topLeft,
            alone[label]!.$2,
            reason: where,
          );
          edge = rect.right;
        }
        expect(edge, tester.getRect(find.byType(ButtonGroup)).right);
      }
    });

    testWidgets('right to left the first child is on the right', (
      tester,
    ) async {
      await pump(
        tester,
        ButtonGroup(children: [outline('First'), outline('Last')]),
        direction: TextDirection.rtl,
      );
      expect(
        tester.getRect(buttonOf('First')).left,
        tester.getRect(buttonOf('Last')).right,
      );
      final first = radiusOf(tester, buttonOf('First'));
      expect(first.topRight, isNot(Radius.zero));
      expect(first.topLeft, Radius.zero);
      final last = radiusOf(tester, buttonOf('Last'));
      expect(last.topLeft, isNot(Radius.zero));
      expect(last.topRight, Radius.zero);
      // And the edge the second gives up is the one towards the first.
      final border = decorationOf(tester, buttonOf('Last')).border!;
      expect(border.right!.width, 0);
      expect(border.left!.width, 1);
    });

    testWidgets('a vertical group stacks, and every child is as wide as the '
        'widest', (tester) async {
      await pump(
        tester,
        ButtonGroup(
          axis: Axis.vertical,
          children: [outline('A'), outline('A longer one'), outline('C')],
        ),
      );
      final a = tester.getRect(buttonOf('A'));
      final b = tester.getRect(buttonOf('A longer one'));
      final c = tester.getRect(buttonOf('C'));
      expect(a.width, b.width);
      expect(c.width, b.width);
      expect(b.top, a.bottom);
      expect(c.top, b.bottom);
      final middle = radiusOf(tester, buttonOf('A longer one'));
      expect(middle, BorderRadius.zero);
      final first = radiusOf(tester, buttonOf('A'));
      expect(first.topLeft, isNot(Radius.zero));
      expect(first.bottomLeft, Radius.zero);
      expect(decorationOf(tester, buttonOf('C')).border!.top!.width, 0);
    });

    testWidgets('every child is as tall as the tallest: a label, a '
        'separator and a small button beside a large one', (tester) async {
      await pump(
        tester,
        ButtonGroup(
          children: [
            const ButtonGroupText(child: Text('https://')),
            Button.secondary(
              size: ButtonSize.sm,
              onPressed: () {},
              child: const Text('Small'),
            ),
            const ButtonGroupSeparator(),
            Button.secondary(
              size: ButtonSize.lg,
              onPressed: () {},
              child: const Text('Large'),
            ),
          ],
        ),
      );
      final height = tester.getSize(find.byType(ButtonGroup)).height;
      final theme = Theme.of(tester.element(find.byType(ButtonGroup)));
      expect(height, theme.buttonSizesTheme.lg!.height);
      expect(tester.getSize(find.byType(ButtonGroupText)).height, height);
      expect(tester.getSize(buttonOf('Small')).height, height);
      final separator = tester.getSize(find.byType(ButtonGroupSeparator));
      expect(separator, Size(1, height));
    });

    testWidgets('twice the text size: the group grows and nothing overflows', (
      tester,
    ) async {
      await pump(
        tester,
        ButtonGroup(
          children: [
            const ButtonGroupText(child: Text('A')),
            outline('B'),
            outline('C'),
          ],
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      final theme = Theme.of(tester.element(find.byType(ButtonGroup)));
      expect(
        tester.getSize(find.byType(ButtonGroup)).height,
        greaterThanOrEqualTo(theme.buttonSizesTheme.regular!.height),
      );
      // The label is whole.
      expect(
        tester.getSize(find.text('B')).height,
        lessThanOrEqualTo(tester.getSize(buttonOf('B')).height),
      );
    });

    testWidgets('one child keeps all its corners', (tester) async {
      await pump(tester, ButtonGroup(children: [outline('Only')]));
      final radius = radiusOf(tester, buttonOf('Only'));
      expect(radius.topLeft, isNot(Radius.zero));
      expect(radius.topRight, radius.topLeft);
      expect(decorationOf(tester, buttonOf('Only')).border!.left!.width, 1);
    });
  });

  group('the seam', () {
    for (final style in styles) {
      for (final brightness in Brightness.values) {
        for (final insideRing in [false, true]) {
          testWidgets('${style.name} ${brightness.name}'
              '${insideRing ? ' inside ring' : ''}: two outlines meet in '
              'one hairline, and their inner corners are square', (
            tester,
          ) async {
            final sampler = FrameSampler();
            final theme = themeOf(
              style,
              brightness: brightness,
              insideRing: insideRing,
            );
            await pump(
              tester,
              ButtonGroup(children: [outline('A'), outline('B')]),
              theme: theme,
              sampler: sampler,
            );
            final a = tester.getRect(buttonOf('A'));
            final b = tester.getRect(buttonOf('B'));
            expect(b.left, a.right);
            expect(radiusOf(tester, buttonOf('A')).topRight, Radius.zero);
            expect(radiusOf(tester, buttonOf('B')).bottomLeft, Radius.zero);

            // Across the seam at mid height: one column of hairline, with
            // each button's fill on either side of it.
            final y = a.center.dy;
            final seen = await sampler.pixels(tester, [
              for (var dx = -4; dx <= 3; dx++) Offset(a.right + dx + .5, y),
            ]);
            final fill = seen.first;
            final lines = seen.where((colour) => colour != fill).length;
            expect(
              lines,
              1,
              reason: 'the seam is $lines pixels of line: $seen',
            );
            // And the hairline runs unbroken along the top, over the seam.
            final top = await sampler.pixels(tester, [
              for (var dx = -3; dx <= 3; dx++)
                Offset(a.right + dx + .5, a.top + .5),
            ]);
            expect(top.toSet().length, 1, reason: 'the top edge: $top');
            expect(top.first, isNot(fill));
          });
        }
      }
    }

    testWidgets('unoutlined children run into each other; a separator '
        'draws the line', (tester) async {
      final sampler = FrameSampler();
      await pump(
        tester,
        ButtonGroup(
          children: [
            Button.secondary(onPressed: () {}, child: const Text('Save')),
            const ButtonGroupSeparator(),
            IconButton.secondary(
              tooltip: 'More',
              onPressed: () {},
              icon: const PhosphorIcon(PhosphorIconsRegular.caretDown),
            ),
          ],
        ),
        sampler: sampler,
      );
      final save = tester.getRect(buttonOf('Save'));
      final separator = tester.getRect(find.byType(ButtonGroupSeparator));
      expect(separator.left, save.right);
      final line = await sampler.pixel(tester, separator.center);
      final fill = await sampler.pixel(
        tester,
        Offset(save.right - 3, save.center.dy),
      );
      expect(line, isNot(fill));
      // In a group an icon button is a segment of the bar, not a circle.
      final icon = radiusOf(tester, find.byType(IconButton));
      expect(icon.topLeft, Radius.zero);
      expect(icon.topRight.x, lessThan(20));
    });
  });

  group('focus', () {
    testWidgets('the focused child is painted last, with a ring squared '
        'like its corners, and nothing moves', (tester) async {
      for (final insideRing in [false, true]) {
        final theme = themeOf(StyleTokens.finesse, insideRing: insideRing);
        await pump(
          tester,
          ButtonGroup(
            children: [outline('A'), outline('B'), outline('C')],
          ),
          theme: theme,
        );
        final layout = tester.renderObject<RenderButtonGroup>(
          find.byWidgetPredicate(
            (widget) => '${widget.runtimeType}' == '_ButtonGroupLayout',
          ),
        );
        expect(layout.paintLast, isNull);
        final before = [
          for (final label in ['A', 'B', 'C']) tester.getRect(find.text(label)),
        ];

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump(const Duration(milliseconds: 300));
        expect(layout.paintLast, 1);
        expect(
          [
            for (final label in ['A', 'B', 'C'])
              tester.getRect(find.text(label)),
          ],
          before,
          reason: 'inside ring: $insideRing',
        );
        final decoration = decorationOf(tester, buttonOf('B'));
        if (insideRing) {
          // Its own focus border, on all four sides.
          final focused = decoration.focusedBorder!;
          expect(focused.left!.width, 2);
          expect(focused.right!.width, 2);
          expect(focused.borderRadius, BorderRadius.zero);
        } else {
          expect(
            decoration.secondaryFocusedBorder!.borderRadius,
            BorderRadius.zero,
          );
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(layout.paintLast, 2);
        FocusManager.instance.primaryFocus!.unfocus();
        await tester.pump();
        await tester.pump();
        expect(layout.paintLast, isNull);
      }
    });

    testWidgets('every child is a Tab stop and is pressed with Enter', (
      tester,
    ) async {
      final pressed = <String>[];
      await pump(
        tester,
        ButtonGroup(
          children: [
            for (final label in ['A', 'B'])
              outline(label, onPressed: () => pressed.add(label)),
          ],
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pressed, ['A', 'B']);
    });
  });

  group('what takes a place', () {
    testWidgets('a menu opened from a button in the group is not part of '
        'it: its rows keep their own shape', (tester) async {
      await pump(
        tester,
        ButtonGroup(
          children: [
            outline('Save'),
            DropdownMenu(
              items: [
                MenuItem(onPressed: () {}, child: const Text('Draft')),
                MenuItem(onPressed: () {}, child: const Text('Copy')),
              ],
              builder: (context, controller, _) => IconButton.outline(
                tooltip: 'More',
                onPressed: controller.toggle,
                icon: const PhosphorIcon(PhosphorIconsRegular.caretDown),
              ),
            ),
          ],
        ),
      );
      // The trigger is the last of the group.
      final trigger = radiusOf(tester, find.byType(IconButton));
      expect(trigger.topLeft, Radius.zero);
      expect(trigger.topRight, isNot(Radius.zero));

      await tester.tap(find.byType(IconButton));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('Draft'), findsOneWidget);
      final theme = Theme.of(tester.element(find.byType(ButtonGroup)));
      final row = radiusOf(
        tester,
        find.ancestor(of: find.text('Draft'), matching: find.byType(Button)),
      );
      final expected = theme.radii.resolve(theme.style.itemRadius);
      expect(row, expected);
    });

    testWidgets('a child replaced by one of another type takes the place '
        'in the same frame', (tester) async {
      // The control it replaces is still mounted, deactivated, while the
      // new one is built; it gave the place up when it was deactivated.
      final icon = ValueNotifier(false);
      addTearDown(icon.dispose);
      await pump(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: icon,
          builder: (context, value, _) => ButtonGroup(
            children: [
              outline('A'),
              if (value)
                IconButton.outline(
                  onPressed: () {},
                  icon: const PhosphorIcon(PhosphorIconsRegular.plus),
                )
              else
                outline('B'),
            ],
          ),
        ),
      );
      expect(radiusOf(tester, buttonOf('B')).topLeft, Radius.zero);
      icon.value = true;
      await tester.pump();
      final last = radiusOf(tester, find.byType(IconButton));
      expect(last.topLeft, Radius.zero);
      expect(last.topRight, isNot(Radius.zero));
      // And back.
      icon.value = false;
      await tester.pump();
      expect(radiusOf(tester, buttonOf('B')).topLeft, Radius.zero);
    });

    testWidgets('so does a Toggle that replaces a Button', (tester) async {
      final toggle = ValueNotifier(false);
      addTearDown(toggle.dispose);
      await pump(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: toggle,
          builder: (context, value, _) => ButtonGroup(
            children: [
              outline('A'),
              if (value)
                Toggle(
                  variant: ToggleVariant.outline,
                  value: false,
                  onChanged: (_) {},
                  child: const Text('B'),
                )
              else
                outline('B'),
            ],
          ),
        ),
      );
      toggle.value = true;
      await tester.pump();
      final decorator = tester.widget<Decorator>(
        find
            .descendant(
              of: find.byType(Toggle),
              matching: find.byType(Decorator),
            )
            .first,
      );
      final radius =
          decorator.decoration!.border!.borderRadius! as BorderRadius;
      expect(radius.topLeft, Radius.zero);
    });

    testWidgets('a toggle group with no gap is one bar', (tester) async {
      await pump(
        tester,
        ToggleGroup<String>.multiple(
          gap: 0,
          variant: ToggleVariant.outline,
          values: const {'b'},
          onValuesChanged: (_) {},
          items: const [
            ToggleGroupItem(value: 'a', child: Text('A')),
            ToggleGroupItem(value: 'b', child: Text('B')),
            ToggleGroupItem(value: 'c', child: Text('C')),
          ],
        ),
      );
      final toggles = find.byType(Toggle);
      expect(toggles, findsNWidgets(3));
      expect(
        tester.getRect(toggles.at(1)).left,
        tester.getRect(toggles.at(0)).right,
      );
      final middle = decorationOf(tester, toggles.at(1));
      expect(middle.border!.borderRadius, BorderRadius.zero);
      expect(middle.border!.left!.width, 0);
      // With a gap they are separate again.
      await pump(
        tester,
        ToggleGroup<String>.multiple(
          variant: ToggleVariant.outline,
          onValuesChanged: (_) {},
          items: const [
            ToggleGroupItem(value: 'a', child: Text('A')),
            ToggleGroupItem(value: 'b', child: Text('B')),
          ],
        ),
      );
      expect(
        tester.getRect(find.byType(Toggle).at(1)).left,
        tester.getRect(find.byType(Toggle).at(0)).right + 4,
      );
      expect(
        (decorationOf(tester, find.byType(Toggle).at(1)).border!.borderRadius!
                as BorderRadius)
            .topLeft,
        isNot(Radius.zero),
      );
    });

    testWidgets('outside a group there is no place to take', (tester) async {
      late BuildContext context;
      await pump(
        tester,
        Builder(
          builder: (c) {
            context = c;
            return outline('Alone');
          },
        ),
      );
      expect(ButtonGroupScope.maybeOf(context), isNull);
      expect(ButtonGroupScope.isWithin(context), isFalse);
    });

    testWidgets('the group is one node for assistive technology, with its '
        'label', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        ButtonGroup(
          semanticLabel: 'Message actions',
          children: [outline('Archive'), outline('Report')],
        ),
      );
      expect(find.bySemanticsLabel('Message actions'), findsOneWidget);
      final group = tester.getSemantics(
        find.bySemanticsLabel('Message actions'),
      );
      // Each button is still its own node under it, and can be pressed.
      for (final label in ['Archive', 'Report']) {
        final node = tester.getSemantics(find.text(label));
        expect(node.label, label);
        expect(
          node.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        var parent = node.parent;
        while (parent != null && parent != group) {
          parent = parent.parent;
        }
        expect(parent, group, reason: '$label is not under the group');
      }
      handle.dispose();
    });
  });
}
