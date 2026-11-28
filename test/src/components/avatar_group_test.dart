import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

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

  /// Avatar [i] itself: the clipped circle inside its ring.
  Finder avatarOf(int i) => find.ancestor(
    of: find.byKey(Key('face$i')),
    matching: find.byType(ClipOval),
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

    testWidgets('is as wide as its overlapping avatars; the rings are '
        'painted outside the box', (tester) async {
      await pumpUna(
        tester,
        Center(
          child: AvatarGroup(children: [for (var i = 0; i < 3; i++) face(i)]),
        ),
      );
      // 24px avatars, each sliding a quarter under the one before: a step of
      // 18. The 2px ring is not part of the layout box.
      expect(
        tester.getSize(find.byType(AvatarGroup)),
        const Size(24 + 18 * 2, 24),
      );
      // The stack must not clip what it paints outside itself.
      final stack = tester.widget<Stack>(
        find.descendant(
          of: find.byType(AvatarGroup),
          matching: find.byType(Stack),
        ),
      );
      expect(stack.clipBehavior, Clip.none);
    });

    testWidgets('ringInLayout: true makes room for the rings', (tester) async {
      await pumpUna(
        tester,
        Center(
          child: AvatarGroup(
            ringInLayout: true,
            children: [for (var i = 0; i < 3; i++) face(i)],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(AvatarGroup)),
        const Size(24 + 18 * 2 + 4, 24 + 4),
      );
    });

    testWidgets('one avatar is just that avatar; with ringInLayout, that '
        'avatar and its ring', (tester) async {
      await pumpUna(
        tester,
        Center(child: AvatarGroup(children: [face(0)])),
      );
      expect(tester.getSize(find.byType(AvatarGroup)), const Size.square(24));
      expect(
        tester.getRect(avatarOf(0)),
        tester.getRect(find.byType(AvatarGroup)),
      );

      await pumpUna(
        tester,
        Center(child: AvatarGroup(ringInLayout: true, children: [face(0)])),
      );
      expect(tester.getSize(find.byType(AvatarGroup)), const Size.square(28));
      expect(
        tester.getRect(ringOf(0)),
        tester.getRect(find.byType(AvatarGroup)),
      );
    });

    testWidgets('no avatars take no space', (tester) async {
      await pumpUna(
        tester,
        const Center(child: AvatarGroup(children: [])),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AvatarGroup)), Size.zero);
    });

    testWidgets('forces every child to the size, whatever its own', (
      tester,
    ) async {
      await pumpUna(
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
      await pumpUna(
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

    testWidgets('lays the avatars out in reading order, a step apart, with '
        "the first avatar's edge on the group's edge", (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(
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
        final avatars = [
          for (var i = 0; i < 3; i++) tester.getRect(avatarOf(i)),
        ];

        // `size + step * (n - 1)` wide and `size` tall: no ring in the box.
        expect(group.size, const Size(40 + 30 * 2, 40), reason: '$direction');
        for (final (i, ring) in rings.indexed) {
          // Each ring sits 2px outside its avatar all round, so the rings
          // stick out of the group's box by their own width.
          expect(ring.size, const Size.square(44), reason: '$direction $i');
          expect(ring.top, group.top - 2, reason: '$direction $i');
          expect(ring, avatars[i].inflate(2), reason: '$direction $i');
          expect(avatars[i].top, group.top, reason: '$direction $i');
          expect(avatars[i].bottom, group.bottom, reason: '$direction $i');
        }
        if (direction == TextDirection.ltr) {
          expect(avatars[0].left, group.left);
          expect(avatars[1].left, group.left + 30);
          expect(avatars[2].left, group.left + 60);
          expect(avatars[2].right, group.right);
          expect(rings[0].left, group.left - 2);
          expect(rings[2].right, group.right + 2);
        } else {
          expect(avatars[0].right, group.right);
          expect(avatars[1].right, group.right - 30);
          expect(avatars[2].right, group.right - 60);
          expect(avatars[2].left, group.left);
          expect(rings[0].right, group.right + 2);
          expect(rings[2].left, group.left - 2);
        }
      }
    });

    testWidgets('ringInLayout: true keeps every ring inside the box, in both '
        'directions', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(
          tester,
          Center(
            child: AvatarGroup(
              size: 40,
              overlap: 10,
              ringInLayout: true,
              children: [for (var i = 0; i < 3; i++) face(i)],
            ),
          ),
          textDirection: direction,
        );
        final group = tester.getRect(find.byType(AvatarGroup));
        final rings = [for (var i = 0; i < 3; i++) tester.getRect(ringOf(i))];
        final avatars = [
          for (var i = 0; i < 3; i++) tester.getRect(avatarOf(i)),
        ];

        expect(
          group.size,
          const Size(40 + 30 * 2 + 4, 40 + 4),
          reason: '$direction',
        );
        for (final (i, ring) in rings.indexed) {
          expect(ring.size, const Size.square(44), reason: '$direction $i');
          expect(ring.top, group.top, reason: '$direction $i');
          expect(ring.bottom, group.bottom, reason: '$direction $i');
          expect(ring, avatars[i].inflate(2), reason: '$direction $i');
        }
        if (direction == TextDirection.ltr) {
          expect(rings[0].left, group.left);
          expect(rings[1].left, group.left + 30);
          expect(rings[2].left, group.left + 60);
          expect(rings[2].right, group.right);
        } else {
          expect(rings[0].right, group.right);
          expect(rings[1].right, group.right - 30);
          expect(rings[2].right, group.right - 60);
          expect(rings[2].left, group.left);
        }
      }
    });

    testWidgets('the default overlap is a quarter of the size', (tester) async {
      await pumpUna(
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
      await pumpUna(
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
        await pumpUna(
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
      await pumpUna(
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
      // A wider ring does not change the default box…
      final group = tester.getRect(find.byType(AvatarGroup));
      expect(group.size, const Size(24 + 18, 24));
      expect(
        tester.getRect(ringOf(0)).topLeft,
        group.topLeft.translate(-4, -4),
      );

      // …but it does when the ring is laid out.
      await pumpUna(
        tester,
        Center(
          child: AvatarGroup(
            ringColor: colour,
            ringWidth: 4,
            ringInLayout: true,
            children: [face(0), face(1)],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(AvatarGroup)),
        const Size(24 + 18 + 8, 24 + 8),
      );
    });

    testWidgets('holds real Avatar widgets', (tester) async {
      await pumpUna(
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
      // 20 + a step of 15; the ring is outside the box.
      expect(tester.getSize(find.byType(AvatarGroup)), const Size(35, 20));
    });

    testWidgets('fits in a row without asking for more than its width', (
      tester,
    ) async {
      await pumpUna(
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

    testWidgets('an avatar in the group is clipped once, by the group', (
      tester,
    ) async {
      Iterable<RenderObject> clipsAbove(Finder finder) sync* {
        RenderObject? object = tester.renderObject(finder);
        while (object != null && object is! RenderView) {
          if ((object is RenderClipOval && object.clipBehavior != Clip.none) ||
              (object is RenderClipPath && object.clipBehavior != Clip.none)) {
            yield object;
          }
          object = object.parent;
        }
      }

      Finder picture(String key) => find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(RawImage),
      );

      final photo = MemoryImage(_transparentPixel);
      await pumpUna(
        tester,
        Center(
          child: AvatarGroup(
            children: [
              Avatar.image(photo, key: const Key('plain')),
              // An avatar nested in another still clips itself.
              Avatar(
                null,
                fallback: Stack(
                  children: [
                    const SizedBox.square(dimension: 40),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Avatar.image(
                        photo,
                        key: const Key('nested'),
                        size: const Size.square(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      expect(clipsAbove(picture('plain')), hasLength(1));
      expect(clipsAbove(picture('nested')), hasLength(2));

      // Outside a group an avatar clips its picture itself.
      await pumpUna(
        tester,
        Center(child: Avatar.image(photo, key: const Key('alone'))),
      );
      expect(clipsAbove(picture('alone')), hasLength(1));

      // Initials need no clip at all.
      await pumpUna(
        tester,
        const Center(
          child: Avatar(null, fallback: Text('A', key: Key('initials'))),
        ),
      );
      expect(clipsAbove(find.byKey(const Key('initials'))), isEmpty);
    });
  });
}

/// A one-pixel transparent PNG.
final _transparentPixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);
