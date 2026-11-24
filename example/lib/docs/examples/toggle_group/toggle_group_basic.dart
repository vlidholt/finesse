import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleGroupBasicExample extends StatefulWidget {
  const ToggleGroupBasicExample({super.key});

  @override
  State<ToggleGroupBasicExample> createState() =>
      _ToggleGroupBasicExampleState();
}

class _ToggleGroupBasicExampleState extends State<ToggleGroupBasicExample> {
  Set<String> alignment = {'left'};

  @override
  Widget build(BuildContext context) {
    return ToggleGroup<String>(
      values: alignment,
      onChanged: (values) => setState(() => alignment = values),
      children: const [
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
