import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// What `FinesseForm.validate` focuses when a field is invalid.
///
/// A form field's state owns a [FocusNode], but only some fields hand it to
/// a widget: the OTP field, the radio group and the time picker are made of
/// several controls and attach none of them to it. Focusing that node used to
/// reparent it, unattached, under the route's scope — the keyboard focus left
/// the UI, and once the form was disposed the focus manager was left holding
/// a disposed node.
void main() {
  /// Pumps a form holding [field] that can be swapped for a plain button
  /// (the page the user navigates to) by clearing the returned notifier.
  Future<ValueNotifier<bool>> pumpForm(
    WidgetTester tester,
    GlobalKey<FinesseFormState> formKey,
    Widget field,
  ) async {
    final showForm = ValueNotifier(true);
    addTearDown(showForm.dispose);
    await tester.pumpWidget(
      FinesseApp(
        home: ValueListenableBuilder(
          valueListenable: showForm,
          builder: (context, form, _) => Center(
            child: form
                ? FinesseForm(key: formKey, child: field)
                : Button(onPressed: () {}, child: const Text('Other')),
          ),
        ),
      ),
    );
    await tester.pump();
    return showForm;
  }

  /// The primary focus, which has to be a node some widget under [field]
  /// owns.
  FocusNode expectFocusInside(WidgetTester tester, Finder field) {
    final focused = FocusManager.instance.primaryFocus!;
    expect(
      focused.context,
      isNotNull,
      reason: 'the primary focus is a node attached to no widget',
    );
    final fieldElement = tester.element(field);
    var inside = false;
    focused.context!.visitAncestorElements((ancestor) {
      inside = ancestor == fieldElement;
      return !inside;
    });
    expect(inside, isTrue, reason: 'the focus is outside the invalid field');
    return focused;
  }

  /// Removes the form and moves the focus on, as a page switch does.
  Future<void> leaveForm(
    WidgetTester tester,
    ValueNotifier<bool> showForm,
  ) async {
    showForm.value = false;
    await tester.pump();
    await tester.tap(find.text('Other'));
    await tester.pump();
    Focus.of(tester.element(find.text('Other'))).requestFocus();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(FocusManager.instance.primaryFocus!.context, isNotNull);
  }

  group('a failed validation focuses a control inside the field', () {
    testWidgets('OTP field: its first slot, and the form can be disposed', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      final first = FocusNode(debugLabel: 'first slot');
      addTearDown(first.dispose);
      final showForm = await pumpForm(
        tester,
        formKey,
        OtpFormField(
          id: 'otp',
          maxLength: 3,
          validator: (v) => 'always wrong',
          children: [
            OtpFieldGroup(
              children: [
                OtpFieldSlot(focusNode: first),
                const OtpFieldSlot(),
                const OtpFieldSlot(),
              ],
            ),
          ],
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(expectFocusInside(tester, find.byType(OtpFormField)), first);

      await leaveForm(tester, showForm);
    });

    testWidgets('radio group: its first radio, and the form can be disposed', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      final first = FocusNode(debugLabel: 'first radio');
      addTearDown(first.dispose);
      final showForm = await pumpForm(
        tester,
        formKey,
        RadioGroupFormField<String>(
          id: 'plan',
          validator: (v) => v == null ? 'pick one' : null,
          items: [
            Radio(value: 'a', label: const Text('A'), focusNode: first),
            const Radio(value: 'b', label: Text('B')),
            const Radio(value: 'c', label: Text('C')),
          ],
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(
        expectFocusInside(tester, find.byType(RadioGroupFormField<String>)),
        first,
      );

      await leaveForm(tester, showForm);
    });

    testWidgets('time picker: its hour field, and the form can be disposed', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      final showForm = await pumpForm(
        tester,
        formKey,
        TimePickerFormField(
          id: 'time',
          validator: (v) => v == null ? 'pick a time' : null,
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      final focused = expectFocusInside(
        tester,
        find.byType(TimePickerFormField),
      );
      // The hour is the first of the picker's three fields.
      final hour = tester.element(find.byType(TimePickerField).first);
      var inHour = false;
      focused.context!.visitAncestorElements((ancestor) {
        inHour = ancestor == hour;
        return !inHour;
      });
      expect(inHour, isTrue, reason: 'the focus is not in the hour field');

      await leaveForm(tester, showForm);
    });

    testWidgets('a field that attaches its node is focused through it', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      final fieldKey = GlobalKey<TextFormFieldState>();
      final showForm = await pumpForm(
        tester,
        formKey,
        TextFormField(
          key: fieldKey,
          id: 'name',
          validator: (v) => 'always wrong',
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus,
        fieldKey.currentState!.focusNode,
      );

      await leaveForm(tester, showForm);
    });

    testWidgets('a field with nothing to focus leaves the focus alone', (
      tester,
    ) async {
      final formKey = GlobalKey<FinesseFormState>();
      final showForm = await pumpForm(
        tester,
        formKey,
        FinesseFormField<String>(
          id: 'custom',
          validator: (v) => 'always wrong',
          builder: (state) => const Text('nothing focusable'),
        ),
      );
      final before = FocusManager.instance.primaryFocus;

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus, before);

      await leaveForm(tester, showForm);
    });
  });
}
