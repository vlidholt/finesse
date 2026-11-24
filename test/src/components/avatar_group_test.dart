import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  Widget face(int i, {double size = 40}) => ColoredBox(
    key: Key('face$i'),
    color: Color(0xff000000 + i * 0x303030),
    child: SizedBox.square(dimension: size),
  );

  /// The ring around avatar [i]: the circle its clip sits in.
  Finder ringOf(int i) => find.ancestor(
    of: find.byKey(Key('face$i')),
    matching: find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).shape == BoxShape.circle,
    ),
  );

  group('AvatarGroup', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => Center(
          child: AvatarGroup(children: [for (var i = 0; i < 4; i++) face(i)]),
        ),
        check: (layout) async {
          expect(find.byType(ClipOval), findsNWidgets(4));
        },
      );
    });

    testWidgets('is as wide as its overlapping avatars and their rings', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: AvatarGroup(children: [for (var i = 0; i < 3; i++) face(i)]),
        ),
      );
      // 24px avatars, each sliding a quarter under the one before: a step of
      // 18. Plus a 2px ring all round.
      expect(
        tester.getSize(find.byType(AvatarGroup)),
        const Size(24 + 18 * 2 + 4, 24 + 4),
      );
    });

    testWidgets('one avatar is just that avatar and its ring', (tester) async {
      await pumpFinesse(
        tester,
        Center(child: AvatarGroup(children: [face(0)])),
      );
      expect(tester.getSize(find.byType(AvatarGroup)), const Size.square(28));
    });

    testWidgets('no avatars take no space', (tester) async {
      await pumpFinesse(
        tester,
        const Center(child: AvatarGroup(children: [])),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AvatarGroup)), Size.zero);
    });

    testWidgets('forces every child to the size, whatever its own', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: AvatarGroup(
            size: 20,
            children: [face(0, size: 64), face(1, size: 8), face(2)],
          ),
        ),
      );
      for (final clip in find.byType(ClipOval).evaluate()) {
        expect(clip.size, const Size.square(20));
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('a child that is not square is cropped, not squashed', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const Center(
          child: AvatarGroup(
            children: [SizedBox(key: Key('wide'), width: 80, height: 40)],
          ),
        ),
      );
      final fitted = tester.widget<FittedBox>(find.byType(FittedBox));
      expect(fitted.fit, BoxFit.cover);
      expect(fitted.clipBehavior, Clip.hardEdge);
      expect(tester.getSize(find.byType(ClipOval)), const Size.square(24));
    });

    testWidgets('lays the avatars out in reading order, a step apart', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          Center(
            child: AvatarGroup(
              size: 40,
              overlap: 10,
              children: [for (var i = 0; i < 3; i++) face(i)],
            ),
          ),
          textDirection: direction,
        );
        final group = tester.getRect(find.byType(AvatarGroup));
        final rings = [for (var i = 0; i < 3; i++) tester.getRect(ringOf(i))];

        expect(group.width, 40 + 30 * 2 + 4);
        for (final ring in rings) {
          expect(ring.size, const Size.square(44));
          expect(ring.top, group.top);
        }
        if (direction == TextDirection.ltr) {
          expect(rings[0].left, group.left);
          expect(rings[1].left, group.left + 30);
          expect(rings[2].left, group.left + 60);
        } else {
          expect(rings[0].right, group.right);
          expect(rings[1].right, group.right - 30);
          expect(rings[2].right, group.right - 60);
        }
      }
    });

    testWidgets('the default overlap is a quarter of the size', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: AvatarGroup(size: 40, children: [face(0), face(1)]),
        ),
      );
      expect(
        tester.getRect(ringOf(1)).left - tester.getRect(ringOf(0)).left,
        30,
      );
    });

    testWidgets('paints the first avatar on top', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: AvatarGroup(children: [for (var i = 0; i < 3; i++) face(i)]),
        ),
      );
      // A stack paints its children in order, so the first avatar has to be
      // the last child.
      final stack = tester.widget<Stack>(
        find.descendant(
          of: find.byType(AvatarGroup),
          matching: find.byType(Stack),
        ),
      );
      final order = [
        for (final child in stack.children)
          find.descendant(
            of: find.byWidget(child),
            matching: find.byWidgetPredicate((w) => w is ColoredBox),
          ),
      ];
      expect(tester.widget(order.last).key, const Key('face0'));
      expect(tester.widget(order.first).key, const Key('face2'));
      // And where two overlap, a hit lands on the earlier one.
      final overlap = tester.getRect(ringOf(1)).topLeft + const Offset(3, 14);
      final result = tester.hitTestOnBinding(overlap);
      final hit = result.path
          .map((e) => e.target)
          .whereType<RenderBox>()
          .toList();
      final face0 = tester.renderObject(find.byKey(const Key('face0')));
      final face1 = tester.renderObject(find.byKey(const Key('face1')));
      expect(hit.contains(face0) || !hit.contains(face1), isTrue);
    });

    testWidgets('rings each avatar in the card colour', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          Center(child: AvatarGroup(children: [face(0), face(1)])),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byType(AvatarGroup));
        for (var i = 0; i < 2; i++) {
          final ring = tester.widget<Container>(ringOf(i));
          expect(
            (ring.decoration! as BoxDecoration).color,
            theme.colorScheme.card,
            reason: '$brightness',
          );
          expect(ring.padding, const EdgeInsets.all(2));
        }
      }
    });

    testWidgets('ringColor and ringWidth override', (tester) async {
      const colour = Color(0xff224466);
      await pumpFinesse(
        tester,
        Center(
          child: AvatarGroup(
            ringColor: colour,
            ringWidth: 4,
            children: [face(0), face(1)],
          ),
        ),
      );
      final ring = tester.widget<Container>(ringOf(0));
      expect((ring.decoration! as BoxDecoration).color, colour);
      expect(ring.padding, const EdgeInsets.all(4));
      expect(tester.getSize(ringOf(0)), const Size.square(32));
      expect(
        tester.getSize(find.byType(AvatarGroup)),
        const Size(24 + 18 + 8, 24 + 8),
      );
    });

    testWidgets('holds real Avatar widgets', (tester) async {
      await pumpFinesse(
        tester,
        const Center(
          child: AvatarGroup(
            size: 20,
            children: [
              Avatar.image(null, fallback: Text('A')),
              Avatar.image(null, fallback: Text('B')),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getSize(find.byType(AvatarGroup)), const Size(39, 24));
    });

    testWidgets('fits in a row without asking for more than its width', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarGroup(children: [face(0), face(1)]),
              const Text('2 mutual'),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.text('2 mutual')).left,
        tester.getRect(find.byType(AvatarGroup)).right,
      );
    });
  });
}
