import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class TextFieldPasswordExample extends StatelessWidget {
  const TextFieldPasswordExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      // Obscured, with a button that shows and hides the text, the
      // password keyboard and the password manager's autofill.
      child: TextField.password(
        placeholder: const Text('Password'),
        leading: PhosphorIcon(
          PhosphorIconsRegular.lock,
          size: 16,
          color: theme.colorScheme.mutedForeground,
        ),
      ),
    );
  }
}
