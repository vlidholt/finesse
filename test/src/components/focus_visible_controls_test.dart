import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// A control a click operates shows its focus as a browser's
/// `:focus-visible` does: after a key, not after the click that chose.
void main() {
  testWidgets('a select keeps no ring after an option is clicked', (
    tester,
  ) async {
    String? value;
    await pumpUna(
      tester,
      Center(
        child: StatefulBuilder(
          builder: (context, setState) => Select<String>(
            value: value,
            placeholder: const Text('Fruit'),
            options: const [
              SelectOption(value: 'apple', child: Text('Apple')),
              SelectOption(value: 'pear', child: Text('Pear')),
            ],
            selectedOptionBuilder: (context, v) => Text(v),
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Fruit'), kind: PointerDeviceKind.mouse);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tap(find.text('Pear'), kind: PointerDeviceKind.mouse);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(value, 'pear');
    final triggerFinder = find
        .ancestor(of: find.text('pear'), matching: find.byType(Decorator))
        .first;
    expect(tester.widget<Decorator>(triggerFinder).focused, isFalse);
  });

  testWidgets('a checkbox focused by Tab shows its ring', (tester) async {
    await pumpUna(
      tester,
      Center(child: Checkbox(value: false, onChanged: (_) {})),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(tester.widget<Decorator>(find.byType(Decorator)).focused, isTrue);
    // A click anywhere hides it again; the focus stays where it was.
    await tester.tapAt(Offset.zero, kind: PointerDeviceKind.mouse);
    await tester.pump();
    expect(tester.widget<Decorator>(find.byType(Decorator)).focused, isFalse);
  });
}
