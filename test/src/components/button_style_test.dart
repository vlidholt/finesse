import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';
import '../../finesse_harness.dart';

/// `Button.style`, `IconButton.style` and `Toggle.style`: one object, merged
/// over the variant's theme, in place of a constructor parameter per colour
/// and metric.
void main() {
  Future<ThemeData> pump(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      FinesseApp(
        theme: theme,
        darkTheme: theme,
        formFactor: FormFactor.desktop,
        home: Center(child: child),
      ),
    );
    return Theme.of(tester.element(find.byWidget(child)));
  }

  /// The fill the control under [of] paints now.
  Color? fillOf(WidgetTester tester, Finder of) => tester
      .widgetList<DecoratedBox>(
        find.descendant(of: of, matching: find.byType(DecoratedBox)),
      )
      .map((box) => boxDecorationOf(box.decoration)?.color)
      .nonNulls
      .firstOrNull;

  Color? inkOf(WidgetTester tester, String label) => tester
      .widget<RichText>(
        find.descendant(
          of: find.text(label),
          matching: find.byType(RichText),
        ),
      )
      .text
      .style
      ?.color;

  group('Button.style', () {
    testWidgets('with none, a button is its variant’s theme', (
      tester,
    ) async {
      final button = Button.outline(onPressed: () {}, child: const Text('Go'));
      final theme = await pump(tester, button);
      final outline = theme.outlineButtonTheme;
      final sizes = theme.buttonSizesTheme.regular!;

      expect(
        Button.themeOf(
          tester.element(find.byType(Button)),
          button.variant ?? ButtonVariant.primary,
        ),
        outline,
      );
      expect(tester.getSize(find.byType(Button)).height, sizes.height);
      expect(fillOf(tester, find.byType(Button)), outline.backgroundColor);
      expect(inkOf(tester, 'Go'), outline.foregroundColor);
    });

    testWidgets('only what it sets changes: the rest is still the variant’s', (
      tester,
    ) async {
      const fill = Color(0xff0a7d4f);
      final theme = await pump(
        tester,
        Button(
          style: const ButtonTheme(
            backgroundColor: fill,
            padding: EdgeInsets.symmetric(horizontal: 40),
          ),
          onPressed: () {},
          child: const Text('Confirm'),
        ),
      );
      final primary = theme.primaryButtonTheme;

      expect(fillOf(tester, find.byType(Button)), fill);
      // The ink, the height and the text style were not named.
      expect(inkOf(tester, 'Confirm'), primary.foregroundColor);
      expect(
        tester.getSize(find.byType(Button)).height,
        theme.buttonSizesTheme.regular!.height,
      );
      final label = tester.getRect(find.text('Confirm'));
      final box = tester.getRect(find.byType(Button));
      expect(label.left - box.left, 40);
      expect(box.right - label.right, 40);
    });

    testWidgets('hover and press colours come from the style too', (
      tester,
    ) async {
      const rest = Color(0xff102030);
      const hover = Color(0xff405060);
      const held = Color(0xff708090);
      await pump(
        tester,
        Button(
          style: const ButtonTheme(
            backgroundColor: rest,
            hoverBackgroundColor: hover,
            pressedBackgroundColor: held,
            // At once, so each state can be read on the next frame.
            transitionDuration: Duration.zero,
          ),
          onPressed: () {},
          child: const Text('Go'),
        ),
      );
      expect(fillOf(tester, find.byType(Button)), rest);

      final mouse = await hoverAt(tester, tester.getCenter(find.text('Go')));
      await tester.pump();
      await tester.pump();
      expect(fillOf(tester, find.byType(Button)), hover);

      await mouse.down(tester.getCenter(find.text('Go')));
      await tester.pump();
      await tester.pump();
      expect(fillOf(tester, find.byType(Button)), held);

      await mouse.up();
      await tester.pump();
      await tester.pump();
      expect(fillOf(tester, find.byType(Button)), hover);
      await tester.pumpAndSettle();
    });

    testWidgets('a decoration is merged into the variant’s: new corners keep '
        'the outline', (tester) async {
      late ThemeData theme;
      await pump(
        tester,
        Builder(
          builder: (context) {
            theme = Theme.of(context);
            return Button.outline(
              style: ButtonTheme(
                decoration: theme.buttonDecoration(radius: theme.radii.full),
              ),
              onPressed: () {},
              child: const Text('Follow'),
            );
          },
        ),
      );
      final decoration = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(Button),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => boxDecorationOf(box.decoration))
          .nonNulls
          .firstWhere((decoration) => decoration.border != null);
      expect(decoration.borderRadius, theme.radii.full);
      final outline = theme.outlineButtonTheme.decoration!.border!;
      expect((decoration.border! as Border).top.color, outline.top!.color);
      expect((decoration.border! as Border).top.width, outline.top!.width);
    });

    testWidgets('width, height and icon size replace the size’s, and a size '
        'still picks the rest', (tester) async {
      final theme = await pump(
        tester,
        Button(
          size: ButtonSize.sm,
          style: const ButtonTheme(width: 180, iconSize: 11),
          onPressed: () {},
          leading: const PhosphorIcon(PhosphorIconsRegular.plus),
          child: const Text('Add'),
        ),
      );
      final size = tester.getSize(find.byType(Button));
      expect(size.width, 180);
      expect(size.height, theme.buttonSizesTheme.sm!.height);
      expect(
        tester.getSize(find.byIcon(PhosphorIconsRegular.plus)),
        const Size.square(11),
      );
    });

    testWidgets('a text style is merged into the variant’s', (tester) async {
      final theme = await pump(
        tester,
        Button(
          style: const ButtonTheme(textStyle: TextStyle(letterSpacing: 3)),
          onPressed: () {},
          child: const Text('Wide'),
        ),
      );
      final style = tester
          .widget<RichText>(
            find.descendant(
              of: find.text('Wide'),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!;
      expect(style.letterSpacing, 3);
      expect(style.fontSize, theme.primaryButtonTheme.textStyle!.fontSize);
      expect(style.fontWeight, theme.primaryButtonTheme.textStyle!.fontWeight);
    });

    testWidgets('pressScale 1 and a zero transition make a row of it', (
      tester,
    ) async {
      const rest = Color(0xff102030);
      const hover = Color(0xff405060);
      await pump(
        tester,
        Button.ghost(
          style: const ButtonTheme(
            pressScale: 1,
            transitionDuration: Duration.zero,
            backgroundColor: rest,
            hoverBackgroundColor: hover,
          ),
          onPressed: () {},
          child: const Text('Row'),
        ),
      );
      await hoverAt(tester, tester.getCenter(find.text('Row')));
      // No fade: the next frame has the highlight whole.
      await tester.pump();
      await tester.pump();
      expect(fillOf(tester, find.byType(Button)), hover);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Row')),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final transform = tester
          .renderObject(find.text('Row'))
          .getTransformTo(tester.renderObject(find.byType(Button)));
      // Not scaled: only the pixel it is nudged down by.
      expect(transform.storage[0], 1);
      expect(transform.storage[5], 1);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
      'a theme’s variant override and a style stack: the style wins',
      (tester) async {
        const themed = Color(0xff111111);
        const styled = Color(0xff222222);
        await pump(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(onPressed: () {}, child: const Text('Themed')),
              Button(
                style: const ButtonTheme(backgroundColor: styled),
                onPressed: () {},
                child: const Text('Styled'),
              ),
            ],
          ),
          theme: ThemeData(
            primaryButtonTheme: const ButtonTheme(backgroundColor: themed),
          ),
        );
        expect(fillOf(tester, find.widgetWithText(Button, 'Themed')), themed);
        expect(fillOf(tester, find.widgetWithText(Button, 'Styled')), styled);
      },
    );
  });

  group('IconButton.style', () {
    testWidgets('sizes are the square ones; a style replaces them', (
      tester,
    ) async {
      final theme = await pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final size in ButtonSize.values)
              IconButton.outline(
                key: ValueKey(size),
                size: size,
                semanticLabel: 'Add',
                onPressed: () {},
                icon: const PhosphorIcon(PhosphorIconsRegular.plus),
              ),
            IconButton.ghost(
              key: const ValueKey('styled'),
              style: const ButtonTheme(
                width: 20,
                height: 20,
                iconSize: 12,
                padding: EdgeInsets.zero,
              ),
              semanticLabel: 'Close',
              onPressed: () {},
              icon: const PhosphorIcon(PhosphorIconsRegular.x),
            ),
          ],
        ),
      );
      final sizes = theme.buttonSizesTheme;
      for (final (size, metrics) in [
        (ButtonSize.regular, sizes.icon!),
        (ButtonSize.sm, sizes.iconSm!),
        (ButtonSize.lg, sizes.iconLg!),
      ]) {
        expect(
          tester.getSize(find.byKey(ValueKey(size))),
          Size.square(metrics.height),
          reason: '$size',
        );
        expect(
          tester.getSize(
            find.descendant(
              of: find.byKey(ValueKey(size)),
              matching: find.byIcon(PhosphorIconsRegular.plus),
            ),
          ),
          Size.square(metrics.iconSize!),
          reason: '$size',
        );
      }
      expect(
        tester.getSize(find.byKey(const ValueKey('styled'))),
        const Size.square(20),
      );
      expect(
        tester.getSize(find.byIcon(PhosphorIconsRegular.x)),
        const Size.square(12),
      );
    });
  });

  group('Toggle.style', () {
    testWidgets('is merged over the variant’s theme, off and on', (
      tester,
    ) async {
      const on = Color(0xff0a7d4f);
      const onInk = Color(0xffffffff);
      var value = false;
      late ThemeData theme;
      await pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            theme = Theme.of(context);
            return Toggle(
              value: value,
              style: const ToggleTheme(
                selectedBackgroundColor: on,
                selectedHoverBackgroundColor: on,
                selectedForegroundColor: onInk,
                width: 120,
              ),
              onChanged: (next) => setState(() => value = next),
              child: const Text('Pin'),
            );
          },
        ),
      );
      expect(tester.getSize(find.byType(Toggle)).width, 120);
      expect(
        tester.getSize(find.byType(Toggle)).height,
        theme.toggleTheme.height,
      );
      // Off is still the theme's.
      expect(
        inkOf(tester, 'Pin'),
        theme.toggleTheme.foregroundColor ?? theme.colorScheme.foreground,
      );

      await tester.tap(find.text('Pin'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(fillOf(tester, find.byType(Toggle)), on);
      expect(inkOf(tester, 'Pin'), onInk);
    });

    testWidgets('a toggle is as wide as its content wherever it is put', (
      tester,
    ) async {
      // In a Wrap or a Column the constraints are loose up to the whole
      // width, which it used to take.
      await pump(
        tester,
        SizedBox(
          width: 600,
          child: Wrap(
            children: [
              Toggle(
                value: false,
                onChanged: (_) {},
                child: const PhosphorIcon(PhosphorIconsRegular.textB),
              ),
              Toggle.outline(
                value: true,
                onChanged: (_) {},
                child: const Text('Bold'),
              ),
            ],
          ),
        ),
      );
      for (final toggle in tester.widgetList<Toggle>(find.byType(Toggle))) {
        expect(
          tester.getSize(find.byWidget(toggle)).width,
          lessThan(120),
        );
      }
      // A parent that says how wide still decides.
      await tester.pumpWidget(const SizedBox.shrink());
      await pump(
        tester,
        SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Toggle(
                value: false,
                onChanged: (_) {},
                child: const Text('Bold'),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(Toggle)).width, 300);
      final label = tester.getRect(find.text('Bold'));
      final box = tester.getRect(find.byType(Toggle));
      expect(label.center.dx, moreOrLessEquals(box.center.dx, epsilon: .5));
    });
  });

  group('rare gestures go around the button', () {
    testWidgets('a FinesseGestureDetector adds a double tap and a secondary '
        'tap without taking the press', (tester) async {
      final events = <String>[];
      await pump(
        tester,
        FinesseGestureDetector(
          onDoubleTap: () => events.add('double'),
          onSecondaryTapDown: (_) => events.add('secondary'),
          child: Button.outline(
            onPressed: () => events.add('pressed'),
            child: const Text('Photo'),
          ),
        ),
      );

      await tester.tap(find.text('Photo'));
      // The press waits for the second tap that does not come.
      await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 20));
      await tester.pumpAndSettle();
      expect(events, ['pressed']);

      events.clear();
      await tester.tap(find.text('Photo'));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();
      expect(events, ['double']);

      events.clear();
      await tester.tap(
        find.text('Photo'),
        buttons: kSecondaryMouseButton,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(events, ['secondary']);
    });

    testWidgets('a Listener hears a press the moment it starts', (
      tester,
    ) async {
      final events = <String>[];
      await pump(
        tester,
        Listener(
          onPointerDown: (_) => events.add('down'),
          child: Button(
            onPressed: () => events.add('pressed'),
            child: const Text('Go'),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Go')),
      );
      expect(events, ['down']);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(events, ['down', 'pressed']);
    });
  });
}
