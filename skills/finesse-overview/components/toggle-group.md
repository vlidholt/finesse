# Toggle Group

A set of two-state buttons that can be toggled on or off. The group is controlled: it shows `values` and reports a tap through `onChanged`; `initialValues` instead makes a group that keeps its own selection. With `gap: 0` the items are joined into one bar, as in a `ButtonGroup`, and `ToggleGroupFormField` puts a group in a `FinesseForm`.

## Single

Selecting one value clears the others.

```dart
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
```

## Multiple

```dart
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
```

## Outline

Every item uses the outline toggle style.

```dart
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
```
