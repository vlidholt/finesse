import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/pressable/pressable_choice.dart';
import 'package:example/docs/examples/pressable/pressable_states.dart';

final pressableDoc = ComponentDoc(
  slug: 'pressable',
  title: 'Pressable',
  description:
      'The behaviour underneath `Chip`, `ListTile` and the navigation '
      'bars, for building a control of your own. A `Pressable` handles '
      'pointer and keyboard activation, the cursor and button semantics, '
      'and hands its interaction states to a builder. It paints nothing '
      'itself. `FocusRing` draws the focus ring of the theme around whatever '
      'the builder returns.',
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
          'Pass `selected` for one of a set. With no `onPressed` the '
          'region is disabled: no focus, the basic cursor, and '
          '`WidgetState.disabled` in the set.',
      minPreviewHeight: 300,
      builder: (_) => const PressableChoiceExample(),
    ),
  ],
);
