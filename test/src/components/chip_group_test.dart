import 'package:finesse/finesse.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../finesse_harness.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.initial = const {},
    this.multiple = true,
    this.allowDeselection = true,
    this.wrap = true,
    this.count = 4,
    this.disabled = const {},
    this.width = 600,
    this.showCheckmark,
    this.leading,
    this.trailing,
  });

  final Set<int> initial;
  final bool multiple;
  final bool allowDeselection;
  final bool wrap;
  final int count;
  final Set<int> disabled;
  final double width;
  final bool? showCheckmark;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late Set<int> values = widget.initial;
  final changes = <Set<int>>[];

  void _changed(Set<int> v) {
    changes.add(v);
    setState(() => values = v);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (var i = 0; i < widget.count; i++)
        ChipGroupItem(
          value: i,
          label: Text('c$i'),
          enabled: !widget.disabled.contains(i),
        ),
    ];
    return Center(
      child: SizedBox(
        width: widget.width,
        child: widget.multiple
            ? ChipGroup<int>.multiple(
                semanticLabel: 'Filters',
                values: values,
                allowDeselection: widget.allowDeselection,
                wrap: widget.wrap,
                showCheckmark: widget.showCheckmark,
                leading: widget.leading,
                trailing: widget.trailing,
                onValuesChanged: _changed,
                items: items,
              )
            : ChipGroup<int>(
                semanticLabel: 'Filters',
                value: values.firstOrNull,
                allowDeselection: widget.allowDeselection,
                wrap: widget.wrap,
                showCheckmark: widget.showCheckmark,
                leading: widget.leading,
                trailing: widget.trailing,
                onChanged: (v) => _changed({?v}),
                items: items,
              ),
      ),
    );
  }
}

