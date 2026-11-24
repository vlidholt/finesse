import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

enum NotifyAbout {
  all('All new messages'),
  mentions('Direct messages and mentions'),
  nothing('Nothing');

  const NotifyAbout(this.message);

  final String message;
}

/// Every form field variant in a single form.
class FormFieldsExample extends StatefulWidget {
  const FormFieldsExample({super.key});

  @override
  State<FormFieldsExample> createState() => _FormFieldsExampleState();
}

class _FormFieldsExampleState extends State<FormFieldsExample> {
  final formKey = GlobalKey<FinesseFormState>();

  static const verifiedEmails = [
    'm@example.com',
    'm@google.com',
    'm@support.com',
  ];

  @override
  Widget build(BuildContext context) {
    return FinesseForm(
      key: formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            TextFormField(
              id: 'username',
              label: const Text('Username'),
              placeholder: const Text('Enter your username'),
            ),
            SelectFormField<String>(
              id: 'email',
              label: const Text('Email'),
              placeholder: const Text('Select a verified email'),
              options: [
                for (final email in verifiedEmails)
                  SelectOption(value: email, child: Text(email)),
              ],
              selectedOptionBuilder: (context, value) => Text(value),
            ),
            TextareaFormField(
              id: 'bio',
              label: const Text('Bio'),
              placeholder: const Text('Tell us about yourself...'),
            ),
            RadioGroupFormField<NotifyAbout>(
              id: 'notify',
              label: const Text('Notify me about'),
              items: [
                for (final option in NotifyAbout.values)
                  Radio(value: option, label: Text(option.message)),
              ],
            ),
            DatePickerFormField(
              id: 'date',
              label: const Text('Date of birth'),
            ),
            TimePickerFormField(
              id: 'time',
              label: const Text('Pick a time'),
            ),
            SwitchFormField(
              id: 'marketing',
              initialValue: false,
              inputLabel: const Text('Marketing emails'),
            ),
            Button(
              child: const Text('Submit'),
              onPressed: () => formKey.currentState!.saveAndValidate(),
            ),
          ],
        ),
      ),
    );
  }
}
