import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/button_group/button_group_basic.dart';
import 'package:example/docs/examples/button_group/button_group_split.dart';
import 'package:example/docs/examples/button_group/button_group_text.dart';
import 'package:example/docs/examples/button_group/button_group_vertical.dart';

final buttonGroupDoc = ComponentDoc(
  slug: 'button_group',
  title: 'Button Group',
  description:
      'Joins buttons into one control. The children keep their own variant '
      'and size; where two meet, the corners are squared and two outlines '
      'share one hairline. `Button`, `IconButton` and `Toggle` do that by '
      'themselves inside a group.',
  examples: [
    ComponentExample(
      id: 'button_group_basic',
      title: 'Default',
      description:
          'Every child is a Tab stop, and the one with the focus is painted '
          'last, so its ring lies over its neighbours. In a group an icon '
          'button is a segment of the bar, not a circle.',
      builder: (_) => const ButtonGroupBasicExample(),
    ),
    ComponentExample(
      id: 'button_group_split',
      title: 'Split button',
      description:
          'A split button is a group of an action and a menu. Children '
          'with no outline run into each other, so a '
          '`ButtonGroupSeparator` draws the line between them. A child may '
          'be a button inside something else, like the `DropdownMenu` '
          'here; the rows of the menu it opens are not part of the group.',
      builder: (_) => const ButtonGroupSplitExample(),
    ),
    ComponentExample(
      id: 'button_group_text',
      title: 'With a label',
      description:
          '`ButtonGroupText` is a label with the outline of a button on a '
          'muted fill: a unit, a prefix, a value between a minus and a '
          'plus. Every child is as tall as the tallest.',
      builder: (_) => const ButtonGroupTextExample(),
    ),
    ComponentExample(
      id: 'button_group_vertical',
      title: 'Vertical, and toggles',
      description:
          '`axis: Axis.vertical` stacks the children, each as wide as the '
          'widest. A `ToggleGroup` with `gap: 0` is joined through the same '
          '`ButtonGroupScope`, which a control of your own can read too.',
      builder: (_) => const ButtonGroupVerticalExample(),
    ),
  ],
);
