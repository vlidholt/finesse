import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class OtpFieldPinExample extends StatelessWidget {
  const OtpFieldPinExample({super.key});

  @override
  Widget build(BuildContext context) {
    return OtpField(
      maxLength: 4,
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      autofillHints: const [],
      onCompleted: (pin) {},
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
    );
  }
}
