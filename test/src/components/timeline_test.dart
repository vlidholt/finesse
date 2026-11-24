import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  TimelineEntry entry(int i, {double marker = 40, double content = 30}) {
    return TimelineEntry(
      marker: SizedBox(key: Key('marker$i'), width: marker, height: marker),
      child: SizedBox(key: Key('content$i'), height: content),
    );
  }

  /// The joining lines, top to bottom.
  Finder lines() => find.descendant(
    of: find.byType(Timeline),
    matching: find.byWidgetPredicate(
      (w) => w is Container && w.decoration is BoxDecoration,
    ),
  );

  Widget timeline(List<TimelineEntry> entries, {double width = 320}) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        child: Timeline(entries: entries),
      ),
    );
  }

  group('TimelineTheme', () {
    test('draws a 2px line in the strong border colour', () {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        expect(theme.timelineTheme.lineColor, theme.colorScheme.borderStrong);
        expect(theme.timelineTheme.lineWidth, 2);
        expect(theme.timelineTheme.gap, 14);
        expect(theme.timelineTheme.spacing, 20);
        expect(theme.timelineTheme.lineGap, 6);
      }
    });
  });

  group('Timeline', () {
    testWidgets('renders in both form factors and text directions', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (layout) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Timeline(
            entries: [
              for (var i = 0; i < 3; i++)
                TimelineEntry(
                  marker: const IconTile(
                    icon: Icon(PhosphorIconsRegular.briefcase),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Role $i'),
                      const Text('Company, two years of doing things'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });

    testWidgets('joins every entry but the last with a line', (tester) async {
      await pumpFinesse(tester, timeline([entry(0), entry(1), entry(2)]));
      expect(lines(), findsNWidgets(2));

      await pumpFinesse(tester, timeline([entry(0)]));
      expect(lines(), findsNothing);
    });

    testWidgets('no entries build nothing and take no height', (tester) async {
      await pumpFinesse(tester, timeline(const []));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Timeline)).height, 0);
    });

    testWidgets('puts the marker in the gutter and the content beside it', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          timeline([entry(0), entry(1)]),
          textDirection: direction,
        );
        final box = tester.getRect(find.byType(Timeline));
        final marker = tester.getRect(find.byKey(const Key('marker0')));
        final content = tester.getRect(find.byKey(const Key('content0')));

        expect(box.width, 320);
        expect(marker.top, box.top);
        expect(content.top, box.top);
        if (direction == TextDirection.ltr) {
          expect(marker.left, box.left);
          // The theme's 14px gap, then the content takes the rest.
          expect(content.left, marker.right + 14);
          expect(content.right, box.right);
        } else {
          expect(marker.right, box.right);
          expect(content.right, marker.left - 14);
          expect(content.left, box.left);
        }
      }
    });

    testWidgets('spaces the entries by the theme spacing', (tester) async {
      await pumpFinesse(tester, timeline([entry(0), entry(1), entry(2)]));
      final first = tester.getRect(find.byKey(const Key('marker0')));
      final second = tester.getRect(find.byKey(const Key('marker1')));
      final third = tester.getRect(find.byKey(const Key('marker2')));
      // Each entry is as tall as its 40px marker plus the line's margins —
      // taller than its 30px content plus 20 of spacing.
      expect(second.top - first.top, greaterThanOrEqualTo(50));
      expect(third.top - second.top, second.top - first.top);
    });

    testWidgets('content taller than its marker sets the entry height', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        timeline([entry(0, content: 120), entry(1)]),
      );
      final first = tester.getRect(find.byKey(const Key('marker0')));
      final second = tester.getRect(find.byKey(const Key('marker1')));
      // 120 of content and 20 of spacing.
      expect(second.top - first.top, 140);
      // The last entry has no spacing under it.
      final box = tester.getRect(find.byType(Timeline));
      expect(box.bottom, second.bottom);
    });

    testWidgets('the line runs from under a marker to the next one, with a '
        'gap at each end', (tester) async {
      await pumpFinesse(
        tester,
        timeline([entry(0, content: 120), entry(1)]),
      );
      final first = tester.getRect(find.byKey(const Key('marker0')));
      final second = tester.getRect(find.byKey(const Key('marker1')));
      final line = tester.getRect(lines());
      // The painted part is the container less its margin.
      final container = tester.widget<Container>(lines());
      final margin = container.margin! as EdgeInsets;

      expect(margin, const EdgeInsets.only(top: 6, bottom: 6));
      expect(line.top + margin.top, first.bottom + 6);
      expect(line.bottom - margin.bottom, second.top - 6);
      // 2px wide, centred under the marker.
      expect(line.width, 2);
      expect(line.center.dx, first.center.dx);
    });

    testWidgets('the line takes the theme colour, or the one it is given', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pumpFinesse(
          tester,
          timeline([entry(0), entry(1)]),
          theme: ThemeData(brightness: brightness),
        );
        final theme = themeOf(tester, find.byType(Timeline));
        expect(
          (tester.widget<Container>(lines()).decoration! as BoxDecoration)
              .color,
          theme.colorScheme.borderStrong,
          reason: '$brightness',
        );
      }

      const colour = Color(0xff336699);
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 320,
            child: Timeline(lineColor: colour, entries: [entry(0), entry(1)]),
          ),
        ),
      );
      expect(
        (tester.widget<Container>(lines()).decoration! as BoxDecoration).color,
        colour,
      );
    });

    testWidgets('gap and spacing can be set per timeline', (tester) async {
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 320,
            child: Timeline(
              gap: 30,
              spacing: 50,
              entries: [entry(0, content: 100), entry(1)],
            ),
          ),
        ),
      );
      final marker = tester.getRect(find.byKey(const Key('marker0')));
      final content = tester.getRect(find.byKey(const Key('content0')));
      final next = tester.getRect(find.byKey(const Key('marker1')));
      expect(content.left, marker.right + 30);
      expect(next.top - marker.top, 150);
    });

    testWidgets('follows a theme override', (tester) async {
      await pumpFinesse(
        tester,
        timeline([entry(0, content: 100), entry(1)]),
        theme: ThemeData(
          timelineTheme: const TimelineTheme(
            lineWidth: 4,
            gap: 8,
            spacing: 10,
            lineGap: 0,
          ),
        ),
      );
      final marker = tester.getRect(find.byKey(const Key('marker0')));
      final next = tester.getRect(find.byKey(const Key('marker1')));
      final line = tester.getRect(lines());
      expect(line.width, 4);
      expect(line.top, marker.bottom);
      expect(line.bottom, next.top);
      expect(
        tester.getRect(find.byKey(const Key('content0'))).left,
        marker.right + 8,
      );
      expect(next.top - marker.top, 110);
    });

    testWidgets('markers of different widths stay centred on their own '
        'lines', (tester) async {
      await pumpFinesse(
        tester,
        timeline([entry(0, marker: 48), entry(1, marker: 24), entry(2)]),
      );
      final all = lines();
      expect(
        tester.getRect(all.at(0)).center.dx,
        tester.getRect(find.byKey(const Key('marker0'))).center.dx,
      );
      expect(
        tester.getRect(all.at(1)).center.dx,
        tester.getRect(find.byKey(const Key('marker1'))).center.dx,
      );
    });

    testWidgets('wrapping text content does not overflow a narrow timeline', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 200,
            child: Timeline(
              entries: [
                for (var i = 0; i < 2; i++)
                  TimelineEntry(
                    marker: SizedBox(
                      key: Key('marker$i'),
                      width: 40,
                      height: 40,
                    ),
                    child: const Text(
                      'A description long enough to wrap on to several lines',
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.textContaining('A description').first).width,
        lessThanOrEqualTo(200 - 40 - 14),
      );
    });

    testWidgets('sizes itself in a scroll view', (tester) async {
      await pumpFinesse(
        tester,
        SingleChildScrollView(
          child: Timeline(entries: [entry(0), entry(1), entry(2)]),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Timeline)).height, greaterThan(120));
    });
  });
}
