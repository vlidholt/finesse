# OTP Field

An `OtpField` takes a one-time password a character per slot. A pasted code, or one the platform offers from a text message, is spread over the slots. Like the other fields it takes `value` and `onChanged`, or `initialValue` to hold its own state; the value has one character per slot, a space for an empty one.

## Default

```dart
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
```

## Controlled

With `value` the parent owns the code: it can clear it, and an edit it does not hand back is undone. `onCompleted` fires when the last empty slot is filled.

```dart
import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

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
    return UnaColumn(
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
```

## PIN

With `obscureText` a filled slot shows a dot, as a PIN is entered; the digits are still what `onChanged` and `onCompleted` report.

```dart
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
```
