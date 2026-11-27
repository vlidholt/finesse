import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:una/una.dart';

import '../../una_harness.dart';

/// Each slot of an OTP field is read as the field's name and its place, and
/// an obscured field gives no digit away.
void main() {
  Finder slot(int i) => find.descendant(
    of: find.byType(OtpFieldSlot).at(i),
    matching: find.byType(EditableText),
  );

  Widget field({bool obscure = false, String? semanticLabel}) => Center(
    child: OtpField(
      maxLength: 3,
      obscureText: obscure,
      semanticLabel: semanticLabel,
      children: const [
        OtpFieldGroup(
          children: [OtpFieldSlot(), OtpFieldSlot(), OtpFieldSlot()],
        ),
      ],
    ),
  );

  testWidgets('each slot says its place', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, field());
    expect(tester.getSemantics(slot(0)).label, 'Digit 1 of 3');
    expect(tester.getSemantics(slot(2)).label, 'Digit 3 of 3');
    await tester.enterText(slot(0), '7');
    await tester.pump();
    expect(tester.getSemantics(slot(0)).value, contains('7'));
    handle.dispose();
  });

  testWidgets('the semanticLabel goes before the place', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, field(semanticLabel: 'Verification code'));
    expect(
      tester.getSemantics(slot(1)).label,
      'Verification code, Digit 2 of 3',
    );
    handle.dispose();
  });

  testWidgets('in a form field each slot takes the label and the hint', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpUna(
      tester,
      Center(
        child: OtpFormField(
          maxLength: 2,
          label: const Text('PIN'),
          description: const Text('From the letter'),
          children: const [
            OtpFieldGroup(children: [OtpFieldSlot(), OtpFieldSlot()]),
          ],
        ),
      ),
    );
    final node = tester.getSemantics(slot(0));
    expect(node.label, 'PIN, Digit 1 of 2');
    expect(node.hint, 'From the letter');
    expect(find.bySemanticsLabel('PIN'), findsNothing);
    handle.dispose();
  });

  testWidgets('an obscured slot is marked so and says only that it is '
      'filled', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUna(tester, field(obscure: true));
    await tester.enterText(slot(0), '7');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final filled = tester.getSemantics(slot(0)).getSemanticsData();
    expect(filled.flagsCollection.isObscured, isTrue);
    expect(filled.value, '•');
    expect(filled.value, isNot(contains('7')));
    expect(filled.label, 'Digit 1 of 3');

    final empty = tester.getSemantics(slot(1)).getSemanticsData();
    expect(empty.flagsCollection.isObscured, isTrue);
    expect(empty.value.replaceAll(RegExp('[​•]'), ''), isEmpty);
    expect(empty.value, isNot(contains('•')));
    // Nowhere in the tree is the digit.
    expect(find.bySemanticsLabel(RegExp('7')), findsNothing);
    handle.dispose();
  });
}
