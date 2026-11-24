import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/divider/divider_basic.dart';

final separatorDoc = ComponentDoc(
  slug: 'separator',
  title: 'Separator',
  description: 'Visually or semantically separates content.',
  examples: [
    ComponentExample(
      id: 'separator_basic',
      title: 'Default',
      builder: (_) => const SeparatorBasicExample(),
    ),
  ],
);