void main() {
  _HostState host(WidgetTester tester) => tester.state(find.byType(_Host));

  Chip chip(WidgetTester tester, int i) =>
      tester.widget(find.widgetWithText(Chip, 'c$i'));

  group('Chip delete', () {
    testWidgets('the cross is a target and a button of its own', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var pressed = 0;
      var deleted = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Remote'),
            onPressed: () => pressed++,
            onDeleted: () => deleted++,
          ),
        ),
      );
      final cross = find.byIcon(PhosphorIconsBold.x);
      expect(cross, findsOneWidget);
      await tester.tap(cross);
      await tester.pump();
      expect((pressed, deleted), (0, 1));
      await tester.tap(find.text('Remote'));
      await tester.pump();
      expect((pressed, deleted), (1, 1));
      // Assistive technology finds it by name and can press it.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Remove')),
        containsSemantics(isButton: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('deleteSemanticLabel names it', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('Remote'),
            onDeleted: () {},
            deleteSemanticLabel: 'Remove Remote',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Remove Remote'), findsOneWidget);
    });

    testWidgets('Backspace and Delete on the focused chip remove it', (
      tester,
    ) async {
      final node = FocusNode();
      final next = FocusNode();
      addTearDown(node.dispose);
      addTearDown(next.dispose);
      var deleted = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: const Text('Remote'),
                focusNode: node,
                onPressed: () {},
                onDeleted: () => deleted++,
              ),
              Button(
                focusNode: next,
                onPressed: () {},
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      expect(deleted, 2);
      // The chip is the one Tab stop: the cross is reached by those keys,
      // so Tab goes straight on to what follows.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(next.hasFocus, isTrue);
    });

    testWidgets('on a tag the cross is the Tab stop', (tester) async {
      useTraditionalHighlights();
      var deleted = 0;
      await pumpFinesse(
        tester,
        Center(
          child: Chip(label: const Text('Tag'), onDeleted: () => deleted++),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(deleted, 1);
    });

    testWidgets('a chip with a cross is wider by the cross, and no taller', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                key: const ValueKey('plain'),
                label: const Text('A'),
                onPressed: () {},
              ),
              Chip(
                key: const ValueKey('cross'),
                label: const Text('A'),
                onPressed: () {},
                onDeleted: () {},
              ),
            ],
          ),
        ),
      );
      final plain = tester.getSize(find.byKey(const ValueKey('plain')));
      final cross = tester.getSize(find.byKey(const ValueKey('cross')));
      expect(cross.height, plain.height);
      expect(cross.width, greaterThan(plain.width + 12));
      // The target is as tall as the chip's content.
      final target = tester.getSize(
        find
            .ancestor(
              of: find.byIcon(PhosphorIconsBold.x),
              matching: find.byType(Pressable),
            )
            .first,
      );
      expect(target.width, greaterThanOrEqualTo(24));
    });

    testWidgets('a disabled chip has no cross and is dimmed, at full size', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                key: const ValueKey('on'),
                label: const Text('A'),
                onPressed: () {},
              ),
              Chip(
                key: const ValueKey('off'),
                label: const Text('A'),
                enabled: false,
                onPressed: () {},
                onDeleted: () {},
              ),
            ],
          ),
        ),
        formFactor: FormFactor.mobile,
      );
      expect(find.byIcon(PhosphorIconsBold.x), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('off'))),
        tester.getSize(find.byKey(const ValueKey('on'))),
      );
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('off')),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('off')),
          matching: find.byType(Opacity),
        ),
        findsOneWidget,
      );
    });
  });

  group('Chip checkmark', () {
    testWidgets('a selected chip grows a check, smoothly', (tester) async {
      var selected = false;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Chip(
              label: const Text('Remote'),
              showCheckmark: true,
              selected: selected,
              onSelected: (v) => setState(() => selected = v),
            ),
          ),
        ),
      );
      final before = tester.getSize(find.byType(Chip)).width;
      await tester.tap(find.byType(Chip));
      await tester.pump();
      // Width grows monotonically to its new size, and stays there.
      var last = before;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final width = tester.getSize(find.byType(Chip)).width;
        expect(width, greaterThanOrEqualTo(last - .01));
        last = width;
      }
      expect(last, greaterThan(before + 12));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Chip)).width, closeTo(last, .5));
      expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);
    });

    testWidgets('the theme turns it on for every chip', (tester) async {
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            label: const Text('A'),
            selected: true,
            onSelected: (_) {},
          ),
        ),
        theme: ThemeData(chipTheme: const ChipTheme(showCheckmark: true)),
      );
      expect(find.byIcon(PhosphorIconsBold.check), findsOneWidget);
      await pumpFinesse(
        tester,
        Center(
          child: Chip(
            key: const ValueKey(2),
            label: const Text('A'),
            selected: true,
            onSelected: (_) {},
          ),
        ),
      );
      expect(find.byIcon(PhosphorIconsBold.check), findsNothing);
    });

    testWidgets('with motion off the check is there at once', (tester) async {
      var selected = false;
      await pumpFinesse(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Center(
            child: Chip(
              label: const Text('Remote'),
              showCheckmark: true,
              selected: selected,
              onSelected: (v) => setState(() => selected = v),
            ),
          ),
        ),
        theme: ThemeData(motion: Motion.none),
      );
      final before = tester.getSize(find.byType(Chip)).width;
      await tester.tap(find.byType(Chip));
      await tester.pump();
      await tester.pump();
      expect(tester.getSize(find.byType(Chip)).width, greaterThan(before + 12));
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group('ChipGroup', () {
    testWidgets('multiple: taps add to and take from the set', (tester) async {
      await pumpFinesse(tester, const _Host(initial: {1}));
      expect(chip(tester, 1).selected, isTrue);
      await tester.tap(find.text('c2'));
      await settle(tester);
      await tester.tap(find.text('c1'));
      await settle(tester);
      expect(host(tester).changes, [
        {1, 2},
        {2},
      ]);
      await tester.tap(find.text('c2'));
      await settle(tester);
      expect(host(tester).values, isEmpty);
    });

    testWidgets('single: a tap replaces the choice', (tester) async {
      await pumpFinesse(tester, const _Host(initial: {1}, multiple: false));
      await tester.tap(find.text('c3'));
      await settle(tester);
      expect(host(tester).values, {3});
      expect(chip(tester, 1).selected, isFalse);
    });

    testWidgets('allowDeselection false keeps the last one chosen', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(initial: {1}, multiple: false, allowDeselection: false),
      );
      await tester.tap(find.text('c1'));
      await settle(tester);
      expect(host(tester).changes, isEmpty);
      expect(chip(tester, 1).selected, isTrue);
    });

    testWidgets('a disabled chip is not chosen, and a null onChanged '
        'disables them all', (tester) async {
      await pumpFinesse(tester, const _Host(disabled: {2}));
      await tester.tap(find.text('c2'), warnIfMissed: false);
      await settle(tester);
      expect(host(tester).changes, isEmpty);
      expect(chip(tester, 2).enabled, isFalse);
      // It keeps the size of its neighbours.
      expect(
        tester.getSize(find.widgetWithText(Chip, 'c2')).height,
        tester.getSize(find.widgetWithText(Chip, 'c1')).height,
      );

      await pumpFinesse(
        tester,
        const Center(
          child: ChipGroup<int>(
            onChanged: null,
            items: [ChipGroupItem(value: 0, label: Text('only'))],
          ),
        ),
      );
      expect(
        tester.widget<Chip>(find.widgetWithText(Chip, 'only')).enabled,
        isFalse,
      );
    });

    testWidgets('wraps onto further rows by default', (tester) async {
      await pumpFinesse(tester, const _Host(count: 12, width: 200));
      final first = tester.getRect(find.widgetWithText(Chip, 'c0'));
      final last = tester.getRect(find.widgetWithText(Chip, 'c11'));
      expect(last.top, greaterThan(first.bottom));
      expect(find.byType(Scrollable), findsNothing);
      final theme = themeOf(tester, find.byType(ChipGroup<int>));
      final second = tester.getRect(find.widgetWithText(Chip, 'c1'));
      expect(second.left - first.right, theme.chipTheme.groupSpacing);
    });

    testWidgets('wrap false: one row that scrolls', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(count: 12, width: 200, wrap: false),
      );
      final first = tester.getRect(find.widgetWithText(Chip, 'c0'));
      final last = tester.getRect(
        find.widgetWithText(Chip, 'c11', skipOffstage: false),
      );
      expect(last.top, first.top);
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.maxScrollExtent, greaterThan(100));
      await tester.drag(find.text('c1'), const Offset(-150, 0));
      await tester.pumpAndSettle();
      expect(position.pixels, greaterThan(100));
      expect(tester.takeException(), isNull);
    });

    group('an action beside the chips', () {
      var pressed = 0;
      Widget action(String label) => Chip(
        key: ValueKey(label),
        label: Text(label),
        onPressed: () => pressed++,
      );

      for (final wrap in [true, false]) {
        testWidgets('${wrap ? 'wrapping' : 'scrolling'}: leading and '
            'trailing stand at the ends of the first row, are pressed and '
            'not chosen', (tester) async {
          pressed = 0;
          await pumpFinesse(
            tester,
            _Host(
              count: 12,
              width: 360,
              wrap: wrap,
              leading: action('Sort'),
              trailing: action('All filters'),
            ),
          );
          final group = tester.getRect(find.byType(ChipGroup<int>));
          final sort = tester.getRect(find.byKey(const ValueKey('Sort')));
          final all = tester.getRect(
            find.byKey(const ValueKey('All filters')),
          );
          final first = tester.getRect(find.widgetWithText(Chip, 'c0'));
          expect(sort.left, group.left);
          expect(all.right, group.right);
          expect(sort.top, first.top);
          expect(all.top, first.top);
          expect(first.left, greaterThan(sort.right));
          await tester.tap(find.byKey(const ValueKey('All filters')));
          await settle(tester);
          expect(pressed, 1);
          expect(host(tester).changes, isEmpty);

          if (wrap) {
            // The chips wrap between the two.
            final last = tester.getRect(find.widgetWithText(Chip, 'c11'));
            expect(last.top, greaterThan(first.bottom));
            expect(last.right, lessThan(all.left));
          } else {
            // The chips scroll under the fade; the actions stay put.
            await tester.drag(find.text('c0'), const Offset(-150, 0));
            await tester.pumpAndSettle();
            expect(
              tester.getRect(find.byKey(const ValueKey('Sort'))),
              sort,
            );
            expect(
              tester.getRect(find.byKey(const ValueKey('All filters'))),
              all,
            );
            expect(
              tester.getRect(find.widgetWithText(Chip, 'c0')).left,
              lessThan(first.left),
            );
          }
          expect(tester.takeException(), isNull);
        });
      }

      testWidgets('the actions are Tab stops of their own; the arrows stay '
          'among the chips', (tester) async {
        await pumpFinesse(
          tester,
          _Host(leading: action('Sort'), trailing: action('All filters')),
        );
        Chip focused() => FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<Chip>()!;
        String label(Chip chip) => (chip.label as Text).data!;

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(label(focused()), 'Sort');
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(label(focused()), 'c0');
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(label(focused()), 'c3');
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(label(focused()), 'All filters');
      });
    });

    testWidgets('a scrolling row fades only at an edge it goes on beyond', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(count: 12, width: 200, wrap: false),
      );
      final fade = tester.renderObject(
        find.byWidgetPredicate((w) => '${w.runtimeType}' == '_EdgeFade'),
      );
      ShaderMaskLayer? mask() => fade.debugLayer as ShaderMaskLayer?;
      // At the start there is more at the end: a mask.
      expect(mask(), isNotNull);
      // A row that fits has nothing to fade and no layer at all.
      await pumpFinesse(
        tester,
        const _Host(count: 2, width: 600, wrap: false),
      );
      final still = tester.renderObject(
        find.byWidgetPredicate((w) => '${w.runtimeType}' == '_EdgeFade'),
      );
      expect(still.debugLayer, isNull);
    });

    testWidgets('a row that stops fitting by a layout alone fades', (
      tester,
    ) async {
      await pumpFinesse(
        tester,
        const _Host(width: 600, wrap: false),
      );
      final fade = tester.renderObject(
        find.byWidgetPredicate((w) => '${w.runtimeType}' == '_EdgeFade'),
      );
      expect(fade.debugLayer, isNull);
      // A layout that starts the fade does not update its compositing bit,
      // and need not: the scroll view below is a repaint boundary.
      expect(fade.needsCompositing, isTrue);
      // Narrower, with no scroll: only the layout finds the row overflows.
      await pumpFinesse(
        tester,
        const _Host(width: 120, wrap: false),
      );
      expect(
        tester.renderObject(
          find.byWidgetPredicate((w) => '${w.runtimeType}' == '_EdgeFade'),
        ),
        same(fade),
      );
      expect(fade.debugLayer, isA<ShaderMaskLayer>());
      expect(fade.needsCompositing, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is one Tab stop; arrows, Home and End move inside it', (
      tester,
    ) async {
      final before = FocusNode(debugLabel: 'before');
      final after = FocusNode(debugLabel: 'after');
      addTearDown(before.dispose);
      addTearDown(after.dispose);
      await pumpFinesse(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Button(
                focusNode: before,
                onPressed: () {},
                child: const Text('Before'),
              ),
              const _Host(initial: {1}, disabled: {2}),
              Button(
                focusNode: after,
                onPressed: () {},
                child: const Text('After'),
              ),
            ],
          ),
        ),
      );
      int? focused() {
        final context = FocusManager.instance.primaryFocus?.context;
        final found = context?.findAncestorWidgetOfExactType<Chip>();
        if (found == null) return null;
        return int.parse(((found.label as Text).data!).substring(1));
      }

      before.requestFocus();
      await tester.pump();
      // Tab lands on the chosen chip, not on the first.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(), 1);
      // Right skips the disabled chip.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused(), 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focused(), 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(focused(), 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focused(), 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focused(), 1);
      // Space chooses.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await settle(tester);
      expect(host(tester).values, isEmpty);
      // Tab leaves the group in one step, and Shift+Tab comes back to
      // where it was.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(after.hasFocus, isTrue);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(focused(), 1);
    });

    testWidgets('the arrows follow the reading direction', (tester) async {
      await pumpFinesse(
        tester,
        const _Host(initial: {1}),
        textDirection: TextDirection.rtl,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      final context = FocusManager.instance.primaryFocus!.context!;
      final chip = context.findAncestorWidgetOfExactType<Chip>()!;
      expect((chip.label as Text).data, 'c2');
    });

    testWidgets('an action beside a scrolling row is a named button of its '
        "own, not part of the group's name", (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(
        tester,
        _Host(
          count: 12,
          width: 300,
          wrap: false,
          leading: Chip(
            label: const Text('Sort'),
            semanticLabel: 'Sort by date',
            onPressed: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Filters'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Sort by date')),
        containsSemantics(isButton: true, hasTapAction: true),
      );
      handle.dispose();
    });

    testWidgets('chosen chips say so to assistive technology', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpFinesse(tester, const _Host(initial: {1}));
      expect(find.bySemanticsLabel('Filters'), findsOneWidget);
      expect(
        tester.getSemantics(find.widgetWithText(Pressable, 'c1')),
        containsSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.widgetWithText(Pressable, 'c0')),
        containsSemantics(isButton: true, isSelected: false),
      );
      handle.dispose();
    });

    testWidgets('builds in every layout, wrapped and scrolling, with checks', (
      tester,
    ) async {
      for (final wrap in [true, false]) {
        await expectBuildsInEveryLayout(
          tester,
          (_) => _Host(
            initial: const {1, 3},
            count: 14,
            width: 300,
            wrap: wrap,
            showCheckmark: true,
          ),
        );
      }
    });
  });
}
