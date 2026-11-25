import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleStyleExample extends StatefulWidget {
  const ToggleStyleExample({super.key});

  @override
  State<ToggleStyleExample> createState() => _ToggleStyleExampleState();
}

class _ToggleStyleExampleState extends State<ToggleStyleExample> {
  bool pinned = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Toggle.outline(
      value: pinned,
      // Only what is on changes: off, hovered and focused are the theme's.
      style: ToggleTheme(
        selectedBackgroundColor: scheme.primary,
        selectedHoverBackgroundColor: scheme.primary.withValues(alpha: .85),
        selectedForegroundColor: scheme.primaryForeground,
      ),
      onChanged: (value) => setState(() => pinned = value),
      leading: PhosphorIcon(
        pinned ? PhosphorIconsFill.pushPin : PhosphorIconsRegular.pushPin,
      ),
      child: Text(pinned ? 'Pinned' : 'Pin'),
    );
  }
}
