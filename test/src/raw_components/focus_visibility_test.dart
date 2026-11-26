import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// Focus shows after a key and not after a click, as CSS's `:focus-visible`.
/// Flutter's focus manager ignores the mouse, so on a desktop whatever a
/// click focused — the first row of a sheet a button opened, the button
/// again once the sheet closed — showed its ring as though it were still
/// selected.
void main() {
  // A desktop, where the focus shows from the start.
  final desktop = TargetPlatformVariant.only(TargetPlatform.macOS);

  /// A button that, clicked, shows a row that takes the focus.
  Widget opener(List<Set<WidgetState>> log) {
    var open = false;
    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(
            onPressed: () => setState(() => open = true),
            child: const Text('Open'),
          ),
          if (open)
            Pressable(
              autofocus: true,
              onPressed: () {},
              builder: (context, states) {
                log.add(states);
                return const SizedBox(width: 80, height: 40);
              },
            ),
        ],
      ),
    );
  }

  testWidgets('a row a click focused shows no focus until a key is pressed', (
    tester,
  ) async {
    final log = <Set<WidgetState>>[];
    await pumpUna(tester, opener(log));
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);

    await tester.tap(find.text('Open'), kind: PointerDeviceKind.mouse);
    await tester.pump();
    await tester.pump();
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.touch);
    expect(log.last, isNot(contains(WidgetState.focused)));

    // A modifier held for a click is not the keyboard being used.
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(log.last, isNot(contains(WidgetState.focused)));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.pump();
    expect(FocusManager.instance.highlightMode, FocusHighlightMode.traditional);
    expect(log.last, contains(WidgetState.focused));

    // And a click hides it again.
    await tester.tapAt(Offset.zero, kind: PointerDeviceKind.mouse);
    await tester.pump();
    expect(log.last, isNot(contains(WidgetState.focused)));
  }, variant: desktop);

  testWidgets('a strategy someone else set is kept', (tester) async {
    useTraditionalHighlights();
    final log = <Set<WidgetState>>[];
    await pumpUna(tester, opener(log));
    await tester.tap(find.text('Open'), kind: PointerDeviceKind.mouse);
    await tester.pump();
    await tester.pump();
    expect(
      FocusManager.instance.highlightStrategy,
      FocusHighlightStrategy.alwaysTraditional,
    );
    expect(log.last, contains(WidgetState.focused));
  }, variant: desktop);

  testWidgets('the first action of a sheet a click opened is not lit', (
    tester,
  ) async {
    await pumpUna(
      tester,
      Builder(
        builder: (context) => Button(
          onPressed: () => showActionSheet<int>(
            context: context,
            actions: const [
              ActionSheetAction(value: 1, label: Text('Save as draft')),
              ActionSheetAction(value: 2, label: Text('Discard')),
            ],
          ),
          child: const Text('Close the editor'),
        ),
      ),
    );
    await tester.tap(
      find.text('Close the editor'),
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    // The row has the focus, as the keyboard needs, but shows none of it.
    final row = find.ancestor(
      of: find.text('Save as draft'),
      matching: find.byType(Pressable),
    );
    final focus = Focus.of(tester.element(find.text('Save as draft')));
    expect(focus.hasFocus, isTrue);
    final ring = tester.widget<FocusRing>(
      find.descendant(of: row, matching: find.byType(FocusRing)),
    );
    expect(ring.visible, isFalse);
  }, variant: desktop);
}
