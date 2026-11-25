import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../decoration_finders.dart';
import '../../finesse_harness.dart';

const _icon = PhosphorIcon(PhosphorIconsRegular.plus);

void main() {
  Widget centred(Widget child) => Center(child: child);

  Finder fab() => find.byType(FloatingActionButton);

  group('FloatingActionButton', () {
    testWidgets('builds in every layout, with and without a label, in every '
        'variant and size', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => centred(
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final variant in FloatingActionButtonVariant.values)
                for (final size in FloatingActionButtonSize.values) ...[
                  FloatingActionButton(
                    icon: _icon,
                    label: const Text('New'),
                    variant: variant,
                    size: size,
                    onPressed: () {},
                  ),
                  FloatingActionButton(
                    icon: _icon,
                    semanticLabel: 'New',
                    variant: variant,
                    size: size,
                    onPressed: () {},
                  ),
                ],
            ],
          ),
        ),
      );
    });

    testWidgets("is the theme's size per form factor: a circle without a "
        'label, a pill with one', (tester) async {
      for (final (formFactor, sizes) in [
        (FormFactor.desktop, [40.0, 48.0, 64.0]),
        (FormFactor.mobile, [44.0, 56.0, 72.0]),
      ]) {
        for (final variant in FloatingActionButtonVariant.values) {
          for (final (index, size) in FloatingActionButtonSize.values.indexed) {
            await pumpFinesse(
              tester,
              centred(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      key: const Key('bare'),
                      icon: _icon,
                      semanticLabel: 'New',
                      variant: variant,
                      size: size,
                      onPressed: () {},
                    ),
                    FloatingActionButton(
                      key: const Key('labelled'),
                      icon: _icon,
                      label: const Text('New'),
                      variant: variant,
                      size: size,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              formFactor: formFactor,
            );
            final reason = '$formFactor $variant $size';
            expect(
              tester.getSize(find.byKey(const Key('bare'))),
              Size.square(sizes[index]),
              reason: reason,
            );
            final labelled = tester.getSize(find.byKey(const Key('labelled')));
            expect(labelled.height, sizes[index], reason: reason);
            expect(labelled.width, greaterThan(sizes[index]), reason: reason);
          }
        }
      }
    });

    testWidgets('the icon takes the theme size and the foreground; the '
        'label takes the label style', (tester) async {
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            label: const Text('New post'),
            onPressed: () {},
          ),
        ),
      );
      final theme = themeOf(tester, fab());
      final icon = IconTheme.of(tester.element(find.byIcon(_icon.icon!)));
      expect(icon.size, theme.floatingActionButtonTheme.iconSize);
      expect(icon.color, theme.colorScheme.primaryForeground);
      final text = DefaultTextStyle.of(tester.element(find.text('New post')));
      expect(text.style.color, theme.colorScheme.primaryForeground);
      expect(
        text.style.fontSize,
        theme.floatingActionButtonTheme.labelStyle!.fontSize,
      );
    });

    testWidgets('primary and secondary are filled from the scheme and '
        'shadowed outside the fill; glass is the strong glass', (tester) async {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        for (final variant in FloatingActionButtonVariant.values) {
          await pumpFinesse(
            tester,
            centred(
              FloatingActionButton(
                icon: _icon,
                label: const Text('New'),
                variant: variant,
                onPressed: () {},
              ),
            ),
            theme: theme,
          );
          final scheme = theme.colorScheme;
          final shadow = tester
              .widgetList<DecoratedBox>(
                find.descendant(
                  of: fab(),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .map((box) => box.decoration)
              .whereType<ShadowDecoration>();
          expect(shadow, hasLength(1), reason: '$variant');
          expect(
            shadow.single.shadows,
            theme.floatingActionButtonTheme.shadows,
          );
          final glass = find.descendant(
            of: fab(),
            matching: find.byType(Glass),
          );
          if (variant == FloatingActionButtonVariant.glass) {
            expect(tester.widget<Glass>(glass).level, GlassLevel.strong);
            // Glass in the default style: it blurs what is behind it.
            expect(
              find.descendant(of: fab(), matching: find.byType(BackdropFilter)),
              findsOneWidget,
            );
          } else {
            expect(glass, findsNothing);
            final fill = tester.widget<AnimatedFill>(
              find.descendant(of: fab(), matching: find.byType(AnimatedFill)),
            );
            expect(
              fill.color,
              variant == FloatingActionButtonVariant.primary
                  ? scheme.primary
                  // Over the card: a scheme's secondary may be a wash, and
                  // the page must not show through a floating button.
                  : Color.alphaBlend(
                      scheme.secondary,
                      scheme.card.withValues(alpha: 1),
                    ),
              reason: '$brightness $variant',
            );
            expect(fill.color!.a, 1, reason: '$brightness $variant');
            expect(fill.borderRadius, theme.radii.full);
          }
        }
      }
    });

    testWidgets('a square style keeps its corners', (tester) async {
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            semanticLabel: 'New',
            onPressed: () {},
          ),
        ),
        theme: ThemeData(style: StyleTokens.lyra),
      );
      final fill = tester.widget<AnimatedFill>(
        find.descendant(of: fab(), matching: find.byType(AnimatedFill)),
      );
      expect(fill.borderRadius, BorderRadius.zero);
    });

    testWidgets('a tap, Enter and Space press it; without onPressed it is '
        'disabled', (tester) async {
      useTraditionalHighlights();
      var pressed = 0;
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            label: const Text('New'),
            onPressed: () => pressed++,
          ),
        ),
      );
      await tester.tap(fab());
      await tester.pump();
      expect(pressed, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(pressed, 3);
      // The focus shows as the theme's ring around the pill.
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester
            .widget<FocusRing>(
              find.descendant(of: fab(), matching: find.byType(FocusRing)),
            )
            .visible,
        isTrue,
      );

      await pumpFinesse(
        tester,
        centred(
          const FloatingActionButton(
            icon: _icon,
            label: Text('New'),
            onPressed: null,
          ),
        ),
      );
      await tester.tap(fab(), warnIfMissed: false);
      expect(pressed, 3);
      final theme = themeOf(tester, fab());
      expect(
        tester
            .widget<Opacity>(
              find.descendant(of: fab(), matching: find.byType(Opacity)).first,
            )
            .opacity,
        theme.disabledOpacity,
      );
    });

    testWidgets('autofocus and a focus node of its own', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            label: const Text('New'),
            focusNode: node,
            autofocus: true,
            onPressed: () {},
          ),
        ),
      );
      expect(node.hasFocus, isTrue);
    });

    testWidgets('hover and press wash the fill with its own ink, without a '
        'flash', (tester) async {
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            label: const Text('New'),
            onPressed: () {},
          ),
        ),
      );
      final theme = themeOf(tester, fab());
      Color fill() => tester
          .widget<AnimatedFill>(
            find.descendant(of: fab(), matching: find.byType(AnimatedFill)),
          )
          .color!;
      expect(fill(), theme.colorScheme.primary);
      await hoverAt(tester, tester.getCenter(fab()));
      await tester.pump();
      expect(fill(), isNot(theme.colorScheme.primary));
      // Still opaque: a wash over the fill, not a fade of it.
      expect(fill().a, 1);
    });

    testWidgets('is one button, named by its label or by semanticLabel', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            label: const Text('New post'),
            onPressed: () {},
          ),
        ),
      );
      var node = tester.getSemantics(fab());
      expect(node.label, 'New post');
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );

      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            label: const Text('New post'),
            semanticLabel: 'Write a new post',
            onPressed: () {},
          ),
        ),
      );
      node = tester.getSemantics(fab());
      expect(node.label, 'Write a new post');
      handle.dispose();
    });

    testWidgets('without a label it must be given a name', (tester) async {
      expect(
        () => FloatingActionButton(icon: _icon, onPressed: () {}),
        throwsAssertionError,
      );
    });

    testWidgets('grows with the text scale rather than clipping its label', (
      tester,
    ) async {
      for (final scale in [1.0, 1.5, 2.0]) {
        await pumpFinesse(
          tester,
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: centred(
              FloatingActionButton(
                icon: _icon,
                label: const Text('New', key: Key('label')),
                onPressed: () {},
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final button = tester.getRect(fab());
        final label = tester.getRect(find.byKey(const Key('label')));
        expect(button.height, scale == 1 ? 48 : greaterThanOrEqualTo(48));
        expect(button.top, lessThanOrEqualTo(label.top), reason: '$scale');
        expect(button.bottom, greaterThanOrEqualTo(label.bottom));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('mirrors: the icon leads in both directions', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          centred(
            FloatingActionButton(
              icon: _icon,
              label: const Text('New'),
              onPressed: () {},
            ),
          ),
          textDirection: direction,
        );
        final icon = tester.getCenter(find.byIcon(_icon.icon!)).dx;
        final label = tester.getCenter(find.text('New')).dx;
        expect(icon < label, direction == TextDirection.ltr);
      }
    });

    testWidgets('follows a theme override', (tester) async {
      const fill = Color(0xff123456);
      const ink = Color(0xfffedcba);
      await pumpFinesse(
        tester,
        centred(
          FloatingActionButton(
            icon: _icon,
            semanticLabel: 'New',
            onPressed: () {},
          ),
        ),
        theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonTheme(
            size: 60,
            iconSize: 30,
            backgroundColor: fill,
            foregroundColor: ink,
            borderRadius: BorderRadius.circular(12),
            shadows: const [],
          ),
        ),
      );
      expect(tester.getSize(fab()), const Size.square(60));
      final box = tester.widget<AnimatedFill>(
        find.descendant(of: fab(), matching: find.byType(AnimatedFill)),
      );
      expect(box.color, fill);
      expect(box.borderRadius, BorderRadius.circular(12));
      final icon = IconTheme.of(tester.element(find.byIcon(_icon.icon!)));
      expect(icon.size, 30);
      expect(icon.color, ink);
      expect(
        tester
            .widgetList<DecoratedBox>(
              find.descendant(of: fab(), matching: find.byType(DecoratedBox)),
            )
            .map((box) => shadowsOf(box.decoration))
            .whereType<List<BoxShadow>>()
            .expand((shadows) => shadows),
        isEmpty,
      );
    });
  });

  group('extended', () {
    Widget button({required bool extended}) => Align(
      alignment: AlignmentDirectional.centerEnd,
      child: FloatingActionButton(
        icon: _icon,
        label: const Text('New post'),
        extended: extended,
        onPressed: () {},
      ),
    );

    testWidgets('false collapses the button to its icon on the surface '
        'spring, one way, and true opens it again', (tester) async {
      await pumpFinesse(tester, button(extended: true));
      final open = tester.getSize(fab()).width;
      expect(open, greaterThan(100));

      await pumpFinesse(tester, button(extended: false));
      // pumpFinesse settles; run it frame by frame instead.
      await pumpFinesse(tester, button(extended: true));
      await tester.pumpWidget(
        FinesseApp(
          formFactor: FormFactor.desktop,
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: button(extended: false),
          ),
        ),
      );
      final widths = <double>[];
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        widths.add(tester.getSize(fab()).width);
      }
      expect(widths[3], inExclusiveRange(48, open));
      for (var i = 1; i < widths.length; i++) {
        expect(widths[i], lessThanOrEqualTo(widths[i - 1] + .01));
      }
      expect(widths.last, 48);
      expect(tester.getSize(fab()).height, 48);
      expect(tester.binding.hasScheduledFrame, isFalse);
      // It shrinks towards the end it is anchored to.
      expect(tester.getRect(fab()).right, 1280);

      await tester.pumpWidget(
        FinesseApp(
          formFactor: FormFactor.desktop,
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: button(extended: true),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 48));
      // Turned round mid-way: on from where it is.
      final mid = tester.getSize(fab()).width;
      expect(mid, inExclusiveRange(48, open));
      await tester.pumpAndSettle();
      expect(tester.getSize(fab()).width, open);
    });

    testWidgets('collapsed, it is still named by its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, button(extended: false));
      expect(tester.getSemantics(fab()).label, 'New post');
      handle.dispose();
    });

    testWidgets('with reduced motion, and with motion off, it changes at '
        'once', (tester) async {
      for (final (reduce, theme) in [
        (true, null),
        (false, ThemeData(motion: Motion.none)),
      ]) {
        Widget app({required bool extended}) => FinesseApp(
          formFactor: FormFactor.desktop,
          theme: theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
            child: child!,
          ),
          home: button(extended: extended),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(app(extended: true));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpWidget(app(extended: false));
        await tester.pump();
        expect(tester.getSize(fab()).width, 48);
      }
    });

    testWidgets('a glass button pops in and out with its blur: nothing above '
        'the filter is translucent', (tester) async {
      // An opacity layer around a backdrop filter takes the blur away on
      // some renderers, the web's among them.
      double opacityAbove(RenderObject? node) {
        var lowest = 1.0;
        for (; node != null; node = node.parent) {
          if (node is RenderAnimatedOpacity) {
            lowest = lowest < node.opacity.value ? lowest : node.opacity.value;
          } else if (node is RenderOpacity) {
            lowest = lowest < node.opacity ? lowest : node.opacity;
          }
        }
        return lowest;
      }

      var shown = false;
      late StateSetter setShown;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setShown = setState;
            return Scaffold(
              floatingActionButton: shown
                  ? FloatingActionButton(
                      icon: _icon,
                      variant: FloatingActionButtonVariant.glass,
                      semanticLabel: 'New post',
                      onPressed: () {},
                    )
                  : null,
              body: const SizedBox.expand(),
            );
          },
        ),
      );
      final filter = find.descendant(
        of: fab(),
        matching: find.byType(BackdropFilter),
      );
      final opacities = <double>[];
      setShown(() => shown = true);
      await tester.pump();
      // It does pop in: small and faint at first. The fade is the
      // surface's own, inside its filter.
      final rest = tester.getSize(fab());
      expect(tester.getRect(fab()).width, lessThan(rest.width));
      final fades = tester.widgetList<FadeTransition>(
        find.descendant(of: fab(), matching: find.byType(FadeTransition)),
      );
      expect(fades.map((fade) => fade.opacity.value), contains(lessThan(1)));
      for (var i = 0; i < 8; i++) {
        opacities.add(opacityAbove(tester.renderObject(filter).parent));
        await tester.pump(const Duration(milliseconds: 16));
      }
      setShown(() => shown = false);
      await tester.pump();
      for (var i = 0; i < 8 && filter.evaluate().isNotEmpty; i++) {
        opacities.add(opacityAbove(tester.renderObject(filter).parent));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(opacities, everyElement(1.0));
    });

    testWidgets('in a scaffold the button stays on its corner while it '
        'collapses: the scaffold does not chase its width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      Widget app({required bool extended}) => FinesseApp(
        formFactor: FormFactor.mobile,
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            icon: _icon,
            label: const Text('New post'),
            extended: extended,
            onPressed: () {},
          ),
          body: const SizedBox.expand(),
        ),
      );
      await tester.pumpWidget(app(extended: true));
      await tester.pump(const Duration(milliseconds: 400));
      final right = tester.getRect(fab()).right;
      expect(right, 390 - 16);
      await tester.pumpWidget(app(extended: false));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.getRect(fab()).right, right);
      }
      expect(tester.getSize(fab()), const Size.square(56));
    });
  });
}
