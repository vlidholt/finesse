import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

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
