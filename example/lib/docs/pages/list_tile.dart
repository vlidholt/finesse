import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/list_tile/list_tile_basic.dart';
import 'package:example/docs/examples/list_tile/list_tile_controls.dart';
import 'package:example/docs/examples/list_tile/list_tile_selectable.dart';
import 'package:example/docs/examples/list_tile/list_tile_settings.dart';
import 'package:example/docs/examples/list_tile/list_tile_value.dart';

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
          'only target; `showChevron` ends a row that leads somewhere.',
      minPreviewHeight: 300,
      builder: (_) => const ListTileSettingsExample(),
    ),
    ComponentExample(
      id: 'list_tile_value',
      title: 'Value, chevron, destructive and disabled',
      description:
          '`value` is the quiet text before the trailing widget: it takes '
          'the room it needs, up to a little under half the row, and never '
          'pushes the title out. `showChevron` marks a row that leads '
          'somewhere, `destructive` one that cannot be undone, and '
          '`enabled: false` dims a row and takes it out of the focus order.',
      minPreviewHeight: 320,
      builder: (_) => const ListTileValueExample(),
    ),
    ComponentExample(
      id: 'list_tile_controls',
      title: 'Switch, checkbox and radio rows',
      description:
          '`SwitchListTile`, `CheckboxListTile` and `RadioListTile` make '
          'the whole row the control: one target, one focus stop, one '
          'thing for a screen reader to announce. A tristate checkbox '
          'shows a dash for "some". Radio rows are the choices of the '
          '`UnaRadioGroup` around their section.',
      minPreviewHeight: 640,
      builder: (_) => const ListTileControlsExample(),
    ),
  ],
);
