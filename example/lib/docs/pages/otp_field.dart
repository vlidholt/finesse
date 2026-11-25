import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/otp_field/otp_field_basic.dart';
import 'package:example/docs/examples/otp_field/otp_field_controlled.dart';

final otpFieldDoc = ComponentDoc(
  slug: 'otp_field',
  title: 'OTP Field',
  description:
      'An `OtpField` takes a one-time password a character per slot. A '
      'pasted code, or one the platform offers from a text message, is spread '
      'over the slots. Like the other fields it takes `value` and '
      '`onChanged`, or `initialValue` to hold its own state; the value has '
      'one character per slot, a space for an empty one.',
  examples: [
    ComponentExample(
      id: 'otp_field_basic',
      title: 'Default',
      builder: (_) => const OtpFieldBasicExample(),
    ),
    ComponentExample(
      id: 'otp_field_controlled',
      title: 'Controlled',
      description:
          'With `value` the parent owns the code: it can clear it, and an '
          'edit it does not hand back is undone. `onCompleted` fires when '
          'the last empty slot is filled.',
      builder: (_) => const OtpFieldControlledExample(),
    ),
  ],
);
