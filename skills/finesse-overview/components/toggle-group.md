# Toggle Group

A set of two-state buttons that can be toggled on or off.

## Single

Selecting one value clears the others.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

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
          child: Icon(LucideIcons.alignLeft),
        ),
        ToggleGroupItem(
          value: 'center',
          semanticLabel: 'Align center',
          child: Icon(LucideIcons.alignCenter),
        ),
        ToggleGroupItem(
          value: 'right',
          semanticLabel: 'Align right',
          child: Icon(LucideIcons.alignRight),
        ),
      ],
    );
  }
}
```

## Multiple

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

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
```

## Outline

Every item uses the outline toggle style.

```dart
import 'package:flutter/widgets.dart';
import 'package:finesse/finesse.dart';

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
```

