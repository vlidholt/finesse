import 'package:example/docs/docs.dart';
import 'package:example/docs/examples/dropdown_menu/dropdown_menu_basic.dart';
import 'package:example/docs/examples/dropdown_menu/dropdown_menu_checkable.dart';

final dropdownMenuDoc = ComponentDoc(
  slug: 'dropdown_menu',
  title: 'Dropdown Menu',
  description:
      'A menu that opens from a trigger. It flips to stay on screen, scrolls '
      'when long, and supports keyboard navigation and type-ahead.',
  examples: [
    ComponentExample(
      id: 'dropdown_menu_basic',
      title: 'Default',
      description:
          'A label, shortcuts written the way the platform writes them, a '
          'submenu and a destructive row.',
      minPreviewHeight: 320,
      builder: (_) => const DropdownMenuBasicExample(),
    ),
    ComponentExample(
      id: 'dropdown_menu_checkable',
      title: 'Checkbox and radio items',
      description:
          'Checkable rows are controlled. A click toggles one and closes the '
          'menu like any row; Space toggles it and keeps the menu open, so '
          'several can be set in one visit. Every row of the menu keeps the '
          'column of the check marks free and the labels line up.',
      minPreviewHeight: 380,
      builder: (_) => const DropdownMenuCheckableExample(),
    ),
  ],
);
