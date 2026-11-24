import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/divider/divider_basic.dart';

final dividerDoc = ComponentDoc(
  slug: 'divider',
  title: 'Divider',
  description:
      'A `Divider` is a hairline that separates content, horizontally or '
      'vertically.',
  examples: [
    ComponentExample(
      id: 'divider_basic',
      title: 'Default',
      builder: (_) => const DividerBasicExample(),
    ),
  ],
);
