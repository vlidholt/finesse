import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGroupVerticalExample extends StatefulWidget {
  const ButtonGroupVerticalExample({super.key});

  @override
  State<ButtonGroupVerticalExample> createState() =>
      _ButtonGroupVerticalExampleState();
}

class _ButtonGroupVerticalExampleState
    extends State<ButtonGroupVerticalExample> {
  var _marks = <String>{'bold'};

  @override
  Widget build(BuildContext context) {
    return FinesseRow(
      gap: GapSize.xl,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom controls, stacked.
        ButtonGroup(
          axis: Axis.vertical,
          semanticLabel: 'Zoom',
          children: [
            IconButton.outline(
              tooltip: 'Zoom in',
              onPressed: () {},
              icon: const PhosphorIcon(PhosphorIconsRegular.plus),
            ),
            IconButton.outline(
              tooltip: 'Zoom out',
              onPressed: () {},
              icon: const PhosphorIcon(PhosphorIconsRegular.minus),
            ),
          ],
        ),
        // A toggle group with no gap is joined the same way.
        ToggleGroup<String>.multiple(
          gap: 0,
          variant: ToggleVariant.outline,
          values: _marks,
          onValuesChanged: (marks) => setState(() => _marks = marks),
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
        ),
      ],
    );
  }
}
