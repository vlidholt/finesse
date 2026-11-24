import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleOutlineExample extends StatefulWidget {
  const ToggleOutlineExample({super.key});

  @override
  State<ToggleOutlineExample> createState() => _ToggleOutlineExampleState();
}

class _ToggleOutlineExampleState extends State<ToggleOutlineExample> {
  bool bold = false;
  bool italic = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Toggle.outline(
          value: bold,
          semanticLabel: 'Bold',
          onChanged: (value) => setState(() => bold = value),
          child: const Icon(PhosphorIconsRegular.textB),
        ),
        Toggle.outline(
          value: italic,
          semanticLabel: 'Italic',
          onChanged: (value) => setState(() => italic = value),
          child: const Icon(PhosphorIconsRegular.textItalic),
        ),
      ],
    );
  }
}
