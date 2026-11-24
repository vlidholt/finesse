import 'package:example/common/page_switch.dart';
import 'package:example/common/theme_editor/customizer_panel.dart';
import 'package:example/strand/screens/home_screen.dart';
import 'package:example/strand/strand_shell.dart';
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

/// The app-level transitions: a Strand destination, a section or a docs
/// page comes in from its side out of the page colour, and the theme
/// editor slides in from the edge — each in one movement, with the page
/// live from the first frame and its state kept.
const _frame = Duration(milliseconds: 16);

void _expectMonotone(List<double> values, {required String reason}) {
  final rising = values.last >= values.first;
  for (var i = 1; i < values.length; i++) {
    final step = values[i] - values[i - 1];
    expect(
      rising ? step >= -1e-9 : step <= 1e-9,
      isTrue,
      reason: '$reason turned back at frame $i: $values',
    );
  }
}

/// The cover and the slide of the [PageSwitch] found by [finder].
({double cover, Offset offset}) _switchOf(WidgetTester tester, Finder finder) {
  // The cover is a box of the page colour painted at the cover's opacity,
  // after the page: the last box in the switch that takes no pointers.
  final cover = tester.widget<ColoredBox>(
    find
        .descendant(
          of: finder,
          matching: find.descendant(
            of: find.byType(IgnorePointer),
            matching: find.byType(ColoredBox),
          ),
        )
        .last,
  );
  final transform = tester.widget<Transform>(
    find.descendant(of: finder, matching: find.byType(Transform)).first,
  );
  final translation = transform.transform.getTranslation();
  return (
    cover: cover.color.a,
    offset: Offset(translation.x, translation.y),
  );
}

void main() {
  setUpAll(setUpFonts);

  group('PageSwitch', () {
    Widget host(int value, {Axis axis = Axis.horizontal, bool reduce = false}) {
      return FinesseApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
            child: PageSwitch(
              value: value,
              axis: axis,
              child: const SizedBox.expand(key: Key('page')),
            ),
          ),
        ),
      );
    }

    testWidgets('nothing plays on first build', (tester) async {
      await tester.pumpWidget(host(0));
      final now = _switchOf(tester, find.byType(PageSwitch));
      expect(now.cover, 0);
      expect(now.offset, Offset.zero);
    });

    testWidgets('a later page comes from the end, an earlier one from the '
        'start, out of the page colour', (tester) async {
      await tester.pumpWidget(host(0));
      for (final (value, sign) in [(2, 1), (1, -1)]) {
        await tester.pumpWidget(host(value));
        final cover = <double>[];
        final slide = <double>[];
        for (var i = 0; i < 20; i++) {
          final now = _switchOf(tester, find.byType(PageSwitch));
          cover.add(now.cover);
          slide.add(now.offset.dx * sign);
          expect(now.offset.dy, 0);
          await tester.pump(_frame);
        }
        // Washed out, never hidden: a bare frame would read as a flash.
        expect(cover.first, inExclusiveRange(.3, .8));
        expect(slide.first, greaterThan(0));
        _expectMonotone(cover, reason: 'cover ($value)');
        _expectMonotone(slide, reason: 'slide ($value)');
        expect(cover.last, 0);
        expect(slide.last, 0);
      }
      // The page itself is never made translucent — it may be full of
      // glass — and never stops taking pointers.
      expect(
        find.ancestor(
          of: find.byKey(const Key('page')),
          matching: find.descendant(
            of: find.byType(PageSwitch),
            matching: find.byWidgetPredicate(
              (w) => w is Opacity || w is FadeTransition || w is IgnorePointer,
            ),
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('on a vertical axis it comes from below or above', (
      tester,
    ) async {
      await tester.pumpWidget(host(0, axis: Axis.vertical));
      await tester.pumpWidget(host(3, axis: Axis.vertical));
      final now = _switchOf(tester, find.byType(PageSwitch));
      expect(now.offset.dx, 0);
      expect(now.offset.dy, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('with reduced motion it only fades', (tester) async {
      await tester.pumpWidget(host(0, reduce: true));
      await tester.pumpWidget(host(1, reduce: true));
      final cover = <double>[];
      for (var i = 0; i < 12; i++) {
        final now = _switchOf(tester, find.byType(PageSwitch));
        expect(now.offset, Offset.zero);
        cover.add(now.cover);
        await tester.pump(_frame);
      }
      _expectMonotone(cover, reason: 'cover');
      expect(cover.last, 0);
    });
  });

  group('the app', () {
    testWidgets('a destination switched to slides in from its side and the '
        'screens keep their state', (tester) async {
      await pumpApp(tester);
      final context = tester.element(find.byType(StrandShell));
      final home = tester.element(find.byType(HomeScreen));
      final shell = find.descendant(
        of: find.byType(StrandShell),
        matching: find.byType(PageSwitch),
      );

      strandDestinationProvider.of(context).value = StrandDestination.jobs;
      await tester.pump();
      final forward = _switchOf(tester, shell);
      expect(forward.cover, inExclusiveRange(.3, .8));
      // Jobs is after Home: from the end.
      expect(forward.offset.dx, greaterThan(0));
      await settle(tester);
      expect(_switchOf(tester, shell).cover, 0);

      strandDestinationProvider.of(context).value = StrandDestination.home;
      await tester.pump();
      expect(_switchOf(tester, shell).offset.dx, lessThan(0));
      await settle(tester);
      // The same Home screen as before, not a new one.
      expect(tester.element(find.byType(HomeScreen)), same(home));
    });

    testWidgets('the theme editor slides in from the end edge and out again, '
        'and is gone when it has left', (tester) async {
      await pumpApp(tester);
      expect(find.byType(ThemeCustomizerPanel), findsNothing);
      editorOpenSignal(tester).value = true;
      await tester.pump();
      final lefts = <double>[];
      for (var i = 0; i < 40; i++) {
        lefts.add(tester.getTopLeft(find.byType(ThemeCustomizerPanel)).dx);
        await tester.pump(_frame);
      }
      // From off the right edge to docked.
      expect(lefts.first, closeTo(desktopSize.width, 1));
      _expectMonotone(lefts, reason: 'the panel');
      expect(
        lefts.last,
        closeTo(desktopSize.width - ThemeCustomizerPanel.width, .5),
      );
      expect(
        lefts.where((x) => x > lefts.last + 1 && x < lefts.first - 1),
        isNotEmpty,
      );

      editorOpenSignal(tester).value = false;
      await tester.pump();
      final leaving = <double>[];
      var frames = 0;
      while (find.byType(ThemeCustomizerPanel).evaluate().isNotEmpty &&
          frames < 80) {
        leaving.add(tester.getTopLeft(find.byType(ThemeCustomizerPanel)).dx);
        await tester.pump(_frame);
        frames++;
      }
      _expectMonotone(leaving, reason: 'the panel leaving');
      expect(find.byType(ThemeCustomizerPanel), findsNothing);
      expect(leaving.length, greaterThan(3));
    });
  });
}
