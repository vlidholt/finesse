import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

void main() {
  testWidgets('tabs without content render only the list', (tester) async {
    String? changed;
    await tester.pumpWidget(
      UnaApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: Tabs<String>(
            value: 'day',
            onChanged: (v) => changed = v,
            tabs: const [
              Tab(value: 'day', child: Text('Day')),
              Tab(value: 'week', child: Text('Week')),
            ],
          ),
        ),
      ),
    );

    final tabs = tester.getRect(find.byType(Tabs<String>));
    final list = tester.getRect(
      find
          .descendant(
            of: find.byType(Tabs<String>),
            matching: find.byType(Decorator),
          )
          .first,
    );
    // No gap and no panel area below the list.
    expect(tabs.height, list.height);

    await tester.tap(find.text('Week'));
    await tester.pump();
    expect(changed, 'week');
  });

  group('the strip hugs its tabs', () {
    const two = [
      Tab(value: 0, child: Text('One')),
      Tab(value: 1, child: Text('Two')),
    ];
    const panels = [
      Tab(value: 0, content: Text('first panel'), child: Text('One')),
      Tab(value: 1, content: Text('second panel'), child: Text('Two')),
    ];

    Future<void> pump(
      WidgetTester tester,
      Widget child, {
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UnaApp(
          home: Directionality(
            textDirection: textDirection,
            child: Padding(padding: const EdgeInsets.all(20), child: child),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    /// The muted pill the tabs sit on.
    Rect strip(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(Tabs<int>),
            matching: find.byType(Decorator),
          )
          .first,
    );

    /// From the leading edge of the first tab to the trailing edge of the
    /// last.
    double tabsWidth(WidgetTester tester) {
      final tabs = find.byType(MovingIndicatorTarget);
      return tester
          .getRect(tabs.first)
          .expandToInclude(tester.getRect(tabs.last))
          .width;
    }

    for (final direction in TextDirection.values) {
      testWidgets('in a parent that stretches it, at the start ($direction)', (
        tester,
      ) async {
        await pump(
          tester,
          textDirection: direction,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Tabs<int>(value: 0, onChanged: (_) {}, tabs: two)],
          ),
        );
        // Not the 760 of the column: the tabs and the strip's own padding.
        expect(strip(tester).width, lessThan(tabsWidth(tester) + 16));
        if (direction == TextDirection.ltr) {
          expect(strip(tester).left, 20);
        } else {
          expect(strip(tester).right, 780);
        }
        // The widget itself is as wide as it was told to be.
        expect(tester.getSize(find.byType(Tabs<int>)).width, 760);
      });
    }

    testWidgets('with panels below it too', (tester) async {
      await pump(
        tester,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Tabs<int>(value: 0, onChanged: (_) {}, tabs: panels)],
        ),
      );
      expect(strip(tester).width, lessThan(tabsWidth(tester) + 16));
      expect(strip(tester).left, 20);
      expect(find.text('first panel'), findsOneWidget);
    });

    testWidgets('in a parent that only bounds it, where the widget is as '
        'big as its strip', (tester) async {
      await pump(
        tester,
        SizedBox(
          height: 200,
          child: Center(
            child: Tabs<int>(value: 0, onChanged: (_) {}, tabs: two),
          ),
        ),
      );
      final pill = strip(tester);
      expect(pill.width, lessThan(tabsWidth(tester) + 16));
      // Not the 200 it could have had.
      expect(pill.height, lessThan(60));
      expect(tester.getRect(find.byType(Tabs<int>)), pill);
      // So the parent's own alignment places it.
      expect(pill.center.dx, closeTo(400, .5));
    });

    testWidgets('tabAlignment places it in the width it was given', (
      tester,
    ) async {
      for (final (alignment, panelled) in [
        (Alignment.center, false),
        (Alignment.center, true),
        (Alignment.centerRight, false),
        (Alignment.centerRight, true),
      ]) {
        await pump(
          tester,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Tabs<int>(
                value: 0,
                onChanged: (_) {},
                tabAlignment: alignment,
                tabs: panelled ? panels : two,
              ),
            ],
          ),
        );
        final pill = strip(tester);
        final reason = '$alignment, panels: $panelled';
        expect(
          pill.width,
          lessThan(tabsWidth(tester) + 16),
          reason: reason,
        );
        if (alignment == Alignment.center) {
          expect(pill.center.dx, closeTo(400, .5), reason: reason);
        } else {
          expect(pill.right, 780, reason: reason);
        }
      }
    });

    testWidgets('a TabBar takes tabAlignment and expandTabs the same way', (
      tester,
    ) async {
      Rect pill() => tester.getRect(
        find
            .descendant(
              of: find.byType(TabBar<int>),
              matching: find.byType(Decorator),
            )
            .first,
      );
      Future<void> bar({AlignmentGeometry? alignment, bool? expand}) => pump(
        tester,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar<int>(
              value: 0,
              onChanged: (_) {},
              variant: TabBarVariant.segmented,
              tabAlignment: alignment,
              expandTabs: expand,
              tabs: two,
            ),
          ],
        ),
      );
      await bar();
      expect(pill().left, 20);
      await bar(alignment: Alignment.center);
      expect(pill().center.dx, closeTo(400, .5));
      expect(pill().width, lessThan(400));
      await bar(alignment: Alignment.center, expand: true);
      expect(pill().width, 760);
    });

    testWidgets('unless the tabs expand: then it fills the width', (
      tester,
    ) async {
      for (final tabs in [two, panels]) {
        await pump(
          tester,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Tabs<int>(
                value: 0,
                expandTabs: true,
                onChanged: (_) {},
                tabs: tabs,
              ),
            ],
          ),
        );
        expect(strip(tester).width, 760);
        expect(tabsWidth(tester), greaterThan(740));
      }
    });
  });

  group('a tab label', () {
    Future<void> pump(WidgetTester tester, List<Tab<int>> tabs) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(280, 600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UnaApp(
          home: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Tabs<int>(
                  value: 0,
                  expandTabs: true,
                  onChanged: (_) {},
                  tabs: tabs,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('gives way in an expanded tab that is too narrow for it', (
      tester,
    ) async {
      // In the test font a glyph is as wide as the text is tall, so the
      // second label alone is wider than its half of a 248-pixel strip.
      await pump(tester, const [
        Tab(value: 0, child: Text('Find jobs')),
        Tab(value: 1, child: Text('My applications')),
      ]);
      expect(tester.takeException(), isNull);
      final tabs = find.byType(MovingIndicatorTarget);
      final first = tester.getRect(tabs.first);
      final second = tester.getRect(tabs.last);
      expect(first.width, closeTo(second.width, .5));
      final label = tester.getRect(find.text('My applications'));
      expect(label.left, greaterThanOrEqualTo(second.left));
      expect(label.right, lessThanOrEqualTo(second.right));
      // One line, cut short — not wrapped under itself in a 32-pixel tab.
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('My applications'),
      );
      expect(paragraph.maxLines, 1);
      expect(paragraph.overflow, TextOverflow.ellipsis);
      expect(paragraph.didExceedMaxLines, isTrue);
    });

    testWidgets('keeps its width when there is room, with the tab centred '
        'around it', (tester) async {
      await pump(tester, const [
        Tab(value: 0, child: Text('A')),
        Tab(value: 1, child: Text('B')),
      ]);
      final tab = tester.getRect(find.byType(MovingIndicatorTarget).first);
      final label = tester.getRect(find.text('A'));
      expect(label.center.dx, closeTo(tab.center.dx, .5));
      expect(
        tester.renderObject<RenderParagraph>(find.text('A')).didExceedMaxLines,
        isFalse,
      );
    });

    testWidgets('gives way next to a leading and a trailing widget', (
      tester,
    ) async {
      await pump(tester, const [
        Tab(
          value: 0,
          leading: SizedBox.square(key: Key('leading'), dimension: 16),
          trailing: SizedBox.square(key: Key('trailing'), dimension: 16),
          child: Text('A label that is much too long'),
        ),
        Tab(value: 1, child: Text('B')),
      ]);
      expect(tester.takeException(), isNull);
      final tab = tester.getRect(find.byType(MovingIndicatorTarget).first);
      expect(
        tester.getRect(find.byKey(const Key('leading'))).left,
        greaterThan(tab.left),
      );
      expect(
        tester.getRect(find.byKey(const Key('trailing'))).right,
        lessThan(tab.right),
      );
    });

    testWidgets('that brings its own Flexible is left as it is', (
      tester,
    ) async {
      await pump(tester, const [
        Tab(
          value: 0,
          child: Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Find jobs and more jobs'),
            ),
          ),
        ),
        Tab(value: 1, child: Text('B')),
      ]);
      expect(tester.takeException(), isNull);
      final tab = tester.getRect(find.byType(MovingIndicatorTarget).first);
      final label = tester.getRect(find.byType(FittedBox));
      expect(label.left, greaterThanOrEqualTo(tab.left));
      expect(label.right, lessThanOrEqualTo(tab.right));
    });

    testWidgets('is not cut short in a tab that sizes to it', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UnaApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: Tabs<int>(
              value: 0,
              onChanged: (_) {},
              tabs: const [
                Tab(value: 0, child: Text('A rather long label')),
                Tab(value: 1, child: Text('B')),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('A rather long label'))
            .didExceedMaxLines,
        isFalse,
      );
    });
  });
}
