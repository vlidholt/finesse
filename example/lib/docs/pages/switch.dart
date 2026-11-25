import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/switch/switch_basic.dart';
import 'package:example/docs/examples/switch/switch_description.dart';

final switchDoc = ComponentDoc(
  slug: 'switch',
  title: 'Switch',
  description:
      'A control that allows the user to toggle between checked and not '
      'checked.',
  examples: [
    ComponentExample(
      id: 'switch_basic',
      title: 'Default',
      builder: (_) => const SwitchBasicExample(),
    ),
    ComponentExample(
      id: 'switch_description',
      title: 'Description and side',
      description:
          '`description` is a muted line under the label; '
          '`controlAffinity` puts the switch before or after them. '
          '`Checkbox` and `Radio` take the same two.',
      builder: (_) => const SwitchDescriptionExample(),
    ),
  ],
);
