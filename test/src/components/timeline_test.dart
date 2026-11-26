import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

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
        // The una style's `timelineLineGap`.
        expect(theme.timelineTheme.lineGap, 8);
      }
    });

    test("the line gap is the style's: 8 in una, 6 in the shadcn styles, "
        'and it follows the spacing unit', () {
      expect(StyleTokens.una.timelineLineGap, 8);
      expect(StyleTokens.unaMobile.timelineLineGap, 8);
      for (final style in [
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        expect(style.timelineLineGap, 6, reason: style.name);
        for (final formFactor in FormFactor.values) {
          expect(
            ThemeData(
              style: style,
              formFactor: formFactor,
            ).timelineTheme.lineGap,
            6,
            reason: '${style.name} ${formFactor.name}',
          );
        }
      }
      expect(
        ThemeData(formFactor: FormFactor.mobile).timelineTheme.lineGap,
        8,
      );
      expect(
        ThemeData(
          style: StyleTokens.una.copyWith(timelineLineGap: 12),
        ).timelineTheme.lineGap,
        12,
      );
      expect(
        ThemeData(spacing: const Spacing(step: 6)).timelineTheme.lineGap,
        12,
      );
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
      await pumpUna(tester, timeline([entry(0), entry(1), entry(2)]));
      expect(lines(), findsNWidgets(2));

      await pumpUna(tester, timeline([entry(0)]));
      expect(lines(), findsNothing);
    });

    testWidgets('no entries build nothing and take no height', (tester) async {
      await pumpUna(tester, timeline(const []));
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Timeline)).height, 0);
    });

    testWidgets('puts the marker in the gutter and the content beside it', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        await pumpUna(
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
      await pumpUna(tester, timeline([entry(0), entry(1), entry(2)]));
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
      await pumpUna(
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

    testWidgets('the line leaves a gap under its own marker and runs flush '
        'to the next one', (tester) async {
      await pumpUna(
        tester,
        timeline([entry(0, content: 120), entry(1), entry(2)]),
      );
      for (var i = 0; i < 2; i++) {
        final from = tester.getRect(find.byKey(Key('marker$i')));
        final to = tester.getRect(find.byKey(Key('marker${i + 1}')));
        final container = tester.widget<Container>(lines().at(i));
        // The painted part is the container less its margin.
        final painted = tester.getRect(
          find.descendant(
            of: lines().at(i),
            matching: find.byType(DecoratedBox),
          ),
        );

        // A gap only at the top: the theme's 8.
        expect(container.margin, const EdgeInsets.only(top: 8));
        expect(painted.top, from.bottom + 8, reason: 'line $i');
        expect(painted.bottom, to.top, reason: 'line $i');
        // 2px wide, centred under the marker.
        expect(painted.width, 2);
        expect(painted.center.dx, from.center.dx);
      }
    });

    testWidgets("the gap under the marker is the style's", (tester) async {
      await pumpUna(
        tester,
        timeline([entry(0, content: 120), entry(1)]),
        theme: ThemeData(style: StyleTokens.nova),
      );
      final first = tester.getRect(find.byKey(const Key('marker0')));
      final second = tester.getRect(find.byKey(const Key('marker1')));
      final painted = tester.getRect(
        find.descendant(of: lines(), matching: find.byType(DecoratedBox)),
      );
      expect(painted.top, first.bottom + 6);
      expect(painted.bottom, second.top);
    });

    testWidgets('a marker as tall as its entry leaves no line, and no '
        'overflow', (tester) async {
      // Content shorter than the marker and no spacing: the line has only
      // its gap to live in.
      await pumpUna(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 320,
            child: Timeline(
              spacing: 0,
              entries: [entry(0, content: 10), entry(1, content: 10)],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final first = tester.getRect(find.byKey(const Key('marker0')));
      final second = tester.getRect(find.byKey(const Key('marker1')));
      // The entry makes room for the gap, so the markers never touch.
      expect(second.top - first.bottom, 8);
      expect(
        tester
            .getSize(
              find.descendant(
                of: lines(),
                matching: find.byType(DecoratedBox),
              ),
            )
            .height,
        0,
      );
    });

    testWidgets('the line takes the theme colour, or the one it is given', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await pumpUna(
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
      await pumpUna(
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
      await pumpUna(
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
      await pumpUna(
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
      await pumpUna(
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
      await pumpUna(
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
      await pumpUna(
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
