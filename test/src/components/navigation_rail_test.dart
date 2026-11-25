import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:finesse/src/utils/moving_indicator.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

/// [NavigationRail]: the destinations down the start edge, and the three
/// places a [NavigationScaffold] can put them.
const _frame = Duration(milliseconds: 16);

const _destinations = [
  NavigationDestination(
    icon: PhosphorIcon(PhosphorIconsRegular.house),
    selectedIcon: PhosphorIcon(PhosphorIconsFill.house),
    label: 'Home',
  ),
  NavigationDestination(
    icon: PhosphorIcon(PhosphorIconsRegular.chatCircleDots),
    label: 'Messages',
    badgeCount: 3,
  ),
  NavigationDestination(
    icon: PhosphorIcon(PhosphorIconsRegular.bell),
    label: 'Alerts',
    showInBottomBar: false,
  ),
];

Widget _rail({
  int? selectedIndex = 0,
  ValueChanged<int>? onSelected,
  bool extended = false,
  Widget? leading,
  Widget? trailing,
  NavigationAction? action,
  double height = 600,
}) {
  return Align(
    alignment: AlignmentDirectional.topStart,
    child: SizedBox(
      height: height,
      child: NavigationRail(
        destinations: _destinations,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        extended: extended,
        leading: leading,
        trailing: trailing,
        action: action,
      ),
    ),
  );
}

Finder _items() => find.descendant(
  of: find.byType(NavigationRail),
  matching: find.byType(Pressable),
);

RenderMovingIndicator _indicator(WidgetTester tester) => tester.renderObject(
  find.descendant(
    of: find.byType(NavigationRail),
    matching: find.byWidgetPredicate(
      (w) => '${w.runtimeType}' == '_MovingIndicatorRenderWidget',
    ),
  ),
);

