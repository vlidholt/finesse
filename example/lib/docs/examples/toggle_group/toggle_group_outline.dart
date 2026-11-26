import 'package:flutter/widgets.dart';
import 'package:una/una.dart';

class ToggleGroupOutlineExample extends StatefulWidget {
  const ToggleGroupOutlineExample({super.key});

  @override
  State<ToggleGroupOutlineExample> createState() =>
      _ToggleGroupOutlineExampleState();
}

class _ToggleGroupOutlineExampleState extends State<ToggleGroupOutlineExample> {
  String? value = 'bold';

  @override
  Widget build(BuildContext context) {
    return ToggleGroup<String>(
      value: value,
      variant: ToggleVariant.outline,
      onChanged: (next) => setState(() => value = next),
      items: const [
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
