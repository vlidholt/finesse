import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/toggle/toggle_basic.dart';
import 'package:example/docs/examples/toggle/toggle_outline.dart';
import 'package:example/docs/examples/toggle/toggle_style.dart';

final toggleDoc = ComponentDoc(
  slug: 'toggle',
  title: 'Toggle',
  description: 'A two-state button that can be either on or off.',
  examples: [
    ComponentExample(
      id: 'toggle_basic',
      title: 'Default',
      builder: (_) => const ToggleBasicExample(),
    ),
    ComponentExample(
      id: 'toggle_outline',
      title: 'Outline',
      description: 'A bordered toggle with a subtle shadow.',
      builder: (_) => const ToggleOutlineExample(),
    ),
    ComponentExample(
      id: 'toggle_style',
      title: 'Restyling one toggle',
      description:
          '`style` takes a `ToggleTheme` that is merged over the variant\'s '
          'theme, so it only says what is different: here, what the toggle '
          'looks like when it is on.',
      builder: (_) => const ToggleStyleExample(),
    ),
  ],
);
