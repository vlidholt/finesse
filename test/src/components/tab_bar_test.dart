import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  const labels = ['Posts', 'About', 'Jobs'];

  Widget bar({
    int selectedIndex = 0,
    ValueChanged<int>? onSelected,
    bool expand = true,
    bool showBorder = true,
    double width = 360,
    double? height,
    Color? indicatorColor,
    EdgeInsetsGeometry? tabPadding,
    List<String> tabs = labels,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        child: TabBar(
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          expand: expand,
          showBorder: showBorder,
          height: height,
          indicatorColor: indicatorColor,
          tabPadding: tabPadding,
          tabs: [for (final label in tabs) Text(label)],
        ),
      ),
    );
  }

  /// The line under the selected tab.
  Finder indicator() => find.descendant(
    of: find.byType(Positioned),
    matching: find.byType(DecoratedBox),
  );

  TextStyle styleOf(WidgetTester tester, String label) =>
      DefaultTextStyle.of(tester.element(find.text(label))).style;

  group('TabBar layout', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => Column(
          children: [
            TabBar(
              selectedIndex: 1,
              onSelected: (_) {},
              tabs: const [Text('Posts'), Text('About'), Text('Jobs')],
            ),
            TabBar(
              selectedIndex: 0,
              expand: false,
              onSelected: (_) {},
              tabs: const [Text('One'), Text('Two')],
            ),
          ],
        ),
      );
    });

    testWidgets("is the style's underline tab height tall", (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(tester, bar(), formFactor: formFactor);
        final theme = themeOf(tester, find.byType(TabBar));
        expect(theme.style.underlineTabHeight, 48);
        expect(tester.getSize(find.byType(TabBar)), const Size(360, 48));
      }
    });

    testWidgets('height overrides it', (tester) async {
      await pumpFinesse(tester, bar(height: 40));
      expect(tester.getSize(find.byType(TabBar)).height, 40);
    });

    testWidgets('expanded tabs share the width equally, in reading order', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(tester, bar(), textDirection: direction);
        final box = tester.getRect(find.byType(TabBar));
        final tabs = [
          for (var i = 0; i < 3; i++)
            tester.getRect(find.byType(Pressable).at(i)),
        ];
        for (final tab in tabs) {
          expect(tab.width, 120);
          expect(tab.height, 48);
        }
        if (direction == TextDirection.ltr) {
          expect(tabs[0].left, box.left);
          expect(tabs[2].right, box.right);
        } else {
          expect(tabs[0].right, box.right);
          expect(tabs[2].left, box.left);
        }
        // Labels are centred in their tab.
        expect(
          tester.getCenter(find.text('Posts')).dx,
          closeTo(tabs[0].center.dx, .5),
        );
        expect(
          tester.getCenter(find.text('Posts')).dy,
          closeTo(tabs[0].center.dy, .5),
        );
      }
    });

    testWidgets('unexpanded tabs are as wide as their label plus padding', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(expand: false));
      for (var i = 0; i < 3; i++) {
        final tab = tester.getSize(find.byType(Pressable).at(i));
        final label = tester.getSize(find.text(labels[i]));
        expect(tab.width, label.width + 32);
      }
      // They start at the leading edge rather than spreading out.
      expect(
        tester.getRect(find.byType(Pressable).first).left,
        tester.getRect(find.byType(TabBar)).left,
      );
    });

    testWidgets('tabPadding sets the padding of unexpanded tabs', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(
          expand: false,
          tabPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      );
      final tab = tester.getSize(find.byType(Pressable).first);
      expect(tab.width, tester.getSize(find.text('Posts')).width + 8);
    });

    testWidgets('unexpanded tabs that do not fit scroll instead of '
        'overflowing', (tester) async {
      await pumpFinesse(
        tester,
        bar(
          expand: false,
          width: 200,
          tabs: const ['Overview', 'Experience', 'Education', 'Portfolio'],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.getSize(find.byType(TabBar)).width, 200);

      final box = tester.getRect(find.byType(TabBar));
      final last = find.text('Portfolio');
      expect(tester.getRect(last).left, greaterThan(box.right));

      await tester.drag(find.byType(TabBar), const Offset(-2000, 0));
      await tester.pump();
      // Scrolled to its end, the last tab is flush with the bar's edge.
      expect(
        tester.getRect(find.byType(Pressable).last).right,
        closeTo(box.right, .5),
      );
      expect(tester.getRect(find.text('Overview')).right, lessThan(box.left));
    });

    testWidgets('expanded labels truncate when the bar is narrow', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(
          width: 240,
          tabs: const ['Overview', 'Experience', 'Education', 'Portfolio'],
        ),
      );
      expect(tester.takeException(), isNull);
      final text = tester.widget<RichText>(
        find.descendant(
          of: find.text('Experience'),
          matching: find.byType(RichText),
        ),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('one tab and no tabs both build', (tester) async {
      await pumpFinesse(tester, bar(tabs: const ['Only']));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Pressable)).width, 360);

      await pumpFinesse(tester, bar(tabs: const []));
      expect(tester.takeException(), isNull);
    });
  });

  group('TabBar selection', () {
    testWidgets('a tap reports the index of the tab', (tester) async {
      final taps = <int>[];
      await pumpFinesse(tester, bar(onSelected: taps.add));

      await tester.tap(find.text('Jobs'));
      await tester.tap(find.text('About'));
      await tester.tap(find.text('Posts'));
      expect(taps, [2, 1, 0]);
    });

    testWidgets('the whole tab is the target, not only its label', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpFinesse(tester, bar(onSelected: taps.add));
      final second = tester.getRect(find.byType(Pressable).at(1));
      await tester.tapAt(second.topLeft + const Offset(3, 3));
      expect(taps, [1]);
    });

    testWidgets('it reports and nothing more: the caller moves the '
        'selection', (tester) async {
      var index = 0;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => bar(
            selectedIndex: index,
            onSelected: (i) => setState(() => index = i),
          ),
        ),
      );
      expect(tester.widget<TabBar>(find.byType(TabBar)).selectedIndex, 0);

      await tester.tap(find.text('Jobs'));
      await settle(tester);
      expect(tester.widget<TabBar>(find.byType(TabBar)).selectedIndex, 2);
      expect(styleOf(tester, 'Jobs').fontWeight, FontWeight.w600);
      expect(styleOf(tester, 'Posts').fontWeight, FontWeight.w500);
    });

    testWidgets('Tab moves between the tabs; Enter and Space select', (
      tester,
    ) async {
      final taps = <int>[];
      await pumpFinesse(tester, bar(onSelected: taps.add));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, [0, 1, 2]);
    });

    testWidgets('without onSelected the tabs are inert', (tester) async {
      await pumpFinesse(tester, bar());
      await tester.tap(find.text('Jobs'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<Pressable>()),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('TabBar colours', () {
    testWidgets('the selected tab is semibold in the foreground; the others '
        'medium and muted', (tester) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          bar(selectedIndex: 1, onSelected: (_) {}),
          theme: ThemeData(brightness: brightness),
        );
        final s = themeOf(tester, find.byType(TabBar)).colorScheme;

        expect(styleOf(tester, 'About').color, s.foreground);
        expect(styleOf(tester, 'About').fontWeight, FontWeight.w600);
        for (final other in ['Posts', 'Jobs']) {
          expect(styleOf(tester, other).color, s.mutedForeground);
          expect(styleOf(tester, other).fontWeight, FontWeight.w500);
        }
      }
    });

    testWidgets('moving the selection moves the colours', (tester) async {
      await pumpFinesse(tester, bar(onSelected: (_) {}));
      final selected = styleOf(tester, 'Posts').color;
      final unselected = styleOf(tester, 'Jobs').color;
      expect(selected, isNot(unselected));

      await pumpFinesse(tester, bar(selectedIndex: 2, onSelected: (_) {}));
      expect(styleOf(tester, 'Jobs').color, selected);
      expect(styleOf(tester, 'Posts').color, unselected);
    });

    testWidgets('hover brings an unselected tab to the foreground', (
      tester,
    ) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, bar(onSelected: (_) {}));
      final s = themeOf(tester, find.byType(TabBar)).colorScheme;
      expect(styleOf(tester, 'Jobs').color, s.mutedForeground);

      final gesture = await hoverAt(
        tester,
        tester.getCenter(find.text('Jobs')),
      );
      expect(styleOf(tester, 'Jobs').color, s.foreground);
      // Hover does not change the weight, so the label does not shift.
      expect(styleOf(tester, 'Jobs').fontWeight, FontWeight.w500);

      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(styleOf(tester, 'Jobs').color, s.mutedForeground);
    });

    testWidgets('the labels use the large text style on a tight line', (
      tester,
    ) async {
      await pumpFinesse(tester, bar());
      final theme = themeOf(tester, find.byType(TabBar));
      expect(styleOf(tester, 'Posts').fontSize, theme.textTheme.large.fontSize);
      expect(styleOf(tester, 'Posts').height, 1);
    });
  });

  group('TabBar indicator', () {
    testWidgets('there is exactly one, under the selected tab', (tester) async {
      for (final direction in TextDirection.values) {
        for (var selected = 0; selected < 3; selected++) {
          await pumpFinesse(
            tester,
            bar(selectedIndex: selected),
            textDirection: direction,
          );
          expect(indicator(), findsOneWidget);
          final tab = tester.getRect(find.byType(Pressable).at(selected));
          final line = tester.getRect(indicator());
          expect(line.left, tab.left);
          expect(line.right, tab.right);
          expect(line.height, 2);
        }
      }
    });

    testWidgets('an out-of-range selection shows none', (tester) async {
      await pumpFinesse(tester, bar(selectedIndex: 7));
      expect(indicator(), findsNothing);
      expect(tester.takeException(), isNull);
      await pumpFinesse(tester, bar(selectedIndex: -1));
      expect(indicator(), findsNothing);
    });

    testWidgets('is drawn in the foreground colour, or the one it is given', (
      tester,
    ) async {
      await pumpFinesse(tester, bar());
      final s = themeOf(tester, find.byType(TabBar)).colorScheme;
      BoxDecoration decoration() =>
          tester.widget<DecoratedBox>(indicator()).decoration as BoxDecoration;
      expect(decoration().color, s.foreground);

      const colour = Color(0xff0077cc);
      await pumpFinesse(tester, bar(indicatorColor: colour));
      expect(decoration().color, colour);
    });

    testWidgets("sits on the bar's bottom edge, inside the bar", (
      tester,
    ) async {
      for (final showBorder in [true, false]) {
        await pumpFinesse(tester, bar(showBorder: showBorder));
        final box = tester.getRect(find.byType(TabBar));
        final line = tester.getRect(indicator());

        // Flush with the bottom — over the hairline when there is one — and
        // never below it: a bar in a clipped card or a list would lose the
        // part that hangs out, and anything under the bar would be painted
        // over.
        expect(line.bottom, box.bottom, reason: 'showBorder: $showBorder');
        expect(line.top, box.bottom - 2, reason: 'showBorder: $showBorder');
      }
    });

    testWidgets('the hairline runs under the whole bar', (tester) async {
      await pumpFinesse(tester, bar());
      final s = themeOf(tester, find.byType(TabBar)).colorScheme;
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(TabBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final border = (box.decoration as BoxDecoration).border! as Border;
      expect(border.bottom.color, s.border);
      expect(border.bottom.width, 1);
      expect(border.top, BorderSide.none);
      // The hairline is painted inside the bar's height, not added to it.
      expect(tester.getSize(find.byType(TabBar)).height, 48);
    });

    testWidgets('showBorder: false removes the hairline, not the height', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(showBorder: false));
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(TabBar),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect((box.decoration as BoxDecoration).border, isNull);
      expect(tester.getSize(find.byType(TabBar)).height, 48);
    });
  });

  group('TabBar focus and semantics', () {
    testWidgets('keyboard focus rings the focused tab', (tester) async {
      useTraditionalHighlights();
      await pumpFinesse(tester, bar(onSelected: (_) {}));
      expect(
        tester
            .widgetList<FocusRing>(find.byType(FocusRing))
            .map((r) => r.visible),
        [false, false, false],
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .widgetList<FocusRing>(find.byType(FocusRing))
            .map((r) => r.visible),
        [true, false, false],
      );
    });

    testWidgets('each tab is a button, and the selected one says so', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, bar(selectedIndex: 1, onSelected: (_) {}));

      for (var i = 0; i < 3; i++) {
        final data = tester
            .getSemantics(find.byType(Pressable).at(i))
            .getSemanticsData();
        expect(data.label, labels[i]);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
        expect(
          data.flagsCollection.isSelected,
          i == 1 ? ui.Tristate.isTrue : ui.Tristate.none,
        );
      }
      handle.dispose();
    });

    testWidgets('the tabs are separate nodes, not one merged label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, bar(onSelected: (_) {}));
      expect(find.bySemanticsLabel('Posts'), findsOneWidget);
      expect(find.bySemanticsLabel('About'), findsOneWidget);
      expect(find.bySemanticsLabel('Jobs'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('inert tabs are disabled buttons', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, bar());
      final data = tester
          .getSemantics(find.byType(Pressable).first)
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      handle.dispose();
    });
  });
}
