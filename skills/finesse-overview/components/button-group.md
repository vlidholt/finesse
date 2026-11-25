# Button Group

Joins buttons into one control. The children keep their own variant and size; where two meet, the corners are squared and two outlines share one hairline. `Button`, `IconButton` and `Toggle` do that by themselves inside a group.

## Default

Every child is a Tab stop, and the one with the focus is painted last, so its ring lies over its neighbours. In a group an icon button is a segment of the bar, not a circle.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGroupBasicExample extends StatelessWidget {
  const ButtonGroupBasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonGroup(
      semanticLabel: 'Message actions',
      children: [
        Button.outline(onPressed: () {}, child: const Text('Archive')),
        Button.outline(onPressed: () {}, child: const Text('Report')),
        Button.outline(onPressed: () {}, child: const Text('Snooze')),
        IconButton.outline(
          tooltip: 'More',
          onPressed: () {},
          icon: const PhosphorIcon(PhosphorIconsRegular.dotsThree),
        ),
      ],
    );
  }
}
```

## Split button

A split button is a group of an action and a menu. Children with no outline run into each other, so a `ButtonGroupSeparator` draws the line between them. A child may be a button inside something else, like the `DropdownMenu` here; the rows of the menu it opens are not part of the group.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGroupSplitExample extends StatelessWidget {
  const ButtonGroupSplitExample({super.key});

  @override
  Widget build(BuildContext context) {
    // A split button is a group, not a widget of its own: the action, a
    // separator (these two have no outline to share) and a menu.
    return ButtonGroup(
      children: [
        Button.secondary(onPressed: () {}, child: const Text('Send')),
        const ButtonGroupSeparator(),
        DropdownMenu(
          items: [
            MenuItem(
              leading: const PhosphorIcon(PhosphorIconsRegular.clock),
              onPressed: () {},
              child: const Text('Send later'),
            ),
            MenuItem(
              leading: const PhosphorIcon(PhosphorIconsRegular.floppyDisk),
              onPressed: () {},
              child: const Text('Save as draft'),
            ),
          ],
          builder: (context, controller, _) => IconButton.secondary(
            tooltip: 'More ways to send',
            onPressed: controller.toggle,
            icon: const PhosphorIcon(PhosphorIconsRegular.caretDown),
          ),
        ),
      ],
    );
  }
}
```

## With a label

`ButtonGroupText` is a label with the outline of a button on a muted fill: a unit, a prefix, a value between a minus and a plus. Every child is as tall as the tallest.

```dart
import 'package:finesse/finesse.dart';
import 'package:flutter/widgets.dart';

class ButtonGroupTextExample extends StatefulWidget {
  const ButtonGroupTextExample({super.key});

  @override
  State<ButtonGroupTextExample> createState() => _ButtonGroupTextExampleState();
}

class _ButtonGroupTextExampleState extends State<ButtonGroupTextExample> {
  var _guests = 2;

  @override
  Widget build(BuildContext context) {
    return ButtonGroup(
      semanticLabel: 'Guests',
      children: [
        IconButton.outline(
          tooltip: 'One fewer',
          enabled: _guests > 1,
          onPressed: () => setState(() => _guests--),
          icon: const PhosphorIcon(PhosphorIconsRegular.minus),
        ),
        // A label that sits in the group like a button.
        ButtonGroupText(
          child: Text('$_guests ${_guests == 1 ? 'guest' : 'guests'}'),
        ),
        IconButton.outline(
          tooltip: 'One more',
          onPressed: () => setState(() => _guests++),
          icon: const PhosphorIcon(PhosphorIconsRegular.plus),
        ),
      ],
    );
  }
}
```

## Vertical, and toggles

`axis: Axis.vertical` stacks the children, each as wide as the widest. A `ToggleGroup` with `gap: 0` is joined through the same `ButtonGroupScope`, which a control of your own can read too.

```dart
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
          toggleVariant: ToggleVariant.outline,
          values: _marks,
          onChanged: (marks) => setState(() => _marks = marks),
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
        ),
      ],
    );
  }
}
```

