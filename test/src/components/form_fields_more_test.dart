// The form fields of the controls that came without one: Autocomplete,
// ChipGroup, Rating, TagField, ColorPickerButton and RangeSlider. For each:
// its value reaches the form, a change is reported, validation shows its
// error and moves the focus into the field, a reset restores the initial
// value, and a disabled field cannot be changed.
import 'package:finesse/finesse.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GlobalKey<FinesseFormState> form;
  late List<Object?> changes;

  setUp(() {
    form = GlobalKey<FinesseFormState>();
    changes = [];
  });

  Future<void> pumpField(WidgetTester tester, Widget field) async {
    await tester.pumpWidget(
      FinesseApp(
        formFactor: FormFactor.desktop,
        home: Center(
          child: SizedBox(
            width: 360,
            child: FinesseForm(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  field,
                  // Somewhere for the focus to be before a validation.
                  Button(onPressed: () {}, child: const Text('Save')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  Object? valueOf(String id) {
    form.currentState!.save();
    return form.currentState!.value[id];
  }

  /// Validates, expects the error to show, and expects the keyboard focus
  /// to be on a node some widget inside [field] owns.
  Future<void> expectInvalidAndFocused(
    WidgetTester tester,
    Finder field,
    String error,
  ) async {
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(error), findsOneWidget);
    final focused = FocusManager.instance.primaryFocus!;
    expect(focused.context, isNotNull);
    final element = tester.element(field);
    var inside = false;
    focused.context!.visitAncestorElements((ancestor) {
      inside = ancestor == element;
      return !inside;
    });
    expect(inside, isTrue, reason: 'the focus is outside the invalid field');
    expect(tester.takeException(), isNull);
  }

  group('AutocompleteFormField', () {
    const cities = ['Lisbon', 'Lima', 'Lyon', 'Oslo'];

    Widget field({bool enabled = true}) => AutocompleteFormField<String>(
      id: 'city',
      label: const Text('City'),
      description: const Text('Where you are based'),
      enabled: enabled,
      initialValue: 'Oslo',
      optionsBuilder: (value) => value.text.isEmpty
          ? const <String>[]
          : cities.where(
              (city) => city.toLowerCase().startsWith(value.text.toLowerCase()),
            ),
      onChanged: changes.add,
      validator: (text) => cities.contains(text) ? null : 'Pick a city',
    );

    testWidgets('its value is the text, typed or taken from an option', (
      tester,
    ) async {
      await pumpField(tester, field());
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Where you are based'), findsOneWidget);
      expect(valueOf('city'), 'Oslo');

      await tester.enterText(find.byType(EditableText), 'Li');
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(valueOf('city'), 'Li');
      await tester.tap(find.text('Lima'));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(valueOf('city'), 'Lima');
      expect(changes, containsAllInOrder(<Object?>['Li', 'Lima']));
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('an invalid text shows the error and takes the focus; a '
        'reset puts the initial text back', (tester) async {
      await pumpField(tester, field());
      await tester.enterText(find.byType(EditableText), 'Nowhere');
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await expectInvalidAndFocused(
        tester,
        find.byType(AutocompleteFormField<String>),
        'Pick a city',
      );
      form.currentState!.reset();
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        'Oslo',
      );
      expect(valueOf('city'), 'Oslo');
    });

    testWidgets('disabled, it cannot be typed into', (tester) async {
      await pumpField(tester, field(enabled: false));
      expect(
        tester
            .widget<Autocomplete<String>>(find.byType(Autocomplete<String>))
            .enabled,
        isFalse,
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    });
  });

  group('ChipGroupFormField', () {
    Widget field({bool enabled = true, bool multiple = true}) =>
        ChipGroupFormField<String>(
          id: 'interests',
          label: const Text('Interests'),
          enabled: enabled,
          multiple: multiple,
          initialValue: const {'data'},
          items: const [
            ChipGroupItem(value: 'design', label: Text('Design')),
            ChipGroupItem(value: 'data', label: Text('Data')),
            ChipGroupItem(value: 'mobile', label: Text('Mobile')),
          ],
          onChanged: changes.add,
          validator: (chosen) => chosen.length < 2 ? 'Pick two' : null,
        );

    testWidgets('its value is the set of chosen chips', (tester) async {
      await pumpField(tester, field());
      expect(valueOf('interests'), {'data'});
      await tester.tap(find.text('Mobile'));
      await tester.pumpAndSettle();
      expect(valueOf('interests'), {'data', 'mobile'});
      expect(changes.last, {'data', 'mobile'});
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('single choice replaces the chosen chip', (tester) async {
      await pumpField(tester, field(multiple: false));
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();
      expect(valueOf('interests'), {'design'});
    });

    testWidgets('an invalid choice shows the error and focuses a chip; a '
        'reset restores it', (tester) async {
      await pumpField(tester, field());
      await expectInvalidAndFocused(
        tester,
        find.byType(ChipGroupFormField<String>),
        'Pick two',
      );
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();
      form.currentState!.reset();
      await tester.pump();
      expect(valueOf('interests'), {'data'});
    });

    testWidgets('disabled, a tap changes nothing', (tester) async {
      await pumpField(tester, field(enabled: false));
      await tester.tap(find.text('Mobile'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(valueOf('interests'), {'data'});
      expect(changes, isEmpty);
    });
  });

  group('RatingFormField', () {
    Widget field({bool enabled = true}) => RatingFormField(
      id: 'stars',
      label: const Text('Your stay'),
      enabled: enabled,
      onChanged: changes.add,
      validator: (stars) => stars == 0 ? 'Give it a rating' : null,
    );

    testWidgets('a tap rates, the arrow keys adjust, and the value reaches '
        'the form', (tester) async {
      await pumpField(tester, field());
      expect(valueOf('stars'), 0.0);
      final stars = tester.getRect(find.byType(Rating));
      // The fourth of five stars.
      await tester.tapAt(
        Offset(stars.left + stars.width * .7, stars.center.dy),
      );
      await tester.pumpAndSettle();
      expect(valueOf('stars'), 4.0);
      expect(changes, [4.0]);
      // As wide as its stars, not as the form.
      expect(stars.width, lessThan(200));
    });

    testWidgets('no rating shows the error and focuses the stars; a reset '
        'clears it', (tester) async {
      await pumpField(tester, field());
      await expectInvalidAndFocused(
        tester,
        find.byType(RatingFormField),
        'Give it a rating',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(valueOf('stars'), 1.0);
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.reset();
      await tester.pump();
      expect(valueOf('stars'), 0.0);
    });

    testWidgets('disabled, it is read-only', (tester) async {
      await pumpField(tester, field(enabled: false));
      await tester.tapAt(tester.getCenter(find.byType(Rating)));
      await tester.pumpAndSettle();
      expect(valueOf('stars'), 0.0);
    });
  });

  group('TagFormField', () {
    Widget field({bool enabled = true}) => TagFormField<String>(
      id: 'skills',
      label: const Text('Skills'),
      enabled: enabled,
      initialValue: const ['dart'],
      labelBuilder: (context, skill) => Text(skill),
      onChanged: changes.add,
      validator: (skills) => skills.length < 2 ? 'Add another' : null,
    );

    testWidgets('typed tags join the list, and the list is the value', (
      tester,
    ) async {
      await pumpField(tester, field());
      expect(valueOf('skills'), ['dart']);
      await tester.enterText(find.byType(EditableText), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(valueOf('skills'), ['dart', 'flutter']);
      expect(changes.last, ['dart', 'flutter']);
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('too few tags shows the error and focuses the input; a '
        'reset restores the list', (tester) async {
      await pumpField(tester, field());
      await expectInvalidAndFocused(
        tester,
        find.byType(TagFormField<String>),
        'Add another',
      );
      await tester.enterText(find.byType(EditableText), 'go');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(valueOf('skills'), ['dart']);
      expect(find.text('go'), findsNothing);
    });
  });

  group('ColorPickerFormField', () {
    const teal = Color(0xFF0F766E);
    const red = Color(0xFFDC2626);

    Widget field({bool enabled = true}) => ColorPickerFormField(
      id: 'accent',
      label: const Text('Accent'),
      enabled: enabled,
      initialValue: teal,
      swatches: const [teal, red],
      onChanged: changes.add,
      validator: (color) => color == teal ? 'Pick another' : null,
    );

    testWidgets('the swatch opens the picker and the chosen colour is the '
        'value', (tester) async {
      await pumpField(tester, field());
      expect(valueOf('accent'), teal);
      await tester.tap(find.byType(ColorPickerButton));
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(ColorPicker), findsOneWidget);
      // The second of the offered colours.
      final swatches = find.descendant(
        of: find.byType(ColorPicker),
        matching: find.byWidgetPredicate(
          (widget) => '${widget.runtimeType}' == '_Swatch',
        ),
      );
      await tester.tap(swatches.last);
      await tester.pumpAndSettle();
      expect(valueOf('accent'), red);
      expect(changes.last, red);
    });

    testWidgets('an invalid colour shows the error and focuses the swatch', (
      tester,
    ) async {
      await pumpField(tester, field());
      await expectInvalidAndFocused(
        tester,
        find.byType(ColorPickerFormField),
        'Pick another',
      );
    });

    testWidgets('disabled, the picker does not open', (tester) async {
      await pumpField(tester, field(enabled: false));
      await tester.tap(find.byType(ColorPickerButton), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(ColorPicker), findsNothing);
    });
  });

  group('RangeSliderFormField', () {
    Widget field({bool enabled = true}) => RangeSliderFormField(
      id: 'price',
      label: const Text('Price'),
      enabled: enabled,
      max: 100,
      initialValue: const [40, 50],
      onChanged: changes.add,
      validator: (range) => range.last - range.first < 20 ? 'Too narrow' : null,
    );

    testWidgets('dragging a thumb changes the value, which is one number '
        'per thumb', (tester) async {
      await pumpField(tester, field());
      expect(valueOf('price'), [40.0, 50.0]);
      final track = tester.getRect(find.byType(RangeSlider));
      await tester.dragFrom(
        Offset(track.left + track.width * .5, track.center.dy),
        Offset(track.width * .4, 0),
      );
      await tester.pumpAndSettle();
      final value = valueOf('price')! as List<double>;
      expect(value.first, 40);
      expect(value.last, greaterThan(80));
      expect(changes, isNotEmpty);
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('a narrow range shows the error and focuses a thumb; a '
        'reset restores it', (tester) async {
      await pumpField(tester, field());
      await expectInvalidAndFocused(
        tester,
        find.byType(RangeSliderFormField),
        'Too narrow',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect((valueOf('price')! as List<double>).first, lessThan(40));
      form.currentState!.reset();
      await tester.pump();
      expect(valueOf('price'), [40.0, 50.0]);
    });

    testWidgets('disabled, a drag changes nothing', (tester) async {
      await pumpField(tester, field(enabled: false));
      final track = tester.getRect(find.byType(RangeSlider));
      await tester.dragFrom(
        Offset(track.left + track.width * .5, track.center.dy),
        Offset(track.width * .3, 0),
      );
      await tester.pumpAndSettle();
      expect(valueOf('price'), [40.0, 50.0]);
    });
  });
}
