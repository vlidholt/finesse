import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// Tabs whose values are their indices.
List<Tab<int>> tabsOf(List<String> labels) => [
  for (final (index, label) in labels.indexed)
    Tab(value: index, child: Text(label)),
];

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
    TextStyle? labelStyle,
    List<String> tabs = labels,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        // What used to be parameters of the bar is the theme's to say.
        child: Builder(
          builder: (context) => Theme(
            data: Theme.of(context).copyWith(
              tabsTheme: TabsTheme(
                underlineHeight: height,
                underlineColor: indicatorColor,
                underlinePadding: tabPadding,
                underlineTextStyle: labelStyle,
              ),
            ),
            child: TabBar<int>(
              value: selectedIndex,
              onChanged: onSelected,
              expandTabs: expand,
              showBorder: showBorder,
              tabs: tabsOf(tabs),
            ),
          ),
        ),
      ),
    );
  }

  /// Where the line under the selected tab rests: the selected target of
  /// the bar's one travelling indicator.
  Finder indicator() => find.byWidgetPredicate(
    (widget) => widget is MovingIndicatorTarget && widget.selected,
  );

  /// The padding around a tab's label.
  EdgeInsetsGeometry paddingOf(WidgetTester tester, String label) => tester
      .widget<Padding>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Padding))
            .first,
      )
      .padding;

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
            TabBar<int>(
              value: 1,
              onChanged: (_) {},
              tabs: tabsOf(const ['Posts', 'About', 'Jobs']),
            ),
            TabBar<int>(
              value: 0,
              expandTabs: false,
              onChanged: (_) {},
              tabs: tabsOf(const ['One', 'Two']),
            ),
          ],
        ),
      );
    });

    testWidgets("is the style's underline tab height tall, plus the hairline "
        'under the tabs', (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(tester, bar(), formFactor: formFactor);
        final theme = themeOf(tester, find.byType(TabBar<int>));
        expect(theme.style.underlineTabHeight, 48);
        expect(tester.getSize(find.byType(TabBar<int>)), const Size(360, 49));
        // The tabs themselves keep the whole 48.
        for (var i = 0; i < 3; i++) {
          expect(tester.getSize(find.byType(Pressable).at(i)).height, 48);
        }

        await pumpFinesse(
          tester,
          bar(showBorder: false),
          formFactor: formFactor,
        );
        expect(tester.getSize(find.byType(TabBar<int>)), const Size(360, 48));
      }
    });

    testWidgets('height sets the height of the tabs; the hairline is added '
        'to it', (tester) async {
      await pumpFinesse(tester, bar(height: 40));
      expect(tester.getSize(find.byType(TabBar<int>)).height, 41);
      expect(tester.getSize(find.byType(Pressable).first).height, 40);

      await pumpFinesse(tester, bar(height: 40, showBorder: false));
      expect(tester.getSize(find.byType(TabBar<int>)).height, 40);
      expect(tester.getSize(find.byType(Pressable).first).height, 40);
    });

    testWidgets('hugging tabs are the same heights as shared ones', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(expand: false));
      expect(tester.getSize(find.byType(TabBar<int>)).height, 49);
      await pumpFinesse(tester, bar(expand: false, showBorder: false));
      expect(tester.getSize(find.byType(TabBar<int>)).height, 48);
    });

    testWidgets('Tabs drops the hairline under an underline bar as TabBar '
        'does', (tester) async {
      Future<double> height({required bool showBorder}) async {
        await pumpFinesse(
          tester,
          Align(
            alignment: Alignment.topCenter,
            child: Tabs<int>(
              value: 0,
              onChanged: (_) {},
              variant: TabBarVariant.underline,
              showBorder: showBorder,
              tabs: tabsOf(labels),
            ),
          ),
        );
        return tester.getSize(find.byType(Tabs<int>)).height;
      }

      expect(
        await height(showBorder: true) - await height(showBorder: false),
        1,
      );
    });

    testWidgets('expanded tabs share the width equally, in reading order', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(tester, bar(), textDirection: direction);
        final box = tester.getRect(find.byType(TabBar<int>));
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
        tester.getRect(find.byType(TabBar<int>)).left,
      );
    });

    testWidgets('the default tab padding is 4 for tabs that share the width '
        'and 16 for tabs that hug their label', (tester) async {
      for (final formFactor in FormFactor.values) {
        await pumpFinesse(tester, bar(), formFactor: formFactor);
        for (final label in labels) {
          expect(
            paddingOf(tester, label),
            const EdgeInsets.symmetric(horizontal: 4),
            reason: 'expanded, ${formFactor.name}',
          );
        }

        await pumpFinesse(tester, bar(expand: false), formFactor: formFactor);
        for (final label in labels) {
          expect(
            paddingOf(tester, label),
            const EdgeInsets.symmetric(horizontal: 16),
            reason: 'hugging, ${formFactor.name}',
          );
        }
      }
    });

    testWidgets('an expanded label has its whole tab less 4 on each side', (
      tester,
    ) async {
      // Four tabs of 60: a label that needs more than 52 truncates, one
      // that needs less does not.
      await pumpFinesse(
        tester,
        bar(
          width: 240,
          tabs: const ['Overview', 'Experience', 'Education', 'Portfolio'],
        ),
      );
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 4; i++) {
        final tab = tester.getRect(find.byType(Pressable).at(i));
        expect(tab.width, 60);
        final label = tester.getRect(
          find.descendant(
            of: find.byType(Pressable).at(i),
            matching: find.byType(RichText),
          ),
        );
        expect(label.width, lessThanOrEqualTo(52));
        expect(label.left, greaterThanOrEqualTo(tab.left + 4));
        expect(label.right, lessThanOrEqualTo(tab.right - 4));
      }
    });

    testWidgets('tabPadding overrides the default of expanded tabs too', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        bar(tabPadding: const EdgeInsets.symmetric(horizontal: 20)),
      );
      expect(
        paddingOf(tester, 'Posts'),
        const EdgeInsets.symmetric(horizontal: 20),
      );
      // The tabs still share the width; only the label's room changes.
      expect(tester.getSize(find.byType(Pressable).first).width, 120);
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
      expect(tester.getSize(find.byType(TabBar<int>)).width, 200);
      // The tabs that do not fit are clipped at the bar's sides, not
      // painted over whatever sits beside it — by a clip one pixel taller
      // than the tabs, so the indicator can still reach over the hairline.
      final clip = find.ancestor(
        of: find.byType(SingleChildScrollView),
        matching: find.descendant(
          of: find.byType(TabBar<int>),
          matching: find.byType(ClipRect),
        ),
      );
      expect(clip, findsOneWidget);
      expect(tester.getSize(clip), const Size(200, 48));
      expect(
        tester.widget<ClipRect>(clip).clipper!.getClip(const Size(200, 48)),
        const Rect.fromLTWH(0, 0, 200, 49),
      );
      expect(
        clip,
        paints..clipRect(rect: const Rect.fromLTWH(0, 0, 200, 49)),
      );

      final box = tester.getRect(find.byType(TabBar<int>));
      final last = find.text('Portfolio');
      expect(tester.getRect(last).left, greaterThan(box.right));

      await tester.drag(find.byType(TabBar<int>), const Offset(-2000, 0));
      await tester.pump();
      // Scrolled to its end, the last tab is flush with the bar's edge.
      expect(
        tester.getRect(find.byType(Pressable).last).right,
        closeTo(box.right, .5),
      );
      expect(tester.getRect(find.text('Overview')).right, lessThan(box.left));
    });

    testWidgets('scrolled, a tab is cut off at the side of the bar while its '
        'indicator still covers the hairline', (tester) async {
      const red = Color(0xffff0000);
      const white = Color(0xffffffff);
      final boundary = GlobalKey();
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: boundary,
            child: ColoredBox(
              color: white,
              child: Padding(
                // Room on every side for anything that escapes the bar.
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  width: 200,
                  child: Builder(
                    builder: (context) => Theme(
                      data: Theme.of(context).copyWith(
                        tabsTheme: const TabsTheme(underlineColor: red),
                      ),
                      child: TabBar<int>(
                        value: 0,
                        expandTabs: false,
                        onChanged: (_) {},
                        tabs: tabsOf(const [
                          'Overview',
                          'Experience',
                          'Education',
                          'Portfolio',
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      final bar = tester.getRect(find.byType(TabBar<int>));
      expect(bar, const Rect.fromLTWH(40, 40, 200, 49));

      // Scroll the selected tab half way out of the bar's start edge.
      final width = tester.getSize(find.byType(Pressable).first).width;
      await tester.drag(find.byType(TabBar<int>), Offset(-width / 2, 0));
      await tester.pump();
      final tab = tester.getRect(find.byType(Pressable).first);
      expect(tab.left, lessThan(bar.left - 10));
      expect(tab.right, greaterThan(bar.left + 10));

      late final ui.Image image;
      await tester.runAsync(() async {
        image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage();
      });
      final data = (await tester.runAsync(() => image.toByteData()))!;
      addTearDown(image.dispose);
      Color pixel(double x, double y) {
        final index = (y.floor() * image.width + x.floor()) * 4;
        return Color.fromARGB(
          data.getUint8(index + 3),
          data.getUint8(index),
          data.getUint8(index + 1),
          data.getUint8(index + 2),
        );
      }

      // The indicator is two rows: the last of the tabs and the hairline's.
      final lastTabRow = bar.top + 47.5;
      final hairlineRow = bar.top + 48.5;
      // Inside the bar both are the indicator's colour…
      expect(pixel(bar.left + 4.5, lastTabRow), red);
      expect(pixel(bar.left + 4.5, hairlineRow), red, reason: 'over hairline');
      // …and outside it, where the rest of the tab would be, nothing is.
      for (final y in [bar.top + 24, lastTabRow, hairlineRow]) {
        for (final x in [bar.left - 4.5, bar.left - .5, tab.left + 4.5]) {
          expect(pixel(x, y), white, reason: 'left of the bar at ($x, $y)');
        }
      }
      // Past the selected tab the hairline shows, and stops with the bar.
      final theme = themeOf(tester, find.byType(TabBar<int>));
      final hairline = pixel(bar.right - 4.5, hairlineRow);
      expect(hairline, isNot(white));
      expect(hairline, isNot(red));
      expect(
        hairline,
        isSameColorAs(Color.alphaBlend(theme.colorScheme.border, white)),
      );
      expect(pixel(bar.right + 4.5, hairlineRow), white);
      expect(pixel(bar.right + 4.5, bar.top + 24), white);
      // And nothing is painted below the bar's own height.
      expect(pixel(bar.left + 4.5, bar.bottom + .5), white);
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
      // The selected tab has nothing to report.
      await tester.tap(find.text('Posts'));
      expect(taps, [2, 1]);
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
      expect(tester.widget<TabBar<int>>(find.byType(TabBar<int>)).value, 0);

      await tester.tap(find.text('Jobs'));
      await settle(tester);
      expect(tester.widget<TabBar<int>>(find.byType(TabBar<int>)).value, 2);
      expect(styleOf(tester, 'Jobs').fontWeight, FontWeight.w600);
      expect(styleOf(tester, 'Posts').fontWeight, FontWeight.w500);
    });

    testWidgets('the bar is one Tab stop; the arrow keys, Home and End '
        'move the selection', (tester) async {
      for (final direction in TextDirection.values) {
        var index = 1;
        final changes = <int>[];
        await pumpFinesse(
          tester,
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                bar(
                  selectedIndex: index,
                  onSelected: (i) {
                    changes.add(i);
                    setState(() => index = i);
                  },
                ),
                const Focus(child: SizedBox(width: 10, height: 10)),
              ],
            ),
          ),
          textDirection: direction,
        );
        Pressable focused() => FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<Pressable>()!;
        int focusedIndex() => tester
            .widgetList<Pressable>(find.byType(Pressable))
            .toList()
            .indexOf(focused());

        // Tab lands on the selected tab, not the first.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(focusedIndex(), 1);
        final forward = direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.arrowLeft;
        final back = direction == TextDirection.ltr
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight;
        await tester.sendKeyEvent(forward);
        await tester.pump();
        expect((index, focusedIndex()), (2, 2));
        // Past the end it comes round.
        await tester.sendKeyEvent(forward);
        await tester.pump();
        expect((index, focusedIndex()), (0, 0));
        await tester.sendKeyEvent(back);
        await tester.pump();
        expect((index, focusedIndex()), (2, 2));
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pump();
        expect((index, focusedIndex()), (0, 0));
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pump();
        expect((index, focusedIndex()), (2, 2));
        expect(changes, [2, 0, 2, 0, 2]);
        // And Tab leaves the bar instead of walking through it.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          FocusManager.instance.primaryFocus!.context!
              .findAncestorWidgetOfExactType<Pressable>(),
          isNull,
        );
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Enter and Space choose the focused tab', (tester) async {
      final taps = <int>[];
      // Nothing selected: the first tab is the stop.
      await pumpFinesse(tester, bar(selectedIndex: -1, onSelected: taps.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, [0, 0]);
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
        final s = themeOf(tester, find.byType(TabBar<int>)).colorScheme;

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
      final s = themeOf(tester, find.byType(TabBar<int>)).colorScheme;
      expect(styleOf(tester, 'Jobs').color, s.mutedForeground);

      final gesture = await hoverAt(
        tester,
        tester.getCenter(find.text('Jobs')),
      );
      // The colour fades over the theme's fast duration.
      await tester.pump(const Duration(milliseconds: 200));
      expect(styleOf(tester, 'Jobs').color, s.foreground);
      // Hover does not change the weight, so the label does not shift.
      expect(styleOf(tester, 'Jobs').fontWeight, FontWeight.w500);

      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(styleOf(tester, 'Jobs').color, s.mutedForeground);
    });

    testWidgets('the labels use the large text style on a tight line', (
      tester,
    ) async {
      await pumpFinesse(tester, bar());
      final theme = themeOf(tester, find.byType(TabBar<int>));
      expect(styleOf(tester, 'Posts').fontSize, theme.textTheme.large.fontSize);
      expect(styleOf(tester, 'Posts').height, 1);
    });

    testWidgets('labelStyle replaces the base style; weight and colour are '
        'still set per tab', (tester) async {
      const style = TextStyle(
        fontSize: 13,
        letterSpacing: .4,
        height: 1.6,
        fontWeight: FontWeight.w900,
        color: Color(0xffff00ff),
      );
      await pumpFinesse(
        tester,
        bar(selectedIndex: 1, labelStyle: style, onSelected: (_) {}),
      );
      final s = themeOf(tester, find.byType(TabBar<int>)).colorScheme;
      for (final label in labels) {
        expect(styleOf(tester, label).fontSize, 13, reason: label);
        expect(styleOf(tester, label).letterSpacing, .4, reason: label);
        // Still a tight line, so the label stays centred in the bar.
        expect(styleOf(tester, label).height, 1, reason: label);
      }
      expect(styleOf(tester, 'About').fontWeight, FontWeight.w600);
      expect(styleOf(tester, 'About').color, s.foreground);
      expect(styleOf(tester, 'Posts').fontWeight, FontWeight.w500);
      expect(styleOf(tester, 'Posts').color, s.mutedForeground);
      // The bar's height does not follow the font size.
      expect(tester.getSize(find.byType(TabBar<int>)).height, 48 + 1);
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
      final s = themeOf(tester, find.byType(TabBar<int>)).colorScheme;
      BoxDecoration decoration() =>
          tester.widget<MovingIndicatorTarget>(indicator()).decoration
              as BoxDecoration;
      expect(decoration().color, s.foreground);

      const colour = Color(0xff0077cc);
      await pumpFinesse(tester, bar(indicatorColor: colour));
      expect(decoration().color, colour);
    });

    testWidgets("sits on the bar's bottom edge, over the hairline, and "
        'never below it', (tester) async {
      for (final expand in [true, false]) {
        for (final showBorder in [true, false]) {
          await pumpFinesse(
            tester,
            bar(showBorder: showBorder, expand: expand),
          );
          final reason = 'showBorder: $showBorder, expand: $expand';
          final box = tester.getRect(find.byType(TabBar<int>));
          final tab = tester.getRect(find.byType(Pressable).first);
          final line = tester.getRect(indicator());

          // Flush with the bottom of the bar: a bar in a clipped card or a
          // list would lose any part that hung out, and anything under the
          // bar would be painted over.
          expect(line.bottom, box.bottom, reason: reason);
          expect(line.height, 2, reason: reason);
          if (showBorder) {
            // One row in the tab, one over the hairline beneath it.
            expect(line.bottom, tab.bottom + 1, reason: reason);
            expect(box.bottom, tab.bottom + 1, reason: reason);
          } else {
            // No hairline to cover: both rows are inside the tab.
            expect(line.bottom, tab.bottom, reason: reason);
            expect(box.bottom, tab.bottom, reason: reason);
          }
        }
      }
    });

    testWidgets('the hairline runs under the whole bar, below the tabs', (
      tester,
    ) async {
      await pumpFinesse(tester, bar());
      final s = themeOf(tester, find.byType(TabBar<int>)).colorScheme;
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TabBar<int>),
              matching: find.byType(Container),
            )
            .first,
      );
      final border = (container.decoration! as BoxDecoration).border! as Border;
      expect(border.bottom.color, s.border);
      expect(border.bottom.width, 1);
      expect(border.top, BorderSide.none);
      // The hairline is added under the tabs, not taken out of them: it is
      // the row between the tabs' bottom edge and the bar's.
      final box = tester.getRect(find.byType(TabBar<int>));
      expect(box.height, 49);
      for (var i = 0; i < 3; i++) {
        final tab = tester.getRect(find.byType(Pressable).at(i));
        expect(tab.top, box.top);
        expect(tab.bottom, box.bottom - 1);
      }
    });

    testWidgets('showBorder: false removes the hairline and its row', (
      tester,
    ) async {
      await pumpFinesse(tester, bar(showBorder: false));
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(TabBar<int>),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((container.decoration! as BoxDecoration).border, isNull);
      final box = tester.getRect(find.byType(TabBar<int>));
      expect(box.height, 48);
      expect(tester.getRect(find.byType(Pressable).first).bottom, box.bottom);
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
        // A tab is one of a set: each says whether it is the selected one.
        expect(
          data.flagsCollection.isSelected,
          i == 1 ? ui.Tristate.isTrue : ui.Tristate.isFalse,
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

    testWidgets('is a tab bar of tabs to a screen reader in both looks, '
        'with a tooltip, a leading icon and a disabled tab', (tester) async {
      final handle = tester.ensureSemantics();
      for (final variant in TabBarVariant.values) {
        await pumpFinesse(
          tester,
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              child: TabBar<String>(
                variant: variant,
                value: 'b',
                onChanged: (_) {},
                tabs: const [
                  Tab(
                    value: 'a',
                    tooltip: 'First',
                    leading: PhosphorIcon(PhosphorIconsRegular.tray),
                    child: Text('A'),
                  ),
                  Tab(value: 'b', semanticLabel: 'Second', child: Text('B')),
                  Tab(value: 'c', enabled: false, child: Text('C')),
                ],
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$variant');
        final bar = tester.getSemantics(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics && w.properties.role == ui.SemanticsRole.tabBar,
          ),
        );
        final roles = <ui.SemanticsRole>[];
        bar.visitChildren((child) {
          roles.add(child.getSemanticsData().role);
          return true;
        });
        expect(roles, List.filled(3, ui.SemanticsRole.tab), reason: '$variant');
        final second = tester
            .getSemantics(find.bySemanticsLabel('Second'))
            .getSemanticsData();
        expect(second.flagsCollection.isSelected, ui.Tristate.isTrue);
        expect(second.hasAction(ui.SemanticsAction.tap), isTrue);
        final third = tester
            .getSemantics(find.bySemanticsLabel('C'))
            .getSemanticsData();
        expect(third.flagsCollection.isEnabled, ui.Tristate.isFalse);
        await tester.pumpWidget(const SizedBox.shrink());
      }
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
