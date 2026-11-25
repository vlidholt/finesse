# Toggle

A two-state button that can be either on or off.

## Default

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleBasicExample extends StatefulWidget {
  const ToggleBasicExample({super.key});

  @override
  State<ToggleBasicExample> createState() => _ToggleBasicExampleState();
}

class _ToggleBasicExampleState extends State<ToggleBasicExample> {
  bool bold = false;
  bool underline = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Toggle(
          value: bold,
          semanticLabel: 'Bold',
          onChanged: (value) => setState(() => bold = value),
          child: const PhosphorIcon(PhosphorIconsRegular.textB),
        ),
        Toggle(
          value: underline,
          leading: const PhosphorIcon(PhosphorIconsRegular.textUnderline),
          onChanged: (value) => setState(() => underline = value),
          child: const Text('Underline'),
        ),
      ],
    );
  }
}
```

## Outline

A bordered toggle with a subtle shadow.

```dart
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
          child: const PhosphorIcon(PhosphorIconsRegular.textB),
        ),
        Toggle.outline(
          value: italic,
          semanticLabel: 'Italic',
          onChanged: (value) => setState(() => italic = value),
          child: const PhosphorIcon(PhosphorIconsRegular.textItalic),
        ),
      ],
    );
  }
}
```

## Restyling one toggle

`style` takes a `ToggleTheme` that is merged over the variant's theme, so it only says what is different: here, what the toggle looks like when it is on.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ToggleStyleExample extends StatefulWidget {
  const ToggleStyleExample({super.key});

  @override
  State<ToggleStyleExample> createState() => _ToggleStyleExampleState();
}

class _ToggleStyleExampleState extends State<ToggleStyleExample> {
  bool pinned = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Toggle.outline(
      value: pinned,
      // Only what is on changes: off, hovered and focused are the theme's.
      style: ToggleTheme(
        selectedBackgroundColor: scheme.primary,
        selectedHoverBackgroundColor: scheme.primary.withValues(alpha: .85),
        selectedForegroundColor: scheme.primaryForeground,
      ),
      onChanged: (value) => setState(() => pinned = value),
      leading: PhosphorIcon(
        pinned ? PhosphorIconsFill.pushPin : PhosphorIconsRegular.pushPin,
      ),
      child: Text(pinned ? 'Pinned' : 'Pin'),
    );
  }
}
```
