import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class TextFieldPasswordExample extends StatefulWidget {
  const TextFieldPasswordExample({super.key});

  @override
  State<TextFieldPasswordExample> createState() =>
      _TextFieldPasswordExampleState();
}

class _TextFieldPasswordExampleState extends State<TextFieldPasswordExample> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: TextField(
        placeholder: const Text('Password'),
        obscureText: obscure,
        leading: Icon(
          PhosphorIconsRegular.lock,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
        trailing: FinesseGestureDetector(
          cursor: SystemMouseCursors.click,
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => obscure = !obscure),
          child: Icon(
            obscure ? PhosphorIconsRegular.eyeSlash : PhosphorIconsRegular.eye,
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ),
    );
  }
}
