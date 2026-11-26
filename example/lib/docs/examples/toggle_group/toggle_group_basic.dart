import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ToggleGroupBasicExample extends StatefulWidget {
  const ToggleGroupBasicExample({super.key});

  @override
  State<ToggleGroupBasicExample> createState() =>
      _ToggleGroupBasicExampleState();
}

class _ToggleGroupBasicExampleState extends State<ToggleGroupBasicExample> {
  String? alignment = 'left';

  @override
  Widget build(BuildContext context) {
    return ToggleGroup<String>(
      value: alignment,
      onChanged: (value) => setState(() => alignment = value),
      items: const [
        ToggleGroupItem(
          value: 'left',
          semanticLabel: 'Align left',
          child: PhosphorIcon(PhosphorIconsRegular.textAlignLeft),
        ),
        ToggleGroupItem(
          value: 'center',
          semanticLabel: 'Align center',
          child: PhosphorIcon(PhosphorIconsRegular.textAlignCenter),
        ),
        ToggleGroupItem(
          value: 'right',
          semanticLabel: 'Align right',
          child: PhosphorIcon(PhosphorIconsRegular.textAlignRight),
        ),
      ],
    );
  }
}
