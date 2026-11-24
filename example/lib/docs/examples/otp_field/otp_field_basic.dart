import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class OtpFieldBasicExample extends StatelessWidget {
  const OtpFieldBasicExample({super.key});

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
        Icon(PhosphorIconsRegular.dotOutline),
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
