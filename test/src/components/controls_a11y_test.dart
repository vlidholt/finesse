import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// The semantics node that holds [text], merged as assistive technology
/// meets it.
SemanticsData _nodeOf(WidgetTester tester, String text) =>
    tester.getSemantics(find.text(text)).getSemanticsData();

void main() {
  group('Switch, Checkbox and Radio', () {
    testWidgets('a switch with no onChanged is disabled, and Space does '
        'nothing', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(child: Switch(value: false, label: Text('Wi-Fi'))),
      );
      // Not a Tab stop: Tab finds nothing to focus.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tester.takeException(), isNull);
      final data = _nodeOf(tester, 'Wi-Fi');
      expect(data.label, 'Wi-Fi');
      expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(data.flagsCollection.isToggled, ui.Tristate.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      handle.dispose();
    });

    testWidgets('a switch with onChanged is one named, enabled node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final seen = <bool>[];
      await pumpUna(
        tester,
        Center(
          child: Switch(
            value: true,
            onChanged: seen.add,
            label: const Text('Wi-Fi'),
          ),
        ),
      );
      final data = _nodeOf(tester, 'Wi-Fi');
      expect(data.label, 'Wi-Fi');
      expect(data.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expect(data.flagsCollection.isToggled, ui.Tristate.isTrue);
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(seen, [false]);
      handle.dispose();
    });

    testWidgets('a checkbox with no onChanged is disabled and named', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(child: Checkbox(value: true, label: Text('Terms'))),
      );
      final data = _nodeOf(tester, 'Terms');
      expect(data.label, 'Terms');
      expect(data.flagsCollection.isEnabled, ui.Tristate.isFalse);
      expect(data.flagsCollection.isChecked, ui.CheckedState.isTrue);
      final opacities = tester.widgetList<Opacity>(
        find.descendant(
          of: find.byType(Checkbox),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacities.any((o) => o.opacity < 1), isTrue);
      handle.dispose();
    });

    testWidgets('a radio is a radio, named by its label', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        UnaRadioGroup<String>(
          value: 'a',
          onChanged: (_) {},
          items: const [
            Radio(value: 'a', label: Text('Alpha')),
            Radio(value: 'b', label: Text('Beta'), enabled: false),
          ],
        ),
      );
      final alpha = _nodeOf(tester, 'Alpha');
      expect(alpha.label, 'Alpha');
      expect(alpha.flagsCollection.isChecked, ui.CheckedState.isTrue);
      expect(alpha.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(alpha.flagsCollection.isEnabled, ui.Tristate.isTrue);
      final beta = _nodeOf(tester, 'Beta');
      expect(beta.label, 'Beta');
      expect(beta.flagsCollection.isChecked, ui.CheckedState.isFalse);
      expect(beta.flagsCollection.isEnabled, ui.Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('a radio group is one Tab stop, and the arrows move and '
        'select, past disabled radios', (tester) async {
      final nodes = [for (var i = 0; i < 4; i++) FocusNode()];
      addTearDown(() {
        for (final node in nodes) {
          node.dispose();
        }
      });
      final seen = <String>[];
      var selected = 'b';
      await pumpUna(
        tester,
        Column(
          children: [
            StatefulBuilder(
              builder: (context, setState) => UnaRadioGroup<String>(
                value: selected,
                onChanged: (value) => setState(() {
                  selected = value;
                  seen.add(value);
                }),
                items: [
                  Radio(value: 'a', focusNode: nodes[0]),
                  Radio(value: 'b', focusNode: nodes[1]),
                  Radio(value: 'c', focusNode: nodes[2], enabled: false),
                  Radio(value: 'd', focusNode: nodes[3]),
                ],
              ),
            ),
            const Button(onPressed: _noop, child: Text('After')),
          ],
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(nodes[1].hasPrimaryFocus, isTrue);
      // Down skips the disabled radio.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(nodes[3].hasPrimaryFocus, isTrue);
      expect(seen, ['d']);
      // Round the end to the start.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(nodes[0].hasPrimaryFocus, isTrue);
      expect(seen, ['d', 'a']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(seen, ['d', 'a', 'd']);
      // The next Tab leaves the group.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus,
        isNot(anyOf(nodes.map(equals).toList())),
      );
      // And Shift+Tab comes back to the selected radio.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
      await tester.pump();
      expect(nodes[3].hasPrimaryFocus, isTrue);
    });

    testWidgets('with nothing selected the first enabled radio is the stop, '
        'and Left goes forward in RTL', (tester) async {
      final nodes = [for (var i = 0; i < 3; i++) FocusNode()];
      addTearDown(() {
        for (final node in nodes) {
          node.dispose();
        }
      });
      final seen = <String>[];
      await pumpUna(
        tester,
        textDirection: TextDirection.rtl,
        UnaRadioGroup<String>(
          onChanged: seen.add,
          items: [
            Radio(value: 'a', focusNode: nodes[0], enabled: false),
            Radio(value: 'b', focusNode: nodes[1]),
            Radio(value: 'c', focusNode: nodes[2]),
          ],
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(nodes[1].hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(nodes[2].hasPrimaryFocus, isTrue);
      expect(seen, ['c']);
    });
  });

  group('Pagination', () {
    testWidgets('a page number is a button named for its page, the current '
        'one selected', (tester) async {
      final handle = tester.ensureSemantics();
      final seen = <int>[];
      await pumpUna(
        tester,
        Center(
          child: Pagination(page: 2, pageCount: 5, onPageChanged: seen.add),
        ),
      );
      final current = _nodeOf(tester, '2');
      expect(current.label, 'Page 2');
      expect(current.flagsCollection.isButton, isTrue);
      expect(current.flagsCollection.isSelected, ui.Tristate.isTrue);
      expect(current.flagsCollection.isFocused, isNot(ui.Tristate.none));
      final other = _nodeOf(tester, '3');
      expect(other.label, 'Page 3');
      expect(other.flagsCollection.isButton, isTrue);
      expect(other.flagsCollection.isSelected, ui.Tristate.isFalse);
      expect(other.hasAction(SemanticsAction.tap), isTrue);
      tester.semantics.tap(find.semantics.byLabel('Page 3'));
      await tester.pump();
      expect(seen, [3]);
      handle.dispose();
    });
  });

  group('Accordion and Collapsible', () {
    testWidgets('an accordion trigger shows its focus ring after a key, '
        'not after a click', (tester) async {
      await pumpUna(
        tester,
        Accordion<String>(
          children: const [
            AccordionItem(
              value: 'a',
              title: Text('Shipping'),
              child: Text('Two days'),
            ),
          ],
        ),
      );
      bool ring() => tester
          .widget<FocusRing>(
            find.ancestor(
              of: find.text('Shipping'),
              matching: find.byType(FocusRing),
            ),
          )
          .visible;
      expect(ring(), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(ring(), isTrue);
      await tester.tap(
        find.text('Shipping'),
        kind: ui.PointerDeviceKind.mouse,
      );
      await tester.pump();
      expect(ring(), isFalse);
    });

    testWidgets('closed content is no Tab stop, and the trigger says whether '
        'it is open', (tester) async {
      final handle = tester.ensureSemantics();
      final controller = CollapsibleController();
      addTearDown(controller.dispose);
      final inner = FocusNode();
      addTearDown(inner.dispose);
      await pumpUna(
        tester,
        Column(
          children: [
            Collapsible(
              controller: controller,
              maintainState: true,
              trigger: (context, open, toggle) =>
                  Button(onPressed: toggle, child: const Text('More')),
              child: Button(
                focusNode: inner,
                onPressed: _noop,
                child: const Text('Hidden action'),
              ),
            ),
          ],
        ),
      );
      final trigger = _nodeOf(tester, 'More');
      expect(trigger.flagsCollection.isExpanded, ui.Tristate.isFalse);
      expect(trigger.flagsCollection.isButton, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      expect(inner.hasFocus, isFalse);

      controller.open();
      await settle(tester);
      expect(
        _nodeOf(tester, 'More').flagsCollection.isExpanded,
        ui.Tristate.isTrue,
      );
      inner.requestFocus();
      await tester.pump();
      expect(inner.hasFocus, isTrue);
      handle.dispose();
    });
  });

  group('Slider', () {
    List<SemanticsData> sliders(WidgetTester tester) {
      final found = <SemanticsData>[];
      void visit(SemanticsNode node) {
        final data = node.getSemanticsData();
        if (data.flagsCollection.isSlider) found.add(data);
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      return found;
    }

    testWidgets('the label is on the slider node, with a percentage', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Slider(
              initialValue: .3,
              semanticLabel: 'Volume',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final [slider] = sliders(tester);
      expect(slider.label, 'Volume');
      expect(slider.value, '30%');
      expect(slider.increasedValue, '31%');
      expect(slider.flagsCollection.isEnabled, ui.Tristate.isTrue);
      expect(slider.hasAction(SemanticsAction.increase), isTrue);
      // No other node carries the name or an action of the slider's.
      var named = 0;
      void visit(SemanticsNode node) {
        if (node.getSemanticsData().label.contains('Volume')) named++;
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      expect(named, 1);
      handle.dispose();
    });

    testWidgets("a range slider's thumbs say which they are", (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: RangeSlider(
              initialValues: const [20, 80],
              max: 100,
              semanticLabel: 'Price',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final labels = sliders(tester).map((data) => data.label).toSet();
      expect(labels, {'Price, Minimum', 'Price, Maximum'});
      handle.dispose();
    });

    testWidgets('Home, End, Page Up and Page Down', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final seen = <double>[];
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 300,
            child: Slider(
              initialValue: 50,
              max: 100,
              divisions: 100,
              focusNode: node,
              onChanged: seen.add,
            ),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(seen, [60, 50, 100, 0]);
    });

    testWidgets('on Liquid Glass the label is on the slider node', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await pumpUna(
          tester,
          Center(
            child: SizedBox(
              width: 300,
              child: Slider(
                initialValue: .5,
                semanticLabel: 'Volume',
                onChanged: (_) {},
              ),
            ),
          ),
        );
        expect(
          find.byWidgetPredicate((w) => '${w.runtimeType}' == 'GlassSlider'),
          findsOneWidget,
        );
        final [slider] = sliders(tester);
        expect(slider.label, 'Volume');
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
      handle.dispose();
    });

    testWidgets('on Liquid Glass a switch is named by its label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await pumpUna(
          tester,
          Center(
            child: Switch(
              value: true,
              onChanged: (_) {},
              label: const Text('Wi-Fi'),
            ),
          ),
        );
        expect(
          find.byWidgetPredicate((w) => '${w.runtimeType}' == 'GlassSwitch'),
          findsOneWidget,
        );
        final data = _nodeOf(tester, 'Wi-Fi');
        expect(data.label, 'Wi-Fi');
        expect(data.flagsCollection.isToggled, ui.Tristate.isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
      handle.dispose();
    });
  });

  group('Chips and toggle groups', () {
    testWidgets('a chip group whose chosen chip is disabled is still '
        'reached by Tab', (tester) async {
      await pumpUna(
        tester,
        Center(
          child: ChipGroup<int>(
            value: 0,
            onChanged: (_) {},
            items: const [
              ChipGroupItem(value: 0, label: Text('zero'), enabled: false),
              ChipGroupItem(value: 1, label: Text('one')),
              ChipGroupItem(value: 2, label: Text('two')),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.descendant(
          of: find.byWidget(focused.widget),
          matching: find.text('one'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a toggle group is one named Tab stop, and the arrows, Home '
        'and End move in it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ToggleGroup<String>(
                semanticLabel: 'Alignment',
                initialValue: 'center',
                onChanged: (_) {},
                items: const [
                  ToggleGroupItem(value: 'left', child: Text('L')),
                  ToggleGroupItem(value: 'center', child: Text('C')),
                  ToggleGroupItem(
                    value: 'justify',
                    child: Text('J'),
                    enabled: false,
                  ),
                  ToggleGroupItem(value: 'right', child: Text('R')),
                ],
              ),
              const Button(onPressed: _noop, child: Text('After')),
            ],
          ),
        ),
      );
      String focused() {
        final context = FocusManager.instance.primaryFocus!.context!;
        for (final label in ['L', 'C', 'J', 'R', 'After']) {
          if (find
              .descendant(
                of: find.byWidget(context.widget),
                matching: find.text(label),
              )
              .evaluate()
              .isNotEmpty) {
            return label;
          }
        }
        return '?';
      }

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // The selected item is the stop.
      expect(focused(), 'C');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // Past the disabled one.
      expect(focused(), 'R');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(focused(), 'L');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(focused(), 'R');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(focused(), 'After');

      var named = false;
      void visit(SemanticsNode node) {
        if (node.getSemanticsData().label == 'Alignment') named = true;
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
      expect(named, isTrue);
      handle.dispose();
    });

    testWidgets("a chip's remove button names the chip and is as tall as "
        'it', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUna(
        tester,
        const Center(
          child: Chip(
            label: Text('Design'),
            semanticLabel: 'Design',
            onDeleted: _noop,
          ),
        ),
      );
      final remove = find.bySemanticsLabel('Remove Design');
      expect(remove, findsOneWidget);
      final chipHeight = tester.getSize(find.byType(Chip)).height;
      final target = tester.getSize(
        find
            .ancestor(
              of: find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.label == 'Remove Design',
              ),
              matching: find.byType(Pressable),
            )
            .first,
      );
      // All of it inside the chip's outline.
      expect(target.height, greaterThanOrEqualTo(chipHeight - 2));
      expect(target.width, greaterThanOrEqualTo(28));
      handle.dispose();
    });
  });

  group('ColorPicker', () {
    Future<List<Color>> pump(
      WidgetTester tester,
      ColorPickerMode mode,
      Color initial,
    ) async {
      final seen = <Color>[];
      await pumpUna(
        tester,
        Center(
          child: SizedBox(
            width: 260,
            child: StatefulBuilder(
              builder: (context, setState) => ColorPicker(
                value: seen.lastOrNull ?? initial,
                initialMode: mode,
                showAlpha: true,
                onChanged: (color) => setState(() => seen.add(color)),
              ),
            ),
          ),
        ),
      );
      return seen;
    }

    SemanticsData named(WidgetTester tester, String label) =>
        tester.getSemantics(find.bySemanticsLabel(label)).getSemanticsData();

    testWidgets('the spectrum is a slider per axis, and the tracks say what '
        'a step makes of them', (tester) async {
      final handle = tester.ensureSemantics();
      final seen = await pump(
        tester,
        ColorPickerMode.spectrum,
        const HSVColor.fromAHSV(1, 120, .5, .5).toColor(),
      );
      final saturation = named(tester, 'Saturation');
      expect(saturation.flagsCollection.isSlider, isTrue);
      expect(saturation.value, '50%');
      expect(saturation.increasedValue, '55%');
      expect(saturation.hasAction(SemanticsAction.increase), isTrue);
      final brightness = named(tester, 'Brightness');
      expect(brightness.flagsCollection.isSlider, isTrue);
      expect(brightness.decreasedValue, '45%');
      tester.semantics.performAction(
        find.semantics.byLabel('Brightness'),
        SemanticsAction.decrease,
      );
      await tester.pump();
      expect(HSVColor.fromColor(seen.last).value, closeTo(.45, .01));

      final hue = named(tester, 'Hue');
      expect(hue.value, '120°');
      expect(hue.increasedValue, '138°');
      expect(hue.decreasedValue, '102°');
      // Fully opaque: no further to go up.
      final opacity = named(tester, 'Opacity');
      expect(opacity.value, '100%');
      expect(opacity.hasAction(SemanticsAction.increase), isFalse);
      expect(opacity.increasedValue, isEmpty);
      expect(opacity.decreasedValue, '95%');
      handle.dispose();
    });

    testWidgets('the grid steps through its cells, with no action past an '
        'end', (tester) async {
      final handle = tester.ensureSemantics();
      final seen = await pump(
        tester,
        ColorPickerMode.grid,
        const Color(0xFFFFFFFF),
      );
      // The grid itself, not the segment that shows it.
      final gridFinder = find.semantics.byPredicate(
        (node) => node.label == 'Grid' && node.value.isNotEmpty,
      );
      final grid = gridFinder.evaluate().single.getSemanticsData();
      expect(grid.value, '#FFFFFF');
      expect(grid.hasAction(SemanticsAction.decrease), isFalse);
      expect(grid.hasAction(SemanticsAction.increase), isTrue);
      expect(grid.increasedValue, isNot('#FFFFFF'));
      tester.semantics.performAction(gridFinder, SemanticsAction.increase);
      await tester.pump();
      expect(colorToHex(seen.single), grid.increasedValue);
      handle.dispose();
    });
  });
}

void _noop() {}
