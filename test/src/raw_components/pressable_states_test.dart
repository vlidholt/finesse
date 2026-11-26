import 'dart:ui' show Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// What `Pressable` took on to carry the buttons: an `enabled` of its own,
/// a states controller, hover and focus callbacks, the toggled state and a
/// semantics node of its own.
void main() {
  setUp(useTraditionalHighlights);

  Widget region({
    required List<Set<WidgetState>> log,
    VoidCallback? onPressed,
    VoidCallback? onLongPress,
    bool? enabled,
    bool? toggled,
    bool? selected,
    FocusNode? focusNode,
    WidgetStatesController? statesController,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    bool semanticContainer = false,
    String? semanticLabel,
  }) {
    return Center(
      child: Pressable(
        onPressed: onPressed,
        onLongPress: onLongPress,
        enabled: enabled,
        toggled: toggled,
        selected: selected,
        focusNode: focusNode,
        statesController: statesController,
        onHover: onHover,
        onFocusChange: onFocusChange,
        semanticContainer: semanticContainer,
        semanticLabel: semanticLabel,
        builder: (context, states) {
          log.add({...states});
          return const SizedBox(width: 120, height: 40, child: Text('Go'));
        },
      ),
    );
  }

  group('Pressable.enabled', () {
    testWidgets('false disables a region that has callbacks', (tester) async {
      final log = <Set<WidgetState>>[];
      var presses = 0;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpUna(
        tester,
        region(
          log: log,
          enabled: false,
          focusNode: focusNode,
          onPressed: () => presses++,
          onLongPress: () => presses++,
        ),
      );
      expect(log.last, {WidgetState.disabled});

      await tester.tap(find.byType(Pressable));
      await tester.longPress(find.byType(Pressable));
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(presses, 0);
      expect(focusNode.hasFocus, isFalse);

      await hoverAt(tester, tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      expect(log.last, {WidgetState.disabled});
    });

    testWidgets('true with nothing to do stays in the focus order and '
        'hovered, does not give under a press, and is not offered to '
        'assistive technology as something to press', (tester) async {
      final handle = tester.ensureSemantics();
      final log = <Set<WidgetState>>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpUna(
        tester,
        region(
          log: log,
          enabled: true,
          focusNode: focusNode,
          semanticLabel: 'Saving',
        ),
      );
      expect(log.last, isEmpty);

      focusNode.requestFocus();
      // The focus moves after the frame; the next one builds it.
      await tester.pump();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      expect(log.last, {WidgetState.focused});

      final mouse = await hoverAt(
        tester,
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      expect(log.last, {WidgetState.focused, WidgetState.hovered});

      // The state follows the press, for the caller's look …
      await mouse.down(tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      expect(log.last, contains(WidgetState.pressed));
      // … but the region itself does not shrink.
      await tester.pump(const Duration(milliseconds: 120));
      final scale = tester.widget<PressScale>(
        find.descendant(
          of: find.byType(Pressable),
          matching: find.byType(PressScale),
        ),
      );
      expect(scale.pressed, isFalse);
      await mouse.up();
      await tester.pump();

      final data = tester
          .getSemantics(find.bySemanticsLabel('Saving'))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      handle.dispose();
    });
  });

  group('Pressable.statesController', () {
    testWidgets('follows hover, press, focus, selected and disabled', (
      tester,
    ) async {
      final controller = WidgetStatesController();
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      var enabled = true;
      var selected = false;
      late StateSetter setOuter;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return region(
              log: [],
              statesController: controller,
              focusNode: focusNode,
              selected: selected,
              onPressed: enabled ? () {} : null,
            );
          },
        ),
      );
      expect(controller.value, isEmpty);

      final mouse = await hoverAt(
        tester,
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      expect(controller.value, {WidgetState.hovered});
      await mouse.down(tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      expect(controller.value, {WidgetState.hovered, WidgetState.pressed});
      await mouse.up();
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(controller.value, isEmpty);

      focusNode.requestFocus();
      await tester.pump();
      expect(controller.value, {WidgetState.focused});
      focusNode.unfocus();
      await tester.pump();

      // The states that follow the widget arrive after the frame: the
      // controller's listeners may not be told during a build.
      setOuter(() => selected = true);
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pump();
      expect(controller.value, {WidgetState.selected});

      setOuter(() {
        selected = false;
        enabled = false;
      });
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pump();
      expect(controller.value, {WidgetState.disabled});
    });

    testWidgets('a state set on the controller from outside is built', (
      tester,
    ) async {
      final controller = WidgetStatesController();
      addTearDown(controller.dispose);
      final log = <Set<WidgetState>>[];
      await pumpUna(
        tester,
        region(log: log, statesController: controller, onPressed: () {}),
      );
      controller.update(WidgetState.hovered, true);
      await tester.pump();
      expect(log.last, {WidgetState.hovered});
      controller.update(WidgetState.hovered, false);
      await tester.pump();
      expect(log.last, isEmpty);
    });

    testWidgets('can be given, swapped and taken away', (tester) async {
      final first = WidgetStatesController();
      final second = WidgetStatesController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      WidgetStatesController? current = first;
      late StateSetter setOuter;
      final log = <Set<WidgetState>>[];
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return region(
              log: log,
              statesController: current,
              onPressed: () {},
            );
          },
        ),
      );
      final mouse = await hoverAt(
        tester,
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      expect(first.value, {WidgetState.hovered});

      setOuter(() => current = second);
      await tester.pump();
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      expect(second.value, {WidgetState.hovered});
      // The one it let go of is no longer written to, or listened to.
      first.update(WidgetState.pressed, true);
      await tester.pump();
      expect(log.last, {WidgetState.hovered});

      setOuter(() => current = null);
      await tester.pump();
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(log.last, isEmpty);
      expect(second.value, {WidgetState.hovered});
      expect(tester.takeException(), isNull);
    });
  });

  group('Pressable callbacks', () {
    testWidgets('onHover is the mouse over an enabled region', (tester) async {
      final hovers = <bool>[];
      var enabled = false;
      late StateSetter setOuter;
      await pumpUna(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return region(
              log: [],
              onHover: hovers.add,
              onPressed: enabled ? () {} : null,
            );
          },
        ),
      );
      final mouse = await hoverAt(
        tester,
        tester.getCenter(find.byType(Pressable)),
      );
      await tester.pump();
      // Disabled: neither the coming nor the going is reported.
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(hovers, isEmpty);

      setOuter(() => enabled = true);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.byType(Pressable)));
      await tester.pump();
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(hovers, [true, false]);

      // A finger is not a hover.
      await tester.tap(find.byType(Pressable));
      await tester.pump();
      expect(hovers, [true, false]);
    });

    testWidgets('onFocusChange hears the focus whether or not it shows', (
      tester,
    ) async {
      // As on a phone: the focus does not show until a key is pressed.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final changes = <bool>[];
      final log = <Set<WidgetState>>[];
      await pumpUna(
        tester,
        region(
          log: log,
          focusNode: focusNode,
          onFocusChange: changes.add,
          onPressed: () {},
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(changes, [true]);
      expect(log.last, isEmpty);
      focusNode.unfocus();
      await tester.pump();
      expect(changes, [true, false]);
    });
  });

  group('Pressable semantics', () {
    testWidgets('toggled is announced, and adds the selected state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final log = <Set<WidgetState>>[];
      await pumpUna(
        tester,
        region(
          log: log,
          toggled: true,
          semanticLabel: 'Bold',
          onPressed: () {},
        ),
      );
      expect(log.last, {WidgetState.selected});
      final flags = tester
          .getSemantics(find.bySemanticsLabel('Bold'))
          .getSemanticsData()
          .flagsCollection;
      expect(flags.isToggled, Tristate.isTrue);
      // A toggle is not one of a set.
      expect(flags.isSelected, Tristate.none);
      handle.dispose();
    });

    testWidgets('semanticContainer keeps the region a node of its own', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      Widget row({required bool container}) => Semantics(
        container: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Name'),
            Pressable(
              onPressed: () {},
              semanticContainer: container,
              builder: (context, states) => const Text('Edit'),
            ),
          ],
        ),
      );

      // Without it the role and the tap are merged into the row.
      await pumpUna(tester, Center(child: row(container: false)));
      final merged = tester.getSemantics(find.text('Name')).getSemanticsData();
      expect(merged.label, contains('Edit'));
      expect(merged.flagsCollection.isButton, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await pumpUna(tester, Center(child: row(container: true)));
      final name = tester.getSemantics(find.text('Name')).getSemanticsData();
      expect(name.label, 'Name');
      expect(name.flagsCollection.isButton, isFalse);
      final edit = tester.getSemantics(find.text('Edit')).getSemanticsData();
      expect(edit.label, 'Edit');
      expect(edit.flagsCollection.isButton, isTrue);
      expect(edit.hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });
  });
}
