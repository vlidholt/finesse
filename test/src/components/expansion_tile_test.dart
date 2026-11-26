import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A row that counts its taps, to show that its state survives.
class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text('Tapped $taps'),
    onTap: () => setState(() => taps++),
  );
}

void main() {
  late List<bool> changes;

  setUp(() => changes = []);

  Widget tile({
    bool? open,
    bool initiallyOpen = false,
    bool maintainState = false,
    bool enabled = true,
    List<Widget>? children,
  }) => ExpansionTile(
    leading: const PhosphorIcon(PhosphorIconsRegular.bell),
    title: const Text('Notifications'),
    value: const Text('2 on'),
    open: open,
    initiallyOpen: initiallyOpen,
    maintainState: maintainState,
    enabled: enabled,
    onOpenChanged: changes.add,
    children:
        children ??
        const [
          ListTile(title: Text('Mentions')),
          ListTile(title: Text('Replies')),
        ],
  );

  Widget section(Widget child) => SingleChildScrollView(
    child: ListSection(
      children: [
        const ListTile(title: Text('Above')),
        child,
        const ListTile(title: Text('Below')),
      ],
    ),
  );

  double rowsHeight(WidgetTester tester) =>
      tester.getSize(find.byType(ExpandReveal)).height;

  group('ExpansionTile', () {
    testWidgets('builds in every layout, open, at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: section(tile(initiallyOpen: true)),
        ),
      );
    });

    testWidgets('a tap on the heading opens it and another closes it', (
      tester,
    ) async {
      await pumpUna(tester, section(tile()));
      expect(find.text('Mentions'), findsNothing);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsOneWidget);
      expect(find.text('Replies'), findsOneWidget);
      expect(changes, [true]);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsNothing);
      expect(changes, [true, false]);
    });

    testWidgets('given open, it shows what it is told and only reports', (
      tester,
    ) async {
      var open = false;
      late StateSetter rebuild;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return section(tile(open: open));
          },
        ),
      );
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(changes, [true]);
      expect(find.text('Mentions'), findsNothing);

      rebuild(() => open = true);
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsOneWidget);
    });

    testWidgets('Enter and Space on the focused heading toggle it', (
      tester,
    ) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpUna(
        tester,
        section(
          ExpansionTile(
            title: const Text('Notifications'),
            focusNode: node,
            onOpenChanged: changes.add,
            children: const [ListTile(title: Text('Mentions'))],
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsNothing);
      expect(changes, [true, false]);
    });

    testWidgets('the heading says whether it is expanded', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(tester, section(tile()));
      expect(
        tester.getSemantics(find.text('Notifications')),
        containsSemantics(
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.text('Notifications')),
        containsSemantics(isExpanded: true),
      );
      handle.dispose();
    });

    testWidgets('the rows unfold steadily, and a change of mind halfway '
        'turns back from where they are', (tester) async {
      await pumpUna(tester, section(tile()));
      await tester.tap(find.text('Notifications'));
      await tester.pump();
      final heights = <double>[];
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        heights.add(rowsHeight(tester));
      }
      for (var i = 1; i < heights.length; i++) {
        expect(heights[i], greaterThanOrEqualTo(heights[i - 1]));
      }
      final halfway = heights.last;
      expect(halfway, greaterThan(0));

      // Closed again before it was fully open: no jump.
      await tester.tap(find.text('Notifications'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(rowsHeight(tester), closeTo(halfway, halfway * .25));
      var last = rowsHeight(tester);
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (find.byType(ExpandReveal).evaluate().isEmpty) break;
        final now = rowsHeight(tester);
        expect(now, lessThanOrEqualTo(last + 0.01));
        last = now;
      }
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('with motion switched off it opens in one frame', (
      tester,
    ) async {
      await pumpUna(
        tester,
        section(tile()),
        theme: ThemeData(motion: Motion.none),
      );
      await tester.tap(find.text('Notifications'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Mentions'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('maintainState keeps the rows state while closed, and out '
        'of reach', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        section(
          tile(
            initiallyOpen: true,
            maintainState: true,
            children: const [
              _Counter(),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Tapped 0'));
      await tester.pump();
      expect(find.text('Tapped 1'), findsOneWidget);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Tapped 1'), findsNothing);
      expect(find.text('Tapped 1', skipOffstage: false), findsOneWidget);
      expect(find.bySemanticsLabel('Tapped 1'), findsNothing);

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(find.text('Tapped 1'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('in a section, the heading of an open row is no longer its '
        'bottom, and the last row under it is', (tester) async {
      ListSectionPosition positionOf(String text) => tester
          .element(find.text(text))
          .dependOnInheritedWidgetOfExactType<ListSectionScope>()!
          .position;

      await pumpUna(
        tester,
        SingleChildScrollView(
          child: ListSection(
            children: [
              const ListTile(title: Text('Above')),
              tile(),
            ],
          ),
        ),
      );
      expect(positionOf('Notifications'), ListSectionPosition.last);
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      expect(positionOf('Notifications'), ListSectionPosition.middle);
      expect(positionOf('Mentions'), ListSectionPosition.middle);
      expect(positionOf('Replies'), ListSectionPosition.last);
    });

    testWidgets('disabled, a tap changes nothing', (tester) async {
      await pumpUna(tester, section(tile(enabled: false)));
      await tester.tap(find.text('Notifications'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Mentions'), findsNothing);
      expect(changes, isEmpty);
    });

    testWidgets('at rest it schedules nothing', (tester) async {
      await pumpUna(tester, section(tile(initiallyOpen: true)));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
