import 'package:finesse/finesse.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';
import '../../fixture_styles.dart';
import '../../frame_sampler.dart';

/// Hover, press, release and leave must each take a control straight to its
/// new look. These tests read the screen frame by frame, because the bug they
/// guard against was invisible in the widget tree: every colour handed to
/// the widgets was right, and `Color.lerp` between an opaque fill and a
/// translucent wash still painted a dark grey halfway there.
void main() {
  final themes = <String, ThemeData>{
    'finesse light': ThemeData(),
    'finesse dark': ThemeData(brightness: Brightness.dark),
    'nova light': ThemeData(
      style: StyleTokens.nova,
      colorScheme: const NeutralColorScheme.light(),
    ),
    'nova dark': ThemeData(
      style: StyleTokens.nova,
      colorScheme: const NeutralColorScheme.dark(),
    ),
  };

  Future<FrameSampler> pump(
    WidgetTester tester,
    ThemeData theme,
    Widget child,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 300);
    addTearDown(tester.view.reset);
    final sampler = FrameSampler();
    await tester.pumpWidget(
      sampler.wrap(
        FinesseApp(
          theme: theme,
          darkTheme: theme,
          home: Builder(
            builder: (context) => ColoredBox(
              color: Theme.of(context).colorScheme.background,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    return sampler;
  }

  Future<TestGesture> mouse(WidgetTester tester) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(1, 1));
    addTearDown(gesture.removePointer);
    await tester.pump();
    return gesture;
  }

  /// Runs hover → press → release → leave over [target], sampling [at], and
  /// expects every phase to be monotone.
  Future<void> expectNoFlash(
    WidgetTester tester,
    FrameSampler sampler,
    TestGesture gesture,
    Finder target,
    Offset at,
    String name,
  ) async {
    final center = tester.getCenter(target);

    await gesture.moveTo(center);
    expectMonotone(await sampler.record(tester, at), reason: '$name hover');

    await gesture.down(center);
    expectMonotone(await sampler.record(tester, at), reason: '$name press');

    await gesture.up();
    expectMonotone(await sampler.record(tester, at), reason: '$name release');

    await gesture.moveTo(const Offset(1, 1));
    expectMonotone(await sampler.record(tester, at), reason: '$name leave');
  }

  group('AnimatedFill.lerp', () {
    test('is a cross-fade: linear in what is seen over any backdrop', () {
      const a = Color(0xe6ffffff); // white glass
      const b = Color(0x0b193c4a); // a 4% dark wash
      for (final backdrop in const [
        Color(0xfff3f5f7),
        Color(0xff000000),
        Color(0xffcc3311),
      ]) {
        final from = rgbOf(over(a, backdrop));
        final to = rgbOf(over(b, backdrop));
        for (final t in [.1, .25, .5, .75, .9]) {
          final seen = rgbOf(over(AnimatedFill.lerp(a, b, t)!, backdrop));
          for (var c = 0; c < 3; c++) {
            expect(
              seen[c],
              closeTo(from[c] + (to[c] - from[c]) * t, 1.5),
              reason: 'backdrop $backdrop, t=$t, channel $c',
            );
          }
        }
      }
    });

    test('Color.lerp is not, which is the flash this replaces', () {
      const a = Color(0xe6ffffff);
      const b = Color(0x0b193c4a);
      const page = Color(0xfff3f5f7);
      final mid = rgbOf(over(Color.lerp(a, b, .5)!, page));
      final ends = [rgbOf(over(a, page)), rgbOf(over(b, page))];
      // Darker than both ends by a wide margin.
      expect(mid[0], lessThan(ends[0][0] - 30));
      expect(mid[0], lessThan(ends[1][0] - 30));
    });

    test('a transparent or null end only fades', () {
      const accent = Color(0xffeaf4f6);
      for (final from in const [Color(0x00000000), null]) {
        final half = AnimatedFill.lerp(from, accent, .5)!;
        expect(half.a, closeTo(.5, .01));
        expect(rgbOf(half), rgbOf(accent));
      }
      expect(AnimatedFill.lerp(null, null, .5), isNull);
      expect(AnimatedFill.lerp(accent, null, 1)!.a, 0);
    });

    test('returns its ends exactly', () {
      const a = Color(0x80112233);
      const b = Color(0xff445566);
      expect(AnimatedFill.lerp(a, b, 0)!.toARGB32(), a.toARGB32());
      expect(AnimatedFill.lerp(a, b, 1)!.toARGB32(), b.toARGB32());
    });
  });

  group('AnimatedFill', () {
    testWidgets('starts at its colours and eases to new ones', (tester) async {
      // A theme and nothing else: the fade is its `Motion.fast`, 120 ms.
      final theme = ThemeData();
      Widget fill(Color color, Color? border) => Theme(
        data: theme,
        child: Center(
          child: AnimatedFill(
            color: color,
            borderColor: border,
            child: const SizedBox(width: 40, height: 20),
          ),
        ),
      );
      const red = Color(0xffff0000);
      const blue = Color(0xff0000ff);
      await tester.pumpWidget(fill(red, blue));
      BoxDecoration box() =>
          tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
              as BoxDecoration;
      expect(box().color, red);
      expect((box().border! as Border).top.color, blue);
      // The outline takes its width, like a Container's.
      expect(tester.getSize(find.byType(AnimatedFill)), const Size(42, 22));

      await tester.pumpWidget(fill(blue, red));
      await tester.pump(const Duration(milliseconds: 60));
      expect(box().color, isNot(red));
      expect(box().color, isNot(blue));
      await tester.pump(const Duration(milliseconds: 80));
      expect(box().color!.toARGB32(), blue.toARGB32());
      expect((box().border! as Border).top.color.toARGB32(), red.toARGB32());
    });

    testWidgets('an outline keeps its place while it fades out', (
      tester,
    ) async {
      final theme = ThemeData();
      Widget fill(Color? border) => Theme(
        data: theme,
        child: Center(
          child: AnimatedFill(
            color: const Color(0xffffffff),
            borderColor: border,
            child: const SizedBox(width: 40, height: 20),
          ),
        ),
      );
      await tester.pumpWidget(fill(const Color(0xff000000)));
      await tester.pumpWidget(fill(null));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.getSize(find.byType(AnimatedFill)), const Size(42, 22));
    });
  });

  for (final MapEntry(key: name, value: theme) in themes.entries) {
    group('no flash, $name:', () {
      for (final variant in ChipVariant.values) {
        testWidgets('a ${variant.name} chip', (tester) async {
          var selected = false;
          final sampler = await pump(
            tester,
            theme,
            StatefulBuilder(
              builder: (context, setState) => Chip(
                label: const SizedBox(width: 40),
                variant: variant,
                selected: selected,
                onSelected: (value) => setState(() => selected = value),
              ),
            ),
          );
          final rect = tester.getRect(find.byType(Chip));
          // Inside the pill, clear of the outline and of the label.
          final at = rect.centerLeft + const Offset(7, 0);
          final gesture = await mouse(tester);
          final chip = find.byType(Chip);
          await expectNoFlash(tester, sampler, gesture, chip, at, name);
          expect(selected, isTrue);
          // And once more from the selected state it is now in.
          await expectNoFlash(tester, sampler, gesture, chip, at, name);
        });
      }

      testWidgets('a list tile', (tester) async {
        final sampler = await pump(
          tester,
          theme,
          SizedBox(
            width: 300,
            child: ListTile(title: const Text('Row'), onTap: () {}),
          ),
        );
        final rect = tester.getRect(find.byType(ListTile));
        await expectNoFlash(
          tester,
          sampler,
          await mouse(tester),
          find.byType(ListTile),
          rect.centerRight - const Offset(6, 0),
          name,
        );
      });

      testWidgets('a control built on Pressable and AnimatedFill', (
        tester,
      ) async {
        final sampler = await pump(
          tester,
          theme,
          Pressable(
            onPressed: () {},
            builder: (context, states) {
              final scheme = Theme.of(context).colorScheme;
              return FocusRing(
                visible: states.contains(WidgetState.focused),
                child: AnimatedFill(
                  color: states.contains(WidgetState.pressed)
                      ? scheme.accent
                      : states.contains(WidgetState.hovered)
                      ? scheme.muted
                      : scheme.card,
                  borderColor: scheme.border,
                  child: const SizedBox(width: 120, height: 60),
                ),
              );
            },
          ),
        );
        final rect = tester.getRect(find.byType(Pressable));
        await expectNoFlash(
          tester,
          sampler,
          await mouse(tester),
          find.byType(Pressable),
          rect.center,
          name,
        );
      });

      testWidgets('the floating bottom bar', (tester) async {
        var index = 0;
        final sampler = await pump(
          tester,
          theme,
          StatefulBuilder(
            builder: (context, setState) => BottomNavigationBar(
              floating: true,
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: const [
                NavigationDestination(icon: SizedBox(), label: 'Home'),
                NavigationDestination(icon: SizedBox(), label: 'Jobs'),
                NavigationDestination(icon: SizedBox(), label: 'Me'),
              ],
            ),
          ),
        );
        final gesture = await mouse(tester);
        Offset item(String label) =>
            tester.getCenter(find.bySemanticsLabel(label));

        // Hover and tap the second destination: it fills, the first empties.
        await gesture.moveTo(item('Jobs'));
        expectMonotone(
          await sampler.record(tester, item('Jobs')),
          reason: '$name hover',
        );
        await gesture.down(item('Jobs'));
        await gesture.up();
        final frames = <List<Color>>[[], []];
        for (var i = 0; i < 16; i++) {
          final seen = await sampler.pixels(tester, [
            item('Jobs'),
            item('Home'),
          ]);
          frames[0].add(seen[0]);
          frames[1].add(seen[1]);
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(index, 1);
        expectMonotone(frames[0], reason: '$name select');
        expectMonotone(frames[1], reason: '$name deselect');
        // The deselected item really did change: it lost its fill.
        expect(frames[1].last, isNot(frames[1].first));

        await gesture.moveTo(const Offset(1, 1));
        expectMonotone(
          await sampler.record(tester, item('Jobs')),
          reason: '$name leave',
        );
      });

      testWidgets("a menu's highlight is on its row at once: no glide and "
          'no fade', (tester) async {
        final controller = FinesseContextMenuController();
        addTearDown(controller.dispose);
        final sampler = await pump(
          tester,
          theme,
          Align(
            alignment: const Alignment(0, -.8),
            child: ContextMenu(
              controller: controller,
              constraints: const BoxConstraints(minWidth: 200),
              items: [
                for (final label in ['One', 'Two', 'Three', 'Four'])
                  ContextMenuItem(onPressed: () {}, child: Text(label)),
              ],
              child: const SizedBox(width: 40, height: 20),
            ),
          ),
        );
        controller.show();
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        final gesture = await mouse(tester);
        // Past the label, where only the row's fill is painted.
        Offset row(String label) {
          final item = tester.getRect(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(ContextMenuItem),
            ),
          );
          return Offset(item.right - 12, item.center.dy);
        }

        final rows = [row('One'), row('Two'), row('Three')];
        final rest = await sampler.pixels(tester, rows);

        // The frame after the pointer arrives already shows the highlight
        // at full strength, and it never changes after that.
        await gesture.moveTo(rows[0]);
        await tester.pump();
        final lit = await sampler.pixel(tester, rows[0]);
        expect(lit, isNot(rest[0]), reason: '$name: no highlight');
        for (final frame in await sampler.record(tester, rows[0])) {
          expect(frame, lit, reason: '$name: the highlight fades in');
        }

        // To the row after next: on the next frame the highlight is there,
        // gone from where it was, and it never crossed the row between.
        await gesture.moveTo(rows[2]);
        await tester.pump();
        for (var i = 0; i < 14; i++) {
          final seen = await sampler.pixels(tester, rows);
          expect(seen[0], rest[0], reason: '$name: frame $i, left behind');
          expect(seen[1], rest[1], reason: '$name: frame $i, passing over');
          expect(seen[2], lit, reason: '$name: frame $i, not arrived');
          await tester.pump(const Duration(milliseconds: 16));
        }

        // And it is gone the frame after the pointer leaves.
        await gesture.moveTo(const Offset(1, 1));
        await tester.pump();
        for (final frame in await sampler.record(tester, rows[2])) {
          expect(frame, rest[2], reason: '$name: the highlight fades out');
        }
      });
    });
  }

  group('focus ring', () {
    /// Whether any [FocusRing] under [finder] is showing.
    bool ringShown(WidgetTester tester, Finder finder) => tester
        .widgetList<FocusRing>(
          find.descendant(of: finder, matching: find.byType(FocusRing)),
        )
        .any((ring) => ring.visible);

    testWidgets('a mouse click never shows it; the keyboard does', (
      tester,
    ) async {
      // As on a desktop: rings are allowed, so only focus decides.
      useTraditionalHighlights();
      var selected = false;
      var index = 0;
      await pump(
        tester,
        ThemeData(),
        StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              Chip(
                label: const Text('Remote'),
                selected: selected,
                onSelected: (value) => setState(() => selected = value),
              ),
              SizedBox(
                width: 200,
                child: ListTile(title: const Text('Row'), onTap: () {}),
              ),
              BottomNavigationBar(
                floating: true,
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                destinations: const [
                  NavigationDestination(icon: SizedBox(), label: 'Home'),
                  NavigationDestination(icon: SizedBox(), label: 'Jobs'),
                ],
              ),
            ],
          ),
        ),
      );
      final gesture = await mouse(tester);
      final all = find.byType(Column);
      for (final target in [
        find.byType(Chip),
        find.byType(ListTile),
        find.bySemanticsLabel('Jobs'),
      ]) {
        await gesture.moveTo(tester.getCenter(target));
        await tester.pump();
        await gesture.down(tester.getCenter(target));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(ringShown(tester, all), isFalse, reason: 'down, $target');
        }
        await gesture.up();
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(ringShown(tester, all), isFalse, reason: 'up, $target');
        }
      }
      expect(selected, isTrue);
      expect(index, 1);

      // Tab reaches the first control and rings it.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(ringShown(tester, find.byType(Chip)), isTrue);
    });
  });

  test('the fixture styles are still importable', () {
    // Keeps this file honest about which styles it walks: the shadcn
    // fixtures live beside it and are not part of the package.
    expect(FixtureStyles.vega, isNotNull);
  });
}
