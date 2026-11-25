import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/menubar/menubar_basic.dart';

final menubarDoc = ComponentDoc(
  slug: 'menubar',
  title: 'Menubar',
  description: 'A visually persistent menu, common in desktop applications.',
  examples: [
    ComponentExample(
      id: 'menubar_basic',
      title: 'Default',
      description:
          'Each menu takes the rows of any other menu: shortcuts, checkbox '
          'rows under View, a radio group under Profiles.',
      minPreviewHeight: 320,
      builder: (_) => const MenubarBasicExample(),
    ),
  ],
);
