import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleGroupMultipleExample extends StatefulWidget {
  const ToggleGroupMultipleExample({super.key});

  @override
  State<ToggleGroupMultipleExample> createState() =>
      _ToggleGroupMultipleExampleState();
}

class _ToggleGroupMultipleExampleState
    extends State<ToggleGroupMultipleExample> {
  Set<String> formatting = {'bold'};

  @override
  Widget build(BuildContext context) {
    return ToggleGroup<String>.multiple(
      values: formatting,
      onChanged: (values) => setState(() => formatting = values),
      children: const [
        ToggleGroupItem(
          value: 'bold',
          semanticLabel: 'Bold',
          child: PhosphorIcon(PhosphorIconsRegular.textB),
        ),
        ToggleGroupItem(
          value: 'italic',
          semanticLabel: 'Italic',
          child: PhosphorIcon(PhosphorIconsRegular.textItalic),
        ),
        ToggleGroupItem(
          value: 'underline',
          semanticLabel: 'Underline',
          child: PhosphorIcon(PhosphorIconsRegular.textUnderline),
        ),
      ],
    );
  }
}