void main() {
  group('NavigationRail', () {
    testWidgets('builds in every layout and style', (tester) async {
      for (final style in [StyleTokens.finesse, StyleTokens.nova]) {
        for (final layout in kLayouts) {
          for (final extended in [false, true]) {
            await pumpFinesse(
              tester,
              _rail(onSelected: (_) {}, extended: extended),
              formFactor: layout.formFactor,
              textDirection: layout.textDirection,
              theme: ThemeData(style: style),
            );
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          }
        }
      }
    });

    testWidgets('is the theme width wide plus its hairline, on the start '
        'edge in both directions', (tester) async {
      for (final direction in TextDirection.values) {
        await pumpFinesse(
          tester,
          _rail(onSelected: (_) {}),
          textDirection: direction,
        );
        final theme = Theme.of(tester.element(find.byType(NavigationRail)));
        final rail = tester.getRect(find.byType(NavigationRail));
        expect(rail.width, theme.navigationRailTheme.width! + 1);
        expect(rail.height, 600);
        if (direction == TextDirection.ltr) {
          expect(rail.left, 0);
        } else {
          expect(rail.right, 1280);
        }
        expect(
          NavigationRail.widthOf(tester.element(find.byType(NavigationRail))),
          rail.width,
        );
        // The line is on the outer edge.
        final line = tester.getRect(
          find.byWidgetPredicate(
            (w) => w is MovingIndicatorTarget && w.selected,
          ),
        );
        expect(
          direction == TextDirection.ltr ? line.left : line.right,
          direction == TextDirection.ltr ? rail.left : rail.right,
        );
        expect(line.width, theme.navigationRailTheme.indicatorWidth);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('keeps clear of the safe area', (tester) async {
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1280, 800),
            padding: EdgeInsets.fromLTRB(30, 40, 0, 20),
          ),
          child: _rail(
            onSelected: (_) {},
            leading: const SizedBox.square(
              key: Key('leading'),
              dimension: 20,
            ),
          ),
        ),
      );
      final theme = Theme.of(tester.element(find.byType(NavigationRail)));
      final width = theme.navigationRailTheme.width!;
      expect(tester.getSize(find.byType(NavigationRail)).width, width + 31);
      final leading = tester.getRect(find.byKey(const Key('leading')));
      expect(leading.top, 40 + theme.navigationRailTheme.padding!);
      // Centred over the icons, past the inset.
      expect(leading.center.dx, 30 + width / 2);
    });

    testWidgets('a tap reports the destination; one line travels there '
        'without turning back', (tester) async {
      var index = 0;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => _rail(
            selectedIndex: index,
            onSelected: (i) => setState(() => index = i),
          ),
        ),
        theme: ThemeData(
          motion: Motion.lively.copyWith(snappy: const MotionSpring()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final indicator = _indicator(tester);
      final start = indicator.indicatorRect!;
      await tester.tap(find.text('Alerts'));
      expect(index, 2);
      await tester.pump();
      final tops = <double>[];
      for (var i = 0; i < 40; i++) {
        await tester.pump(_frame);
        tops.add(indicator.indicatorRect!.top);
      }
      for (var i = 1; i < tops.length; i++) {
        expect(tops[i], greaterThanOrEqualTo(tops[i - 1] - 1e-6));
      }
      expect(tops.toSet().length, greaterThan(5));
      await tester.pumpAndSettle();
      expect(indicator.indicatorRect!.top, greaterThan(start.top + 100));
      expect(indicator.indicatorRect!.height, start.height);
    });

    testWidgets('extended, the labels sit beside the icons in a wider rail, '
        'and the change morphs without a jump', (tester) async {
      var extended = false;
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return _rail(onSelected: (_) {}, extended: extended);
          },
        ),
      );
      final theme = Theme.of(tester.element(find.byType(NavigationRail)));
      final style = theme.navigationRailTheme;
      final iconBefore = tester.getCenter(find.byType(PhosphorIcon).first);
      final labelBefore = tester.getRect(find.text('Home'));
      // Under the icon.
      expect(labelBefore.top, greaterThan(iconBefore.dy));
      expect(labelBefore.center.dx, moreOrLessEquals(style.width! / 2));

      rebuild(() => extended = true);
      await tester.pump();
      final widths = <double>[];
      for (var i = 0; i < 60; i++) {
        await tester.pump(_frame);
        expect(tester.takeException(), isNull);
        widths.add(tester.getSize(find.byType(NavigationRail)).width);
      }
      for (var i = 1; i < widths.length; i++) {
        expect(widths[i], greaterThanOrEqualTo(widths[i - 1] - 1e-6));
        expect(widths[i] - widths[i - 1], lessThan(40));
      }
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(NavigationRail)).width,
        style.extendedWidth! + 1,
      );
      final icon = tester.getRect(find.byType(PhosphorIcon).first);
      final label = tester.getRect(find.text('Home'));
      // Beside the icon, which has not moved sideways.
      expect(icon.center.dx, moreOrLessEquals(iconBefore.dx));
      expect(label.left, greaterThan(icon.right));
      expect(label.center.dy, moreOrLessEquals(icon.center.dy, epsilon: 1));
      expect(find.text('Home'), findsOneWidget);
      expect(
        tester.getSize(_items().first).height,
        style.extendedItemHeight,
      );
    });

    testWidgets('with reduced motion the change is immediate', (tester) async {
      var extended = false;
      late StateSetter rebuild;
      await pumpFinesse(
        tester,
        MediaQuery(
          data: const MediaQueryData(
            size: Size(1280, 800),
            disableAnimations: true,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return _rail(onSelected: (_) {}, extended: extended);
            },
          ),
        ),
      );
      rebuild(() => extended = true);
      await tester.pump();
      await tester.pump(_frame);
      final theme = Theme.of(tester.element(find.byType(NavigationRail)));
      expect(
        tester.getSize(find.byType(NavigationRail)).width,
        theme.navigationRailTheme.extendedWidth! + 1,
      );
    });

    testWidgets('leading at the top, the action under it, trailing at the '
        'bottom; the action is a button of its own', (tester) async {
      var composed = 0;
      await pumpFinesse(
        tester,
        _rail(
          onSelected: (_) {},
          leading: const SizedBox.square(key: Key('leading'), dimension: 24),
          trailing: const SizedBox.square(key: Key('trailing'), dimension: 24),
          action: NavigationAction(
            icon: const PhosphorIcon(PhosphorIconsBold.plus),
            label: 'Compose',
            onPressed: () => composed++,
          ),
        ),
      );
      final leading = tester.getRect(find.byKey(const Key('leading')));
      final trailing = tester.getRect(find.byKey(const Key('trailing')));
      final first = tester.getRect(find.text('Home'));
      final action = tester.getRect(_items().first);
      expect(leading.bottom, lessThanOrEqualTo(action.top));
      expect(action.bottom, lessThanOrEqualTo(first.top));
      expect(
        trailing.top,
        greaterThan(tester.getRect(find.text('Alerts')).top),
      );
      expect(trailing.bottom, lessThanOrEqualTo(600));
      // Round, in the middle of the rail.
      expect(action.width, action.height);
      expect(action.center.dx, leading.center.dx);
      await tester.tapAt(action.center);
      expect(composed, 1);
    });

    testWidgets('too short for its destinations, they scroll and nothing '
        'overflows', (tester) async {
      await pumpFinesse(
        tester,
        _rail(
          onSelected: (_) {},
          height: 150,
          trailing: const SizedBox.square(key: Key('trailing'), dimension: 24),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.byKey(const Key('trailing'))).bottom,
        lessThanOrEqualTo(150),
      );
      await tester.drag(find.text('Home'), const Offset(0, -80));
      await tester.pump();
      expect(tester.getRect(find.text('Home')).top, lessThan(0));
    });

    testWidgets('Up and Down move the focus; Enter chooses', (tester) async {
      final chosen = <int>[];
      await pumpFinesse(tester, _rail(onSelected: chosen.add));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(chosen, [2, 1]);
    });

    testWidgets('each destination is one button to a screen reader: its '
        'label, whether it is selected, and its count', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, _rail(selectedIndex: 1, onSelected: (_) {}));
      for (final (index, label) in ['Home', 'Messages', 'Alerts'].indexed) {
        final data = tester
            .getSemantics(find.bySemanticsLabel(label))
            .getSemanticsData();
        expect(data.flagsCollection.isButton, isTrue);
        expect(
          data.flagsCollection.isSelected,
          index == 1 ? ui.Tristate.isTrue : ui.Tristate.isFalse,
        );
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
        if (index == 1) expect(data.value, '3');
      }
      handle.dispose();
    });

    testWidgets('grows with the text scale instead of clipping its labels', (
      tester,
    ) async {
      for (final extended in [false, true]) {
        await pumpFinesse(
          tester,
          MediaQuery(
            data: const MediaQueryData(
              size: Size(1280, 800),
              textScaler: TextScaler.linear(2),
            ),
            child: _rail(onSelected: (_) {}, extended: extended),
          ),
        );
        expect(tester.takeException(), isNull);
        final item = tester.getRect(_items().first);
        final label = tester.getRect(find.text('Home'));
        expect(label.top, greaterThanOrEqualTo(item.top));
        expect(label.bottom, lessThanOrEqualTo(item.bottom));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('the theme restyles it', (tester) async {
      const colour = Color(0xFF123456);
      await pumpFinesse(
        tester,
        _rail(onSelected: (_) {}),
        theme: ThemeData(
          navigationRailTheme: const NavigationRailTheme(
            width: 96,
            indicatorColor: colour,
            indicatorWidth: 5,
          ),
        ),
      );
      expect(tester.getSize(find.byType(NavigationRail)).width, 97);
      final target = tester.widget<MovingIndicatorTarget>(
        find.byWidgetPredicate((w) => w is MovingIndicatorTarget && w.selected),
      );
      expect((target.decoration as BoxDecoration).color, colour);
      expect(tester.getSize(find.byWidget(target)).width, 5);
    });
  });

  group('NavigationScaffold layouts', () {
    Widget scaffold({
      NavigationLayout layout = NavigationLayout.auto,
      int index = 0,
      ValueChanged<int>? onSelected,
    }) {
      return NavigationScaffold(
        layout: layout,
        destinations: _destinations,
        selectedIndex: index,
        onDestinationSelected: onSelected,
        leading: const SizedBox.square(key: Key('logo'), dimension: 24),
        action: NavigationAction(
          icon: const PhosphorIcon(PhosphorIconsBold.plus),
          label: 'Compose',
          onPressed: () {},
        ),
        body: ListView(
          children: const [SizedBox(key: Key('first'), height: 80)],
        ),
      );
    }

    testWidgets('auto is the top bar on a desktop and the bottom bar on a '
        'phone', (tester) async {
      await pumpFinesse(tester, scaffold());
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());

      await pumpFinesse(tester, scaffold(), formFactor: FormFactor.mobile);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('a layout can be asked for on either form factor', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        scaffold(layout: NavigationLayout.bottomBar),
      );
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpFinesse(
        tester,
        scaffold(layout: NavigationLayout.topBar),
        formFactor: FormFactor.mobile,
        surfaceSize: const Size(900, 700),
      );
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('the rail sits under the app bar, beside the page, in both '
        'directions', (tester) async {
      for (final direction in TextDirection.values) {
        final chosen = <int>[];
        await pumpFinesse(
          tester,
          scaffold(layout: NavigationLayout.rail, onSelected: chosen.add),
          textDirection: direction,
        );
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(BottomNavigationBar), findsNothing);
        final bar = tester.getRect(find.byType(AppBar));
        final rail = tester.getRect(find.byType(NavigationRail));
        // The app bar keeps its leading widget and spans the window.
        expect(find.byKey(const Key('logo')), findsOneWidget);
        expect(bar.width, 1280);
        expect(rail.height, 800);
        // Its content starts below the bar.
        expect(
          tester.getRect(find.text('Home')).top,
          greaterThan(bar.bottom),
        );
        // The page is beside it and starts below the bar too.
        final first = tester.getRect(find.byKey(const Key('first')));
        expect(first.top, bar.bottom);
        if (direction == TextDirection.ltr) {
          expect(first.left, rail.right);
          expect(first.right, 1280);
        } else {
          expect(first.right, rail.left);
          expect(first.left, 0);
        }
        // Indices are into the whole list, whatever the rail lists.
        await tester.tap(find.text('Alerts'));
        expect(chosen, [2]);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('showInRail takes a destination off the rail; left alone it '
        'follows showInTopBar', (tester) async {
      await pumpFinesse(
        tester,
        NavigationScaffold(
          layout: NavigationLayout.rail,
          selectedIndex: 2,
          onDestinationSelected: (_) {},
          destinations: const [
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.bell),
              label: 'Alerts',
              showInTopBar: false,
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.gear),
              label: 'Settings',
              showInTopBar: false,
              showInRail: true,
            ),
            NavigationDestination(
              icon: PhosphorIcon(PhosphorIconsRegular.user),
              label: 'Me',
              showInRail: false,
            ),
          ],
          body: const SizedBox.expand(),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Alerts'), findsNothing);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Me'), findsNothing);
      // Settings is the second on the rail and the selected one.
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        1,
      );
    });
  });
}
