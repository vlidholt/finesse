# Form

Building forms with `FinesseForm`: field values collect under their ids, and validation runs per field.

## Validation and submit

`saveAndValidate` runs every validator and returns whether the form is valid. Values collect in `formKey.currentState!.value`.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class FormProfileExample extends StatefulWidget {
  const FormProfileExample({super.key});

  @override
  State<FormProfileExample> createState() => _FormProfileExampleState();
}

class _FormProfileExampleState extends State<FormProfileExample> {
  final formKey = GlobalKey<FinesseFormState>();

  @override
  Widget build(BuildContext context) {
    return FinesseForm(
      key: formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            TextFormField(
              id: 'username',
              label: const Text('Username'),
              placeholder: const Text('Enter your username'),
              description: const Text('This is your public display name.'),
              validator: (v) {
                if (v.length < 2) {
                  return 'Username must be at least 2 characters.';
                }
                return null;
              },
            ),
            CheckboxFormField(
              id: 'terms',
              initialValue: false,
              inputLabel: const Text('I accept the terms and conditions'),
              validator: (v) {
                if (!v) {
                  return 'You must accept the terms and conditions';
                }
                return null;
              },
            ),
            Button(
              child: const Text('Submit'),
              onPressed: () {
                if (formKey.currentState!.saveAndValidate()) {
                  Toaster.of(context).show(
                    Toast(
                      title: const Text('Form submitted'),
                      description: Text('${formKey.currentState!.value}'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

## Every field type

Each input component has a `*FormField` counterpart that plugs into `FinesseForm` the same way: `TextFormField`, `SelectFormField`, `TextareaFormField`, `RadioGroupFormField`, `DatePickerFormField`, `DateRangePickerFormField`, `TimePickerFormField`, `CheckboxFormField`, `SwitchFormField`, and `OtpFormField`. See `example/lib/docs/examples/form/form_fields.dart` for one of each wired into a single form.

## OTP verification

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

class FormOtpExample extends StatefulWidget {
  const FormOtpExample({super.key});

  @override
  State<FormOtpExample> createState() => _FormOtpExampleState();
}

class _FormOtpExampleState extends State<FormOtpExample> {
  final formKey = GlobalKey<FinesseFormState>();

  @override
  Widget build(BuildContext context) {
    return FinesseForm(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          OtpFormField(
            id: 'otp',
            maxLength: 6,
            label: const Text('OTP'),
            description: const Text('Enter your one-time password.'),
            validator: (v) => v.contains(' ') ? 'Fill the whole code' : null,
            children: const [
              OtpFieldGroup(
                children: [
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                ],
              ),
              Icon(LucideIcons.dot),
              OtpFieldGroup(
                children: [
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                  OtpFieldSlot(),
                ],
              ),
            ],
          ),
          Button(
            child: const Text('Verify'),
            onPressed: () => formKey.currentState!.saveAndValidate(),
          ),
        ],
      ),
    );
  }
}
```
