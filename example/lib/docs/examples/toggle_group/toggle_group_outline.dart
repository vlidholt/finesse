import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleGroupOutlineExample extends StatefulWidget {
  const ToggleGroupOutlineExample({super.key});

  @override
  State<ToggleGroupOutlineExample> createState() =>
      _ToggleGroupOutlineExampleState();
}

class _ToggleGroupOutlineExampleState extends State<ToggleGroupOutlineExample> {
  Set<String> values = const {'bold'};

  @override
  Widget build(BuildContext context) {
    return ToggleGroup<String>(
      values: values,
      toggleVariant: ToggleVariant.outline,
      onChanged: (next) => setState(() => values = next),
      children: const [
        ToggleGroupItem(
          value: 'bold',
          semanticLabel: 'Bold',
          child: Icon(PhosphorIconsRegular.textB),
        ),
        ToggleGroupItem(
          value: 'italic',
          semanticLabel: 'Italic',
          child: Icon(PhosphorIconsRegular.textItalic),
        ),
        ToggleGroupItem(
          value: 'underline',
          semanticLabel: 'Underline',
          child: Icon(PhosphorIconsRegular.textUnderline),
        ),
      ],
    );
  }
}
