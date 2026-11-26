import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
        PhosphorIcon(PhosphorIconsRegular.dotOutline),
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
