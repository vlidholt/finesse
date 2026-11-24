import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Frame-by-frame checks of the navigation bars: one indicator that travels
/// between the destinations, icons that cross-fade from their regular to
/// their selected form, badges that pop, and a press that is acknowledged.
const _frame = Duration(milliseconds: 16);

// Springs without bounce, so "monotone" is exact.
final _motion = Motion.lively.copyWith(
  snappy: const MotionSpring(),
  bouncy: const MotionSpring(),
);

const _names = ['Home', 'Jobs', 'Chat', 'Me'];

List<NavigationDestination> _destinations({int? chatCount}) => [
  for (final name in _names)
    NavigationDestination(
      icon: SizedBox.square(key: Key('$name-icon'), dimension: 24),
      selectedIcon: SizedBox.square(key: Key('$name-selected'), dimension: 24),
      label: name,
      badgeCount: name == 'Chat' ? chatCount : null,
    ),
];

Widget _app(
  Widget child, {
  bool reduceMotion = false,
  Motion? motion,
  FormFactor formFactor = FormFactor.desktop,
}) {
  return FinesseApp(
    theme: ThemeData(motion: motion ?? _motion),
    formFactor: formFactor,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
        ),
        child: Center(child: child),
      ),
    ),
  );
}

RenderMovingIndicator _indicator(WidgetTester tester, Type bar) =>
    tester.renderObject<RenderMovingIndicator>(
      find.descendant(
        of: find.byType(bar),
        matching: find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_MovingIndicatorRenderWidget',
        ),
      ),
    );

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

/// The opacity [finder] is painted with, through every layer above it.
double _opacityOf(WidgetTester tester, Finder finder) {
  var opacity = 1.0;
  RenderObject? node = tester.renderObject(finder);
  while (node != null) {
    if (node is RenderOpacity) opacity *= node.opacity;
    if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
    node = node.parent;
  }
  return opacity;
}

/// The scale of the pop around a destination's icon.
double _iconScale(WidgetTester tester, Finder icon) => tester
    .widget<Transform>(
      find.ancestor(of: icon, matching: find.byType(Transform)).first,
    )
    .transform
    .storage[0];

