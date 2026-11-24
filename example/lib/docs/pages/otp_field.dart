import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/otp_field/otp_field_basic.dart';

final otpFieldDoc = ComponentDoc(
  slug: 'otp_field',
  title: 'OTP Field',
  description:
      'An `OtpField` takes a one-time password a character per slot, with '
      'copy-paste support.',
  examples: [
    ComponentExample(
      id: 'otp_field_basic',
      title: 'Default',
      builder: (_) => const OtpFieldBasicExample(),
    ),
  ],
);
