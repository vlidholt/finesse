import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class OtpFieldControlledExample extends StatefulWidget {
  const OtpFieldControlledExample({super.key});

  @override
  State<OtpFieldControlledExample> createState() =>
      _OtpFieldControlledExampleState();
}

class _OtpFieldControlledExampleState extends State<OtpFieldControlledExample> {
  // A space stands for an empty slot.
  String _code = '';
  String? _checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FinesseColumn(
      mainAxisSize: MainAxisSize.min,
      gap: GapSize.md,
      children: [
        OtpField(
          maxLength: 4,
          value: _code,
          keyboardType: TextInputType.number,
          onChanged: (code) => setState(() {
            _code = code;
            _checked = null;
          }),
          // Called once, when the last empty slot is filled.
          onCompleted: (code) => setState(() => _checked = code),
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
        ),
        Text(
          _checked == null
              ? 'Entered: "${_code.trimRight()}"'
              : 'Checking $_checked…',
          style: theme.textTheme.muted,
        ),
        Button.outline(
          size: ButtonSize.sm,
          // Setting the value from outside empties every slot.
          onPressed: () => setState(() {
            _code = '';
            _checked = null;
          }),
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
