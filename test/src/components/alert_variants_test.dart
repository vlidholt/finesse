import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../frame_sampler.dart';

/// The success, warning and info variants of `Alert`, and dismissal.
void main() {
  const styles = [
    StyleTokens.fluid,
    StyleTokens.crisp,
    StyleTokens.pebble,
    StyleTokens.sharp,
  ];

  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + .05) / (lo + .05);
  }

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    ThemeData? theme,
    bool reduceMotion = false,
    double textScale = 1,
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 500);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UnaApp(
        theme: theme,
        darkTheme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Directionality(textDirection: direction, child: child!),
        ),
        home: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [child, const Text('below')],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Decorator decoratorOf(WidgetTester tester) => tester.widget<Decorator>(
    find.descendant(
      of: find.byType(Alert),
      matching: find.byType(Decorator),
    ),
  );

  group('the tinted variants', () {
    test('take their colours from the scheme, and the theme says so', () {
      final theme = ThemeData();
      final scheme = theme.colorScheme;
      final alert = theme.primaryAlertTheme;
      expect(alert.successColor, scheme.success);
      expect(alert.warningColor, scheme.warning);
      expect(alert.infoColor, scheme.tint);
      for (final fill in [
        alert.successBackgroundColor!,
        alert.warningBackgroundColor!,
        alert.infoBackgroundColor!,
      ]) {
        // An opaque wash over the card: not the card, and not see-through.
        expect(fill.a, 1);
        expect(fill, isNot(scheme.card));
      }
    });

    test('their text and their icon read on the tint, in every style and '
        'brightness', () {
      for (final style in styles) {
        for (final brightness in Brightness.values) {
          final theme = ThemeData(style: style, brightness: brightness);
          final alert = theme.primaryAlertTheme;
          final where = '${style.name} ${brightness.name}';
          for (final (name, accent, fill) in [
            ('success', alert.successColor!, alert.successBackgroundColor!),
            ('warning', alert.warningColor!, alert.warningBackgroundColor!),
            ('info', alert.infoColor!, alert.infoBackgroundColor!),
          ]) {
            expect(
              contrast(alert.titleStyle!.color!, fill),
              greaterThanOrEqualTo(4.5),
              reason: 'title on $name, $where',
            );
            expect(
              contrast(over(alert.descriptionStyle!.color!, fill), fill),
              greaterThanOrEqualTo(4.5),
              reason: 'description on $name, $where',
            );
            // A graphic: WCAG's 3:1.
            expect(
              contrast(accent, fill),
              greaterThanOrEqualTo(3),
              reason: 'icon on $name, $where',
            );
          }
        }
      }
    });

    testWidgets('each shows its own icon in its accent on its fill, with '
        'the metrics of the primary alert', (tester) async {
      for (final (variant, icon) in [
        (AlertVariant.success, PhosphorIconsFill.checkCircle),
        (AlertVariant.warning, PhosphorIconsFill.warning),
        (AlertVariant.info, PhosphorIconsFill.info),
      ]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await pump(
          tester,
          Alert(
            variant: variant,
            title: const Text('Title'),
            description: const Text('Description'),
          ),
        );
        final theme = Theme.of(tester.element(find.byType(Alert)));
        final alert = theme.primaryAlertTheme;
        final (accent, fill) = switch (variant) {
          AlertVariant.success => (
            alert.successColor,
            alert.successBackgroundColor,
          ),
          AlertVariant.warning => (
            alert.warningColor,
            alert.warningBackgroundColor,
          ),
          _ => (alert.infoColor, alert.infoBackgroundColor),
        };
        final found = find.byIcon(icon);
        expect(found, findsOneWidget, reason: '$variant');
        final iconTheme = IconTheme.of(tester.element(found));
        expect(iconTheme.color, accent);
        expect(iconTheme.size, alert.iconSize);
        final decoration = decoratorOf(tester).decoration!;
        expect(decoration.color, fill);
        expect(
          decoration.border!.borderRadius,
          alert.decoration!.border!.borderRadius,
        );
        expect(decoration.border!.padding, alert.decoration!.border!.padding);
        // The edge carries the accent.
        final edge = decoration.border!.top!.color!;
        expect(edge.withValues(alpha: 1), accent!.withValues(alpha: 1));
        expect(edge.a, lessThan(1));
      }
    });

    testWidgets('an icon of your own replaces the one the variant brings; '
        'a theme override recolours it', (tester) async {
      await pump(
        tester,
        const Alert(
          variant: AlertVariant.success,
          icon: PhosphorIcon(PhosphorIconsRegular.confetti),
          title: Text('Done'),
        ),
        theme: ThemeData(
          primaryAlertTheme: const AlertTheme(
            successColor: Color(0xff00aa00),
            successBackgroundColor: Color(0xffeeffee),
          ),
        ),
      );
      expect(find.byIcon(PhosphorIconsFill.checkCircle), findsNothing);
      final icon = find.byIcon(PhosphorIconsRegular.confetti);
      expect(
        IconTheme.of(tester.element(icon)).color,
        const Color(0xff00aa00),
      );
      expect(decoratorOf(tester).decoration!.color, const Color(0xffeeffee));
    });

    testWidgets('the primary and destructive alerts are as they were: no '
        'icon unless given one', (tester) async {
      await pump(tester, const Alert(title: Text('Plain')));
      expect(
        find.descendant(
          of: find.byType(Alert),
          matching: find.bySubtype<Icon>(),
        ),
        findsNothing,
      );
      final theme = Theme.of(tester.element(find.byType(Alert)));
      expect(decoratorOf(tester).decoration!.color, theme.colorScheme.card);
    });
  });

  group('dismissal', () {
    testWidgets('without onDismissed there is no close button and nothing '
        'around the alert', (tester) async {
      await pump(tester, const Alert(title: Text('Plain')));
      expect(find.byType(IconButton), findsNothing);
      expect(find.byType(ExpandReveal), findsNothing);
    });

    testWidgets('the close button folds the alert away, what is below '
        'rising smoothly, and only then is onDismissed called', (tester) async {
      var dismissed = 0;
      await pump(
        tester,
        Alert(
          variant: AlertVariant.info,
          title: const Text('Maintenance'),
          description: const Text('Saturday at two.'),
          onDismissed: () => dismissed++,
        ),
      );
      final height = tester.getSize(find.byType(Alert)).height;
      expect(height, greaterThan(40));
      final below = tester.getTopLeft(find.text('below')).dy;

      await tester.tap(find.byType(IconButton));
      await tester.pump();
      expect(dismissed, 0);
      var last = below;
      var moved = false;
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final now = tester.getTopLeft(find.text('below')).dy;
        expect(now, lessThanOrEqualTo(last + .01), reason: 'frame $frame');
        expect(last - now, lessThan(height / 2), reason: 'frame $frame');
        if (now < last) moved = true;
        if (now > below - height + 1) expect(dismissed, 0);
        last = now;
      }
      expect(moved, isTrue);
      expect(last, moreOrLessEquals(below - height, epsilon: .5));
      expect(dismissed, 1);
      await tester.pumpAndSettle();
      expect(dismissed, 1);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a second press while it folds does nothing more', (
      tester,
    ) async {
      var dismissed = 0;
      await pump(
        tester,
        Alert(title: const Text('T'), onDismissed: () => dismissed++),
      );
      final button = tester.getCenter(find.byType(IconButton));
      await tester.tapAt(button);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.tapAt(button);
      await tester.pumpAndSettle();
      expect(dismissed, 1);
    });

    for (final (name, motion, reduce) in <(String, Motion?, bool)>[
      ('reduced motion', null, true),
      ('Motion.none', Motion.none, false),
    ]) {
      testWidgets('$name: it is gone at once', (tester) async {
        var dismissed = 0;
        await pump(
          tester,
          Alert(title: const Text('T'), onDismissed: () => dismissed++),
          reduceMotion: reduce,
          theme: motion == null ? null : ThemeData(motion: motion),
        );
        final below = tester.getTopLeft(find.text('below')).dy;
        await tester.tap(find.byType(IconButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
        expect(dismissed, 1);
        expect(tester.getTopLeft(find.text('below')).dy, lessThan(below));
      });
    }

    testWidgets('the close button is at the end, is named, and works from '
        'the keyboard', (tester) async {
      final handle = tester.ensureSemantics();
      var dismissed = 0;
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(const SizedBox.shrink());
        await pump(
          tester,
          Alert(title: const Text('Title'), onDismissed: () => dismissed++),
          direction: direction,
        );
        final button = tester.getCenter(find.byType(IconButton)).dx;
        final title = tester.getCenter(find.text('Title')).dx;
        expect(
          direction == TextDirection.ltr ? button > title : button < title,
          isTrue,
          reason: '$direction',
        );
      }
      expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(dismissed, 1);
      handle.dispose();
    });

    testWidgets('twice the text size: nothing overflows', (tester) async {
      await pump(
        tester,
        Alert(
          variant: AlertVariant.warning,
          title: const Text('A title that is long enough to wrap around'),
          description: const Text('And a description that does the same.'),
          onDismissed: () {},
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
