import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class InputOtpBasicExample extends StatelessWidget {
  const InputOtpBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return OtpField(
      maxLength: 6,
      onChanged: (value) {},
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
    );
  }
}
