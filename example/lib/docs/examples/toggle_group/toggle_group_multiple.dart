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
          child: Icon(LucideIcons.bold),
        ),
        ToggleGroupItem(
          value: 'italic',
          semanticLabel: 'Italic',
          child: Icon(LucideIcons.italic),
        ),
        ToggleGroupItem(
          value: 'underline',
          semanticLabel: 'Underline',
          child: Icon(LucideIcons.underline),
        ),
      ],
    );
  }
}
