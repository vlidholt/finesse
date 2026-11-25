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

  group('RadioListTile under a FinesseRadioGroup', () {
    const options = ['Everyone', 'Connections', 'No one'];

    Widget rows({bool sectionEnabled = true}) => ListSection(
      children: [
        for (final option in options)
          RadioListTile<String>(
            key: Key(option),
            title: Text(option),
            value: option,
            enabled: sectionEnabled,
          ),
      ],
    );

    PopIn dot(WidgetTester tester, String option) => tester.widget<PopIn>(
      find.descendant(
        of: find.byKey(Key(option)),
        matching: find.byType(PopIn),
      ),
    );

    testWidgets('a row given neither groupValue nor onChanged shows the '
        "group's selection and selects through it", (tester) async {
      var selected = 'Everyone';
      final seen = <String>[];
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 340,
            child: StatefulBuilder(
              builder: (context, setState) => FinesseRadioGroup<String>(
                // A section takes the width it is given, and a
                // horizontal wrap is the one that gives it one.
                axis: Axis.horizontal,
                value: selected,
                onChanged: (value) => setState(() {
                  selected = value;
                  seen.add(value);
                }),
                items: [rows()],
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      // The section is as wide as the group lets it be.
      expect(tester.getSize(find.byType(ListSection)).width, 340);
      expect(dot(tester, 'Everyone').visible, isTrue);
      expect(dot(tester, 'No one').visible, isFalse);

      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, ['No one']);
      expect(dot(tester, 'Everyone').visible, isFalse);
      expect(dot(tester, 'No one').visible, isTrue);
      // The selected row is not reported again.
      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, ['No one']);
    });

    testWidgets('a group that keeps its own state, and the keyboard', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 340,
            child: FinesseRadioGroup<String>(
              axis: Axis.horizontal,
              initialValue: 'Connections',
              items: [rows()],
            ),
          ),
        ),
      );
      expect(dot(tester, 'Connections').visible, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(dot(tester, 'Everyone').visible, isTrue);
      expect(dot(tester, 'Connections').visible, isFalse);
      final node = tester.getSemantics(find.byKey(const Key('Everyone')));
      expect(node.flagsCollection.isChecked, ui.CheckedState.isTrue);
      expect(node.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      handle.dispose();
    });

    testWidgets('a disabled group, or a disabled row, takes no tap', (
      tester,
    ) async {
      final seen = <String>[];
      Widget build({required bool group, required bool row}) => Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 340,
          child: FinesseRadioGroup<String>(
            axis: Axis.horizontal,
            value: 'Everyone',
            enabled: group,
            onChanged: seen.add,
            items: [rows(sectionEnabled: row)],
          ),
        ),
      );
      await pumpFinesse(tester, build(group: false, row: true));
      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, isEmpty);
      await pumpFinesse(tester, build(group: true, row: false));
      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, isEmpty);
      await pumpFinesse(tester, build(group: true, row: true));
      await tester.tap(find.text('No one'));
      await tester.pumpAndSettle();
      expect(seen, ['No one']);
    });

    testWidgets("a row that is told its groupValue is its caller's, "
        'whatever group is around it', (tester) async {
      final seen = <int?>[];
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 340,
            // A group of another type, for something else on the page.
            child: FinesseRadioGroup<String>(
              axis: Axis.horizontal,
              initialValue: 'x',
              items: [
                ListSection(
                  children: [
                    for (final n in [1, 2])
                      RadioListTile<int>(
                        key: Key('$n'),
                        title: Text('Option $n'),
                        value: n,
                        groupValue: 1,
                        onChanged: seen.add,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(dot(tester, '1').visible, isTrue);
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(seen, [2]);
    });

    testWidgets('with no group and no onChanged the row is switched off', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: 340, child: rows()),
        ),
      );
      expect(tester.takeException(), isNull);
      final node = tester.getSemantics(find.byKey(const Key('Everyone')));
      expect(node.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });
  });
}
