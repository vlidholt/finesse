import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/list_section/list_section_form.dart';
import 'package:example/docs/examples/list_section/list_section_plain.dart';
import 'package:example/docs/examples/list_section/list_section_settings.dart';
import 'package:example/docs/examples/list_section/list_section_sliver.dart';

final listSectionDoc = ComponentDoc(
  slug: 'list_section',
  title: 'List Section',
  description:
      'A group of rows under one heading: the grouped list of a settings '
      'page, the sections of a form, a menu of destinations.',
  examples: [
    ComponentExample(
      id: 'list_section_settings',
      title: 'Settings',
      description:
          'Rows on a card with a header above and a footer below. A hairline '
          'separates two rows and starts where the text does. The rows are '
          '`ListTile`, `SwitchListTile` and `RadioListTile`: the whole row is '
          'the target, and on a phone it is at least a touch target tall.',
      minPreviewHeight: 620,
      builder: (_) => const ListSectionSettingsExample(),
    ),
    ComponentExample(
      id: 'list_section_form',
      title: 'A form',
      description:
          'A form row is a `ListTile` with a control as its `trailing`. '
          '`headerTrailing` puts a link at the end of the heading.',
      minPreviewHeight: 320,
      builder: (_) => const ListSectionFormExample(),
    ),
    ComponentExample(
      id: 'list_section_plain',
      title: 'Plain',
      description:
          '`ListSectionVariant.plain` drops the card: rows run from edge to '
          'edge with only hairlines between them.',
      minPreviewHeight: 320,
      builder: (_) => const ListSectionPlainExample(),
    ),
    ComponentExample(
      id: 'list_section_sliver',
      title: 'Long lists',
      description:
          'A `ListSection` builds all of its rows. `SliverListSection` is the '
          'same section as a sliver of a `CustomScrollView`, and '
          '`SliverListSection.builder` builds its rows as they scroll into '
          'view: the card is one decoration behind them, and no row is '
          'clipped or composited on its own.',
      minPreviewHeight: 460,
      builder: (_) => const ListSectionSliverExample(),
    ),
  ],
);
