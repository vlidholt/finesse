import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  const target = SizedBox(key: Key('target'), width: 24, height: 24);

  /// The painted badge: the pill or the dot.
  Finder badgeBox() => find.descendant(
    of: find.byType(IndicatorBadge),
    matching: find.byWidgetPredicate(
      (w) => w is DecoratedBox && w.decoration is ShapeDecoration,
    ),
  );

  ShapeDecoration decorationOf(WidgetTester tester) =>
      tester.widget<DecoratedBox>(badgeBox()).decoration as ShapeDecoration;

  group('IndicatorBadgeTheme', () {
    test('is an 18px destructive pill ringed in the card colour', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final badge = theme.indicatorBadgeTheme;
        expect(badge.size, 18);
        expect(badge.dotSize, 10);
        expect(badge.padding, const EdgeInsets.symmetric(horizontal: 5));
        expect(badge.backgroundColor, theme.colorScheme.destructive);
        expect(badge.foregroundColor, theme.colorScheme.destructiveForeground);
        expect(badge.ringColor, theme.colorScheme.card);
        expect(badge.ringWidth, 2);
        expect(badge.textStyle!.fontSize, 11);
        expect(badge.textStyle!.fontWeight, FontWeight.w600);
        // One line exactly as tall as the pill, so the digits are centred.
        expect(badge.textStyle!.fontSize! * badge.textStyle!.height!, 18);
      }
    });
  });

  group('IndicatorBadge count', () {
    testWidgets('shows the count', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, child: target)),
      );
      expect(find.text('3'), findsOneWidget);
      expect(find.byKey(const Key('target')), findsOneWidget);
    });

    testWidgets('shows 99+ above the maximum', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 100, child: target)),
      );
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('100'), findsNothing);

      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 12345, child: target)),
      );
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('shows the maximum itself in full', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 99, child: target)),
      );
      expect(find.text('99'), findsOneWidget);
      expect(find.text('99+'), findsNothing);
    });

    testWidgets('maxCount moves the cut-off', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(count: 10, maxCount: 9, child: target),
        ),
      );
      expect(find.text('9+'), findsOneWidget);

      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(count: 150, maxCount: 999, child: target),
        ),
      );
      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('hides on zero, leaving only the child', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 0, child: target)),
      );
      expect(find.text('0'), findsNothing);
      expect(badgeBox(), findsNothing);
      expect(find.byKey(const Key('target')), findsOneWidget);
      // No stack, no overlay: the widget is its child.
      expect(
        find.descendant(
          of: find.byType(IndicatorBadge),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );
      expect(tester.getSize(find.byType(IndicatorBadge)), const Size(24, 24));
    });

    testWidgets('hides on a negative count', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: -2, child: target)),
      );
      expect(badgeBox(), findsNothing);
    });

    testWidgets('showZero keeps a zero visible', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(count: 0, showZero: true, child: target),
        ),
      );
      expect(find.text('0'), findsOneWidget);
      expect(badgeBox(), findsOneWidget);
    });

    testWidgets('a zero count with no child takes no space', (tester) async {
      await pumpFinesse(tester, const Center(child: IndicatorBadge(count: 0)));
      expect(tester.getSize(find.byType(IndicatorBadge)), Size.zero);
    });

    testWidgets('visible: false hides a count, a label and a dot alike', (
      tester,
    ) async {
      for (final badge in const [
        IndicatorBadge(count: 5, visible: false, child: target),
        IndicatorBadge(label: Text('new'), visible: false, child: target),
        IndicatorBadge(visible: false, child: target),
      ]) {
        await pumpFinesse(tester, Center(child: badge));
        expect(badgeBox(), findsNothing);
        expect(find.byKey(const Key('target')), findsOneWidget);
      }
    });

    testWidgets('appears and disappears as the count changes', (tester) async {
      Future<void> pump(int count) => pumpFinesse(
        tester,
        Center(
          child: IndicatorBadge(count: count, child: target),
        ),
      );
      await pump(0);
      expect(badgeBox(), findsNothing);
      await pump(2);
      expect(find.text('2'), findsOneWidget);
      await pump(0);
      expect(badgeBox(), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('IndicatorBadge shape', () {
    testWidgets('with neither count nor label it is a dot', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(child: target)),
      );
      expect(find.byType(Text), findsNothing);
      expect(tester.getSize(badgeBox()), const Size.square(10));
      expect(decorationOf(tester).shape, isA<StadiumBorder>());
    });

    testWidgets('a single digit is a circle of the theme size', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, child: target)),
      );
      // The digit is narrower than the minimum width, so the pill is round.
      final size = tester.getSize(badgeBox());
      expect(size.height, 18);
      expect(size.width, greaterThanOrEqualTo(18));
    });

    testWidgets('a longer count widens into a pill, never taller', (
      tester,
    ) async {
      await pumpFinesse(tester, const Center(child: IndicatorBadge(count: 3)));
      final one = tester.getSize(badgeBox());
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 250)),
      );
      final many = tester.getSize(badgeBox());

      expect(many.height, 18);
      expect(many.width, greaterThan(one.width));
      // The text plus 5 of padding each side.
      expect(many.width, tester.getSize(find.text('99+')).width + 10);
    });

    testWidgets("a badge on a small child is not squeezed to the child's "
        'width', (tester) async {
      // The badge is free-standing here…
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 250)),
      );
      final alone = tester.getSize(badgeBox());
      final aloneText = tester.getSize(find.text('99+'));

      // …and pinned to a 24px icon here. It overhangs the icon; it must not
      // be laid out inside the icon's 24px and clip its own digits.
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 250, child: target)),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.text('99+')), aloneText);
      expect(tester.getSize(badgeBox()), alone);
    });

    testWidgets('size sets the pill height and the dot diameter', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 1, size: 24)),
      );
      expect(tester.getSize(badgeBox()).height, 24);

      await pumpFinesse(tester, const Center(child: IndicatorBadge(size: 6)));
      expect(tester.getSize(badgeBox()), const Size.square(6));
    });

    testWidgets('a label replaces the count', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(count: 7, label: Text('new'), child: target),
        ),
      );
      expect(find.text('new'), findsOneWidget);
      expect(find.text('7'), findsNothing);
      expect(tester.getSize(badgeBox()).height, 18);
    });

    testWidgets('without a child it is laid out on its own', (tester) async {
      await pumpFinesse(tester, const Center(child: IndicatorBadge(count: 3)));
      expect(
        find.descendant(
          of: find.byType(IndicatorBadge),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );
      // It takes exactly the pill's space — the ring is painted outside it.
      expect(
        tester.getSize(find.byType(IndicatorBadge)),
        tester.getSize(badgeBox()),
      );
    });
  });

  group('IndicatorBadge colours', () {
    testWidgets('takes the destructive pair and a card-coloured ring', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          const Center(child: IndicatorBadge(count: 3, child: target)),
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(IndicatorBadge)).colorScheme;
        final decoration = decorationOf(tester);
        final shape = decoration.shape as StadiumBorder;

        expect(decoration.color, s.destructive, reason: '$brightness');
        expect(shape.side.color, s.card);
        expect(shape.side.width, 2);
        // Outside the pill, so it does not eat into the 18px.
        expect(shape.side.strokeAlign, BorderSide.strokeAlignOutside);
        expect(
          DefaultTextStyle.of(tester.element(find.text('3'))).style.color,
          s.destructiveForeground,
        );
      }
    });

    testWidgets('color, foregroundColor, ringColor and ringWidth override', (
      tester,
    ) async {
      const fill = Color(0xff00aa55);
      const text = Color(0xff001122);
      const ring = Color(0xff334455);
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(
            count: 3,
            color: fill,
            foregroundColor: text,
            ringColor: ring,
            ringWidth: 4,
            child: target,
          ),
        ),
      );
      final decoration = decorationOf(tester);
      final shape = decoration.shape as StadiumBorder;
      expect(decoration.color, fill);
      expect(shape.side.color, ring);
      expect(shape.side.width, 4);
      expect(
        DefaultTextStyle.of(tester.element(find.text('3'))).style.color,
        text,
      );
    });

    testWidgets('a ring width of zero removes the ring', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, ringWidth: 0)),
      );
      expect(
        (decorationOf(tester).shape as StadiumBorder).side,
        BorderSide.none,
      );
    });

    testWidgets("the ring does not change the badge's size", (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, ringWidth: 0)),
      );
      final bare = tester.getSize(badgeBox());
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, ringWidth: 6)),
      );
      expect(tester.getSize(badgeBox()), bare);
    });
  });

  group('IndicatorBadge position', () {
    testWidgets('does not change the size of the widget it is pinned to', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, child: target)),
      );
      expect(tester.getSize(find.byType(IndicatorBadge)), const Size(24, 24));
      expect(
        tester.getSize(find.byKey(const Key('target'))),
        const Size(24, 24),
      );
    });

    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: [
              IndicatorBadge(count: 3, child: target),
              IndicatorBadge(count: 250, child: target),
              IndicatorBadge(child: target),
              IndicatorBadge(count: 12),
            ],
          ),
        ),
      );
    });

    testWidgets('sits on the top end corner, hanging 35% of itself outside', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(child: target)),
      );
      final child = tester.getRect(find.byKey(const Key('target')));
      final dot = tester.getRect(badgeBox());

      // A 10px dot aligned into the corner, then pushed 3.5px up and out.
      expect(dot.right, closeTo(child.right + 3.5, 1e-6));
      expect(dot.top, closeTo(child.top - 3.5, 1e-6));
    });

    testWidgets('mirrors to the top start corner in right-to-left', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(child: target)),
        textDirection: TextDirection.rtl,
      );
      final child = tester.getRect(find.byKey(const Key('target')));
      final dot = tester.getRect(badgeBox());

      expect(dot.left, closeTo(child.left - 3.5, 1e-6));
      expect(dot.top, closeTo(child.top - 3.5, 1e-6));
    });

    testWidgets('alignment picks another corner', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(
            alignment: AlignmentDirectional.bottomEnd,
            child: target,
          ),
        ),
      );
      final child = tester.getRect(find.byKey(const Key('target')));
      final dot = tester.getRect(badgeBox());
      expect(dot.right, closeTo(child.right + 3.5, 1e-6));
      expect(dot.bottom, closeTo(child.bottom + 3.5, 1e-6));
    });

    testWidgets('an overhang of zero keeps the badge inside the child', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(
            overhang: 0,
            alignment: AlignmentDirectional.bottomEnd,
            child: target,
          ),
        ),
      );
      final child = tester.getRect(find.byKey(const Key('target')));
      final dot = tester.getRect(badgeBox());
      expect(dot.right, child.right);
      expect(dot.bottom, child.bottom);
    });

    testWidgets('offset nudges it: positive x towards the end, positive y '
        'down', (tester) async {
      Future<Rect> dotWith(Offset offset, TextDirection direction) async {
        await pumpFinesse(
          tester,
          Center(
            child: IndicatorBadge(offset: offset, child: target),
          ),
          textDirection: direction,
        );
        return tester.getRect(badgeBox());
      }

      final ltr = await dotWith(Offset.zero, TextDirection.ltr);
      final ltrMoved = await dotWith(const Offset(4, 2), TextDirection.ltr);
      expect(ltrMoved.left, closeTo(ltr.left + 4, 1e-6));
      expect(ltrMoved.top, closeTo(ltr.top + 2, 1e-6));

      final rtl = await dotWith(Offset.zero, TextDirection.rtl);
      final rtlMoved = await dotWith(const Offset(4, 2), TextDirection.rtl);
      // The end is on the left now.
      expect(rtlMoved.left, closeTo(rtl.left - 4, 1e-6));
      expect(rtlMoved.top, closeTo(rtl.top + 2, 1e-6));
    });

    testWidgets('the overhang is not clipped by the stack', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, child: target)),
      );
      final stack = tester.widget<Stack>(
        find.descendant(
          of: find.byType(IndicatorBadge),
          matching: find.byType(Stack),
        ),
      );
      expect(stack.clipBehavior, Clip.none);
    });
  });

  group('IndicatorBadge semantics', () {
    testWidgets('the count is read as text by default', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(child: IndicatorBadge(count: 3, child: target)),
      );
      expect(find.bySemanticsLabel('3'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('semanticLabel replaces the bare number', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(
            count: 3,
            semanticLabel: '3 unread messages',
            child: target,
          ),
        ),
      );
      expect(find.bySemanticsLabel('3 unread messages'), findsOneWidget);
      expect(find.bySemanticsLabel('3'), findsNothing);
      handle.dispose();
    });

    testWidgets('a dot can be given a meaning', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        const Center(
          child: IndicatorBadge(semanticLabel: 'Online', child: target),
        ),
      );
      expect(find.bySemanticsLabel('Online'), findsOneWidget);
      handle.dispose();
    });
  });
}
