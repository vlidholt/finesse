import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/list_tile/list_tile_basic.dart';
import 'package:example/docs/examples/list_tile/list_tile_selectable.dart';
import 'package:example/docs/examples/list_tile/list_tile_settings.dart';

final listTileDoc = ComponentDoc(
  slug: 'list_tile',
  title: 'List Tile',
  description:
      'A row with a leading widget, a title, a subtitle and a trailing '
      'widget: a conversation, a person to follow, a shared file, a '
      'settings entry.',
  examples: [
    ComponentExample(
      id: 'list_tile_basic',
      title: 'Leading, subtitle and trailing',
      description:
          'The title and subtitle each truncate to one line by default, '
          'so a long name never pushes the trailing widget out.',
      minPreviewHeight: 300,
      builder: (_) => const ListTileBasicExample(),
    ),
    ComponentExample(
      id: 'list_tile_selectable',
      title: 'Tappable and selected',
      description:
          'With an `onTap` the row highlights under the pointer and takes '
          'keyboard focus. `selected` marks the current row of a list.',
      minPreviewHeight: 340,
      builder: (_) => const ListTileSelectableExample(),
    ),
    ComponentExample(
      id: 'list_tile_settings',
      title: 'Settings',
      description:
          '`subtitleMaxLines` lets the second line wrap. A row with a '
          'control at the end leaves `onTap` out, so the control is the '
          'only target.',
      minPreviewHeight: 300,
      builder: (_) => const ListTileSettingsExample(),
    ),
  ],
);
