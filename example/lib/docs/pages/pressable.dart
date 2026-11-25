import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/pressable/pressable_choice.dart';
import 'package:example/docs/examples/pressable/pressable_states.dart';

final pressableDoc = ComponentDoc(
  slug: 'pressable',
  title: 'Pressable',
  description:
      'The behaviour underneath everything that is pressed — `Button`, '
      '`IconButton`, `Toggle`, `Chip`, `ListTile`, the navigation bars — '
      'for building a control of your own. A `Pressable` handles pointer '
      'and keyboard activation, the press response, the cursor and button '
      'semantics, and hands its interaction states to a builder. It paints '
      'nothing itself. `FocusRing` draws the focus ring of the theme around '
      'whatever the builder returns, and `AnimatedFill` fades its fill '
      'between states.',
  examples: [
    ComponentExample(
      id: 'pressable_states',
      title: 'Interaction states',
      description:
          'The builder receives a set of `WidgetState`s: `hovered`, '
          '`pressed`, `focused`, `selected` and `disabled`. Activate the '
          'focused region with Enter or Space.',
      builder: (_) => const PressableStatesExample(),
    ),
    ComponentExample(
      id: 'pressable_choice',
      title: 'Selected and disabled',
      description:
          'Pass `selected` for one of a set, or `toggled` for a region that '
          'stays on. With no `onPressed` the region is disabled: no focus, '
          'the basic cursor, and `WidgetState.disabled` in the set; '
          '`enabled` says otherwise in either direction. A '
          '`statesController` shares the states with whoever else follows '
          'them, `onHover` and `onFocusChange` report the two, and '
          '`semanticContainer` makes the region a semantics node of its '
          'own, as a button is.',
      minPreviewHeight: 300,
      builder: (_) => const PressableChoiceExample(),
    ),
  ],
);
