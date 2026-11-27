import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/page_indicator.dart'
    show debugPageIndicatorDots;
import 'package:una/una.dart';

import '../../frame_sampler.dart';
import '../../una_harness.dart';

void main() {
  late List<int> changes;

  setUp(() => changes = []);

  Widget carousel({
    int count = 4,
    CarouselController? controller,
    int initialPage = 0,
    double viewportFraction = 1,
    double? spacing,
    Axis axis = Axis.horizontal,
    bool loop = false,
    Duration? autoPlay,
    bool? showArrows,
    bool showIndicator = false,
    BorderRadius? borderRadius,
    double? height = 200,
    double? aspectRatio,
    double width = 400,
  }) => Center(
    child: SizedBox(
      width: width,
      height: axis == Axis.vertical ? 300 : null,
      child: Carousel(
        controller: controller,
        initialPage: initialPage,
        viewportFraction: viewportFraction,
        spacing: spacing,
        axis: axis,
        loop: loop,
        autoPlay: autoPlay,
        showArrows: showArrows,
        showIndicator: showIndicator,
        borderRadius: borderRadius,
        height: height,
        aspectRatio: aspectRatio,
        semanticLabel: 'Photos',
        onPageChanged: changes.add,
        children: [
          for (var i = 0; i < count; i++)
            ColoredBox(
              color: Color(0xff000000 + 40 * (i + 1)),
              child: Center(child: Text('Page $i')),
            ),
        ],
      ),
    ),
  );

  Finder arrow(String label) => find.byWidgetPredicate(
    (widget) => widget is Pressable && widget.semanticLabel == label,
  );

  double opacityOf(WidgetTester tester, Finder of) => tester
      .widget<AnimatedOpacity>(
        find.ancestor(of: of, matching: find.byType(AnimatedOpacity)).first,
      )
      .opacity;

  /// Connects a mouse and puts it over the carousel.
  Future<TestGesture> hover(WidgetTester tester) =>
      hoverAt(tester, tester.getCenter(find.byType(Carousel)));

  group('CarouselTheme', () {
    test('is fed by the style and the scheme', () {
      final theme = ThemeData();
      final carousel = theme.carouselTheme;
      expect(carousel.arrowSize, theme.style.iconButtonSize);
      expect(carousel.arrowColor, theme.colorScheme.popover);
      expect(carousel.activeDotColor, theme.colorScheme.tint);
      expect(
        theme.withFormFactor(FormFactor.mobile).carouselTheme.arrowSize,
        greaterThanOrEqualTo(44),
      );
      expect(
        ThemeData(
          carouselTheme: const CarouselTheme(dotSize: 9),
        ).copyWith(radius: BorderRadius.circular(3)).carouselTheme.dotSize,
        9,
      );
      expect(ThemeData(), ThemeData());
    });
  });

  group('Carousel paging', () {
    testWidgets('a drag turns the page and reports it', (tester) async {
      await pumpUna(tester, carousel());
      expect(find.text('Page 0'), findsOneWidget);
      await tester.fling(find.text('Page 0'), const Offset(-200, 0), 1500);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 0'), findsNothing);
    });

    testWidgets('it stops at the ends unless it loops', (tester) async {
      await pumpUna(tester, carousel());
      await tester.fling(find.text('Page 0'), const Offset(200, 0), 1500);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);

      await pumpUna(tester, const SizedBox());
      await pumpUna(tester, carousel(loop: true));
      await tester.fling(find.text('Page 0'), const Offset(200, 0), 1500);
      await tester.pumpAndSettle();
      expect(changes, [3]);
      await tester.fling(find.text('Page 3'), const Offset(-200, 0), 1500);
      await tester.pumpAndSettle();
      expect(changes, [3, 0]);
    });

    testWidgets('initialPage is where it starts', (tester) async {
      await pumpUna(tester, carousel(initialPage: 2));
      expect(find.text('Page 2'), findsOneWidget);
      expect(changes, isEmpty);
    });

    testWidgets('viewportFraction shows the neighbours, a gap apart', (
      tester,
    ) async {
      await pumpUna(
        tester,
        carousel(viewportFraction: .8, spacing: 20, initialPage: 1),
      );
      final page = tester.getRect(
        find
            .ancestor(
              of: find.text('Page 1'),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(page.width, moreOrLessEquals(400 * .8 - 20));
      final next = tester.getRect(
        find
            .ancestor(
              of: find.text('Page 2', skipOffstage: false),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(next.left - page.right, moreOrLessEquals(20));
    });

    testWidgets('height, aspectRatio, or the room it is given decide its '
        'size', (tester) async {
      await pumpUna(tester, carousel(height: 120));
      expect(tester.getSize(find.byType(Carousel)), const Size(400, 120));
      await pumpUna(tester, carousel(height: null, aspectRatio: 2));
      expect(tester.getSize(find.byType(Carousel)), const Size(400, 200));
      await pumpUna(
        tester,
        SizedBox(
          width: 300,
          height: 150,
          child: Carousel(children: const [Text('a'), Text('b')]),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a vertical carousel pages up and down', (tester) async {
      await pumpUna(tester, carousel(axis: Axis.vertical, height: 300));
      await tester.fling(find.text('Page 0'), const Offset(0, -200), 1500);
      await tester.pumpAndSettle();
      expect(changes, [1]);
    });

    testWidgets('the corners are clipped when a radius is given', (
      tester,
    ) async {
      await pumpUna(tester, carousel());
      expect(
        find.descendant(
          of: find.byType(Carousel),
          matching: find.byType(ClipRRect),
        ),
        findsNothing,
      );
      await pumpUna(
        tester,
        carousel(borderRadius: BorderRadius.circular(16)),
      );
      expect(
        tester
            .widget<ClipRRect>(
              find.descendant(
                of: find.byType(Carousel),
                matching: find.byType(ClipRRect),
              ),
            )
            .borderRadius,
        BorderRadius.circular(16),
      );
    });

    testWidgets('builds in every layout', (tester) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => carousel(showIndicator: true, showArrows: true, width: 320),
      );
    });

    testWidgets('at rest it schedules nothing', (tester) async {
      await pumpUna(tester, carousel(showIndicator: true));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group('CarouselController', () {
    testWidgets('moves, steps, jumps and reports the page', (tester) async {
      final controller = CarouselController();
      addTearDown(controller.dispose);
      var notified = 0;
      controller.addListener(() => notified++);
      await pumpUna(tester, carousel(controller: controller));
      expect(controller.pageCount, 4);
      expect(controller.page, 0);

      controller.nextPage();
      await tester.pumpAndSettle();
      expect(controller.page, 1);
      controller.animateToPage(3);
      await tester.pumpAndSettle();
      expect(controller.page, 3);
      controller.nextPage();
      await tester.pumpAndSettle();
      expect(controller.page, 3, reason: 'no page after the last');
      controller.previousPage();
      await tester.pumpAndSettle();
      expect(controller.page, 2);
      controller.jumpToPage(0);
      await tester.pump();
      expect(controller.page, 0);
      expect(changes.last, 0);
      expect(notified, greaterThanOrEqualTo(4));
    });

    testWidgets('a looping carousel goes the short way round', (tester) async {
      final controller = CarouselController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        carousel(controller: controller, loop: true, count: 5),
      );
      controller.animateToPage(4);
      // One page back, not four forward: page 1 never comes by.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.text('Page 2'), findsNothing);
      }
      await tester.pumpAndSettle();
      expect(controller.page, 4);
      controller.nextPage();
      await tester.pumpAndSettle();
      expect(controller.page, 0);
    });

    testWidgets('a second step while the first is under way goes one page '
        'further', (tester) async {
      for (final loop in [false, true]) {
        final controller = CarouselController();
        addTearDown(controller.dispose);
        changes.clear();
        await pumpUna(tester, const SizedBox());
        await pumpUna(
          tester,
          carousel(controller: controller, count: 5, loop: loop),
        );
        controller.nextPage();
        await tester.pump(const Duration(milliseconds: 50));
        controller.nextPage();
        await tester.pumpAndSettle();
        expect(controller.page, 2, reason: 'loop: $loop');
        // Only the arrival is reported.
        expect(changes, [2], reason: 'loop: $loop');
        controller.previousPage();
        await tester.pump(const Duration(milliseconds: 50));
        controller.previousPage();
        await tester.pumpAndSettle();
        expect(controller.page, 0, reason: 'loop: $loop');
      }
    });

    testWidgets('a programmatic move is monotone and settles; under '
        'Motion.none it jumps', (tester) async {
      final controller = CarouselController();
      addTearDown(controller.dispose);
      await pumpUna(tester, carousel(controller: controller));
      controller.nextPage();
      final lefts = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        // The next page is built once it shows.
        final next = find.text('Page 1', skipOffstage: false);
        if (next.evaluate().isEmpty) continue;
        lefts.add(tester.getTopLeft(next).dx);
      }
      expect(lefts.length, greaterThan(30));
      expect(lefts.last, lessThan(lefts.first));
      for (var i = 1; i < lefts.length; i++) {
        expect(lefts[i], lessThanOrEqualTo(lefts[i - 1] + .5));
      }
      await tester.pumpAndSettle();

      await pumpUna(tester, const SizedBox());
      await pumpUna(
        tester,
        carousel(controller: controller),
        theme: ThemeData(motion: Motion.none),
      );
      controller.nextPage();
      await tester.pump();
      expect(controller.page, 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('Carousel arrows', () {
    testWidgets('without a mouse there are none', (tester) async {
      await pumpUna(tester, carousel());
      expect(arrow('Next page'), findsNothing);
    });

    testWidgets('with a mouse they fade in under the pointer, and the one '
        'with nowhere to go stays hidden', (tester) async {
      await pumpUna(tester, carousel());
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(5, 5));
      addTearDown(mouse.removePointer);
      await tester.pump();
      expect(arrow('Next page'), findsOneWidget);
      expect(opacityOf(tester, arrow('Next page')), 0);

      await mouse.moveTo(tester.getCenter(find.byType(Carousel)));
      await tester.pumpAndSettle();
      expect(opacityOf(tester, arrow('Next page')), 1);
      expect(opacityOf(tester, arrow('Previous page')), 0);

      await tester.tap(arrow('Next page'));
      await tester.pumpAndSettle();
      expect(changes, [1]);
      expect(opacityOf(tester, arrow('Previous page')), 1);

      await mouse.moveTo(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(opacityOf(tester, arrow('Next page')), 0);
    });

    testWidgets('a looping carousel shows both at every page', (tester) async {
      await pumpUna(tester, carousel(loop: true));
      await hover(tester);
      await tester.pumpAndSettle();
      expect(opacityOf(tester, arrow('Previous page')), 1);
      await tester.tap(arrow('Previous page'));
      await tester.pumpAndSettle();
      expect(changes, [3]);
    });

    testWidgets('showArrows: true shows them without a pointer; false '
        'never', (tester) async {
      await pumpUna(tester, carousel(showArrows: true));
      expect(opacityOf(tester, arrow('Next page')), 1);
      await pumpUna(tester, const SizedBox());
      await pumpUna(tester, carousel(showArrows: false));
      await hover(tester);
      await tester.pumpAndSettle();
      expect(arrow('Next page'), findsNothing);
    });

    testWidgets('the arrows swap sides and carets in a right-to-left '
        'layout', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpUna(tester, const SizedBox());
        await pumpUna(
          tester,
          carousel(showArrows: true, initialPage: 1),
          textDirection: direction,
        );
        final next = tester.getCenter(arrow('Next page')).dx;
        final previous = tester.getCenter(arrow('Previous page')).dx;
        final ltr = direction == TextDirection.ltr;
        expect(next > previous, ltr);
        expect(
          find.descendant(
            of: arrow('Next page'),
            matching: find.byIcon(
              ltr
                  ? PhosphorIconsRegular.caretRight
                  : PhosphorIconsRegular.caretLeft,
            ),
          ),
          findsOneWidget,
        );
      }
    });
  });

  group('Carousel keyboard', () {
    testWidgets('arrows, Page Up/Down, Home and End move between pages '
        'while it has the focus', (tester) async {
      useTraditionalHighlights();
      await pumpUna(tester, carousel());
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      for (final (key, page) in [
        (LogicalKeyboardKey.arrowRight, 1),
        (LogicalKeyboardKey.pageDown, 2),
        (LogicalKeyboardKey.arrowLeft, 1),
        (LogicalKeyboardKey.end, 3),
        (LogicalKeyboardKey.pageUp, 2),
        (LogicalKeyboardKey.home, 0),
      ]) {
        await tester.sendKeyEvent(key);
        await tester.pumpAndSettle();
        expect(changes.last, page, reason: key.debugName);
      }
    });

    testWidgets('in a right-to-left layout the left arrow goes on', (
      tester,
    ) async {
      await pumpUna(
        tester,
        carousel(),
        textDirection: TextDirection.rtl,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(changes, [1]);
    });

    testWidgets('a vertical carousel takes up and down', (tester) async {
      await pumpUna(tester, carousel(axis: Axis.vertical, height: 300));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(changes, [1]);
    });

    testWidgets('the focus ring shows for the keyboard', (tester) async {
      useTraditionalHighlights();
      await pumpUna(tester, carousel());
      FocusRing ring() => tester.widget<FocusRing>(
        find
            .descendant(
              of: find.byType(Carousel),
              matching: find.byType(FocusRing),
            )
            .first,
      );
      expect(ring().visible, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(ring().visible, isTrue);
    });
  });

  group('Carousel auto-play', () {
    const interval = Duration(seconds: 3);

    testWidgets('moves on by itself, and from the last page back to the '
        'first', (tester) async {
      await pumpUna(tester, carousel(count: 3, autoPlay: interval));
      await tester.pump(interval);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      await tester.pump(interval);
      await tester.pumpAndSettle();
      await tester.pump(interval);
      await tester.pumpAndSettle();
      expect(changes, [1, 2, 0]);
      await pumpUna(tester, const SizedBox());
    });

    testWidgets('waits while the pointer is over it', (tester) async {
      await pumpUna(tester, carousel(autoPlay: interval));
      final mouse = await hover(tester);
      await tester.pump(interval * 3);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      await mouse.moveTo(const Offset(5, 5));
      await tester.pump();
      await tester.pump(interval);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      await pumpUna(tester, const SizedBox());
    });

    testWidgets('waits while it has the focus and while it is touched', (
      tester,
    ) async {
      await pumpUna(tester, carousel(autoPlay: interval));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.pump(interval * 2);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      final finger = await tester.startGesture(
        tester.getCenter(find.byType(Carousel)),
      );
      await tester.pump(interval * 2);
      expect(changes, isEmpty);
      await finger.up();
      await tester.pump(interval);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      await pumpUna(tester, const SizedBox());
    });

    testWidgets('does not run with reduced motion', (tester) async {
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: carousel(autoPlay: interval),
        ),
      );
      await tester.pump(interval * 3);
      expect(changes, isEmpty);
    });

    testWidgets('does not run under a screen reader', (tester) async {
      await pumpUna(
        tester,
        MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: carousel(autoPlay: interval),
        ),
      );
      await tester.pump(interval * 3);
      expect(changes, isEmpty);
      // Nothing plays, so there is nothing to pause.
      expect(find.bySemanticsLabel('Pause slide show'), findsNothing);
    });

    testWidgets('a pause button stops it, and play starts it again', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, carousel(count: 3, autoPlay: interval));
      expect(find.bySemanticsLabel('Pause slide show'), findsOneWidget);
      tester.semantics.tap(find.semantics.byLabel('Pause slide show'));
      await tester.pump();
      await tester.pump(interval * 3);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      tester.semantics.tap(find.semantics.byLabel('Play slide show'));
      await tester.pump();
      await tester.pump(interval);
      await tester.pumpAndSettle();
      expect(changes, [1]);
      await pumpUna(tester, const SizedBox());
      handle.dispose();
    });

    testWidgets('leaves no timer behind', (tester) async {
      await pumpUna(tester, carousel(autoPlay: interval));
      await pumpUna(tester, const SizedBox());
      // The test fails on a pending timer by itself.
    });
  });

  group('Carousel semantics', () {
    testWidgets('says which page of how many, steps either way, and names '
        'each page', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, carousel(initialPage: 1));
      final node = tester.getSemantics(find.byType(Carousel));
      final data = node.getSemanticsData();
      expect(data.label, 'Photos');
      expect(data.value, 'Page 2 of 4');
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);
      expect(find.bySemanticsLabel(RegExp('2 of 4')), findsWidgets);

      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.increase,
      );
      await tester.pumpAndSettle();
      expect(changes, [2]);
      handle.dispose();
    });
  });

  group('PageIndicator', () {
    Widget indicator({
      int count = 5,
      int index = 0,
      ValueChanged<int>? onSelected,
      PageController? controller,
      int maxVisible = 7,
      Axis axis = Axis.horizontal,
      PageIndicatorVariant variant = PageIndicatorVariant.plain,
    }) => Center(
      child: PageIndicator(
        count: count,
        index: index,
        onSelected: onSelected,
        controller: controller,
        maxVisible: maxVisible,
        axis: axis,
        variant: variant,
      ),
    );

    test('the pill is one dot stretched, and the strip never changes '
        'length as it moves', () {
      for (final page in [0.0, .25, .5, 1.0, 2.75, 4.0]) {
        final dots = debugPageIndicatorDots(count: 5, page: page);
        expect(dots, hasLength(5));
        final end = dots.last.start + dots.last.length;
        expect(end, moreOrLessEquals(5 * 6 + 4 * 6 + 12), reason: '$page');
      }
      final at2 = debugPageIndicatorDots(count: 5, page: 2);
      expect(at2[2].length, 18);
      expect(at2[1].length, 6);
      // Half way, two dots share the pill's extra length.
      final half = debugPageIndicatorDots(count: 5, page: 2.5);
      expect(half[2].length, moreOrLessEquals(12));
      expect(half[3].length, moreOrLessEquals(12));
    });

    test('an endless view hands the pill from the last dot to the first', () {
      final wrap = debugPageIndicatorDots(count: 4, page: 3.5);
      expect(wrap.first.length, moreOrLessEquals(12));
      expect(wrap.last.length, moreOrLessEquals(12));
    });

    test('more pages than maxVisible are a window with smaller dots at an '
        'edge that has more beyond it', () {
      final start = debugPageIndicatorDots(count: 12, page: 0, maxVisible: 5);
      expect(start.first.scale, 1);
      final lastShown = start.where((dot) => dot.start < 50).last;
      expect(lastShown.scale, lessThan(1));

      final middle = debugPageIndicatorDots(count: 12, page: 6, maxVisible: 5);
      final current = middle.firstWhere((dot) => dot.index == 6);
      expect(current.scale, 1);
      expect(current.length, 18);
      expect(middle.firstWhere((dot) => dot.index == 4).scale, lessThan(1));
      expect(middle.firstWhere((dot) => dot.index == 8).scale, lessThan(1));

      final end = debugPageIndicatorDots(count: 12, page: 11, maxVisible: 5);
      expect(end.last.scale, 1);
    });

    testWidgets("its size is the window's, whatever the page", (tester) async {
      await pumpUna(tester, indicator());
      expect(
        tester.getSize(find.byType(CustomPaint).last),
        const Size(5 * 6 + 4 * 6 + 12, 6),
      );
      await pumpUna(tester, indicator(count: 30, maxVisible: 5));
      expect(
        tester.getSize(find.byType(CustomPaint).last),
        const Size(5 * 6 + 4 * 6 + 12, 6),
      );
      await pumpUna(tester, indicator(axis: Axis.vertical));
      expect(
        tester.getSize(find.byType(CustomPaint).last),
        const Size(6, 5 * 6 + 4 * 6 + 12),
      );
    });

    testWidgets('a change of index glides and settles', (tester) async {
      await pumpUna(tester, indicator());
      await pumpUna(tester, indicator(index: 3));
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a tap on a dot selects its page, in both directions', (
      tester,
    ) async {
      for (final direction in TextDirection.values) {
        final selected = <int>[];
        await pumpUna(
          tester,
          indicator(index: 1, onSelected: selected.add),
          textDirection: direction,
        );
        final rect = tester.getRect(find.byType(PageIndicator));
        // The last dot is at the end edge.
        await tester.tapAt(
          direction == TextDirection.ltr
              ? rect.centerRight - const Offset(3, 0)
              : rect.centerLeft + const Offset(3, 0),
        );
        await tester.pump();
        expect(selected, [4], reason: direction.name);
        await tester.tapAt(
          direction == TextDirection.ltr
              ? rect.centerLeft + const Offset(3, 0)
              : rect.centerRight - const Offset(3, 0),
        );
        expect(selected, [4, 0], reason: direction.name);
      }
    });

    testWidgets('a tap on a dot selects its page when the indicator is '
        'stretched', (tester) async {
      for (final variant in PageIndicatorVariant.values) {
        for (final direction in TextDirection.values) {
          final selected = <int>[];
          await pumpUna(
            tester,
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 300,
                child: PageIndicator(
                  count: 5,
                  index: 2,
                  variant: variant,
                  onSelected: selected.add,
                ),
              ),
            ),
            textDirection: direction,
          );
          final dots = tester.getRect(find.byType(CustomPaint).last);
          final first = direction == TextDirection.ltr
              ? dots.centerLeft + const Offset(3, 0)
              : dots.centerRight - const Offset(3, 0);
          await tester.tapAt(first);
          final last = direction == TextDirection.ltr
              ? dots.centerRight - const Offset(3, 0)
              : dots.centerLeft + const Offset(3, 0);
          await tester.tapAt(last);
          expect(selected, [0, 4], reason: '${variant.name} ${direction.name}');
        }
      }
    });

    testWidgets('a dot fades between its colours without a flash, '
        'whatever their opacity', (tester) async {
      final sampler = FrameSampler();
      final index = ValueNotifier(0);
      addTearDown(index.dispose);
      await pumpUna(
        tester,
        sampler.wrap(
          ColoredBox(
            color: const Color(0xFF000000),
            child: Align(
              alignment: Alignment.topLeft,
              child: ValueListenableBuilder(
                valueListenable: index,
                builder: (context, index, _) => PageIndicator(
                  count: 3,
                  index: index,
                  // A translucent white, as the dark border is, to an
                  // opaque colour.
                  color: const Color(0x1AFFFFFF),
                  activeColor: const Color(0xFFFF0000),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      index.value = 1;
      await tester.pump();
      final frames = await sampler.record(
        tester,
        tester.getTopLeft(find.byType(CustomPaint).last) + const Offset(3, 3),
        frames: 30,
      );
      expect(rgbOf(frames.first), [255, 0, 0]);
      expectMonotone(frames, reason: 'the first dot');
    });

    testWidgets('the arrow keys step while it has the focus', (tester) async {
      final selected = <int>[];
      await pumpUna(
        tester,
        indicator(index: 1, onSelected: selected.add),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(selected, [2, 0]);
    });

    testWidgets('without onSelected it is a picture: no focus, no taps', (
      tester,
    ) async {
      await pumpUna(tester, indicator());
      expect(
        find.descendant(
          of: find.byType(PageIndicator),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('it follows a page view under the finger', (tester) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      await pumpUna(
        tester,
        Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView(
                controller: controller,
                children: const [Text('A'), Text('B'), Text('C')],
              ),
            ),
            PageIndicator(count: 3, index: 0, controller: controller),
          ],
        ),
      );
      final gesture = await tester.startGesture(const Offset(600, 100));
      await gesture.moveBy(const Offset(-30, 0));
      await gesture.moveBy(const Offset(-610, 0));
      await tester.pump();
      expect(controller.page, closeTo(.5, .05));
      // The painter asks the controller: nothing was rebuilt for this.
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('announces the page and steps for assistive technology', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final selected = <int>[];
      await pumpUna(
        tester,
        indicator(index: 1, onSelected: selected.add),
      );
      final node = tester.getSemantics(find.byType(PageIndicator));
      final data = node.getSemanticsData();
      expect(data.value, 'Page 2 of 5');
      expect(data.increasedValue, 'Page 3 of 5');
      expect(data.decreasedValue, 'Page 1 of 5');
      tester.binding.pipelineOwner.semanticsOwner!.performAction(
        node.id,
        SemanticsAction.decrease,
      );
      expect(selected, [0]);

      await pumpUna(tester, indicator(index: 4));
      expect(
        tester.getSemantics(find.byType(PageIndicator)).label,
        'Page 5 of 5',
      );
      handle.dispose();
    });

    testWidgets('the overlay variant sits on a capsule with white dots', (
      tester,
    ) async {
      await pumpUna(
        tester,
        indicator(variant: PageIndicatorVariant.overlay),
      );
      final theme = themeOf(tester, find.byType(PageIndicator));
      final capsule = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(PageIndicator),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (capsule.decoration as ShapeDecoration).color,
        theme.carouselTheme.overlayColor,
      );
    });

    testWidgets("a carousel's own indicator follows its pages", (
      tester,
    ) async {
      await pumpUna(tester, carousel(showIndicator: true));
      final indicator = tester.widget<PageIndicator>(
        find.byType(PageIndicator),
      );
      expect(indicator.count, 4);
      expect(indicator.variant, PageIndicatorVariant.overlay);
      expect(indicator.controller, isNotNull);
      await tester.fling(find.text('Page 0'), const Offset(-200, 0), 1500);
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageIndicator>(find.byType(PageIndicator)).index,
        1,
      );
      // A single page needs no indicator.
      await pumpUna(tester, const SizedBox());
      await pumpUna(tester, carousel(count: 1, showIndicator: true));
      expect(find.byType(PageIndicator), findsNothing);
    });
  });
}
