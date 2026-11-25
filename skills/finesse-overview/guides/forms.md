# Forms and values

## Controls are controlled

Every control that holds a value follows Flutter's convention: it shows
`value` and reports a change through `onChanged`, and the parent decides
what the value becomes. A control that can sensibly hold its own state
also takes `initialValue` instead (never both). A `controller` exists only
where there is more to do than hold the value: opening and closing,
scrolling, editing text.

```dart
class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  bool _digest = true;
  String? _language = 'en';
  double _volume = .4;

  @override
  Widget build(BuildContext context) {
    return FinesseColumn(
      gap: GapSize.md,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Switch(
          value: _digest,
          onChanged: (value) => setState(() => _digest = value),
          label: const Text('Weekly digest'),
        ),
        Select<String>(
          value: _language,
          onChanged: (value) => setState(() => _language = value),
          placeholder: const Text('Language'),
          options: const [
            SelectOption(value: 'en', label: 'English'),
            SelectOption(value: 'sv', label: 'Svenska'),
          ],
          selectedOptionBuilder: (context, value) =>
              Text(value == 'en' ? 'English' : 'Svenska'),
        ),
        Slider(
          value: _volume,
          onChanged: (value) => setState(() => _volume = value),
        ),
      ],
    );
  }
}
```

- Labels on controls are `label` and `description`; on surfaces (cards,
  dialogs, sheets, toasts, alerts) `title` and `description`.
- `enabled: false` disables, never `disabled: true`.
- Activation names: `onPressed` on buttons and button-like controls,
  `onTap` on rows, cards and text fields, `onSelected` for picking from a
  list, `onChanged` for a value.
- Text fields keep a `TextEditingController` when you need one; otherwise
  `initialValue` + `onChanged`.

## Pickers are fields

`DatePicker`, `DateRangePicker` and `TimePicker` look like a text field
showing the value, and open a calendar in a popover on a desktop and a
bottom sheet (calendar or wheels) on a phone. `DateField` and `TimeField`
are typed, keyboard-first entry in small number fields. `Select` opens a
list (a bottom sheet on a phone for the searchable and multiple variants).
`presentation: PickerPresentation.popover` or `.sheet` forces one
presentation; the default follows the form factor.

## FinesseForm

A `FinesseForm` collects its fields' values under their `id`s and runs
their validators. Each field is the control with a `label`, a
`description` and an error line:

```dart
class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _form = GlobalKey<FinesseFormState>();

  void _submit() {
    final form = _form.currentState!;
    if (form.saveAndValidate()) {
      final values = form.value; // {'email': ..., 'plan': ..., 'terms': ...}
      Toaster.of(context).show(Toast(title: Text('Welcome, $values')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FinesseForm(
      key: _form,
      child: FinesseColumn(
        gap: GapSize.lg,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            id: 'email',
            label: const Text('Email'),
            placeholder: const Text('you@example.com'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v.contains('@') ? null : 'Enter an email',
          ),
          SelectFormField<String>(
            id: 'plan',
            label: const Text('Plan'),
            placeholder: const Text('Choose a plan'),
            options: const [
              SelectOption(value: 'free', label: 'Free'),
              SelectOption(value: 'pro', label: 'Pro'),
            ],
            selectedOptionBuilder: (context, value) => Text(value),
            validator: (v) => v == null ? 'Choose a plan' : null,
          ),
          CheckboxFormField(
            id: 'terms',
            initialValue: false,
            inputLabel: const Text('I accept the terms'),
            validator: (v) => v ? null : 'Accept the terms to go on',
          ),
          Button(onPressed: _submit, child: const Text('Create account')),
        ],
      ),
    );
  }
}
```

- `saveAndValidate()` saves every field, validates them and moves the
  focus to the first invalid one; `validate()`, `save()` and `reset()` do
  one step each. `value` is the map of values by id;
  `setFieldValue(id, value)` and `setFieldError(id, error)` change one.
- A form field holds its own value: give it `initialValue` (or the form an
  `initialValue` map), not `value`.
- `FinesseForm.of(context)` reaches the form from below it.
- `autovalidateMode` on the form or a field decides when errors appear.

### Every form field

| Control | Form field |
| --- | --- |
| `TextField`, `Textarea` | `TextFormField` (and `TextFormField.password`), `TextareaFormField` |
| `Autocomplete`, `TagField`, `NumberField`, `OtpField` | `AutocompleteFormField`, `TagFormField`, `NumberFormField`, `OtpFormField` |
| `Checkbox`, `Switch` | `CheckboxFormField`, `SwitchFormField` |
| `FinesseRadioGroup`, `SegmentedControl` | `RadioGroupFormField`, `SegmentedControlFormField` |
| `ToggleGroup`, `ToggleGroup.multiple` | `ToggleGroupFormField`, `ToggleGroupMultipleFormField` |
| `ChipGroup`, `ChipGroup.multiple` | `ChipGroupFormField`, `ChipGroupMultipleFormField` |
| `Select`, `Select.multiple` | `SelectFormField`, `SelectMultipleFormField` (both with `.withSearch`) |
| `Slider`, `RangeSlider`, `Rating` | `SliderFormField`, `RangeSliderFormField`, `RatingFormField` |
| `DatePicker`, `DateRangePicker`, `DateField` | `DatePickerFormField`, `DateRangePickerFormField`, `DateFormField` |
| `TimePicker`, `TimeField` | `TimePickerFormField`, `TimeFormField` |
| `ColorPicker` | `ColorPickerFormField` |

A control of your own joins a form by extending `FinesseFormField<T>`,
whose `builder` gets the `FormFieldState<T>` (`value`, `didChange`,
`errorText`).

## Text input details

- `TextField` has `clearable`, `TextField.password` (with a reveal
  button), `showCounter`, and touch selection handles, toolbar and
  magnifier on phones. `SearchField` is a text field for a query (a
  magnifier, a clear button, Escape clears).
- A focused field is scrolled clear of the keyboard and of a scaffold's
  footer by itself.
- `KeyboardToolbar` puts previous/next/done above the software keyboard.

See also: [text-field.md](../components/text-field.md),
[select.md](../components/select.md),
[date-picker.md](../components/date-picker.md),
[date-field.md](../components/date-field.md),
[time-picker.md](../components/time-picker.md),
[time-field.md](../components/time-field.md),
[checkbox.md](../components/checkbox.md),
[radio-group.md](../components/radio-group.md),
[otp-field.md](../components/otp-field.md),
[tag-field.md](../components/tag-field.md),
[number-field.md](../components/number-field.md),
[autocomplete.md](../components/autocomplete.md).
