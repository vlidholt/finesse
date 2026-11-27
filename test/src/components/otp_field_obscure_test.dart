import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// An obscured field, as a PIN is entered: a filled slot shows a dot and
/// draws its character unseen; an empty slot shows nothing; the digits are
/// still what the field reports.
void main() {
  testWidgets('filled slots show a dot, and the digits are reported', (
    tester,
  ) async {
    String? changed;
    await pumpUna(
      tester,
      Center(
        child: OtpField(
          maxLength: 4,
          obscureText: true,
          onChanged: (value) => changed = value,
          children: const [
            OtpFieldGroup(
              children: [
                OtpFieldSlot(),
                OtpFieldSlot(),
                OtpFieldSlot(),
                OtpFieldSlot(),
              ],
            ),
          ],
        ),
      ),
    );
    Finder slot(int i) => find.descendant(
      of: find.byType(OtpFieldSlot).at(i),
      matching: find.byType(EditableText),
    );
    await tester.enterText(slot(0), '7');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(changed, '7   ');

    // The characters are drawn in a transparent colour.
    final editable = tester.widget<EditableText>(slot(0));
    expect(editable.style.color!.a, 0);

    double dotScale(int i) => tester
        .widget<AnimatedScale>(
          find.descendant(
            of: find.byType(OtpFieldSlot).at(i),
            matching: find.byType(AnimatedScale),
          ),
        )
        .scale;
    expect(dotScale(0), 1);
    expect(dotScale(1), 0);
  });

  testWidgets('a field that is not obscured draws its characters', (
    tester,
  ) async {
    await pumpUna(
      tester,
      const Center(
        child: OtpField(
          maxLength: 2,
          initialValue: '12',
          children: [
            OtpFieldGroup(children: [OtpFieldSlot(), OtpFieldSlot()]),
          ],
        ),
      ),
    );
    expect(find.byType(AnimatedScale), findsNothing);
    final editable = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );
    expect(editable.style.color!.a, greaterThan(0));
  });
}
