import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/toast.dart' show RenderToastStack;
import 'package:una/una.dart';

import '../../frame_sampler.dart';

/// A toast is a floating surface, and has to look like one: told from the
/// page it floats over by its fill, its hairline and its shadow.
///
/// It did not. Its fill was the *page* colour, and the clip that crops each
/// toast in the stack to its slot cut its shadow off, so "Invitation sent"
/// was a line of text adrift on the page inside a hairline nobody could
/// see. These read the screen: what the toast was given says nothing about
/// what a clip left of it.
void main() {
  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + .05) / (lo + .05);
  }

  const black = Color(0xff000000);
  const white = Color(0xffffffff);
  const shadcn = [StyleTokens.crisp, StyleTokens.pebble, StyleTokens.sharp];

  ThemeData themeOf(StyleTokens style, Brightness brightness) => ThemeData(
    style: style,
    brightness: brightness,
    colorScheme: style == StyleTokens.fluid
        ? null
        : brightness == Brightness.dark
        ? const GraphiteColorScheme.dark()
        : const GraphiteColorScheme.light(),
  );

  group('the toast themes', () {
    test('a toast is a popover surface: glass in the una style', () {
      for (final brightness in Brightness.values) {
        final theme = themeOf(StyleTokens.fluid, brightness);
        final toast = theme.toastTheme;
        expect(toast.backgroundColor, theme.popoverTheme.decoration!.color);
        expect(toast.backgroundColor!.a, lessThan(1));
        expect(toast.filter, theme.popoverTheme.filter);
        expect(toast.filter, isNotNull);
        expect(toast.shadows, isNotEmpty);
        expect(toast.border!.top!.color!.a, greaterThan(0));
        expect(toast.titleStyle!.color, theme.colorScheme.popoverForeground);
        // Not the page colour, which is what made it disappear.
        expect(
          toast.backgroundColor!.withValues(alpha: 1),
          isNot(theme.colorScheme.background),
        );
      }
    });

    test("and sonner's `bg-popover text-popover-foreground` in the shadcn "
        'styles: solid', () {
      for (final style in shadcn) {
        for (final brightness in Brightness.values) {
          final theme = themeOf(style, brightness);
          final toast = theme.toastTheme;
          final where = '${style.name} $brightness';
          expect(
            toast.backgroundColor,
            theme.colorScheme.popover,
            reason: where,
          );
          expect(toast.filter, isNull, reason: where);
          expect(
            toast.titleStyle!.color,
            theme.colorScheme.popoverForeground,
            reason: where,
          );
          expect(toast.shadows, isNotEmpty, reason: where);
        }
      }
    });

    test('every variant shares that surface and says what it is with an '
        'icon that reads on it', () {
      for (final style in [StyleTokens.fluid, ...shadcn]) {
        for (final brightness in Brightness.values) {
          final theme = themeOf(style, brightness);
          final toast = theme.toastTheme;
          for (final backdrop in [
            theme.colorScheme.background,
            black,
            white,
          ]) {
            final fill = over(toast.backgroundColor!, backdrop);
            for (final (name, colour) in [
              ('success', toast.successColor!),
              ('warning', toast.warningColor!),
              ('destructive', toast.destructiveColor!),
              ('loading', toast.loadingColor!),
            ]) {
              // A graphic, not text: WCAG's 3:1.
              expect(
                contrast(over(colour, fill), fill),
                greaterThanOrEqualTo(3),
                reason: '$name: ${style.name} $brightness over $backdrop',
              );
            }
          }
        }
      }
    });

    test('its text, and a button on it, read over anything', () {
      for (final style in [StyleTokens.fluid, ...shadcn]) {
        for (final brightness in Brightness.values) {
          final theme = themeOf(style, brightness);
          final toast = theme.toastTheme;
          for (final backdrop in [
            theme.colorScheme.background,
            black,
            white,
          ]) {
            final where = '${style.name} $brightness over $backdrop';
            final fill = over(toast.backgroundColor!, backdrop);
            expect(
              contrast(toast.titleStyle!.color!, fill),
              greaterThanOrEqualTo(4.5),
              reason: 'title: $where',
            );
            expect(
              contrast(over(toast.descriptionStyle!.color!, fill), fill),
              greaterThanOrEqualTo(4.5),
              reason: 'description: $where',
            );
            // An "Undo" is an outline or a ghost button: the page's
            // foreground on whatever the toast is.
            expect(
              contrast(theme.colorScheme.foreground, fill),
              greaterThanOrEqualTo(4.5),
              reason: 'action: $where',
            );
          }
        }
      }
    });
  });

  group('on screen', () {
    Future<FrameSampler> pump(
      WidgetTester tester,
      ThemeData theme,
      Color backdrop,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 500);
      addTearDown(tester.view.reset);
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      final sampler = FrameSampler();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        sampler.wrap(
          UnaApp(
            theme: theme.copyWith(
              // Room under the toast for its shadow to be read.
              toasterTheme: const ToasterTheme(padding: EdgeInsets.all(40)),
            ),
            darkTheme: theme,
            home: ColoredBox(
              color: backdrop,
              child: const SizedBox.expand(key: Key('host')),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      return sampler;
    }

    ToasterState toasterOf(WidgetTester tester) =>
        Toaster.of(tester.element(find.byKey(const Key('host'))));

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    Future<void> expire(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 1));
    }

    for (final style in [StyleTokens.fluid, ...shadcn]) {
      for (final brightness in Brightness.values) {
        testWidgets('${style.name} ${brightness.name}: a toast has an edge '
            'over the page and over a card', (tester) async {
          final theme = themeOf(style, brightness);
          final scheme = theme.colorScheme;
          for (final (name, backdrop) in [
            ('the page', scheme.background),
            (
              'a card',
              over(theme.cardTheme.backgroundColor!, scheme.background),
            ),
          ]) {
            final where = '${style.name} ${brightness.name} over $name';
            final sampler = await pump(tester, theme, backdrop);
            toasterOf(tester).show(
              const Toast(
                title: Text('Invitation sent'),
                description: Text('She will see it in her network tab.'),
              ),
            );
            await settle(tester);
            final rect = tester.getRect(find.byType(Toast));
            final x = rect.center.dx + 60;
            final seen = await sampler.pixels(tester, [
              Offset(x, rect.bottom - 6), // the fill, clear of the text
              Offset(x, rect.bottom - .5), // the hairline
              Offset(x, rect.bottom + 5), // the shadow under it
              Offset(x, rect.top + .5),
              const Offset(40, 40), // the bare backdrop
            ]);
            final fill = seen[0];
            final hairline = seen[1];
            final shadow = seen[2];
            final top = seen[3];
            // The bare backdrop, to within the rounding of a translucent
            // card.
            for (var c = 0; c < 3; c++) {
              expect(
                (rgbOf(seen[4])[c] - rgbOf(backdrop)[c]).abs(),
                lessThanOrEqualTo(1),
                reason: where,
              );
            }
            final una = style == StyleTokens.fluid;
            final dark = brightness == Brightness.dark;

            // The edge: the hairline against what is outside it — the bare
            // backdrop above the toast, the shadowed one below.
            expect(
              math.max(contrast(top, backdrop), contrast(fill, backdrop)),
              greaterThan(dark ? 1.25 : 1.07),
              reason: 'the top edge, $where',
            );
            // Below, the edge is the hairline or the fill, whichever
            // stands further from the shadow: on a grey page a white
            // toast's own fill draws it.
            expect(
              math.max(contrast(hairline, shadow), contrast(fill, shadow)),
              greaterThan(dark ? 1.3 : 1.03),
              reason: 'the bottom edge, $where',
            );
            // The shadow: the stack used to clip it off. (On the shadcn
            // styles' near-black page no shadow can show; there the fill
            // and the hairline carry the toast.)
            expect(
              shadow.computeLuminance(),
              lessThanOrEqualTo(backdrop.computeLuminance()),
              reason: 'the shadow, $where',
            );
            if (!dark || una) {
              expect(
                contrast(shadow, backdrop),
                greaterThan(dark ? 1.08 : 1.12),
                reason: 'the shadow, $where',
              );
            }
            // And the surface itself is not the page: its fill differs
            // from it by more than a rounding step — in the default style
            // in both modes, in the shadcn ones in dark, where the popover
            // is a step lighter than the page. (shadcn's light popover *is*
            // its page colour; a toast there is its hairline and shadow.)
            if (name == 'the page' && (una || dark)) {
              final difference = [
                for (var c = 0; c < 3; c++)
                  (rgbOf(fill)[c] - rgbOf(backdrop)[c]).abs(),
              ].reduce((a, b) => a > b ? a : b);
              expect(difference, greaterThanOrEqualTo(5), reason: where);
            }
            await expire(tester);
          }
        });
      }
    }

    testWidgets('in the stack only the toast in front casts a shadow, and '
        'each gets its own when the stack opens', (tester) async {
      await pump(
        tester,
        themeOf(StyleTokens.fluid, Brightness.light),
        const Color(0xfff3f5f7),
      );
      final toaster = toasterOf(tester);
      for (final title in ['One', 'Two', 'Three']) {
        toaster.show(Toast(title: Text(title)));
        await settle(tester);
      }
      // The clip around each toast: its slot, plus the room it leaves the
      // shadow.
      double room(String title) {
        final stack = tester.renderObject<RenderToastStack>(
          find.byWidgetPredicate(
            (widget) => '${widget.runtimeType}' == '_ToastStack',
          ),
        );
        return stack.debugShadowRoomOf(
          tester.renderObject<RenderBox>(find.text(title)),
        );
      }

      expect(room('Three'), greaterThan(20));
      expect(room('Two'), 0);
      expect(room('One'), 0);

      // Hovered, the stack opens and every toast lies on the page.
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Three')));
      await settle(tester);
      expect(room('Three'), greaterThan(20));
      expect(room('Two'), room('Three'));
      expect(room('One'), room('Three'));

      await mouse.moveTo(Offset.zero);
      await settle(tester);
      expect(room('One'), 0);
      await expire(tester);
    });

    {
      testWidgets('a glass toast fades inside its filter, not under an '
          'opacity layer', (tester) async {
        await pump(
          tester,
          themeOf(StyleTokens.fluid, Brightness.light),
          const Color(0xfff3f5f7),
        );
        toasterOf(tester).show(const Toast(title: Text('Saved')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 40));

        double opacityAbove(Finder finder) {
          var lowest = 1.0;
          var node = tester.renderObject(finder).parent;
          while (node != null) {
            if (node is RenderAnimatedOpacity) {
              if (node.opacity.value < lowest) lowest = node.opacity.value;
            } else if (node is RenderOpacity) {
              if (node.opacity < lowest) lowest = node.opacity;
            }
            node = node.parent;
          }
          return lowest;
        }

        final filter = find.descendant(
          of: find.byType(Toast),
          matching: find.byType(BackdropFilter),
        );
        expect(filter, findsOneWidget);
        // Mid-entrance nothing above the filter is translucent, and the
        // content under it is.
        expect(opacityAbove(filter), 1);
        expect(opacityAbove(find.text('Saved')), inExclusiveRange(0, 1));
        await settle(tester);
        expect(opacityAbove(find.text('Saved')), 1);
        await expire(tester);
        await settle(tester);
        expect(find.text('Saved'), findsNothing);
      });
    }
  });
}
