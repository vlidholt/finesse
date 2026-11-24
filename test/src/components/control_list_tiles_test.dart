import 'dart:ui' as ui;

import 'package:finesse/finesse.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

void main() {
  Widget host(Widget child, {double width = 340}) => Align(
    alignment: Alignment.topCenter,
    child: SizedBox(
      width: width,
      child: ListSection(children: [child]),
    ),
  );

  /// The one semantics node of the tile.
  SemanticsData dataOf(WidgetTester tester) =>
      tester.getSemantics(find.byType(Pressable)).getSemanticsData();

  group('SwitchListTile', () {
    Widget tile({
      bool value = false,
      ValueChanged<bool>? onChanged,
      bool enabled = true,
      ControlAffinity affinity = ControlAffinity.trailing,
      FocusNode? focusNode,
    }) => host(
      SwitchListTile(
        title: const Text('Read receipts'),
        subtitle: const Text('Let people see'),
        secondary: const SizedBox(key: Key('s'), width: 20, height: 20),
        value: value,
        onChanged: onChanged,
        enabled: enabled,
        controlAffinity: affinity,
        focusNode: focusNode,
      ),
    );

    testWidgets('a tap anywhere on the row toggles', (tester) async {
      final changes = <bool>[];
      await pumpFinesse(tester, tile(onChanged: changes.add));
      await tester.tap(find.text('Read receipts'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tapAt(
        tester.getRect(find.byType(ListTile)).centerLeft + const Offset(4, 0),
      );
      await tester.pumpAndSettle();
      expect(changes, [true, true, true]);
    });

    testWidgets('it is controlled: the switch shows the value it is given', (
      tester,
    ) async {
      await pumpFinesse(tester, tile(onChanged: (_) {}));
      await tester.tap(find.text('Read receipts'));
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await pumpFinesse(tester, tile(value: true, onChanged: (_) {}));
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    });

    testWidgets('the row is the only focus stop, and Space and Enter toggle', (
      tester,
    ) async {
      final changes = <bool>[];
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpFinesse(
        tester,
        tile(onChanged: changes.add, focusNode: node),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, [true, true]);
      // The next Tab leaves the row: the switch inside is not a stop.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<Switch>(),
        isNull,
      );
    });

    testWidgets('it is one semantic node: the title as label, the value as '
        'state', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile(value: true, onChanged: (_) {}));
      final data = dataOf(tester);
      expect(data.label, 'Read receipts\nLet people see');
      expect(data.flagsCollection.isToggled, ui.Tristate.isTrue);
      expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
      // Nothing under the row announces a second switch.
      var toggles = 0;
      void visit(SemanticsNode node) {
        if (node.getSemanticsData().flagsCollection.isToggled !=
            ui.Tristate.none) {
          toggles++;
        }
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      expect(toggles, 1);

      await pumpFinesse(tester, tile(onChanged: (_) {}));
      expect(dataOf(tester).flagsCollection.isToggled, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('disabled, or without onChanged, it does nothing', (
      tester,
    ) async {
      final changes = <bool>[];
      await pumpFinesse(tester, tile(enabled: false, onChanged: changes.add));
      await tester.tap(find.text('Read receipts'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(tester.widget<Switch>(find.byType(Switch)).enabled, isFalse);

      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, tile());
      await tester.tap(find.text('Read receipts'));
      await tester.pumpAndSettle();
      final data = dataOf(tester);
      expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('the control is at the end, or first with a leading '
        'affinity, in both directions', (tester) async {
      for (final direction in TextDirection.values) {
        for (final affinity in ControlAffinity.values) {
          await pumpFinesse(
            tester,
            tile(onChanged: (_) {}, affinity: affinity),
            textDirection: direction,
          );
          final control = tester.getCenter(find.byType(Switch)).dx;
          final other = tester.getCenter(find.byKey(const Key('s'))).dx;
          final title = tester.getCenter(find.text('Read receipts')).dx;
          final controlFirst =
              (affinity == ControlAffinity.leading) ==
              (direction == TextDirection.ltr);
          expect(
            control < title,
            controlFirst,
            reason: '${affinity.name} ${direction.name}',
          );
          expect(other < title, !controlFirst);
        }
      }
    });

    testWidgets('builds in every layout at twice the text size', (
      tester,
    ) async {
      await expectBuildsInEveryLayout(
        tester,
        (_) => MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: tile(onChanged: (_) {}),
        ),
      );
    });
  });

  group('CheckboxListTile', () {
    Widget tile({
      required bool? value,
      ValueChanged<bool?>? onChanged,
      bool tristate = false,
    }) => host(
      CheckboxListTile(
        title: const Text('Product updates'),
        value: value,
        tristate: tristate,
        onChanged: onChanged,
      ),
    );

    testWidgets('a tap toggles between checked and unchecked', (tester) async {
      final changes = <bool?>[];
      await pumpFinesse(tester, tile(value: false, onChanged: changes.add));
      await tester.tap(find.text('Product updates'));
      await pumpFinesse(tester, tile(value: true, onChanged: changes.add));
      await tester.tap(find.text('Product updates'));
      await tester.pumpAndSettle();
      expect(changes, [true, false]);
    });

    testWidgets('tristate goes unchecked, checked, mixed and round again', (
      tester,
    ) async {
      bool? value = false;
      final seen = <bool?>[];
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => tile(
            value: value,
            tristate: true,
            onChanged: (v) => setState(() {
              value = v;
              seen.add(v);
            }),
          ),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Product updates'));
        await tester.pumpAndSettle();
      }
      expect(seen, [true, null, false, true]);
    });

    testWidgets('the mixed state draws a dash and is announced as mixed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        tile(value: null, tristate: true, onChanged: (_) {}),
      );
      expect(find.byIcon(PhosphorIconsBold.minus), findsOneWidget);
      final data = dataOf(tester);
      expect(data.flagsCollection.isChecked, ui.CheckedState.mixed);
      expect(data.label, 'Product updates');

      await pumpFinesse(tester, tile(value: true, onChanged: (_) {}));
      expect(find.byIcon(PhosphorIconsBold.minus), findsNothing);
      expect(dataOf(tester).flagsCollection.isChecked, ui.CheckedState.isTrue);
      await pumpFinesse(tester, tile(value: false, onChanged: (_) {}));
      expect(
        dataOf(tester).flagsCollection.isChecked,
        ui.CheckedState.isFalse,
      );
      handle.dispose();
    });

    test('a null value needs tristate', () {
      expect(
        () => CheckboxListTile(
          title: const Text('x'),
          value: null,
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });

  group('RadioListTile', () {
    Widget group({
      required String? selected,
      ValueChanged<String?>? onChanged,
      bool toggleable = false,
    }) => Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 340,
        child: ListSection(
          children: [
            for (final option in ['Everyone', 'Connections', 'No one'])
              RadioListTile<String>(
                key: Key(option),
                title: Text(option),
                value: option,
                groupValue: selected,
                toggleable: toggleable,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );

    testWidgets('a tap selects the row, and the selected row shows its dot', (
      tester,
    ) async {
      String? selected = 'Everyone';
      final seen = <String?>[];
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => group(
            selected: selected,
            onChanged: (v) => setState(() {
              selected = v;
              seen.add(v);
            }),
          ),
        ),
      );
      PopIn dot(String option) => tester.widget<PopIn>(
        find.descendant(
          of: find.byKey(Key(option)),
          matching: find.byType(PopIn),
        ),
      );
      expect(dot('Everyone').visible, isTrue);
      expect(dot('No one').visible, isFalse);
      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, ['No one']);
      expect(dot('Everyone').visible, isFalse);
      expect(dot('No one').visible, isTrue);
      // The selected row is not reported again.
      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, ['No one']);
    });

    testWidgets('a toggleable selected row clears the choice', (tester) async {
      final seen = <String?>[];
      await pumpFinesse(
        tester,
        group(selected: 'Everyone', toggleable: true, onChanged: seen.add),
      );
      await tester.tap(find.text('Everyone'));
      await tester.pumpAndSettle();
      expect(seen, [null]);
    });

    testWidgets('each row is one node: a radio in an exclusive group', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        group(selected: 'Connections', onChanged: (_) {}),
      );
      SemanticsData data(String option) => tester
          .getSemantics(
            find.descendant(
              of: find.byKey(Key(option)),
              matching: find.byType(Pressable),
            ),
          )
          .getSemanticsData();
      expect(data('Connections').label, 'Connections');
      expect(
        data('Connections').flagsCollection.isChecked,
        ui.CheckedState.isTrue,
      );
      expect(
        data('Connections').flagsCollection.isInMutuallyExclusiveGroup,
        isTrue,
      );
      expect(
        data('Everyone').flagsCollection.isChecked,
        ui.CheckedState.isFalse,
      );
      handle.dispose();
    });

    testWidgets('rows of a section have hairlines between them and take '
        'arrow-free Tab order', (tester) async {
      useTraditionalHighlights();
      final seen = <String?>[];
      await pumpFinesse(
        tester,
        group(selected: 'Everyone', onChanged: seen.add),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(seen, ['Connections']);
    });

    testWidgets('the mark is the picture a Radio draws, in every style', (
      tester,
    ) async {
      for (final style in [
        StyleTokens.finesse,
        StyleTokens.nova,
        StyleTokens.maia,
        StyleTokens.lyra,
      ]) {
        await pumpFinesse(
          tester,
          Column(
            children: [
              group(selected: 'Everyone', onChanged: (_) {}),
              const FinesseRadioGroup<String>(
                initialValue: 'a',
                items: [Radio(key: Key('radio'), value: 'a')],
              ),
            ],
          ),
          theme: ThemeData(style: style),
        );
        expect(tester.takeException(), isNull);
        Finder markIn(Key key) => find
            .descendant(of: find.byKey(key), matching: find.byType(Decorator))
            .first;
        expect(
          tester.getSize(markIn(const Key('Everyone'))),
          tester.getSize(markIn(const Key('radio'))),
        );
        expect(
          tester.widget<Decorator>(markIn(const Key('Everyone'))).decoration,
          tester.widget<Decorator>(markIn(const Key('radio'))).decoration,
        );
      }
    });
  });
}
