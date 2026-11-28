import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/src/components/skeleton_paint.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

RenderSkeleton _renderOf(WidgetTester tester, [Finder? finder]) =>
    tester.renderObject<RenderSkeleton>(
      finder ??
          find.descendant(
            of: find.byType(Skeleton),
            matching: find.byType(SkeletonPaint),
          ),
    );

Widget _app(Widget child, {bool reduceMotion = false, ThemeData? theme}) =>
    UnaApp(
      theme: theme,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: Center(child: child),
        ),
      ),
    );

void main() {
  group('Skeleton', () {
    testWidgets('renders at the requested size', (tester) async {
      await tester.pumpWidget(
        _app(const Skeleton(width: 200, height: 16, animate: false)),
      );
      expect(tester.getSize(find.byType(Skeleton)), const Size(200, 16));
    });

    testWidgets('reads its colours from the theme', (tester) async {
      await tester.pumpWidget(
        _app(
          const Skeleton(width: 10, height: 10),
          theme: ThemeData(
            colorScheme: const GraphiteColorScheme.light(),
            brightness: Brightness.light,
            skeletonTheme: const SkeletonTheme(
              color: Color(0xFF123456),
              highlightColor: Color(0xFF654321),
              animate: false,
            ),
          ),
        ),
      );
      final render = _renderOf(tester);
      expect(render.color, const Color(0xFF123456));
      expect(render.highlightColor, const Color(0xFF654321));
      expect(render.motion, SkeletonMotion.still);
    });

    testWidgets('its highlight is lighter than its base, light and dark', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        final theme = ThemeData(brightness: brightness);
        final base = theme.skeletonTheme.color!;
        final highlight = theme.skeletonTheme.highlightColor!;
        // The same colour, only its alpha changes: no other colour on the way.
        expect(highlight.r, base.r);
        expect(highlight.g, base.g);
        expect(highlight.b, base.b);
        final page = theme.colorScheme.background;
        double luminance(Color c) =>
            Color.alphaBlend(c, page).computeLuminance();
        expect(
          luminance(highlight),
          greaterThan(luminance(base)),
          reason: brightness.name,
        );
      }
    });

    testWidgets('is hidden from semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const Skeleton(width: 10, height: 10, animate: false)),
      );
      expect(find.byType(ExcludeSemantics), findsWidgets);
      handle.dispose();
    });

    testWidgets('every skeleton moves to one clock, and only while one is '
        'shown', (tester) async {
      expect(SkeletonClock.instance.isTicking, isFalse);
      await tester.pumpWidget(
        _app(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeleton(width: 100, height: 20),
              SizedBox(height: 40),
              Skeleton(width: 300, height: 20),
            ],
          ),
        ),
      );
      expect(SkeletonClock.instance.isTicking, isTrue);
      await tester.pump(const Duration(milliseconds: 400));
      final renders = find
          .byType(SkeletonPaint)
          .evaluate()
          .map((e) => e.renderObject! as RenderSkeleton)
          .toList();
      expect(renders, hasLength(2));
      // Both see one band in the same place on the screen.
      expect(renders.first.bandCentre, isNotNull);
      expect(renders.first.bandCentre, renders.last.bandCentre);

      await tester.pumpWidget(const SizedBox());
      expect(SkeletonClock.instance.isTicking, isFalse);
    });

    testWidgets('the band crosses and then rests', (tester) async {
      await tester.pumpWidget(_app(const Skeleton(width: 100, height: 20)));
      final centres = <double?>[];
      for (var i = 0; i < 18; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        centres.add(_renderOf(tester).bandCentre);
      }
      final moving = centres.whereType<double>().toList();
      expect(moving.length, greaterThan(6));
      expect(moving.first, lessThan(moving[moving.length ~/ 2]));
      expect(centres, contains(isNull));
    });

    testWidgets('holds still and schedules nothing under reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const Skeleton(width: 100, height: 20), reduceMotion: true),
      );
      expect(_renderOf(tester).motion, SkeletonMotion.still);
      expect(_renderOf(tester).isListening, isFalse);
      expect(SkeletonClock.instance.isTicking, isFalse);
      // Nothing left running: this would time out otherwise.
      await tester.pumpAndSettle();
    });

    testWidgets('holds still off stage', (tester) async {
      await tester.pumpWidget(
        _app(
          const TickerMode(
            enabled: false,
            child: Skeleton(width: 100, height: 20),
          ),
        ),
      );
      expect(_renderOf(tester).motion, SkeletonMotion.still);
      expect(SkeletonClock.instance.isTicking, isFalse);

      await tester.pumpWidget(
        _app(
          const IndexedStack(
            children: [SizedBox(), Skeleton(width: 100, height: 20)],
          ),
        ),
      );
      expect(
        _renderOf(
          tester,
          find.byType(SkeletonPaint, skipOffstage: false),
        ).motion,
        SkeletonMotion.still,
      );
      expect(SkeletonClock.instance.isTicking, isFalse);
    });

    testWidgets('the named shapes take their metrics from the theme', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Skeleton.avatar(key: Key('avatar')),
              Skeleton.button(key: Key('button')),
              Skeleton.button(key: Key('sm'), size: ButtonSize.sm),
              Skeleton.chip(key: Key('chip')),
              Skeleton.circle(key: Key('circle'), size: 12),
            ],
          ),
        ),
      );
      final theme = themeOf(tester, find.byKey(const Key('avatar')));
      expect(
        tester.getSize(find.byKey(const Key('avatar'))),
        theme.avatarTheme.size,
      );
      expect(
        tester.getSize(find.byKey(const Key('button'))).height,
        theme.buttonSizesTheme.regular!.height,
      );
      expect(
        tester.getSize(find.byKey(const Key('sm'))).height,
        theme.buttonSizesTheme.sm!.height,
      );
      expect(
        tester.getSize(find.byKey(const Key('chip'))).height,
        theme.chipTheme.height,
      );
      expect(
        tester.getSize(find.byKey(const Key('circle'))),
        const Size(12, 12),
      );
    });
  });

  group('Skeleton shapes', () {
    testWidgets('SkeletonText is as tall as the text it stands in for', (
      tester,
    ) async {
      const style = TextStyle(fontSize: 15, height: 22 / 15);
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 300,
            child: SkeletonText(lines: 4, style: style),
          ),
        ),
      );
      expect(tester.getSize(find.byType(SkeletonText)).height, 88);
      final widths = find
          .byType(Skeleton)
          .evaluate()
          .map((e) => tester.getSize(find.byWidget(e.widget)).width)
          .toList();
      expect(widths, hasLength(4));
      expect(widths.first, 300);
      expect(widths.last, 180);
    });

    Widget gallery() => const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonText(),
          SkeletonText(lines: 1),
          SkeletonListTile(),
          SkeletonListTile(
            leading: null,
            subtitleLines: 2,
            trailing: Skeleton.button(width: 64),
          ),
          SkeletonCard(actions: 2),
          SkeletonCard(mediaAspectRatio: null, lines: 3),
          SkeletonChatBubble(),
          SkeletonChatBubble(direction: ChatBubbleDirection.outgoing),
          SkeletonTableRow(),
          SkeletonTableRow(columns: 3, flex: [2, 1, 1], row: 1),
          Wrap(
            children: [
              Skeleton.avatar(),
              Skeleton.button(),
              Skeleton.chip(),
            ],
          ),
          Row(
            children: [
              // Unbounded: a text and a bubble take a width of their own.
              SkeletonText(lines: 2),
            ],
          ),
        ],
      ),
    );

    testWidgets('lay out in every layout', (tester) async {
      await expectBuildsInEveryLayout(tester, (_) => gallery());
    });

    testWidgets('lay out at large text scales', (tester) async {
      for (final formFactor in FormFactor.values) {
        for (final scale in [1.0, 1.6, 2.4]) {
          await pumpUna(
            tester,
            Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: gallery(),
              ),
            ),
            formFactor: formFactor,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${formFactor.name} at $scale',
          );
          // An overflow is reported once per render object: start afresh.
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    });

    testWidgets('a chat bubble sits on its side with its tail corner', (
      tester,
    ) async {
      await pumpUna(
        tester,
        const Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonChatBubble(key: Key('in')),
                SkeletonChatBubble(
                  key: Key('out'),
                  direction: ChatBubbleDirection.outgoing,
                ),
              ],
            ),
          ),
        ),
      );
      final box = tester.getRect(find.byType(Column).first);
      final incoming = tester.getRect(
        find.descendant(
          of: find.byKey(const Key('in')),
          matching: find.byType(Skeleton),
        ),
      );
      final outgoing = tester.getRect(
        find.descendant(
          of: find.byKey(const Key('out')),
          matching: find.byType(Skeleton),
        ),
      );
      expect(incoming.left, box.left);
      expect(outgoing.right, box.right);
      final theme = themeOf(tester, find.byKey(const Key('in')));
      final tail = Radius.circular(theme.chatBubbleTheme.tailRadius!);
      final radius =
          _renderOf(
                tester,
                find.descendant(
                  of: find.byKey(const Key('in')),
                  matching: find.byType(SkeletonPaint),
                ),
              ).borderRadius
              as BorderRadiusDirectional;
      expect(radius.bottomStart, tail);
    });
  });
}