void main() {
  group('NavigationBar', () {
    Widget bar(int? selected, {int? chatCount}) => NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (_) {},
      destinations: _destinations(chatCount: chatCount),
    );

    testWidgets('one indicator travels to the new destination, stretching '
        'on the way', (tester) async {
      await tester.pumpWidget(_app(bar(0)));
      await tester.pump(_frame);
      final indicator = _indicator(tester, NavigationBar);
      final start = indicator.indicatorRect!;

      await tester.pumpWidget(_app(bar(2)));
      final lefts = <double>[];
      final rights = <double>[];
      final widths = <double>[];
      for (var i = 0; i < 40; i++) {
        final rect = indicator.indicatorRect!;
        // One shape, fully there: nothing fades out here and in there.
        expect(indicator.indicatorOpacity, 1);
        lefts.add(rect.left);
        rights.add(rect.right);
        widths.add(rect.width);
        expect(rect.top, start.top);
        expect(rect.height, start.height);
        await tester.pump(_frame);
      }
      _expectMonotone(lefts, reason: 'left edge');
      _expectMonotone(rights, reason: 'right edge');
      // Two destinations along, the same size as it left.
      expect(lefts.last, closeTo(start.left + 2 * 88, .1));
      expect(widths.last, closeTo(start.width, .1));
      // The leading edge gets ahead of the trailing one: it stretches.
      expect(widths.reduce((a, b) => a > b ? a : b), greaterThan(start.width));
    });

    testWidgets('a second selection mid-travel carries on from where the '
        'indicator is', (tester) async {
      await tester.pumpWidget(_app(bar(0)));
      await tester.pump(_frame);
      final indicator = _indicator(tester, NavigationBar);
      await tester.pumpWidget(_app(bar(3)));
      for (var i = 0; i < 5; i++) {
        await tester.pump(_frame);
      }
      final lefts = <double>[indicator.indicatorRect!.left];
      await tester.pumpWidget(_app(bar(1)));
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        lefts.add(indicator.indicatorRect!.left);
      }
      // No frame moves it further than a spring could in 16 ms.
      for (var i = 1; i < lefts.length; i++) {
        expect((lefts[i] - lefts[i - 1]).abs(), lessThan(40));
      }
      final settled = MatrixUtils.transformRect(
        indicator.getTransformTo(null),
        indicator.indicatorRect!,
      );
      expect(
        settled.center.dx,
        closeTo(tester.getRect(find.text('Jobs')).center.dx, .5),
      );
    });

    testWidgets('the icon cross-fades to its selected form with a pop, and '
        'the colours fade', (tester) async {
      await tester.pumpWidget(_app(bar(0)));
      await tester.pump(_frame);
      // At rest there is one icon per destination.
      expect(find.byKey(const Key('Home-selected')), findsOneWidget);
      expect(find.byKey(const Key('Home-icon')), findsNothing);
      expect(find.byKey(const Key('Chat-icon')), findsOneWidget);
      expect(find.byKey(const Key('Chat-selected')), findsNothing);

      Color labelColor(String label) =>
          tester.widget<Text>(find.text(label)).style!.color!;
      final resting = labelColor('Chat');
      final selected = labelColor('Home');
      expect(resting, isNot(selected));

      await tester.pumpWidget(_app(bar(2)));
      final incoming = <double>[];
      final outgoing = <double>[];
      final scales = <double>[];
      var midLabel = false;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        final arriving = find.byKey(const Key('Chat-selected'));
        final leaving = find.byKey(const Key('Chat-icon'));
        incoming.add(
          arriving.evaluate().isEmpty ? 0 : _opacityOf(tester, arriving),
        );
        outgoing.add(
          leaving.evaluate().isEmpty ? 0 : _opacityOf(tester, leaving),
        );
        scales.add(
          _iconScale(tester, arriving.evaluate().isEmpty ? leaving : arriving),
        );
        final now = labelColor('Chat');
        if (now != resting && now != selected) midLabel = true;
      }
      _expectMonotone(incoming, reason: 'the selected icon');
      _expectMonotone(outgoing, reason: 'the regular icon');
      // A cross-fade: there are frames with both on screen…
      expect(
        [
          for (var i = 0; i < incoming.length; i++)
            incoming[i] > 0 && outgoing[i] > 0,
        ],
        contains(true),
      );
      // …a pop on the way, back to rest at the end…
      expect(scales.reduce((a, b) => a > b ? a : b), greaterThan(1.03));
      expect(scales.last, closeTo(1, 1e-6));
      // …and the label's colour passed through the colours between.
      expect(midLabel, isTrue);
      expect(labelColor('Chat'), selected);
      expect(labelColor('Home'), resting);
      // At rest again, the other icon of each is gone from the tree.
      expect(find.byKey(const Key('Chat-icon')), findsNothing);
      expect(find.byKey(const Key('Home-selected')), findsNothing);
      // The one that was deselected only faded: no pop.
      expect(_iconScale(tester, find.byKey(const Key('Home-icon'))), 1);
    });

    testWidgets('a badge pops in when the first notification arrives and '
        'out when the last is read', (tester) async {
      await tester.pumpWidget(_app(bar(0)));
      await tester.pump(_frame);
      expect(find.text('2'), findsNothing);
      // The icon is not rebuilt around a new badge: same element.
      final icon = tester.element(find.byKey(const Key('Chat-icon')));

      await tester.pumpWidget(_app(bar(0, chatCount: 2)));
      await tester.pump(_frame);
      await tester.pump(_frame);
      expect(find.text('2'), findsOneWidget);
      // Still growing: one of the transforms around it is short of 1.
      expect(
        tester
            .widgetList<Transform>(
              find.ancestor(
                of: find.text('2'),
                matching: find.byType(Transform),
              ),
            )
            .map((t) => t.transform.storage[0]),
        contains(lessThan(1)),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.element(find.byKey(const Key('Chat-icon'))), same(icon));

      await tester.pumpWidget(_app(bar(0)));
      await tester.pump(_frame);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(_frame);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('with reduced motion the indicator and the icon change at '
        'once', (tester) async {
      await tester.pumpWidget(_app(bar(0), reduceMotion: true));
      await tester.pump(_frame);
      final indicator = _indicator(tester, NavigationBar);
      final start = indicator.indicatorRect!;
      await tester.pumpWidget(_app(bar(2), reduceMotion: true));
      await tester.pump(_frame);
      expect(indicator.indicatorRect!.left, closeTo(start.left + 176, .1));
      expect(indicator.indicatorRect!.width, closeTo(start.width, .1));
      expect(find.byKey(const Key('Chat-selected')), findsOneWidget);
      expect(find.byKey(const Key('Chat-icon')), findsNothing);
      expect(_iconScale(tester, find.byKey(const Key('Chat-selected'))), 1);
    });
  });

  group('BottomNavigationBar', () {
    Widget bar(int? selected) => BottomNavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (_) {},
      action: NavigationAction(
        icon: const SizedBox.square(dimension: 22),
        label: 'Create',
        onPressed: () {},
      ),
      destinations: _destinations(),
    );

    testWidgets('one lens travels behind the destinations, stretching, and '
        'settles on the new one', (tester) async {
      await tester.pumpWidget(_app(bar(0), formFactor: FormFactor.mobile));
      await tester.pump(_frame);
      final lens = _indicator(tester, BottomNavigationBar);
      final start = lens.indicatorRect!;
      final home = tester.getRect(find.bySemanticsLabel('Home'));
      expect(
        MatrixUtils.transformRect(lens.getTransformTo(null), start),
        home,
      );

      await tester.pumpWidget(_app(bar(3), formFactor: FormFactor.mobile));
      final lefts = <double>[];
      final widths = <double>[];
      for (var i = 0; i < 40; i++) {
        final rect = lens.indicatorRect!;
        expect(lens.indicatorOpacity, 1);
        lefts.add(rect.left);
        widths.add(rect.width);
        await tester.pump(_frame);
      }
      _expectMonotone(lefts, reason: 'the lens');
      expect(widths.reduce((a, b) => a > b ? a : b), greaterThan(start.width));
      expect(
        MatrixUtils.transformRect(
          lens.getTransformTo(null),
          lens.indicatorRect!,
        ),
        tester.getRect(find.bySemanticsLabel('Me')),
      );
      // The action in the middle is not a destination: the lens passes
      // behind it and never rests there.
      expect(
        tester
            .widgetList<MovingIndicatorTarget>(
              find.byType(MovingIndicatorTarget),
            )
            .length,
        4,
      );
    });

    testWidgets('a tap is acknowledged: the icon dips and springs back, the '
        'lens under it does not shrink', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (context, setState) => BottomNavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: _destinations(),
            ),
          ),
          formFactor: FormFactor.mobile,
        ),
      );
      await tester.pump(_frame);
      final lens = _indicator(tester, BottomNavigationBar);
      final size = lens.indicatorRect!.size;

      double pressScale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.bySemanticsLabel('Jobs'),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .storage[0];

      // Down and up within one frame: never built pressed.
      await tester.tap(find.bySemanticsLabel('Jobs'));
      var lowest = 1.0;
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        final scale = pressScale();
        if (scale < lowest) lowest = scale;
        expect(lens.indicatorRect!.height, size.height);
      }
      expect(index, 1);
      expect(lowest, lessThan(.995));
      expect(lowest, greaterThanOrEqualTo(_motion.pressScale - 1e-6));
      expect(pressScale(), closeTo(1, 1e-6));
      expect(lens.indicatorRect!.size, size);
    });
  });
}
